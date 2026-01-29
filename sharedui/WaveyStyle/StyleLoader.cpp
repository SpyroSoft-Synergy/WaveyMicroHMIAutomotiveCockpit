#include "StyleLoader.h"

#include <QDir>
#include <QFontDatabase>
#include <QQuickStyle>

ThemeValues StyleLoader::theme(const QString &name) const
{
    return m_themes.value(name);
}

void StyleLoader::loadStyleData(const QString &configFilePath, const QStringList &themeNames)
{
    if (!QFile::exists(configFilePath)) {
        qDebug() << "Config file not found under path: " << configFilePath;
        m_initialThemeName = QString();
        return;
    }

    QSettings settings(configFilePath, QSettings::IniFormat);
    m_initialThemeName = StyleLoader::loadThemeName(settings);
    qDebug() << "Configured theme name: " << m_initialThemeName;

    for (const auto &theme : themeNames) {
        settings.beginGroup(theme);
        m_themes.insert(theme, loadTheme(theme, settings));
        settings.endGroup();
    }
}

QString StyleLoader::loadThemeName(const QSettings &settings)
{
    if (settings.contains("Theme")) {
        return settings.value("Theme").toString();
    }
    return {};
}

ThemeValues StyleLoader::loadTheme(const QString &group, const QSettings &settings)
{
    ThemeValues theme;
    theme.themeName = group;
    theme.backgroundRadius = settings.value("BackgroundRadius").toFloat();
    theme.accentColor = QColor::fromString(settings.value("AccentColor").toString());
    theme.backgroundColor = QColor::fromString(settings.value("BackgroundColor").toString());
    theme.primaryColor = QColor::fromString(settings.value("PrimaryColor").toString());
    theme.secondaryAccentColor = QColor::fromString(settings.value("SecondaryAccentColor").toString());
    theme.secondaryColor = QColor::fromString(settings.value("SecondaryColor").toString());
    theme.sliderBackgroundColor = QColor::fromString(settings.value("SliderBackgroundColor").toString());
    theme.sliderGradientColor = QColor::fromString(settings.value("SliderGradientColor").toString());
    theme.separatorColor = QColor::fromString(settings.value("SeparatorColor").toString());
    theme.cardBackgroundColor = QColor::fromString(settings.value("CardBackgroundColor").toString());
    theme.overlayColor = QColor::fromString(settings.value("OverlayColor").toString());

    return theme;
}

QString StyleLoader::initialThemeName() const
{
    return m_initialThemeName;
}
