import QtQuick
import QtQml
import com.spyro_soft.wavey.sysuiipc

/** Object which detects multiple touch operations and
  * translates them into gestures objects.
  *
  * Detects such gesture:
  * - Tap - when finger is pressed and released without move in short time
  * - DoubleTap - when there are two taps in short time
  * - Scroll - Fingers are moved in one axis (vertical or horizontal). Send after each update of fingers positions on screen
  * - Swipe - Move in one direction with minimum swipe length in short time. Send only once during gesture.
  * - Drag - Movement of fingers after long press on screen in one place. Sent each update of fingers position.
  * - Pinch - Gesture with two fingers which moves in different directions, proportional change of distance is sent
  */
QtObject {
    id: root

    /* Currently gesture handled by GestureRecognizer, it is used by update function */
    property var currentHandledGesture: {
        "id": 0
    }
    readonly property Timer doubleTapTimer: Timer {
        id: doubleTapTimer

        interval: root.maxTimeForTap / 2
        running: false

        onTriggered: {
            if (root.lastTapData.tapsNumber !== 1 || root.currentHandledGesture.gestureKind !== Sysuiipc.Unknown) {
                return;
            }
            tapAndHoldTimer.stop();
            root.madeGesture(root.currentHandledGesture.id, Sysuiipc.Tap, Sysuiipc.None, root.lastTapData.fingerCount, Sysuiipc.gestureChangeValues());
            root.lastTapData.tapsNumber = 0;
            resetCurrentGesture();
        }
    }

    /* Data for last Tap gesture used to determine if new gesture is double tap */
    property var lastTapData: {
        "time": new Date(),
        "fingerCount": 0,
        "tapsNumber": 0
    }
    readonly property int maxTimeForDoubleTap: maxTimeForTap + 200 // [ms] maximum time between taps to be marked as double tap
    readonly property int maxTimeForTap: 300 // [ms] maximum time between press and release of finger to be marked as tap
    readonly property int maximumScrollVariation: 30 // [pixels] max difference during scroll between finger and initial gesture coordination on opposite axis
    readonly property int minimumLengthForSwipe: 100 // [pixels] minimum length of gesture to be marked as swipe type
    readonly property int minimumScrollLength: 40 // [pixels] minimum length of gesture to be marked as scroll type
    readonly property int minimumSwipeVelocity: 850
    readonly property int minimumTimeForTapAndHold: 1000 // [ms] minimum time between press and release to be marked as tap and hold
    readonly property Timer tapAndHoldTimer: Timer {
        id: tapAndHoldTimer

        interval: root.minimumTimeForTapAndHold
        running: false

        onTriggered: {
            if (root.currentHandledGesture.gestureKind !== Sysuiipc.Unknown) {
                return;
            }
            doubleTapTimer.stop();
            root.madeGesture(root.currentHandledGesture.id, Sysuiipc.TapAndHold, Sysuiipc.None, root.currentHandledGesture.fingerCount, Sysuiipc.gestureChangeValues());
            root.lastTapData.tapsNumber = 0;
        }
    }
    readonly property int thresholdAngle: 360 * 0.1 // [degrees] devation of angle which is acceptable for gesture to be in one axis
    readonly property int thresholdDistanceGestures: 30 // [pixels] max difference of gesture change coordinates between the same fingers gesture (for scroll)
    readonly property int timeBetweenScrollUpdates: 300

    /* Sends signal when one of handled gestures is executed, in arguments there are given:
       gesture kind from enum com.spyro_soft.wavey.Sysuiipc::GestureID, gesture direction from enum com.spyro_soft.wavey.Sysuiipc::GestureDirection,
       number of fingers executing gesture, Qt.vector2d with change of gesture coordinates between start and current position */
    signal madeGesture(int id, int gestureKind, int gestureDirection, int fingerCount, var changeValue)

    /* Changes touch points to objects with gesture data (Change of coordinates, direction.
       Return object {coordsChange:{x, y}, directions: GestureDirection} */
    function changeTouchPointsToSysUIIPC(touchPoints) {
        var gestures = [];
        for (const touchingPoint of touchPoints) {
            var singleGesture = {};
            singleGesture.coordsChange = Qt.vector2d(touchingPoint.x - touchingPoint.startX, touchingPoint.y - touchingPoint.startY);
            singleGesture.direction = getTouchDirection(singleGesture.coordsChange);
            gestures.push(singleGesture);
        }
        return gestures;
    }

    /* analyze touch event if it is a horizontal or vertical swipe */
    function getTouchDirection(gestureVector) {
        let swipeAngle = Math.atan2(gestureVector.y, gestureVector.x) * 180 / Math.PI;

        /* Check if swipe gesture is long enough to detect it as a gesture */
        if (swipeAngle >= 0 - thresholdAngle && swipeAngle <= 0 + thresholdAngle) {
            return Sysuiipc.Right;
        }
        if (swipeAngle >= 180 - thresholdAngle && swipeAngle <= 180) {
            return Sysuiipc.Left;
        }
        if (swipeAngle >= -180 && swipeAngle <= -180 + thresholdAngle) {
            return Sysuiipc.Left;
        }
        if (swipeAngle >= -90 - thresholdAngle && swipeAngle <= -90 + thresholdAngle) {
            return Sysuiipc.Top;
        }
        if (swipeAngle >= 90 - thresholdAngle && swipeAngle <= 90 + thresholdAngle) {
            return Sysuiipc.Bottom;
        }
        return Sysuiipc.None;
    }

    /* Checks if touch points in the list are the same gesture (similar x and y coordination value) */
    function ifSameGestures(gestures) {
        if (gestures.length >= 2) {
            var coordsChange = gestures[0].coordsChange;
            for (const nextFinger of gestures.slice(1)) {
                if (Math.abs(coordsChange.x - nextFinger.coordsChange.x) > thresholdDistanceGestures || Math.abs(coordsChange.y - nextFinger.coordsChange.y) > thresholdDistanceGestures) {
                    return false;
                }
            }
        }
        return true;
    }

    /* Check if scroll is ready to send updated version */
    function omitScrollUpdate(coordsChange) {
        // Not a scroll or not valid
        if (root.currentHandledGesture.gestureKind !== Sysuiipc.Scroll || !root.currentHandledGesture.isValid) {
            return false;
        }

        const currentTime = Date.now();
        const lastScrollUpdate = root.currentHandledGesture.lastScrollUpdate;

        if (currentTime - lastScrollUpdate >= root.timeBetweenScrollUpdates) {
            const changeVector = Qt.vector2d(coordsChange.x, coordsChange.y);
            const currentScrollLength = changeVector.length();
            const previousScrollLength = root.currentHandledGesture.lastChangeVectorLength;
            // check if we don't have to change the initialy detected direction
            // if we're moving in the same direction as previously
            // the steps shall increase and we shall revert the direction
            if (currentScrollLength < previousScrollLength) {
                root.currentHandledGesture.direction = oppositeDirection(root.currentHandledGesture.direction);
            }

            root.currentHandledGesture.lastChangeVectorLength = currentScrollLength;
            root.currentHandledGesture.lastScrollUpdate = currentTime;
            return false;
        }

        return true;
    }

    function oppositeDirection(direction) {
        switch (direction) {
        case Sysuiipc.Top:
            return Sysuiipc.Bottom;
        case Sysuiipc.Left:
            return Sysuiipc.Right;
        case Sysuiipc.Bottom:
            return Sysuiipc.Top;
        case Sysuiipc.Right:
            return Sysuiipc.Left;
        default:
            return Sysuiipc.None;
        }
    }

    /* Update of pressed points. As argument given all touchpoints, calculate begin distance used by pinch gesture */
    function pressedUpdate(handledTouchPoints) {
        if (doubleTapTimer.running) {
            doubleTapTimer.restart();
        }
        if (!tapAndHoldTimer.running) {
            tapAndHoldTimer.start();
        }

        resetCurrentGesture();
        var pressedFingers = handledTouchPoints.filter(touchPoint => touchPoint.pressed);
        root.currentHandledGesture.fingerCount = pressedFingers.length;
        // If there are two touch points save distance for possible pinch gesture
        if (pressedFingers.length === 2) {
            root.currentHandledGesture.initialFingerDistance = Math.hypot(pressedFingers[1].x - pressedFingers[0].x, pressedFingers[1].y - pressedFingers[0].y);
        }
    }

    /* Update of released points. As argument given all touchpoints. Function determines if gesture is Tap or Double Tap */
    function releaseUpdate(handledTouchPoints) {
        const handledGestures = [Sysuiipc.Drag, Sysuiipc.Swipe, Sysuiipc.Pinch];
        tapAndHoldTimer.stop();

        var pressedTouchPointsNum = handledTouchPoints.filter(touchPoint => touchPoint.pressed).length;
        if (pressedTouchPointsNum === 0 && handledGestures.includes(root.currentHandledGesture.gestureKind)) {
            root.currentHandledGesture.isValid = false;
            let valueToSend = Sysuiipc.gestureChangeValues();
            valueToSend.released = true;
            root.madeGesture(root.currentHandledGesture.id, root.currentHandledGesture.gestureKind, Sysuiipc.None, root.currentHandledGesture.fingerCount, valueToSend);
            return;
        }

        var currentTime = Date.now();
        var timeFromBegin = currentTime - root.currentHandledGesture.startTime;
        // Check if time between start and end is short enough for gesture to be a tap
        const gestureTimeDiff = currentTime - root.currentHandledGesture.startTime;
        if (pressedTouchPointsNum === 0 && gestureTimeDiff < maxTimeForTap && root.currentHandledGesture.gestureKind === Sysuiipc.Unknown) {
            // Check if tap is continuation of previous tap or it is new
            if ((currentTime - root.lastTapData.time) < maxTimeForDoubleTap && root.currentHandledGesture.fingerCount === root.lastTapData.fingerCount && root.lastTapData.tapsNumber === 1) {
                // When double tap, counter is reset and the next tap will be single
                root.lastTapData.tapsNumber = 0;
                doubleTapTimer.stop();
                root.madeGesture(root.currentHandledGesture.id, Sysuiipc.DoubleTap, Sysuiipc.None, root.lastTapData.fingerCount, Sysuiipc.gestureChangeValues());
            } else {
                root.lastTapData.tapsNumber = 1;
                root.lastTapData.fingerCount = root.currentHandledGesture.fingerCount;
                doubleTapTimer.restart();
            }
            root.lastTapData.time = currentTime;
            return;
        } else if (pressedTouchPointsNum === 0) {
            root.lastTapData.tapsNumber = 0;
        }
        root.currentHandledGesture.isValid = false; // Not handle anymore gesture, after releasing any touchpoint
    }

    /* Inserts initial data for each new started gesture */
    function resetCurrentGesture() {
        var previousId = currentHandledGesture.id;
        root.currentHandledGesture = {
            "id": previousId + 1,
            "isValid": true,
            "gestureKind": Sysuiipc.Unknown,
            "direction": Sysuiipc.None,
            "startTime": Date.now(),
            "initialFingerDistance": 0,
            "fingerCount": 0,
            "sent": false,
            "lastChangeVectorLength": 0,
            "lastScrollUpdate": Date.UTC(0, 0) // qmllint disable
        };
    }

    /* Update of touchpoints position. As argument given all active touchpoints. It sends gesture with determined type,
     * difference between initial and current gesture coordinates (or scale of distance between touch points).
     * Sends swipe if scroll gesture has minimum length in given time for swipe.
    */
    function touchUpdate(touchPoints) {
        if (!root.currentHandledGesture.isValid) {
            return;
        }
        var gestures = changeTouchPointsToSysUIIPC(touchPoints);
        var timeFromBegin = Date.now() - root.currentHandledGesture.startTime;
        var ifGesturesAreTheSame = ifSameGestures(gestures);
        if (root.currentHandledGesture.gestureKind === Sysuiipc.Unknown) {
            // The type of gesture is not determined yet, check if drag or scroll or pinch
            if (ifGesturesAreTheSame) {
                if (timeFromBegin > maxTimeForTap * 2 && gestures[0].coordsChange.length() > minimumScrollLength) {
                    root.currentHandledGesture.gestureKind = Sysuiipc.Drag;
                } else if (gestures[0].coordsChange.length() > minimumScrollLength) {
                    if (gestures[0].direction !== Sysuiipc.None) {
                        const maxVelocity = Math.max(...touchPoints.map(o => Math.max(Math.abs(o.velocity.x), Math.abs(o.velocity.y))));
                        root.currentHandledGesture.gestureKind = maxVelocity > root.minimumSwipeVelocity ? Sysuiipc.Swipe : Sysuiipc.Scroll;
                        root.currentHandledGesture.direction = gestures[0].direction;
                    } else {
                        // Gesture is not moving in one axis, the gesture is not handled
                        root.currentHandledGesture.isValid = false;
                    }
                }
            } else if (touchPoints.length === 2) {
                // If two touch points moves differently, then gesture is marked as pinch
                root.currentHandledGesture.gestureKind = Sysuiipc.Pinch;
            }
        }
        var valueToSend = Sysuiipc.gestureChangeValues();
        if (root.currentHandledGesture.gestureKind === Sysuiipc.Pinch) {
            // calculate the proportional difference between current and initial fingers distance
            if (touchPoints.length === 2) {
                var currentDistance = Math.hypot(touchPoints[1].x - touchPoints[0].x, touchPoints[1].y - touchPoints[0].y);
                valueToSend.scale = currentDistance / root.currentHandledGesture.initialFingerDistance;
            } else {
                return;
            }
        } else if (root.currentHandledGesture.gestureKind === Sysuiipc.Swipe && root.currentHandledGesture.sent) {
            // we've already sent swipe so we don't have to repeat ourselves
            return;
        } else {
            valueToSend.x = gestures[0].coordsChange.x;
            valueToSend.y = gestures[0].coordsChange.y;
        }
        root.currentHandledGesture.direction = gestures[0].direction;
        if (root.currentHandledGesture.isValid && root.currentHandledGesture.gestureKind !== Sysuiipc.Unknown && !omitScrollUpdate(valueToSend)) {
            root.currentHandledGesture.sent = true;
            root.madeGesture(root.currentHandledGesture.id, root.currentHandledGesture.gestureKind, root.currentHandledGesture.direction, touchPoints.length, valueToSend);
        }
    }
}
