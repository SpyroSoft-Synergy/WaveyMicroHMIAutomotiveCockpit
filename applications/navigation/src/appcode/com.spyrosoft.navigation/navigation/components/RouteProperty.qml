import QtQuick
import wavey.style

Item {
    id: root

    property alias iconSource: icon.source
    property alias text: value.text
    property alias iconWidth: icon.width

    Image {
        id: icon

        width: height
        height: root.height
        smooth: true
        fillMode: Image.PreserveAspectFit

        anchors {
            left: root.left
            leftMargin: 25
        }

    }

    Text {
        id: value

        color: WaveyStyle.secondaryColor
        font: WaveyFonts.subtitle_3

        anchors {
            left: icon.right
            leftMargin: 10
            right: root.right
            verticalCenter: root.verticalCenter
        }

    }

}
