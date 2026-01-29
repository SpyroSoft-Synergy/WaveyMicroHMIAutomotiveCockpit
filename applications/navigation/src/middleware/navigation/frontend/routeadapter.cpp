#include "routeadapter.h"

#include "geopoint.h"

QGeoRoute RouteAdapter::toGeoRoute(const com::spyro_soft::wavey::navigation_iface::Route &route) const
{
    QGeoRoute geoRoute;

    geoRoute.setRouteId(route.id());
    geoRoute.setBounds(route.bounds().value<QGeoRectangle>());
    geoRoute.setTravelTime(route.travelTime());
    geoRoute.setDistance(route.distance());

    QList<QGeoCoordinate> coords;
    const auto &routeCoords = route.path();
    std::transform(routeCoords.begin(), routeCoords.end(), std::inserter(coords, coords.begin()),
                   [](const QVariant &variant) -> QGeoCoordinate {
                       using namespace com::spyro_soft::wavey::navigation_iface;
                       if (!variant.canConvert<GeoPoint>()) {
                           return QGeoCoordinate();
                       }

                       const GeoPoint point = variant.value<GeoPoint>();

                       return QGeoCoordinate(point.latitude(), point.longitude());
                   });
    geoRoute.setPath(coords);

    return geoRoute;
}
