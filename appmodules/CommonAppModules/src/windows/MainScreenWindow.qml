import QtQuick
import QtApplicationManager.Application

import wavey.style

WaveyWindowBase {
    id: root

    default property alias content: contentItem.data

    width: 1840
    height: 660

    Component.onCompleted: {
        setWindowProperty(ApplicationWindowsConsts.windowTypeProperty, ApplicationWindowsConsts.mainScreenWindowType)
    }

    RoundedItem {
        id: contentItem
        anchors.fill: parent
        radius: 20
    }

    Rectangle {
        anchors.fill: contentItem
        color: "transparent"
        border.color: WaveyStyle.accentColor
        border.width: 3
        opacity: root.isActive ? 1.0 : 0.3
        radius: 20
        layer.enabled: true
        layer.smooth: true
        layer.effect: AppSlotBorderEffect { }

        Behavior on opacity {
            NumberAnimation { duration: 300 }
        }
    }
}
