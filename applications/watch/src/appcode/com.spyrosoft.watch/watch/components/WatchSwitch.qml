import wavey.style
import QtQuick
import QtQuick.Shapes
import QtQuick.Controls

Item {
    id: root

    signal leftClicked
    signal rightClicked

    property int selectedItem

    required property int radius
    required property string leftText
    required property string rightText

    Row {
        anchors.centerIn: parent
        spacing: 0

        Shape {
            width: root.width / 2
            height: root.height

            ShapePath {
                id: leftShape
                strokeWidth: 2
                strokeColor: WaveyStyle.primaryColor
                capStyle: ShapePath.RoundCap
                fillColor: "transparent"

                startX: root.radius / 2
                startY: 0
                PathLine {
                    x: root.width / 2
                    y: 0
                }
                PathLine {
                    x: root.width / 2
                    y: root.height
                }
                PathLine {
                    x: root.radius / 2
                    y: root.height
                }
                PathArc {
                    x: root.radius / 2
                    y: 0
                    radiusX: root.radius / 2
                    radiusY: root.radius / 2
                }
            }
            Label {
                text: root.leftText
                color: WaveyStyle.primaryColor
                anchors.centerIn: parent

                font {
                    family: WaveyFonts.h4.family
                    pixelSize: 38
                    weight: WaveyFonts.h4.weight
                }
            }

            MouseArea {
                anchors.fill: parent
                onClicked: {
                    root.state = "leftClicked"
                    root.leftClicked()
                }
            }
        }

        Shape {
            width: root.width / 2
            height: root.height

            ShapePath {
                id: rightShape
                strokeWidth: 2
                strokeColor: WaveyStyle.primaryColor
                capStyle: ShapePath.RoundCap
                fillColor: "transparent"

                startX: 0
                startY: 0
                PathLine {
                    x: root.width / 2 - root.radius / 2
                    y: 0
                }
                PathArc {
                    x: root.width / 2 - root.radius / 2
                    y: root.height
                    radiusX: root.radius / 2
                    radiusY: root.radius / 2
                }
                PathLine {
                    x: 0
                    y: root.height
                }
                PathLine {
                    x: 0
                    y: 0
                }
            }
            Label {
                text: root.rightText
                color: WaveyStyle.primaryColor
                anchors.centerIn: parent

                font {
                    family: WaveyFonts.h4.family
                    pixelSize: 38
                    weight: WaveyFonts.h4.weight
                }
            }
            MouseArea {
                anchors.fill: parent
                onClicked: {
                    root.state = "rightClicked"
                    root.rightClicked()
                }
            }
        }
    }

    states: [
        State {
            name: "leftClicked"
            when: root.selectedItem == 0

            PropertyChanges {
                target: leftShape
                fillColor: "#331AF3FF"
            }
            PropertyChanges {
                target: rightShape
                fillColor: "transparent"
            }
        },
        State {
            name: "rightClicked"
            when: root.selectedItem == 1

            PropertyChanges {
                target: rightShape
                fillColor: "#331AF3FF"
            }
            PropertyChanges {
                target: leftShape
                fillColor: "transparent"
            }
        }
    ]
}
