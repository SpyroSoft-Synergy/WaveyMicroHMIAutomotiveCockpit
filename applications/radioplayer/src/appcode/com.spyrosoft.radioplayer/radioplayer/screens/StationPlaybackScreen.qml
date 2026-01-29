import QtQuick
import wavey.style
import radioplayer.viewmodels
import radioplayer.components

Rectangle {
    id: root

    property RadioPlayerViewModelBase viewModel

    width: 1840
    height: 660

    color: WaveyStyle.backgroundColor
    radius: WaveyStyle.backgroundRadius

    QtObject {
       id: d

       property int stationBarWidth
    }

    Image {
        source: "../assets/playback_screen/ellipse.png"
        width: root.width
        height: 260
        anchors.bottom: root.bottom
        anchors.bottomMargin: -140
    }

    CoverBlur {
        anchors.centerIn: roundedCoverImage
        imageSource: root.viewModel.currentStationCover
        isPlaying: root.viewModel.isPlaying
    }

    RoundedItem {
        id: roundedCoverImage
        anchors {
            horizontalCenter: parent.horizontalCenter
            top: parent.top
            topMargin: 110
        }
        width: 280
        height: 280
        radius: 6
        Image {
            anchors.fill: parent
            source: root.viewModel.currentStationCover
        }
    }

    DesaturationEffect {
        id: currentCoverDesaturationEffect
        anchors.fill: roundedCoverImage
        source: roundedCoverImage
        opacity: root.viewModel.isPlaying ? 0 : 1

        Behavior on opacity {
            NumberAnimation {}
        }
    }

    Text {
        anchors {
            horizontalCenter: parent.horizontalCenter
            bottom: stationBar.top
            bottomMargin: 65
        }
        horizontalAlignment: Text.AlignHCenter
        color: WaveyStyle.secondaryColor
        font: WaveyFonts.text_3
        text: String("%1 MHz").arg(root.viewModel.currentStationFrequency)
    }

    Text {
        anchors {
            horizontalCenter: parent.horizontalCenter
            bottom: stationBar.top
            bottomMargin: 25
        }
        horizontalAlignment: Text.AlignHCenter
        color: WaveyStyle.secondaryColor
        font {
            family: WaveyFonts.text_3.family
            pixelSize: 32
            weight: 600
        }
        text: root.viewModel.currentStationName
    }

    StationBar {
        id: stationBar
        viewModel: root.viewModel
        width: d.stationBarWidth
        anchors {
            horizontalCenter: parent.horizontalCenter
            bottom: parent.bottom
            bottomMargin: 65
        }
    }

    states: [
        State {
            name: "1840"
            when: root.width >= 1840
            PropertyChanges {
                target: d
                stationBarWidth: 670
            }
        },
        State {
            name: "1220"
            when: root.width < 1840 && root.width >= 1220
            PropertyChanges {
                target: d
                stationBarWidth: 670
            }
        },
        State {
            name: "910"
            when: root.width < 1220 && root.width >= 910
            PropertyChanges {
                target: d
                stationBarWidth: 628
            }
        },
        State {
            name: "600"
            when: root.width < 910
            PropertyChanges {
                target: d
                stationBarWidth: 516
            }
        }
    ]

    transitions: Transition {
        NumberAnimation {
            target: d
            duration: 200
            property: "stationBarWidth"
        }
    }
}
