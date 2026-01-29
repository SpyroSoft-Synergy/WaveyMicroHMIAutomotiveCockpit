import QtQuick
import QtQuick.Controls
import wavey.style

Slider {
    id: root
    from: 0
    to: 100
    stepSize: 10
    snapMode: Slider.SnapAlways
    rotation: -90
    background: Rectangle {
        x: root.leftPadding
        y: root.topPadding + root.availableHeight / 2 - height / 2
        implicitWidth: 330
        implicitHeight: 2
        width: root.availableWidth
        height: implicitHeight
        radius: 2
        color: WaveyStyle.sliderBackgroundColor

        Rectangle {
            width: root.visualPosition * parent.width
            height: parent.height
            gradient: Gradient {
                orientation: Gradient.Horizontal
                GradientStop {
                    position: 0.0
                    color: WaveyStyle.sliderGradientColor
                }
                GradientStop {
                    position: 1.0
                    color: WaveyStyle.accentColor
                }
            }

            radius: 2
        }
    }

    handle: Rectangle {
        x: root.leftPadding + root.visualPosition * (root.availableWidth - width)
        y: root.topPadding + root.availableHeight / 2 - height / 2
        implicitWidth: 30
        implicitHeight: 30
        radius: 15
        color: WaveyStyle.accentColor
    }
}
