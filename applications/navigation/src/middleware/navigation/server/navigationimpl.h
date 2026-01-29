#ifndef NAVIGATIONIMPL_H
#define NAVIGATIONIMPL_H

#include "directionsstep.h"
#include "helpers/geocodinghelper.h"
#include "navigation/navigationserviceproviderfactory.h"
#include "rep_navigation_source.h"

#include <QGeoRoute>

using namespace com::spyro_soft::wavey::navigation_iface;

class NavigationImpl : public NavigationSource
{
    Q_OBJECT

public:
    NavigationImpl(QObject *parent = nullptr);
    ~NavigationImpl();

    qreal zoomLevel() const override;
    Route currentRoute() const override;
    QVariantList directions() const override;
    GeoPoint position() const override;
    qreal rotation() const override;

public Q_SLOTS:
    QVariant updateZoom(qreal pinchScale) override;
    QVariant stopZoom() override;

    QVariant setDestination(const com::spyro_soft::wavey::navigation_iface::GeoPoint &point) override;
    QVariant setDestinationLatLong(qreal longitude, qreal latitude) override;
    QVariant popDirectionsStep() override;
    QVariant setSimulatorMode(bool value) override;

private Q_SLOTS:
    void reemitPositionChanged();

private:
    Route parseGeoRoute(const QGeoRoute &geoRoute) const;
    QVector<std::shared_ptr<DirectionsStep>> parseDirections(const QGeoRoute &geoRoute);

    void updateRoute(const QGeoRoute &route);
    void updateStreetName(const QGeoLocation &location, const std::shared_ptr<DirectionsStep> direction);

    QGeoCoordinate toGeoCoordinate(const GeoPoint &point) const;
    GeoPoint toGeoPoint(const QGeoCoordinate &coordinate) const;

    NavigationServiceProviderFactory m_serviceProviderFactory;
    std::unique_ptr<INavigationServiceProvider> m_serviceProvider;

    qreal m_zoomLevel;
    qreal m_previousZoomLevel;

    Route m_currentRoute;
    QList<std::shared_ptr<DirectionsStep>> m_currentDirections;

    QGeoCoordinate m_previousPosition;
};

#endif  // NAVIGATIONIMPL_H
