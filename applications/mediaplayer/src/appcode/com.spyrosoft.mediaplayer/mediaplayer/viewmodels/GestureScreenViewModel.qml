import QtQuick
import QtQml
import com.spyro_soft.wavey.media
import wavey.gestures
import wavey.viewmodels

MediaPlayerViewModelBase {
    id: root

    readonly property QtObject priv: QtObject {
        id: priv

        readonly property MediaPlayerServer server : MediaPlayerServer {
            Component.onCompleted: {
                start()
            }
        }
    }
}
