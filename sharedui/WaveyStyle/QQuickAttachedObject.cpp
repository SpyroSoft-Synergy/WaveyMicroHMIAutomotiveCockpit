#include "QQuickAttachedObject.h"

#include <QQuickItem>
#include <QQuickWindow>

static QQuickAttachedObject *attachedObject(const QMetaObject *type, QObject *object, bool create = false)
{
    if (object == nullptr) {
        return nullptr;
    }
    auto func = qmlAttachedPropertiesFunction(object, type);
    return qobject_cast<QQuickAttachedObject *>(qmlAttachedPropertiesObject(object, func, create));
}

static QQuickAttachedObject *findAttachedParent(const QMetaObject *type, QObject *object)
{
    QQuickItem *item = qobject_cast<QQuickItem *>(object);
    if (item != nullptr) {
        // lookup parent items and popups
        QQuickItem *parent = item->parentItem();
        while (parent != nullptr) {
            QQuickAttachedObject *attached = attachedObject(type, parent);
            if (attached != nullptr) {
                return attached;
            }

            parent = parent->parentItem();
        }

        // fallback to item's window
        QQuickAttachedObject *attached = attachedObject(type, item->window());
        if (attached != nullptr) {
            return attached;
        }
    }

    // lookup parent window
    auto *window = qobject_cast<QQuickWindow *>(object);
    if (window != nullptr) {
        auto *parentWindow = qobject_cast<QQuickWindow *>(window->parent());
        if (parentWindow != nullptr) {
            QQuickAttachedObject *attached = attachedObject(type, window);
            if (attached != nullptr) {
                return attached;
            }
        }
    }

    // fallback to engine (global)
    if (object != nullptr) {
        QQmlEngine *engine = qmlEngine(object);
        if (engine != nullptr) {
            QByteArray name = QByteArray("_q_") + type->className();
            QQuickAttachedObject *attached = engine->property(name).value<QQuickAttachedObject *>(); //NOLINT
            if (attached == nullptr) {
                attached = attachedObject(type, engine, true);
                engine->setProperty(name, QVariant::fromValue(attached));
            }
            return attached;
        }
    }

    return nullptr;
}

static QList<QQuickAttachedObject *> findAttachedChildren(const QMetaObject *type, QObject *object) //NOLINT(misc-no-recursion)
{
    QList<QQuickAttachedObject *> children;

    QQuickItem *item = qobject_cast<QQuickItem *>(object);
    if (item == nullptr) {
        auto *window = qobject_cast<QQuickWindow *>(object);
        if (window != nullptr) {
            item = window->contentItem();

            const auto &windowChildren = window->children();
            for (QObject *child : windowChildren) {
                auto *childWindow = qobject_cast<QQuickWindow *>(child);
                if (childWindow != nullptr) {
                    QQuickAttachedObject *attached = attachedObject(type, childWindow);
                    if (attached != nullptr) {
                        children += attached;
                    }
                }
            }
        }
    }

    if (item != nullptr) {
        const auto childItems = item->childItems();
        for (QQuickItem *child : childItems) {
            QQuickAttachedObject *attached = attachedObject(type, child);
            if (attached != nullptr) {
                children += attached;
            }
            else {
                // TODO(rnd): remove recursion
                children += findAttachedChildren(type, child);
            }
        }
    }

    return children;
}

static QQuickItem *findAttachedItem(QObject *parent)
{
    return qobject_cast<QQuickItem *>(parent);
}

class QQuickAttachedObjectPrivate : public QObject
{
public:
    Q_DECLARE_PUBLIC(QQuickAttachedObject) //NOLINT

    explicit QQuickAttachedObjectPrivate(QObject *parent)
        : QObject(parent)
        , q_ptr(parent)
    {
    }

    static QQuickAttachedObjectPrivate *get(QQuickAttachedObject *attachedObject)
    {
        return attachedObject->d_func();
    }

    void attachTo(QObject *object) const;
    void detachFrom(QObject *object) const;

    void itemWindowChanged(QQuickWindow *window);
    void itemParentChanged(QQuickItem *parent);

    QList<QQuickAttachedObject *> attachedChildren; //NOLINT
    QPointer<QQuickAttachedObject> attachedParent; //NOLINT

private:
    QObject *q_ptr {};
};

void QQuickAttachedObjectPrivate::attachTo(QObject *object) const
{
    QQuickItem *item = findAttachedItem(object);
    if (item != nullptr) {
        connect(item, &QQuickItem::windowChanged, this, &QQuickAttachedObjectPrivate::itemWindowChanged);
        connect(item, &QQuickItem::parentChanged, this, &QQuickAttachedObjectPrivate::itemParentChanged);
    }
}

void QQuickAttachedObjectPrivate::detachFrom(QObject *object) const
{
    QQuickItem *item = findAttachedItem(object);
    if (item != nullptr) {
        disconnect(item, &QQuickItem::windowChanged, this, &QQuickAttachedObjectPrivate::itemWindowChanged);
        disconnect(item, &QQuickItem::parentChanged, this, &QQuickAttachedObjectPrivate::itemParentChanged);
    }
}

void QQuickAttachedObjectPrivate::itemWindowChanged(QQuickWindow *window)
{
    Q_Q(QQuickAttachedObject);
    QQuickAttachedObject *attachedParent = nullptr;
    auto *item = qobject_cast<QQuickItem *>(q->sender());
    if (item != nullptr) {
        attachedParent = findAttachedParent(q->metaObject(), item);
    }
    if (attachedParent == nullptr) {
        attachedParent = attachedObject(q->metaObject(), window);
    }
    q->setAttachedParent(attachedParent);
}

void QQuickAttachedObjectPrivate::itemParentChanged(QQuickItem *parent)
{
    Q_UNUSED(parent);
    Q_Q(QQuickAttachedObject);
    q->setAttachedParent(findAttachedParent(q->metaObject(), parent));
}

QQuickAttachedObject::QQuickAttachedObject(QObject *parent)
    : QObject(parent)
    , d_ptr(new QQuickAttachedObjectPrivate(this))
{
    Q_D(QQuickAttachedObject);
    d->attachTo(parent);
}

QQuickAttachedObject::~QQuickAttachedObject()
{
    Q_D(QQuickAttachedObject);
    d->detachFrom(parent());
    setAttachedParent(nullptr);
}

QList<QQuickAttachedObject *> QQuickAttachedObject::attachedChildren() const
{
    Q_D(const QQuickAttachedObject);
    return d->attachedChildren;
}

QQuickAttachedObject *QQuickAttachedObject::attachedParent() const
{
    Q_D(const QQuickAttachedObject);
    return d->attachedParent;
}

void QQuickAttachedObject::setAttachedParent(QQuickAttachedObject *parent)
{
    Q_D(QQuickAttachedObject);
    if (d->attachedParent == parent) {
        return;
    }

    QQuickAttachedObject *oldParent = d->attachedParent;
    if (d->attachedParent != nullptr) {
        QQuickAttachedObjectPrivate::get(d->attachedParent)->attachedChildren.removeOne(this);
    }
    d->attachedParent = parent;
    if (parent != nullptr) {
        QQuickAttachedObjectPrivate::get(parent)->attachedChildren.append(this);
    }
    attachedParentChange(parent, oldParent);
}

void QQuickAttachedObject::init()
{
    QQuickAttachedObject *attachedParent = findAttachedParent(metaObject(), parent());
    if (attachedParent != nullptr) {
        setAttachedParent(attachedParent);
    }

    const QList<QQuickAttachedObject *> attachedChildren = findAttachedChildren(metaObject(), parent());
    for (QQuickAttachedObject *child : attachedChildren) {
        child->setAttachedParent(this);
    }
}

void QQuickAttachedObject::attachedParentChange(QQuickAttachedObject *newParent, QQuickAttachedObject *oldParent) //NOLINT
{
    Q_UNUSED(newParent);
    Q_UNUSED(oldParent);
}
