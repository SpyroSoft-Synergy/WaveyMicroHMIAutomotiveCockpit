#include "WaveyFonts.h"

#include <QFontDatabase>
#include <QStringList>

namespace DefaultFontParameters {
    const int PixelSize = 16;
    const QFont::Weight Weight = QFont::Normal;
}

WaveyFonts::WaveyFonts(QObject *parent) : QObject{parent}
{
    QDir font_directory(":/wavey/style/fonts");
    for (const QFileInfo &font : font_directory.entryInfoList(QStringList() << "*.ttf", QDir::Files)) {
        QFontDatabase::addApplicationFont(font.filePath());
    }

    loadFontsData();
}

void WaveyFonts::setUpFont(const QString &fontName, QFont *currentFont)
{
    QString configFilePath(":/wavey/style/style.conf");
    QSettings configFile(configFilePath, QSettings::IniFormat);
    configFile.beginGroup("Fonts/" + fontName);
    currentFont->setFamily(configFile.value("Family", "Arial").toString());
    currentFont->setWeight(qvariant_cast<QFont::Weight>(configFile.value("Weight", DefaultFontParameters::Weight)));
    currentFont->setPixelSize(configFile.value("PixelSize", DefaultFontParameters::PixelSize).toInt());
    currentFont->setLetterSpacing(QFont::AbsoluteSpacing, configFile.value("LetterSpacing", 0.0).toFloat());
    configFile.endGroup();
}

void WaveyFonts::loadFontsData()
{
    QString configFilePath(":/wavey/style/style.conf");
    if (!QFile::exists(configFilePath)) {
        qDebug() << "Config file not found!";
        return;
    }

    setUpFont("H1", &m_h1);
    setUpFont("H4", &m_h4);
    setUpFont("H6", &m_h6);
    setUpFont("H7", &m_h7);
    setUpFont("M", &m_m);
    setUpFont("Numbers", &m_numbers);
    setUpFont("RotaryCounter", &m_rotary_counter);
    setUpFont("Subtitle3", &m_subtitle_3);
    setUpFont("Text3", &m_text_3);
    setUpFont("Text6", &m_text_6);
    setUpFont("Speed", &m_speed);
    setUpFont("UserGuideAction", &m_userGuideAction);
}

QFont WaveyFonts::h1() const
{
    return m_h1;
}

QFont WaveyFonts::h4() const
{
    return m_h4;
}

QFont WaveyFonts::h6() const
{
    return m_h6;
}

QFont WaveyFonts::h7() const
{
    return m_h7;
}

QFont WaveyFonts::m() const
{
    return m_m;
}

QFont WaveyFonts::numbers() const
{
    return m_numbers;
}

QFont WaveyFonts::rotary_counter() const
{
    return m_rotary_counter;
}

QFont WaveyFonts::subtitle_3() const
{
    return m_subtitle_3;
}

QFont WaveyFonts::text_3() const
{
    return m_text_3;
}

QFont WaveyFonts::text_6() const
{
    return m_text_6;
}

QFont WaveyFonts::speed() const
{
    return m_speed;
}

QFont WaveyFonts::userGuideAction() const
{
    return m_userGuideAction;
}
