#include "osmnavigationserviceprovider.h"

#include "helpers/geocodinghelper.h"
#include "helpers/navigationcache.h"

#include <QGeoRouteRequest>
#include <QGeoRoutingManager>
#include <QGeoServiceProvider>

namespace {
static const QGeoCoordinate kOfficeGeoCoordinate = QGeoCoordinate(53.449946777198406, 14.535589645779803);
}

OsmNavigationServiceProvider::OsmNavigationServiceProvider()
    : m_navigationCache(std::make_shared<NavigationCache>()),
      m_geoServiceProvider(std::make_unique<QGeoServiceProvider>("osm")),
      m_geoCodingHelper(std::make_unique<GeoCodingHelper>(m_geoServiceProvider->geocodingManager(), m_navigationCache)),
      m_positionSource(std::unique_ptr<QGeoPositionInfoSource>(QGeoPositionInfoSource::createDefaultSource(nullptr)))
{
    connect(m_positionSource.get(), &QGeoPositionInfoSource::positionUpdated, this,
            &OsmNavigationServiceProvider::positionChanged);
    m_positionSource->startUpdates();
}

OsmNavigationServiceProvider::~OsmNavigationServiceProvider() = default;

void OsmNavigationServiceProvider::calculateRoute(const QGeoCoordinate &destination,
                                                  const std::function<void(QGeoRoute)> callback)
{
    const auto reportError = [callback](const QString &msg, bool critical = true) {
        if (critical) {
            qCritical() << msg;
        } else {
            qWarning() << msg;
        }
        callback(QGeoRoute());
    };

    const auto manager = m_geoServiceProvider->routingManager();
    if (!manager) {
        reportError("Failed to get routing manager from geo service provider");
        return;
    }

    QList<QGeoCoordinate> route{kOfficeGeoCoordinate, destination};
    auto *reply = manager->calculateRoute(QGeoRouteRequest(route));

    if (!reply) {
        reportError(QStringLiteral("Failed to create route calculation request for destination: %1")
                        .arg(destination.toString()));
        return;
    }

    m_geoCodingHelper->clearQueue();
    connect(reply, &QGeoRouteReply::finished, this, [reply, callback, reportError] {
        const auto routes = reply->routes();
        if (routes.size() > 0) {
            callback(routes.first());
        } else {
            reportError(QStringLiteral("Route calculation failed. Error: %1, Message: %2")
                            .arg(reply->error())
                            .arg(reply->errorString()),
                        false);
        }
        reply->deleteLater();
    });
}

void OsmNavigationServiceProvider::reverseGeocode(const QGeoCoordinate &position,
                                                  const std::function<void(QGeoLocation)> callback)
{
    m_geoCodingHelper->reverseGeocode(position, callback);
}

QGeoCoordinate OsmNavigationServiceProvider::getPosition() const
{
    if (m_positionSource && m_positionSource->lastKnownPosition().isValid())
        return m_positionSource->lastKnownPosition().coordinate();
    return kOfficeGeoCoordinate;
}

qreal OsmNavigationServiceProvider::getRotation() const
{
    if (m_positionSource && m_positionSource->lastKnownPosition().isValid())
        return m_positionSource->lastKnownPosition().attribute(QGeoPositionInfo::Attribute::Direction);
    return 0;
}
