import QtQuick
import QtQml
import com.spyro_soft.wavey.watch_iface

import wavey.gestures
import wavey.viewmodels

WatchViewModelBase {
    id: root

    readonly property QtObject priv: QtObject {
        id: priv

        readonly property WatchServer server : WatchServer {
            Component.onCompleted: {
                start()
            }
        }
    }
}
