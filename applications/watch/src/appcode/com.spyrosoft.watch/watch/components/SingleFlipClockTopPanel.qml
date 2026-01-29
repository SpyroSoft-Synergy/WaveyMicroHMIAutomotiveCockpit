import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import wavey.style

Item {
    id: root
    required property string number

    property int fullHeight
    property int numberSize

    Rectangle {
        anchors.fill: root
        color: WaveyStyle.backgroundColor
    }

    Image {
        anchors.top: root.top
        width: root.width
        fillMode: Image.Stretch
        source: "./../assets/FlipCardDecor.png"
    }

    Label {
        text: root.number
        color: WaveyStyle.secondaryColor
        height: root.fullHeight
        width: root.width
        anchors.top: parent.top
        anchors.horizontalCenter: parent.horizontalCenter

        horizontalAlignment: Text.AlignHCenter
        verticalAlignment: Text.AlignVCenter

        font {
            family: WaveyFonts.h1.family
            pixelSize: root.numberSize
            weight: 700
        }
    }
}
