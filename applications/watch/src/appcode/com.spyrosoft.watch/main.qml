import QtQuick
import wavey.viewmodels

import watch.windows

QtObject {
    id: root

    readonly property ApplicationRootViewModel viewModel: ApplicationRootViewModel {}

    readonly property Component mainScreenWindowComponent: Component {
        MainScreenWindow {
            // This shouldn't be required... did something change in Qt 6.4?
            Component.onCompleted: {
                showNormal()
            }
        }
    }

    readonly property Component gestureScreenWindowComponent: Component {
        GestureScreenWindow {
            // This shouldn't be required... did something change in Qt 6.4?
            Component.onCompleted: {
                showNormal()
            }
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

    readonly property Loader testBedLoader: Loader {
        active: true
        asynchronous: true
        source: typeof(testBedPath) !== "undefined" ? testBedPath : ""

    }

}
