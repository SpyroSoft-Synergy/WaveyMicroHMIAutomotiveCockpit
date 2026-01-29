import QtQuick
import QtQuick.Controls

Row {
    id: root

    signal beginPinch(real value)
    signal endPinch
    signal fingerCountChanged(int fingerCount)
    signal updatePinch(real value)

    spacing: 20

    Component.onCompleted: {
        root.fingerCountChanged(1);
    }

    ComboBox {
        id: fingersCountBox

        font.pixelSize: 50
        height: 100
        model: [1, 2, 3]

        onActivated: index => {
            root.fingerCountChanged(index + 1);
        }
    }

    Slider {
        id: scaleChange

        anchors.verticalCenter: parent.verticalCenter
        from: 0
        stepSize: 0.1
        to: 10
        value: 1
        width: 300

        onPressedChanged: {
            if (scaleChange.pressed) {
                root.beginPinch(scaleChange.value);
            } else {
                root.endPinch();
            }
        }
        onValueChanged: {
            if (scaleChange.pressed) {
                root.updatePinch(scaleChange.value);
            }
        }
    }

    Button {
        anchors.verticalCenter: parent.verticalCenter
        text: "Reset"

        onClicked: {
            fingersCountBox.currentIndex = 0;
            scaleChange.value = 1;
        }
    }
}
