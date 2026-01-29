#include "appslotsmodelimpl.h"

AppSlotsModelImpl::AppSlotsModelImpl(QObject *parent) : QIfPagingModelSimpleSource(parent)
{
    appendSlot("Media Player", "com.spyrosoft.mediaplayer");
    Q_EMIT countChanged(QUuid{}, m_appSlots.count());
}

bool AppSlotsModelImpl::appendSlot(const QString &name, const QString &appId)
{
    auto appSlot = AppSlot{name, appId};
    m_appSlots.append(appSlot);

    emit dataChanged(QUuid(), {QVariant::fromValue(appSlot)}, m_appSlots.count() - 1, 0);
    return true;
}

bool AppSlotsModelImpl::setSlotName(int index, const QString &name)
{
    if (index < m_appSlots.count()) {
        auto &appSlot = m_appSlots[index];
        appSlot.setName(name);
        emit dataChanged(QUuid(), {QVariant::fromValue(appSlot)}, index, 1);
        return true;
    }
    return false;
}

bool AppSlotsModelImpl::setSlotAppId(int index, const QString &appId)
{
    if (index < m_appSlots.count()) {
        auto &appSlot = m_appSlots[index];
        appSlot.setAppId(appId);
        emit dataChanged(QUuid{}, {QVariant::fromValue(appSlot)}, index, 1);
        return true;
    }
    return false;
}

bool AppSlotsModelImpl::removeSlot(int index)
{
    if (index < m_appSlots.count()) {
        m_appSlots.removeAt(index);
        emit dataChanged(QUuid{}, QVariantList(), index, 1);
        return true;
    }
    return false;
}

bool AppSlotsModelImpl::moveSlot(int from, int to)
{
    if (from == to || from < 0 || to < 0 || from >= m_appSlots.size() || to >= m_appSlots.size()) {
        return false;
    }

    m_appSlots.swapItemsAt(from, to);
    return true;
}

void AppSlotsModelImpl::registerInstance(const QUuid &identifier)
{
    Q_UNUSED(identifier)
}

void AppSlotsModelImpl::unregisterInstance(const QUuid &identifier)
{
    Q_UNUSED(identifier)
}

void AppSlotsModelImpl::fetchData(const QUuid &identifier, int start, int count)
{
    Q_EMIT supportedCapabilitiesChanged(identifier, QtInterfaceFrameworkModule::SupportsGetSize);
    QVariantList list;
    int max = qMin(start + count, m_appSlots.count());
    for (int i = start; i < max; i++) {
        list.append(QVariant::fromValue(m_appSlots.at(i)));
    }

    emit dataFetched(identifier, list, start, max < m_appSlots.count());
}
