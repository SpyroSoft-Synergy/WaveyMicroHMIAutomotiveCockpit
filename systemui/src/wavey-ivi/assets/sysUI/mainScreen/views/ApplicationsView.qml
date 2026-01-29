pragma ComponentBehavior: Bound
import QtQuick
import QtApplicationManager.SystemUI
import viewmodels
import models
import wavey.style
import shaderEffects
import mainScreen.controls

Item {
    id: root

    readonly property int addAppSlotWidth: 360
    readonly property real arrangeScale: 7 / 11
    readonly property int fullSlotWidth: 1840
    readonly property int halfSlotWidth: (fullSlotWidth - spacing) / 2
    readonly property int largeSlotWidth: 2 * thirdSlotWidth + spacing
    readonly property int slotHeight: 660
    readonly property int spacing: 20
    readonly property int thirdSlotWidth: (fullSlotWidth - 2 * spacing) / 3
    property MainScreenViewModel viewModel

    function slotWidth(size, arrangeMode = root.viewModel.arrangeModeActive, appCount = root.viewModel.apps.count) {
        if (!arrangeMode) {
            if (appCount === 1) {
                return root.fullSlotWidth;
            } else if (appCount > 2) {
                return root.thirdSlotWidth;
            }
        }
        switch (size) {
        case ApplicationSlot.Size.Small:
            return root.thirdSlotWidth;
        case ApplicationSlot.Size.Medium:
            return root.halfSlotWidth;
        case ApplicationSlot.Size.Large:
            return root.largeSlotWidth;
        default:
            return root.halfSlotWidth;
        }
    }

    width: fullSlotWidth // required for proper transformation origin

    states: State {
        name: "arrange"
        when: root.viewModel.arrangeModeActive

        PropertyChanges {
            scale: root.arrangeScale
            target: content
        }

        PropertyChanges {
            opacity: 1.0
            target: appAddIcon
        }
    }
    transitions: Transition {
        from: "*"
        to: "*"

        ScriptAction {
            script: {
                content.switchEditModeAnimationInProgress = true;
                if (root.viewModel.arrangeModeActive) {
                    root.viewModel.apps.setInArrangeMode(true);
                }
            }
        }

        NumberAnimation {
            properties: "scale"
        }

        NumberAnimation {
            duration: 100
            properties: "opacity"
            target: appAddIcon
        }

        ScriptAction {
            script: {
                content.switchEditModeAnimationInProgress = false;
                if (!root.viewModel.arrangeModeActive) {
                    root.viewModel.apps.setInArrangeMode(false);
                }
            }
        }
    }

    Item {
        id: content

        property bool switchEditModeAnimationInProgress: false

        anchors.centerIn: parent
        height: root.slotHeight
        transformOrigin: Item.Center
        width: root.fullSlotWidth // required for proper transformation origin

        ListView {
            id: appSlotsView

            property bool moveSlotModeActive: false

            anchors.centerIn: parent
            height: root.slotHeight
            interactive: false
            model: root.viewModel.apps
            orientation: ListView.Horizontal
            spacing: root.spacing
            width: childrenRect.width

            delegate: Item {
                id: component

                readonly property real isSlotMoving: component.model.slot.mode === ApplicationSlot.Mode.Move
                required property var model
                readonly property real slotWidth: root.slotWidth(component.model.slot.size)
                property real widthMultiplier: 1.0

                height: root.slotHeight
                width: slotWidth * widthMultiplier

                states: [
                    State {
                        name: "move_mode"
                        when: component.isSlotMoving

                        PropertyChanges {
                            anchors.verticalCenterOffset: -component.height * 0.25
                            target: appWindow
                        }
                    },
                    State {
                        name: "move_mode_background_slot"
                        when: appSlotsView.moveSlotModeActive

                        PropertyChanges {
                            opacity: 0.5
                            target: component
                        }
                    },
                    State {
                        extend: "selected_to_close"
                        name: "closed"
                        when: component.model.slot.closed

                        PropertyChanges {
                            anchors.verticalCenterOffset: -component.height * 1.6
                            target: appWindow
                        }

                        PropertyChanges {
                            target: component
                            width: 0
                        }

                        PropertyChanges {
                            opacity: 0.0
                            target: closeAppGlow
                        }

                        PropertyChanges {
                            opacity: 0.0
                            target: appCloseContainer
                        }

                        PropertyChanges {
                            opacityOffset: 0.6
                            target: maskRect
                        }
                    },
                    State {
                        name: "selected_to_close"
                        when: component.model.slot.mode === ApplicationSlot.Mode.Close

                        PropertyChanges {
                            opacityOffset: 0.4
                            target: maskRect
                        }

                        PropertyChanges {
                            layer.enabled: true
                            target: appContainer
                        }

                        PropertyChanges {
                            anchors.bottomMargin: 0
                            opacity: 1.0
                            target: appCloseContainer
                        }

                        PropertyChanges {
                            anchors.verticalCenterOffset: -component.height * 0.25
                            target: appWindow
                        }

                        PropertyChanges {
                            opacity: 0.0
                            target: activeAppGlow
                        }

                        PropertyChanges {
                            opacity: 1.0
                            target: closeAppGlow
                        }
                    }
                ]
                transitions: [
                    Transition {
                        from: "*"
                        to: "selected_to_close"

                        NumberAnimation {
                            property: "anchors.verticalCenterOffset"
                            target: appWindow
                        }

                        NumberAnimation {
                            property: "opacityOffset"
                            target: maskRect
                        }

                        NumberAnimation {
                            properties: "opacity,anchors.bottomMargin"
                            target: appCloseContainer
                        }

                        NumberAnimation {
                            property: "opacity"
                            target: activeAppGlow
                        }

                        SequentialAnimation {
                            PauseAnimation {
                                duration: 50
                            }

                            NumberAnimation {
                                property: "opacity"
                                target: closeAppGlow
                            }
                        }
                    },
                    Transition {
                        from: "selected_to_close"
                        to: "closed"

                        NumberAnimation {
                            property: "opacityOffset"
                            target: maskRect
                        }

                        SequentialAnimation {
                            NumberAnimation {
                                duration: 450
                                property: "anchors.verticalCenterOffset"
                                target: appWindow
                            }

                            ParallelAnimation {
                                NumberAnimation {
                                    property: "width"
                                    target: component
                                }

                                SequentialAnimation {
                                    PauseAnimation {
                                        duration: 50
                                    }

                                    ParallelAnimation {
                                        NumberAnimation {
                                            property: "opacity"
                                            target: appCloseContainer
                                        }

                                        NumberAnimation {
                                            property: "opacity"
                                            target: closeAppGlow
                                        }
                                    }
                                }
                            }
                        }
                    },
                    Transition {
                        from: "selected_to_close"
                        to: "*"

                        NumberAnimation {
                            property: "opacityOffset"
                            target: maskRect
                        }

                        NumberAnimation {
                            property: "anchors.verticalCenterOffset"
                            target: appWindow
                        }

                        NumberAnimation {
                            properties: "opacity,anchors.bottomMargin"
                            target: appCloseContainer
                        }

                        NumberAnimation {
                            property: "opacity"
                            target: closeAppGlow
                        }

                        SequentialAnimation {
                            PauseAnimation {
                                duration: 100
                            }

                            NumberAnimation {
                                property: "opacity"
                                target: activeAppGlow
                            }
                        }

                        SequentialAnimation {
                            PauseAnimation {
                                duration: 250
                            }

                            PropertyAction {
                                property: "layer.enabled"
                                target: appContainer
                            }
                        }
                    },
                    Transition {
                        from: "*"
                        reversible: true
                        to: "move_mode"

                        NumberAnimation {
                            duration: 150
                            property: "anchors.verticalCenterOffset"
                            target: appWindow
                        }
                    },
                    Transition {
                        from: "*"
                        reversible: true
                        to: "move_mode_background_slot"

                        NumberAnimation {
                            property: "opacity"
                            target: component
                        }
                    }
                ]
                Behavior on width {
                    id: componentWidthBehaviour

                    enabled: {
                        if (content.switchEditModeAnimationInProgress) {
                            return true;
                        }
                        if (component.model.slot.mode !== ApplicationSlot.Mode.None) {
                            return false;
                        }
                        return root.viewModel.apps.resizeEnabled || root.viewModel.apps.count === 1;
                    }

                    NumberAnimation {
                    }
                }

                onIsSlotMovingChanged: appSlotsView.moveSlotModeActive = isSlotMoving

                Image {
                    id: activeAppGlow

                    anchors.horizontalCenter: appContainer.horizontalCenter
                    anchors.verticalCenter: parent.bottom
                    anchors.verticalCenterOffset: 40
                    fillMode: Image.Stretch
                    opacity: root.viewModel.arrangeModeActive && component.model.slot.active ? 1 : 0
                    source: "../../mainScreenUI/active_app_glow.png"
                    visible: root.viewModel.arrangeModeActive
                    width: slotWidth * 1.5

                    Behavior on opacity {
                        NumberAnimation {
                        }
                    }
                    Behavior on width {
                        enabled: componentWidthBehaviour.enabled

                        NumberAnimation {
                        }
                    }
                }

                Image {
                    id: closeAppGlow

                    anchors.fill: activeAppGlow
                    fillMode: Image.Stretch
                    opacity: 0.0
                    source: "../../mainScreenUI/close_app_glow.png"
                }

                Row {
                    id: appCloseContainer

                    opacity: 0.0
                    spacing: 10

                    anchors {
                        bottom: parent.bottom
                        bottomMargin: -50
                        horizontalCenter: parent.horizontalCenter
                    }

                    Image {
                        id: appCloseIcon

                        anchors.bottom: parent.bottom
                        height: width
                        source: "../../mainScreenUI/close_app.png"
                        width: 48 / root.arrangeScale
                    }

                    Text {
                        id: appActionText

                        anchors.verticalCenter: appCloseIcon.verticalCenter
                        color: WaveyStyle.primaryColor
                        font: appName.font
                        text: "Close Application"
                    }
                }

                Rectangle {
                    id: maskRect

                    property real opacityOffset: 0.01

                    height: root.height / arrangeScale
                    layer.enabled: true
                    visible: false

                    gradient: Gradient {
                        GradientStop {
                            color: "#00FFFFFF"
                            position: 0.0
                        }

                        GradientStop {
                            color: "#FFFFFF"
                            position: maskRect.opacityOffset
                        }
                    }

                    anchors {
                        left: parent.left
                        right: parent.right
                    }
                }

                Item {
                    id: appContainer

                    height: maskRect.height
                    layer.enabled: false

                    layer.effect: OpacityMask {
                        opacityMaskSource: maskRect
                        source: appContainer
                    }

                    anchors {
                        left: parent.left
                        right: parent.right
                        verticalCenter: parent.verticalCenter
                    }

                    WindowItem {
                        id: appWindow

                        height: component.height
                        window: component.model.slot.windowObject

                        anchors {
                            left: parent.left
                            right: parent.right
                            verticalCenter: parent.verticalCenter
                        }
                    }

                    Text {
                        id: appName

                        color: WaveyStyle.accentColor
                        opacity: {
                            const targetOpacity = component.model.slot.active ? 1 : 0.5;
                            if (content.switchEditModeAnimationInProgress) {
                                return root.viewModel.arrangeModeActive ? targetOpacity : 0;
                            } else if (!root.viewModel.arrangeModeActive) {
                                return 0;
                            }

                            return targetOpacity;
                        }
                        text: component.model.slot.name
                        visible: root.viewModel.arrangeModeActive

                        Behavior on opacity {
                            enabled: content.switchEditModeAnimationInProgress

                            NumberAnimation {
                            }
                        }

                        anchors {
                            horizontalCenter: appWindow.horizontalCenter
                            top: appWindow.bottom
                            topMargin: 15
                        }

                        font {
                            family: WaveyFonts.h7.family
                            pixelSize: WaveyFonts.h7.pixelSize / root.arrangeScale
                            weight: WaveyFonts.h7.weight
                        }
                    }
                }
            }
            move: Transition {
                NumberAnimation {
                    duration: 200
                    property: "x"
                }
            }
            moveDisplaced: Transition {
                NumberAnimation {
                    duration: 200
                    property: "x"
                }
            }
        }

        Item {
            id: tryaddSlotArea

            readonly property bool active: viewModel.apps.addAppSlotSelected

            height: root.slotHeight
            opacity: {
                if (root.viewModel.apps.count < root.viewModel.apps.maxSlotsCount && root.viewModel.availableAppsVisualModel.length > 0) {
                    return active ? 1.0 : 0.25;
                }
                return 0;
            }
            width: root.viewModel.arrangeModeActive ? root.addAppSlotWidth / root.arrangeScale : 0

            Behavior on opacity {
                NumberAnimation {
                }
            }
            Behavior on width {
                enabled: root.viewModel.apps.count > 0 || !root.viewModel.arrangeModeActive

                NumberAnimation {
                }
            }

            anchors {
                left: appSlotsView.right
                leftMargin: appSlotsView.spacing
                verticalCenter: appSlotsView.verticalCenter
            }

            Image {
                anchors.bottomMargin: -10
                anchors.fill: parent
                fillMode: Image.Stretch
                layer.enabled: tryaddSlotArea.active
                source: "../../mainScreenUI/add_slot_border.png"

                layer.effect: AppSlotBorderEffect {
                }
            }

            Rectangle {
                id: addSlotGradient

                anchors.fill: parent
                color: WaveyStyle.accentColor
                radius: 35

                gradient: Gradient {
                    GradientStop {
                        color: Qt.rgba(addSlotGradient.color.r, addSlotGradient.color.g, addSlotGradient.color.b, 0.2)
                        position: 0.0
                    }

                    GradientStop {
                        color: Qt.rgba(addSlotGradient.color.r, addSlotGradient.color.g, addSlotGradient.color.b, 0.0)
                        position: 0.5
                    }
                }
            }

            Image {
                anchors.horizontalCenter: parent.horizontalCenter
                anchors.verticalCenter: parent.bottom
                anchors.verticalCenterOffset: 40
                fillMode: Image.Stretch
                opacity: root.viewModel.arrangeModeActive && tryaddSlotArea.active ? 1 - appPicker.opacity : 0
                source: "../../mainScreenUI/active_app_glow.png"
                width: parent.width * 1.5
            }

            Image {
                anchors.horizontalCenter: parent.right
                anchors.verticalCenter: parent.verticalCenter
                fillMode: Image.Stretch
                opacity: appPicker.opacity
                rotation: -90
                source: "../../mainScreenUI/active_app_glow.png"
                width: parent.height * 1.25
            }

            Image {
                anchors.horizontalCenter: parent.left
                anchors.verticalCenter: parent.verticalCenter
                fillMode: Image.Stretch
                opacity: appPicker.opacity
                rotation: 90
                source: "../../mainScreenUI/active_app_glow.png"
                width: parent.height * 1.25

                Behavior on opacity {
                    NumberAnimation {
                    }
                }
            }

            Image {
                id: appAddIcon

                anchors.centerIn: parent
                height: width
                opacity: 0
                source: "../../mainScreenUI/add_app.png"
                width: 96
            }

            Text {
                color: WaveyStyle.accentColor
                opacity: appAddIcon.opacity
                scale: appAddIcon.scale
                text: "Add Application"

                anchors {
                    horizontalCenter: appAddIcon.horizontalCenter
                    top: appAddIcon.bottom
                    topMargin: 6
                }

                font {
                    family: WaveyFonts.h7.family
                    pixelSize: WaveyFonts.h7.pixelSize / root.arrangeScale
                    weight: WaveyFonts.h7.weight
                }
            }

            AppPicker {
                id: appPicker

                anchors.centerIn: tryaddSlotArea
                appCount: root.viewModel.availableApps.length
                arrangeScale: root.arrangeScale
                availableApps: root.viewModel.availableAppsVisualModel
                currentIndex: root.viewModel.availableAppIndex
                isShown: root.viewModel.appSelectionActive && root.viewModel.arrangeModeActive
            }

            Connections {
                function onAppSelectionGoDown() {
                    appPicker.goDown();
                }

                function onAppSelectionGoUp() {
                    appPicker.goUp();
                }

                target: root.viewModel
            }
        }
    }

    Row {
        id: pager

        spacing: 8

        anchors {
            bottom: root.bottom
            horizontalCenter: parent.horizontalCenter
            margins: 15
        }

        Repeater {
            model: {
                const appCount = root.viewModel.apps.count;
                if (root.viewModel.arrangeModeActive && appCount < root.viewModel.apps.maxSlotsCount && root.viewModel.availableAppsVisualModel.length > 0) {
                    // Diplay add application slot in pager
                    return appCount + 1;
                }
                return appCount;
            }

            Rectangle {
                id: pagerComponent

                readonly property bool active: pagerComponent.model.index === root.viewModel.apps.activeSlot
                required property var model

                color: WaveyStyle.accentColor // qmllint disable

                height: 8
                opacity: active ? 1.0 : 0.2
                radius: 4
                width: active ? 40 : height

                Behavior on width {
                    NumberAnimation {
                    }
                }
            }
        }
    }
}
