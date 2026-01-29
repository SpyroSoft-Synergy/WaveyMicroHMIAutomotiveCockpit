import QtQuick
import QtQml
import com.spyro_soft.wavey.radioplayer_iface

import wavey.gestures
import wavey.viewmodels

RadioPlayerViewModelBase {
    id: root

    readonly property QtObject priv: QtObject {
        id: p

        readonly property GesturesListener gesturesListener: GesturesListener {
            active: root.active

            onDoubleTap: (fingerCount) => {
                             if (fingerCount === 1) {
                                 root.togglePlayback()
                                 return true
                             }
                             return false
                         }
            onScroll: (fingerCount, direction) => {
                          if (fingerCount === 1 && root.currentViewIndex === 1) {
                              if (direction === GesturesListener.Top) {
                                  root.prevStation()
                                  return true
                              }
                              if (direction === GesturesListener.Bottom) {
                                  root.nextStation()
                                  return true
                              }
                          }
                          if (fingerCount === 2) {
                              if (root.currentViewIndex === 0 && direction === GesturesListener.Top) {
                                  root.currentViewIndex = 1
                                  return true
                              }
                              if (root.currentViewIndex === 1 && direction === GesturesListener.Bottom) {
                                  root.currentViewIndex = 0
                                  return true
                              }
                          }
                          return false
                      }

            onSwipe: (fingerCount, direction) => {
                         if (fingerCount === 1) {
                             if ((root.currentViewIndex === 0 || root.currentViewIndex === 1) && direction === GesturesListener.Right) {
                                 root.prevStation()
                                 return true
                             }
                             if ((root.currentViewIndex === 0 || root.currentViewIndex === 1) && direction === GesturesListener.Left) {
                                 root.nextStation()
                                 return true
                             }
                         }
                         if (fingerCount === 2) {
                             if (root.currentViewIndex === 0 && direction === GesturesListener.Top) {
                                 root.currentViewIndex = 1
                                 return true
                             }
                             if (root.currentViewIndex === 1 && direction === GesturesListener.Bottom) {
                                 root.currentViewIndex = 0
                                 return true
                             }
                         }
                         return false
                     }
        }
    }
}
