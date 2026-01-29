import QtQuick
import QtQuick.Controls
import QtQml
import com.spyro_soft.wavey.weather_iface
import wavey.gestures
import wavey.viewmodels
import QtApplicationManager.SystemUI 2.0

WeatherViewModelBase {
    id: root

    property var maxScrollBarWidth: {
        hasOwnProperty: prop => {
            for (const p in this) {
                if (p === prop)
                    return true;
            }
            return false;
        };
    }
    readonly property QtObject priv: QtObject {
        id: p

        readonly property GesturesListener gesturesListener: GesturesListener {
            property real baseStepSize: 0.0018
            property int dx: 0

            active: root.active

            onDrag: (fingerCount, direction, values) => {
                if (fingerCount === 1) {
                    // dragging occurs when the user moves 40 pixels from the starting point, otherwise it's Tap and Hold
                    // this is so that when the user stops dragging, and then starts dragging again, the movement seems fluid
                    // so there is no jumping from one corner to another
                    // also, the signals are not sent every pixel, so the moment user starts dragging, the signal may be sent from the 41st pixel
                    // the range [39, 41] seems like a reliable one
                    if ((Math.abs(values.x) >= 39 && Math.abs(values.x) <= 41) && (Math.abs(dx) < 38 || Math.abs(dx) > 42)) {
                        dx = 0;
                    }
                    moveBy((values.x - dx) * baseStepSize);
                    dx = values.x;
                    return true;
                }
                return false;
            }
        }
    }
    property ScrollBar scrollBar: null

    function moveBy(dx) {
        if (scrollBar) {
            if (!maxScrollBarWidth.hasOwnProperty(scrollBar.background.width) || maxScrollBarWidth[scrollBar.background.width] < scrollBar.contentItem.width) {
                maxScrollBarWidth[scrollBar.background.width] = scrollBar.contentItem.width;
            }
            const scrollBarWidth = maxScrollBarWidth[scrollBar.background.width] / scrollBar.background.width;
            if (scrollBar.position + dx + scrollBarWidth > 1) {
                scrollBar.position = 1 - scrollBarWidth;
            } else if (scrollBar.position + dx < 0) {
                scrollBar.position = 0;
            } else if (dx !== 0) {
                scrollBar.position += dx;
            }
        }
    }
}
