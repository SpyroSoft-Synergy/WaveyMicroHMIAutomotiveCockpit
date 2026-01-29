#ifndef OSMNAVIGATIONSERVICEPROVIDER_H
#define OSMNAVIGATIONSERVICEPROVIDER_H

#include "inavigationserviceprovider.h"

#include <QGeoLocation>
#include <QGeoPositionInfoSource>
#include <QGeoRoute>
#include <QGeoServiceProvider>
#include <QObject>

class GeoCodingHelper;
class NavigationCache;

class OsmNavigationServiceProvider : public QObject, public INavigationServiceProvider
{
    Q_OBJECT

public:
    explicit OsmNavigationServiceProvider();
    ~OsmNavigationServiceProvider();

    void calculateRoute(const QGeoCoordinate &destination, const std::function<void(QGeoRoute)> callback) override;
    void reverseGeocode(const QGeoCoordinate &position, const std::function<void(QGeoLocation)> callback) override;
    QGeoCoordinate getPosition() const override;
    qreal getRotation() const override;

Q_SIGNALS:
    void positionChanged() override;

private:
    std::shared_ptr<NavigationCache> m_navigationCache;
    std::unique_ptr<QGeoServiceProvider> m_geoServiceProvider;
    std::unique_ptr<GeoCodingHelper> m_geoCodingHelper;
    std::unique_ptr<QGeoPositionInfoSource> m_positionSource;
};

#endif  // OSMNAVIGATIONSERVICEPROVIDER_H
