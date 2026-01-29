# Wavey

## Pre-requisties
At this moment no one passed through Windows environment setup thus there is only basic manual however, you can check other OS manuals for commands and try on Windows.
### Android Development Enviroment

1. Install Android Studio
2. In Android Studio run Tools -> SDK Manager
3. Install Android 11.0 - Android SDK Platfor 30 by checking box
4. In SDK Tools check:
    - Android SDK Build-Tools 33.0.0
    - NDK 23.2.8568313
5. (Optional) If you want to test application on Android emulator in Tools -> Device Manager can be created virtual device

### Qt enviroment

1. Download Qt Installer from Qt site for open - source use.
2. In Qt installer check in components to install 'Qt 6.4.0' with Android
3. After installing open Qt Creator and open Edit -> Preferences
4. Go to tab Devices -> Android
5. Choose location for 'JDK location' and 'Android SDK'
5.1 If QTCreator report issues tools, Android Studio (Tools -> SDK Manager -> SDK Tools install Android SDK Comand-line Tools
6. The rest of options should be set automatically

### Other dependencies
The Wavey applications needs two additional Qt modules: 
* [Qt Application Manager](https://doc.qt.io/QtApplicationManager/) 
* [Qt Interface Framework](https://doc.qt.io/QtInterfaceFramework/)

They need to be built from sources:
#### Windows
Prerequisites:
Make sure Perl, Python, CMake, Ninja and your compiler(e.g mingw1120) are installed and they're added to PATH.

Installing Qt Application Manager for Desktop
```
cd /c/Qt/6.4.0/Src/
git clone git@github.com:qt/qtapplicationmanager.git
cd qtapplicationmanager
git checkout 6.4
ninja
ninja install
```

Installing Qt Interface Framework for Desktop
```
cd /c/Qt/6.4.0/Src/
git clone git://code.qt.io/qt/qtinterfaceframework.git
cd qtinterfaceframework
git checkout 6.4
ninja
ninja install
```