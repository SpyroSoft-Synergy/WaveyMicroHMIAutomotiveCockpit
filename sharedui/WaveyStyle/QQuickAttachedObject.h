#ifndef QQUICKATTACHEDOBJECT_H
#define QQUICKATTACHEDOBJECT_H

#include <QObject>
#include <QtQml>
#include <QtGlobal>

// NOLINTBEGIN

// Code below copied from Qt sources (qtdeclarative/src/quickcontrols2impl/qquickattachedobject_p.h)
// Adjustments:
// * Removed QQuickPopup casts
// * Replaced parent change listener with parent change signal

// This file should be removed when moving to Qt 6.5 and QQuickAttachedPropertyPropagator should be used instead

class QQuickAttachedObjectPrivate;

class QQuickAttachedObject : public QObject //NOLINT
{
    Q_OBJECT

public:
    explicit QQuickAttachedObject(QObject *parent = nullptr);
    ~QQuickAttachedObject() override;

    [[nodiscard]] QList<QQuickAttachedObject *> attachedChildren() const;

    [[nodiscard]] QQuickAttachedObject *attachedParent() const;
    void setAttachedParent(QQuickAttachedObject *parent);

protected:
    void init();

    virtual void attachedParentChange(QQuickAttachedObject *newParent, QQuickAttachedObject *oldParent);

private:
    QQuickAttachedObjectPrivate *d_ptr;
    Q_DISABLE_COPY(QQuickAttachedObject)
    Q_DECLARE_PRIVATE(QQuickAttachedObject) //NOLINT
};

// NOLINTEND

#endif // QQUICKATTACHEDOBJECT_H
