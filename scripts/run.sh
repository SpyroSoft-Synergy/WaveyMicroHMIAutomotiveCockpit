#!/bin/bash
#
# Wavey Run Script
# Usage: ./scripts/run.sh [options]
#
# Runs the Wavey HMI system (both main and gesture screens)
#
# Options:
#   --main-only     Run only the main screen
#   --gesture-only  Run only the gesture screen
#   --help          Show this help
#

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_DIR="$(dirname "$SCRIPT_DIR")"
DOCKER_IMAGE="wavey/systemui:oss-qt-6.4.2"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Default values
RUN_MAIN=true
RUN_GESTURE=true

# Parse arguments
while [[ $# -gt 0 ]]; do
    case $1 in
        --main-only)
            RUN_GESTURE=false
            shift
            ;;
        --gesture-only)
            RUN_MAIN=false
            shift
            ;;
        --help|-h)
            head -13 "$0" | tail -11
            exit 0
            ;;
        *)
            echo -e "${RED}Unknown option: $1${NC}"
            echo "Use --help for usage information"
            exit 1
            ;;
    esac
done

# Check if build exists
if [[ ! -f "$PROJECT_DIR/build/systemui/src/wavey-ivi/WaveySystemUI" ]]; then
    echo -e "${RED}Error: WaveySystemUI not found. Please build first:${NC}"
    echo "  ./scripts/build.sh all"
    exit 1
fi

# Create config directory for theme persistence
mkdir -p ~/.config/SpyroSoft

# Enable X11 access for Docker (required for GUI applications)
if command -v xhost &> /dev/null; then
    xhost +local:docker > /dev/null 2>&1 || true
fi

echo -e "${GREEN}============================================${NC}"
echo -e "${GREEN}Starting Wavey HMI${NC}"
echo -e "${GREEN}============================================${NC}"

# Build the run command based on options
RUN_CMD=""

if [[ "$RUN_MAIN" == true ]]; then
    RUN_CMD="./WaveySystemUI --no-cache --config-file wavey-common-config.yaml --config-file wavey-main-config-desktop.yaml --disable-installer"
    if [[ "$RUN_GESTURE" == true ]]; then
        RUN_CMD="$RUN_CMD &"
    fi
fi

if [[ "$RUN_GESTURE" == true ]]; then
    if [[ "$RUN_MAIN" == true ]]; then
        RUN_CMD="$RUN_CMD sleep 2 && "
    fi
    RUN_CMD="${RUN_CMD}./WaveySystemUI --no-cache --config-file wavey-common-config.yaml --config-file wavey-gesture-config-desktop.yaml --disable-installer"
    if [[ "$RUN_MAIN" == true ]]; then
        RUN_CMD="$RUN_CMD &"
    fi
fi

if [[ "$RUN_MAIN" == true && "$RUN_GESTURE" == true ]]; then
    RUN_CMD="$RUN_CMD wait"
fi

# Library paths for monorepo build
# Applications middleware servers
LIB_PATHS="/workspace/build/applications/mediaplayer/src/middleware/mediaplayer/server"
LIB_PATHS="$LIB_PATHS:/workspace/build/applications/navigation/src/middleware/navigation/server"
LIB_PATHS="$LIB_PATHS:/workspace/build/applications/weather/src/middleware/weather/server"
LIB_PATHS="$LIB_PATHS:/workspace/build/applications/watch/src/middleware/watch/server"
LIB_PATHS="$LIB_PATHS:/workspace/build/applications/radioplayer/src/middleware/radioplayer/server"
# Applications middleware frontends
LIB_PATHS="$LIB_PATHS:/workspace/build/applications/mediaplayer/src/middleware/mediaplayer/frontend"
LIB_PATHS="$LIB_PATHS:/workspace/build/applications/navigation/src/middleware/navigation/frontend"
LIB_PATHS="$LIB_PATHS:/workspace/build/applications/weather/src/middleware/weather/frontend"
LIB_PATHS="$LIB_PATHS:/workspace/build/applications/watch/src/middleware/watch/frontend"
LIB_PATHS="$LIB_PATHS:/workspace/build/applications/radioplayer/src/middleware/radioplayer/frontend"
# SystemUI middleware
LIB_PATHS="$LIB_PATHS:/workspace/build/systemui/src/middleware/sysuiipc/server"
LIB_PATHS="$LIB_PATHS:/workspace/build/systemui/src/middleware/sysuiipc/frontend"
# Shared libraries
LIB_PATHS="$LIB_PATHS:/workspace/build/sharedui/WaveyStyle"
# InterfaceFramework backends
LIB_PATHS="$LIB_PATHS:/workspace/build/interfaceframework"

# Determine if we should use TTY
DOCKER_TTY_FLAG=""
if [ -t 0 ]; then
    DOCKER_TTY_FLAG="-it"
fi

# Run in Docker
docker run --rm $DOCKER_TTY_FLAG \
    -v "$PROJECT_DIR:/workspace" \
    -v ~/.config/SpyroSoft:/home/developer/.config/SpyroSoft \
    -w /workspace/build/systemui/src/wavey-ivi \
    -e DISPLAY=$DISPLAY \
    -e LD_LIBRARY_PATH="$LIB_PATHS" \
    -e QML_IMPORT_PATH="/workspace/build/systemui/src/wavey-ivi/sysUI:/workspace/appmodules/CommonAppModules/src:/workspace/build/qml:/workspace/build/systemui/src/wavey-ivi/qml-plugins:/workspace/build/src/wavey-ivi/qml-plugins:/workspace/build/imports" \
    -e QT_PLUGIN_PATH="/workspace/build/interfaceframework" \
    -v /tmp/.X11-unix:/tmp/.X11-unix \
    --device /dev/dri \
    "$DOCKER_IMAGE" \
    bash -c "$RUN_CMD"
