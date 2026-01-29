#include "fakenavigationserviceprovider.h"

#include <QFileInfo>
#include <QGeoManeuver>
#include <QGeoRouteSegment>
#include <QJsonArray>
#include <QJsonDocument>
#include <QJsonObject>

namespace {
constexpr static const qint32 kMinDistanceMeters = 5;
constexpr static const qint32 kMinDestinationDistanceMeters = 200;
constexpr static const qreal kSpeedKmph = 40;
constexpr static const qint32 kPositionUpdateMs = 250;
constexpr static const qreal kMetersPerTick =
    kSpeedKmph * 1000.0 /
    (3600 * (1000 / kPositionUpdateMs));  // speed * meters_in_km / (seconds_in_hour * (ms_in_second / tickrate))
static const QString kFakeRouteId = QStringLiteral("FakeID");
static const QGeoCoordinate kStartPosition = QGeoCoordinate(36.12981621017106, -115.15295743118646);
}  // namespace

FakeNavigationServiceProvider::FakeNavigationServiceProvider()
    : m_existingRoutes(&FakeNavigationServiceProvider::compareCoords),
      m_currentPosition(kStartPosition),
      m_targetPosition(QGeoCoordinate())
{
    readRoutes();
    QObject::startTimer(kPositionUpdateMs);
}

void FakeNavigationServiceProvider::calculateRoute(const QGeoCoordinate &destination,
                                                   const std::function<void(QGeoRoute)> callback)
{
    const auto foundRoute =
        std::find_if(m_existingRoutes.begin(), m_existingRoutes.end(),
                     [destination](const std::pair<QGeoCoordinate, QString> routeInfo) {
                         return routeInfo.first.distanceTo(destination) < kMinDestinationDistanceMeters;
                     });
    if (foundRoute == m_existingRoutes.end())
        return;

    readRoute(foundRoute->second);
    callback(m_currentRoute);
}

void FakeNavigationServiceProvider::reverseGeocode(const QGeoCoordinate &position,
                                                   const std::function<void(QGeoLocation)> callback)
{}

QGeoCoordinate FakeNavigationServiceProvider::getPosition() const
{
    return m_currentPosition;
}

qreal FakeNavigationServiceProvider::getRotation() const
{
    return m_currentPosition.azimuthTo(m_targetPosition);
}

void FakeNavigationServiceProvider::timerEvent(QTimerEvent *event)
{
    Q_UNUSED(event);

    if (m_currentPosition.distanceTo(m_targetPosition) < kMinDistanceMeters) {
        auto currentPath = m_currentRoute.path();
        if (currentPath.size() > 1) {
            const auto foundCoordinate =
                std::find_if(currentPath.begin(), currentPath.end(), [this](const QGeoCoordinate &coordinate) {
                    return coordinate.distanceTo(m_currentPosition) < kMinDistanceMeters;
                });

            if (foundCoordinate != currentPath.end() && std::next(foundCoordinate) != currentPath.end()) {
                m_targetPosition = *std::next(foundCoordinate);
                currentPath.removeFirst();
                m_currentRoute.setPath(currentPath);
            }
        } else {
            m_targetPosition = QGeoCoordinate();
        }
    }

    if (m_targetPosition.isValid()) {
        const qreal azimuth = m_currentPosition.azimuthTo(m_targetPosition);
        m_currentPosition = m_currentPosition.atDistanceAndAzimuth(kMetersPerTick, azimuth);
        Q_EMIT positionChanged();
    }
}

void FakeNavigationServiceProvider::readRoutes()
{
    m_existingRoutes.clear();
    QFile routesJSON = QFile(QStringLiteral(":/routes/routes.json"));
    if (routesJSON.open(QFile::ReadOnly)) {
        const auto json = QJsonDocument().fromJson(routesJSON.readAll()).object();
        const auto routes = json.value("routes").toArray();
        for (const auto &route : routes) {
            const QJsonObject routeObject = route.toObject();
            const QGeoCoordinate coordinate = parseCoordinate(routeObject.value("destination").toString());
            if (coordinate.isValid()) {
                m_existingRoutes[coordinate] = routeObject.value("name").toString();
            }
        }
    }
}

void FakeNavigationServiceProvider::readRoute(const QString &routeName)
{
    const QFileInfo routeFileInfo = QFileInfo(QStringLiteral(":/routes/%1.txt").arg(routeName));
    if (!routeFileInfo.exists() || !routeFileInfo.isFile() || !routeFileInfo.isReadable()) {
        qWarning() << "Tried to read route" << routeName << "which doesn't exist or is invalid.";
        return;
    }

    QFile routeFile = routeFileInfo.absoluteFilePath();
    if (!routeFile.open(QFile::ReadOnly)) {
        qWarning() << "Failed to open route file" << routeFileInfo;
    }

    QList<QGeoCoordinate> path;
    qreal pathLength = 0.0;
    while (!routeFile.atEnd()) {
        const QString line = routeFile.readLine();
        const QStringList coordinates = line.split(QChar(';'));
        for (const QString &coordinateString : coordinates) {
            const QGeoCoordinate coordinate = parseCoordinate(coordinateString);
            if (coordinate.isValid()) {
                if (path.size() >= 1) {
                    const auto &lastCoord = path.last();
                    pathLength += lastCoord.distanceTo(coordinate);
                }

                path.push_back(coordinate);
            }
        }
    }

    QGeoRoute route;
    route.setRouteId(kFakeRouteId);
    route.setPath(path);
    route.setDistance(pathLength);
    route.setTravelTime((pathLength / 1000 / kSpeedKmph) * 60 * 60);

    Q_EMIT positionChanged();

    m_currentRoute = route;
    m_currentPosition = path.first();
    m_targetPosition = path.at(1);

    path.remove(0, 2);
}

QGeoCoordinate FakeNavigationServiceProvider::parseCoordinate(const QString &coordinateString) const
{
    const QStringList coords = coordinateString.split(QChar(','));
    if (coords.size() == 2) {
        bool success;
        const qreal latitude = coords.first().toDouble(&success);
        if (!success)
            return QGeoCoordinate();

        const qreal longitude = coords.last().toDouble(&success);
        if (!success)
            return QGeoCoordinate();

        return QGeoCoordinate(latitude, longitude);
    }

    return QGeoCoordinate();
}

bool FakeNavigationServiceProvider::compareCoords(const QGeoCoordinate &lhs, const QGeoCoordinate &rhs)
{
    return std::make_tuple(lhs.latitude(), lhs.longitude(), lhs.altitude()) <
           std::make_tuple(rhs.latitude(), rhs.longitude(), rhs.altitude());
}
