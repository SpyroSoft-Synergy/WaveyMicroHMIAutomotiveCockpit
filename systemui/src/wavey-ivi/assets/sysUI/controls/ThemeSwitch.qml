import QtQuick
import wavey.style

Item {
    id: root

    signal changeTheme(int theme)

    states: State {
        name: "expanded"
        when: content.expanded

        PropertyChanges {
            target: leftOption
            textOpacity: 1
        }

        PropertyChanges {
            target: rightOption
            textOpacity: 1
        }

        PropertyChanges {
            height: 70
            target: content
            width: 288
        }

        PropertyChanges {
            target: highlighImage
            y: 0
        }
    }
    transitions: Transition {
        PropertyAnimation {
            duration: 200
            properties: "textOpacity"
            target: leftOption
        }

        PropertyAnimation {
            duration: 200
            properties: "textOpacity"
            target: rightOption
        }

        PropertyAnimation {
            duration: 250
            properties: "width,height"
            target: content
        }

        PropertyAnimation {
            duration: 250
            properties: "y"
            target: highlighImage
        }
    }

    Image {
        id: highlighImage

        fillMode: Image.PreserveAspectFit
        source: "../mainScreenUI/theme_switch_background.png"
        width: parent.width
        y: -120
    }

    MouseArea {
        id: dragMouseArea

        property real pressY: -1

        anchors.horizontalCenter: parent.horizontalCenter
        anchors.top: parent.top
        height: 100
        width: parent.width * 0.5

        onPositionChanged: mouse => {
            if (!dragMouseArea.pressed) {
                return;
            }
            const diff = mouse.y - pressY;
            const minimumY = 30;
            if (diff > minimumY && !content.expanded) {
                content.expanded = true;
            } else if (diff < -minimumY && content.expanded) {
                content.expanded = false;
            }
        }
        onPressed: mouse => {
            pressY = mouse.y;
        }
    }

    Item {
        id: content

        property bool expanded: false
        readonly property Timer foldTimer: Timer {
            interval: 3000
            repeat: false
            running: false

            onTriggered: content.expanded = false
        }

        anchors.horizontalCenter: parent.horizontalCenter
        anchors.top: parent.top
        anchors.topMargin: 15
        enabled: content.expanded
        height: 8
        width: 120

        // It is restarting because it also restarts when user click any option
        // That could cause to fold content before desired time
        onExpandedChanged: expanded ? foldTimer.restart() : foldTimer.stop()

        SwitchSide {
            id: leftOption

            anchors.left: parent.left
            text: "Night"
            value: WaveyStyle.Dark

            onClicked: {
                content.foldTimer.restart();
                root.changeTheme(value);
            }
        }

        Rectangle {
            anchors.centerIn: parent
            color: leftOption.backgroundColor
            height: parent.height
            width: 2
        }

        SwitchSide {
            id: rightOption

            anchors.right: parent.right
            isLeftSide: false
            text: "Day"
            value: WaveyStyle.Light

            onClicked: {
                content.foldTimer.restart();
                root.changeTheme(value);
            }
        }
    }

    component SwitchSide: Item {
        id: switchSide

        readonly property bool active: WaveyStyle.theme === value
        property color backgroundColor: WaveyStyle.primaryColor // qmllint disable
        property string fontFamily: WaveyFonts.h7.family // qmllint disable

        property bool isLeftSide: true
        property string text: ""
        property color textColor: WaveyStyle.primaryColor // qmllint disable
        property real textOpacity: 0.0
        property int value: -1

        signal clicked

        clip: true
        height: parent.height
        width: parent.width * 0.5

        Rectangle {
            anchors.left: switchSide.isLeftSide ? parent.left : undefined
            anchors.right: switchSide.isLeftSide ? undefined : parent.right
            border.color: switchSide.backgroundColor
            border.width: switchSide.active ? 2 : 1
            color: {
                const alpha = (switchSide.active ? 0.2 : 0.0) + (1.0 - switchSide.textOpacity);
                return Qt.alpha(switchSide.backgroundColor, Math.min(1.0, alpha));
            }
            height: parent.height
            radius: height
            width: parent.width * 1.2
        }

        Text {
            anchors.centerIn: parent
            color: switchSide.textColor
            font.family: switchSide.fontFamily
            font.pixelSize: 26
            font.weight: switchSide.active ? WaveyFonts.h6.weight : WaveyFonts.h7.weight // qmllint disable
            opacity: switchSide.textOpacity
            text: switchSide.text
        }

        MouseArea {
            anchors.fill: parent

            onClicked: switchSide.clicked()
        }
    }
}
