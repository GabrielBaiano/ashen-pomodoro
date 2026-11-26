#!/bin/sh
set -e

# ashen-pomodoro installer
VERSION="v2.0.0"
REPO="GabrielBaiano/ashen-pomodoro"
TARGET_DIR="${HOME}/.local/bin"

if [ "$(id -u)" -eq 0 ]; then
    TARGET_DIR="/usr/local/bin"
fi

mkdir -p "${TARGET_DIR}"

OS="$(uname -s)"
ARCH="$(uname -m)"

if [ "$OS" != "Linux" ] && [ "$OS" != "Darwin" ]; then
    echo "ashen-pomodoro targets Linux and macOS terminals. Detected OS: $OS"
    exit 1
fi

echo "Installing ashen-pomodoro (${VERSION})..."

INSTALLED=0
if [ "$OS" = "Linux" ] && [ "$ARCH" = "x86_64" ]; then
    TMP_DIR=$(mktemp -d)
    TAR_URL="https://github.com/${REPO}/releases/download/${VERSION}/ashen-${VERSION}-linux-x86_64.tar.gz"
    if curl -sSL -f "$TAR_URL" -o "${TMP_DIR}/ashen.tar.gz" 2>/dev/null; then
        tar -xzf "${TMP_DIR}/ashen.tar.gz" -C "${TMP_DIR}"
        install -m 755 "${TMP_DIR}/bonfire" "${TARGET_DIR}/bonfire"
        ln -sf bonfire "${TARGET_DIR}/ashen"
        ln -sf bonfire "${TARGET_DIR}/fireplace"
        rm -rf "${TMP_DIR}"
        INSTALLED=1
    else
        rm -rf "${TMP_DIR}"
    fi
fi

if [ "$INSTALLED" -eq 0 ]; then
    if ! command -v make >/dev/null 2>&1 || ( ! command -v cc >/dev/null 2>&1 && ! command -v gcc >/dev/null 2>&1 ); then
        echo "Error: Pre-compiled binary unavailable for ${OS}/${ARCH} and 'make'/'cc' not found."
        echo "Please install build tools (build-essential / Xcode CLT) and try again."
        exit 1
    fi

    TMP_DIR=$(mktemp -d)
    echo "Compiling from source..."
    curl -sSL "https://github.com/${REPO}/archive/refs/tags/${VERSION}.tar.gz" | tar -xz -C "${TMP_DIR}"
    SRC_DIR=$(find "${TMP_DIR}" -maxdepth 1 -type d \( -name "ashen-pomodoro*" -o -name "bonfire-pomodoro*" \) | head -n 1)
    make -C "${SRC_DIR}"
    install -m 755 "${SRC_DIR}/bonfire" "${TARGET_DIR}/bonfire"
    ln -sf bonfire "${TARGET_DIR}/ashen"
    ln -sf bonfire "${TARGET_DIR}/fireplace"
    rm -rf "${TMP_DIR}"
fi

echo "ashen-pomodoro installed successfully to ${TARGET_DIR}/ashen (alias: bonfire)"

case ":$PATH:" in
    *":${TARGET_DIR}:"*) ;;
    *)
        echo ""
        echo "Note: ${TARGET_DIR} is not in your PATH."
        echo "Add it by adding this to your ~/.bashrc or ~/.zshrc:"
        echo "    export PATH=\"${TARGET_DIR}:\$PATH\""
        ;;
esac

echo ""
echo "Run 'ashen' (or 'bonfire') to begin your focus session."
