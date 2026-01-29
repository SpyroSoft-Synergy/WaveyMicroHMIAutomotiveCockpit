# Wavey

## Pre-requisties for macOS

### Before we start, make sure you have additional applications and libraries installed and configured. Open terminal and type:
- for Xcode Command Line Tools 
```shell
xcode-select --install
```
- for Brew package manager
```shell
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
```
- Next install following packages to prepare dev environment 
```shell
 brew install pyenv pyenv-virtualenv ninja icu4c spirv-tools xz tcl-tk
```
<span style="color: red;font-weight:bold">IMPORTANT: please fill in the correct software versions for Qt and NDK (this file can be outdated)</span>
- Update `.zshrc` file and reload terminal or type `source .zshrc`
```shell
# JAVA_HOME - from Android Studio
export JAVA_HOME="/Applications/Android Studio.app/Contents/jbr/Contents/Home/"

# Qt env
export PATH=$PATH:~/Qt/Tools/CMake/CMake.app/Contents/bin/
export Qt6_DIR=~/Qt/6.4.3/macos
export CMAKE_PREFIX_PATH=~/Qt/6.4.3/macos
export QTBUILD_VERSION=6.4.3
export NDK_ANDROID=23.1.7779620

# pyenv
export PYENV_ROOT="$HOME/.pyenv"
export PATH="$PYENV_ROOT/bin:$PATH"
export PYENV_VIRTUALENV_DISABLE_PROMPT=1
export PYENV_VIRTUALENVWRAPPER_PREFER_PYVENV="true"
eval "$(pyenv init --path)"
eval "$(pyenv init -)"
if which pyenv-virtualenv-init > /dev/null; then eval "$(pyenv virtualenv-init -)"; fi
```

### Android Development Enviroment
1. [Download and install Android Studio](https://developer.android.com/studio)
2. In Android Studio run Tools -> SDK Manager
3. Install Android 11.0 - `Android SDK Platfor 30` by checking box
4. In SDK Tools check:
    - `Android SDK Build-Tools 33.0.0`
    - `NDK 23.1.7779620`
5. (Optional) If you want to test application on Android emulator in Tools -> Device Manager can be created virtual device

### Qt enviroment
1. Download Qt Installer from Qt site for open - source use.
2. In Qt installer check in components to install `Qt 6.4.3` with Android
3. When installation has finish open `Qt Maintanance Tool.app` and install additional packages:
   - Qt Multimedia (qt maintenance tool)
   - Qt Quick 3D (qt maintenance tool)
   - Qt WebSockets (qt maintenance tool)
   - Qt Shader tool (qt maintenance tool)
   - Qt Positioning (qt maintenance tool)
   - Qt 5 Compatibility Module (qt maintenance tool)
4. After installing open Qt Creator and open Edit -> Preferences
5. Go to tab Devices -> Android
6. Choose location for 'JDK location' and 'Android SDK'
7. If QTCreator report issues tools, Android Studio (Tools -> SDK Manager -> SDK Tools install Android SDK Comand-line Tools
8. The rest of options should be set automatically

### Python environment
In terminal type following commands
```shell
cd ~/Qt
pyenv install 3.10.9
pyenv virtualenv 3.10.9 wavey
pyenv local wavey
pip install virtualenv conan==1.59 click path jinja2
```
<span style="color: red;font-weight: bold">IMPORTANT: Make sure that your OSX is using cmake from QT. When you type in terminal `which cmake` it shoud point to this from QT</span>

### Conan packages
[Whole manual](https://git.spyrosoft.it/hmi/wavey/conan/-/tree/main/)

```shell
conan remote add wavey https://git.spyrosoft.it/api/v4/projects/183/packages/conan`
conan user <Yout GitLab User Name> -r wavey -p <Your Personal Access Token>`
```

Verify if conan repo is working:
```shell
conan search Test -r wavey
```

Update conan profiles to use proper Qt version:
```shell
conan profile update env.CMAKE_TOOLCHAIN_FILE=~/Qt/$QTBUILD_VERSION/android_x86_64/lib/cmake/Qt6 android_x86_64
conan profile update env.CMAKE_TOOLCHAIN_FILE=~/Qt/$QTBUILD_VERSION/android_x86/lib/cmake/Qt6 android_x86
conan profile update env.CMAKE_TOOLCHAIN_FILE=~/Qt/$QTBUILD_VERSION/android_arm64_v8a/lib/cmake/Qt6 android_arm64-v8a
conan profile update env.CMAKE_TOOLCHAIN_FILE=~/Qt/$QTBUILD_VERSION/android_armv7/lib/cmake/Qt6 android_armeabi-v7a
```

## Other dependencies
The Wavey applications needs additionala Qt modules: 
* [Qt Application Manager](https://doc.qt.io/QtApplicationManager/) 
* [Qt Interface Framework](https://doc.qt.io/QtInterfaceFramework/)
* [Qt Http Server](https://doc.qt.io/qt-6/qthttpserver-index.html)
* [Qt Location](https://github.com/qt/qtlocation)

___They need to be built from sources___

### Installing Qt Application Manager for Desktop:
```shell
git clone git://code.qt.io/qt/qtapplicationmanager.git
cd qtapplicationmanager/
git checkout $QTBUILD_VERSION # checkout to proper Qt version
```
Build for desktop version
```shell
mkdir build_desktop && cd build_desktop
cmake .. -DCMAKE_PREFIX_PATH=$CMAKE_PREFIX_PATH
cmake --build .
cmake --install .
```

After successful build and installation create build for android version
```shell
cd ..
mkdir build_x86_64 && cd build_x86_64
cmake .. -DANDROID_ABI:STRING=x86_64 -DANDROID_NDK:PATH=~/Library/Android/sdk/ndk/$NDK_ANDROID -DANDROID_SDK_ROOT:PATH=~/Library/Android/sdk -DCMAKE_TOOLCHAIN_FILE:FILEPATH=~/Library/Android/sdk/ndk/$NDK_ANDROID/build/cmake/android.toolchain.cmake -DQT_HOST_PATH:PATH=~/Qt/$QTBUILD_VERSION/macos -DCMAKE_FIND_ROOT_PATH:PATH=~/Qt/$QTBUILD_VERSION/android_x86_64 -DANDROID_STL:STRING=c++_shared
```

### Installing Qt Interface Framework for Desktop:
```shell
git clone git://code.qt.io/qt/qtinterfaceframework.git
cd qtinterfaceframework/
git checkout $QTBUILD_VERSION # checkout to proper Qt version
git submodule init && git submodule update
```

Comment lines 634, 643, 644 in file
`qtinterfaceframework/src/interfaceframework/queryparser/qifqueryparser_p.h`

Build for desktop version
```shell
mkdir build_desktop && cd build_desktop
cmake .. -DCMAKE_PREFIX_PATH=$CMAKE_PREFIX_PATH -G "Ninja"
cmake --build .
cmake --install .
```

After successful build and installation create build for android version
```shell
cd ..
mkdir build_x86_64 && cd build_x86_64
cmake .. -DANDROID_ABI:STRING=x86_64 -DANDROID_NDK:PATH=~/Library/Android/sdk/ndk/$NDK_ANDROID -DANDROID_SDK_ROOT:PATH=~/Library/Android/sdk -DCMAKE_TOOLCHAIN_FILE:FILEPATH=~/Library/Android/sdk/ndk/$NDK_ANDROID/build/cmake/android.toolchain.cmake -DQT_HOST_PATH:PATH=~/Qt/$QTBUILD_VERSION/macos -DCMAKE_FIND_ROOT_PATH:PATH=~/Qt/$QTBUILD_VERSION/android_x86_64 -DANDROID_STL:STRING=c++_shared
```

### Installing Qt Http Server
```shell
git clone git://code.qt.io/qt/qthttpserver.git
cd qthttpserver
git checkout $QTBUILD_VERSION # same version from QT instalation
mkdir build_desktop && cd build_desktop
cmake .. -DCMAKE_PREFIX_PATH=$CMAKE_PREFIX_PATH
cmake --build .
cmake --install .
```

### Installinig Qt Location
```shell
git clone git://code.qt.io/qt/qtlocation.git
cd qtlocation
git fetch https://codereview.qt-project.org/qt/qtlocation refs/changes/87/382087/22 && git checkout -b change-382087 FETCH_HEAD
git submodule update --init --recursive
git revert 7779e6a05cde72320e47cf4d5ebed78b9e049226

# apply patch for linux build
cd ./src/3rdparty/maplibre-gl-native
git clone https://git.spyrosoft.it/snippets/8.git
git apply 8/icu.patch
cd -

mkdir build
cd build
cmake .. -DCMAKE_PREFIX_PATH=$CMAKE_PREFIX_PATH -DQT_NO_PACKAGE_VERSION_CHECK=TRUE -G "Ninja"
ninja
ninja install
```
