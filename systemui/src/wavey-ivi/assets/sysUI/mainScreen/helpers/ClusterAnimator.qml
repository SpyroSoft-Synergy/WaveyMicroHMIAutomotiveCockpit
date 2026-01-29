import QtQuick

Item {
    id: root

    // From 0.0 to 1.0
    property real charge: 0
    readonly property int maxPower: 7000
    // From 0 to maxPower
    property int power: 0

    // From 0 to maxSpeed
    property int speed: 0

    SequentialAnimation {
        id: speedAnimation

        loops: Animation.Infinite
        running: true

        ParallelAnimation {
            id: speedingAnimation

            NumberAnimation {
                duration: 3000
                property: "charge"
                target: root
                to: 0.0
            }

            SequentialAnimation {
                NumberAnimation {
                    duration: 4500
                    easing.type: Easing.OutSine
                    property: "power"
                    target: root
                    to: 3000
                }

                NumberAnimation {
                    duration: 500
                    property: "power"
                    // 2nd gear
                    target: root
                    to: 2000
                }

                NumberAnimation {
                    duration: 4500
                    easing.type: Easing.OutSine
                    property: "power"
                    target: root
                    to: 4500
                }

                NumberAnimation {
                    duration: 500
                    property: "power"
                    // 3rd gear
                    target: root
                    to: 4100
                }

                NumberAnimation {
                    duration: 4500
                    easing.type: Easing.OutSine
                    property: "power"
                    target: root
                    to: 4800
                }

                NumberAnimation {
                    duration: 500
                    property: "power"
                    // 4th gear
                    target: root
                    to: 4200
                }

                NumberAnimation {
                    duration: 4500
                    easing.type: Easing.OutSine
                    property: "power"
                    target: root
                    to: 5000
                }

                NumberAnimation {
                    duration: 500
                    property: "power"
                    // 5th gear
                    target: root
                    to: 4800
                }

                NumberAnimation {
                    duration: 10000
                    easing.type: Easing.OutSine
                    property: "power"
                    target: root
                    to: 6500
                }
            }

            SequentialAnimation {
                NumberAnimation {
                    duration: 4500
                    property: "speed"
                    target: root
                    to: 30
                }

                NumberAnimation {
                    duration: 500
                    property: "speed"
                    // 2nd gear
                    target: root
                    to: 35
                }

                NumberAnimation {
                    duration: 4500
                    property: "speed"
                    target: root
                    to: 60
                }

                NumberAnimation {
                    duration: 500
                    property: "speed"
                    // 3rd gear
                    target: root
                    to: 65
                }

                NumberAnimation {
                    duration: 4500
                    property: "speed"
                    target: root
                    to: 90
                }

                NumberAnimation {
                    duration: 500
                    property: "speed"
                    // 4nd gear
                    target: root
                    to: 90
                }

                NumberAnimation {
                    duration: 4500
                    property: "speed"
                    target: root
                    to: 140
                }

                NumberAnimation {
                    duration: 500
                    property: "speed"
                    // 5nd gear
                    target: root
                    to: 145
                }

                NumberAnimation {
                    duration: 10000
                    property: "speed"
                    target: root
                    to: 200
                }
            }
        }

        ParallelAnimation {
            id: neutralAnimation

            SequentialAnimation {
                NumberAnimation {
                    duration: 10000 // 10s
                    property: "power"
                    target: root
                    to: 500
                }

                SequentialAnimation {
                    // idle animation
                    loops: 4

                    NumberAnimation {
                        duration: 2500
                        easing.type: Easing.OutInBounce
                        property: "power"
                        target: root
                        to: 800
                    }

                    NumberAnimation {
                        duration: 2500
                        easing.type: Easing.OutInBounce
                        property: "power"
                        target: root
                        to: 500
                    }
                }
            }

            NumberAnimation {
                duration: 30000
                property: "speed"
                target: root
                to: 60
            }

            NumberAnimation {
                duration: 30000
                property: "charge"
                target: root
                to: 0.8
            }
        }

        ParallelAnimation {
            id: slowSpeedAnimation

            NumberAnimation {
                duration: 5000
                property: "charge"
                target: root
                to: 0.0
            }

            SequentialAnimation {
                NumberAnimation {
                    duration: 4500
                    property: "power"
                    target: root
                    to: 2500
                }

                NumberAnimation {
                    duration: 500
                    property: "power"
                    // gear change
                    target: root
                    to: 2100
                }

                PauseAnimation {
                    duration: 5000
                }

                ParallelAnimation {
                    NumberAnimation {
                        duration: 10000
                        property: "charge"
                        target: root
                        to: 0.6
                    }

                    NumberAnimation {
                        duration: 10000
                        property: "power"
                        target: root
                        to: 500
                    }
                }
            }

            SequentialAnimation {
                NumberAnimation {
                    duration: 10000
                    property: "speed"
                    target: root
                    to: 100
                }

                NumberAnimation {
                    duration: 10000
                    property: "speed"
                    target: root
                    to: 0
                }
            }
        }
    }
}
