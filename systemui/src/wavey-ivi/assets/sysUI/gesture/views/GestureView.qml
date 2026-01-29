import QtQuick 2.15
import controls
import viewmodels
import com.spyro_soft.wavey.sysuiipc
import helpers
import wavey.style

Item {
    id: root

    readonly property bool pressed: liquidEffect.points.length > 0
    property GestureViewModel viewModel

    readonly property QtObject internal: QtObject {
        id: internal

        property list<point> points
        property list<vector2d> velocities
    }

    Connections {
        function onPlayGestureAnimation(gestureId, animationId) {
            gestureAnimator.run(animationId);
        }

        target: viewModel
    }

    LiquidEffect {
        id: liquidEffect

        anchors.fill: parent
        color: points.length > 1 ? points.length > 2 ? WaveyStyle.sliderGradientColor : WaveyStyle.accentColor : WaveyStyle.primaryColor
        points: gestureAnimator.running ? gestureAnimator.points : internal.points
        velocities: gestureAnimator.running ? gestureAnimator.velocities : internal.velocities
    }

    GestureAnimator {
        id: gestureAnimator

    }

    Rectangle {
        id: gestureArea

        anchors.fill: parent
        color: "transparent"

        MultiPointTouchArea {
            id: touchArea

            anchors.fill: parent

            touchPoints: [
                TouchPoint {
                    id: touchPoint0

                },
                TouchPoint {
                    id: touchPoint1

                },
                TouchPoint {
                    id: touchPoint2

                }
            ]

            onPressed: () => {
                root.viewModel.pressedUpdate([touchPoint0, touchPoint1, touchPoint2]);
            }
            onReleased: () => {
                root.viewModel.releaseUpdate([touchPoint0, touchPoint1, touchPoint2]);
            }
            onTouchUpdated: touchPoints => {
                var newPoints = [];
                var newVelocities = [];
                for (let i = 0; i < touchPoints.length; i++) {
                    newPoints.push(Qt.point(touchPoints[i].x, touchPoints[i].y));
                    newVelocities.push(Qt.vector2d(touchPoints[i].x - touchPoints[i].previousX, touchPoints[i].y - touchPoints[i].previousY));
                }
                internal.points = newPoints;
                internal.velocities = newVelocities;
            }
            onUpdated: activeTouchPoints => {
                root.viewModel.touchUpdate(activeTouchPoints);
            }
        }
    }

    Loader {
        active: root.viewModel.developmentMode
        anchors.fill: parent
        sourceComponent: gestureMenu

        Component {
            id: gestureMenu

            GesturesEmulationMenu {
                onRequestGesture: (type, direction) => root.viewModel.requestGesture(type, direction)
                onRunAnimation: animationId => gestureAnimator.run(animationId)
            }
        }
    }
}
