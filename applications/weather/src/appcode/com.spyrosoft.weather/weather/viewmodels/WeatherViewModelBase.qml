import QtQuick
import QtQml
import com.spyro_soft.wavey.weather_iface
import wavey.gestures
import wavey.viewmodels

ApplicationRootViewModel {
    id: root

    readonly property QtObject d: QtObject {
        id: d

        readonly property Weather weather: Weather {
            id: weather
        }
    }
}
