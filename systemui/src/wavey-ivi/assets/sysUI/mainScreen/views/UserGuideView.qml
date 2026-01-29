import QtQuick
import QtQuick.Controls
import com.spyro_soft.wavey.sysuiipc
import wavey.style
import viewmodels

Item {
    id: root

    enum GuideScenario {
        EditModeScenario,
        NavigationAppScenario,
        MediaPlayerAppScenario
    }
    enum GuideScenarioStep {
        OpenEditMode,
        CloseEditMode,
        ChangeAppLeft,
        ChangeAppRight,
        ScrollApp,
        SelectApp,
        ZoomOut,
        CloseApp,
        MediaPlayerNextSong,
        MediaPlayerVolume,
        MediaPlayerSongProgress,
        MediaPlayerNextPage,
        MediaPlayerStopPlay,
        MediaPlayerScroll,
        MediaPlayerSelect,
        MediaPlayerPreviousPage,
        NavigationZoom
    }

    readonly property QtObject internal: QtObject {
        id: internal

        property string actionText: ""
        property int activeScenario: -1
        property var activeScenarioSteps: []
        property int currentStep: -1
        property int frameCount: -1
        property int frameHeight: -1
        property int frameWidth: -1
        property string iconSource: ""
        property var lastScenarios: []
        readonly property Timer postStepTimer: Timer {
            id: postStepTimer

            readonly property int defaultInterval: 500

            interval: defaultInterval
            repeat: false
            running: false

            // Sometime gestures consist of 2 steps, like TapAndHold and then scroll
            // It runs delayed action for specific step
            onTriggered: {
                interval = defaultInterval;
                internal.postProcessNextStep();
            }
        }
        readonly property Timer stepTimer: Timer {
            id: stepTimer

            property bool runSingleScenario: false

            interval: 5000
            repeat: true
            running: false

            onTriggered: {
                if (internal.activeScenarioSteps.length > 0) {
                    internal.processNextStep();
                    return;
                }
                if (runSingleScenario) {
                    runSingleScenario = false;
                    stop();
                    internal.reset();
                    return;
                }

                internal.chooseNextScenario();
                internal.prepareScenarioSteps();
                if (internal.activeScenarioSteps.length === 0) {
                    console.error("Failed to prepare next steps. Trying to restart user guides");
                    stop();
                    internal.start();
                }
            }
        }

        function chooseNextScenario() {
            lastScenarios.push(activeScenario);
            if (root.viewModel.arrangeModeActive) {
                activeScenario = UserGuideView.EditModeScenario;
                return;
            }

            const activeAppId = viewModel.apps.getSlotAppId(viewModel.apps.activeSlot);
            if (activeAppId === "com.spyrosoft.mediaplayer" && !wasInLastNScenarios(UserGuideView.MediaPlayerAppScenario, 2)) {
                activeScenario = UserGuideView.MediaPlayerAppScenario;
            } else if (activeAppId === "com.spyrosoft.navigation" && !wasInLastNScenarios(UserGuideView.NavigationAppScenario, 2)) {
                activeScenario = UserGuideView.NavigationAppScenario;
            } else {
                activeScenario = UserGuideView.EditModeScenario;
            }
        }

        function postProcessNextStep() {
            switch (currentStep) {
            case UserGuideView.MediaPlayerVolume:
                viewModel.drawUserGuideGesture(Sysuiipc.Scroll, Sysuiipc.Top, 1, Sysuiipc.gestureChangeValues(), Sysuiipc.Scroll1Top);
                break;
            case UserGuideView.MediaPlayerSongProgess:
                viewModel.drawUserGuideGesture(Sysuiipc.Scroll, Sysuiipc.Right, 1, Sysuiipc.gestureChangeValues(), Sysuiipc.Scroll1Right);
                break;
            case UserGuideView.CloseApp:
                viewModel.drawUserGuideGesture(Sysuiipc.Unknown, Sysuiipc.None, 0, Sysuiipc.gestureChangeValues(0, 0, 0, true), Sysuiipc.UnkownAnimation);
                break;
            default:
                break;
            }
        }

        function prepareEditModeScenario() {
            const appCount = viewModel.apps.count;

            let editModeScenarioSteps = [];
            if (!viewModel.arrangeModeActive) {
                editModeScenarioSteps.push(UserGuideView.OpenEditMode);
            }

            const newAppsAvailable = viewModel.availableApps.length > 0;

            if (appCount > 1) {
                let newAppCount = appCount;
                let activeSlot = viewModel.apps.activeSlot;
                if (newAppsAvailable && viewModel.apps.activeSlot == appCount - 1 && appCount < viewModel.apps.maxSlotsCount) {
                    // Select "add app" slot, add new app
                    editModeScenarioSteps.push(UserGuideView.ChangeAppRight);
                    editModeScenarioSteps.push(UserGuideView.SelectApp);
                    editModeScenarioSteps.push(UserGuideView.ScrollApp);
                    editModeScenarioSteps.push(UserGuideView.SelectApp);
                    ++newAppCount;
                } else if (viewModel.apps.activeSlot >= appCount - 1) {
                    --activeSlot;
                    editModeScenarioSteps.push(UserGuideView.ChangeAppLeft);
                } else {
                    ++activeSlot;
                    editModeScenarioSteps.push(UserGuideView.ChangeAppRight);
                }
                if (newAppCount === 2) {
                    editModeScenarioSteps.push(UserGuideView.ZoomOut);
                }
                if (activeSlot > 0) {
                    // Move to left to close oldest app
                    editModeScenarioSteps.push(UserGuideView.ChangeAppLeft);
                }
                editModeScenarioSteps.push(UserGuideView.CloseApp);
            } else if (appCount <= 1) {
                if (appCount === 1 && newAppsAvailable) {
                    // Select "add app" slot only if there is one app
                    editModeScenarioSteps.push(UserGuideView.ChangeAppRight);
                }
                // Add new app
                editModeScenarioSteps.push(UserGuideView.SelectApp);
                editModeScenarioSteps.push(UserGuideView.ScrollApp);
                editModeScenarioSteps.push(UserGuideView.SelectApp);
                if (appCount === 1 && newAppsAvailable) {
                    // Now there should be 2 apps
                    // Zooming out is avilable
                    editModeScenarioSteps.push(UserGuideView.ZoomOut);
                    // Move to oldest app (one on left)
                    editModeScenarioSteps.push(UserGuideView.ChangeAppLeft);
                    // Close it
                    editModeScenarioSteps.push(UserGuideView.CloseApp);
                }
            }
            editModeScenarioSteps.push(UserGuideView.CloseEditMode);

            console.log("Prepared edit mode scenario:", editModeScenarioSteps);
            activeScenarioSteps = editModeScenarioSteps;
        }

        function prepareMediaPlayerAppScenario() {
            var mediaPlayerScenarioSteps = [
                // Song page
                UserGuideView.MediaPlayerNextSong,
                //                UserGuideView.MediaPlayerVolume, // TODO uncomment after implemented
                //                UserGuideView.MediaPlayerSongProgress, // TODO uncomment after implemented
                UserGuideView.MediaPlayerNextPage, UserGuideView.MediaPlayerStopPlay,
                // Song selection page
                //                UserGuideView.MediaPlayerVolume, // TODO uncomment after implemented
                UserGuideView.MediaPlayerScroll, UserGuideView.MediaPlayerSelect, UserGuideView.MediaPlayerPreviousPage];
            activeScenarioSteps = mediaPlayerScenarioSteps;
        }

        function prepareNavigationAppScenario() {
            var navigationScenarioSteps = [UserGuideView.NavigationZoom];
            activeScenarioSteps = navigationScenarioSteps;
        }

        function prepareScenarioSteps() {
            switch (activeScenario) {
            case UserGuideView.EditModeScenario:
                prepareEditModeScenario();
                break;
            case UserGuideView.NavigationAppScenario:
                prepareNavigationAppScenario();
                break;
            case UserGuideView.MediaPlayerAppScenario:
                prepareMediaPlayerAppScenario();
                break;
            default:
                break;
            }
        }

        function processNextStep() {
            currentStep = -1;
            internal.iconSource = "";
            internal.actionText = "";

            if (activeScenarioSteps.length === 0) {
                return;
            }

            currentStep = activeScenarioSteps.shift();
            console.log("Go further in guide", currentStep);
            switch (currentStep) {
            case UserGuideView.OpenEditMode:
                internal.iconSource = "open_edit_mode";
                internal.actionText = "edit mode";
                internal.frameWidth = 100;
                internal.frameHeight = 110; // If problems sets back to 100
                internal.frameCount = 38;
                viewModel.drawUserGuideGesture(Sysuiipc.Swipe, Sysuiipc.Top, 3, Sysuiipc.gestureChangeValues(), Sysuiipc.Drag3Up);
                break;
            case UserGuideView.CloseEditMode:
                internal.iconSource = "close_edit_mode";
                internal.actionText = "close\nedit mode";
                internal.frameWidth = 100;
                internal.frameHeight = 130;
                internal.frameCount = 41;
                viewModel.drawUserGuideGesture(Sysuiipc.Swipe, Sysuiipc.Bottom, 3, Sysuiipc.gestureChangeValues(), Sysuiipc.Drag3Down);
                break;
            case UserGuideView.ChangeAppLeft:
                internal.iconSource = "select_app";
                internal.actionText = "change\nselected app";
                internal.frameWidth = 102;
                internal.frameHeight = 102;
                internal.frameCount = 55;
                viewModel.drawUserGuideGesture(Sysuiipc.Scroll, Sysuiipc.Left, 2, Sysuiipc.gestureChangeValues(), Sysuiipc.Scroll2Left);
                break;
            case UserGuideView.ChangeAppRight:
                internal.iconSource = "select_app";
                internal.actionText = "change\nselected app";
                internal.frameWidth = 102;
                internal.frameHeight = 102;
                internal.frameCount = 55;
                viewModel.drawUserGuideGesture(Sysuiipc.Scroll, Sysuiipc.Right, 2, Sysuiipc.gestureChangeValues(), Sysuiipc.Scroll2Right);
                break;
            case UserGuideView.ZoomOut:
                internal.iconSource = "zoom_out";
                internal.actionText = "change app size";
                internal.frameWidth = 102;
                internal.frameHeight = 102;
                internal.frameCount = 55;
                viewModel.drawUserGuideGesture(Sysuiipc.Pinch, Sysuiipc.None, 2, Sysuiipc.gestureChangeValues(0, 0, 2.5, false), Sysuiipc.ZoomOut);
                break;
            case UserGuideView.NavigationZoom:
                internal.iconSource = "zoom_out";
                internal.actionText = "zoom out map";
                internal.frameWidth = 102;
                internal.frameHeight = 102;
                internal.frameCount = 55;
                const zoom = 0.9 + 0.1 * Math.random();
                viewModel.drawUserGuideGesture(Sysuiipc.Pinch, Sysuiipc.None, 2, Sysuiipc.gestureChangeValues(0, 0, zoom, false), Sysuiipc.ZoomOut);
                break;
            case UserGuideView.SelectApp:
                internal.iconSource = "tap_and_hold";
                internal.actionText = "add app";
                internal.frameWidth = 100;
                internal.frameHeight = 100;
                internal.frameCount = 59;
                viewModel.drawUserGuideGesture(Sysuiipc.TapAndHold, Sysuiipc.None, 1, Sysuiipc.gestureChangeValues(), Sysuiipc.TapAndHold1);
                break;
            case UserGuideView.CloseApp:
                internal.iconSource = "close_app";
                internal.actionText = "close app";
                internal.frameWidth = 100;
                internal.frameHeight = 140;
                internal.frameCount = 44;
                viewModel.drawUserGuideGesture(Sysuiipc.Drag, Sysuiipc.Top, 3, Sysuiipc.gestureChangeValues(), Sysuiipc.Drag3Up);
                break;
            case UserGuideView.MediaPlayerNextSong:
                internal.iconSource = "next_prev_song";
                internal.actionText = "next / previous\nsong";
                internal.frameWidth = 152;
                internal.frameHeight = 102;
                internal.frameCount = 92;
                viewModel.drawUserGuideGesture(Sysuiipc.Swipe, Sysuiipc.Right, 1, Sysuiipc.gestureChangeValues(), Sysuiipc.Swipe1Right);
                break;
            case UserGuideView.MediaPlayerVolume:
                internal.iconSource = "1_hold_scroll_vertical";
                internal.actionText = "volume";
                viewModel.drawUserGuideGesture(Sysuiipc.TapAndHold, Sysuiipc.None, 1, Sysuiipc.gestureChangeValues(), Sysuiipc.TapAndHold1);
                break;
            case UserGuideView.MediaPlayerSongProgress:
                internal.iconSource = "1_hold_scroll_horizontal";
                internal.actionText = "song progress";
                viewModel.drawUserGuideGesture(Sysuiipc.TapAndHold, Sysuiipc.None, 1, Sysuiipc.gestureChangeValues(), Sysuiipc.TapAndHold1);
                break;
            case UserGuideView.MediaPlayerNextPage:
                internal.iconSource = "next_page_mediaplayer";
                internal.actionText = "view next page";
                internal.frameWidth = 102;
                internal.frameHeight = 102;
                internal.frameCount = 55;
                viewModel.drawUserGuideGesture(Sysuiipc.Swipe, Sysuiipc.Bottom, 2, Sysuiipc.gestureChangeValues(), Sysuiipc.Swipe2Down);
                break;
            case UserGuideView.MediaPlayerPreviousPage:
                internal.iconSource = "prev_page_mediaplayer";
                internal.actionText = "view prev page";
                internal.frameWidth = 100;
                internal.frameHeight = 100;
                internal.frameCount = 90;
                viewModel.drawUserGuideGesture(Sysuiipc.Swipe, Sysuiipc.Top, 2, Sysuiipc.gestureChangeValues(), Sysuiipc.Swipe2Up);
                break;
            case UserGuideView.MediaPlayerStopPlay:
                internal.iconSource = "stop_play";
                internal.actionText = "pause / play";
                internal.frameWidth = 100;
                internal.frameHeight = 100;
                internal.frameCount = 30;
                viewModel.drawUserGuideGesture(Sysuiipc.DoubleTap, Sysuiipc.None, 1, Sysuiipc.gestureChangeValues(), Sysuiipc.DoubleTap2);
                break;
            case UserGuideView.MediaPlayerScroll:
                internal.iconSource = "scroll";
                internal.actionText = "scroll";
                internal.frameWidth = 102;
                internal.frameHeight = 102;
                internal.frameCount = 55;
                viewModel.drawUserGuideGesture(Sysuiipc.Scroll, Sysuiipc.Top, 1, Sysuiipc.gestureChangeValues(), Sysuiipc.Scroll1Top);
                break;
            case UserGuideView.ScrollApp:
                internal.iconSource = "scroll";
                internal.actionText = "scroll";
                internal.frameWidth = 102;
                internal.frameHeight = 102;
                internal.frameCount = 55;
                viewModel.drawUserGuideGesture(Sysuiipc.Scroll, Sysuiipc.Top, 1, Sysuiipc.gestureChangeValues(), Sysuiipc.Scroll1Top);
                break;
            case UserGuideView.MediaPlayerSelect:
                internal.iconSource = "stop_play";
                internal.actionText = "pause / play";
                internal.frameWidth = 100;
                internal.frameHeight = 100;
                internal.frameCount = 30;
                viewModel.drawUserGuideGesture(Sysuiipc.DoubleTap, Sysuiipc.Bottom, 1, Sysuiipc.gestureChangeValues(), Sysuiipc.DoubleTap1);
                break;
            default:
                console.error("Unknown scenario step detected!", currentStep);
                return;
            }

            internal.postStepTimer.start();
        }

        function reset() {
            internal.iconSource = "";
            internal.actionText = "";
            activeScenarioSteps = [];
            currentStep = -1;
            lastScenarios = [];
            activeScenario = -1;
        }

        function start() {
            reset();

            chooseNextScenario();
            prepareScenarioSteps();

            if (activeScenarioSteps.length === 0) {
                console.error("Failed to start user guides, steps are empty! Active scenario:", activeScenario);
                return;
            }

            stepTimer.start();
        }

        function stop() {
            console.log("Stopping user guides!");
            stepTimer.stop();
            postStepTimer.stop();
            reset();
        }

        function wasInLastNScenarios(scenario, n) {
            const index = internal.lastScenarios.lastIndexOf(scenario);
            const lastIndex = internal.lastScenarios.length - 1;
            return index !== -1 && lastIndex - index < n;
        }
    }
    property MainScreenViewModel viewModel

    Connections {
        function onUserGuideModeActiveChanged() {
            if (root.viewModel.userGuideModeActive) {
                if (internal.stepTimer.running) {
                    return;
                }
                internal.start();
            } else {
                internal.stop();
            }
        }

        target: root.viewModel
    }

    Item {
        anchors.centerIn: parent
        anchors.horizontalCenterOffset: 40
        height: 200
        width: 200

        AnimatedSprite {
            id: animationSprite

            readonly property int fps: 24

            anchors.bottom: gestureText.top
            anchors.horizontalCenter: parent.horizontalCenter
            frameCount: internal.frameCount
            frameDuration: 40
            frameHeight: internal.frameHeight
            frameWidth: internal.frameWidth
            running: internal.iconSource !== ""
            source: internal.iconSource !== "" ? String("../../mainScreenUI/%1/gesture_%2.png").arg(WaveyStyle.currentThemeName.toLowerCase()).arg(internal.iconSource) : ""
        }

        Text {
            id: gestureText

            color: WaveyStyle.secondaryColor
            font: WaveyFonts.userGuideAction
            horizontalAlignment: Text.AlignHCenter
            text: internal.actionText

            anchors {
                bottom: parent.bottom
                left: parent.left
                right: parent.right
                topMargin: 15
            }
        }
    }

    Loader {
        active: root.viewModel.developmentMode
        anchors.fill: parent

        sourceComponent: MouseArea {
            acceptedButtons: Qt.RightButton

            onClicked: mouse => {
                testMenu.x = mouse.x;
                testMenu.y = mouse.y;
                testMenu.open();
            }

            Menu {
                id: testMenu

                MenuItem {
                    enabled: !internal.stepTimer.running
                    text: "start guide"

                    onClicked: internal.start()
                }

                MenuItem {
                    enabled: internal.stepTimer.running
                    text: "stop guide"

                    onClicked: internal.stop()
                }

                MenuItem {
                    enabled: !internal.stepTimer.running
                    text: "start edit mode guide"

                    onClicked: {
                        internal.stepTimer.runSingleScenario = true;
                        internal.activeScenario = UserGuideView.EditModeScenario;
                        internal.prepareScenarioSteps();
                        internal.stepTimer.start();
                    }
                }

                MenuItem {
                    enabled: !internal.stepTimer.running
                    text: "start navigation guide"

                    onClicked: {
                        internal.stepTimer.runSingleScenario = true;
                        internal.activeScenario = UserGuideView.NavigationAppScenario;
                        internal.prepareScenarioSteps();
                        internal.stepTimer.start();
                    }
                }

                MenuItem {
                    enabled: !internal.stepTimer.running
                    text: "start media player guide"

                    onClicked: {
                        internal.stepTimer.runSingleScenario = true;
                        internal.activeScenario = UserGuideView.MediaPlayerAppScenario;
                        internal.prepareScenarioSteps();
                        internal.stepTimer.start();
                    }
                }
            }
        }
    }
}
