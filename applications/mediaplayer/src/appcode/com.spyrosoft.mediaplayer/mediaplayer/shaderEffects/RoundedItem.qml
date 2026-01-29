import QtQuick

Item {
    id: root
    property real radius: 0
    layer.enabled: true
    layer.smooth: true
    layer.effect: ShaderEffect {
        property real radius: root.radius
        fragmentShader: "../assets/shaders/roundedItem.frag.qsb"
    }
}
