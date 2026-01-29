import QtQuick

Item {
    id: root
    property var source
    property real desaturateDesaturation: 1

    ShaderEffect {
        readonly property var iSource: source
        readonly property real desaturateDesaturation: parent.desaturateDesaturation

        vertexShader: '../assets/shaders/desaturation.vert.qsb'
        fragmentShader: '../assets/shaders/desaturation.frag.qsb'
        width: parent.width
        height: parent.height
    }
}
