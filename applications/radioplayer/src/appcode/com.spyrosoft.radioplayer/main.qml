import QtQuick
import wavey.viewmodels

import radioplayer.windows

QtObject {
    id: root

    readonly property ApplicationRootViewModel viewModel: ApplicationRootViewModel {}

    readonly property Component mainScreenWindowComponent: Component {
        MainScreenWindow {
        }
    }

    readonly property Component gestureScreenWindowComponent: Component {
        GestureScreenWindow {
        }
    }

    readonly property Component clusterWindowComponent: Component {
        ClusterWindow {
        }
    }

    readonly property Loader mainScreenWindowLoader: Loader {
        active: root.viewModel.isMainScreen
        asynchronous: true
        sourceComponent: root.mainScreenWindowComponent
    }

    readonly property Loader gestureScreenWindowLoader: Loader {
        active: root.viewModel.isGestureScreen
        asynchronous: true
        sourceComponent: root.gestureScreenWindowComponent
    }

    readonly property Loader clusterWindowLoader: Loader {
        active: root.viewModel.isMainScreen
        asynchronous: true
        sourceComponent: root.clusterWindowComponent
    }

    readonly property Loader testBedLoader: Loader {
        active: true
        asynchronous: true
        source: typeof(testBedPath) !== "undefined" ? testBedPath : ""
    }
}
