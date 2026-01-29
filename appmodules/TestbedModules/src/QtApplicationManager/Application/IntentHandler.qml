import QtQml
import QtApplicationManager
import TestBed.helpers

QtObject {
    id: root
    property list<string> intentIds
    readonly property QtObject d: QtObject {
        readonly property Connections intentServerConn: Connections {
            target: IntentsServerHelper
            function onRequestIssued(request) {
                 if (intentIds.includes(request.intentId)) {
                    root.requestReceived(request)
                 }
            }
        }
    }

    signal requestReceived(IntentClientRequest request)

}
