import QtQuick

Item {
    id: root

    property alias color: first.color
    property alias font: first.font
    property real value: 0.

    height: row.height
    width: row.width

    readonly property QtObject internal: QtObject {
        id: internal

        property real precision: 0.5
        property real rounded: Math.round(root.value / precision) * precision
    }

    Row {
        id: row

        RotaryDigit {
            id: first

            value: Math.trunc(internal.rounded * 0.1)
        }

        RotaryDigit {
            anchors.baseline: first.baseline
            color: first.color
            font: first.font
            value: Math.trunc(internal.rounded)
        }

        Text {
            id: dot

            anchors.baseline: first.baseline
            color: first.color
            font.family: first.font.family
            font.letterSpacing: 4
            font.pixelSize: first.font.pixelSize / 2.
            font.weight: first.font.weight
            text: "."
        }

        RotaryDigit {
            anchors.baseline: dot.baseline
            color: dot.color
            font: dot.font
            model: [0, 5]
            value: internal.rounded / internal.precision
        }
    }
}
