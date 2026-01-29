#include <QFile>
#include <QFileInfo>
#include <QQmlEngine>
#include <QStandardPaths>
#include <QtAppManCommon/global.h>
#include <QtAppManCommon/logging.h>
#include <QtAppManMain/configuration.h>
#include <QtAppManMain/main.h>
#include <QtAppManManager/applicationmanager.h>
#include <QtAppManManager/sudo.h>
#include <QtAppManPackage/packageutilities.h>

#include <sysuiipcserver.h>

namespace {
const auto IS_GESTURE_SCREEN_PROPERTY = "isGestureScreen";
const auto QML_RUNTIME = "qml";
const auto ENV_VARS_KEY = "environmentVariables";
const auto ENV_VAR_EXTEND_PATH_COMMAND = "extend_path:";
#ifdef Q_OS_WINDOWS
const auto PATH_SEPARATOR = ";";
#else
const auto PATH_SEPARATOR = ":";
#endif
};  // namespace

void initMapCache()
{
    const auto cacheLocation = QStandardPaths::standardLocations(QStandardPaths::CacheLocation);
    QFile mapFile = QFile(":/maplibregllv.db");
    assert(mapFile.exists());

    const auto destinationFilePath = cacheLocation.first() + "/maplibregl.db";
    QFileInfo destinationFile = QFileInfo(destinationFilePath);

    if (destinationFile.exists()) {
        QFile fileToRemove = QFile(destinationFilePath);
        fileToRemove.remove();
        qInfo() << "Removed previous map db.";
    }

    if (mapFile.copy(destinationFilePath)) {
        QFile destinationFile = QFile(destinationFilePath);
        destinationFile.setPermissions(QFile::Permission::ReadOther | QFile::Permission::WriteOther |
                                       QFile::Permission::ReadUser | QFile::Permission::WriteUser |
                                       QFile::Permission::ReadOwner | QFile::Permission::WriteOwner |
                                       QFile::Permission::ReadGroup | QFile::Permission::WriteGroup);
        qInfo() << "Copied cache" << mapFile.fileName() << "to" << destinationFilePath;
    } else {
        qWarning() << "Initial map db copy failed." << mapFile.errorString() << destinationFilePath;
    }
}

Q_DECL_EXPORT int main(int argc, char *argv[])
{
    QCoreApplication::setApplicationName(QStringLiteral("Wavey"));
    QCoreApplication::setApplicationVersion(QStringLiteral(WAVEY_VERSION));

    QtAM::Logging::initialize(argc, argv);
    QtAM::Sudo::forkServer(QtAM::Sudo::DropPrivilegesPermanently);

    try {
        qputenv("QT_ENABLE_HIGHDPI_SCALING", "0");
        QtAM::Main applicationMain(argc, argv);

        QtAM::Configuration cfg;
        cfg.parseWithArguments(QCoreApplication::arguments());
        applicationMain.setup(&cfg);

        // configure environment variables
        const auto envVars = cfg.runtimeConfigurations().value(QML_RUNTIME).toMap().value(ENV_VARS_KEY).toMap();
        const auto envVarsKeys = envVars.keys();
        for (const auto &envVarKey : envVarsKeys) {
            auto value = envVars.value(envVarKey).toString();
            if (value.startsWith(ENV_VAR_EXTEND_PATH_COMMAND)) {
                auto originalValue = qgetenv(envVarKey.toLatin1());
                value = value.remove(ENV_VAR_EXTEND_PATH_COMMAND) +
                        (originalValue.isEmpty() ? "" : PATH_SEPARATOR + originalValue);
            }
            qputenv(envVarKey.toLatin1(), value.toLatin1());
        }

        const auto &systemProperties = QtAM::ApplicationManager::instance()->systemProperties();
        const auto isGestureScreen = systemProperties.value(IS_GESTURE_SCREEN_PROPERTY).toBool();

        if (isGestureScreen) {
            // NOLINTNEXTLINE(cppcoreguidelines-owning-memory): applicationMain owns sysUIIPCService
            auto *sysUIIPCService = new SysUIIPCServer(&applicationMain);
            sysUIIPCService->start();
        } else {
            initMapCache();
        }
        applicationMain.loadQml(cfg.loadDummyData());
        applicationMain.showWindow(cfg.fullscreen() && !cfg.noFullscreen());

        return MainBase::exec();
    } catch (const std::exception &e) {
        qCCritical(QtAM::LogSystem) << "ERROR:" << e.what();
        return 2;
    }
}
