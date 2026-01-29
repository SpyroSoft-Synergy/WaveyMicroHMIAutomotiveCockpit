// Copyright (C) 2022 The Qt Company Ltd.
// SPDX-License-Identifier: BSD-3-Clause

import QtQuick

Item {
    id: rootItem

    property int blurMax: 64
    // This property defines a multiplier for extending the blur radius.
    // The value ranges from 0.0 (not multiplied) to inf. By default, the property is set to 0.0. Incresing the multiplier extends the blur radius, but decreases the blur quality. This is more performant option for a bigger blur radius than BLUR_HELPER_MAX_LEVEL as it doesn't increase the amount of texture lookups.
    // Note: This affects to both blur and shadow effects.
    property real blurMultiplier: 0
    property alias blurSrc1: blurredItemSource1
    property alias blurSrc2: blurredItemSource2
    property alias blurSrc3: blurredItemSource3
    property alias blurSrc4: blurredItemSource4
    property alias blurSrc5: blurredItemSource5
    property alias blurSrc6: blurredItemSource6
    property var source: null

    QtObject {
        id: priv

        property bool useBlurItem1: true
        property bool useBlurItem2: true
        property bool useBlurItem3: rootItem.blurMax > 2
        property bool useBlurItem4: rootItem.blurMax > 8
        property bool useBlurItem5: rootItem.blurMax > 16
        property bool useBlurItem6: rootItem.blurMax > 32
    }

    ShaderEffectSource {
        id: blurredItemSource1

        height: Math.ceil(rootItem.height / 64) * 64
        hideSource: rootItem.visible
        smooth: true
        sourceItem: priv.useBlurItem1 ? rootItem.source : null
        visible: false
        width: Math.ceil(rootItem.width / 64) * 64
    }

    BlurItem {
        id: blurredItem1

        property var source: blurredItemSource1

        anchors.fill: blurredItemSource2
    }

    ShaderEffectSource {
        id: blurredItemSource2

        height: blurredItemSource1.height / 2
        hideSource: rootItem.visible
        smooth: true
        sourceItem: priv.useBlurItem2 ? blurredItem1 : null
        visible: false
        width: blurredItemSource1.width / 2
    }

    BlurItem {
        id: blurredItem2

        property var source: blurredItemSource2

        anchors.fill: blurredItemSource3
    }

    ShaderEffectSource {
        id: blurredItemSource3

        height: blurredItemSource2.height / 2
        hideSource: rootItem.visible
        smooth: true
        sourceItem: priv.useBlurItem3 ? blurredItem2 : null
        visible: false
        width: blurredItemSource2.width / 2
    }

    BlurItem {
        id: blurredItem3

        property var source: blurredItemSource3

        anchors.fill: blurredItemSource4
    }

    ShaderEffectSource {
        id: blurredItemSource4

        height: blurredItemSource3.height / 2
        hideSource: rootItem.visible
        smooth: true
        sourceItem: priv.useBlurItem4 ? blurredItem3 : null
        visible: false
        width: blurredItemSource3.width / 2
    }

    BlurItem {
        id: blurredItem4

        property var source: blurredItemSource4

        anchors.fill: blurredItemSource5
    }

    ShaderEffectSource {
        id: blurredItemSource5

        height: blurredItemSource4.height / 2
        hideSource: rootItem.visible
        smooth: true
        sourceItem: priv.useBlurItem5 ? blurredItem4 : null
        visible: false
        width: blurredItemSource4.width / 2
    }

    BlurItem {
        id: blurredItem5

        property var source: blurredItemSource5

        anchors.fill: blurredItemSource6
    }

    ShaderEffectSource {
        id: blurredItemSource6

        height: blurredItemSource5.height / 2
        hideSource: rootItem.visible
        smooth: true
        sourceItem: priv.useBlurItem6 ? blurredItem5 : null
        visible: false
        width: blurredItemSource5.width / 2
    }

    component BlurItem: ShaderEffect {
        property vector2d offset: Qt.vector2d((1.0 + rootItem.blurMultiplier) / width // qmllint disable
        , (1.0 + rootItem.blurMultiplier) / height)

        fragmentShader: "bluritems.frag.qsb"
        smooth: true
        vertexShader: "bluritems.vert.qsb"
        visible: false
    }
}
