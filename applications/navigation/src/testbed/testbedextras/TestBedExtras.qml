import QtQuick
import QtQuick.Controls
import com.spyro_soft.wavey.navigation_iface

Row {
    readonly property Navigation
    navigation: Navigation {
        id: navigation
    }

    TextField {
        id: positionField
    }

    Button {
        text: "Send Directions"
        onClicked: {
            let latLong = positionField.text.split(",");
            console.log("LatLong:", parseFloat(latLong[0]), parseFloat(latLong[1]));
            navigation.setDestinationLatLong(parseFloat(latLong[0]), parseFloat(latLong[1]));
        }
    }

}
