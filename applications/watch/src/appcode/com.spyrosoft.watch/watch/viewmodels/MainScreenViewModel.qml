import QtQuick
import QtQuick.Controls
import QtQml
import com.spyro_soft.wavey.watch_iface

import wavey.gestures
import wavey.viewmodels

WatchViewModelBase {
    id: root

    property ScrollBar verticalScrollBar: null
    property ScrollBar horizontalScrollBar: null
    property ScrollBar horizontalScrollBar2: null

    readonly property QtObject priv: QtObject {
        id: p

        readonly property GesturesListener gesturesListener: GesturesListener {
            property real baseStepSize: 0.0018
            property int dx: 0
            property int dx2: 0
            property int dy: 0

            active: root.active
            onDrag: (fingerCount, direction, values) => {
                        if (fingerCount === 1) {
                            if (shouldScroll(values.x, dx)) {
                                moveHorizontalBy((values.x - dx) * baseStepSize, root.horizontalScrollBar)
                                moveHorizontalBy((values.x - dx2) * baseStepSize, root.horizontalScrollBar2)
                                dx = values.x
                                dx2 = values.x
                            } else {
                                dx = 0
                                dx2 = 0
                            }
                            if (shouldScroll(values.y, dy)) {
                                moveVerticalBy((values.y - dy) * baseStepSize)
                                dy = values.y
                            } else {

                            }

                            return true
                        }
                        return false
                    }
        }
    }

    function shouldScroll(value, delta) {
        // dragging occurs when the user moves 40 pixels from the starting point, otherwise it's Tap and Hold
        // this is so that when the user stops dragging, and then starts dragging again, the movement seems fluid
        // so there is no jumping from one corner to another
        // also, the signals are not sent every pixel, so the moment user starts dragging, the signal may be sent from the 41st pixel
        // the range [39, 41] seems like a reliable one
        return !((Math.abs(value) >= 39 && Math.abs(value) <= 41)
                 && (Math.abs(delta) < 38 || Math.abs(delta) > 42))
    }

    property var maxScrollBarWidth: {
        hasOwnProperty: prop => {
            for (const p in this) {
                if (p === prop)
                    return true;
            }
            return false;
        };
    }

    property var maxScrollBarHeight: {
        hasOwnProperty: prop => {
            for (const p in this) {
                if (p === prop)
                    return true;
            }
            return false;
        };
    }

    function moveHorizontalBy(dx, scrollBar) {
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

    function moveVerticalBy(dy) {
        if(verticalScrollBar) {
            if (!maxScrollBarHeight.hasOwnProperty(verticalScrollBar.background.height) || maxScrollBarHeight[verticalScrollBar.background.height] < verticalScrollBar.contentItem.height) {
                maxScrollBarHeight[verticalScrollBar.background.height] = verticalScrollBar.contentItem.height;
            }
            const scrollBarHeight = maxScrollBarHeight[verticalScrollBar.background.height] / verticalScrollBar.background.height;
            if (verticalScrollBar.position + dy + scrollBarHeight > 1) {
                verticalScrollBar.position = 1 - scrollBarHeight;
            } else if (verticalScrollBar.position + dy < 0) {
                verticalScrollBar.position = 0;
            } else if (dy !== 0) {
                verticalScrollBar.position += dy;
            }
        }
    }
}
