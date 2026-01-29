#ifndef APPSTYLEIMPL_H
#define APPSTYLEIMPL_H

#include "rep_appstyle_source.h"

class AppStyleImpl : public AppStyleSimpleSource
{
    Q_OBJECT

public:
    explicit AppStyleImpl(QObject *parent = nullptr);

public slots:
    QVariant propagateThemeChange(int theme) override;
};

#endif  // APPSTYLEIMPL_H
