import QtQuick
import models
import com.spyro_soft.wavey.sysuiipc
import QtApplicationManager.SystemUI

ListModel {
    id: root

    readonly property alias activeSlot: internal.activeSlot
    readonly property bool addAppSlotSelected: root.activeSlot === root.count
    property Component appSlotComponent: Component {
        ApplicationSlot {
        }
    }
    readonly property int maxSlotsCount: 3
    readonly property bool modelReady: appSlots.isInitialized && appSlots.isValid
    readonly property QtObject internal: QtObject {
        id: internal

        property int activeSlot: -1
        readonly property AppSlots appSlots: AppSlots {
            id: appSlots

            onCurrentAppSlotIndexChanged: newActiveAppIndex => {
                internal.swapActiveApp(newActiveAppIndex);
            }
            onDataMoved: (from, to) => {
                root.move(from, to, 1);
            }
        }
        readonly property Connections appSlotsConnections: Connections {
            function onRowsInserted(parent, start, end) {
                root.addItemsFromModel(start, end + 1);
                internal.resetSizes();
            }

            function onRowsRemoved(parent, start, end) {
                for (var i = end; i >= start; i--) {
                    let appSlot = root.get(i).slot;
                    appSlot.stopApplication();
                    root.remove(i);
                    if (root.activeSlot === i) {
                        internal.activeSlot = -1;
                        if (i < root.count) {
                            internal.swapActiveApp(i);
                        } else {
                            root.activateSlot(i - 1);
                        }
                    }
                }
                internal.resetSizes();

                if (root.count === 0) {
                    // Special case where appSlots.currentAppSlotIndex is 0
                    // after deleting last app. It require manual update of active slot.
                    internal.activeSlot = 0;
                }
            }

            target: appSlots.appSlots
        }
        property bool inArrangeMode: false

        function handleCloseApp(appId) {
            console.log("Finishing close app process", appId);
            let index = -1;
            for (let i = 0; i < root.count; i++) {
                let appSlot = root.get(i);
                if (appSlot.slot.appId === appId) {
                    index = i;
                    break;
                }
            }
            if (index < 0) {
                console.error("Trying to close invalid app! AppId:", appId);
                return;
            }
            appSlots.removeSlot(index);
        }

        function resetSizes() {
            for (var i = 0; i < root.count; i++) {
                root.get(i).slot.size = ApplicationSlot.Size.Medium;
            }
        }

        function swapActiveApp(newActiveAppIndex) {
            if (newActiveAppIndex !== internal.activeSlot && newActiveAppIndex >= 0) {
                if (internal.activeSlot > -1 && internal.activeSlot < root.count) {
                    root.get(internal.activeSlot).slot.active = false;
                }
                if (newActiveAppIndex < root.count) {
                    root.get(newActiveAppIndex).slot.active = true;
                }
                internal.activeSlot = newActiveAppIndex;
            }
        }
    }
    readonly property bool resizeEnabled: apps.count === 2

    function activateSlot(index) {
        if (index >= 0 && index < root.count) {
            appSlots.currentAppSlotIndex = index;
        }
    }

    function addItemsFromModel(start, end) {
        const addedFromAddAppSlot = addAppSlotSelected;
        for (let i = start; i < end; i++) {
            const appSlotData = appSlots.appSlots.get(i);
            if ((i === root.count) || (i < root.count && root.get(i).slot.appId !== appSlotData.appId)) {
                var appSlot = appSlotComponent.createObject(root, {
                    "name": appSlotData.name,
                    "appId": appSlotData.appId,
                    "inArrangeMode": internal.inArrangeMode
                });
                root.insert(i, {
                    "slot": appSlot
                });
                appSlot.startApplication();
                appSlot.requestClose.connect(function (appId) {
                    internal.handleCloseApp(appId);
                });
            }
        }

        if (addedFromAddAppSlot && !addAppSlotSelected && internal.activeSlot !== -1) {
            root.get(internal.activeSlot).slot.active = true;
        } else if (root.count === 1) {
            if (appSlots.currentAppSlotIndex === 0) {
                internal.swapActiveApp(appSlots.currentAppSlotIndex);
            } else {
                appSlots.currentAppSlotIndex = 0;
            }
        }
    }

    function changeAppSlotMode(index, mode) {
        if (index < 0 || index >= root.count) {
            return;
        }
        root.get(index).slot.mode = mode;
    }

    function finishSelectedAction(index) {
        if (index < 0 || index >= root.count) {
            return;
        }

        let appSlot = root.get(index);
        // For now don't allow to remove application window
        // we shall first have logic to stop it gracefully
        switch (appSlot.slot.mode) {
        case ApplicationSlot.Mode.Close:
            // Remove is called from inside application slot
            // It is delayed to show full close animation
            appSlot.slot.closed = true;
            console.log("closing", appSlot.slot.appId);
            break;
        default:
            break;
        }
    }

    function getAppSlotMode(index) {
        if (index < 0 || index >= root.count) {
            return ApplicationSlot.Mode.None;
        }
        return root.get(index).slot.mode;
    }

    function getAppSlotSize(index) {
        if (index < 0 || index >= root.count) {
            return ApplicationSlot.Size.Medium;
        }
        return root.get(index).slot.size;
    }

    function getSlotAppId(index) {
        if (index < 0 || index >= root.count) {
            return "";
        }
        return root.get(index).slot.appId;
    }

    function getSlotByAppId(appId) {
        for (let i = 0; i < root.count; i++) {
            let appSlot = root.get(i);
            if (appSlot.slot.appId === appId) {
                return appSlot.slot;
            }
        }
        return null;
    }

    function onWindowAdded(window) {
        let appSlot = getSlotByAppId(window.application.id);
        if (appSlot !== null) {
            appSlot.windowObject = window;
        }
    }

    function setInArrangeMode(inArrangeMode) {
        for (let i = 0; i < root.count; i++) {
            let appSlot = root.get(i);
            appSlot.slot.inArrangeMode = inArrangeMode;
        }
        internal.inArrangeMode = inArrangeMode;
        if (inArrangeMode && root.count === 0) {
            tryActivatingNextSlot(true, 1);
        }
    }

    function tryActivatingNextSlot(arrangeMode = false, remainingAppCount = 0) {
        if (arrangeMode && remainingAppCount > 0 && internal.activeSlot === root.count - 1 && root.count < maxSlotsCount) {
            // Select add app slot.
            appSlots.currentAppSlotIndex = root.count;
            return;
        }

        if (root.count > 0 && internal.activeSlot < root.count - 1 || (internal.activeSlot === -1 && arrangeMode)) {
            activateSlot(root.activeSlot + 1);
        }
    }

    function tryActivatingPrevSlot() {
        if (root.count > 0 && internal.activeSlot > 0) {
            activateSlot(root.activeSlot - 1);
        }
    }

    function tryAddSlot(name, appId) {
        if (appId !== "" && getSlotByAppId(appId) === null && root.count < root.maxSlotsCount) {
            appSlots.appendSlot(name, appId);
        }
    }

    function tryMoveActiveSlotLeft() {
        if (activeSlot === 0) {
            return;
        }
        appSlots.moveSlot(activeSlot, activeSlot - 1, 1);
    }

    function tryMoveActiveSlotRight() {
        if (activeSlot >= count - 1) {
            return;
        }
        appSlots.moveSlot(activeSlot, activeSlot + 1, 1);
    }

    function tryResizingActiveApp(size) {
        if (!resizeEnabled) {
            return;
        }

        const currentSlotIndex = internal.activeSlot;
        const siblingSlotIndex = (internal.activeSlot + 1) % 2;

        switch (size) {
        case ApplicationSlot.Size.Small:
            root.get(currentSlotIndex).slot.size = size;
            root.get(siblingSlotIndex).slot.size = ApplicationSlot.Size.Large;
            break;
        case ApplicationSlot.Size.Medium:
            root.get(currentSlotIndex).slot.size = size;
            root.get(siblingSlotIndex).slot.size = size;
            break;
        case ApplicationSlot.Size.Large:
            root.get(currentSlotIndex).slot.size = size;
            root.get(siblingSlotIndex).slot.size = ApplicationSlot.Size.Small;
            break;
        default:
            console.warn("Trying to resize app slot to unkown size!");
            break;
        }
    }

    onModelReadyChanged: {
        if (modelReady && count === 0) {
            root.addItemsFromModel(0, appSlots.appSlots.count);
        }
    }
}
