import QtQuick
import wavey.style
import shaderEffects
import viewmodels
import mainScreen.helpers
import QtApplicationManager.SystemUI

Item {
    id: root

    readonly property int indicatorProgressOffset: 40
    readonly property string resourcePath: "../../mainScreenUI/cluster/"
    property MainScreenViewModel viewModel

    QtObject {
        id: priv

        property string activeCategory: ""
        readonly property ListModel categoryModel: ListModel {
            id: categoryModel

            ListElement {
                category: "phone"
                text: "Phone content not available"
                title: "Phone"
            }

            ListElement {
                category: "media"
                text: "Media content not available"
                title: "Multimedia"
            }

            ListElement {
                category: "navigation"
                text: "Navigation content not available"
                title: "Navigation"
            }

            ListElement {
                category: "stats"
                text: "Stats content not available"
                title: "Stats"
            }
        }
        readonly property Connections clusterWindowsConnections: Connections {
            id: clusterWindowsConnections

            function onAppClusterWindowsChanged() {
                indexChangeConnections.onActiveSlotChanged();
            }

            target: root.viewModel
        }
        readonly property Connections indexChangeConnections: Connections {
            id: indexChangeConnections

            function onActiveSlotChanged() {
                const appId = root.viewModel.apps.getSlotAppId(root.viewModel.apps.activeSlot);
                const window = root.viewModel.clusterWindows[appId];
                appContainerItem.window = window ?? null;
                priv.activeCategory = window ? window.application.categories[0] : "";
            }

            function onCountChanged() {
                indexChangeConnections.onActiveSlotChanged();
            }

            target: viewModel.apps
        }
    }

    Image {
        id: leftIndicatorsBackground

        source: resourcePath + "left_indicators_bg.png"

        anchors {
            left: parent.left
            leftMargin: 90
            verticalCenter: parent.verticalCenter
        }
    }

    Item {
        // Container to prevent shader blur clipping
        id: powerProgressOff

        anchors.fill: powerProgressOn
        layer.enabled: true
        visible: false

        Image {
            source: root.resourcePath + "power_off.png"

            anchors {
                right: parent.right
                top: parent.top
            }
        }
    }

    Item {
        // Container to prevent shader blur clipping
        id: powerProgressOn

        height: powerProgressOnImage.height + root.indicatorProgressOffset
        layer.enabled: true
        visible: false
        width: powerProgressOnImage.width + root.indicatorProgressOffset

        anchors {
            left: leftIndicatorsBackground.left
            leftMargin: -root.indicatorProgressOffset
            top: leftIndicatorsBackground.top
        }

        Image {
            id: powerProgressOnImage

            source: root.resourcePath + "power_on.png"

            anchors {
                right: parent.right
                top: parent.top
            }
        }
    }

    ClusterCircleMask {
        id: powerProgress

        anchors.fill: powerProgressOn
        centerOffset: Qt.point(0.720, 0.152)
        fromAngle: 254
        secondSource: powerProgressOff
        source: powerProgressOn
        splitPercent: {
            const percent = ((animator.maxPower - animator.power) / animator.maxPower * 10 + 1);
            return 1.0 - Math.log10(percent);
        }
        toAngle: 326
    }

    Image {
        id: chargingProgressOff

        anchors.fill: chargingProgressOn
        source: root.resourcePath + "charging_off.png"
        visible: false
    }

    Image {
        id: chargingProgressOn

        source: root.resourcePath + "charging_on.png"
        visible: false

        anchors {
            bottom: leftIndicatorsBackground.bottom
            left: leftIndicatorsBackground.left
        }
    }

    ClusterCircleMask {
        id: chargingProgress

        anchors.fill: chargingProgressOn
        centerOffset: Qt.point(0.720, -0.521)
        clockwise: false
        fromAngle: 206
        secondSource: chargingProgressOff
        source: chargingProgressOn
        splitPercent: animator.charge
        toAngle: 240
    }

    Image {
        id: rightIndicatorsBackground

        source: root.resourcePath + "right_indicators_bg.png"

        anchors {
            left: middleContents.right
            verticalCenter: parent.verticalCenter
        }
    }

    Item {
        // Container to prevent shader blur clipping
        id: fuelProgressOff

        anchors.fill: fuelProgressOn
        layer.enabled: true
        visible: false

        Image {
            source: root.resourcePath + "fuel_off.png"

            anchors {
                left: parent.left
                top: parent.top
            }
        }
    }

    Item {
        // Container to prevent shader blur clipping
        id: fuelProgressOn

        height: fuelProgressOnImage.height + root.indicatorProgressOffset
        layer.enabled: true
        visible: false
        width: fuelProgressOnImage.width + root.indicatorProgressOffset

        anchors {
            right: rightIndicatorsBackground.right
            rightMargin: -root.indicatorProgressOffset
            top: rightIndicatorsBackground.top
        }

        Image {
            id: fuelProgressOnImage

            source: root.resourcePath + "fuel_on.png"

            anchors {
                left: parent.left
                top: parent.top
            }
        }
    }

    ClusterCircleMask {
        id: fuelProgress

        anchors.fill: fuelProgressOn
        centerOffset: Qt.point(-0.720, 0.070)
        clockwise: false
        fromAngle: 42
        secondSource: fuelProgressOff
        source: fuelProgressOn
        splitPercent: 1.0
        toAngle: 109

        Behavior on splitPercent {
            NumberAnimation {
            }
        }

        Timer {
            interval: 3000
            repeat: true
            running: true

            onTriggered: {
                const step = 0.01;
                let percent = fuelProgress.splitPercent - step;
                if (percent < 0.02) {
                    percent = 1.0;
                }
                fuelProgress.splitPercent = percent;
            }
        }
    }

    Image {
        id: batteryProgressOff

        anchors.fill: batteryProgressOn
        source: root.resourcePath + "battery_off.png"
        visible: false
    }

    Image {
        id: batteryProgressOn

        source: root.resourcePath + "battery_on.png"
        visible: true

        anchors {
            bottom: rightIndicatorsBackground.bottom
            bottomMargin: 21
            right: rightIndicatorsBackground.right
        }
    }

    ClusterCircleMask {
        id: batteryProgress

        anchors.fill: batteryProgressOn
        centerOffset: Qt.point(-0.75, -0.55)
        fromAngle: 122
        secondSource: batteryProgressOff
        source: batteryProgressOn
        splitPercent: 1.0
        toAngle: 154

        Behavior on splitPercent {
            NumberAnimation {
            }
        }

        Timer {
            interval: 3000
            repeat: true
            running: true

            onTriggered: {
                const step = 0.01;
                let percent = batteryProgress.splitPercent;
                if (animator.charging > 0) {
                    percent = Math.min(1.0, percent + step);
                } else {
                    percent -= step;
                }
                if (percent < 0.02) {
                    percent = 1.0;
                }
                batteryProgress.splitPercent = percent;
            }
        }
    }

    Item {
        height: 500
        width: 500

        anchors {
            horizontalCenter: middleContents.horizontalCenter
            top: leftIndicatorsBackground.top
            topMargin: 80
        }

        WindowItem {
            id: appContainerItem

            anchors.fill: parent
            visible: appContainerItem.window != null
        }

        Text {
            anchors.centerIn: parent
            anchors.verticalCenterOffset: -50
            color: WaveyStyle.secondaryColor // qmllint disable
            font: WaveyFonts.h7 // qmllint disable
            text: "Content not available"
            visible: appContainerItem.window == null
        }
    }

    Column {
        id: middleContents

        spacing: 10
        width: 500

        anchors {
            left: leftIndicatorsBackground.right
            leftMargin: -20
            top: parent.top
            topMargin: 50
        }

        Image {
            anchors.horizontalCenter: parent.horizontalCenter
            source: root.resourcePath + "speed_limit.png"
        }

        Item {
            anchors.horizontalCenter: parent.horizontalCenter
            height: speedText.height + 30
            width: parent.width

            Text {
                id: speedText

                anchors.horizontalCenter: parent.horizontalCenter
                color: WaveyStyle.secondaryColor
                font: WaveyFonts.speed
                text: "0"

                Timer {
                    interval: 1000 / 3
                    repeat: true
                    running: true

                    onTriggered: speedText.text = animator.speed
                }
            }

            Text {
                color: WaveyStyle.secondaryColor
                text: "km/h"

                anchors {
                    horizontalCenter: speedText.horizontalCenter
                    top: speedText.baseline
                    topMargin: 10
                }

                font {
                    family: WaveyFonts.h7.family
                    pixelSize: 12
                }
            }
        }

        Row {
            id: optionRow

            anchors.horizontalCenter: parent.horizontalCenter
            spacing: 0

            Repeater {
                id: optionsRepeater

                model: priv.categoryModel

                delegate: Item {
                    id: optionComponent

                    readonly property bool active: optionComponent.model.category === priv.activeCategory
                    required property var model

                    height: 27
                    width: 100

                    Text {
                        anchors.horizontalCenter: parent.horizontalCenter
                        anchors.top: parent.top
                        color: optionComponent.active ? WaveyStyle.primaryColor : WaveyStyle.secondaryColor
                        font: WaveyFonts.numbers
                        text: optionComponent.model.title
                    }

                    Rectangle {
                        color: WaveyStyle.primaryColor
                        height: optionComponent.active ? 2 : 1
                        opacity: optionComponent.active ? 1 : 0.2

                        anchors {
                            bottom: parent.bottom
                            left: parent.left
                            right: parent.right
                        }
                    }
                }
            }
        }
    }

    Row {
        spacing: 15

        anchors {
            left: leftIndicatorsBackground.left
            top: middleContents.top
        }

        Image {
            id: laneAssist

            property bool on: false

            source: root.resourcePath + String("laneassist_%1.png").arg(laneAssist.on ? "on" : "off")

            Timer {
                interval: laneAssist.on ? 2000 : 5000
                repeat: true
                running: true

                onTriggered: laneAssist.on = !laneAssist.on
            }
        }

        Image {
            id: changeLane

            property bool on: false

            source: root.resourcePath + String("changelane_%1.png").arg(changeLane.on ? "on" : "off")

            Timer {
                interval: changeLane.on ? 2500 : 4000
                repeat: true
                running: true

                onTriggered: changeLane.on = !changeLane.on
            }
        }
    }

    Row {
        spacing: 15

        anchors {
            bottom: parent.bottom
            bottomMargin: middleContents.anchors.topMargin
            left: leftIndicatorsBackground.left
        }

        Image {
            source: root.resourcePath + "autobeamlights_on.png"
        }

        Image {
            source: root.resourcePath + "daylights_on.png"
        }
    }

    ClusterAnimator {
        id: animator

    }
}
