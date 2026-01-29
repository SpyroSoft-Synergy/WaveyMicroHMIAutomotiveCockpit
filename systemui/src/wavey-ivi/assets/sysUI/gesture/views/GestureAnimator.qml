import QtQuick

import com.spyro_soft.wavey.sysuiipc

Item {
    id: root

    readonly property alias points: internal.points
    readonly property bool running: internal.currentAnimation && internal.currentAnimation.running
    readonly property alias velocities: internal.velocities

    readonly property int dragPrePauseMs: 310
    readonly property int interTapPauseMs: 150
    readonly property int scrollDurationMs: 1000
    readonly property int swipeDragMoveDurationMs: 600
    readonly property int tapAndHoldDurationMs: 750
    readonly property int tapPauseMs: 250
    readonly property int zoomPrePauseMs: 200
    readonly property int zoomDurationMs: 1000

    function prepare1Point() {
        internal.points = Qt.binding(function () {
            return [internal.point0];
        });
        internal.velocities = Qt.binding(function () {
            return [internal.velocity0];
        });
    }

    function prepare2Points() {
        internal.points = Qt.binding(function () {
            return [internal.point0, internal.point1];
        });
        internal.velocities = Qt.binding(function () {
            return [internal.velocity0, internal.velocity1];
        });
    }

    function prepare3Points() {
        internal.points = Qt.binding(function () {
            return [internal.point0, internal.point1, internal.point2];
        });
        internal.velocities = Qt.binding(function () {
            return [internal.velocity0, internal.velocity1, internal.velocity2];
        });
    }

    function resetPoints() {
        internal.points = Qt.binding(function () {
            return [];
        });
        internal.velocities = Qt.binding(function () {
            return [];
        });
    }

    function run(animId) {
        console.log("Run gesture animation:", Sysuiipc.gestureAnimationToString(animId));
        if (internal.currentAnimation) {
            internal.currentAnimation.stop();
        }
        internal.currentAnimation = null;

        switch (animId) {
        // TAP
        case Sysuiipc.DoubleTap1:
            internal.currentAnimation = doubleTap1;
            break;
        case Sysuiipc.DoubleTap2:
            internal.currentAnimation = doubleTap2;
            break;
        case Sysuiipc.TapAndHold1:
            internal.currentAnimation = tapAndHold1;
            break;
        // SWIPE
        case Sysuiipc.Swipe1Right:
            internal.currentAnimation = swipe1Right;
            break;
        case Sysuiipc.Swipe2Up:
            internal.currentAnimation = swipe2Up;
            break;
        case Sysuiipc.Swipe2Down:
            internal.currentAnimation = swipe2Down;
            break;
        case Sysuiipc.Swipe3Up:
            internal.currentAnimation = swipe3Up;
            break;
        case Sysuiipc.Swipe3Down:
            internal.currentAnimation = swipe3Down;
            break;
        // SCROLL
        case Sysuiipc.Scroll1Right:
            internal.currentAnimation = scroll1Right;
            break;
        case Sysuiipc.Scroll1Top:
            internal.currentAnimation = scroll1Top;
            break;
        case Sysuiipc.Scroll1Down:
            internal.currentAnimation = scroll1Down;
            break;
        case Sysuiipc.Scroll2Right:
            internal.currentAnimation = scroll2Right;
            break;
        case Sysuiipc.Scroll2Left:
            internal.currentAnimation = scroll2Left;
            break;
        // DRAG
        case Sysuiipc.Drag2Up:
            internal.currentAnimation = drag2Up;
            break;
        case Sysuiipc.Drag2Down:
            internal.currentAnimation = drag2Down;
            break;
        case Sysuiipc.Drag3Up:
            internal.currentAnimation = drag3Up;
            break;
        case Sysuiipc.Drag3Down:
            internal.currentAnimation = drag3Down;
            break;
        // ZOOM
        case Sysuiipc.ZoomOut:
            internal.currentAnimation = zoomOut;
            break;
        default:
            console.error("Gesture animation is not handled:", Sysuiipc.gestureAnimationToString(animId), ",animationId:", animId);
            return;
        }

        if (internal.currentAnimation) {
            internal.currentAnimation.restart();
        }
    }

    readonly property QtObject internal: QtObject {
        id: internal

        property Animation currentAnimation: null
        property vector2d velocity0
        property vector2d velocity1
        property vector2d velocity2
        property point point0
        property point point1
        property point point2
        property list<point> points
        property list<vector2d> velocities
    }

    SequentialAnimation {
        id: doubleTap1

        ScriptAction {
            script: {
                internal.velocity0 = Qt.vector2d(0, 0);
                prepare1Point();
                internal.point0 = Qt.point(400, 500);
            }
        }

        PauseAnimation {
            duration: tapPauseMs
        }

        ScriptAction {
            script: {
                resetPoints();
            }
        }

        PauseAnimation {
            duration: interTapPauseMs
        }

        ScriptAction {
            script: {
                prepare1Point();
                internal.point0 = Qt.point(425, 525);
            }
        }

        PauseAnimation {
            duration: tapPauseMs
        }

        ScriptAction {
            script: resetPoints()
        }
    }

    SequentialAnimation {
        id: doubleTap2

        ScriptAction {
            script: {
                internal.velocity0 = Qt.vector2d(0, 0);
                internal.velocity1 = Qt.vector2d(0, 0);
                prepare2Points();
                internal.point0 = Qt.point(400, 500);
                internal.point1 = Qt.point(600, 500);
            }
        }

        PauseAnimation {
            duration: tapPauseMs
        }

        ScriptAction {
            script: {
                resetPoints();
            }
        }

        PauseAnimation {
            duration: interTapPauseMs
        }

        ScriptAction {
            script: {
                prepare2Points();
                internal.point0 = Qt.point(425, 525);
                internal.point1 = Qt.point(625, 525);
            }
        }

        PauseAnimation {
            duration: tapPauseMs
        }

        ScriptAction {
            script: resetPoints()
        }
    }

    SequentialAnimation {
        id: tapAndHold1

        ScriptAction {
            script: {
                internal.velocity0 = Qt.vector2d(0, 0);
                prepare1Point();
                internal.point0 = Qt.point(600, 500);
            }
        }

        PauseAnimation {
            duration: tapAndHoldDurationMs
        }

        ScriptAction {
            script: {
                resetPoints();
            }
        }
    }

    SequentialAnimation {
        id: swipe1Right

        ScriptAction {
            script: {
                internal.velocity0 = Qt.vector2d(3.5, 0);
                prepare1Point();
            }
        }

        PropertyAnimation {
            duration: swipeDragMoveDurationMs
            from: Qt.point(400, 500)
            property: "point0"
            target: internal
            to: Qt.point(600, 500)
        }

        ScriptAction {
            script: resetPoints()
        }
    }

    SequentialAnimation {
        id: swipe2Up

        ScriptAction {
            script: {
                internal.velocity0 = Qt.vector2d(0, -3.5);
                internal.velocity1 = Qt.vector2d(0, -3.5);
                prepare2Points();
            }
        }

        ParallelAnimation {
            PropertyAnimation {
                duration: swipeDragMoveDurationMs
                from: Qt.point(465, 900)
                property: "point0"
                target: internal
                to: Qt.point(465, 300)
            }

            PropertyAnimation {
                duration: swipeDragMoveDurationMs
                from: Qt.point(615, 900)
                property: "point1"
                target: internal
                to: Qt.point(615, 300)
            }
        }

        ScriptAction {
            script: resetPoints()
        }
    }

    SequentialAnimation {
        id: swipe2Down

        ScriptAction {
            script: {
                internal.velocity0 = Qt.vector2d(0, 3.5);
                internal.velocity1 = Qt.vector2d(0, 3.5);
                prepare2Points();
            }
        }

        ParallelAnimation {
            PropertyAnimation {
                duration: swipeDragMoveDurationMs
                from: Qt.point(465, 300)
                property: "point0"
                target: internal
                to: Qt.point(465, 900)
            }

            PropertyAnimation {
                duration: swipeDragMoveDurationMs
                from: Qt.point(615, 300)
                property: "point1"
                target: internal
                to: Qt.point(615, 900)
            }
        }

        ScriptAction {
            script: resetPoints()
        }
    }

    SequentialAnimation {
        id: swipe3Up

        ScriptAction {
            script: {
                internal.velocity0 = Qt.vector2d(0, -3.5);
                internal.velocity1 = Qt.vector2d(0, -3.5);
                internal.velocity2 = Qt.vector2d(0, -3.5);
                prepare3Points();
            }
        }

        ParallelAnimation {
            PropertyAnimation {
                duration: swipeDragMoveDurationMs
                from: Qt.point(390, 900)
                property: "point0"
                target: internal
                to: Qt.point(390, 300)
            }

            PropertyAnimation {
                duration: swipeDragMoveDurationMs
                from: Qt.point(540, 900)
                property: "point1"
                target: internal
                to: Qt.point(540, 300)
            }

            PropertyAnimation {
                duration: swipeDragMoveDurationMs
                from: Qt.point(690, 900)
                property: "point2"
                target: internal
                to: Qt.point(690, 300)
            }
        }

        ScriptAction {
            script: resetPoints()
        }
    }

    SequentialAnimation {
        id: swipe3Down

        ScriptAction {
            script: {
                internal.velocity0 = Qt.vector2d(0, 3.5);
                internal.velocity1 = Qt.vector2d(0, 3.5);
                internal.velocity2 = Qt.vector2d(0, 3.5);
                prepare3Points();
            }
        }

        ParallelAnimation {
            PropertyAnimation {
                duration: swipeDragMoveDurationMs
                from: Qt.point(390, 300)
                property: "point0"
                target: internal
                to: Qt.point(390, 900)
            }

            PropertyAnimation {
                duration: swipeDragMoveDurationMs
                from: Qt.point(540, 300)
                property: "point1"
                target: internal
                to: Qt.point(540, 900)
            }

            PropertyAnimation {
                duration: swipeDragMoveDurationMs
                from: Qt.point(690, 300)
                property: "point2"
                target: internal
                to: Qt.point(690, 900)
            }
        }

        ScriptAction {
            script: resetPoints()
        }
    }

    SequentialAnimation {
        id: zoomOut

        ScriptAction {
            script: {
                internal.velocity0 = Qt.vector2d(0, -3.5);
                internal.velocity1 = Qt.vector2d(0, 3.5);
                prepare2Points();
                internal.point0 = Qt.point(500, 500);
                internal.point1 = Qt.point(500, 700);
            }
        }

        PauseAnimation {
            duration: zoomPrePauseMs
        }

        ParallelAnimation {
            PropertyAnimation {
                duration: zoomDurationMs
                property: "point0"
                target: internal
                to: Qt.point(500, 300)
            }

            PropertyAnimation {
                duration: zoomDurationMs
                property: "point1"
                target: internal
                to: Qt.point(500, 900)
            }
        }

        ScriptAction {
            script: resetPoints()
        }
    }

    SequentialAnimation {
        id: drag2Up

        ScriptAction {
            script: {
                internal.velocity0 = Qt.vector2d(0, -3.5);
                internal.velocity1 = Qt.vector2d(0, -3.5);
                prepare2Points();
                internal.point0 = Qt.point(390, 900);
                internal.point1 = Qt.point(540, 900);
            }
        }

        PauseAnimation {
            duration: dragPrePauseMs
        }

        ParallelAnimation {
            PropertyAnimation {
                duration: swipeDragMoveDurationMs
                property: "point0"
                target: internal
                to: Qt.point(390, 600)
            }

            PropertyAnimation {
                duration: swipeDragMoveDurationMs
                property: "point1"
                target: internal
                to: Qt.point(540, 600)
            }
        }

        PauseAnimation {
            duration: interTapPauseMs
        }

        ScriptAction {
            script: resetPoints()
        }
    }

    SequentialAnimation {
        id: drag2Down

        ScriptAction {
            script: {
                internal.velocity0 = Qt.vector2d(0, 3.5);
                internal.velocity1 = Qt.vector2d(0, 3.5);
                prepare2Points();
                internal.point0 = Qt.point(390, 500);
                internal.point1 = Qt.point(540, 500);
            }
        }

        PauseAnimation {
            duration: dragPrePauseMs
        }

        ParallelAnimation {
            PropertyAnimation {
                duration: swipeDragMoveDurationMs
                property: "point0"
                target: internal
                to: Qt.point(390, 800)
            }

            PropertyAnimation {
                duration: swipeDragMoveDurationMs
                property: "point1"
                target: internal
                to: Qt.point(540, 800)
            }
        }

        PauseAnimation {
            duration: interTapPauseMs
        }

        ScriptAction {
            script: resetPoints()
        }
    }

    SequentialAnimation {
        id: drag3Up

        ScriptAction {
            script: {
                internal.velocity0 = Qt.vector2d(0, -3.5);
                internal.velocity1 = Qt.vector2d(0, -3.5);
                internal.velocity2 = Qt.vector2d(0, -3.5);
                prepare3Points();
                internal.point0 = Qt.point(390, 900);
                internal.point1 = Qt.point(540, 900);
                internal.point2 = Qt.point(690, 900);
            }
        }

        PauseAnimation {
            duration: dragPrePauseMs
        }

        ParallelAnimation {
            PropertyAnimation {
                duration: swipeDragMoveDurationMs
                property: "point0"
                target: internal
                to: Qt.point(390, 600)
            }

            PropertyAnimation {
                duration: swipeDragMoveDurationMs
                property: "point1"
                target: internal
                to: Qt.point(540, 600)
            }

            PropertyAnimation {
                duration: swipeDragMoveDurationMs
                property: "point2"
                target: internal
                to: Qt.point(690, 600)
            }
        }

        PauseAnimation {
            duration: interTapPauseMs
        }

        ScriptAction {
            script: resetPoints()
        }
    }

    SequentialAnimation {
        id: drag3Down

        ScriptAction {
            script: {
                internal.velocity0 = Qt.vector2d(0, 3.5);
                internal.velocity1 = Qt.vector2d(0, 3.5);
                internal.velocity2 = Qt.vector2d(0, 3.5);
                prepare3Points();
                internal.point0 = Qt.point(390, 300);
                internal.point1 = Qt.point(540, 300);
                internal.point2 = Qt.point(690, 300);
            }
        }

        PauseAnimation {
            duration: dragPrePauseMs
        }

        ParallelAnimation {
            PropertyAnimation {
                duration: swipeDragMoveDurationMs
                property: "point0"
                target: internal
                to: Qt.point(390, 600)
            }

            PropertyAnimation {
                duration: swipeDragMoveDurationMs
                property: "point1"
                target: internal
                to: Qt.point(540, 600)
            }

            PropertyAnimation {
                duration: swipeDragMoveDurationMs
                property: "point2"
                target: internal
                to: Qt.point(690, 600)
            }
        }

        PauseAnimation {
            duration: interTapPauseMs
        }

        ScriptAction {
            script: resetPoints()
        }
    }

    SequentialAnimation {
        id: scroll1Right

        ScriptAction {
            script: {
                internal.velocity0 = Qt.vector2d(3.5, 0);
                prepare1Point();
            }
        }

        PropertyAnimation {
            duration: scrollDurationMs
            from: Qt.point(400, 600)
            property: "point0"
            target: internal
            to: Qt.point(700, 600)
        }

        ScriptAction {
            script: resetPoints()
        }
    }

    SequentialAnimation {
        id: scroll1Top

        ScriptAction {
            script: {
                internal.velocity0 = Qt.vector2d(0, -3.5);
                prepare1Point();
            }
        }

        PropertyAnimation {
            duration: scrollDurationMs
            from: Qt.point(600, 700)
            property: "point0"
            target: internal
            to: Qt.point(600, 400)
        }

        ScriptAction {
            script: resetPoints()
        }
    }

    SequentialAnimation {
        id: scroll1Down

        ScriptAction {
            script: {
                internal.velocity0 = Qt.vector2d(0, 3.5);
                prepare1Point();
            }
        }

        PropertyAnimation {
            duration: scrollDurationMs
            from: Qt.point(600, 500)
            property: "point0"
            target: internal
            to: Qt.point(600, 800)
        }

        ScriptAction {
            script: resetPoints()
        }
    }

    SequentialAnimation {
        id: scroll2Left

        ScriptAction {
            script: {
                internal.velocity0 = Qt.vector2d(-3.5, 0);
                internal.velocity1 = Qt.vector2d(-3.5, 0);
                prepare2Points();
            }
        }

        ParallelAnimation {
            PropertyAnimation {
                duration: scrollDurationMs
                from: Qt.point(700, 500)
                property: "point0"
                target: internal
                to: Qt.point(500, 500)
            }

            PropertyAnimation {
                duration: scrollDurationMs
                from: Qt.point(700, 700)
                property: "point1"
                target: internal
                to: Qt.point(500, 700)
            }
        }

        ScriptAction {
            script: resetPoints()
        }
    }

    SequentialAnimation {
        id: scroll2Right

        ScriptAction {
            script: {
                internal.velocity0 = Qt.vector2d(3.5, 0);
                internal.velocity1 = Qt.vector2d(3.5, 0);
                prepare2Points();
            }
        }

        ParallelAnimation {
            PropertyAnimation {
                duration: scrollDurationMs
                from: Qt.point(400, 500)
                property: "point0"
                target: internal
                to: Qt.point(600, 500)
            }

            PropertyAnimation {
                duration: scrollDurationMs
                from: Qt.point(400, 700)
                property: "point1"
                target: internal
                to: Qt.point(600, 700)
            }
        }

        ScriptAction {
            script: resetPoints()
        }
    }
}
