import QtQuick
import wavey.style
import wavey.windows as WaveyWindows
import mediaplayer.viewmodels
import mediaplayer.components
import mediaplayer.shaderEffects
import QtApplicationManager.Application

WaveyWindows.ClusterWindow {
    id: root

    property MediaPlayerViewModelBase viewModel: MediaPlayerViewModelBase{}
    
    title: qsTr("ClusterScreen")

    Item {
        id: content
        clip: true
        anchors.fill: parent

        CoverBlur {
            id: coverBlur
            imageSource: root.viewModel.currentSongCover
            isPlaying: root.viewModel.isPlaying
            anchors.centerIn: roundedCoverImage
            scale: 0.5
        }

        RotatingCover {
            id: roundedCoverImage
            coverSource: root.viewModel.currentSongCover
            anchors.centerIn: parent
            animation: changingSongAnimation
            scale: 0.625
        }

        RoundedItem {
            id: roundedCurrentCoverDesaturationEffect
            width: 320
            height: width
            anchors.centerIn: roundedCoverImage
            radius: 6
            scale: 0.625
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
            text: root.viewModel.currentSongArtist
            font: WaveyFonts.subtitle_3
            color: WaveyStyle.secondaryColor
            anchors.horizontalCenter: parent.horizontalCenter
            anchors.top: roundedCoverImage.bottom
            anchors.topMargin: -46

            Text {
                text: root.viewModel.currentSongTitle
                font: WaveyFonts.h6
                color: WaveyStyle.secondaryColor
                anchors.horizontalCenter: parent.horizontalCenter
                anchors.top: parent.bottom
                anchors.topMargin: 10
            }
        }
    }
}
