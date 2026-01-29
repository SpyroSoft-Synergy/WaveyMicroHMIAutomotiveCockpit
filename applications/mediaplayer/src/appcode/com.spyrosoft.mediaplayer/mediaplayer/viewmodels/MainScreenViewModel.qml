import QtQuick
import QtQml
import com.spyro_soft.wavey.media

import wavey.gestures
import wavey.viewmodels


MediaPlayerViewModelBase {
    id: root

    readonly property QtObject priv: QtObject {
        id: p

        property bool pressAndHoldModifier: false
        property point lastPressAndHoldDragPosition: Qt.point(0, 0)
        property bool pressAndHoldDragSongProgressAction: false
        property bool pressAndHoldDragVolumeAction: false

        onPressAndHoldModifierChanged: {
            pressAndHoldDragVolumeAction = false
            pressAndHoldDragSongProgressAction = false
        }

        readonly property GesturesListener gesturesListener: GesturesListener {
            active: root.active
            onTap: (fingerCount) => {
                p.pressAndHoldModifier = false
            }

            onDoubleTap: (fingerCount) => {
                             p.pressAndHoldModifier = false
                             if (fingerCount === 1) {
                                 root.togglePlayback()
                                 return true
                             }
                             return false
                         }
            onDrag: (fingerCount, direction, valueChange) => {
                        if (fingerCount === 1 && p.pressAndHoldModifier) {
                            if (valueChange.released) {
                                p.pressAndHoldModifier = false
                                return true
                            }

                            switch(direction) {
                            case GesturesListener.Right:
                                root.advanceSongProgress(1)
                                return true
                            case GesturesListener.Left:
                                root.advanceSongProgress(-1)
                                return true
                            case GesturesListener.Top:
                                root.changeVolume(root.volume + 1)
                                return true
                            case GesturesListener.Bottom:
                                root.changeVolume(root.volume - 1)
                                return true
                            default:
                                return false
                            }
                        }
                        p.pressAndHoldModifier = false
                        return false
                    }

            onPressAndHold: (fingerCount) => {
                                if (fingerCount === 1) {
                                    p.pressAndHoldModifier = true
                                    return true
                                }
                            }

            onScroll: (fingerCount, direction) => {
                          p.pressAndHoldModifier = false
                          if (fingerCount === 1 && root.currentViewIndex === 1 || root.currentViewIndex === 2) {
                              if (direction === GesturesListener.Top) {
                                  root.prevSong()
                                  return true
                              }
                              if (direction === GesturesListener.Bottom) {
                                  root.nextSong()
                                  return true
                              }
                          }

                          if (fingerCount === 2) {
                              if (root.currentViewIndex === 0 && direction === GesturesListener.Bottom) {
                                  root.currentViewIndex = 1
                                  return true
                              }
                              if (root.currentViewIndex === 1 && direction === GesturesListener.Top) {
                                  root.currentViewIndex = 0
                                  return true
                              }
                          }
                          return false
                      }


            onSwipe: (fingerCount, direction) => {
                         p.pressAndHoldModifier = false
                         if (fingerCount === 1) {
                             if ((root.currentViewIndex === 0 || root.currentViewIndex === 1) && direction === GesturesListener.Right) {
                                 root.prevSong()
                                 return true
                             }
                             if ((root.currentViewIndex === 0 || root.currentViewIndex === 1) && direction === GesturesListener.Left) {
                                 root.nextSong()
                                 return true
                             }
                         }
                         if (fingerCount === 2) {
                             if (root.currentViewIndex === 0 && direction === GesturesListener.Bottom) {
                                 root.currentViewIndex = 1
                                 return true
                             }
                             if (root.currentViewIndex === 1 && direction === GesturesListener.Top) {
                                 root.currentViewIndex = 0
                                 return true
                             }
                         }
                         return false
                     }

        }
    }
}
