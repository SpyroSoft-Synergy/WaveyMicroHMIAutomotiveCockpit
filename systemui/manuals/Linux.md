# Wavey

## PRE-REQUISTIES
Following instructions are suitable for Linux OS in any variant (virtual machine/native/wsl).
- problems with VirtualBox (windows11):
    - cmd/ps as admin -> `bcdedit /set hypervisorlaunchtype off`
    - settings -> privacy&security -> windows security -> device security -> disable core isolation
    - *After last update: **Kernel DMA Protection** has been activated, VirtualBox cannot work at best performance*
- problems with wsl:
    - applications black screen:
        - install the latest intel DHC driver - [link](https://www.intel.com/content/www/us/en/download/19344/intel-graphics-windows-dch-drivers.html)
- qt 6.4.3 does not work properly as a build on target device

---

## ESSENTIAL APPLICATIONS INSTALLATION
- Install following apps:
    ```bash
    sudo apt update \
        && sudo apt upgrade -y \
        && sudo apt install -y --no-install-recommends autoconf bc build-essential checkinstall clang-tidy curl g++ gcc git \
            lcov libasound2 libatk-bridge2.0-0 libgdk-pixbuf2.0-0 libgl1-mesa-dev libglu1-mesa libgtk-3-0 libnspr4 libnss3-dev \
            libpulse0 libsqlite3-0 libstdc++6 libtool libxcb-xinerama0 libxss1 libxtst6 locales make ninja-build \
            openjdk-11-jdk openssh-client perl python3 python3-pip python3-virtualenv ruby-bundler ruby-full \
            software-properties-common sudo unzip wget zip libfontconfig1-dev libfreetype6-dev libssl-dev libx11-dev \
            libx11-xcb-dev libxext-dev libxfixes-dev libxi-dev libxrender-dev libxcb1-dev libxcb-glx0-dev \
            libxcb-keysyms1-dev libxcb-image0-dev libxcb-shm0-dev libxcb-icccm4-dev libxcb-sync-dev libxcb-xfixes0-dev \
            libxcb-shape0-dev libxcb-randr0-dev libxcb-render-util0-dev libxcb-util-dev libxcb-xinerama0-dev libxcb-xkb-dev \
            libxkbcommon-dev libxkbcommon-x11-dev zlib1g-dev spirv-tools libicu-dev
    ```
-  Get non problematic cmake version (3.24.2)
    ```bash
    sudo apt remove --purge --auto-remove cmake \
        && wget https://github.com/Kitware/CMake/releases/download/v3.24.2/cmake-3.24.2.tar.gz \
        && tar -zxvf cmake-3.24.2.tar.gz \
        && cd cmake-3.24.2 \
        && ./bootstrap \
        && make \
        && sudo make install \
        && hash -r \
        && cd .. \
        && rm cmake-3.24.2.tar.gz \
        && sudo rm -r cmake-3.24.2
    ```

---

## ANDROID
- **Minimalist** version of android sdk
    ```bash
    export WAVEY_ANDROID_SDK_TOOLS_VERSION="8512546" && \
    export WAVEY_ANDROID_NDK_VERSION="23.2.8568313" && \
    export WAVEY_ANDROID_ROOT=~/Android/Sdk \
        && wget https://dl.google.com/android/repository/commandlinetools-linux-${WAVEY_ANDROID_SDK_TOOLS_VERSION}_latest.zip \
            -O android-sdk-tools.zip \
        && unzip -q android-sdk-tools.zip \
        && rm android-sdk-tools.zip \
        && mkdir -p ${WAVEY_ANDROID_ROOT}/cmdline-tools/latest \
        && mv cmdline-tools/* ${WAVEY_ANDROID_ROOT}/cmdline-tools/latest \
        && rm -r cmdline-tools \
        && yes | ${WAVEY_ANDROID_ROOT}/cmdline-tools/latest/bin/sdkmanager --licenses \
        && ${WAVEY_ANDROID_ROOT}/cmdline-tools/latest/bin/sdkmanager "platform-tools" "platforms;android-31" "build-tools;33.0.0" "ndk;${WAVEY_ANDROID_NDK_VERSION}"
    ```
- **Full** version of android
    ```
    1. Install Android Studio (standard setup)
    2. In Welcome screen Android Studio->More Actions->SDK Manager
    3. In SDK Platform tab check: Android 11 (30)
    4. In SDK Tools check:
        - Android SDK Build-Tools 3X.X.X
        - NDK 2X.2.XXXXXXX
        - Android SDK Command-line Tools
        - Android SDK Tools (Obsolete) (uncheck "Hide obsolete Packages" first)
    5. (Optional) If you want to test application on Android emulator in Tools -> Device Manager can be created virtual device
    ```

---

## ANDROID OPENSSL
- due to changes made to the repository ([KDAB/android_openssl](https://github.com/KDAB/android_openssl)). OpenSSL is not compatible with qt android applications, so we have to download manually.
    ```bash
    cd ~/Android \
        && git clone https://github.com/KDAB/android_openssl.git \
        && cd android_openssl \
        && git reset --hard f5d857ef1d437595f7c3ab0d06e61beae7ca8b99 \
        && cd -
    ```

---

## QT
- **Requirements:**
    - Qt account
- Enter the email and password to the variables that will automatically install the needed version of QT and all the add-ons for the compilation environment
    ```bash
    export WAVEY_QT_ACCOUNT_EMAIL="" && \
    export WAVEY_QT_ACCOUNT_PASSWORD="" && \
    export WAVEY_QT_VERSION="qt6.642" && \
    export WAVEY_QT_INSTALLER_VERSION="4.5.2" \
        && wget https://d13lb3tujbc8s0.cloudfront.net/onlineinstallers/qt-unified-linux-x64-${WAVEY_QT_INSTALLER_VERSION}-online.run \
            -O qt_installer.run \
        && chmod +x qt_installer.run \
        && ./qt_installer.run \
            --email ${WAVEY_QT_ACCOUNT_EMAIL} \
            --password ${WAVEY_QT_ACCOUNT_PASSWORD} \
            --auto-answer telemetry-question=No \
            --accept-obligations \
            --accept-licenses \
            --confirm-command \
            --root ~/Qt \
            install \
                qt.${WAVEY_QT_VERSION}.gcc_64 \
                qt.${WAVEY_QT_VERSION}.android \
                qt.${WAVEY_QT_VERSION}.qtquick3d \
                qt.${WAVEY_QT_VERSION}.qt5compat \
                qt.${WAVEY_QT_VERSION}.qtshadertools \
                qt.${WAVEY_QT_VERSION}.addons.qthttpserver \
                qt.${WAVEY_QT_VERSION}.addons.qtmultimedia \
                qt.${WAVEY_QT_VERSION}.addons.qtpositioning \
                qt.${WAVEY_QT_VERSION}.addons.qtremoteobjects \
                qt.${WAVEY_QT_VERSION}.addons.qtwebsockets \
                qt.tools.openssl \
                qt.tools.openssl.src \
        && rm qt_installer.run
    ```
- Qt applications that use OpenSSL require version 1.1
    ```bash
    cd ~/Qt/Tools/OpenSSL/src \
        && ./config \
        && make \
        && sudo make install \
        && sudo ldconfig \
        && cd -
    ```
- Qt creator configuration for android build
    ```
    1. Run Qt Creator and open Edit (top bar) -> Preferences
    2. Go to tab Devices -> Android
    3. Choose location for 'JDK location' and 'Android SDK' (should be filled in automatically)
        - for JDK: /usr/lib/jvm/java-11-openjdk-amd64
        - for SDK: /home/{username}/Android/Sdk
    4. Install the additional options that qt asks for (Androids sdk's)
    ```

---

## QT MODULES
- Applications needs few additional Qt modules which has to be build from sources
- **Requirements:**
    - Access to internal gitlab: [link](https://git.spyrosoft.it)
    - Added ssh key to your account.
    - Basic git config: `user.email` and `user.name`
- Install following apps:
    - qtinterfaceframework
    - qtapplicationmanager
    - qtlocation
    ```bash
    export WAVEY_ANDROID_SDK_PATH=~/Android/Sdk && \
    export WAVEY_ANDROID_NDK_VERSION="23.2.8568313" && \
    export WAVEY_ANDROID_NDK_PATH=~/Android/Sdk/ndk/${WAVEY_ANDROID_NDK_VERSION} && \
    export WAVEY_QT_VERSION="6.4.2" && \
    export WAVEY_QT_PATH_GCC=~/Qt/${WAVEY_QT_VERSION}/gcc_64 && \
    export WAVEY_QT_PATH_ARM=~/Qt/${WAVEY_QT_VERSION}/android_arm64_v8a && \
    export WAVEY_QT_PATH_x86_64=~/Qt/${WAVEY_QT_VERSION}/android_x86_64 \
        && mkdir ~/QtModules \
        && cd ~/QtModules \
        && echo "################ Cloning repo: qtapplicationmanager [GIT] ################" \
        && git clone git://code.qt.io/qt/qtapplicationmanager.git \
        && cd qtapplicationmanager \
        && git checkout ${WAVEY_QT_VERSION} \
        && git submodule update --init --recursive \
        && mkdir build_desktop \
        && cd build_desktop \
            && echo "################ Building qtapplicationmanager [DESKTOP] ################" \
            && cmake .. \
                -DCMAKE_PREFIX_PATH:PATH=${WAVEY_QT_PATH_GCC} \
                -DCMAKE_GENERATOR:STRING=Ninja \
            && ninja \
            && sudo ninja install \
        && cd .. \
        && mkdir build_arm \
        && cd build_arm \
            && echo "################ Building qtapplicationmanager [ANDROID_arm64-v8a] ################" \
            && cmake .. \
                -DANDROID_ABI:STRING=arm64-v8a \
                -DANDROID_NDK:PATH=${WAVEY_ANDROID_NDK_PATH} \
                -DANDROID_NATIVE_API_LEVEL=31 \
                -DANDROID_SDK_ROOT:PATH=${WAVEY_ANDROID_SDK_PATH} \
                -DCMAKE_GENERATOR:STRING=Ninja \
                -DCMAKE_TOOLCHAIN_FILE:FILEPATH=${WAVEY_ANDROID_NDK_PATH}/build/cmake/android.toolchain.cmake \
                -DQT_HOST_PATH:PATH=${WAVEY_QT_PATH_GCC} \
                -DCMAKE_FIND_ROOT_PATH:PATH=${WAVEY_QT_PATH_ARM} \
                -DANDROID_STL:STRING=c++_shared \
            && ninja \
            && sudo ninja install \
        && cd .. \
            && mkdir build_x86_64 \
            && cd build_x86_64 \
            && echo "################ Building qtapplicationmanager [ANDROID_x86_64] ################" \
            && cmake .. \
                -DANDROID_ABI:STRING=x86_64 \
                -DANDROID_NDK:PATH=${WAVEY_ANDROID_NDK_PATH} \
                -DANDROID_NATIVE_API_LEVEL=31 \
                -DANDROID_SDK_ROOT:PATH=${WAVEY_ANDROID_SDK_PATH} \
                -DCMAKE_GENERATOR:STRING=Ninja \
                -DCMAKE_TOOLCHAIN_FILE:FILEPATH=${WAVEY_ANDROID_NDK_PATH}/build/cmake/android.toolchain.cmake \
                -DQT_HOST_PATH:PATH=${WAVEY_QT_PATH_GCC} \
                -DCMAKE_FIND_ROOT_PATH:PATH=${WAVEY_QT_PATH_x86_64} \
                -DANDROID_STL:STRING=c++_shared \
            && ninja \
            && sudo ninja install \
        && cd ../.. \
        && echo "################ Cloning repo: qtinterfaceframework [GIT] ################" \
        && git clone git://code.qt.io/qt/qtinterfaceframework.git \
        && cd qtinterfaceframework \
        && git checkout ${WAVEY_QT_VERSION} \
        && git submodule update --init --recursive \
        && mkdir build_desktop \
        && cd build_desktop \
            && echo "################ Building qtinterfaceframework [DESKTOP] ################" \
            && cmake .. \
                -DCMAKE_PREFIX_PATH:PATH=${WAVEY_QT_PATH_GCC} \
                -DCMAKE_GENERATOR:STRING=Ninja \
            && ninja \
            && sudo ninja install \
        && cd .. \
        && mkdir build_arm \
        && cd build_arm \
            && echo "################ Building qtinterfaceframework [ANDROID_arm64-v8a] ################" \
            && cmake .. \
                -DANDROID_ABI:STRING=arm64-v8a \
                -DANDROID_NDK:PATH=${WAVEY_ANDROID_NDK_PATH} \
                -DANDROID_NATIVE_API_LEVEL=31 \
                -DANDROID_SDK_ROOT:PATH=${WAVEY_ANDROID_SDK_PATH} \
                -DCMAKE_GENERATOR:STRING=Ninja \
                -DCMAKE_TOOLCHAIN_FILE:FILEPATH=${WAVEY_ANDROID_NDK_PATH}/build/cmake/android.toolchain.cmake \
                -DQT_HOST_PATH:PATH=${WAVEY_QT_PATH_GCC} \
                -DCMAKE_FIND_ROOT_PATH:PATH=${WAVEY_QT_PATH_ARM} \
                -DANDROID_STL:STRING=c++_shared \
            && ninja \
            && sudo ninja install \
        && cd .. \
        && mkdir build_x86_64 \
        && cd build_x86_64 \
            && echo "################ Building qtinterfaceframework [ANDROID_x86_64] ################" \
            && cmake .. \
                -DANDROID_ABI:STRING=x86_64 \
                -DANDROID_NDK:PATH=${WAVEY_ANDROID_NDK_PATH} \
                -DANDROID_NATIVE_API_LEVEL=31 \
                -DANDROID_SDK_ROOT:PATH=${WAVEY_ANDROID_SDK_PATH} \
                -DCMAKE_GENERATOR:STRING=Ninja \
                -DCMAKE_TOOLCHAIN_FILE:FILEPATH=${WAVEY_ANDROID_NDK_PATH}/build/cmake/android.toolchain.cmake \
                -DQT_HOST_PATH:PATH=${WAVEY_QT_PATH_GCC} \
                -DCMAKE_FIND_ROOT_PATH:PATH=${WAVEY_QT_PATH_x86_64} \
                -DANDROID_STL:STRING=c++_shared \
            && ninja \
            && sudo ninja install \
        && cd ../.. \
        && echo "################ Cloning repo: qtlocation [GIT] ################" \
        && git clone git://code.qt.io/qt/qtlocation.git \
        && cd qtlocation \
        && git fetch https://codereview.qt-project.org/qt/qtlocation refs/changes/87/382087/22 \
        && git checkout -b change-382087 FETCH_HEAD \
        && git submodule update --init --recursive \
        && git revert 7779e6a05cde72320e47cf4d5ebed78b9e049226 \
        && cd src/3rdparty/maplibre-gl-native \
        && git clone https://git.spyrosoft.it/snippets/8.git \
        && git apply 8/icu.patch \
        && cd - \
        && mkdir build_desktop \
        && cd build_desktop \
            && echo "################ Building qtlocation [DESKTOP] ################" \
            && cmake .. \
                -DCMAKE_PREFIX_PATH:PATH=${WAVEY_QT_PATH_GCC} \
                -DCMAKE_GENERATOR:STRING=Ninja \
                -DQT_NO_PACKAGE_VERSION_CHECK=TRUE \
            && ninja \
            && sudo ninja install \
        && cd .. \
        && mkdir build_arm \
        && cd build_arm \
            && echo "################ Building qtlocation [ANDROID_arm64-v8a] ################" \
            && cmake .. \
                -DANDROID_ABI:STRING=arm64-v8a \
                -DANDROID_NDK:PATH=${WAVEY_ANDROID_NDK_PATH} \
                -DANDROID_NATIVE_API_LEVEL=31 \
                -DANDROID_SDK_ROOT:PATH=${WAVEY_ANDROID_SDK_PATH} \
                -DCMAKE_GENERATOR:STRING=Ninja \
                -DCMAKE_TOOLCHAIN_FILE:FILEPATH=${WAVEY_ANDROID_NDK_PATH}/build/cmake/android.toolchain.cmake \
                -DQT_HOST_PATH:PATH=${WAVEY_QT_PATH_GCC} \
                -DCMAKE_FIND_ROOT_PATH:PATH=${WAVEY_QT_PATH_ARM} \
                -DANDROID_STL:STRING=c++_shared \
                -DQT_NO_PACKAGE_VERSION_CHECK=TRUE \
            && ninja \
            && sudo ninja install \
        && cd .. \
        && mkdir build_x86_64 \
        && cd build_x86_64 \
            && echo "################ Building qtlocation [ANDROID_x86_64] ################" \
            && cmake .. \
                -DANDROID_ABI:STRING=x86_64 \
                -DANDROID_NDK:PATH=${WAVEY_ANDROID_NDK_PATH} \
                -DANDROID_NATIVE_API_LEVEL=31 \
                -DANDROID_SDK_ROOT:PATH=${WAVEY_ANDROID_SDK_PATH} \
                -DCMAKE_GENERATOR:STRING=Ninja \
                -DCMAKE_TOOLCHAIN_FILE:FILEPATH=${WAVEY_ANDROID_NDK_PATH}/build/cmake/android.toolchain.cmake \
                -DQT_HOST_PATH:PATH=${WAVEY_QT_PATH_GCC} \
                -DCMAKE_FIND_ROOT_PATH:PATH=${WAVEY_QT_PATH_x86_64} \
                -DANDROID_STL:STRING=c++_shared \
                -DQT_NO_PACKAGE_VERSION_CHECK=TRUE \
            && ninja \
            && sudo ninja install \
        && cd ~
    ```

---

## CONAN
- Problems:
    - At this moment newest Conan version (2.0.1) contains bug that is not finding essential command - conan user
- Create personal token:
    - Follow instructions located [here](https://git.spyrosoft.it/hmi/wavey/conan) to create your personal token which be used for authorization
- **Requirements:**
    - gitLab user name
    - personal token
-  Enter the gitlab user name and personal token to the variables that will automatically install and configure conan application
    - please check your gcc version
    ```bash
    export WAVEY_CONAN_USER="" && \
    export WAVEY_CONAN_TOKEN="" && \
    export WAVEY_GCC_VERSION="11.3" && \
    export WAVEY_QT_VERSION="6.4.2" && \
    export WAVEY_QT_PATH_GCC=~/Qt/${WAVEY_QT_VERSION}/gcc_64 && \
    export WAVEY_QT_PATH_ARM=~/Qt/${WAVEY_QT_VERSION}/android_arm64_v8a && \
    export WAVEY_QT_PATH_x86_64=~/Qt/${WAVEY_QT_VERSION}/android_x86_64 \
        && pip install conan==1.59.0 \
        && source ~/.profile \
        && conan remote add wavey https://git.spyrosoft.it/api/v4/projects/183/packages/conan \
        && conan user ${WAVEY_CONAN_USER} -r wavey -p ${WAVEY_CONAN_TOKEN} \
        && conan config install git@git.spyrosoft.it:hmi/wavey/conan.git -sf=conan_profiles \
        && conan profile update env.CMAKE_PREFIX_PATH=${WAVEY_QT_PATH_GCC} linux \
        && conan profile update settings.compiler.version=${WAVEY_GCC_VERSION} linux \
        && conan profile update env.CMAKE_TOOLCHAIN_FILE=${WAVEY_QT_PATH_ARM}/lib/cmake/Qt6/qt.toolchain.cmake android_arm64-v8a \
        && conan profile update env.CMAKE_TOOLCHAIN_FILE=${WAVEY_QT_PATH_x86_64}/lib/cmake/Qt6/qt.toolchain.cmake android_x86_64
    ```
- Check if conan works:
    - `conan search Test* -r wavey`
        ```
        Existing package recipes:

        Test/0.1@wavey/beta
        Test/0.2@wavey/beta
        Test/0.2@wavey/stable
        Test/0.3@pno-test/beta
        Test/0.3@wavey/stable
        test_project/0.1.0
        test_project2/0.1.0
        ```
- Additionals:
    - Update Conan profile paths (depending on what build you need)
        ```
        conan profile update env.CMAKE_PREFIX_PATH=~/Qt/6.4.3/gcc_64 linux
        conan profile update env.CMAKE_TOOLCHAIN_FILE=~/Qt/6.4.3/android_x86_64/lib/cmake/Qt6 android_x86_64
        conan profile update env.CMAKE_TOOLCHAIN_FILE=~/Qt/6.4.3/android_x86/lib/cmake/Qt6 android_x86
        conan profile update env.CMAKE_TOOLCHAIN_FILE=~/Qt/6.4.3/android_arm64_v8a/lib/cmake/Qt6 android_arm64-v8a
        conan profile update env.CMAKE_TOOLCHAIN_FILE=~/Qt/6.4.3/android_armv7/lib/cmake/Qt6 android_armeabi-v7a
        ```

---

### Checking if everything is OK
1. Clone any app: `git clone https://git.spyrosoft.it/hmi/wavey/aplications/radioplayer`
1. Open Qt -> edit -> preferences -> devices, if popup appears, confirm and install
1. There should say: Android settings are OK.
1. Qt-> Open Project -> radioplayer -> CMakeLists.txt
1. If everything got set up correctly, project should build and run without errors.
