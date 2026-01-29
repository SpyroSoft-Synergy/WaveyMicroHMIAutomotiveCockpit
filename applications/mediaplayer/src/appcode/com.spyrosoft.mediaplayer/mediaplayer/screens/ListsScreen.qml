import QtQuick
import wavey.style
import mediaplayer.components
import mediaplayer.shaderEffects
import mediaplayer.viewmodels

Rectangle {
    id: root

    property MediaPlayerViewModelBase viewModel

    QtObject {
       id: d
       property int activeCoverWidth
       property int coverBottomMargin
       property int coversDistance
       property int coverRightMargin
       property int playlistLeftMargin
       property int sliderLeftMargin
       property real scale
       property real blurOpacity
       property real coverOpacity
    }

    width: 1840
    height: 660

    color: WaveyStyle.backgroundColor
    radius: WaveyStyle.backgroundRadius

    Image {
        source: "../assets/ellipse.png"
        width: root.width
        height: 260
        anchors.top: root.top
        anchors.topMargin: height / -2
    }

    Text {
        id: playlistName
        text: "Playlist"
        anchors.top: parent.top
        anchors.topMargin: 90
        anchors.horizontalCenter: parent.horizontalCenter
        color: WaveyStyle.accentColor
        font: WaveyFonts.h1
    }

    ListView {
        id: songlist
        property int listLength: model.length

        width: 820
        height: 392
        anchors.left: root.left
        anchors.leftMargin: d.playlistLeftMargin
        anchors.bottom: root.bottom
        anchors.bottomMargin: 58
        spacing: 18
        clip: true
        highlightMoveDuration: 300
        currentIndex: root.viewModel.currentSong

        model: root.viewModel.playlist
        delegate: SongInList {
            width: d.activeCoverWidth
            songNumber: (index + 1).toString().padStart(2, '0')
            songTitle: modelData.title
            songArtist: modelData.artist
            songDuration: modelData.durationString
        }
        highlight: ActiveSongMarker {
            width: d.activeCoverWidth
            isCurrentlyPlaying: root.viewModel.isPlaying
        }
    }


    PlaylistScroll {
        listHeight: songlist.height
        contentHeight: songlist.contentHeight
        contentY: songlist.contentY
        anchorParent: songlist
        anchors.left: root.left
        anchors.leftMargin: d.sliderLeftMargin
    }

    CoverBlur {
        id: coverBlur
        imageSource: root.viewModel.currentSongCover
        isPlaying: root.viewModel.isPlaying
        anchors.centerIn: carousel
        opacity: d.blurOpacity
        scale: d.scale
    }

    ListCarousel {
        id: carousel
        model: root.viewModel.playlist
        anchors.right: parent.right
        anchors.rightMargin: d.coverRightMargin
        anchors.bottom: parent.bottom
        anchors.bottomMargin: d.coverBottomMargin
        opacity: d.coverOpacity
        scale: d.scale
        isPlaying: root.viewModel.isPlaying
        coversDistance: d.coversDistance

        property bool initialRun: true
    }

    Connections {
        target: root.viewModel
        function onCurrentSongCoverChanged() {
            /* SOJ: On the initial run of the carousel we have to move one cover backwards - it's because of my pathView implementation */
            if (carousel.initialRun) {
                carousel.pathView.decrementCurrentIndex()
                carousel.initialRun = false
                return
            }
            /* Match the carousel with the current song */
            while (carousel.currentCoverIndex !== root.viewModel.currentSong) {
                if (root.viewModel.lastPlaybackDirectionChange == 1) {
                    carousel.currentCoverIndex = (carousel.currentCoverIndex + root.viewModel.playlist.length - 1) % root.viewModel.playlist.length
                    carousel.pathView.decrementCurrentIndex()
                } else {
                    carousel.currentCoverIndex = (carousel.currentCoverIndex + 1) % root.viewModel.playlist.length
                    carousel.pathView.incrementCurrentIndex()
                }
            }
        }
    }

    states: [
        State {
            name: "1840"
            when: root.width >= 1840
            PropertyChanges {
                target: d
                activeCoverWidth: 700
                blurOpacity: 0.75
                coverBottomMargin: 58
                coversDistance: 100
                coverOpacity: 1.0
                coverRightMargin: 336
                playlistLeftMargin: 192
                scale: 1.0
                sliderLeftMargin: 68
            }
        },

        State {
            name: "1220"
            when: root.width < 1840 && root.width >= 1220
            PropertyChanges {
                target: d
                activeCoverWidth: 560
                blurOpacity: 0.75
                coverBottomMargin: 60
                coversDistance: 80
                coverOpacity: 1.0
                coverRightMargin: 100
                playlistLeftMargin: 107
                scale: 0.78
                sliderLeftMargin: 43
            }
        },

        State {
            name: "910"
            when: root.width < 1220 && root.width >= 910
            PropertyChanges {
                target: d
                activeCoverWidth: 442
                blurOpacity: 0.75
                coverBottomMargin: 60
                coversDistance: 80
                coverOpacity: 1.0
                coverRightMargin: 30
                playlistLeftMargin: 63
                scale: 0.642
                sliderLeftMargin: 43
            }
        },

        State {
            name: "600"
            when: root.width < 910
            PropertyChanges {
                target: d
                activeCoverWidth: 492
                blurOpacity: 0.0
                coverBottomMargin: 60
                coversDistance: 40
                coverOpacity: 0.0
                coverRightMargin: 0
                playlistLeftMargin: 63
                scale: 0.642
                sliderLeftMargin: 43
            }
        }
    ]

    transitions: Transition {
        NumberAnimation {
            target: d
            properties: "activeCoverWidth, blurOpacity, coverBottomMargin, coverOpacity, coversDistance,
                         coverRightMargin, playlistLeftMargin, scale, sliderLeftMargin"
        }
    }
}
