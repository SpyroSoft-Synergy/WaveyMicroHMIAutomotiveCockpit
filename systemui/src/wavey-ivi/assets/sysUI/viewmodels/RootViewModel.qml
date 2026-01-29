import QtQuick
import QtApplicationManager.SystemUI 2.0
import helpers
import models

QtObject {
    id: root

    readonly property ApplicationSlotsModel apps: ApplicationSlotsModel {
        id: appSlots

    }
    readonly property bool developmentMode: ApplicationManager.systemProperties.developmentMode // qmllint disable

    // linter detects as map, when systemProperties is var type
    readonly property bool isGestureScreen: ApplicationManager.systemProperties.isGestureScreen // qmllint disable
    readonly property int screenHeight: ApplicationManager.systemProperties.screenHeight // qmllint disable
    readonly property int screenWidth: ApplicationManager.systemProperties.screenWidth // qmllint disable
    readonly property WindowsModelObserver windowsModelObserver: WindowsModelObserver {
        onAppslotWindowAdded: window => appSlots.onWindowAdded(window)
    }
}
