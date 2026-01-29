#include "gesturedetectorimpl.h"

GestureDetectorImpl::GestureDetectorImpl(QObject *parent) : GestureDetectorSimpleSource(parent) {}

QVariant GestureDetectorImpl::propagateGesture(int id, Sysuiipc::GestureType type, Sysuiipc::GestureDirection direction,
                                               int fingerCount, const GestureChangeValues &changeValue)
{
    if (m_previousGestureId != id) {
        m_previousGestureId = id;
        Q_EMIT gestureDetected(id, type, direction, fingerCount, changeValue);
    } else if (changeValue.released()) {
        Q_EMIT gestureReleased(id, type, fingerCount);
    } else {
        Q_EMIT gestureUpdated(id, type, direction, fingerCount, changeValue);
    }
    return true;
}

QVariant GestureDetectorImpl::propagateGestureAnimation(int id, Sysuiipc::GestureAnimation animationId)
{
    Q_EMIT gestureAnimationDetected(id, animationId);
    return true;
}

QVariant GestureDetectorImpl::propagateTouchAction(bool pressed)
{
    Q_EMIT touchActionDetected(pressed);
    return true;
}
