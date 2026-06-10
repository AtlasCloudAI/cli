# Atlas Cloud CLI

> One command to call 300+ LLM, image, and video models from your shell. Cross-platform · MCP-ready.

<p>
  <a href="https://github.com/AtlasCloudAI/cli/releases"><img src="https://img.shields.io/github/v/release/AtlasCloudAI/cli?style=flat&colorA=18181B&colorB=28CF8D" alt="release" /></a>
  <a href="https://www.npmjs.com/package/atlascloud-cli"><img src="https://img.shields.io/npm/dm/atlascloud-cli.svg?style=flat&colorA=18181B&colorB=28CF8D" alt="npm downloads" /></a>
  <a href="https://github.com/AtlasCloudAI/cli/blob/main/LICENSE"><img src="https://img.shields.io/github/license/AtlasCloudAI/cli?style=flat&colorA=18181B&colorB=28CF8D" alt="license" /></a>
  <a href="https://github.com/AtlasCloudAI/cli/stargazers"><img src="https://img.shields.io/github/stars/AtlasCloudAI/cli?style=flat&colorA=18181B&colorB=28CF8D" alt="stars" /></a>
  <a href="https://github.com/AtlasCloudAI/cli/pulls"><img src="https://img.shields.io/badge/PRs-welcome-28CF8D.svg?style=flat&colorA=18181B" alt="PRs welcome" /></a>
</p>

![Atlas Cloud CLI demo](demo.gif)

> **[→ Get your free Atlas Cloud API key](https://www.atlascloud.ai/console/api-keys?utm_source=github&utm_campaign=cli)** — 300+ models, one key, OpenAI-compatible.

This repository hosts public installers, release artifacts, and lightweight package-manager wrappers for the `atlas` CLI. The Go source repository is maintained separately.

## Supported Models

- 🎬 **Video** — Seedance 2.0 · Kling 3 · Sora 2 · Veo 3.1 · HappyHorse 1 · Grok Imagine 1.5 · Wan 2.7
- 🎨 **Image** — Nano Banana 2/Pro · GPT Image 2 · Flux 2 · Seedream 5
- 💬 **LLM** — Claude · GPT · DeepSeek · MiniMax · Kimi · GLM · Qwen
- 🔊 **Audio** — Grok TTS

- 📚 **Explore more** — [300+ models »](https://www.atlascloud.ai/models?utm_source=github&utm_campaign=cli)

## Contents

- [Supported Models](#supported-models)
- [Install](#install)
- [Quickstart](#quickstart)
- [Commands](#commands)
- [Global Flags](#global-flags)
- [Updating](#updating)
- [Uninstall](#uninstall)
- [Troubleshooting](#troubleshooting)
- [Support](#support)
- [More Atlas Cloud Tools](#more-atlas-cloud-tools)
- [License](#license)

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

Generate your first image, video, and chat completion — one line each:

```bash
# Image
atlas generate image google/nano-banana-2/text-to-image -p "a cat astronaut, studio lighting"

# Video
atlas generate video bytedance/seedance-2.0-fast/text-to-video -p "a paper plane gliding over a neon city at dusk"

# Chat (LLM)
atlas chat "explain UUID v7"

# Browse the full catalog any time
atlas models list
```

First time only — authenticate with your [API key](https://www.atlascloud.ai/console/api-keys?utm_source=github&utm_campaign=cli):

```bash
atlas auth login                               # interactive
atlas auth login --token "$ATLASCLOUD_API_KEY" # CI / non-interactive
```

Prefer environment variables? Copy [`.env.example`](.env.example) to `.env` and set `ATLASCLOUD_API_KEY`.

More end-to-end scripts (minimal call → real-world scenario → multi-step pipeline) live in [`examples/`](examples/).

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

## More Atlas Cloud Tools

- 🧰 **Want to use it from the terminal?** → [atlascloud-cli](https://github.com/AtlasCloudAI/cli)
- 🤖 **Want to use it in Claude Code / Cursor?** → Install the [Atlas Cloud MCP Server](https://github.com/AtlasCloudAI/mcp-server)
- 🎬 **Want it as a Claude Code / Codex / Gemini CLI Skill?** → Install [atlas-cloud-skills](https://github.com/AtlasCloudAI/atlas-cloud-skills)
- 🎨 **ComfyUI nodes** → [atlascloud_comfyui](https://github.com/AtlasCloudAI/atlascloud_comfyui)
- 🔁 **n8n nodes** → [n8n-nodes-atlascloud](https://github.com/AtlasCloudAI/n8n-nodes-atlascloud)
- 💬 **Join our Discord** → [discord.gg/MWmMr4q9es](https://discord.gg/MWmMr4q9es)
- 🌐 **Website** → [atlascloud.ai](https://www.atlascloud.ai?utm_source=github&utm_campaign=cli)

## License

MIT
