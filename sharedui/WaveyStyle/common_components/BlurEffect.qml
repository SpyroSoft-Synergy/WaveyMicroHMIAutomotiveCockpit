// Created with Qt Quick Effect Maker (version 0.40)
import QtQuick

Item {
    id: root
    property var source: null
    property real blurHelperBlurMultiplier: 1
    property real fastBlurAmount: 1

    BlurHelper {
        id: blurHelper
        anchors.fill: parent
        blurMax: 128
        blurMultiplier: root.blurHelperBlurMultiplier
        source: root.source
    }
    ShaderEffect {
        readonly property var iSource: root.source
        readonly property var iSourceBlur1: blurHelper.blurSrc1
        readonly property var iSourceBlur2: blurHelper.blurSrc2
        readonly property var iSourceBlur3: blurHelper.blurSrc3
        readonly property var iSourceBlur4: blurHelper.blurSrc4
        readonly property var iSourceBlur5: blurHelper.blurSrc5
        readonly property var iSourceBlur6: blurHelper.blurSrc6
        readonly property real blurHelperBlurMultiplier: parent.blurHelperBlurMultiplier
        readonly property real fastBlurAmount: parent.fastBlurAmount

        vertexShader: "qrc:/wavey/style/common_shaders/blureffect.vert.qsb"
        fragmentShader: "qrc:/wavey/style/common_shaders/blureffect.frag.qsb"
        width: parent.width
        height: parent.height
    }
}

