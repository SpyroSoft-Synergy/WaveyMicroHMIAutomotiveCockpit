import QtQuick
import wavey.viewmodels
import weather.windows

QtObject {
    id: root

    readonly property Component clusterWindowComponent: Component {
        ClusterWindow {
        }
    }
    readonly property Loader clusterWindowLoader: Loader {
        active: root.viewModel.isMainScreen
        asynchronous: true
        sourceComponent: root.clusterWindowComponent
    }
    readonly property Component gestureScreenWindowComponent: Component {
        GestureScreenWindow {
        }
    }
    readonly property Loader gestureScreenWindowLoader: Loader {
        active: root.viewModel.isGestureScreen
        asynchronous: true
        sourceComponent: root.gestureScreenWindowComponent
    }
    readonly property Component mainScreenWindowComponent: Component {
        MainScreenWindow {
        }
    }
    readonly property Loader mainScreenWindowLoader: Loader {
        active: root.viewModel.isMainScreen
        asynchronous: true
        sourceComponent: root.mainScreenWindowComponent
    }
    readonly property Loader testBedLoader: Loader {
        active: true
        asynchronous: true
        source: typeof (testBedPath) !== "undefined" ? testBedPath : ""
    }
    readonly property ApplicationRootViewModel viewModel: ApplicationRootViewModel {
    }
}
