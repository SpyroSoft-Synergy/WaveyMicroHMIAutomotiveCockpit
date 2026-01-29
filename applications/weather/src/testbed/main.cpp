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

    const QUrl url(QDir::currentPath() + "/" + APPID + "/main.qml");
    QObject::connect(&engine, &QQmlApplicationEngine::objectCreated,
                     &app, [url](QObject *obj, const QUrl &objUrl) {
        if (!obj && url == objUrl)
            QCoreApplication::exit(-1);
    }, Qt::QueuedConnection);
    engine.rootContext()->setContextProperty("testBedPath", QDir::currentPath()  + "/imports/TestBed/TestBedWindow.qml");
    engine.load(url);

    return app.exec();
}
