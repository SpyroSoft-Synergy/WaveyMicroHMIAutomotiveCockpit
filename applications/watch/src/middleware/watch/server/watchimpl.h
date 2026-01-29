#ifndef WATCHIMPL_H
#define WATCHIMPL_H

#include "rep_watch_source.h"

using namespace com::spyro_soft::wavey::watch_iface;

class WatchImpl : public WatchSource
{
public:
    WatchImpl(QObject *parent = nullptr);
    ~WatchImpl() = default;

public Q_SLOTS:
    int currentClock() const override;
    QVariant setClock(int index) override;

private:
    bool m_currentClock;
};

#endif // WATCHIMPL_H
