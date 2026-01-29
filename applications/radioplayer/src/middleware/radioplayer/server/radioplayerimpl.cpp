#include "radioplayerimpl.h"

#include "station.h"

#include <QDir>
#include <QJsonDocument>
#include <QJsonObject>
#include <QJsonArray>
#include <QTimer>

using namespace Qt::Literals::StringLiterals;

namespace {
    const auto BASE_ROUTE_URL = u"/covers/v1/<arg>"_s;
    const auto COVER_URL = u"http://127.0.0.1:%1/covers/v1/%2"_s;
}

RadioPlayerImpl::RadioPlayerImpl(QObject *parent)
    : RadioPlayerSource{parent}
{
    QTimer::singleShot(0, this, [this]() { initializeStations(); });

    m_serverPort = m_httpServer.listen(QHostAddress::LocalHost);
    if (!m_serverPort) {
        qFatal("Covers server failed to listen on a port.");
    }
    m_httpServer.route(BASE_ROUTE_URL, [] (const QUrl &url) {
        auto resp = QHttpServerResponse::fromFile(u":/stationdata/covers/%1"_s.arg(url.path()));
        return resp;
    });
}

QVariant RadioPlayerImpl::togglePlayback()
{
    m_playbackInfo.setIsPlaying(!m_playbackInfo.isPlaying());
    Q_EMIT playbackInfoChanged(m_playbackInfo);
    return true;
}

QVariant RadioPlayerImpl::nextStation()
{
    const int currentStationNumber = m_playbackInfo.currentStationNumber();
    const int stationCount = stations().count();
    m_playbackInfo.setCurrentStationNumber((currentStationNumber + 1) % stationCount);
    Q_EMIT playbackInfoChanged(m_playbackInfo);
    return true;
}

QVariant RadioPlayerImpl::setStation(int index)
{
    m_playbackInfo.setCurrentStationNumber(index);
    Q_EMIT playbackInfoChanged(m_playbackInfo);
    return true;
}

QVariant RadioPlayerImpl::prevStation()
{
    const int currentStationNumber = m_playbackInfo.currentStationNumber();
    const int stationCount = stations().count();
    m_playbackInfo.setCurrentStationNumber((currentStationNumber + stationCount - 1) % stationCount);
    Q_EMIT playbackInfoChanged(m_playbackInfo);
    return true;
}

QVariantList RadioPlayerImpl::stations() const
{
    return m_stations;
}

PlaybackInfo RadioPlayerImpl::playbackInfo() const
{
    return m_playbackInfo;
}

void RadioPlayerImpl::initializeStations()
{
    auto stationsJSON = QFile(u":/stationdata/stations.json"_s);
    if (stationsJSON.open(QFile::ReadOnly)) {
        auto json = QJsonDocument().fromJson(stationsJSON.readAll()).object();
        auto stations = json.value(u"stations"_s).toArray();
        m_stations.clear();
        QMap<int, Station> stationMap;
        for (const auto& station : stations) {
            auto stationItem = Station {};
            auto stationObject = station.toObject();
            auto frequency = static_cast<qreal>(stationObject.value(u"frequency"_s).toDouble());
            stationItem.setName(stationObject.value("name").toString());
            stationItem.setFrequency(frequency);
            stationItem.setCoverUrl(COVER_URL.arg(m_serverPort).arg(stationObject.value(u"cover"_s).toString()));
            stationMap.insert(stationItem.frequency(), stationItem);
        }
        for (const auto &station : stationMap.values()) {
            m_stations.append(QVariant::fromValue(station));
        }
    }

    Q_EMIT stationsChanged(m_stations);
    m_playbackInfo.setCurrentStationNumber(0);
    m_playbackInfo.setIsPlaying(true);
    Q_EMIT playbackInfoChanged(m_playbackInfo);
}
