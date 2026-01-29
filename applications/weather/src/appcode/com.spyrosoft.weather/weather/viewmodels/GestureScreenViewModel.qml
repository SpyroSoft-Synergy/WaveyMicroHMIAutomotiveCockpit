import QtQuick
import QtQml
import com.spyro_soft.wavey.weather_iface
import wavey.gestures
import wavey.viewmodels

WeatherViewModelBase {
    id: root

    readonly property QtObject priv: QtObject {
        id: priv

        readonly property WeatherServer server: WeatherServer {
            Component.onCompleted: {
                start();
            }
        }
    }
}
