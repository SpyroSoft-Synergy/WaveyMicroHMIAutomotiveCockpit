import QtQuick
import QtQuick.Controls

StackView {
    id: root
    property int currentScreenIndex: 0
    property list <QtObject> appScreens
    property int animationDuration: 250

    function switchScreen(newScreenIndex) {
        if (newScreenIndex > currentScreenIndex) {
            root.push(appScreens[newScreenIndex])
        } else {
            root.pop()
        }
        root.currentScreenIndex = newScreenIndex
    }

    popEnter: Transition {}
    popExit: Transition {
        YAnimator {
            from: 0
            to: -root.height
            duration: root.animationDuration
            easing.type: Easing.InQuad
        }
    }
    pushEnter: Transition {
        YAnimator {
            from: -root.height
            to: 0
            duration: root.animationDuration
            easing.type: Easing.InQuad
        }
    }
    pushExit: Transition {}
}
