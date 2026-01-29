#include "WaveyStyle.h"

WaveyStyle::WaveyStyle(QObject *parent)
    : QQuickAttachedObject{parent}
    , m_theme(WaveyStyleTheme::instance()->initialTheme())
{
    connect(WaveyStyleTheme::instance(), &WaveyStyleTheme::themeChanged, this, &WaveyStyle::onAppThemeChanged);
    reloadThemeValues();

    QQuickAttachedObject::init();
}

WaveyStyle *WaveyStyle::qmlAttachedProperties(QObject *object)
{
    return new WaveyStyle(object); //NOLINT
}

WaveyStyle::Theme WaveyStyle::theme() const
{
    return m_theme;
}

void WaveyStyle::setTheme(Theme theme)
{
    m_explicitTheme = true;
    if (m_theme == theme) {
        return;
    }
    m_theme = theme;
    reloadThemeValues();
    emit themeChanged();
}

void WaveyStyle::propagateTheme() //NOLINT(misc-no-recursion)
{
    const auto styles = attachedChildren();
    for (QQuickAttachedObject *child : styles) {
        auto *style = qobject_cast<WaveyStyle*>(child);
        if (style != nullptr) {
            style->inheritTheme(m_theme);
        }
    }
}

void WaveyStyle::inheritTheme(Theme theme) //NOLINT(misc-no-recursion)
{
    if (m_explicitTheme || m_theme == theme) {
        return;
    }

    m_theme = theme;
    reloadThemeValues();
    propagateTheme();
    emit themeChanged();
}

float WaveyStyle::backgroundRadius() const
{
    return m_currentTheme.backgroundRadius;
}

QColor WaveyStyle::primaryColor() const
{
    return m_customPrimary ? m_primary : m_currentTheme.primaryColor;
}

void WaveyStyle::setPrimary(const QColor &color)
{
    m_explicitPrimary = true;
    m_customPrimary = true;
    if (m_primary == color) {
        return;
    }
    m_primary = color;
    emit themeChanged();
}

void WaveyStyle::propagatePrimary() //NOLINT(misc-no-recursion)
{
    const auto styles = attachedChildren();
    for (QQuickAttachedObject *child : styles) {
        auto *style = qobject_cast<WaveyStyle *>(child);
        if (style != nullptr) {
            style->inheritPrimary(m_primary, m_customPrimary);
        }
    }
}

void WaveyStyle::inheritPrimary(const QColor &color, bool custom) //NOLINT(misc-no-recursion)
{
    if (m_explicitPrimary || m_primary == color) {
        return;
    }

    m_customPrimary = custom;
    m_primary = color;
    propagatePrimary();
    emit themeChanged();
}

QColor WaveyStyle::accentColor() const
{
    return m_customAccent ? m_accent : m_currentTheme.accentColor;
}

void WaveyStyle::setAccent(const QColor &color)
{
    m_explicitAccent = true;
    m_customAccent = true;
    if (m_accent == color) {
        return;
    }
    m_accent = color;
    emit themeChanged();
}

void WaveyStyle::propagateAccent() //NOLINT(misc-no-recursion)
{
    const auto styles = attachedChildren();
    for (QQuickAttachedObject *child : styles) {
        auto *style = qobject_cast<WaveyStyle*>(child);
        if (style != nullptr) {
            style->inheritAccent(m_accent, m_customAccent);
        }
    }
}

void WaveyStyle::inheritAccent(const QColor &color, bool custom) //NOLINT(misc-no-recursion)
{
    if (m_explicitAccent || m_accent == color) {
        return;
    }

    m_customAccent = custom;
    m_accent = color;
    propagateAccent();
    emit themeChanged();
}

QColor WaveyStyle::backgroundColor() const
{
    return m_currentTheme.backgroundColor;
}

QColor WaveyStyle::secondaryAccentColor() const
{
    return m_currentTheme.secondaryAccentColor;
}

QColor WaveyStyle::secondaryColor() const
{
    return m_currentTheme.secondaryColor;
}

QColor WaveyStyle::sliderBackgroundColor() const
{
    return m_currentTheme.sliderBackgroundColor;
}

QColor WaveyStyle::sliderGradientColor() const
{
    return m_currentTheme.sliderGradientColor;
}

QColor WaveyStyle::separatorColor() const
{
    return m_currentTheme.separatorColor;
}

QColor WaveyStyle::cardBackgroundColor() const
{
    return m_currentTheme.cardBackgroundColor;
}

QColor WaveyStyle::overlayColor() const
{
    return m_currentTheme.overlayColor;
}

QString WaveyStyle::currentThemeName() const
{
    return themeNames().value(m_theme);
}

void WaveyStyle::setAppTheme(Theme theme)
{
    WaveyStyleTheme::instance()->setTheme(theme);
}

QHash<WaveyStyle::Theme, QString> WaveyStyle::themeNames()
{
    static const QHash<Theme, QString> names {
        { Dark, "Dark" },
        { Light, "Light" }
    };
    return names;
}

WaveyStyle::Theme WaveyStyle::defaultTheme()
{
    return Dark;
}

void WaveyStyle::onAppThemeChanged()
{
    const Theme newTheme = WaveyStyleTheme::instance()->theme();
    if (m_explicitTheme || m_theme == newTheme) {
        return;
    }
    m_theme = newTheme;
    reloadThemeValues();
    emit themeChanged();
}

void WaveyStyle::attachedParentChange(QQuickAttachedObject *newParent, QQuickAttachedObject *oldParent) //NOLINT
{
    Q_UNUSED(oldParent)
    auto *style = qobject_cast<WaveyStyle*>(newParent);
    if (style != nullptr) {
        inheritPrimary(style->m_primary, style->m_customPrimary);
        inheritAccent(style->m_accent, style->m_customAccent);
        inheritTheme(style->theme());
    }
}

void WaveyStyle::reloadThemeValues()
{
    m_currentTheme = WaveyStyleTheme::instance()->themeValues(m_theme);
}

WaveyStyleTheme::WaveyStyleTheme(QObject *parent) : QObject(parent)
{
    const QString configFilePath(":/wavey/style/style.conf");
    m_styleLoader.loadStyleData(configFilePath, WaveyStyle::themeNames().values());
}

WaveyStyleTheme *WaveyStyleTheme::instance()
{
    static WaveyStyleTheme theme;
    return &theme;
}

WaveyStyle::Theme WaveyStyleTheme::theme() const
{
    return m_theme;
}

void WaveyStyleTheme::setTheme(WaveyStyle::Theme theme)
{
    if (theme == m_theme) {
        return;
    }
    m_theme = theme;
    emit themeChanged();
}

ThemeValues WaveyStyleTheme::themeValues(WaveyStyle::Theme theme) const
{
    return m_styleLoader.theme(WaveyStyle::themeNames().value(theme));
}

WaveyStyle::Theme WaveyStyleTheme::initialTheme()
{
    const QString &name = m_styleLoader.initialThemeName();
    if (name.isEmpty()) {
        return WaveyStyle::defaultTheme();
    }
    return WaveyStyle::themeNames().key(name);
}
