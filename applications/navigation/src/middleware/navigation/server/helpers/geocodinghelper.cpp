#include "geocodinghelper.h"

#include "navigationcache.h"

#include <QGeoCodingManager>

namespace {
constexpr static const qint32 kMsBetweenQueries = 1200;
}

GeoCodingHelper::GeoCodingHelper(QGeoCodingManager *manager, const std::shared_ptr<NavigationCache> &cache)
    : m_manager(manager),
      m_lastQuery(std::chrono::system_clock::now() - std::chrono::milliseconds(kMsBetweenQueries)),
      m_cache(cache)
{
    // Nominatim, default osm geocoding service, limits number of request per minute from single client.
    // TOS states that we need to wait at least 1s between requests, timer additionally waits 200ms just
    // to be sure, because otherwise IP gets banned and we don't get any replies back.
    m_queryTimer.setInterval(kMsBetweenQueries);
    m_queryTimer.setSingleShot(false);
    m_queryTimer.callOnTimeout(this, &GeoCodingHelper::sendQuery);
}

GeoCodingHelper::~GeoCodingHelper() = default;

void GeoCodingHelper::reverseGeocode(const QGeoCoordinate &coordinate, const std::function<void(QGeoLocation)> callback)
{
    using namespace std::chrono;

    const auto cachedLocation = m_cache->getLocation(coordinate);
    if (!cachedLocation.isEmpty()) {
        callback(cachedLocation);
    } else {
        const Query query{coordinate, callback};
        if (m_queries.empty()) {
            const milliseconds::rep remainingWaitTime =
                kMsBetweenQueries - duration_cast<milliseconds>(m_lastQuery - system_clock::now()).count();
            m_queryTimer.start(std::max(remainingWaitTime, static_cast<milliseconds::rep>(0)));
        }

        m_queries.push(query);
    }
}

void GeoCodingHelper::clearQueue()
{
    std::queue<Query> empty;
    m_queries.swap(empty);
    m_queryTimer.stop();
}

void GeoCodingHelper::sendQuery()
{
    const Query query = m_queries.front();
    m_queries.pop();

    if (QGeoCodeReply *reply = m_manager->reverseGeocode(query.coordinate)) {
        QObject::connect(reply, &QGeoCodeReply::finished, m_manager,
                         std::bind(&GeoCodingHelper::receiveReply, this, query, reply));
        m_lastQuery = std::chrono::system_clock::now();
    }

    if (m_queries.empty())
        m_queryTimer.stop();
}

void GeoCodingHelper::receiveReply(const Query &query, QGeoCodeReply *reply)
{
    if (reply->error() != QGeoCodeReply::NoError)
        qWarning() << "Nominatim returned error:" << reply->errorString();

    const auto locations = reply->locations();
    if (!locations.empty()) {
        const QGeoLocation location = locations.first();
        m_cache->addLocation(location, query.coordinate);
        query.callback(location);
    }
    reply->deleteLater();
}
