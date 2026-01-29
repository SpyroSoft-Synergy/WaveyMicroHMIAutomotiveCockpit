import QtQuick
import com.spyro_soft.wavey.sysuiipc
import QtApplicationManager
import QtApplicationManager.SystemUI
import models
import wavey.style

RootViewModel {
    id: root

    readonly property alias appSelectionActive: internal.appSelectionActive
    readonly property alias arrangeModeActive: internal.arrangeModeActive
    readonly property alias availableAppIndex: internal.availableAppIndex
    readonly property alias availableApps: internal.availableApps
    readonly property var availableAppsVisualModel: {
        var apps = [];
        for (let i = 0; i < internal.availableApps.length; i++) {
            apps.push(internal.availableApps[i]);
        }
        if (apps.length === 2) {
            // To get good looking view for 2 items, it adds transparent item
            apps = internal.addNullApp(apps);
        }
        return apps;
    }
    readonly property alias clusterWindows: internal.clusterWindows
    readonly property QtObject internal: QtObject {
        id: internal

        readonly property Connections appManConnections: Connections {
            function onApplicationRunStateChanged(id, runState) {
                let appsList = internal.availableApps;
                let index = -1;

                if (runState === Am.Running) {
                    index = appsList.findIndex(item => item.id === id);
                    if (index !== -1) {
                        appsList.splice(index, 1);
                    } else {
                        return;
                    }
                } else if (runState === Am.NotRunning) {
                    const app = ApplicationManager.application(id);
                    appsList = internal.addAvailableApp(app, appsList);
                } else {
                    return;
                }

                internal.availableApps = appsList;
                if (internal.availableApps.length > 0) {
                    internal.availableAppIndex = 0;
                }
            }

            target: ApplicationManager
        }
        property bool appSelectionActive: false
        readonly property AppStyle appStyle: AppStyle {
            id: appStyle

            onThemeChanged: theme => WaveyStyle.setAppTheme(theme)
        }
        readonly property Connections appsModelConnections: Connections {
            function onAddAppSlotSelectedChanged(value) {
                if (!value) {
                    internal.appSelectionActive = false;
                }
            }

            target: root.apps
        }
        // Arrange mode
        property bool arrangeModeActive: false
        property int availableAppIndex: -1
        property var availableApps: []
        property var clusterWindows: ({})
        // Gestures
        property int currentGestureId: -1
        readonly property GestureDetector gestureDetector: GestureDetector {
            id: gestureDetector

            onGestureDetected: (gestureId, gestureType, gestureDirection, fingerCount, valueChange) => {
                if (internal.currentGestureId !== gestureId) {
                    root.internal.handleGestureRelease(gestureId, gestureType, fingerCount);
                }
                internal.currentGestureId = gestureId;
                internal.lockedGestureId = -1;
                internal.startArrangeModeGestureId = -1;
                internal.lockedGestureMode = ApplicationSlot.Mode.None;
                root.lastGesture = qsTr("gesture id %1 detected, type:%2 direction:%3 fingerCount:%4 position:%5;%6 scale:%7").arg(gestureId).arg(Sysuiipc.gestureTypeToString(gestureType)).arg(Sysuiipc.gestureDirectionToString(gestureDirection)).arg(fingerCount).arg(valueChange.x).arg(valueChange.y).arg(valueChange.scale);
                root.internal.handleGesture(gestureId, gestureType, gestureDirection, fingerCount, valueChange);
            }
            onGestureReleased: (gestureId, gestureType, fingerCount) => {
                internal.currentGestureId = -1;
                root.lastGesture += qsTr(" , released");
                root.internal.handleGestureRelease(gestureId, gestureType, fingerCount);
            }
            onGestureUpdated: (gestureId, gestureType, gestureDirection, fingerCount, valueChange) => {
                internal.userGuideModeActive = false;
                root.lastGesture = qsTr("gesture id %1 detected, type:%2 direction:%3 fingerCount:%4 position:%5;%6 scale:%7").arg(gestureId).arg(Sysuiipc.gestureTypeToString(gestureType)).arg(Sysuiipc.gestureDirectionToString(gestureDirection)).arg(fingerCount).arg(valueChange.x).arg(valueChange.y).arg(valueChange.scale);
                root.internal.handleGesture(gestureId, gestureType, gestureDirection, fingerCount, valueChange);
            }
            onTouchActionDetected: pressed => {
                internal.userGuideModeActive = false;
                if (pressed) {
                    internal.userGuideStartTimer.stop();
                } else {
                    // Only start timer on release
                    internal.userGuideStartTimer.restartTimer();
                }
            }
        }
        property int lockedGestureId: -1
        property int lockedGestureMode: ApplicationSlot.Mode.None
        property int startArrangeModeGestureId: -1
        // User guide
        property int userGuideGestureId: 200000
        property bool userGuideModeActive: false
        readonly property Timer userGuideStartTimer: Timer {
            id: userGuideStartTimer

            function restartTimer() {
                // Run user guides only on target (developmentMode is false)
                if (internal.userGuideModeActive || root.developmentMode) {
                    return;
                }
                restart();
            }

            interval: 20000 // 20s
            repeat: false
            running: !root.developmentMode

            onTriggered: internal.userGuideModeActive = true
        }
        readonly property Connections windowsModelObserverConnections: Connections {
            function onClusterWindowAboutToBeRemoved(window) {
                const appId = window.application.id;
                delete internal.clusterWindows[appId];
                root.appClusterWindowsChanged();
            }

            function onClusterWindowAdded(window) {
                const appId = window.application.id;
                internal.clusterWindows[appId] = window;
                root.appClusterWindowsChanged();
            }

            target: root.windowsModelObserver
        }

        function addAvailableApp(app, appsList) {
            const appObject = {
                icon: app.icon,
                label: app.name,
                id: (app.applicationId !== undefined ? app.applicationId : app.id)
            };
            appsList.push(appObject);
            appsList.sort((a, b) => a.label.localeCompare(b.label));
            return appsList;
        }

        function addNullApp(appsList) {
            // To get proper effect on scrolling through 2 apps, empty app is added
            // to fill 3 apps path view. Null app is not visible
            const app = {
                icon: "",
                name: "zz",
                applicationId: "null"
            };
            return internal.addAvailableApp(app, appsList);
        }

        function handleAppZoom(zoomScale) {
            if (!root.apps.resizeEnabled) {
                return;
            }

            if (zoomScale > 2.0) {
                // Change to max size
                root.apps.tryResizingActiveApp(ApplicationSlot.Size.Large);
            } else if (zoomScale > 1.25) {
                if (root.apps.getAppSlotSize(root.apps.activeSlot) === ApplicationSlot.Size.Small) {
                    root.apps.tryResizingActiveApp(ApplicationSlot.Size.Medium);
                }
            } else if (zoomScale > 0.75)
            // skip 0.75 - 1.25
            {} else if (zoomScale > 0.5) {
                if (root.apps.getAppSlotSize(root.apps.activeSlot) === ApplicationSlot.Size.Large) {
                    root.apps.tryResizingActiveApp(ApplicationSlot.Size.Medium);
                }
            } else {
                // Change to smallest size
                root.apps.tryResizingActiveApp(ApplicationSlot.Size.Small);
            }
        }

        function handleArrangeModeGesture(gestureId, gestureType, gestureDirection, fingerCount, valueChange) {
            const isMovingMode = root.apps.getAppSlotMode(root.apps.activeSlot) === ApplicationSlot.Mode.Move;
            if (!isMovingMode && fingerCount === 3 && (gestureType === Sysuiipc.Swipe || gestureType === Sysuiipc.Scroll) && gestureDirection === Sysuiipc.Bottom) {
                root.internal.arrangeModeActive = false;
                return;
            }

            if (startArrangeModeGestureId === gestureId) {
                // Nothing more can be done in gesture that enabled arrange mode
                return;
            }

            const lockedGesture = internal.lockedGestureId === gestureId;

            if (root.apps.addAppSlotSelected) {
                if (gestureType === Sysuiipc.TapAndHold) {
                    if (!internal.appSelectionActive) {
                        internal.appSelectionActive = true;
                    } else {
                        const app = internal.availableApps[internal.availableAppIndex];
                        root.apps.tryAddSlot(app.label, app.id);
                    }
                    return;
                } else if (gestureType === Sysuiipc.Swipe || gestureType === Sysuiipc.Scroll) {
                    if (gestureDirection === Sysuiipc.Top) {
                        const newIndex = (internal.availableAppIndex + 1) % root.availableAppsVisualModel.length;
                        if (root.availableAppsVisualModel[newIndex].id === "null") {
                            internal.availableAppIndex = (newIndex + 1) % root.availableAppsVisualModel.length;
                            root.appSelectionGoDown();
                            return;
                        }
                        internal.availableAppIndex = newIndex;
                        root.appSelectionGoUp();
                        return;
                    } else if (gestureDirection === Sysuiipc.Bottom) {
                        const newIndex = (internal.availableAppIndex + root.availableAppsVisualModel.length - 1) % root.availableAppsVisualModel.length;
                        if (root.availableAppsVisualModel[newIndex].id === "null") {
                            internal.availableAppIndex = (newIndex + root.availableAppsVisualModel.length - 1) % root.availableAppsVisualModel.length;
                            root.appSelectionGoUp();
                            return;
                        }
                        internal.availableAppIndex = newIndex;
                        root.appSelectionGoDown();
                        return;
                    }
                }
            }

            if (gestureType === Sysuiipc.Scroll || gestureType === Sysuiipc.Swipe) {
                if (gestureDirection === Sysuiipc.Top && !isMovingMode && root.apps.count > 1) {
                    root.apps.changeAppSlotMode(root.apps.activeSlot, ApplicationSlot.Mode.Move);
                    return;
                } else if (gestureDirection === Sysuiipc.Bottom) {
                    if (isMovingMode) {
                        root.apps.changeAppSlotMode(root.apps.activeSlot, ApplicationSlot.Mode.None);
                        return;
                    }
                }

                if (gestureDirection === Sysuiipc.Right) {
                    if (isMovingMode) {
                        root.apps.tryMoveActiveSlotRight();
                    } else {
                        root.apps.tryActivatingNextSlot(internal.arrangeModeActive, internal.availableApps.length);
                    }
                    return;
                } else if (gestureDirection === Sysuiipc.Left) {
                    if (isMovingMode) {
                        root.apps.tryMoveActiveSlotLeft();
                    } else {
                        root.apps.tryActivatingPrevSlot();
                    }
                    return;
                }
            }

            if (isMovingMode) {
                // Needs to exit moving mode to do anything more to slot
                return;
            }

            if (gestureType === Sysuiipc.Pinch) {
                handleAppZoom(valueChange.scale);
            } else if (gestureType === Sysuiipc.Drag && gestureDirection === Sysuiipc.Top) {
                internal.lockedGestureId = gestureId;
                internal.lockedGestureMode = ApplicationSlot.Mode.Close;
                root.apps.changeAppSlotMode(root.apps.activeSlot, ApplicationSlot.Mode.Close);
            } else if (gestureType === Sysuiipc.Drag && gestureDirection === Sysuiipc.Bottom) {
                if (lockedGesture && internal.lockedGestureMode === ApplicationSlot.Mode.Close) {
                    root.apps.changeAppSlotMode(root.apps.activeSlot, ApplicationSlot.Mode.None);
                    return;
                }
                if (root.apps.addAppSlotSelected) {
                    root.apps.tryActivatingPrevSlot();
                }
                root.internal.arrangeModeActive = false;
            }
        }

        function handleGesture(gestureId, gestureType, gestureDirection, fingerCount, valueChange) {
            let gestureConsumed = false;
            if (internal.arrangeModeActive) {
                handleArrangeModeGesture(gestureId, gestureType, gestureDirection, fingerCount, valueChange);
                gestureConsumed = true;
            } else if (fingerCount === 2 && (gestureType === Sysuiipc.Scroll || gestureType === Sysuiipc.Swipe)) {
                if (gestureDirection === Sysuiipc.Right) {
                    root.apps.tryActivatingNextSlot(internal.arrangeModeActive, internal.availableApps.length);
                    gestureConsumed = true;
                } else if (gestureDirection === Sysuiipc.Left) {
                    root.apps.tryActivatingPrevSlot();
                    gestureConsumed = true;
                }
            } else if (fingerCount === 3 && (gestureType === Sysuiipc.Swipe || gestureType === Sysuiipc.Scroll) && gestureDirection === Sysuiipc.Top) {
                startArrangeModeGestureId = gestureId;
                root.internal.arrangeModeActive = true;
                gestureConsumed = true;
            } else if (startArrangeModeGestureId === gestureId) {
                gestureConsumed = true;
            }

            if (!gestureConsumed) {
                sendGestureToActiveApp(gestureId, gestureType, gestureDirection, fingerCount, valueChange, false);
            }
        }

        function handleGestureRelease(gestureId, gestureType, fingerCount) {
            if (internal.arrangeModeActive) {
                root.apps.finishSelectedAction(root.apps.activeSlot);
            } else if (gestureType === Sysuiipc.Pinch) {
                sendGestureToActiveApp(gestureId, gestureType, Sysuiipc.None, fingerCount, {
                    x: 0,
                    y: 0,
                    scale: 1
                }, true);
            }
        }

        function sendGestureToActiveApp(gestureId, gestureType, gestureDirection, fingerCount, valueChange, gestureReleased) {
            // forward gestures only to active app
            let activeApplication = root.apps.getSlotAppId(root.apps.activeSlot);
            if (activeApplication === "") {
                return;
            }

            var request = IntentClient.sendIntentRequest("handleGesture", activeApplication, {
                type: gestureType,
                fingerCount: fingerCount,
                direction: gestureDirection,
                valueChange: {
                    x: valueChange.x,
                    y: valueChange.y,
                    scale: valueChange.scale,
                    released: gestureReleased
                }
            });

            request.onReplyReceived.connect(function () {
                if (request.succeeded) {
                    var result = request.result;
                } else {
                    console.log("Intent request failed: " + request.errorMessage);
                }
            });
        }

        Component.onCompleted: {
            let appsList = [];
            for (let i = 0; i < ApplicationManager.count; i++) {
                const app = ApplicationManager.get(i);
                appsList = internal.addAvailableApp(app, appsList);
            }

            internal.availableApps = appsList;

            if (internal.availableApps.length > 0) {
                internal.availableAppIndex = 0;
            }
        }
        onArrangeModeActiveChanged: {
            internal.appSelectionActive = false;
            // Check if add slot is active when leaving edit mode.
            // Assign last item as active
            if (!arrangeModeActive && root.apps.activeSlot === root.apps.count && root.apps.count > 0) {
                root.apps.tryActivatingPrevSlot();
            }
        }
    }
    property string lastGesture
    readonly property alias userGuideModeActive: internal.userGuideModeActive

    signal appClusterWindowsChanged
    signal appSelectionGoDown
    signal appSelectionGoUp

    function drawUserGuideGesture(gestureType, gestureDirection, fingerCount, valueChange, animationId) {
        let id = ++internal.userGuideGestureId;
        gestureDetector.propagateGestureAnimation(id, animationId);
        internal.handleGesture(id, gestureType, gestureDirection, fingerCount, valueChange);
        if (valueChange.released) {
            internal.handleGestureRelease(id, gestureType, fingerCount);
        }
    }

}
