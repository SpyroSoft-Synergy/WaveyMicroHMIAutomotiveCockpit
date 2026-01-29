#ifndef STYLELOADER_H
#define STYLELOADER_H

#include "ThemeValues.h"

#include <QMap>
#include <QSettings>
#include <QString>

class StyleLoader
{
public:
    StyleLoader() = default;

    [[nodiscard]] ThemeValues theme(const QString &name) const;
    void loadStyleData(const QString &configFilePath, const QStringList &themeNames);
    [[nodiscard]] static QString loadThemeName(const QSettings &settings);
    static ThemeValues loadTheme(const QString &group, const QSettings &settings);

    [[nodiscard]] QString initialThemeName() const;

private:
    QString m_initialThemeName{};
    QMap<QString, ThemeValues> m_themes{};
};

#endif // STYLELOADER_H
