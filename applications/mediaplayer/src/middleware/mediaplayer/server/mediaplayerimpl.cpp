#include "mediaplayerimpl.h"
#include <QDir>
#include <QJsonDocument>
#include <QJsonObject>
#include <QJsonArray>
#include <algorithm>
#include <QStringLiteral>

namespace {
    using namespace Qt::Literals::StringLiterals;

    const auto BASE_ROUTE_URL = u"/covers/v1/<arg>"_s;
    const auto COVER_URL = u"http://127.0.0.1:%1/covers/v1/%2"_s;
}

MediaPlayerImpl::MediaPlayerImpl(QObject *parent)
    : MediaPlayerSource(parent)
{
   QTimer::singleShot(0, this, [this]() { initializePlaylists(); });
   m_playbackTimer.setInterval(1000);
   connect(&m_playbackTimer, &QTimer::timeout, this, [this] {
        setAbsoluteTrackPosition(m_playbackInfo.absoluteTrackPosition() + 1);
   });
   m_serverPort = m_httpServer.listen(QHostAddress::LocalHost);
    if (!m_serverPort) {
       qFatal("Covers server failed to listen on a port.");
    }
    m_httpServer.route(BASE_ROUTE_URL, [] (const QUrl &url) {
        auto resp = QHttpServerResponse::fromFile(QStringLiteral(":/playlistdata/covers/%1").arg(url.path()));
        return resp;
    });

    m_playbackInfo.setIsPlaying(true);
    m_playbackTimer.start();
    m_playbackInfo.setIsLooping(true);
    Q_EMIT playbackInfoChanged(m_playbackInfo);
}

QVariant MediaPlayerImpl::togglePlayback()
{
   setIsPlaying(!m_playbackInfo.isPlaying());
   return true;
}

QVariant MediaPlayerImpl::nextSong()
{
    int songIndex;
    const int currentTrackNumber = m_playbackInfo.currentTrackNumber();
    const int playlistCount = m_currentPlaylist.songs().count();

    if (m_playbackInfo.isRandom()) {
        songIndex = generateRandomSong(currentTrackNumber);
    } else {
        if (!m_playbackInfo.isLooping() && currentTrackNumber + 1 == playlistCount) {
            songIndex = 0;
            setIsPlaying(false);
        } else {
            songIndex = (currentTrackNumber + 1) % playlistCount;
        }
    }

    initializePlaybackInfo(m_currentPlaylist.songs().at(songIndex).value<Song>());
    return true;
}

QVariant MediaPlayerImpl::prevSong()
{
    int songIndex;
    const int currentTrackNumber = m_playbackInfo.currentTrackNumber();
    const int playlistCount = m_currentPlaylist.songs().count();

    if (m_playbackInfo.isRandom()) {
        songIndex = generateRandomSong(currentTrackNumber);
    } else {
        if (!m_playbackInfo.isLooping() && currentTrackNumber - 1 < 0) {
            songIndex = m_currentPlaylist.songs().count() - 1;
            setIsPlaying(false);
        } else {
            songIndex = (currentTrackNumber + playlistCount - 1) % playlistCount;
        }
    }

    initializePlaybackInfo(m_currentPlaylist.songs().at(songIndex).value<Song>());
    return true;
}

QVariant MediaPlayerImpl::switchPlaylist(const QString &name)
{
    // TODO add when ready to handle
    return true;
}

QVariant MediaPlayerImpl::advanceSongProgress(int value)
{
    setAbsoluteTrackPosition(m_playbackInfo.absoluteTrackPosition() + value);
    return true;
}

QVariant MediaPlayerImpl::changeVolume(int volume)
{
    volume = qMin(100, qMax(0, volume));

    if (m_playbackInfo.volume() != volume) {
        m_playbackInfo.setVolume(volume);
        Q_EMIT playbackInfoChanged(m_playbackInfo);
    }
    return true;
}

QVariant MediaPlayerImpl::toggleRandom()
{
    setIsRandom(!m_playbackInfo.isRandom());
    return true;
}

QVariant MediaPlayerImpl::toggleLooping()
{
    setIsLooping(!m_playbackInfo.isLooping());
    return true;
}

QVariantList MediaPlayerImpl::playlists() const
{
    return m_playlists;
}

Playlist MediaPlayerImpl::currentPlaylist() const
{
    return m_currentPlaylist;
}

PlaybackInfo MediaPlayerImpl::playbackInfo() const
{
    return m_playbackInfo;
}

void MediaPlayerImpl::setPlaylists(QVariantList playlists)
{
    if (playlists != m_playlists) {
        m_playlists = playlists;
        Q_EMIT playlistsChanged(m_playlists);
    }
}

void MediaPlayerImpl::setCurrentPlaylist(Playlist currentPlaylist)
{
    if (currentPlaylist != m_currentPlaylist) {
        m_currentPlaylist = currentPlaylist;
        Q_EMIT currentPlaylistChanged(m_currentPlaylist);
    }
}

void MediaPlayerImpl::setCurrentTrackNumber(int currentTrackNumber)
{

    if (m_playbackInfo.currentTrackNumber() != currentTrackNumber) {
        m_playbackInfo.setCurrentTrackNumber(currentTrackNumber);
        Q_EMIT playbackInfoChanged(m_playbackInfo);
    }
}

void MediaPlayerImpl::setIsPlaying(bool isPlaying)
{
    if (m_playbackInfo.isPlaying() != isPlaying) {
        m_playbackInfo.setIsPlaying(isPlaying);
        Q_EMIT playbackInfoChanged(m_playbackInfo);
    }
    if (m_playbackInfo.isPlaying()) {
        m_playbackTimer.start();
    } else {
        m_playbackTimer.stop();
    }
}

void MediaPlayerImpl::setAbsoluteTrackPosition(int trackPosition)
{
    if (m_playbackInfo.absoluteTrackPosition() != trackPosition) {
        if (trackPosition < m_playbackInfo.currentTrackDuration()) {
            m_playbackInfo.setAbsoluteTrackPosition(qMax(0, trackPosition));
            m_playbackInfo.setRelativeTrackPosition((qreal) m_playbackInfo.absoluteTrackPosition() / m_playbackInfo.currentTrackDuration());
            Q_EMIT playbackInfoChanged(m_playbackInfo);
        } else {
            nextSong();
        }
    }
}

void MediaPlayerImpl::setCurrentTrackDuration(int currentTrackDuration)
{
    if (m_playbackInfo.currentTrackDuration() != currentTrackDuration) {
        m_playbackInfo.setCurrentTrackDuration(currentTrackDuration);
        Q_EMIT playbackInfoChanged(m_playbackInfo);
    }
}

void MediaPlayerImpl::initializePlaybackInfo(const Song &song)
{
    m_playbackInfo.setCurrentTrackDuration(song.duration());
    m_playbackInfo.setRelativeTrackPosition(0.0);
    m_playbackInfo.setAbsoluteTrackPosition(0);
    m_playbackInfo.setCurrentTrackNumber(m_currentPlaylist.songs().indexOf(QVariant::fromValue(song)));
    Q_EMIT playbackInfoChanged(m_playbackInfo);
}

void MediaPlayerImpl::setIsRandom(bool isRandom)
{
    if (m_playbackInfo.isRandom() != isRandom) {
        m_playbackInfo.setIsRandom(isRandom);
        Q_EMIT playbackInfoChanged(m_playbackInfo);
    }
}

void MediaPlayerImpl::setIsLooping(bool isLooping)
{
    if (m_playbackInfo.isLooping() != isLooping) {
        m_playbackInfo.setIsLooping(isLooping);
        Q_EMIT playbackInfoChanged(m_playbackInfo);
    }
}

void MediaPlayerImpl::initializePlaylists()
{
    QDir directory(":/playlistdata");
    QStringList playlists = directory.entryList(QStringList() << "*.json", QDir::Files);
    for(const auto& playlist : playlists) {
        auto playlistJSON = QFile{directory.filePath(playlist)};
        if (playlistJSON.open(QFile::ReadOnly)) {
              auto json = QJsonDocument().fromJson(playlistJSON.readAll()).object();
              auto playlistName = json.value("playlistName").toString();
              auto songs = json.value("songs").toArray();
              auto songsList = QVariantList{};
              for (const auto& song : songs) {
                  auto songItem = Song{};
                  auto songObject = song.toObject();
                  auto duration = songObject.value("duration").toString();
                  songItem.setAlbum(songObject.value("album").toString());
                  songItem.setTitle(songObject.value("title").toString());
                  songItem.setArtist(songObject.value("artist").toString());
                  songItem.setDuration(durationToInt(duration));
                  songItem.setDurationString(duration);
                  songItem.setCoverUrl(COVER_URL.arg(m_serverPort).arg(songObject.value("cover").toString()));
                  songsList.append(QVariant::fromValue(songItem));
              }
              m_playlists.append(QVariant::fromValue(Playlist{playlistName, songsList}));
        }
    }

    m_currentPlaylist = m_playlists.at(0).value<Playlist>();


    Q_EMIT playlistsChanged(m_playlists);
    Q_EMIT currentPlaylistChanged(m_currentPlaylist);

    initializePlaybackInfo(m_currentPlaylist.songs().at(0).value<Song>());
}

int MediaPlayerImpl::generateRandomSong(const int currentTrackNumber)
{
    std::random_device rd;
    std::mt19937 g(rd());
    std::uniform_int_distribution<> rng(0, m_currentPlaylist.songs().count() - 1);
    auto randomSongNumber = rng(g);
    while (currentTrackNumber == randomSongNumber) {
        randomSongNumber = rng(g);
    }
    return randomSongNumber;
}

int MediaPlayerImpl::durationToInt(const QString &value)
{
    auto parts = value.split(":");
    std::reverse(parts.begin(), parts.end());
    auto multiplier = 1;
    auto duration = 0;
    for(const auto& part : parts) {
        duration += part.toInt() * multiplier;
        multiplier *= 60;
    }

    return duration;
}


