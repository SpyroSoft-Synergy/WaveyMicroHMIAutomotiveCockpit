import QtQuick
import QtApplicationManager.Application

WaveyWindowBase {
    id: root

    width: 500
    height: 500

    Component.onCompleted: {
        setWindowProperty(ApplicationWindowsConsts.windowTypeProperty, ApplicationWindowsConsts.clusterWindowType)
    }
}