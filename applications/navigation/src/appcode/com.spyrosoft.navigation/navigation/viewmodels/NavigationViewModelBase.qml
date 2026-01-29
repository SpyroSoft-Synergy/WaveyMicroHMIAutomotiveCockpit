import QtQml
import QtQuick
import com.spyro_soft.wavey.navigation_iface
import wavey.gestures
import wavey.viewmodels

ApplicationRootViewModel {
    id: root

    readonly property alias zoomLevel: navigation.zoomLevel
    readonly property alias currentRoute: navigation.currentRoute
    readonly property alias directions: navigation.directions
    readonly property alias position: navigation.position
    readonly property alias rotation: navigation.rotation
    readonly property QtObject
    d: QtObject {
        id: d

        readonly property Navigation
        navigation: Navigation {
            id: navigation

            onNewRouteStarted: root.newRouteStarted()
        }

    }

    signal newRouteStarted()

    function updateZoom(scale) {
        navigation.updateZoom(scale);
    }

    function stopZoom() {
        navigation.stopZoom();
    }

    function setDestinationLatLong(latitude, logitude) {
        navigation.setDestinationLatLong(latitude, logitude);
    }

}
