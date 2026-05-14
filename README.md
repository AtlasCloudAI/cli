# AtlasCloud CLI

Call AtlasCloud LLM, image, and video models from your shell.

![AtlasCloud CLI demo](demo.gif)

This repository hosts public installers, release artifacts, and lightweight package-manager wrappers for the `atlas` CLI. The Go source repository is maintained separately.

## Install

### macOS / Linux

```bash
curl -fsSL https://raw.githubusercontent.com/AtlasCloudAI/cli/main/install.sh | sh
```

Options:

```bash
INSTALLER=https://raw.githubusercontent.com/AtlasCloudAI/cli/main/install.sh

# Custom prefix, no sudo if the directory is writable
curl -fsSL "$INSTALLER" | sh -s -- --prefix="$HOME/.local"
```

The installer always uses the latest GitHub Release, downloads the matching archive, and verifies it against `checksums.txt`.

### Windows

```powershell
irm https://raw.githubusercontent.com/AtlasCloudAI/cli/main/install.ps1 | iex
```

Options:

```powershell
# Custom install dir
$env:ATLAS_INSTALL_DIR="$HOME\bin"; irm https://raw.githubusercontent.com/AtlasCloudAI/cli/main/install.ps1 | iex

# Skip adding atlas.exe to user PATH
$env:ATLAS_NO_PATH="1"; irm https://raw.githubusercontent.com/AtlasCloudAI/cli/main/install.ps1 | iex
```

The Windows installer always uses the latest GitHub Release, downloads the matching `windows_amd64` or `windows_arm64` zip, verifies it against `checksums.txt`, installs `atlas.exe`, and adds the install directory to the user PATH by default.

### Homebrew

```bash
brew install AtlasCloudAI/tap/atlascloud
```

The formula is named `atlascloud`, but it installs the `atlas` command.

### npm

```bash
npm install -g atlascloud-cli
```

The npm package is a thin wrapper. Its postinstall script downloads the matching prebuilt release archive and verifies the checksum before exposing `atlas`.

### Manual

Download the archive for your OS and architecture from [Releases](https://github.com/AtlasCloudAI/cli/releases), extract it, and place the binaries in your `PATH`.

## Quickstart

```bash
atlas auth login
atlas chat "explain UUID v7"
atlas models list
atlas generate image google/nano-banana-2/text-to-image -p "a cat"
```

For CI and non-interactive environments:

```bash
atlas auth login --token "$ATLAS_API_KEY"
atlas chat "hi" --model deepseek-ai/DeepSeek-V3-0324
```

## Commands

| Command | Purpose |
|---|---|
| `atlas auth` | Log in, log out, inspect local auth state |
| `atlas chat` | Send a chat completion request |
| `atlas models` | List and inspect available models |
| `atlas generate` | Generate images and videos, poll job status |
| `atlas account` | Upcoming: account and billing endpoints are not available yet |
| `atlas version` | Print build information |

Run `atlas --help` or `atlas <command> --help` for full flag reference.

## Global Flags

| Flag | Purpose |
|---|---|
| `--json` | Force machine-readable JSON output |
| `--no-color` | Disable ANSI color |
| `--quiet` | Suppress spinners and progress text |
| `--verbose` | Print debug output to stderr |

## Updating

```bash
# curl installer
curl -fsSL https://raw.githubusercontent.com/AtlasCloudAI/cli/main/install.sh | sh

# Homebrew
brew update && brew upgrade atlascloud

# npm
npm install -g atlascloud-cli@latest
```

## Uninstall

```bash
# curl installer, default prefix
sudo rm -f /usr/local/bin/atlas

# Homebrew
brew uninstall atlascloud

# npm
npm uninstall -g atlascloud-cli
```

## Troubleshooting

`Not logged in` — run `atlas auth login`.

`Unknown model` — run `atlas models list` or `atlas models search <keyword>`.

Installer checksum failure — do not run the downloaded archive. Retry the install or open an issue with the exact URL and version.

## Support

Bugs and feature requests: [GitHub Issues](https://github.com/AtlasCloudAI/cli/issues). Please include `atlas version`, your OS/arch, install method, and the exact command that failed.

## License

MIT
