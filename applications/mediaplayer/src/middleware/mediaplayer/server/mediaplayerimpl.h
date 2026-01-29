#ifndef GESTUREDETECTORIMPL_H
#define GESTUREDETECTORIMPL_H

#include "rep_mediaplayer_source.h"
#include "song.h"
#include <QTimer>
#include <QtHttpServer>

using namespace com::spyro_soft::wavey::media;

class MediaPlayerImpl : public MediaPlayerSource
{
public:
    MediaPlayerImpl(QObject *parent = nullptr);

    // MediaPlayerDetectorSource interface
public Q_SLOTS:
    virtual QVariant togglePlayback() override;
    virtual QVariant toggleRandom() override;
    virtual QVariant toggleLooping() override;
    QVariant nextSong() override;
    QVariant prevSong() override;
    QVariant switchPlaylist(const QString &name) override;
    QVariant advanceSongProgress(int value) override;
    QVariant changeVolume(int volume) override;

    // MediaPlayerSource interface
public:
    QVariantList playlists() const override;
    Playlist currentPlaylist() const override;
    PlaybackInfo playbackInfo() const override;

protected:
    virtual void setPlaylists(QVariantList playlists);
    virtual void setCurrentPlaylist(Playlist currentPlaylist);
    virtual void setCurrentTrackNumber(int currentTrackNumber);
    virtual void setIsPlaying(bool isPlaying);
    virtual void setAbsoluteTrackPosition(int trackPosition);
    virtual void setCurrentTrackDuration(int currentTrackDuration);
    virtual void initializePlaybackInfo(const Song& song);
    virtual void setIsRandom(bool randomize);
    virtual void setIsLooping(bool looping);

    void initializePlaylists();
    int generateRandomSong(const int currentTrackNumber);

private:
    int durationToInt(const QString& value);

    QVariantList m_playlists;
    Playlist m_currentPlaylist;
    PlaybackInfo m_playbackInfo;
    QTimer m_playbackTimer;
    QHttpServer m_httpServer;
    quint16 m_serverPort;
};

#endif // GESTUREDETECTORIMPL_H
