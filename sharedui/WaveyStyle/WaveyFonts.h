#ifndef WAVEYFONTS_H
#define WAVEYFONTS_H

#include <QFont>
#include <QObject>
#include <QtQml>

class WaveyFonts : public QObject
{
    Q_OBJECT
    QML_ELEMENT
    QML_SINGLETON

    Q_PROPERTY(QFont h1 MEMBER m_h1 READ h1 CONSTANT)
    Q_PROPERTY(QFont h4 MEMBER m_h4 READ h4 CONSTANT)
    Q_PROPERTY(QFont h6 MEMBER m_h6 READ h6 CONSTANT)
    Q_PROPERTY(QFont h7 MEMBER m_h7 READ h7 CONSTANT)
    Q_PROPERTY(QFont m MEMBER m_m READ m CONSTANT)
    Q_PROPERTY(QFont numbers MEMBER m_numbers READ numbers CONSTANT)
    Q_PROPERTY(QFont rotary_counter MEMBER m_rotary_counter READ rotary_counter CONSTANT)
    Q_PROPERTY(QFont subtitle_3 MEMBER m_subtitle_3 READ subtitle_3 CONSTANT)
    Q_PROPERTY(QFont text_3 MEMBER m_text_3 READ text_3 CONSTANT)
    Q_PROPERTY(QFont text_6 MEMBER m_text_6 READ text_6 CONSTANT)
    Q_PROPERTY(QFont speed MEMBER m_speed READ speed CONSTANT)
    Q_PROPERTY(QFont userGuideAction MEMBER m_userGuideAction READ userGuideAction CONSTANT)

public:
    explicit WaveyFonts(QObject *parent = nullptr);

    static void setUpFont(const QString &fontName, QFont *currentFont);
    void loadFontsData();

    [[nodiscard]] QFont h1() const;
    [[nodiscard]] QFont h4() const;
    [[nodiscard]] QFont h6() const;
    [[nodiscard]] QFont h7() const;
    [[nodiscard]] QFont m() const;
    [[nodiscard]] QFont numbers() const;
    [[nodiscard]] QFont rotary_counter() const;
    [[nodiscard]] QFont subtitle_3() const;
    [[nodiscard]] QFont text_3() const;
    [[nodiscard]] QFont text_6() const;
    [[nodiscard]] QFont speed() const;
    [[nodiscard]] QFont userGuideAction() const;

private:
    QFont m_h1;
    QFont m_h4;
    QFont m_h6;
    QFont m_h7;
    QFont m_m;
    QFont m_numbers;
    QFont m_rotary_counter;
    QFont m_subtitle_3;
    QFont m_text_3;
    QFont m_text_6;
    QFont m_speed;
    QFont m_userGuideAction;
};

#endif // WAVEYFONTS_H
