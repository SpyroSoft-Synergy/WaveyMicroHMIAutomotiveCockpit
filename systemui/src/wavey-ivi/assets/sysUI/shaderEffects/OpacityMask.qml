// Created with Qt Quick Effect Maker (version 0.41), Mon Nov 21 09:39:15 2022

import QtQuick

Item {
    id: rootItem

    // This property inverts the behavior of the mask source.
    property bool opacityMaskInvert: false

    // This property defines the item that is going to be used as the mask. The mask item alpha values are used to determine the source item's pixels visibility in the display.
    property var opacityMaskSource: null

    // This is the main source for the effect
    property var source: null

    ShaderEffect {
        readonly property var iSource: rootItem.source
        readonly property bool opacityMaskInvert: parent.opacityMaskInvert
        readonly property var opacityMaskSource: parent.opacityMaskSource

        fragmentShader: 'opacityMask.frag.qsb'
        height: parent.height
        vertexShader: 'opacityMask.vert.qsb'
        width: parent.width
    }
}
