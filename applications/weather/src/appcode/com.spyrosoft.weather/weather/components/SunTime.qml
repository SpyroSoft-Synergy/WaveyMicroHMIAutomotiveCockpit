import QtQuick
import wavey.style

Row {
    required property string icon
    required property string what

    spacing: 12
    width: 80

    Image {
        height: width
        source: `../assets/icons/${icon}.png`
        width: row.height
    }

    Text {
        color: WaveyStyle.primaryColor
        text: what

        font {
            family: WaveyFonts.text_6.family
            pixelSize: WaveyFonts.text_6.pixelSize
            weight: WaveyFonts.text_6.weight
        }
    }
}
