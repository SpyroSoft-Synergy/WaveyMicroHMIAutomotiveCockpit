#ifndef THEMEVALUES_H
#define THEMEVALUES_H

#include <QColor>
#include <QString>

struct ThemeValues
{
    float backgroundRadius{0.0};
    QColor accentColor{};
    QColor backgroundColor{};
    QColor primaryColor{};
    QColor secondaryAccentColor{};
    QColor secondaryColor{};
    QColor sliderBackgroundColor{};
    QColor sliderGradientColor{};
    QColor separatorColor{};
    QColor cardBackgroundColor{};
    QColor overlayColor{};
    QString themeName{};
};

#endif // THEMEVALUES_H
