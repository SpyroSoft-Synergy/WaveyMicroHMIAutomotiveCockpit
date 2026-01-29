#include "navigationcache.h"

namespace {
constexpr static const qint32 kMinDistance = 15;  // meters
}

NavigationCache::NavigationCache(QObject *parent) : QObject{parent} {}

QGeoLocation NavigationCache::getLocation(const QGeoCoordinate &coord) const
{
    using namespace std::placeholders;
    const auto foundLocation =
        std::find_if(m_cache.begin(), m_cache.end(), std::bind(&NavigationCache::isNearby, _1, coord));
    return foundLocation != m_cache.end() ? foundLocation->m_location : QGeoLocation();
}

void NavigationCache::addLocation(const QGeoLocation &location, const QGeoCoordinate &sampleCoordinate)
{
    m_cache.push_back(Location{location, sampleCoordinate});
}

bool NavigationCache::isNearby(const Location &location, const QGeoCoordinate &coord)
{
    return location.m_coordinate.distanceTo(coord) < kMinDistance ||
           location.m_location.coordinate().distanceTo(coord) < kMinDistance;
}
