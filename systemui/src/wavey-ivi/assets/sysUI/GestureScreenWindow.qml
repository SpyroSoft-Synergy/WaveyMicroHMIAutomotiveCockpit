import QtQuick
import controls
import gesture.views
import helpers
import viewmodels
import wavey.style
import wavey.ui
import QtApplicationManager.SystemUI

Window {
    id: root

    property GestureViewModel viewModel: GestureViewModel {
    }

    color: WaveyStyle.backgroundColor // qmllint disable
    height: root.viewModel.screenHeight
    title: "Wavey Gesture Screen"
    visible: true
    width: root.viewModel.screenWidth

    Component.onCompleted: PressListener.listenTo(root) // qmllint disable

    Item {
        id: content

        height: background.height
        scale: Math.min(root.width / content.width, root.height / content.height)
        transformOrigin: Item.TopLeft
        width: background.width

        states: [
            State {
                name: "visible"
                when: !gestureView.pressed

                PropertyChanges {
                    opacity: 1
                    target: tempLeft
                }

                PropertyChanges {
                    opacity: 1
                    target: tempRight
                }

                PropertyChanges {
                    opacity: 1
                    target: acSettings
                }
            },
            State {
                name: "hidden"
                when: gestureView.pressed && (!tempLeft.active || !tempRight.active)

                PropertyChanges {
                    opacity: 0
                    target: tempLeft
                }

                PropertyChanges {
                    opacity: 0
                    target: tempRight
                }

                PropertyChanges {
                    opacity: 0
                    target: acSettings
                }
            }
        ]
        transitions: [
            Transition {
                from: "visible"

                NumberAnimation {
                    duration: 100
                    properties: "opacity"
                    target: tempLeft
                }

                NumberAnimation {
                    duration: 100
                    properties: "opacity"
                    target: tempRight
                }

                NumberAnimation {
                    duration: 100
                    properties: "opacity"
                    target: acSettings
                }
            },
            Transition {
                from: "hidden"

                SequentialAnimation {
                    PauseAnimation {
                        duration: 600
                    }

                    ParallelAnimation {
                        NumberAnimation {
                            duration: 1000
                            properties: "opacity"
                            target: tempLeft
                        }

                        NumberAnimation {
                            duration: 1000
                            properties: "opacity"
                            target: tempRight
                        }

                        NumberAnimation {
                            duration: 1000
                            properties: "opacity"
                            target: acSettings
                        }
                    }
                }
            }
        ]

        Image {
            id: background

            source: String("gestureUI/%1/background.png").arg(WaveyStyle.currentThemeName.toLowerCase())
        }

        GestureView {
            id: gestureView

            anchors.fill: parent
            anchors.topMargin: 479
            viewModel: root.viewModel
        }

        Item {
            id: appContainer

            clip: true

            anchors {
                bottom: separator.top
                left: parent.left
                right: parent.right
                top: parent.top
            }

            Repeater {
                model: root.viewModel.apps

                WindowItem {
                    id: windowItem

                    required property int index
                    required property var model

                    anchors.fill: parent
                    visible: windowItem.model.slot.active
                    window: windowItem.model.slot.windowObject

                    Rectangle {
                        anchors.fill: parent
                        color: "white"
                        opacity: 0.5
                        visible: windowItem.model.slot.appId === ""

                        Text {
                            anchors.centerIn: parent
                            text: windowItem.model.slot.name + " " + windowItem.index
                        }
                    }
                }
            }
        }

        Rectangle {
            id: separator

            color: WaveyStyle.separatorColor // qmllint disable
            height: 2
            opacity: 0.2

            anchors {
                left: parent.left
                right: parent.right
                top: parent.top
                topMargin: 479
            }
        }

        TempControl {
            id: tempLeft

            anchors.left: parent.left
            anchors.leftMargin: 50
            anchors.top: gestureView.top
            anchors.topMargin: 55
            label: "Driver"
            value: 70.0
        }

        TempControl {
            id: tempRight

            anchors.right: parent.right
            anchors.rightMargin: 50
            anchors.top: gestureView.top
            anchors.topMargin: 55
            label: "Passenger"
            value: 71.0
        }

        Rectangle {
            id: tempBar

            anchors.bottom: parent.bottom
            anchors.bottomMargin: 30
            anchors.horizontalCenter: parent.horizontalCenter
            color: WaveyStyle.primaryColor // qmllint disable
            height: 8
            radius: 4
            width: 120
        }

        Column {
            id: acSettings

            anchors.bottom: tempBar.top
            anchors.bottomMargin: 15
            anchors.horizontalCenter: parent.horizontalCenter
            spacing: 5

            Image {
                anchors.horizontalCenter: parent.horizontalCenter
                source: String("gestureUI/%1/ac_icon.png").arg(WaveyStyle.currentThemeName.toLowerCase())
            }

            Text {
                color: WaveyStyle.primaryColor // qmllint disable
                font: WaveyFonts.h7 // qmllint disable
                text: "AC Settings"
            }
        }

        Image {
            anchors.bottom: parent.bottom
            source: String("gestureUI/%1/ac_glow.png").arg(WaveyStyle.currentThemeName.toLowerCase())
            width: parent.width
        }

        Loader {
            // Currently Theme Switching is disable until white theme design is updated
            active: false
            anchors.fill: parent

            sourceComponent: ThemeSwitch {
                id: themeSwitch

                anchors.left: parent.left
                anchors.right: parent.right
                anchors.top: parent.top

                onChangeTheme: theme => root.viewModel.changeTheme(theme)
            }
        }

        Loader {
            active: root.viewModel.developmentMode
            anchors.bottom: lastGesture.top
            anchors.horizontalCenter: parent.horizontalCenter
            sourceComponent: gesturesPanel

            Component {
                id: gesturesPanel

                GesturesEmulationPanel {
                    onBeginPinch: value => root.viewModel.beginFakePinch(value)
                    onEndPinch: () => root.viewModel.endFakePinch()
                    onFingerCountChanged: fingerCount => root.viewModel.fingerCount = fingerCount
                    onUpdatePinch: value => root.viewModel.updateFakePinch(value)
                }
            }
        }

        Text {
            id: lastGesture

            anchors.bottom: background.bottom
            anchors.bottomMargin: 10
            anchors.horizontalCenter: background.horizontalCenter
            color: WaveyStyle.theme === WaveyStyle.Light ? "black" : "white"
            font.pixelSize: 15
            text: root.viewModel.lastGesture
            visible: root.viewModel.developmentMode
        }
    }
}
