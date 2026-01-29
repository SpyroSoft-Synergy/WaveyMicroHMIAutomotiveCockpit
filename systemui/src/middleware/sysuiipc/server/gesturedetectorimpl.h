#ifndef GESTUREDETECTORIMPL_H
#define GESTUREDETECTORIMPL_H

#include "rep_gesturedetector_source.h"

using namespace com::spyro_soft::wavey::sysuiipc;

class GestureDetectorImpl : public GestureDetectorSimpleSource
{
public:
    GestureDetectorImpl(QObject *parent = nullptr);

    // GestureDetectorSource interface
public slots:
    QVariant propagateGesture(int id, Sysuiipc::GestureType type, Sysuiipc::GestureDirection direction, int fingerCount,
                              const GestureChangeValues &changeValue) override;
    QVariant propagateGestureAnimation(int id, Sysuiipc::GestureAnimation animationId) override;
    QVariant propagateTouchAction(bool pressed) override;

private:
    int m_previousGestureId = -1;
};

#endif  // GESTUREDETECTORIMPL_H
