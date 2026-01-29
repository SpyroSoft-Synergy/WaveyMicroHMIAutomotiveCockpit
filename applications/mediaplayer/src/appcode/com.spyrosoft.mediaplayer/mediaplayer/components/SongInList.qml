import QtQuick
import wavey.style

Item {
    id: root
    property string songNumber: "69"
    property string songTitle: "BLABLABLA"
    property string songArtist: "SOME RANDOM SHIT ARTIST"
    property string songDuration: "4:20"
    property bool isCurrentSong: ListView.isCurrentItem
    property int animationDuration: 200

    width: 700
    height: 64

    Text {
        id: number
        text: root.songNumber
        anchors.top: parent.top
        anchors.left: parent.left
        anchors.topMargin: 8
        anchors.leftMargin: 16
        color: WaveyStyle.primaryColor
        font: WaveyFonts.numbers
    }

    Text {
        id: title
        text: root.songTitle
        color: root.isCurrentSong ? WaveyStyle.accentColor : WaveyStyle.secondaryColor
        anchors.top: parent.top
        anchors.topMargin: 6
        anchors.left: number.right
        anchors.leftMargin: 12
        font: WaveyFonts.h6

        Behavior on color {
            ColorAnimation {
                duration: root.animationDuration
            }
        }
    }

    Row {
        id: textRow
        anchors.left: number.right
        anchors.bottom: parent.bottom
        anchors.leftMargin: 12
        anchors.bottomMargin: 8
        spacing: 6

        Text {
            id: artist
            text: root.songArtist
            color: WaveyStyle.primaryColor
            font: WaveyFonts.subtitle_3
        }

        Text {
            id: separator
            text: "- " + root.songDuration
            color: WaveyStyle.primaryColor
            font: WaveyFonts.subtitle_3
        }
    }

    // qmllint disable
    PlayStop {
        id: playStopIcon
        width: 18
        height: 18
        anchors.horizontalCenter: number.horizontalCenter
        anchors.bottom: root.bottom
        anchors.bottomMargin: 11
        opacity: root.isCurrentSong ? 1.0 : 0.0

        Behavior on opacity {
            NumberAnimation {}
        }
    }
}
