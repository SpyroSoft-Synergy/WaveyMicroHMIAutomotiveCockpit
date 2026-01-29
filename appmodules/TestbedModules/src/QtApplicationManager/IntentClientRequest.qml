import QtQml

QtObject {

    enum Direction {
        ToSystem,
        ToApplication
    }

    readonly property string requestId: ""
    readonly property int direction: IntentClientRequest.Direction.ToApplication
    readonly property string intentId: ""
    readonly property string applicationId: ""
    readonly property string requestingApplicationId: ""
    readonly property var parameters: {}
    readonly property bool succeeded: false
    readonly property string errorMessage: ""
    readonly property var result: {}

    function sendErrorReply(errorMessage) {}

    function sendReply(result) {}
}
