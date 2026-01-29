import QtQuick
import QtQuick.Controls

import com.spyro_soft.wavey.sysuiipc

MouseArea {
    id: root

    signal requestGesture(int type, int direction)
    signal runAnimation(int animationId)

    acceptedButtons: Qt.RightButton

    onClicked: mouse => {
        animationMenu.x = mouse.x;
        animationMenu.y = mouse.y;
        animationMenu.open();
    }

    Menu {
        id: animationMenu

        Menu {
            title: "Draw animation"

            Repeater {
                delegate: MenuItem {
                    id: drawAnimationComponent

                    required property var model

                    text: Sysuiipc.gestureAnimationToString(drawAnimationComponent.model.modelData)

                    onClicked: runAnimation(drawAnimationComponent.model.modelData)
                }

                Component.onCompleted: {
                    let array = [];
                    for (var i = Sysuiipc.UnkownAnimation + 1; i < Sysuiipc.AnimationCount; i++) {
                        array.push(i);
                    }
                    model = array;
                }
            }
        }

        Menu {
            title: "Simulate animation"

            Repeater {
                delegate: MenuItem {
                    id: simulateAnimationComponent

                    required property var model

                    text: simulateAnimationComponent.model.name

                    onClicked: requestGesture(simulateAnimationComponent.model.gestureType, simulateAnimationComponent.model.gestureDirection)
                }
                model: ListModel {
                }

                Component.onCompleted: {
                    const directionalGestures = [Sysuiipc.Swipe, Sysuiipc.Drag, Sysuiipc.Scroll];
                    const directions = [Sysuiipc.Top, Sysuiipc.Left, Sysuiipc.Right, Sysuiipc.Bottom];
                    for (var i = 0; i < directionalGestures.length; i++) {
                        const gesture = directionalGestures[i];
                        for (var j = 0; j < directions.length; j++) {
                            const direction = directions[j];
                            const obj = {
                                "gestureType": gesture,
                                "gestureDirection": direction,
                                "name": Sysuiipc.gestureTypeToString(gesture) + Sysuiipc.gestureDirectionToString(direction)
                            };
                            model.append(obj);
                        }
                    }
                    const clickGestures = [Sysuiipc.Tap, Sysuiipc.DoubleTap, Sysuiipc.TapAndHold];
                    for (var i = 0; i < clickGestures.length; i++) {
                        const gesture = clickGestures[i];
                        const obj = {
                            "gestureType": gesture,
                            "gestureDirection": Sysuiipc.None,
                            "name": Sysuiipc.gestureTypeToString(gesture)
                        };
                        model.append(obj);
                    }
                }
            }
        }
    }
}
