import QtQuick
import TestBed.helpers

Window {
    id: window
    signal windowPropertyChanged(string name, var value)

    readonly property QtObject d: QtObject {
        id: d
        
        property var windowProperties: ({})

        readonly property Connections  propertiesHelperConnections: Connections {
            target: WindowPropertiesHelper
            function onWindowPropertyChanged(windowInstance, name, value) {
                if (windowInstance === window || windowInstance === null) {
                    d.windowProperties[name] = value
                    window.windowPropertyChanged(name, value)
                }
            }    
        }
    }

    function windowProperties() {
        return d.windowProperties
    }

    function windowProperty(name) {
        if (d.windowProperties.hasOwnProperty(name)) {
            return d.windowProperties[name]
        }
        return undefined
    }

    function setWindowProperty(name, value) {
        WindowPropertiesHelper.setWindowProperty(window, name, value)
    }

    Component.onCompleted: {
        color = "black"
        show()
    }

}
