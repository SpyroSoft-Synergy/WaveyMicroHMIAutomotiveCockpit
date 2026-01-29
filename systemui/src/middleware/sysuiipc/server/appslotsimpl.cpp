#include "appslotsimpl.h"

AppSlotsImpl::AppSlotsImpl(QObject *parent) : AppSlotsSimpleSource(parent), m_appSlotsModel(new AppSlotsModelImpl(this))
{
    setCurrentAppSlotIndex(-1);
}

AppSlotsModelImpl *AppSlotsImpl::appSlotsModel() const
{
    return m_appSlotsModel;
}

QVariant AppSlotsImpl::appendSlot(const QString &name, const QString &appId)
{
    return m_appSlotsModel->appendSlot(name, appId);
}

QVariant AppSlotsImpl::setSlotName(int index, const QString &name)
{
    return m_appSlotsModel->setSlotName(index, name);
}

QVariant AppSlotsImpl::setSlotAppId(int index, const QString &appId)
{
    return m_appSlotsModel->setSlotAppId(index, appId);
}

QVariant AppSlotsImpl::removeSlot(int index)
{
    return m_appSlotsModel->removeSlot(index);
}

QVariant AppSlotsImpl::moveSlot(int from, int to)
{
    const bool result = m_appSlotsModel->moveSlot(from, to);
    if (result) {
        emit dataMoved(from, to);
        if (from == currentAppSlotIndex()) {
            setCurrentAppSlotIndex(to);
        }
    }
    return result;
}
