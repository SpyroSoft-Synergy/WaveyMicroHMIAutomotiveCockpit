import QtQuick
import watch.components
import QtQuick.Layouts
import wavey.style
import wavey.components
import watch.viewmodels

Item {
    id: root

    property WatchViewModelBase viewModel

    function updateTime() {
        const weekday = ["Sunday", "Monday", "Tuesday", "Wednesday", "Thursday", "Friday", "Saturday"]
        const month = ["January", "February", "March", "April", "May", "June", "July", "August", "September", "October", "November", "December"]

        let date = new Date()
        analogClock.hour = digitalClock.hour = date.getUTCHours()
        analogClock.minutes = digitalClock.minutes = date.getUTCMinutes()
        analogClock.seconds = digitalClock.seconds = date.getUTCSeconds()
        analogClock.day = digitalClock.day = date.getUTCDate()
        analogClock.month = digitalClock.month = month[date.getUTCMonth()]
        analogClock.year = digitalClock.year = date.getUTCFullYear()
        analogClock.dayOfTheWeek = digitalClock.dayOfTheWeek = weekday[date.getUTCDay()]
    }

    Timer {
        interval: 1000
        running: true
        repeat: true
        onTriggered: root.updateTime()
        triggeredOnStart: true
    }

    Rectangle {
        anchors.fill: parent
        color: WaveyStyle.backgroundColor
    }

    ScreenSwitcher {
        id: mainScreenSwitcher
        anchors.fill: parent
        currentScreenIndex: 0
        appScreens: [
            AnalogClockScreen {
                id: analogClock
                onRegisterHorizontalScrollBar: scrollBar => root.viewModel.horizontalScrollBar2 = scrollBar
                onRegisterVerticalScrollBar: scrollBar => root.viewModel.verticalScrollBar = scrollBar
            },

            DigitalClockScreen {
                id: digitalClock
                width: root.width
                height: root.height
                onRegisterScrollBar: scrollBar => root.viewModel.horizontalScrollBar = scrollBar
            }
        ]
        initialItem: mainScreenSwitcher.appScreens[mainScreenSwitcher.currentScreenIndex]
        popEnter: Transition {
            YAnimator {
                from: -mainScreenSwitcher.height
                to: 0
                duration: mainScreenSwitcher.animationDuration
                easing.type: Easing.InQuad
            }
        }
        popExit: Transition {
            YAnimator {
                from: 0
                to: mainScreenSwitcher.height
                duration: mainScreenSwitcher.animationDuration
                easing.type: Easing.InQuad
            }
        }
        pushEnter: Transition {
            YAnimator {
                from: mainScreenSwitcher.height
                to: 0
                duration: mainScreenSwitcher.animationDuration
                easing.type: Easing.InQuad
            }
        }
        pushExit: Transition {
            YAnimator {
                from: 0
                to: -mainScreenSwitcher.height
                duration: mainScreenSwitcher.animationDuration
                easing.type: Easing.InQuad
            }
        }
    }

    Connections {
        target: root.viewModel.d.watch
        function onCurrentClockChanged() {
            mainScreenSwitcher.switchScreen(root.viewModel.d.watch.currentClock)
        }
    }
}
