# Wavey

## Pre-requisties

Environment setup OS dependent manuals:
- [Linux](/manuals/Linux.md)
- [Macos](/manuals/Macos.md)
- [Windows](/manuals/Windows.md)


## Running application

### Pre build steps
1. Install (or check) python modules: click and path
```
pip install --user click path
```

### Qt Creator

To run the project in Qt Creator choose option 'File -> Open file or project' and choose file <REPO_LOCATION>/CMakeLists.txt.
Choose kit with which you want build the application (Desktop and Android).

<span style="color: red"> IMPORTANT:</span> If You are using Macos please follow these steps before You will run project in Qt Creator 

#### Step only if You are using Macos
Before we run the project in Qt Creator we need open and modify conanfile.txt file in project which we would like to run. We should find this file in
```
~/src/testbed/conanfile.txt 
```
When we open we should replace:
```
lib,*.so -> .
lib,*.dll -> .
```
to
```
lib,*.dylib* -> .
```

### Desktop
To run the application on desktop the kit for desktop should be chosen. In tab Projects modify Run options in Destkop kit options.
As command line arguments insert:
- ` --no-cache --config-file wavey-common-config.yaml --config-file wavey-gesture-config-desktop.yaml --disable-installer --verbose --recreate-database --clear-cache ` - for gesture application
- ` --no-cache --config-file wavey-common-config.yaml --config-file wavey-main-config-desktop.yaml --disable-installer --verbose --recreate-database --clear-cache ` - for main application

In command line arguments there are YAML files which are used by Application Manager as configuration.

### Android
To run the application on Android the kit for device architecture should be chosen.

- for running in emulator provided by Android Studio choose x86 or x86_64 depending if emulating device has 32 or 64 bits architecture
- for running in Android Auto on Qualcomm hardware choose arm64_v8a

In build options correct SDK version should be chosen for which we want build the application (SDK 30 in case of used Android Auto 11 on hardware) in 'Build Android APK' step.

In command line arguments there are YAML files which are used by Application Manager as configuration. Command line arguments are given in `src/wavey-ivi/android/AndroidManifest.xml` file. 
There is one manifest file for two applications, they are being run in the same APK package. Each application will be shown on assigned screen, when deployed to Quallcomm.

Testing on emulator is also possible. In emulator device settings, a secondary display has to be added (tab 'Displays' in Extended Controls, option 'Add secondary display'). After deploying the Wavey application, it has to be set as default home application (Settings -> Apps & notifications -> Default applications -> Home app). After rebooting of the emulator, application should be working on two screens (one for Main Screen and second for Gesture Screen).

### Unit tests
The nit tests for QML files are in catalog `src/wavey-ivi/assets/test`. They are being built with the source code. To run the test choose 'qmlTestRunner' as configuration to run in Qt Cretor or run executable `<build_directory>/src/wavey-ivi/qmlTestRunner`. The command lines arguments has to be given `-import <build_directory>/src/wavey-ivi/sysUI -import <build_directory>/src/wavey-ivi/qml-plugins` for importing QML files to test.

### Static code analysis
To perform static analysis clang-tidy for C++ code and qmllint for QML files

#### clang-tidy
To run build with static analysis of C++ code, value for CMake (`ENABLE_CLANG_TIDY`) has to be defined. In Qt Creator in build settings it can be add in configuration values or in terminal execute commands:
```
cmake <SRC_DIR> -DCMAKE_PREFIX_PATH:PATH=~/Qt/6.4.0/gcc_64 -DCMAKE_GENERATOR:STRING=Ninja -DENABLE_CLANG_TIDY:BOOL=ON
cmake --build .
```

The checks for Clang-tidy are defined in `src/wavey-ivi/.clang-tidy`. If check is not applicable for the project, it can be disabled by adding name with sign '-' before to 'Checks' string.
For example: '-modernize-use-trailing-return-type'

#### qmllint
To run qmllint run target created by CMake - `qmllint`. In Qt Creator target can be enabled in build settings by checking this target in build step. 
It also can be run in terminal by command `ninja qmllint` in build directory.

#### checkstyle (linter for Java)
There is also available linter jor Java code. In CI there is used checkstyle program (can be downloaded here: https://checkstyle.org/).
Commands to execute locally:
```
java -jar checkstyle-<VERSION_NUMBER>-all.jar -c /sun_checks.xml src/wavey-ivi/android/src/com/spyrosoft/wavey/*.java
java -jar checkstyle-<VERSION_NUMBER>-all.jar -c /google_checks.xml src/wavey-ivi/android/src/com/spyrosoft/wavey/*.java
```
