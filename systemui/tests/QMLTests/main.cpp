#include <QtQuickTest>
static bool s_importPath = qputenv("QML2_IMPORT_PATH", IMPORT_PATH);

class Setup : public QObject
{
    Q_OBJECT

public:
    Setup() {}

public slots:
    void applicationAvailable() { qDebug() << "import_path:" << s_importPath << qgetenv("QML2_IMPORT_PATH"); }
};

QUICK_TEST_MAIN_WITH_SETUP(wavey - ivi, Setup)

#include "main.moc"
