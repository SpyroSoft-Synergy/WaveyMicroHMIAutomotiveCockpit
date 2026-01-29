import QtQuick
import navigation.windows
import wavey.viewmodels

QtObject {
    id: root

    readonly property ApplicationRootViewModel
    viewModel: ApplicationRootViewModel {
    }

    readonly property Component
    mainScreenWindowComponent: Component {
        MainScreenWindow {
        }

    }

    readonly property Component
    gestureScreenWindowComponent: Component {
        GestureScreenWindow {
        }

    }

    readonly property Component
    clusterWindowComponent: Component {
        ClusterWindow {
        }

    }

    readonly property Loader
    mainScreenWindowLoader: Loader {
        active: root.viewModel.isMainScreen
        asynchronous: true
        sourceComponent: root.mainScreenWindowComponent
    }

    readonly property Loader
    gestureScreenWindowLoader: Loader {
        active: root.viewModel.isGestureScreen
        asynchronous: true
        sourceComponent: root.gestureScreenWindowComponent
    }

    readonly property Loader
    clusterWindowLoader: Loader {
        active: root.viewModel.isMainScreen
        asynchronous: true
        sourceComponent: root.clusterWindowComponent
    }

    readonly property Item
    testBed: Item {
    }

    Component.onCompleted: {
        try {
            console.log("Trying to create testbed window");
            let code = 'import TestBed; TestBedWindow{width: 450; height: 400}';
            let testBedWindow = Qt.createQmlObject(code, testBed, "testbed_TestBedWindow_qml");
        } catch (error) {
            console.log(error.toString());
        }
    }
}
