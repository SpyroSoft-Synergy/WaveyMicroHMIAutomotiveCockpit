#include "watchimpl.h"

WatchImpl::WatchImpl(QObject *parent)
    : WatchSource(parent)
{

}

int WatchImpl::currentClock() const {
    return m_currentClock;
}

QVariant WatchImpl::setClock(int index) {
    m_currentClock = index;
    emit currentClockChanged(m_currentClock);
    return true;
}
