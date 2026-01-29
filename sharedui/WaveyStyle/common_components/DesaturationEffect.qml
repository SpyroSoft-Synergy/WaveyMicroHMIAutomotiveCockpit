import QtQuick

Item {
    id: root
    property var source
    property real desaturateDesaturation: 1

    ShaderEffect {
        readonly property var iSource: root.source
        readonly property real desaturateDesaturation: parent.desaturateDesaturation

        vertexShader: "qrc:/wavey/style/common_shaders/desaturation.vert.qsb"
        fragmentShader: "qrc:/wavey/style/common_shaders/desaturation.frag.qsb"
        width: parent.width
        height: parent.height
    }
}
