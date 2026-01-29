import QtQml
import QtQuick
import com.spyro_soft.wavey.navigation_iface
import wavey.gestures
import wavey.viewmodels

NavigationViewModelBase {
    id: root

    readonly property QtObject
    priv: QtObject {
        id: p

        readonly property GesturesListener
        gesturesListener: GesturesListener {
            active: root.active
            onPinch: (fingerCount, values) => {
                if (values.released)
                    root.stopZoom();
                else
                    root.updateZoom(values.scale);
                return true;
            }
        }

    }

}
