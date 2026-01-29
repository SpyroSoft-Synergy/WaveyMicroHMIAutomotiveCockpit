#ifndef NAVIGATIONCACHE_H
#define NAVIGATIONCACHE_H

#include <QCache>
#include <QGeoCoordinate>
#include <QGeoLocation>
#include <QObject>

class NavigationCache : public QObject
{
    Q_OBJECT

public:
    explicit NavigationCache(QObject *parent = nullptr);

    QGeoLocation getLocation(const QGeoCoordinate &coord) const;
    void addLocation(const QGeoLocation &location, const QGeoCoordinate &sampleCoordinate);

private:
    struct Location
    {
        QGeoLocation m_location;
        QGeoCoordinate m_coordinate;
    };

    static bool isNearby(const Location &location, const QGeoCoordinate &coord);

    // TODO: add some persistent form of cache
    QVector<Location> m_cache;
};

#endif  // NAVIGATIONCACHE_H
