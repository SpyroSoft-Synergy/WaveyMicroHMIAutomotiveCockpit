import QtQuick
import wavey.style
import mediaplayer.components
import mediaplayer.shaderEffects
import mediaplayer.viewmodels

Rectangle {
    id: root
    property MediaPlayerViewModelBase viewModel

    color: WaveyStyle.backgroundColor
    radius: WaveyStyle.backgroundRadius
    width: 1840
    height: 660

    Image {
        source: "../assets/ellipse.png"
        width: root.width
        height: 260
        anchors.bottom: root.bottom
        anchors.bottomMargin: -140
        opacity: 0.85
    }

    CoverBlur {
        id: coverBlur
        imageSource: root.viewModel.currentSongCover
        isPlaying: root.viewModel.isPlaying
        anchors.centerIn: roundedCoverImage
    }

    RotatingCover {
        id: roundedCoverImage
        coverSource: root.viewModel.currentSongCover
        anchors.horizontalCenter: root.horizontalCenter
        anchors.top: root.top
        anchors.topMargin: 90
        animation: changingSongAnimation
    }

    RoundedItem {
        id: roundedCurrentCoverDesaturationEffect
        width: 320
        height: width
        anchors.centerIn: roundedCoverImage
        radius: 6
        transform: Rotation {
            origin.x: 160
            origin.y: 160
            axis {
                x: 0
                y: 1
                z: 0
            }
            angle: roundedCoverImage.rotationAngle
        }

        DesaturationEffect {
            id: currentCoverDesaturationEffect
            source: roundedCoverImage
            anchors.fill: parent
            opacity: root.viewModel.isPlaying ? 0 : 1

            Behavior on opacity {
                NumberAnimation {}
            }
        }
    }

    SequentialAnimation {
        id: changingSongAnimation
        property int rotationDuration: 150
        alwaysRunToEnd: true
        property bool initialRun: true

        NumberAnimation {
            target: roundedCoverImage
            properties: "rotationAngle"
            to: roundedCoverImage.rotationAngle + 90 * root.viewModel.lastPlaybackDirectionChange
            duration: changingSongAnimation.rotationDuration
            alwaysRunToEnd: true
        }

        ScriptAction {
            script: {
                if (!changingSongAnimation.initialRun) {
                    roundedCoverImage.isCoverMirrored = !roundedCoverImage.isCoverMirrored
                } else {
                    changingSongAnimation.initialRun = false
                }
            }
        }

        NumberAnimation {
            target: roundedCoverImage
            properties: "rotationAngle"
            to: roundedCoverImage.rotationAngle + 180 * root.viewModel.lastPlaybackDirectionChange
            duration: changingSongAnimation.rotationDuration
            alwaysRunToEnd: true
        }
    }

    Text {
        id: currentSongTitle
        text: root.viewModel.currentSongTitle
        font: WaveyFonts.text_3
        color: WaveyStyle.secondaryColor
        anchors.horizontalCenter: roundedCoverImage.horizontalCenter
        anchors.top: roundedCoverImage.bottom
        anchors.topMargin: 26

        Text {
            id: currentSongArtist
            text: root.viewModel.currentSongArtist
            font: WaveyFonts.h4
            color: WaveyStyle.secondaryColor
            anchors.top: currentSongTitle.bottom
            anchors.horizontalCenter: currentSongTitle.horizontalCenter

            Text {
                id: currentSongAlbum
                text: root.viewModel.currentSongAlbum
                color: WaveyStyle.primaryColor
                font: WaveyFonts.subtitle_3
                anchors.top: currentSongArtist.bottom
                anchors.horizontalCenter: currentSongArtist.horizontalCenter
                anchors.topMargin: 6
            }
        }
    }

    SongBar {
        id: songBar
        width: root.width < 910 ? 510 : 580
        anchors.bottom: root.bottom
        anchors.bottomMargin: 97
        anchors.horizontalCenter: root.horizontalCenter
        isPlaying: root.viewModel.isPlaying
        songProgress: root.viewModel.currentSongProgress
        duration: root.viewModel.currentPlaybackTime
        remainingDuration: root.viewModel.currentSongRemainingDuration
    }
}
