import QtQuick
import QtTest
import com.spyro_soft.wavey.sysuiipc
import gesture.views
import helpers

Item {
    id: root

    property var gesturesReceived: []

    height: 1920
    width: 1080

    GestureRecognizer {
        id: gestureRecognizerObj
    }
    SignalSpy {
        id: touchAreaPressed
        signalName: "pressed"
        target: touchArea
    }
    SignalSpy {
        id: touchAreaUpdated
        signalName: "updated"
        target: touchArea
    }
    SignalSpy {
        id: touchAreaReleased
        signalName: "released"
        target: touchArea
    }
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

        onPressed: gestureRecognizerObj.pressedUpdate([touchPoint0, touchPoint1, touchPoint2])
        onReleased: gestureRecognizerObj.releaseUpdate([touchPoint0, touchPoint1, touchPoint2])
        onUpdated: activeTouchPoints => {
            return gestureRecognizerObj.touchUpdate(activeTouchPoints);
        }
    }
    Connections {
        function onMadeGesture(gestureId, gestureType, gestureDirection, fingerCount, valueChange) {
            root.gesturesReceived.push({
                    "gestureId": gestureId,
                    "gestureType": gestureType,
                    "gestureDirection": gestureDirection,
                    "fingerCount": fingerCount,
                    "valueChange": valueChange
                });
        }

        target: gestureRecognizerObj
    }
    TestCase {
        property var sequence
        property int startX: 500
        property int startY: 1000

        function cleanup() {
            root.gesturesReceived.splice(0);
        }
        function init() {
            touchAreaPressed.clear();
            touchAreaUpdated.clear();
            touchAreaReleased.clear();
            sequence = touchEvent(touchArea);
        }
        function test_horizontal_scroll() {
            sequence.press(0, touchArea, startX, startY).commit();
            wait(100);
            sequence.move(0, touchArea, startX + 50, startY + 5).commit();
            wait(250);
            sequence.move(0, touchArea, startX + 100, startY).commit();
            wait(250);
            sequence.move(0, touchArea, startX + 150, startY).commit();
            wait(250);
            sequence.move(0, touchArea, startX + 150, startY).commit();
            wait(250);
            compare(root.gesturesReceived.length, 2, "Should receive gesture");
            var lastGesture = root.gesturesReceived[root.gesturesReceived.length - 1];
            compare(Sysuiipc.gestureTypeToString(lastGesture.gestureType), Sysuiipc.gestureTypeToString(Sysuiipc.Scroll), "Wrong gesture type");
            compare(Sysuiipc.gestureDirectionToString(lastGesture.gestureDirection), Sysuiipc.gestureDirectionToString(Sysuiipc.Right), "Wrong Gesture Direction");
            compare(lastGesture.fingerCount, 1, "Wrong Finger Count");
            compare(lastGesture.valueChange.x, 150, "Wrong scroll data");
            wait(50);
            sequence.move(0, touchArea, startX + 150, startY - 5).commit();
            sequence.release(0).commit();
            wait(150);
            verify(root.gesturesReceived.length >= 2, "Should receive new gestures");
            lastGesture = root.gesturesReceived[root.gesturesReceived.length - 1];
            compare(lastGesture.gestureType, Sysuiipc.Scroll, "Wrong gesture");
            compare(Sysuiipc.gestureDirectionToString(lastGesture.gestureDirection), Sysuiipc.gestureDirectionToString(Sysuiipc.Right), "Wrong direction");
            compare(lastGesture.fingerCount, 1, "Wrong finger count");
            compare(lastGesture.valueChange.x, 150, "Wrong value change");
            verify(root.gesturesReceived[0].gestureId === root.gesturesReceived[1].gestureId);
        }
        function test_multiple_finger_swipe() {
            sequence.press(0, touchArea, startX, startY);
            sequence.press(1, touchArea, startX, startY + 50);
            sequence.commit();
            touchAreaPressed.wait();
            sequence.move(0, touchArea, touchPoint0.x + 90, startY + 1);
            sequence.move(1, touchArea, touchPoint1.x + 90, startY + 50);
            sequence.commit();
            touchAreaUpdated.wait();
            wait(50);
            sequence.move(0, touchArea, touchPoint0.x + 90, startY);
            sequence.move(1, touchArea, touchPoint1.x + 92, startY + 50);
            sequence.commit();
            touchAreaUpdated.wait();
            wait(50);
            sequence.move(0, touchArea, startX + 180, startY + 1);
            sequence.move(1, touchArea, startX + 179, startY + 50);
            sequence.commit();
            touchAreaUpdated.wait();
            wait(1);
            sequence.move(0, touchArea, startX + 269, startY - 5);
            sequence.move(1, touchArea, startX + 272, startY + 50);
            sequence.commit();
            touchAreaUpdated.wait();
            sequence.release(0);
            sequence.release(1);
            sequence.commit();
            compare(root.gesturesReceived.length, 2, "Should receive gesture");
            const swipeGesture = root.gesturesReceived[0];
            compare(swipeGesture.gestureType, Sysuiipc.Swipe, "Not received Swipe gesture");
            compare(swipeGesture.valueChange.released, false, "Swipe gesture cannot be released until release");
            verify(swipeGesture.gestureDirection === Sysuiipc.Right && swipeGesture.fingerCount === 2, "Wrong Swipe data");
            const swipeReleaseGesture = root.gesturesReceived[1];
            compare(swipeReleaseGesture.gestureType, Sysuiipc.Swipe, "Not received Swipe release gesture");
            compare(swipeReleaseGesture.valueChange.released, true, "Swipe gesture should be released");
        }
        function test_pinch() {
            sequence.press(0, touchArea, startX, startY);
            sequence.press(1, touchArea, startX, startY + 50);
            sequence.commit();
            wait(50);
            sequence.move(0, touchArea, startX, startY - 25);
            sequence.move(1, touchArea, startX, startY + 75);
            sequence.commit();
            wait(50);
            sequence.move(0, touchArea, startX, startY - 50);
            sequence.move(1, touchArea, startX, startY + 100);
            sequence.commit();
            sequence.release(0);
            sequence.release(1);
            sequence.commit();
            verify(root.gesturesReceived.length >= 3, "Should receive gesture");
            var pressGesture = root.gesturesReceived[root.gesturesReceived.length - 2];
            verify(pressGesture.gestureType === Sysuiipc.Pinch, "Not received Pinch gesture");
            verify(pressGesture.valueChange.scale === 3 && pressGesture.fingerCount === 2, "Wrong Pinch data");
            var releaseGesture = root.gesturesReceived[root.gesturesReceived.length - 1];
            verify(releaseGesture.gestureType === Sysuiipc.Pinch, "Not received release Pinch gesture");
            verify(releaseGesture.valueChange.released === true, "Wrong Pinch data");
        }
        function test_swipe() {
            sequence.press(0, touchArea, startX, startY).commit();
            touchAreaPressed.wait();
            wait(50);
            sequence.move(0, touchArea, startX, startY + 100).commit();
            touchAreaUpdated.wait();
            wait(50);
            sequence.move(0, touchArea, startX + 5, startY + 190).commit();
            touchAreaUpdated.wait();
            wait(50);
            sequence.move(0, touchArea, startX + 5, startY + 270).commit();
            wait(50);
            touchAreaUpdated.wait();
            sequence.release(0).commit();
            compare(root.gesturesReceived.length, 2, "Should receive gesture");
            const swipeGesture = root.gesturesReceived[0];
            compare(swipeGesture.gestureType, Sysuiipc.Swipe, "Not received Swipe gesture");
            compare(swipeGesture.valueChange.released, false, "Swipe gesture cannot be released until release");
            verify(swipeGesture.gestureDirection === Sysuiipc.Bottom && swipeGesture.fingerCount === 1, "Wrong Swipe data");
            const swipeReleaseGesture = root.gesturesReceived[1];
            compare(swipeReleaseGesture.gestureType, Sysuiipc.Swipe, "Not received Swipe release gesture");
            compare(swipeReleaseGesture.valueChange.released, true, "Swipe gesture should be released");
        }
        function test_tap() {
            wait(50);
            sequence.press(0, touchArea, startX, startY).commit();
            touchAreaPressed.wait();
            sequence.release(0).commit();
            touchAreaReleased.wait();
            wait(160);
            compare(root.gesturesReceived.length, 1, "Should receive one gesture");
            compare(root.gesturesReceived[0].gestureType, Sysuiipc.Tap, "No received tap gesture");
            sequence.press(0, touchArea, startX + 10, startY).commit();
            sequence.release(0).commit();
            wait(20);
            sequence.press(0, touchArea, startX + 10, startY).commit();
            sequence.release(0).commit();
            compare(root.gesturesReceived.length, 2, "Should receive two gestures");
            verify(root.gesturesReceived[1].gestureType === Sysuiipc.DoubleTap, "No received double tap gesture");
            sequence.press(0, touchArea, startX, startY - 10).commit();
            sequence.release(0).commit();
            wait(160);
            verify(root.gesturesReceived.length === 3, "Should receive three gestures");
            verify(root.gesturesReceived[2].gestureType === Sysuiipc.Tap, "Tap is send again");
            sequence.press(0, touchArea, startX + 10, startY).commit();
            wait(1050);
            sequence.release(0).commit();
            compare(root.gesturesReceived.length, 4, "Should receive four gestures");
            verify(root.gesturesReceived[3].gestureType === Sysuiipc.TapAndHold, "Tap and Hold");
        }
        function test_vertical_scroll() {
            var start = Date.now();
            sequence.press(1, touchArea, startX, startY).commit();
            wait(50);
            sequence.move(1, touchArea, touchPoint0.x - 2, touchPoint0.y + 20).commit();
            wait(260);
            sequence.move(1, touchArea, touchPoint0.x + 2, touchPoint0.y + 20).commit();
            wait(150);
            sequence.move(1, touchArea, touchPoint0.x - 2, touchPoint0.y + 20).commit();
            wait(350);
            sequence.move(1, touchArea, touchPoint0.x + 2, touchPoint0.y + 50).commit();
            wait(100);
            compare(root.gesturesReceived.length, 2, "Should receive gesture");
            var lastGesture = root.gesturesReceived[root.gesturesReceived.length - 1];
            compare(Sysuiipc.gestureTypeToString(lastGesture.gestureType), Sysuiipc.gestureTypeToString(Sysuiipc.Scroll), "Wrong gesture type");
            compare(Sysuiipc.gestureDirectionToString(lastGesture.gestureDirection), Sysuiipc.gestureDirectionToString(Sysuiipc.Bottom), "Wrong Gesture Direction");
            compare(lastGesture.fingerCount, 1, "Wrong Finger Count");
            compare(lastGesture.valueChange.y, 110, "Wrong Bottom scroll data");
            wait(350);
            sequence.move(1, touchArea, startX - 2, startY + 60).commit();
            sequence.release(1).commit();
            wait(50);
            compare(root.gesturesReceived.length, 3, "Should receive new gestures");
            compare(root.gesturesReceived[0].gestureId, lastGesture.gestureId, "Wrong gesture ID");
            lastGesture = root.gesturesReceived[root.gesturesReceived.length - 1];
            compare(Sysuiipc.gestureTypeToString(lastGesture.gestureType), Sysuiipc.gestureTypeToString(Sysuiipc.Scroll), "Wrong gesture type");
            compare(lastGesture.valueChange.y, 60, "Wrong Bottom scroll data");
            compare(Sysuiipc.gestureDirectionToString(lastGesture.gestureDirection), Sysuiipc.gestureDirectionToString(Sysuiipc.Top), "Wrong Gesture Direction");
            compare(lastGesture.fingerCount, 1, "Wrong Finger Count");
        }

        name: "GestureRecognizerTests"
        when: windowShown
    }
}
