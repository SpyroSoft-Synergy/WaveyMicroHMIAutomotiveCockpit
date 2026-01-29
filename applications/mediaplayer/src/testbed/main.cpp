#include <QGuiApplication>
#include <QQmlApplicationEngine>
#include <QDir>
#include <QQmlContext>
#include <QWindow>

int main(int argc, char *argv[])
{
    QGuiApplication app(argc, argv);
    QQmlApplicationEngine engine;
    engine.addImportPath(QDir::currentPath() + "/imports");
    engine.addImportPath(QDir::currentPath() + "/" + APPID);

    QString urlPrefix;
#ifdef Q_OS_WIN
    urlPrefix = "file:";
    qputenv("PATH", qgetenv("PATH") + QString(";" + QDir::currentPath() + "/lib").toLatin1());
#endif

    const QUrl url(urlPrefix + QDir::currentPath() + "/" + APPID + "/main.qml");
    QObject::connect(&engine, &QQmlApplicationEngine::objectCreated,
                     &app, [url](QObject *obj, const QUrl &objUrl) {
        if (!obj && url == objUrl)
            QCoreApplication::exit(-1);
    }, Qt::QueuedConnection);
    engine.load(url);

    return app.exec();
}
