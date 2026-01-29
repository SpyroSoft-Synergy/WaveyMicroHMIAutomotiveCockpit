#ifndef PRESSLISTENER_H
#define PRESSLISTENER_H

#include <QtQml>

class PressListener : public QObject
{
    Q_OBJECT
    QML_ELEMENT
    QML_SINGLETON

public:
    explicit PressListener(QObject *parent = nullptr);

    Q_INVOKABLE void listenTo(QObject *obj);

signals:
    void pressed() const;
    void released() const;

protected:
    bool eventFilter(QObject *object, QEvent *event) override;
};

#endif  // PRESSLISTENER_H
