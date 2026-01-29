#!/bin/bash
#
# Wavey Install Script
# Usage: ./scripts/install.sh [--prefix <path>] [--clean]
#
# Installs the monorepo build into a staging prefix.
#

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_DIR="$(dirname "$SCRIPT_DIR")"
DOCKER_IMAGE="wavey/systemui:oss-qt-6.4.2"

PREFIX="$PROJECT_DIR/install"
CLEAN=false

while [[ $# -gt 0 ]]; do
    case $1 in
        --prefix)
            PREFIX="$2"
            shift 2
            ;;
        --clean)
            CLEAN=true
            shift
            ;;
        --help|-h)
            echo "Usage: ./scripts/install.sh [--prefix <path>] [--clean]"
            exit 0
            ;;
        *)
            echo "Unknown option: $1"
            exit 1
            ;;
    esac
done

if [[ ! -d "$PROJECT_DIR/build" ]]; then
    echo "Build directory not found. Run ./scripts/build.sh first."
    exit 1
fi

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

REL_PREFIX="${PREFIX#$PROJECT_DIR/}"

if [[ "$CLEAN" == true ]]; then
    echo "Cleaning install prefix: $PREFIX"
    rm -rf "$PREFIX"
fi

# Pass host user UID/GID to create files with correct ownership
HOST_UID=$(id -u)
HOST_GID=$(id -g)

docker run --rm \
    -v "$PROJECT_DIR:/workspace" \
    -w /workspace \
    --user "$HOST_UID:$HOST_GID" \
    "$DOCKER_IMAGE" \
    bash -c "cmake --install ./build --prefix \"/workspace/$REL_PREFIX\""
