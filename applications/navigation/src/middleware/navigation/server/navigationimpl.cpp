#include "navigationimpl.h"

#include "geopoint.h"

#include <QGeoAddress>
#include <QGeoLocation>
#include <QGeoManeuver>
#include <QGeoRectangle>
#include <QGeoRouteSegment>
#include <QGeoRoutingManager>
#include <QTimer>

#include <cmath>

namespace {
constexpr static const qreal kPinchSentitivity = 0.8;
constexpr static const qreal kMinZoomLevel = 20;
constexpr static const qreal kMaxZoomLevel = 10;
constexpr static const qreal kDefaultZoomLevel = 15;
constexpr static const qreal kStreetFetchLimit = 3;
constexpr static const qreal kMaxMovementMeters = 100;

static const auto kLoadingStreetName = QStringLiteral("Loading...");
}  // namespace

NavigationImpl::NavigationImpl(QObject *parent)
    : NavigationSource(parent), m_zoomLevel(kDefaultZoomLevel), m_previousZoomLevel(kDefaultZoomLevel)
{
    NavigationImpl::setSimulatorMode(true);
}

NavigationImpl::~NavigationImpl() = default;

qreal NavigationImpl::zoomLevel() const
{
    return m_zoomLevel;
}

Route NavigationImpl::currentRoute() const
{
    return m_currentRoute;
}

QVariantList NavigationImpl::directions() const
{
    QVariantList list;
    std::transform(m_currentDirections.begin(), m_currentDirections.end(), std::inserter(list, list.begin()),
                   [](const std::shared_ptr<DirectionsStep> step) {
                       if (step)
                           return QVariant::fromValue(*step);
                       else
                           return QVariant::fromValue(DirectionsStep());
                   });

    return list;
}

GeoPoint NavigationImpl::position() const
{
    return toGeoPoint(m_serviceProvider->getPosition());
}

qreal NavigationImpl::rotation() const
{
    return m_serviceProvider->getRotation();
}

QVariant NavigationImpl::updateZoom(qreal pinchScale)
{
    if (!qIsNull(pinchScale)) {
        const qreal pinchFactor = (pinchScale - 1) * kPinchSentitivity + 1;
        m_zoomLevel =
            std::max(std::min((m_previousZoomLevel - kMaxZoomLevel) * pinchFactor + kMaxZoomLevel, kMinZoomLevel),
                     kMaxZoomLevel);
        Q_EMIT zoomLevelChanged(m_zoomLevel);
    }
    return true;
}

QVariant NavigationImpl::stopZoom()
{
    m_previousZoomLevel = m_zoomLevel;
    return true;
}

QVariant NavigationImpl::setDestination(const GeoPoint &point)
{
    using namespace std::placeholders;

    m_serviceProvider->calculateRoute(toGeoCoordinate(point), std::bind(&NavigationImpl::updateRoute, this, _1));
    return true;
}

QVariant NavigationImpl::setDestinationLatLong(qreal latitude, qreal longitude)
{
    return setDestination(GeoPoint(latitude, longitude));
}

QVariant NavigationImpl::popDirectionsStep()
{
    using namespace std::placeholders;

    if (m_currentDirections.size() > 0) {
        m_currentDirections.pop_front();

        const auto fetchIndex = kStreetFetchLimit - 1;
        if (m_currentDirections.size() > kStreetFetchLimit) {
            const std::shared_ptr<DirectionsStep> directionStep = m_currentDirections.at(fetchIndex);
            const GeoPoint referencePoint = directionStep->referencePoint();
            m_serviceProvider->reverseGeocode(toGeoCoordinate(referencePoint),
                                              std::bind(&NavigationImpl::updateStreetName, this, _1, directionStep));
        }
    }

    return true;
}

QVariant NavigationImpl::setSimulatorMode(bool value)
{
    if (m_serviceProvider) {
        if (auto *oldProvider = dynamic_cast<QObject *>(m_serviceProvider.get())) {
            disconnect(oldProvider, nullptr, nullptr, nullptr);
        }
    }

    m_serviceProvider = m_serviceProviderFactory.getNavigationServiceProvider(
        value ? NavigationServiceProviderFactory::Type::Simulator : NavigationServiceProviderFactory::Type::Osm);

    auto *newProvider = dynamic_cast<QObject *>(m_serviceProvider.get());
    if (!newProvider) {
        qCritical() << "Failed to cast navigation service provider to QObject";
        return QVariant{};
    }

    const bool connected = connect(newProvider, SIGNAL(positionChanged()), this, SLOT(reemitPositionChanged()));
    if (!connected) {
        qWarning() << "Failed to connect positionChanged signal";
        return QVariant{};
    }

    return true;
}

void NavigationImpl::reemitPositionChanged()
{
    const auto currentPosition = toGeoCoordinate(position());
    const auto distanceTravelled = currentPosition.distanceTo(m_previousPosition);
    if (distanceTravelled < kMaxMovementMeters) {
        m_currentRoute.setDistanceTravelled(m_currentRoute.distanceTravelled() + distanceTravelled);
    }
    m_previousPosition = currentPosition;

    Q_EMIT currentRouteChanged(currentRoute());
    Q_EMIT positionChanged(position());
    Q_EMIT rotationChanged(rotation());
}

Route NavigationImpl::parseGeoRoute(const QGeoRoute &geoRoute) const
{
    Route route;
    route.setId(geoRoute.routeId());
    route.setBounds(QVariant::fromValue(geoRoute.bounds()));
    route.setTravelTime(geoRoute.travelTime());
    route.setDistance(geoRoute.distance());

    QVariantList path;
    const auto currentPath = geoRoute.path();
    std::transform(currentPath.begin(), currentPath.end(), std::inserter(path, path.begin()),
                   [this](const QGeoCoordinate &coord) { return QVariant::fromValue(toGeoPoint(coord)); });
    route.setPath(path);

    return route;
}

QVector<std::shared_ptr<DirectionsStep>> NavigationImpl::parseDirections(const QGeoRoute &geoRoute)
{
    using namespace com::spyro_soft::wavey::navigation_iface;
    using namespace std::placeholders;

    QVector<std::shared_ptr<DirectionsStep>> directions;
    for (const QGeoRouteSegment &segment : geoRoute.segments()) {
        const QGeoManeuver &maneuver = segment.maneuver();
        auto directionStep = std::make_shared<DirectionsStep>();

        switch (maneuver.direction()) {
        case QGeoManeuver::NoDirection:
        case QGeoManeuver::DirectionForward:
            directionStep->setDirection(Navigation_iface::Direction::Up);
            break;
        case QGeoManeuver::DirectionBearRight:
        case QGeoManeuver::DirectionLightRight:
        case QGeoManeuver::DirectionRight:
        case QGeoManeuver::DirectionHardRight:
            directionStep->setDirection(Navigation_iface::Direction::Right);
            break;
        case QGeoManeuver::DirectionUTurnRight:
        case QGeoManeuver::DirectionUTurnLeft:
            directionStep->setDirection(Navigation_iface::Direction::Down);
            break;
        case QGeoManeuver::DirectionHardLeft:
        case QGeoManeuver::DirectionLeft:
        case QGeoManeuver::DirectionLightLeft:
        case QGeoManeuver::DirectionBearLeft:
            directionStep->setDirection(Navigation_iface::Direction::Left);
            break;
        }

        directionStep->setStreetName(kLoadingStreetName);
        directionStep->setDistance(segment.distance());
        directionStep->setReferencePoint(toGeoPoint(maneuver.waypoint()));

        if (directions.size() <= kStreetFetchLimit) {
            m_serviceProvider->reverseGeocode(maneuver.waypoint(),
                                              std::bind(&NavigationImpl::updateStreetName, this, _1, directionStep));
        }

        directions.push_back(directionStep);
    }

    return directions;
}

void NavigationImpl::updateRoute(const QGeoRoute &route)
{
    m_currentRoute = parseGeoRoute(route);
    m_currentDirections = parseDirections(route);

    Q_EMIT currentRouteChanged(m_currentRoute);
    Q_EMIT directionsChanged(directions());
    Q_EMIT newRouteStarted();

    const auto currentPath = m_currentRoute.path();
    if (currentPath.isEmpty()) {
        qWarning() << "Changed route but destination is unavailable";
        return;
    }
    qInfo() << "Changed route. Destination:" << toGeoCoordinate(currentPath.last().value<GeoPoint>());
}

void NavigationImpl::updateStreetName(const QGeoLocation &location, const std::shared_ptr<DirectionsStep> directionStep)
{
    if (location.isEmpty()) {
        directionStep->setStreetName(QString());
    } else {
        directionStep->setStreetName(location.address().street());
    }

    Q_EMIT directionsChanged(directions());
}

QGeoCoordinate NavigationImpl::toGeoCoordinate(const GeoPoint &point) const
{
    return QGeoCoordinate(point.latitude(), point.longitude());
}

GeoPoint NavigationImpl::toGeoPoint(const QGeoCoordinate &coordinate) const
{
    return GeoPoint(coordinate.latitude(), coordinate.longitude());
}
