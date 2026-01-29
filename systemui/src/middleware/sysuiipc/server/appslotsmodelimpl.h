#ifndef APPSLOTSMODELIMPL_H
#define APPSLOTSMODELIMPL_H

#include "appslot.h"

#include <QVector>
#include <QtIfRemoteObjectsHelper/rep_qifpagingmodel_source.h>

using namespace com::spyro_soft::wavey::sysuiipc;
class AppSlotsModelImpl : public QIfPagingModelSimpleSource
{
    Q_OBJECT

public:
    AppSlotsModelImpl(QObject *parent = nullptr);

    bool appendSlot(const QString &name, const QString &appId);
    bool setSlotName(int index, const QString &name);
    bool setSlotAppId(int index, const QString &appId);
    bool removeSlot(int index);
    bool moveSlot(int from, int to);

    // QIfPagingModelSource interface
public slots:
    void registerInstance(const QUuid &identifier) override;
    void unregisterInstance(const QUuid &identifier) override;
    void fetchData(const QUuid &identifier, int start, int count) override;

private:
    QVector<AppSlot> m_appSlots;
};

#endif  // APPSLOTSMODELIMPL_H
