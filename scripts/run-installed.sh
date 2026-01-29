#!/bin/bash
#
# Wavey Run (Installed) Script
# Usage: ./scripts/run-installed.sh [options]
#
# Runs the installed Wavey HMI system (both main and gesture screens)
#
# Options:
#   --prefix <path>  Installation prefix (default: ./install)
#   --main-only      Run only the main screen
#   --gesture-only   Run only the gesture screen
#   --help           Show this help
#

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_DIR="$(dirname "$SCRIPT_DIR")"
DOCKER_IMAGE="wavey/systemui:oss-qt-6.4.2"

PREFIX="$PROJECT_DIR/install"
RUN_MAIN=true
RUN_GESTURE=true
QT_SDK_ROOT="/sdk/Qt/6.4.2/gcc_64"

while [[ $# -gt 0 ]]; do
    case $1 in
        --prefix)
            PREFIX="$2"
            shift 2
            ;;
        --main-only)
            RUN_GESTURE=false
            shift
            ;;
        --gesture-only)
            RUN_MAIN=false
            shift
            ;;
        --help|-h)
            head -16 "$0" | tail -13
            exit 0
            ;;
        *)
            echo "Unknown option: $1"
            exit 1
            ;;
    esac
done

if [[ "$PREFIX" != /* ]]; then
    PREFIX="${PROJECT_DIR}/${PREFIX#./}"
fi

case "$PREFIX" in
    "$PROJECT_DIR"/*) ;;
    *)
        echo "Install prefix must be inside the project directory:"
        echo "  $PROJECT_DIR"
        exit 1
        ;;
esac

if [[ ! -x "$PREFIX/bin/WaveySystemUI" ]]; then
    echo "Installed binary not found. Run ./scripts/install.sh first."
    exit 1
fi

REL_PREFIX="${PREFIX#$PROJECT_DIR/}"

RUN_CMD=""
if [[ "$RUN_MAIN" == true ]]; then
    RUN_CMD="./bin/WaveySystemUI --no-cache --config-file ./share/wavey/wavey-common-config.yaml --config-file ./share/wavey/wavey-main-config-desktop.yaml --disable-installer"
    if [[ "$RUN_GESTURE" == true ]]; then
        RUN_CMD="$RUN_CMD &"
    fi
fi

if [[ "$RUN_GESTURE" == true ]]; then
    if [[ "$RUN_MAIN" == true ]]; then
        RUN_CMD="$RUN_CMD sleep 2 && "
    fi
    RUN_CMD="${RUN_CMD}./bin/WaveySystemUI --no-cache --config-file ./share/wavey/wavey-common-config.yaml --config-file ./share/wavey/wavey-gesture-config-desktop.yaml --disable-installer"
    if [[ "$RUN_MAIN" == true ]]; then
        RUN_CMD="$RUN_CMD &"
    fi
fi

if [[ "$RUN_MAIN" == true && "$RUN_GESTURE" == true ]]; then
    RUN_CMD="$RUN_CMD wait"
fi

mkdir -p ~/.config/SpyroSoft

# Enable X11 access for Docker (required for GUI applications)
if command -v xhost &> /dev/null; then
    xhost +local:docker > /dev/null 2>&1 || true
fi

DOCKER_TTY_FLAG=""
if [ -t 0 ]; then
    DOCKER_TTY_FLAG="-it"
fi

docker run --rm $DOCKER_TTY_FLAG \
    -v "$PROJECT_DIR:/workspace" \
    -v ~/.config/SpyroSoft:/home/developer/.config/SpyroSoft \
    -w "/workspace/$REL_PREFIX" \
    -e DISPLAY=$DISPLAY \
    -e QT_PLUGIN_PATH="${QT_SDK_ROOT}/plugins:/workspace/$REL_PREFIX/lib/plugins" \
    -e QT_QPA_PLATFORM_PLUGIN_PATH="${QT_SDK_ROOT}/plugins/platforms" \
    -e QML2_IMPORT_PATH="${QT_SDK_ROOT}/qml:/workspace/$REL_PREFIX/share/wavey/qml-plugins" \
    -e QML_IMPORT_PATH="${QT_SDK_ROOT}/qml:/workspace/$REL_PREFIX/share/wavey/qml-plugins" \
    -v /tmp/.X11-unix:/tmp/.X11-unix \
    --device /dev/dri \
    "$DOCKER_IMAGE" \
    bash -c "$RUN_CMD"
