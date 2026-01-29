import QtQuick
import wavey.style

Column {
    property int humidity: parent.humidity

    function calculateHeight() {
        return Math.round(Math.random() * (parent.height - 10) + 10);
    }

    anchors.fill: parent
    spacing: 0

    Rectangle {
        id: margin
        color: WaveyStyle.backgroundColor
        height: parent.height - bar.height
        width: parent.width
    }

    Rectangle {
        id: bar
        function getColor() {
            if (parent.humidity < 20) {
                return "#1afff1";
            } else if (parent.humidity < 40) {
                return "#32EDF9";
            } else if (parent.humidity < 60) {
                return "#32D5F9";
            } else if (parent.humidity < 80) {
                return "#32BDF9";
            } else if (parent.humidity <= 100) {
                return "#32B1F9";
            }
        }

        color: getColor()
        height: 0
        radius: 5
        width: parent.width

        NumberAnimation on height  {
            id: animation
            duration: 1000
            running: false

            Component.onCompleted: {
                animation.to = calculateHeight();
                animation.start();
            }
        }

        Timer {
            interval: 2500
            repeat: true
            running: true

            onTriggered: {
                animation.to = calculateHeight();
                animation.start();
            }
        }

        Item {
            id: stripes

            property int stripe_gap: 4
            property int stripe_length: stripe_width + stripe_gap
            property int stripe_width: 4

            Repeater {
                model: Math.ceil(bar.height / stripes.stripe_length)

                Rectangle {
                    required property int index

                    function calculateHeightMath() {
                        const side = Math.min(bar.width, y);
                        return Math.sqrt(2 * Math.pow(side, 2)) + 5;
                    }

                    color: WaveyStyle.backgroundColor
                    height: calculateHeightMath()
                    width: stripes.stripe_width
                    y: bar.height - index * stripes.stripe_length

                    transform: Rotation {
                        angle: 225
                    }
                }
            }

            Repeater {
                model: Math.ceil(bar.width / stripes.stripe_length)

                Rectangle {
                    required property int index

                    function calculateHeightMath() {
                        const side = Math.min(bar.height, bar.width - x);
                        return Math.sqrt(2 * Math.pow(side, 2)) + 5;
                    }

                    color: WaveyStyle.backgroundColor
                    height: calculateHeightMath()
                    width: stripes.stripe_width
                    x: bar.width - index * stripes.stripe_length
                    y: bar.height + 5

                    transform: Rotation {
                        angle: 225
                        origin.y: parent.height / 2
                    }
                }
            }
        }
    }
}
