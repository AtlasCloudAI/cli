#!/bin/sh
# cli installer — installs `atlas` (CLI).
#
# Usage:
#   curl -fsSL https://raw.githubusercontent.com/AtlasCloudAI/cli/main/install.sh | sh
#   ... | sh -s -- --prefix=$HOME/.local
#   ... | sh -s -- --tag v0.1.4
#
# Telemetry (opt-in): set ATLAS_TELEMETRY=1 to send an anonymous install
# ping (OS, arch, version) to api.atlascloud.ai/i/v1. Off by default.

set -e

REPO="AtlasCloudAI/cli"
PREFIX="/usr/local"
TAG="v0.1.4"
INSTALL_CLI=yes

while [ "$#" -gt 0 ]; do
  case "$1" in
    --prefix=*)  PREFIX="${1#*=}"; shift ;;
    --prefix)    PREFIX="$2"; shift 2 ;;
    --tag=*)     TAG="${1#*=}"; shift ;;
    --tag)       TAG="$2"; shift 2 ;;
    --cli-only)  INSTALL_CLI=yes; shift ;;
    *) echo "Unknown arg: $1" >&2; exit 1 ;;
  esac
done

# 1. Detect platform
OS="$(uname -s | tr '[:upper:]' '[:lower:]')"
ARCH="$(uname -m)"
case "$ARCH" in
  x86_64|amd64)  ARCH="amd64" ;;
  arm64|aarch64) ARCH="arm64" ;;
  *) echo "Unsupported arch: $ARCH" >&2; exit 1 ;;
esac
case "$OS" in
  darwin|linux) ;;
  *) echo "Unsupported OS: $OS (use scoop/winget on Windows)" >&2; exit 1 ;;
esac

TMPDIR="$(mktemp -d)"
trap 'rm -rf "$TMPDIR"' EXIT

# 2. Resolve tag. The default is pinned to avoid GitHub API rate limits.
VER="${TAG#v}"

# 3. Download + extract
TARBALL="cli_${VER}_${OS}_${ARCH}.tar.gz"
URL="https://github.com/$REPO/releases/download/$TAG/$TARBALL"
CHECKSUMS_URL="https://github.com/$REPO/releases/download/$TAG/checksums.txt"
echo "Downloading $URL"
curl -fsSL -o "$TMPDIR/$TARBALL" "$URL"
curl -fsSL -o "$TMPDIR/checksums.txt" "$CHECKSUMS_URL"

expected_sha="$(awk -v file="$TARBALL" '$2 == file { print $1 }' "$TMPDIR/checksums.txt" | head -n 1)"
[ -z "$expected_sha" ] && { echo "Checksum for $TARBALL not found." >&2; exit 1; }

if command -v sha256sum >/dev/null 2>&1; then
  actual_sha="$(sha256sum "$TMPDIR/$TARBALL" | awk '{print $1}')"
elif command -v shasum >/dev/null 2>&1; then
  actual_sha="$(shasum -a 256 "$TMPDIR/$TARBALL" | awk '{print $1}')"
else
  echo "Missing sha256sum or shasum; cannot verify archive." >&2
  exit 1
fi

[ "$actual_sha" = "$expected_sha" ] || {
  echo "Checksum mismatch for $TARBALL." >&2
  echo "expected: $expected_sha" >&2
  echo "actual:   $actual_sha" >&2
  exit 1
}

tar -xzf "$TMPDIR/$TARBALL" -C "$TMPDIR"

# 4. Install
BIN_DIR="$PREFIX/bin"
[ -d "$BIN_DIR" ] || { mkdir -p "$BIN_DIR" 2>/dev/null || sudo mkdir -p "$BIN_DIR"; }
run() { if [ -w "$BIN_DIR" ]; then "$@"; else sudo "$@"; fi; }

INSTALLED=""
if [ "$INSTALL_CLI" = "yes" ]; then
  run install -m 0755 "$TMPDIR/atlas" "$BIN_DIR/atlas"
  # macOS: strip quarantine xattr so Gatekeeper does not block exec.
  [ "$OS" = "darwin" ] && run xattr -d com.apple.quarantine "$BIN_DIR/atlas" 2>/dev/null || true
  INSTALLED="$INSTALLED atlas"
fi

# 5. Anonymous install ping — OPT-IN. Default: off.
# Set ATLAS_TELEMETRY=1 if you want to help upstream see how many people
# install, on which platform/version.
if [ "$ATLAS_TELEMETRY" = "1" ]; then
  PRODUCTS=$(echo "$INSTALLED" | tr ' ' ',' | sed 's/^,//')
  curl -fsSL "https://api.atlascloud.ai/i/v1?os=$OS&arch=$ARCH&version=$VER&products=$PRODUCTS&channel=installsh" \
    >/dev/null 2>&1 || true
fi

echo ""
echo "Installed:$INSTALLED"
[ "$INSTALL_CLI" = "yes" ] && echo "  $($BIN_DIR/atlas version 2>/dev/null || echo atlas)"

echo ""
echo "Next: atlas auth login"
