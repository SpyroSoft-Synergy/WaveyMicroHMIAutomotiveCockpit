import QtQuick
import wavey.style

SwapableImage {
    id: root

    readonly property string path: "../assets/gesturescreen/"
    property bool isLooping
    property string loopingImg: isLooping ? "on.png" : "off.png"
    property alias mouseArea: mouseArea
    source: String("%1/%2/looping_%3").arg(root.path).arg(WaveyStyle.currentThemeName.toLowerCase()).arg(root.loopingImg)

    Image {
        id: loopingShadow
        opacity: root.isLooping ? 1.0 : 0.0
        anchors.top: root.top
        anchors.topMargin: 0
        anchors.horizontalCenter: root.horizontalCenter
        source: String("%1/%2/shadow.png").arg(root.path).arg(WaveyStyle.currentThemeName.toLowerCase())

        Behavior on opacity {
            NumberAnimation {
                duration: root.animationDuration
            }
        }
    }

    MouseArea {
        id: mouseArea
        anchors.fill: parent
    }
}
