#include "appstyleimpl.h"

AppStyleImpl::AppStyleImpl(QObject *parent) : AppStyleSimpleSource{parent} {}

QVariant AppStyleImpl::propagateThemeChange(int theme)
{
    Q_EMIT themeChanged(theme);
    return true;
}
