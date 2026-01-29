import QtQuick
import QtApplicationManager.Application

ApplicationManagerWindow {
    id: root
    color: "transparent"

    property bool isActive: !!windowProperty[ApplicationWindowsConsts.isActiveProperty]

    onWindowPropertyChanged: (name, value) => {
         if (name === ApplicationWindowsConsts.isActiveProperty) {
             root.isActive = value
         }
     }

    // This shouldn't be required... did something changed in Qt 6.4?
    Component.onCompleted: {
        showNormal()
    }
}