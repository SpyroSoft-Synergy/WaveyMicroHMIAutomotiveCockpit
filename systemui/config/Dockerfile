FROM ubuntu:jammy

USER root

ENV TZ=Europe/Warsaw
RUN ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone

RUN apt update \
    && apt upgrade -y \
    && apt install -y --no-install-recommends autoconf bc build-essential checkinstall clang-tidy curl g++ gcc git \
        lcov libasound2 libatk-bridge2.0-0 libgdk-pixbuf2.0-0 libgl1-mesa-dev libglu1-mesa libgtk-3-0 libnspr4 libnss3-dev \
        libpulse0 libsqlite3-0 libstdc++6 libtool libxcb-xinerama0 libxss1 libxtst6 locales make ninja-build \
        openjdk-11-jdk openssh-client perl python3 python3-pip python3-virtualenv ruby-bundler ruby-full \
        software-properties-common sudo unzip wget zip libfontconfig1-dev libfreetype6-dev libssl-dev libx11-dev \
        libx11-xcb-dev libxext-dev libxfixes-dev libxi-dev libxrender-dev libxcb1-dev libxcb-glx0-dev \
        libxcb-keysyms1-dev libxcb-image0-dev libxcb-shm0-dev libxcb-icccm4-dev libxcb-sync-dev libxcb-xfixes0-dev \
        libxcb-shape0-dev libxcb-randr0-dev libxcb-render-util0-dev libxcb-util-dev libxcb-xinerama0-dev libxcb-xkb-dev \
        libxkbcommon-dev libxkbcommon-x11-dev zlib1g-dev spirv-tools libicu-dev

# git
RUN git config --global user.name developer \
    && git config --global user.email developer@dev.com

# CMake 3.24.2
RUN apt remove --purge --auto-remove cmake \
    && wget https://github.com/Kitware/CMake/releases/download/v3.24.2/cmake-3.24.2.tar.gz \
    && tar -zxvf cmake-3.24.2.tar.gz \
    && cd cmake-3.24.2 \
    && ./bootstrap \
    && make \
    && make install \
    && hash -r \
    && cd .. \
    && rm cmake-3.24.2.tar.gz \
    && rm -r cmake-3.24.2

ARG WAVEY_QT_ACCOUNT_EMAIL
ARG WAVEY_QT_ACCOUNT_PASSWORD

ENV WAYVE_SDK_ROOT=/sdk
ENV WAVEY_QT_ROOT=${WAYVE_SDK_ROOT}/Qt
ENV WAVEY_QT_INSTALLER_VERSION="4.5.2"
ENV WAVEY_QT_COMPONENT_VERSION="qt6.642"
ENV WAVEY_QT_VERSION="6.4.2"
ENV WAVEY_QT_PATH_GCC=${WAVEY_QT_ROOT}/${WAVEY_QT_VERSION}/gcc_64
ENV WAVEY_QT_PATH_ARM=${WAVEY_QT_ROOT}/${WAVEY_QT_VERSION}/android_arm64_v8a
ENV WAVEY_QT_PATH_x86_64=${WAVEY_QT_ROOT}/${WAVEY_QT_VERSION}/android_x86_64
ENV WAVEY_QT_MODULES_ROOT=${WAYVE_SDK_ROOT}/QtModules
ENV WAVEY_ANDROID_SDK_ROOT=${WAYVE_SDK_ROOT}/Android/Sdk
ENV WAVEY_ANDROID_SDK_TOOLS_VERSION="8512546"
ENV WAVEY_ANDROID_NDK_VERSION="23.2.8568313"
ENV WAVEY_ANDROID_NDK_PATH=${WAVEY_ANDROID_SDK_ROOT}/ndk/${WAVEY_ANDROID_NDK_VERSION}

# android sdk/ndk (cmdline tools)
RUN cd /tmp \
    && wget https://dl.google.com/android/repository/commandlinetools-linux-${WAVEY_ANDROID_SDK_TOOLS_VERSION}_latest.zip \
        -O android-sdk-tools.zip \
    && unzip -q android-sdk-tools.zip \
    && rm android-sdk-tools.zip \
    && mkdir -p ${WAVEY_ANDROID_SDK_ROOT}/cmdline-tools/latest \
    && mv cmdline-tools/* ${WAVEY_ANDROID_SDK_ROOT}/cmdline-tools/latest \
    && rm -r cmdline-tools \
    && yes | ${WAVEY_ANDROID_SDK_ROOT}/cmdline-tools/latest/bin/sdkmanager --licenses \
    && ${WAVEY_ANDROID_SDK_ROOT}/cmdline-tools/latest/bin/sdkmanager "platform-tools" "platforms;android-31" "build-tools;33.0.0" "ndk;${WAVEY_ANDROID_NDK_VERSION}"

# android_openssl
RUN cd ${WAVEY_ANDROID_SDK_ROOT} \
    && git clone https://github.com/KDAB/android_openssl.git \
    && cd android_openssl \
    && git reset --hard f5d857ef1d437595f7c3ab0d06e61beae7ca8b99

# Qt
RUN cd /tmp \
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
        --root ${WAVEY_QT_ROOT} \
        install \
            qt.${WAVEY_QT_COMPONENT_VERSION}.gcc_64 \
            qt.${WAVEY_QT_COMPONENT_VERSION}.android \
            qt.${WAVEY_QT_COMPONENT_VERSION}.qtquick3d \
            qt.${WAVEY_QT_COMPONENT_VERSION}.qt5compat \
            qt.${WAVEY_QT_COMPONENT_VERSION}.qtshadertools \
            qt.${WAVEY_QT_COMPONENT_VERSION}.addons.qthttpserver \
            qt.${WAVEY_QT_COMPONENT_VERSION}.addons.qtmultimedia \
            qt.${WAVEY_QT_COMPONENT_VERSION}.addons.qtpositioning \
            qt.${WAVEY_QT_COMPONENT_VERSION}.addons.qtremoteobjects \
            qt.${WAVEY_QT_COMPONENT_VERSION}.addons.qtwebsockets \
            qt.tools.openssl \
            qt.tools.openssl.src \
    && rm qt_installer.run

# QtModules - qtapplicationmanager
RUN mkdir ${WAVEY_QT_MODULES_ROOT} \
    && cd ${WAVEY_QT_MODULES_ROOT} \
    && git clone git://code.qt.io/qt/qtapplicationmanager.git \
    && cd qtapplicationmanager \
    && git checkout ${WAVEY_QT_VERSION} \
    && git submodule update --init --recursive \
    && mkdir build_desktop \
    && cd build_desktop \
    && cmake .. \
        -DCMAKE_PREFIX_PATH:PATH=${WAVEY_QT_PATH_GCC} \
        -DCMAKE_GENERATOR:STRING=Ninja \
    && ninja \
    && ninja install \
    && cd .. \
    && mkdir build_arm \
    && cd build_arm \
    && cmake .. \
        -DANDROID_ABI:STRING=arm64-v8a \
        -DANDROID_NDK:PATH=${WAVEY_ANDROID_NDK_PATH} \
        -DANDROID_NATIVE_API_LEVEL=31 \
        -DANDROID_SDK_ROOT:PATH=${WAVEY_ANDROID_SDK_ROOT} \
        -DCMAKE_GENERATOR:STRING=Ninja \
        -DCMAKE_TOOLCHAIN_FILE:FILEPATH=${WAVEY_ANDROID_NDK_PATH}/build/cmake/android.toolchain.cmake \
        -DQT_HOST_PATH:PATH=${WAVEY_QT_PATH_GCC} \
        -DCMAKE_FIND_ROOT_PATH:PATH=${WAVEY_QT_PATH_ARM} \
        -DANDROID_STL:STRING=c++_shared \
    && ninja \
    && ninja install \
    && cd .. \
    && mkdir build_x86_64 \
    && cd build_x86_64 \
    && cmake .. \
        -DANDROID_ABI:STRING=x86_64 \
        -DANDROID_NDK:PATH=${WAVEY_ANDROID_NDK_PATH} \
        -DANDROID_NATIVE_API_LEVEL=31 \
        -DANDROID_SDK_ROOT:PATH=${WAVEY_ANDROID_SDK_ROOT} \
        -DCMAKE_GENERATOR:STRING=Ninja \
        -DCMAKE_TOOLCHAIN_FILE:FILEPATH=${WAVEY_ANDROID_NDK_PATH}/build/cmake/android.toolchain.cmake \
        -DQT_HOST_PATH:PATH=${WAVEY_QT_PATH_GCC} \
        -DCMAKE_FIND_ROOT_PATH:PATH=${WAVEY_QT_PATH_x86_64} \
        -DANDROID_STL:STRING=c++_shared \
    && ninja \
    && ninja install

# QtModules - qtinterfaceframework
RUN cd ${WAVEY_QT_MODULES_ROOT} \
    && git clone git://code.qt.io/qt/qtinterfaceframework.git \
    && cd qtinterfaceframework \
    && git checkout ${WAVEY_QT_VERSION} \
    && git submodule update --init --recursive \
    && mkdir build_desktop \
    && cd build_desktop \
    && cmake .. \
        -DCMAKE_PREFIX_PATH:PATH=${WAVEY_QT_PATH_GCC} \
        -DCMAKE_GENERATOR:STRING=Ninja \
    && ninja \
    && ninja install \
    && cd .. \
    && mkdir build_arm \
    && cd build_arm \
    && cmake .. \
        -DANDROID_ABI:STRING=arm64-v8a \
        -DANDROID_NDK:PATH=${WAVEY_ANDROID_NDK_PATH} \
        -DANDROID_NATIVE_API_LEVEL=31 \
        -DANDROID_SDK_ROOT:PATH=${WAVEY_ANDROID_SDK_ROOT} \
        -DCMAKE_GENERATOR:STRING=Ninja \
        -DCMAKE_TOOLCHAIN_FILE:FILEPATH=${WAVEY_ANDROID_NDK_PATH}/build/cmake/android.toolchain.cmake \
        -DQT_HOST_PATH:PATH=${WAVEY_QT_PATH_GCC} \
        -DCMAKE_FIND_ROOT_PATH:PATH=${WAVEY_QT_PATH_ARM} \
        -DANDROID_STL:STRING=c++_shared \
    && ninja \
    && ninja install \
    && cd .. \
    && mkdir build_x86_64 \
    && cd build_x86_64 \
    && cmake .. \
        -DANDROID_ABI:STRING=x86_64 \
        -DANDROID_NDK:PATH=${WAVEY_ANDROID_NDK_PATH} \
        -DANDROID_NATIVE_API_LEVEL=31 \
        -DANDROID_SDK_ROOT:PATH=${WAVEY_ANDROID_SDK_ROOT} \
        -DCMAKE_GENERATOR:STRING=Ninja \
        -DCMAKE_TOOLCHAIN_FILE:FILEPATH=${WAVEY_ANDROID_NDK_PATH}/build/cmake/android.toolchain.cmake \
        -DQT_HOST_PATH:PATH=${WAVEY_QT_PATH_GCC} \
        -DCMAKE_FIND_ROOT_PATH:PATH=${WAVEY_QT_PATH_x86_64} \
        -DANDROID_STL:STRING=c++_shared \
    && ninja \
    && ninja install

# QtModules - qtlocation
RUN cd ${WAVEY_QT_MODULES_ROOT} \
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
    && cmake .. \
        -DCMAKE_PREFIX_PATH:PATH=${WAVEY_QT_PATH_GCC} \
        -DCMAKE_GENERATOR:STRING=Ninja \
        -DQT_NO_PACKAGE_VERSION_CHECK=TRUE \
    && ninja \
    && ninja install \
    && cd .. \
    && mkdir build_arm \
    && cd build_arm \
    && cmake .. \
        -DANDROID_ABI:STRING=arm64-v8a \
        -DANDROID_NDK:PATH=${WAVEY_ANDROID_NDK_PATH} \
        -DANDROID_NATIVE_API_LEVEL=31 \
        -DANDROID_SDK_ROOT:PATH=${WAVEY_ANDROID_SDK_ROOT} \
        -DCMAKE_GENERATOR:STRING=Ninja \
        -DCMAKE_TOOLCHAIN_FILE:FILEPATH=${WAVEY_ANDROID_NDK_PATH}/build/cmake/android.toolchain.cmake \
        -DQT_HOST_PATH:PATH=${WAVEY_QT_PATH_GCC} \
        -DCMAKE_FIND_ROOT_PATH:PATH=${WAVEY_QT_PATH_ARM} \
        -DANDROID_STL:STRING=c++_shared \
        -DQT_NO_PACKAGE_VERSION_CHECK=TRUE \
    && ninja \
    && ninja install \
    && cd .. \
    && mkdir build_x86_64 \
    && cd build_x86_64 \
    && cmake .. \
        -DANDROID_ABI:STRING=x86_64 \
        -DANDROID_NDK:PATH=${WAVEY_ANDROID_NDK_PATH} \
        -DANDROID_NATIVE_API_LEVEL=31 \
        -DANDROID_SDK_ROOT:PATH=${WAVEY_ANDROID_SDK_ROOT} \
        -DCMAKE_GENERATOR:STRING=Ninja \
        -DCMAKE_TOOLCHAIN_FILE:FILEPATH=${WAVEY_ANDROID_NDK_PATH}/build/cmake/android.toolchain.cmake \
        -DQT_HOST_PATH:PATH=${WAVEY_QT_PATH_GCC} \
        -DCMAKE_FIND_ROOT_PATH:PATH=${WAVEY_QT_PATH_x86_64} \
        -DANDROID_STL:STRING=c++_shared \
        -DQT_NO_PACKAGE_VERSION_CHECK=TRUE \
    && ninja \
    && ninja install

# Conan
RUN pip install conan==1.59.0 \
    && conan remote add wavey https://git.spyrosoft.it/api/v4/projects/183/packages/conan
