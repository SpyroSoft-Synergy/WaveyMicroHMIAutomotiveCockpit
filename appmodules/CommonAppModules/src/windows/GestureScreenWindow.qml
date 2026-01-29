import QtQuick
import QtApplicationManager.Application

WaveyWindowBase {
    id: root

    width: 1080
    height: 480

    Component.onCompleted: {
        setWindowProperty(ApplicationWindowsConsts.windowTypeProperty, ApplicationWindowsConsts.gestureScreenWindowType)
    }
}