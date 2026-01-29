import QtQuick
import QtApplicationManager.Application

QtObject {
    id: root
    enum GestureType {
        Unknown,
        Swipe,
        Drag,
        Tap,
        DoubleTap,
        Scroll,
        Pinch,
        TapAndHold
    }

    enum GestureDirection {
        None,
        Left,
        Top,
        Right,
        Bottom
    }

    property bool active: false

    property var onTap: null
    property var onScroll: null
    property var onDrag: null
    property var onDoubleTap: null
    property var onPinch: null
    property var onSwipe: null
    property var onPressAndHold: null

    readonly property QtObject d: QtObject {
        readonly property IntentHandler gesturesIntentHandler: IntentHandler{
            intentIds: ["handleGesture"]
            onRequestReceived: (request) => {
                let handled = false             
                if (active) {
                    const type = request.parameters["type"]
                    const fingerCount = request.parameters["fingerCount"]
                    const direction = request.parameters["direction"]
                    const valueChange = request.parameters["valueChange"]
                    switch(type) {
                        case GesturesListener.GestureType.Swipe: {
                            if (root.onSwipe) {
                                handled = root.onSwipe(fingerCount, direction)
                            }
                        }
                        break;
                        case GesturesListener.GestureType.Drag: {
                            if (root.onDrag) {
                                handled = root.onDrag(fingerCount, direction, {x: valueChange.x, y: valueChange.y, released: valueChange.released})
                            }
                        }
                        break;
                        case GesturesListener.GestureType.Tap: {
                            if (root.onTap) {
                                handled = root.onTap(fingerCount)
                            }
                        }
                        break;
                        case GesturesListener.GestureType.DoubleTap: {
                            if (root.onDoubleTap) {
                                handled = root.onDoubleTap(fingerCount)
                            }
                        }
                        break;
                        case GesturesListener.GestureType.Scroll: {
                            if (root.onScroll) {
                                handled = root.onScroll(fingerCount, direction)
                            }
                        }
                        break; 
                        case GesturesListener.GestureType.Pinch: {
                            if (root.onPinch) {
                                handled = root.onPinch(fingerCount, { scale: valueChange.scale, released: valueChange.released })
                            }
                        }
                        break;
                        case GesturesListener.GestureType.TapAndHold: {
                            if (root.onPressAndHold) {
                                handled = root.onPressAndHold(fingerCount)
                            }
                        }
                        break
                        default:
                        break
                    }
                }
                if (handled) {
                    request.sendReply({})
                } else {
                    request.sendErrorReply(active ? "Not handled" : "Not active!")
                }                    
            }
        }
    }
}
