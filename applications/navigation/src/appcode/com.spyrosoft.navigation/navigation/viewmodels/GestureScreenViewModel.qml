import QtQml
import QtQuick
import com.spyro_soft.wavey.navigation_iface
import wavey.gestures
import wavey.viewmodels

NavigationViewModelBase {
    id: root

    readonly property QtObject
    priv: QtObject {
        id: priv

        readonly property NavigationServer
        server: NavigationServer {
            Component.onCompleted: {
                start();
            }
        }

    }

}
