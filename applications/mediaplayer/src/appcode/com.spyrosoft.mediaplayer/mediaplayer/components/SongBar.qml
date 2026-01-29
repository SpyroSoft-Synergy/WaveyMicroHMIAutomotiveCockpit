import QtQuick
import wavey.style

Item {
    id: root
    width: 580
    property int barHeight: 4
    property bool isPlaying: true
    property double songProgress
    property int barRadius: 4
    property alias duration: durationLabel.text
    property alias remainingDuration: remainingDurationLabel.text

    Rectangle {
        id: bar
        width: root.width
        height: root.barHeight
        radius: root.barRadius
        color: WaveyStyle.primaryColor
        opacity: 0.35
    }

    Rectangle {
        id: progress
        width: root.width * root.songProgress
        height: root.barHeight
        radius: root.barRadius
        color: WaveyStyle.primaryColor
        opacity: root.isPlaying ? 1.0 : 0.3

        Behavior on opacity {
            NumberAnimation {}
        }

        Behavior on width {
            NumberAnimation {
                duration: 1000
            }
        }
    }

    Text {
        id: durationLabel
        color: WaveyStyle.secondaryColor
        font: WaveyFonts.text_6
        anchors.top: bar.bottom
        anchors.topMargin: 3
    }

    Text {
        id: remainingDurationLabel
        color: WaveyStyle.secondaryColor
        font: WaveyFonts.text_6
        anchors.top: bar.bottom
        anchors.topMargin: 3
        anchors.right: bar.right
    }

    Behavior on width {
        SmoothedAnimation {
            duration: 500
        }
    }
}
