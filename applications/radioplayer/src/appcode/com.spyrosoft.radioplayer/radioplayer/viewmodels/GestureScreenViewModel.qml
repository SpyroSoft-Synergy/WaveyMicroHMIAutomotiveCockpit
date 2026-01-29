import QtQuick
import QtQml
import com.spyro_soft.wavey.radioplayer_iface

import wavey.gestures
import wavey.viewmodels

RadioPlayerViewModelBase {
    id: root

    readonly property QtObject priv: QtObject {
        id: priv

        readonly property RadioPlayerServer server : RadioPlayerServer {
            Component.onCompleted: {
                start()
            }
        }
    }
}
