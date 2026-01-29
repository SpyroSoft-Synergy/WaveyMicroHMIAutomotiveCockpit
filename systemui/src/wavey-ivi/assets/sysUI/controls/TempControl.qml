import QtQuick
import wavey.style

Item {
    id: root

    property bool active: touchIndicator.containsMouse
    property string fontFamily: WaveyFonts.numbers.family // qmllint disable
    property alias label: label.text
    property bool on: false
    property alias value: counter.value

    height: status.y + status.height
    width: shader.width

    onValueChanged: value = Math.min(Math.max(value, 60.0), 86.0)

    readonly property QtObject internal: QtObject {
        id: internal

        readonly property string baseAssetPath: "controlsUI/"
        readonly property string themeAssetPath: baseAssetPath + WaveyStyle.currentThemeName.toLowerCase() + "/"
    }

    Image {
        id: bars

        fillMode: Image.Tile
        layer.enabled: true
        layer.smooth: true
        layer.wrapMode: ShaderEffectSource.Repeat
        source: internal.baseAssetPath + "temp_bars.png"
        visible: false
    }

    ShaderEffect {
        id: shader

        property variant bars: bars
        property real barsOffset: 0
        property real colorState: upButton.pressed ? 1. : downButton.pressed ? -1. : 0.
        property variant downGradient: Image {
            source: internal.themeAssetPath + "temp_gradient_down.png"
        }
        property variant gradient: Image {
            source: internal.themeAssetPath + "temp_gradient.png"
        }
        property variant mask: Image {
            source: internal.baseAssetPath + "temp_mask.png"
        }
        property variant upGradient: Image {
            source: internal.themeAssetPath + "temp_gradient_up.png"
        }

        fragmentShader: "qrc:/assets/sysUI/shaderEffects/tempSlider.frag.qsb"
        height: 1200
        width: 105

        Behavior on barsOffset {
            SmoothedAnimation {
                duration: 600
                velocity: -1
            }
        }
        Behavior on colorState {
            PropertyAnimation {
                duration: 100
            }
        }

        DragHandler {
            id: dragHandler

            property real pressValue: 0

            signal dragEnd
            signal dragStart
            signal dragUpdate(x: real, y: real)

            dragThreshold: 25
            target: null
            xAxis.enabled: false

            onCentroidChanged: {
                if (active) {
                    dragUpdate(this.centroid.position.x - this.centroid.pressPosition.x, this.centroid.position.y - this.centroid.pressPosition.y);
                }
            }
            onGrabChanged: function (transition, point) {
                switch (transition) {
                case PointerDevice.GrabPassive:
                    dragStart();
                    break;
                case PointerDevice.UngrabPassive:
                    dragEnd();
                    break;
                }
            }
        }

        Connections {
            property real dragStartOffsetValue: 0

            function onDragStart() {
                dragStartOffsetValue = shader.barsOffset;
            }

            function onDragUpdate(x, y) {
                shader.barsOffset = dragStartOffsetValue - (y / shader.height);
            }

            target: dragHandler
        }
    }

    MouseArea {
        id: touchIndicator

        anchors.fill: parent
        hoverEnabled: true
    }

    MouseArea {
        id: upButton

        anchors.top: shader.top
        height: shader.height / 2.
        width: shader.width

        onClicked: root.value += 0.5
    }

    MouseArea {
        id: downButton

        anchors.bottom: shader.bottom
        height: shader.height / 2.
        width: shader.width

        onClicked: root.value -= 0.5
    }

    Item {
        id: status

        anchors.horizontalCenter: shader.horizontalCenter
        anchors.top: shader.bottom
        anchors.topMargin: 40
        height: 91
        width: 98

        RotaryCounter {
            id: counter

            color: WaveyStyle.primaryColor // qmllint disable
            font: WaveyFonts.rotary_counter // qmllint disable
        }

        Image {
            id: link

            anchors.right: parent.right
            anchors.top: parent.top
            anchors.topMargin: 6
            opacity: root.on ? 1.0 : 0.2
            source: String("controlsUI/%1/temp_link.png").arg(WaveyStyle.currentThemeName.toLowerCase())
        }

        Text {
            id: label

            anchors.baseline: parent.bottom
            anchors.baselineOffset: -5
            anchors.horizontalCenter: parent.horizontalCenter
            color: WaveyStyle.primaryColor // qmllint disable
            font: WaveyFonts.text_3 // qmllint disable
        }
    }

    Connections {
        property real dragStartValue: 0

        function onDragStart() {
            dragStartValue = root.value;
        }

        function onDragUpdate(x, y) {
            let ticks = Math.trunc(y / (-55.));
            root.value = ticks * 0.5 + dragStartValue;
        }

        target: dragHandler
    }
}
