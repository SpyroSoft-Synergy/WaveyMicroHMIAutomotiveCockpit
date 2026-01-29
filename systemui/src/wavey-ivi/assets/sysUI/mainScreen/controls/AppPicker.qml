import QtQuick
import QtQuick.Controls
import Qt5Compat.GraphicalEffects
import shaderEffects
import wavey.style

Item {
    id: root

    property int appCount: 0
    property real arrangeScale: 1
    property alias availableApps: view.model
    property int currentIndex: 0
    property bool isShown: true

    function goDown() {
        view.decrementCurrentIndex();
        view.currentIndex = root.currentIndex;
    }

    function goUp() {
        view.incrementCurrentIndex();
        view.currentIndex = root.currentIndex;
    }

    height: parent.height * 1.2
    state: isShown ? "shown" : "hidden"
    width: parent.width

    states: [
        State {
            name: "hidden"

            PropertyChanges {
                opacity: 0
                target: root
            }
        },
        State {
            name: "shown"

            PropertyChanges {
                opacity: 1
                target: root
            }
        }
    ]
    transitions: Transition {
        from: "*"
        to: "*"

        NumberAnimation {
            duration: 100
            easing.type: Easing.InOutQuad
            properties: "opacity"
        }
    }

    onIsShownChanged: {
        view.currentIndex = root.currentIndex;
    }

    Component {
        id: delegate

        Item {
            id: delegateItem

            readonly property bool isCurrent: view.currentIndex === index
            readonly property int radius: 40

            height: width * 0.76
            scale: PathView.iconScale
            visible: modelData.id !== "null"
            width: root.width * 0.75
            z: PathView.iconOrder

            Rectangle {
                anchors.fill: parent
                color: WaveyStyle.cardBackgroundColor
                radius: parent.radius

                Rectangle {
                    anchors.fill: parent
                    radius: parent.radius

                    gradient: Gradient {
                        GradientStop {
                            color: {
                                const col = Qt.color(WaveyStyle.accentColor);
                                return Qt.rgba(col.r, col.g, col.b, 0.0);
                            }
                            position: 0.2
                        }

                        GradientStop {
                            color: {
                                const col = Qt.color(WaveyStyle.accentColor);
                                return Qt.rgba(col.r, col.g, col.b, 0.15);
                            }
                            position: 1.0
                        }
                    }
                }
            }

            Rectangle {
                anchors.fill: parent
                border.width: 2
                color: "transparent"
                layer.enabled: true
                layer.smooth: true
                opacity: delegateItem.isCurrent ? 1 : 0.1
                radius: parent.radius

                layer.effect: AppSlotBorderEffect {
                }
                Behavior on opacity {
                    NumberAnimation {
                    }
                }
            }

            Column {
                id: column

                anchors.centerIn: parent
                spacing: 10
                width: parent.width

                Item {
                    anchors.horizontalCenter: column.horizontalCenter
                    height: ic.height
                    width: ic.width

                    Image {
                        id: ic

                        height: width
                        smooth: true
                        source: modelData.icon
                        sourceSize.height: 96
                        sourceSize.width: 96
                        visible: false
                        width: 48 / root.arrangeScale
                    }

                    ColorOverlay {
                        anchors.fill: ic
                        color: appName.color
                        source: ic

                        Behavior on color {
                            ColorAnimation {
                            }
                        }
                    }
                }

                Text {
                    id: appName

                    anchors.horizontalCenter: column.horizontalCenter
                    color: delegateItem.isCurrent ? WaveyStyle.secondaryColor : WaveyStyle.accentColor
                    text: modelData.label

                    Behavior on color {
                        ColorAnimation {
                        }
                    }

                    font {
                        family: WaveyFonts.h7.family
                        pixelSize: WaveyFonts.h7.pixelSize / root.arrangeScale
                        weight: WaveyFonts.h7.weight
                    }
                }
            }
        }
    }

    PathView {
        id: view

        anchors.fill: parent
        delegate: delegate
        focus: true
        highlightRangeMode: PathView.StrictlyEnforceRange
        pathItemCount: 3
        preferredHighlightBegin: 0.5
        preferredHighlightEnd: 0.5

        path: Path {
            startX: view.width / 2
            startY: 0

            PathAttribute {
                name: "iconScale"
                value: 0.85
            }

            PathAttribute {
                name: "iconOrder"
                value: 0
            }

            PathLine {
                x: view.width / 2
                y: view.height / 2
            }

            PathAttribute {
                name: "iconScale"
                value: 1
            }

            PathAttribute {
                name: "iconOrder"
                value: 8
            }

            PathLine {
                x: view.width / 2
                y: view.height
            }

            PathAttribute {
                name: "iconScale"
                value: 0.85
            }

            PathAttribute {
                name: "iconOrder"
                value: 0
            }
        }
    }

    Column {
        spacing: 8

        anchors {
            right: view.right
            rightMargin: 25
            verticalCenter: view.verticalCenter
        }

        Repeater {
            model: root.appCount

            delegate: Rectangle {
                readonly property bool isCurrent: index === view.currentIndex

                color: isCurrent ? WaveyStyle.secondaryColor : WaveyStyle.accentColor
                height: width
                opacity: isCurrent ? 1 : 0.3
                radius: width / 2
                width: 8
            }
        }
    }
}
