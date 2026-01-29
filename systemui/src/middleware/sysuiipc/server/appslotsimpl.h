#ifndef APPSLOTSIMPL_H
#define APPSLOTSIMPL_H

#include "appslotsmodelimpl.h"
#include "rep_appslots_source.h"

class AppSlotsImpl : public AppSlotsSimpleSource
{
    Q_OBJECT

public:
    AppSlotsImpl(QObject *parent = nullptr);

    AppSlotsModelImpl *appSlotsModel() const;

    // AppSlotsSource interface
public slots:
    virtual QVariant appendSlot(const QString &name, const QString &appId) override;
    virtual QVariant setSlotName(int index, const QString &name) override;
    virtual QVariant setSlotAppId(int index, const QString &appId) override;
    virtual QVariant removeSlot(int index) override;
    virtual QVariant moveSlot(int from, int to) override;

private:
    AppSlotsModelImpl *m_appSlotsModel;
};

#endif  // APPSLOTSIMPL_H
