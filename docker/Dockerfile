FROM ubuntu:jammy
#   docker build -t wavey/systemui:oss-qt-6.4.2 -f monorepo/systemui/config/Dockerfile .

USER root

ENV TZ=Europe/Warsaw
RUN ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone

RUN apt update \
    && apt upgrade -y \
    && apt install -y --no-install-recommends autoconf bc build-essential checkinstall clang-tidy curl g++ gcc git \
        lcov libasound2 libatk-bridge2.0-0 libgdk-pixbuf2.0-0 libgl1-mesa-dev libglu1-mesa libgtk-3-0 libnspr4 libnss3-dev \
        libpulse0 libsqlite3-0 libstdc++6 libtool libxcb-xinerama0 libxss1 libxtst6 locales make ninja-build \
        openjdk-11-jdk openssh-client perl python3 python3-pip python3-virtualenv python3-venv python3-distutils \
        ruby-bundler ruby-full \
        software-properties-common sudo unzip wget zip libfontconfig1-dev libfreetype6-dev libssl-dev libx11-dev \
        libx11-xcb-dev libxext-dev libxfixes-dev libxi-dev libxrender-dev libxcb1-dev libxcb-glx0-dev \
        libxcb-keysyms1-dev libxcb-image0-dev libxcb-shm0-dev libxcb-icccm4-dev libxcb-sync-dev libxcb-xfixes0-dev \
        libxcb-shape0-dev libxcb-randr0-dev libxcb-render-util0-dev libxcb-util-dev libxcb-xinerama0-dev libxcb-xkb-dev \
        libxkbcommon-dev libxkbcommon-x11-dev zlib1g-dev spirv-tools libicu-dev libvulkan-dev

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

ENV WAYVE_SDK_ROOT=/sdk
ENV WAVEY_QT_ROOT=${WAYVE_SDK_ROOT}/Qt
ENV WAVEY_QT_VERSION="6.4.2"
ENV WAVEY_QT_PATH_GCC=${WAVEY_QT_ROOT}/${WAVEY_QT_VERSION}/gcc_64
# Alias for build script compatibility
ENV QT_PATH_GCC=${WAVEY_QT_PATH_GCC}
ENV WAVEY_QT_MODULES="qtquick3d qt5compat qtshadertools qthttpserver qtmultimedia qtpositioning qtremoteobjects qtwebsockets"
ENV WAVEY_QT_MODULES_ROOT=${WAYVE_SDK_ROOT}/QtModules
# Qt (open-source downloads via aqtinstall; no account needed)
RUN python3 -m pip install --no-cache-dir aqtinstall \
    && aqt install-qt linux desktop ${WAVEY_QT_VERSION} gcc_64 \
        --outputdir ${WAVEY_QT_ROOT} \
        --modules ${WAVEY_QT_MODULES}

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
    && ninja install

# QtModules - qtinterfaceframework
# Clone first, then install qface from the bundled submodule to avoid virtualenv deployment issues
# The virtualenv deployment script has issues with Python 3.10's module structure on Ubuntu 22.04
# Pin path<16 to avoid API breaking changes (Path.getcwd() removed in path>=16)
RUN cd ${WAVEY_QT_MODULES_ROOT} \
    && git clone git://code.qt.io/qt/qtinterfaceframework.git \
    && cd qtinterfaceframework \
    && git checkout ${WAVEY_QT_VERSION} \
    && git submodule update --init --recursive \
    && pip3 install --no-cache-dir "path>=11.0.1,<16" \
    && pip3 install --no-cache-dir -r ./src/3rdparty/qface/requirements.txt \
    && pip3 install --no-cache-dir --no-deps ./src/3rdparty/qface \
    && mkdir build_desktop \
    && cd build_desktop \
    && cmake .. \
        -DCMAKE_PREFIX_PATH:PATH=${WAVEY_QT_PATH_GCC} \
        -DCMAKE_GENERATOR:STRING=Ninja \
        -DFEATURE_system_qface=ON \
    && ninja \
    && ninja install

# QtModules - qtlocation
# Copy the ICU patch for maplibre-gl-native (adds ICU linking on Linux)
COPY docker/maplibre-icu.patch /tmp/maplibre-icu.patch
RUN cd ${WAVEY_QT_MODULES_ROOT} \
    && git clone git://code.qt.io/qt/qtlocation.git \
    && cd qtlocation \
    && git fetch https://codereview.qt-project.org/qt/qtlocation refs/changes/87/382087/22 \
    && git checkout -b change-382087 FETCH_HEAD \
    && git submodule update --init --recursive \
    && git revert --no-edit 7779e6a05cde72320e47cf4d5ebed78b9e049226 \
    && cd src/3rdparty/maplibre-gl-native \
    && git apply /tmp/maplibre-icu.patch \
    && cd - \
    && mkdir build_desktop \
    && cd build_desktop \
    && cmake .. \
        -DCMAKE_PREFIX_PATH:PATH=${WAVEY_QT_PATH_GCC} \
        -DCMAKE_GENERATOR:STRING=Ninja \
        -DQT_NO_PACKAGE_VERSION_CHECK=TRUE \
    && ninja \
    && ninja install

