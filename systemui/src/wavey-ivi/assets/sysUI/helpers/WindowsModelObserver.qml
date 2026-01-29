import QtQuick
import QtApplicationManager.SystemUI
import wavey.windows

QtObject {
    id: root

    readonly property QtObject internal: QtObject {
        id: internal

        readonly property Connections winManagerConnections: Connections {
            function onWindowAboutToBeRemoved(window) {
                window.windowProperty(ApplicationWindowsConsts.windowTypeProperty);
                if (window.windowProperty(ApplicationWindowsConsts.windowTypeProperty) === ApplicationWindowsConsts.clusterWindowType) {
                    root.clusterWindowAboutToBeRemoved(window);
                }
            }

            function onWindowAdded(window) {
                window.windowProperty(ApplicationWindowsConsts.windowTypeProperty);
                if (window.windowProperty(ApplicationWindowsConsts.windowTypeProperty) === ApplicationWindowsConsts.mainScreenWindowType || window.windowProperty(ApplicationWindowsConsts.windowTypeProperty) === ApplicationWindowsConsts.gestureScreenWindowType) {
                    root.appslotWindowAdded(window);
                } else if (window.windowProperty(ApplicationWindowsConsts.windowTypeProperty) === ApplicationWindowsConsts.clusterWindowType) {
                    root.clusterWindowAdded(window);
                }
            }

            target: WindowManager
        }
    }

    signal appslotWindowAdded(var window)
    signal clusterWindowAboutToBeRemoved(var window)
    signal clusterWindowAdded(var window)
}
