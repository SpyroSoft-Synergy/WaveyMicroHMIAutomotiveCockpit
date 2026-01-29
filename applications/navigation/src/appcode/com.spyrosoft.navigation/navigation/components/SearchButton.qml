import QtQuick

TwoStateImageButton {
    id: root

    normalSource: "../assets/search_button.png"
    activeSource: "../assets/search_button_focused.png"

    MouseArea {
        width: root.width * 1.1
        height: root.height
        anchors.centerIn: parent
        onPressed: {
            root.isActive = true;
        }
        onReleased: {
            root.isActive = false;
        }
    }

}
