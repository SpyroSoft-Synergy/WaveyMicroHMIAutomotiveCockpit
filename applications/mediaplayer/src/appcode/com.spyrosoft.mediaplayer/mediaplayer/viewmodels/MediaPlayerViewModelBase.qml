import QtQuick
import QtQml
import com.spyro_soft.wavey.media

import wavey.gestures
import wavey.viewmodels

ApplicationRootViewModel {
    id: root

    readonly property var playlist : d.playlist

    readonly property alias isPlaying: mediaPlayer.playbackInfo.isPlaying
    readonly property alias isLooping: mediaPlayer.playbackInfo.isLooping
    readonly property alias isRandom: mediaPlayer.playbackInfo.isRandom
    readonly property alias volume: mediaPlayer.playbackInfo.volume
    readonly property alias currentSong: mediaPlayer.playbackInfo.currentTrackNumber
    readonly property string currentPlaybackTime: d.durationToString(d.currentPlaybackTime)
    readonly property string currentSongTitle: d.currentSong ? d.currentSong.title : ""
    readonly property string currentSongArtist: d.currentSong ? d.currentSong.artist : ""
    readonly property string currentSongAlbum: d.currentSong ? d.currentSong.album : ""
    readonly property string currentSongDuration: d.currentSong ? d.durationToString(d.currentSong.duration) : ""
    readonly property string currentSongRemainingDuration: "-" + d.durationToString(d.currentSongDuration - d.currentPlaybackTime)
    readonly property real currentSongProgress: d.mediaPlayer.playbackInfo.relativeTrackPosition
    readonly property string currentSongCover:  d.currentSong ? d.currentSong.coverUrl : ""
    readonly property string playlistSongsCount: playlist.length + " songs"
    readonly property string playlistDuration: d.playlistDuration
    property int lastPlaybackDirectionChange: 1
    property int currentViewIndex: 0

    readonly property QtObject d: QtObject {
        id: d
        readonly property var playlist: mediaPlayer.currentPlaylist ? mediaPlayer.currentPlaylist.songs : []
        readonly property var currentSong: playlist.length > 0 && mediaPlayer.playbackInfo.currentTrackNumber >= 0 ? playlist[mediaPlayer.playbackInfo.currentTrackNumber] : null
        readonly property int currentPlaybackTime: mediaPlayer.playbackInfo.absoluteTrackPosition
        readonly property int currentSongDuration: mediaPlayer.playbackInfo.currentTrackDuration
        property string playlistDuration: "0:00"

        readonly property MediaPlayer mediaPlayer : MediaPlayer {
            id: mediaPlayer
        }

        onPlaylistChanged: {
            let sum = 0;
            for (var i=0; i < playlist.length; i++ ) {
                sum += playlist[i].duration
            }
            d.playlistDuration = d.durationToString(sum);
        }


        function durationToString(duration) {
            const timing = [Math.floor(duration / 60) % 60, duration % 60]
            return timing.map(e => e.toString().padStart(2, '0')).join(':')
        }

        function durationStringToInt(durationString) {
            const a = durationString.split(':'); // split it at the colons
            return (+a[0]) * 60 + (+a[1]);
        }

    }

    function advanceSongProgress(value) {
        mediaPlayer.advanceSongProgress(value)
    }

    function changeVolume(value) {
        mediaPlayer.changeVolume(value)
    }

    function togglePlayback() {
        mediaPlayer.togglePlayback()
    }

    function toggleLooping() {
        mediaPlayer.toggleLooping()
    }

    function toggleRandom() {
        mediaPlayer.toggleRandom()
    }

    function nextSong() {
        root.lastPlaybackDirectionChange = -1
        mediaPlayer.nextSong()
    }

    function prevSong() {
        root.lastPlaybackDirectionChange = 1
        mediaPlayer.prevSong()
    }

    function switchToSong(index) {
        d.switchToSong(index)
    }

    function playlistDurationToString() {
        let sum = 0;
        console.log(d.playlist.length)
        for (let i = 0; i < d.playlist.length; ++i) {
            console.log(d.playlist[i])
            sum += d.playlist[i].duration
        }
        return d.durationToString(sum)
    }
}
