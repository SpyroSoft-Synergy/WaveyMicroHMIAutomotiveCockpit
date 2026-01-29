import QtQuick
import QtQuick.Controls
import TestBed.helpers
import wavey.windows

Window {
    color: "red"
    minimumWidth: content.childrenRect.width + 30
    minimumHeight: content.childrenRect.height + 30
    visible: true
    title: "testbed"

    enum GestureType {
        Unknown,
        Swipe,
        Drag,
        Tap,
        DoubleTap,
        Scroll,
        Pinch,
        TapAndHold
    }

    enum GestureDirection {
        None,
        Left,
        Top,
        Right,
        Bottom
    }

    Column {
        id: content
        anchors.centerIn: parent
        spacing: 10

        Text {
            text: "Application Gestures"
            font.bold: true
        }

        Row {
            spacing: 20
            Text {
                text: "Type"
                width: 150
            }

            ComboBox {
                id: type
                model: ["Unknown", "Swipe", "Drag", "Tap", "DoubleTap", "Scroll", "Pinch"]

            }
        }

        Row {
            spacing: 20
            Text {
                text: "Fingers Count:"
                width: 150
            }

            SpinBox {
                id: fingersCount
                from: 1
                to: 3
            }
        }

        Row {
            spacing: 20
            Text {
                text: "Direction:"
                width: 150
            }

            ComboBox {
                id: direction
                model: ["None", "Left", "Top", "Right", "Bottom"]

            }
        }

        Row {
            spacing: 20
            Text {
                text: "X Change (" + xChange.value + "):"
                width: 150
            }

            Slider {
                id: xChange
                from: -1080
                to: 1080
                value: 0
                stepSize: 1

            }

            Button {
                text: "Reset"
                onClicked: {
                    xChange.value = 0
                }
            }
        }

        Row {
            spacing: 20
            Text {
                text: "Y Change (" + yChange.value + "):"
                width: 150
            }

            Slider {
                id: yChange
                from: -1080
                to: 1080
                value: 0
                stepSize: 1

            }

            Button {
                text: "Reset"
                onClicked: {
                    yChange.value = 0
                }
            }
        }

        Row {
            spacing: 20
            Text {
                text: "Scale Change (" + scaleChange.value + "):"
                width: 150
            }

            Slider {
                id: scaleChange
                from: 0
                to: 10
                value: 1
                stepSize: 0.1

            }

            Button {
                text: "Reset"
                onClicked: {
                    scaleChange.value = 1
                }
            }
        }

        Text {
            text: "Application Gestures Modifiers"
            font.bold: true
        }

        CheckBox {
            id: pressAndHoldModifier
            text: "Press And Hold"
            checked: false
        }

        Button {
            text: "Send Gesture"
            enabled: !delayedGestureTimer.running
            onClicked: {
                if (pressAndHoldModifier.checked) {
                    IntentsServerHelper.makeGestureRequest(TestBedWindow.GestureType.TapAndHold, fingersCount.value, TestBedWindow.GestureDirection.None, xChange.value, yChange.value, scaleChange.value, false)
                    delayedGestureTimer.start()
                    return
                }
                IntentsServerHelper.makeGestureRequest(type.currentIndex, fingersCount.value, direction.currentIndex, xChange.value, yChange.value, scaleChange.value, false)
                if (type.currentIndex === 6)
                    IntentsServerHelper.makeGestureRequest(type.currentIndex, fingersCount.value, direction.currentIndex, xChange.value, yChange.value, scaleChange.value, true)
            }
        }

        Timer {
            id: delayedGestureTimer
            interval: 820
            onTriggered: {
                IntentsServerHelper.makeGestureRequest(type.currentIndex, fingersCount.value, direction.currentIndex, xChange.value, yChange.value, scaleChange.value, false)
            }
        }

        Text {
            text: "Application Window properties"
            font.bold: true
        }

        CheckBox {
            text: "window active"
            checked: true
            Component.onCompleted: if (checked) updateActive()
            onCheckedChanged: updateActive()

            function updateActive() {
                WindowPropertiesHelper.setWindowPropertyGlobal(ApplicationWindowsConsts.isActiveProperty, checked)
            }
        }

        Component.onCompleted: {
            try {
                console.log("Looking for test bed extras")
                let code = 'import testbedextras; TestBedExtras{}';
                let newObject = Qt.createQmlObject(code,
                                                   content,
                                                   "testbedextras_TestBedExtras_qml");
            } catch (error) {
                console.log(error.toString())
            }
        }
    }

    Component.onCompleted: {
        showNormal()
    }

}
