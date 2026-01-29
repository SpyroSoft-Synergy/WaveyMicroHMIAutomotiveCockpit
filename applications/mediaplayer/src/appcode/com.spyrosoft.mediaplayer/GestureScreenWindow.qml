import QtQuick
import wavey.style
import wavey.windows as WaveyWindows
import mediaplayer.viewmodels
import mediaplayer.components
import mediaplayer.shaderEffects
import QtApplicationManager.Application

WaveyWindows.GestureScreenWindow {
    id: root

    property GestureScreenViewModel viewModel: GestureScreenViewModel{}
    
    title: qsTr("GestureScreen")

    Item {
        id: content
        clip: true
        anchors.fill: parent

        CoverBlur {
            id: coverBlur
            imageSource: root.viewModel.currentSongCover
            isPlaying: root.viewModel.isPlaying
            anchors.centerIn: coverMask
            scale: 0.5
        }

        RoundedItem {
            id: coverMask
            anchors.horizontalCenter: parent.horizontalCenter
            anchors.top: parent.top
            anchors.topMargin: 160
            width: 200
            height: 200
            radius: 6

            SwapableImage {
                id: songCover
                source: root.viewModel.currentSongCover
                anchors.fill: coverMask
                imageWidth: parent.width
                imageHeight: imageWidth
                layer.enabled: true
            }

            DesaturationEffect {
                id: coverDesaturation
                source: songCover
                anchors.fill: songCover
                opacity: root.viewModel.isPlaying ? 0 : 1

                Behavior on opacity {
                    NumberAnimation {}
                }
            }

        }

        VolumeSlider {
            id: volumeSlider
            x: -70
            y: 221
            value: root.viewModel.volume
            onValueChanged: {
                if (pressed) {
                    root.viewModel.changeVolume(volumeSlider.value)
                }
            }
        }

        Text {
            text: "Volume"
            color: WaveyStyle.accentColor
            font: WaveyFonts.text_3
            anchors.horizontalCenter: volumeSlider.horizontalCenter
            anchors.bottom: parent.bottom
            anchors.bottomMargin: 40
        }

        LoopingButton {
            id: loopingButton
            anchors.top: parent.top
            anchors.topMargin: 123
            anchors.right: parent.right
            anchors.rightMargin: 55
            isLooping: root.viewModel.isLooping
            mouseArea.onClicked: root.viewModel.toggleLooping()
        }

        RandomButton {
            id: randomButton
            anchors.top: loopingButton.bottom
            anchors.topMargin: 45
            anchors.horizontalCenter: loopingButton.horizontalCenter
            isRandom: root.viewModel.isRandom
            mouseArea.onClicked: root.viewModel.toggleRandom()
        }

        SongBar {
            width: root.width < 910 ? 510 : 580
            anchors.bottom: parent.bottom
            anchors.bottomMargin: 38
            anchors.horizontalCenter: parent.horizontalCenter
            isPlaying: root.viewModel.isPlaying
            songProgress: root.viewModel.currentSongProgress
            duration: root.viewModel.currentPlaybackTime
            remainingDuration: root.viewModel.currentSongRemainingDuration
        }

        Text {
            id: currentAppName
            text: "Media Player"
            color: WaveyStyle.accentColor
            // TODO: Add new WaveyFont
            font.family: WaveyFonts.h1.family
            font.weight: WaveyFonts.h1.weight
            font.pixelSize: 38
            anchors.horizontalCenter: parent.horizontalCenter
            anchors.top: parent.top
            anchors.topMargin: 80
        }
    }
}
