#!/bin/sh
# cli installer — installs `atlas` (CLI).
#
# Usage:
#   curl -fsSL https://raw.githubusercontent.com/AtlasCloudAI/cli/main/install.sh | sh
#   ... | sh -s -- --prefix=$HOME/.local
#   ... | sh -s -- --version=0.1.15
#
# Telemetry is on by default. Set ATLAS_TELEMETRY=0 to skip the anonymous
# install ping (OS, arch, version) to api.atlascloud.ai/i/v1.

set -e

REPO="${ATLAS_RELEASE_REPO:-AtlasCloudAI/cli}"
PREFIX="$HOME/.local"
VERSION="${ATLAS_VERSION:-}"
VERSION_URL="${ATLAS_VERSION_URL:-https://raw.githubusercontent.com/$REPO/main/VERSION}"

while [ "$#" -gt 0 ]; do
  case "$1" in
    --prefix=*)  PREFIX="${1#*=}"; shift ;;
    --prefix)    PREFIX="$2"; shift 2 ;;
    --version=*) VERSION="${1#*=}"; shift ;;
    --version)   VERSION="$2"; shift 2 ;;
    *) echo "Unknown arg: $1" >&2; exit 1 ;;
  esac
done

normalize_version() {
  v="$(printf '%s' "$1" | tr -d '[:space:]')"
  v="${v#v}"
  case "$v" in
    ""|*/*|*\\*) return 1 ;;
    [0-9]*) ;;
    *) return 1 ;;
  esac
  printf '%s' "$v"
}

resolve_version() {
  if [ -n "$VERSION" ]; then
    normalize_version "$VERSION" || {
      echo "Invalid version: $VERSION" >&2
      exit 1
    }
    return
  fi

  raw_version="$(curl -fsSL "$VERSION_URL" 2>/dev/null || true)"
  if [ -n "$raw_version" ]; then
    normalize_version "$raw_version" || {
      echo "Invalid version from $VERSION_URL: $raw_version" >&2
      echo "Try passing --version=0.1.15 explicitly." >&2
      exit 1
    }
    return
  fi

  echo "Could not resolve latest Atlas CLI version from $VERSION_URL." >&2
  echo "Try passing --version=0.1.15 or setting ATLAS_VERSION." >&2
  exit 1
}

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
  *) echo "Unsupported OS: $OS (use install.ps1 or npm on Windows)" >&2; exit 1 ;;
esac

TMPDIR="$(mktemp -d)"
trap 'rm -rf "$TMPDIR"' EXIT

# 2. Resolve version without using the GitHub Releases API. Anonymous GitHub
# API calls are limited to 60/hour/IP and can make installers flaky.
VER="$(resolve_version)"
TAG="v$VER"

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

run install -m 0755 "$TMPDIR/atlas" "$BIN_DIR/atlas"
printf 'native\n' > "$TMPDIR/atlas.install"
run install -m 0644 "$TMPDIR/atlas.install" "$BIN_DIR/atlas.install"
# macOS: strip quarantine xattr so Gatekeeper does not block exec.
[ "$OS" = "darwin" ] && run xattr -d com.apple.quarantine "$BIN_DIR/atlas" 2>/dev/null || true

# 5. Anonymous install ping — on unless ATLAS_TELEMETRY=0/false/no/off.
telemetry_off="$(printf '%s' "${ATLAS_TELEMETRY-}" | tr '[:upper:]' '[:lower:]' | tr -d '[:space:]')"
case "$telemetry_off" in
  0|false|no|off) ;;
  *)
    curl -fsSL --max-time 2 "https://api.atlascloud.ai/i/v1?os=$OS&arch=$ARCH&version=$VER&products=atlas&channel=installsh" \
      >/dev/null 2>&1 || true
    ;;
esac

echo ""
echo "Installed: atlas"
echo "  $(ATLAS_TELEMETRY=0 "$BIN_DIR/atlas" version 2>/dev/null || echo atlas)"

echo ""
echo "Next: atlas auth login"
echo "Using Claude Code or Codex? Run atlas skills install --agent claude (or --agent codex)."
echo "Then start a new agent session and ask Atlas to create an image or video."
if [ -w "$BIN_DIR" ]; then
  echo "Automatic updates are enabled for official native installations. Set ATLAS_AUTO_UPDATE=0 to disable."
else
  echo "Automatic updates are unavailable: $BIN_DIR is not writable by this user."
fi
case ":$PATH:" in
  *":$BIN_DIR:"*) ;;
  *) echo "Add $BIN_DIR to your PATH before running atlas." ;;
esac
active_atlas="$(command -v atlas || true)"
if [ -n "$active_atlas" ] && [ "$active_atlas" != "$BIN_DIR/atlas" ]; then
  echo "Another atlas is first on PATH: $active_atlas"
  echo "Put $BIN_DIR before that directory on PATH to use this installation."
fi
