#ifndef GEOCODINGHELPER_H
#define GEOCODINGHELPER_H

#include <QGeoCoordinate>
#include <QGeoLocation>
#include <QObject>
#include <QTimer>
#include <queue>

#include <chrono>

class QGeoCodingManager;
class QGeoCodeReply;
class NavigationCache;

class GeoCodingHelper : public QObject
{
    Q_OBJECT

public:
    GeoCodingHelper(QGeoCodingManager *manager, const std::shared_ptr<NavigationCache> &cache);
    ~GeoCodingHelper();

    void reverseGeocode(const QGeoCoordinate &coordinate, const std::function<void(QGeoLocation)> callback);
    void clearQueue();

private:
    struct Query
    {
        QGeoCoordinate coordinate;
        std::function<void(QGeoLocation)> callback;
    };

    void sendQuery();
    void receiveReply(const Query &query, QGeoCodeReply *reply);

    std::shared_ptr<NavigationCache> m_cache;
    std::queue<Query> m_queries;
    QGeoCodingManager *m_manager;
    QTimer m_queryTimer;
    std::chrono::time_point<std::chrono::system_clock> m_lastQuery;
};

#endif  // GEOCODINGHELPER_H
