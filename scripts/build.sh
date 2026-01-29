#!/bin/bash
#
# Wavey Build Script
# Usage: ./scripts/build.sh [options]
#
# Options:
#   --clean          Remove build directory before building
#   --testbed        Build with testbed enabled
#   --install        Install after build
#   --prefix <path>  Install prefix (default: ./install)
#   --run            Run from build tree after build
#   --run-installed  Run from install prefix after build (implies --install)
#   --help           Show this help
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
CLEAN=false
RUN=false
RUN_INSTALLED=false
INSTALL=false
BUILD_TESTBED="OFF"
PREFIX="$PROJECT_DIR/install"

# Parse arguments
while [[ $# -gt 0 ]]; do
    case $1 in
        --clean)
            CLEAN=true
            shift
            ;;
        --run)
            RUN=true
            shift
            ;;
        --run-installed)
            RUN_INSTALLED=true
            shift
            ;;
        --install)
            INSTALL=true
            shift
            ;;
        --prefix)
            PREFIX="$2"
            shift 2
            ;;
        --testbed)
            BUILD_TESTBED="ON"
            shift
            ;;
        --help|-h)
            head -17 "$0" | tail -14
            exit 0
            ;;
        *)
            echo -e "${RED}Unknown option: $1${NC}"
            exit 1
            ;;
    esac
done

if [[ "$RUN_INSTALLED" == true ]]; then
    INSTALL=true
fi

echo -e "${GREEN}============================================${NC}"
echo -e "${GREEN}Wavey Build${NC}"
echo -e "${GREEN}============================================${NC}"

# Clean if requested
if [[ "$CLEAN" == true ]]; then
    echo -e "${YELLOW}Cleaning build directory...${NC}"
    rm -rf "$PROJECT_DIR/build"
fi

# Run docker build
echo -e "${YELLOW}Starting Docker build...${NC}"

# Pass host user UID/GID to create files with correct ownership
HOST_UID=$(id -u)
HOST_GID=$(id -g)

docker run --rm \
    -v "$PROJECT_DIR:/workspace" \
    -w /workspace \
    --user "$HOST_UID:$HOST_GID" \
    "$DOCKER_IMAGE" \
    bash -c "cmake -S . -B ./build \
            -DCMAKE_GENERATOR:STRING=Ninja \
            -DCMAKE_PREFIX_PATH:PATH=\${QT_PATH_GCC:-/sdk/Qt/6.4.2/gcc_64} \
            -DCMAKE_BUILD_TYPE=Release \
            -DCMAKE_EXPORT_COMPILE_COMMANDS=1 \
            -DBUILD_TESTBED=$BUILD_TESTBED && \
        cmake --build ./build --target all"

BUILD_RESULT=$?

if [[ $BUILD_RESULT -eq 0 ]]; then
    echo -e "${GREEN}============================================${NC}"
    echo -e "${GREEN}Build successful!${NC}"
    echo -e "${GREEN}============================================${NC}"
else
    echo -e "${RED}============================================${NC}"
    echo -e "${RED}Build failed!${NC}"
    echo -e "${RED}============================================${NC}"
    exit 1
fi

if [[ "$INSTALL" == true ]]; then
    "$SCRIPT_DIR/install.sh" --prefix "$PREFIX"
fi

if [[ "$RUN_INSTALLED" == true ]]; then
    "$SCRIPT_DIR/run-installed.sh" --prefix "$PREFIX"
elif [[ "$RUN" == true ]]; then
    "$SCRIPT_DIR/run.sh"
fi
