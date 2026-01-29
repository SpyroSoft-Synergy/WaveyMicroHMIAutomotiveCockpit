import QtQuick
import helpers
import com.spyro_soft.wavey.sysuiipc

QtObject {
    id: root

    required property GestureDetector gestureDetector
    property int fakeGestureId: 100000

    function beginFakePinch(value) {
        root.fakeGestureId += 1;
        root.updateFakePinch(value);
    }

    function endFakePinch() {
        gestureDetector.propagateGesture(root.fakeGestureId, Sysuiipc.Pinch, Sysuiipc.None, 2, Sysuiipc.gestureChangeValues(0, 0, 0, true));
    }

    function updateFakePinch(value) {
        gestureDetector.propagateGesture(root.fakeGestureId, Sysuiipc.Pinch, Sysuiipc.None, 2, Sysuiipc.gestureChangeValues(0, 0, value, false));
    }

    function requestGesture(gestureType, gestureDirection, fingerCount) {
        gestureDetector.propagateGesture(++root.fakeGestureId, gestureType, gestureDirection, fingerCount, Sysuiipc.gestureChangeValues());
    }
}
