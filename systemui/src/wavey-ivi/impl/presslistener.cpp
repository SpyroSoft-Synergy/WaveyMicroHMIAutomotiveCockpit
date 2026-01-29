#include "presslistener.h"

#include <QEvent>

PressListener::PressListener(QObject *parent) : QObject{parent} {}

void PressListener::listenTo(QObject *obj)
{
    if (obj == nullptr) {
        return;
    }
    obj->installEventFilter(this);
}

bool PressListener::eventFilter(QObject *object, QEvent *event)
{
    Q_UNUSED(object)
    if (event->type() == QEvent::MouseButtonPress || event->type() == QEvent::TouchBegin) {
        emit pressed();
    } else if (event->type() == QEvent::MouseButtonRelease || event->type() == QEvent::TouchEnd ||
               event->type() == QEvent::TouchCancel) {
        emit released();
    }
    return false;
}
