#ifndef ROUTEADAPTER_H
#define ROUTEADAPTER_H

#include "frontendex/route.h"

#include <QGeoRectangle>
#include <QObject>
#include <QtLocation/QGeoRoute>
#include <QtQml/QQmlEngine>

class RouteAdapter : public QObject
{
    Q_OBJECT
    QML_ELEMENT
    QML_SINGLETON

public:
    Q_INVOKABLE QGeoRoute toGeoRoute(const com::spyro_soft::wavey::navigation_iface::Route &route) const;
};

#endif  // ROUTEADAPTER_H
