import QtQuick
import helpers
import wavey.style
import wavey.ui
import com.spyro_soft.wavey.sysuiipc

RootViewModel {
    id: root

    readonly property QtObject internal: QtObject {
        id: internal

        readonly property AppStyle appStyle: AppStyle {
            onThemeChanged: theme => WaveyStyle.setAppTheme(theme)
        }
        readonly property FakeGestureViewModel fakeGestures: FakeGestureViewModel {
            gestureDetector: gestureDetector
        }
        readonly property GestureDetector gestureDetector: GestureDetector {
            id: gestureDetector

            onGestureAnimationDetected: (gestureId, animationId) => {
                root.lastGesture = qsTr("gesture animation id %1 detected, animation:%2").arg(gestureId).arg(animationId);
                root.playGestureAnimation(gestureId, animationId);
            }
            onGestureDetected: (gestureId, gestureType, gestureDirection, fingerCount, valueChange) => {
                root.lastGesture = qsTr("gesture id %1 detected, type:%2 direction:%3 fingerCount:%4 position:%5;%6 scale:%7").arg(gestureId).arg(Sysuiipc.gestureTypeToString(gestureType)).arg(Sysuiipc.gestureDirectionToString(gestureDirection)).arg(fingerCount).arg(valueChange.x).arg(valueChange.y).arg(valueChange.scale);
            }
            onGestureReleased: gestureId => {
                root.lastGesture += qsTr(" , released");
            }
            onGestureUpdated: (gestureId, gestureType, gestureDirection, fingerCount, valueChange) => {
                root.lastGesture = qsTr("gesture id %1 detected, type:%2 direction:%3 fingerCount:%4 position:%5;%6 scale:%7").arg(gestureId).arg(Sysuiipc.gestureTypeToString(gestureType)).arg(Sysuiipc.gestureDirectionToString(gestureDirection)).arg(fingerCount).arg(valueChange.x).arg(valueChange.y).arg(valueChange.scale);
            }
        }
        readonly property GestureRecognizer gestureRecognizer: GestureRecognizer {
            id: gestureRecognizer

            onMadeGesture: (id, gestureKind, gestureDirection, fingerCount, changeValue) => {
                gestureDetector.propagateGesture(id, gestureKind, gestureDirection, (root.developmentMode ? root.fingerCount : fingerCount), changeValue);
            }
        }
        readonly property Connections pressListenerConnections: Connections {
            function onPressed() {
                gestureDetector.propagateTouchAction(true);
            }

            function onReleased() {
                gestureDetector.propagateTouchAction(false);
            }

            target: PressListener // qmllint disable
        }
    }
    property int fingerCount
    property string lastGesture

    signal playGestureAnimation(int gestureId, int animationId)

    function beginFakePinch(value) {
        internal.fakeGestures.beginFakePinch(value);
    }

    function changeTheme(theme) {
        internal.appStyle.propagateThemeChange(theme);
    }

    function endFakePinch() {
        internal.fakeGestures.endFakePinch();
    }

    function pressedUpdate(touchPoints) {
        gestureRecognizer.pressedUpdate(touchPoints);
    }

    function releaseUpdate(touchPoints) {
        gestureRecognizer.releaseUpdate(touchPoints);
    }

    function requestGesture(gestureType, gestureDirection) {
        // Only for dev mode
        if (!root.developmentMode) {
            return;
        }
        internal.fakeGestures.requestGesture(gestureType, gestureDirection, root.fingerCount);
    }

    function touchUpdate(touchPoints) {
        gestureRecognizer.touchUpdate(touchPoints);
    }

    function updateFakePinch(value) {
        internal.fakeGestures.updateFakePinch(value);
    }
}
