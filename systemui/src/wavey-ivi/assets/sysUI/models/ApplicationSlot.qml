import QtQuick
import QtApplicationManager.SystemUI
import wavey.windows

QtObject {
    id: root

    enum Mode {
        None,
        Close,
        Move
    }
    enum Size {
        Small,
        Medium,
        Large
    }

    property bool active: false
    property string appId: ""

    // Delayed closing to play full close animation
    readonly property Timer closeTimer: Timer {
        id: closeTimer

        interval: 1000
        repeat: false

        onTriggered: root.requestClose(root.appId)
    }
    property bool closed: false
    property bool inArrangeMode: false
    property int mode: ApplicationSlot.Mode.None
    property string name: ""
    property int size: ApplicationSlot.Size.Medium
    property WindowObject windowObject: null

    signal requestClose(string appId)

    function setActiveStatus() {
        if (root.windowObject != null) {
            windowObject.setWindowProperty(ApplicationWindowsConsts.isActiveProperty, active);
        }
    }

    function setInArrangeMode() {
        if (root.windowObject != null) {
            windowObject.setWindowProperty(ApplicationWindowsConsts.arrangeModeProperty, root.inArrangeMode);
        }
    }

    function startApplication() {
        if (appId !== "") {
            ApplicationManager.startApplication(appId);
        }
    }

    function stopApplication() {
        if (appId !== "") {
            ApplicationManager.stopApplication(appId);
        }
    }

    onActiveChanged: {
        setActiveStatus();
    }
    onClosedChanged: {
        if (closed) {
            closeTimer.start();
        }
    }
    onInArrangeModeChanged: {
        setInArrangeMode();
    }
    onWindowObjectChanged: {
        setActiveStatus();
        setInArrangeMode();
        if (windowObject) {
            windowObject.setWindowProperty(ApplicationWindowsConsts.iconSourceProperty, windowObject.application.icon);
        }
    }
}
