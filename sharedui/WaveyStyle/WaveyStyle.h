#ifndef WAVEYSTYLE_H
#define WAVEYSTYLE_H

#include "QQuickAttachedObject.h"
#include "StyleLoader.h"
#include "ThemeValues.h"

#include <QColor>
#include <QMap>
#include <QObject>
#include <QString>
#include <QtQml>

// TODO(esa) change to QQuickAttachedPropertyPropagator in 6.5
class WaveyStyle : public QQuickAttachedObject
{
    Q_OBJECT
    QML_ELEMENT
    QML_UNCREATABLE("")
    QML_ATTACHED(WaveyStyle)

    Q_PROPERTY(Theme theme READ theme WRITE setTheme NOTIFY themeChanged FINAL)
    Q_PROPERTY(QString currentThemeName READ currentThemeName NOTIFY themeChanged FINAL)
    Q_PROPERTY(float backgroundRadius READ backgroundRadius NOTIFY themeChanged FINAL)

    /* Colors */
    Q_PROPERTY(QColor primaryColor READ primaryColor WRITE setPrimary NOTIFY themeChanged FINAL)
    Q_PROPERTY(QColor accentColor READ accentColor WRITE setAccent NOTIFY themeChanged FINAL)
    Q_PROPERTY(QColor backgroundColor READ backgroundColor NOTIFY themeChanged FINAL)
    Q_PROPERTY(QColor secondaryAccentColor READ secondaryAccentColor NOTIFY themeChanged FINAL)
    Q_PROPERTY(QColor secondaryColor READ secondaryColor NOTIFY themeChanged FINAL)
    Q_PROPERTY(QColor sliderBackgroundColor READ sliderBackgroundColor NOTIFY themeChanged FINAL)
    Q_PROPERTY(QColor sliderGradientColor READ sliderGradientColor NOTIFY themeChanged FINAL)
    Q_PROPERTY(QColor separatorColor READ separatorColor NOTIFY themeChanged FINAL)
    Q_PROPERTY(QColor cardBackgroundColor READ cardBackgroundColor NOTIFY themeChanged FINAL)
    Q_PROPERTY(QColor overlayColor READ overlayColor NOTIFY themeChanged FINAL)

public:
    enum Theme {
        Dark,
        Light
    };
    Q_ENUM(Theme)

    explicit WaveyStyle(QObject *parent = nullptr);

    static WaveyStyle* qmlAttachedProperties(QObject *object);

    [[nodiscard]] Theme theme() const;
    void setTheme(Theme theme);
    void propagateTheme();
    void inheritTheme(Theme theme);

    [[nodiscard]] QString currentThemeName() const;

    [[nodiscard]] float backgroundRadius() const;

    [[nodiscard]] QColor primaryColor() const;
    void setPrimary(const QColor &color);
    void propagatePrimary();
    void inheritPrimary(const QColor &color, bool custom);

    [[nodiscard]] QColor accentColor() const;
    void setAccent(const QColor &color);
    void propagateAccent();
    void inheritAccent(const QColor &color, bool custom);

    [[nodiscard]] QColor backgroundColor() const;
    [[nodiscard]] QColor secondaryAccentColor() const;
    [[nodiscard]] QColor secondaryColor() const;
    [[nodiscard]] QColor sliderBackgroundColor() const;
    [[nodiscard]] QColor sliderGradientColor() const;
    [[nodiscard]] QColor separatorColor() const;
    [[nodiscard]] QColor cardBackgroundColor() const;
    [[nodiscard]] QColor overlayColor() const;

    Q_INVOKABLE static void setAppTheme(WaveyStyle::Theme theme);

    static QHash<Theme, QString> themeNames();
    static Theme defaultTheme();

signals:
    void themeChanged();

public slots:
    void onAppThemeChanged();

protected:
    void attachedParentChange(QQuickAttachedObject *newParent, QQuickAttachedObject *oldParent) override;

private:
    void reloadThemeValues();

    Theme m_theme;

    // Marking colors that were explicitly set on specific item.
    // That will block inheriting style from parent
    bool m_explicitTheme = false;
    bool m_explicitPrimary = false;
    bool m_explicitAccent = false;

    // Marking color that was inherited or explicitly set
    bool m_customPrimary = false;
    bool m_customAccent = false;

    QColor m_accent, m_primary;

    ThemeValues m_currentTheme {};
};

class WaveyStyleTheme : public QObject
{
    Q_OBJECT
public:
    [[nodiscard]] static WaveyStyleTheme* instance();

    [[nodiscard]] WaveyStyle::Theme theme() const;
    void setTheme(WaveyStyle::Theme theme);

    [[nodiscard]] ThemeValues themeValues(WaveyStyle::Theme theme) const;

    [[nodiscard]] WaveyStyle::Theme initialTheme();

signals:
    void themeChanged();

private:
    explicit WaveyStyleTheme(QObject *parent = nullptr);

    WaveyStyle::Theme m_theme = WaveyStyle::defaultTheme();
    StyleLoader m_styleLoader;
};

QML_DECLARE_TYPEINFO(WaveyStyle, QML_HAS_ATTACHED_PROPERTIES)

#endif // WAVEYSTYLE_H
