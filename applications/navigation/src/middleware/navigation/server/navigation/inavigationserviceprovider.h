#ifndef INAVIGATIONSERVICEPROVIDER_H
#define INAVIGATIONSERVICEPROVIDER_H

#include <QGeoLocation>
#include <QGeoRoute>

#include <functional>

class INavigationServiceProvider
{
public:
    virtual void calculateRoute(const QGeoCoordinate &destination, const std::function<void(QGeoRoute)> callback) = 0;
    virtual void reverseGeocode(const QGeoCoordinate &position, const std::function<void(QGeoLocation)> callback) = 0;
    virtual QGeoCoordinate getPosition() const = 0;
    virtual qreal getRotation() const = 0;

    virtual void positionChanged() = 0;

    virtual ~INavigationServiceProvider() = default;
};

#endif  // INAVIGATIONSERVICEPROVIDER_H
