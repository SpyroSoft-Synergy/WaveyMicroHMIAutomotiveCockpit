import QtQuick
import wavey.style

ShaderEffect {
    id: root

    readonly property var colorSource: appSlotMask

    fragmentShader: "qrc:/common_shaders/appSlotBorder.frag.qsb"

    Rectangle {
        id: appSlotMask
        anchors.fill: parent
        visible: false
        color: WaveyStyle.accentColor // qmllint disable
        gradient: Gradient {
            GradientStop { position: 0.0; color: Qt.rgba(appSlotMask.color.r, appSlotMask.color.g, appSlotMask.color.b, 0.25) }
            GradientStop { position: 1.0; color: appSlotMask.color }
        }
        layer.enabled: true
        layer.smooth: true
    }
}
