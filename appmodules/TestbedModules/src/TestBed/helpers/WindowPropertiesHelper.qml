pragma Singleton
import QtQuick

QtObject {
    id: root

    signal windowPropertyChanged(var window, string name, var value)

    function setWindowProperty(window, name, value) {
        root.windowPropertyChanged(window, name,value)
    }

    function setWindowPropertyGlobal(name, value) {
        root.windowPropertyChanged(null, name,value)
    }
}
