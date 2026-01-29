pragma Singleton
import QtQuick
import QtApplicationManager 2.0

QtObject {
    id: root
    signal requestIssued(IntentClientRequest request)

    readonly property Component requestComponent : Component {
        id: requestComponent
        IntentClientRequest {}
    }

    function makeGestureRequest(gestureType, fingerCount, gestureDirection, xChange, yChange, scaleChange, released = false) {
        let requestInstance = requestComponent.createObject(root, {intentId: "handleGesture", parameters: {type: gestureType, fingerCount: fingerCount, direction:  gestureDirection, valueChange: { x: xChange, y: yChange, scale: scaleChange, released: released }}})
        root.requestIssued(requestInstance)
    }
}
