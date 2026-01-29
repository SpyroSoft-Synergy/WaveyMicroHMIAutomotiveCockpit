// Created with Qt Quick Effect Maker (version 0.41), Thu Nov 24 10:33:01 2022

import QtQuick

Item {
    id: rootItem

    // Offset to center of the circle image is set
    property point centerOffset: Qt.point(0.0, 0.0)
    // Split is clockwise (first source then secondSource)
    property bool clockwise: true
    // Extends blur
    property real fastBlurAmount: 0.3

    // Starting angle (degree 0 is at the top and goes clockwise)
    property real fromAngle: 0
    // Blur radius
    property real radius: 4
    // Second source that is showed above split percent
    property var secondSource: null

    // This is the main source for the effect
    property var source: null
    // Percent between from and to angle from (0.0 to 1.0)
    property real splitPercent: 0
    // Ending angle
    property real toAngle: 360

    BlurHelper {
        id: blurHelper

        anchors.fill: parent
        source: rootItem.source
    }

    ShaderEffect {
        readonly property real blurHelperBlurMultiplier: blurHelper.blurMultiplier
        readonly property point centerOffset: parent.centerOffset
        readonly property bool clockwise: parent.clockwise
        readonly property real fastBlurAmount: parent.fastBlurAmount
        readonly property real fromAngle: Math.max(0.0, parent.fromAngle)
        readonly property var iSource: rootItem.source
        readonly property var iSourceBlur1: blurHelper.blurSrc1
        readonly property var iSourceBlur2: blurHelper.blurSrc2
        readonly property var iSourceBlur3: blurHelper.blurSrc3
        readonly property var iSourceBlur4: blurHelper.blurSrc4
        readonly property var iSourceBlur5: blurHelper.blurSrc5
        readonly property var iSourceBlur6: blurHelper.blurSrc6
        readonly property real radius: parent.radius
        readonly property var secondSource: parent.secondSource
        readonly property real splitAngle: {
            const percent = clockwise ? splitPercent : 1.0 - splitPercent;
            const newSplitAngle = (toAngle - fromAngle) * percent + fromAngle;
            return clockwise ? newSplitAngle : 360.0 - newSplitAngle;
        }
        readonly property real splitPercent: parent.splitPercent
        readonly property real toAngle: Math.min(360.0, parent.toAngle)

        fragmentShader: 'clustercirclemask.frag.qsb'
        height: parent.height
        vertexShader: 'clustercirclemask.vert.qsb'
        width: parent.width
    }
}
