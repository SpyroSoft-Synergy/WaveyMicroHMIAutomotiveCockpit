import QtQuick
import QtQml
import com.spyro_soft.wavey.watch_iface

import wavey.gestures
import wavey.viewmodels

ApplicationRootViewModel {
    id: root

    readonly property QtObject d: QtObject {
        id: d

        readonly property Watch watch: Watch {
            id: watch
        }
    }

    function setClock(index) {
        watch.setClock(index)
    }
}
