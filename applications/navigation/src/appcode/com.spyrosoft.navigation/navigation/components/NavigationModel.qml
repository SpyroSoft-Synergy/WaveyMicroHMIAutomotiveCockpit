import QtQuick

ListModel {
    ListElement {
        name: "Home"
        address: "Sky Birch Ct"
        icon: "../assets/home"
        location: function() {
            return Qt.point(36.1202, -115.264);
        }
    }

    ListElement {
        name: "Work"
        address: "Nellis Blvd"
        icon: "../assets/work"
        location: function() {
            return Qt.point(36.1651, -115.062);
        }
    }

    ListElement {
        name: "LV Airport"
        address: "Airport Dr"
        icon: "../assets/address"
        location: function() {
            return Qt.point(36.2091, -115.2);
        }
    }

    ListElement {
        name: "G. Ramsay Burger"
        address: "Las Vegas Blvd"
        icon: "../assets/address"
        location: function() {
            return Qt.point(36.1097, -115.173);
        }
    }

}
