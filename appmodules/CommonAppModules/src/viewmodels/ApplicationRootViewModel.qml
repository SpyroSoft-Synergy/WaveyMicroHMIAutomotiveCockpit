import QtQuick
import QtApplicationManager.Application

QtObject {
    readonly property bool isGestureScreen: ApplicationInterface.systemProperties["isGestureScreen"]
    readonly property bool isMainScreen: ApplicationInterface.systemProperties["isMainScreen"]
    property bool active: false
}
