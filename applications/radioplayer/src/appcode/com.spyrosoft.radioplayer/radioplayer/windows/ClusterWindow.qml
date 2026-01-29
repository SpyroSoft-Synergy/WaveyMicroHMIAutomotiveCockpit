import QtQuick
import QtQuick.Controls
import QtApplicationManager.Application
import wavey.style
import wavey.windows as WaveyWindows
import radioplayer.components
import radioplayer.viewmodels

WaveyWindows.ClusterWindow {
    id: root

    property RadioPlayerViewModelBase viewModel: RadioPlayerViewModelBase {}

    title: qsTr("ClusterScreen")

    Item {
        id: content
        clip: true
        anchors.fill: parent

        CoverBlur {
            id: coverBlur
            imageSource: root.viewModel.currentStationCover
            isPlaying: root.viewModel.isPlaying
            anchors.centerIn: roundedCoverImage
            scale: 0.625
        }

        RoundedItem {
            id: roundedCoverImage
            anchors.centerIn: parent
            width: 320
            height: width
            radius: 6
            scale: 0.625

            Image {
                id: coverImage
                anchors.fill: parent
                source: root.viewModel.currentStationCover
            }
        }

        RoundedItem {
            id: roundedCoverImageDesaturationEffect
            anchors.centerIn: parent
            width: 320
            height: width
            radius: 6
            scale: 0.625

            DesaturationEffect {
                anchors.fill: parent
                source: roundedCoverImage
                opacity: root.viewModel.isPlaying ? 0 : 1

                Behavior on opacity {
                    NumberAnimation {}
                }
            }
        }

        Text {
            text: root.viewModel.currentStationName
            font: WaveyFonts.subtitle_3
            color: WaveyStyle.secondaryColor
            anchors.horizontalCenter: parent.horizontalCenter
            anchors.top: roundedCoverImage.bottom
            anchors.topMargin: -46

            Text {
                text: String("%1 MHz").arg(root.viewModel.currentStationFrequency)
                font: WaveyFonts.h6
                color: WaveyStyle.secondaryColor
                anchors.horizontalCenter: parent.horizontalCenter
                anchors.top: parent.bottom
                anchors.topMargin: 10
            }
        }
    }
}
