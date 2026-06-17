# Atlas Cloud CLI

> Call Atlas Cloud LLM, image, video, and audio APIs from your shell, scripts, and CI jobs.

<p>
  <a href="https://github.com/AtlasCloudAI/cli/releases"><img src="https://img.shields.io/github/v/release/AtlasCloudAI/cli?style=flat&colorA=18181B&colorB=28CF8D" alt="release" /></a>
  <a href="https://www.npmjs.com/package/atlascloud-cli"><img src="https://img.shields.io/npm/dm/atlascloud-cli.svg?style=flat&colorA=18181B&colorB=28CF8D" alt="npm downloads" /></a>
  <a href="https://github.com/AtlasCloudAI/cli/blob/main/LICENSE"><img src="https://img.shields.io/github/license/AtlasCloudAI/cli?style=flat&colorA=18181B&colorB=28CF8D" alt="license" /></a>
  <a href="https://github.com/AtlasCloudAI/cli/stargazers"><img src="https://img.shields.io/github/stars/AtlasCloudAI/cli?style=flat&colorA=18181B&colorB=28CF8D" alt="stars" /></a>
  <a href="https://github.com/AtlasCloudAI/cli/pulls"><img src="https://img.shields.io/badge/PRs-welcome-28CF8D.svg?style=flat&colorA=18181B" alt="PRs welcome" /></a>
</p>

> **[→ Get your free Atlas Cloud API key](https://www.atlascloud.ai/console/api-keys?utm_source=github&utm_campaign=cli)** — 300+ models, one key, OpenAI-compatible.

This repository hosts public installers, release artifacts, and lightweight package-manager wrappers for the `atlas` CLI. The Go source repository is maintained separately.

## Supported Models

- 🎬 **Video** — Seedance 2.0 · Kling 3 · Sora 2 · Veo 3.1 · HappyHorse 1 · Grok Imagine 1.5 · Wan 2.7
- 🎨 **Image** — Nano Banana 2/Pro · GPT Image 2 · Flux 2 · Seedream 5
- 💬 **LLM** — Claude · GPT · DeepSeek · MiniMax · Kimi · GLM · Qwen
- 🔊 **Audio** — Grok TTS

- 📚 **Explore more** — [300+ models »](https://www.atlascloud.ai/models?utm_source=github&utm_campaign=cli)

Availability, parameters, and pricing vary by model. Use `atlas models get` and
`atlas generate cost` against the live catalog before automating billable calls.

## Contents

- [Supported Models](#supported-models)
- [Install](#install)
- [API caller workflows](#api-caller-workflows)
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

## API caller workflows

Authenticate once, then choose the command path that matches the API call you
want to make. Discovery and cost commands are safe to run before starting a
billable generation.

```bash
atlas auth login                               # interactive
atlas auth login --token "$ATLASCLOUD_API_KEY" # CI / non-interactive
atlas auth status
```

| Job | Command pattern | Notes |
|---|---|---|
| Discover available models | `atlas models list --type video --json` | Replace `video` with `chat` or `image`; avoid hard-coding stale model IDs. |
| Inspect model parameters | `atlas models get MODEL_ID --json` | Read required fields, defaults, and vendor-specific parameter names. |
| Estimate generation cost | `atlas generate cost video MODEL_ID ... --json` | Use `cost image` or `cost video`; calls the pricing endpoint only. |
| Call a chat or multimodal model | `atlas chat --model MODEL_ID "prompt"` | Supports text plus `--image`, `--video`, and `--audio` for capable models. |
| Start an image/video job | `atlas generate image MODEL_ID ...` | Use `generate image` or `generate video`; add `--no-wait --json` for async scripts. |
| Continue an async job | `atlas generate get PREDICTION_ID` / `atlas generate wait PREDICTION_ID` | Poll status or wait until completion. |
| Script and CI usage | `atlas --json ... \| jq ...` | Non-TTY output is JSON by default; `--json` makes it explicit. |

### Explore without model calls

```bash
atlas models list --type video --json | jq -r '.models[].id'
atlas models search seedance --type video --json
atlas models get bytedance/seedance-2.0-fast/text-to-video --json
```

### Estimate cost before generation

```bash
atlas generate cost video bytedance/seedance-2.0-fast/text-to-video \
  -p "A product shot slowly rotates on a clean white background" \
  --duration 5 \
  --resolution 720p \
  --param generate_audio=false \
  --json
```

### Make API calls

```bash
atlas chat --model deepseek-ai/DeepSeek-V3-0324 "Return only a JSON object with status=ok"

PRED=$(atlas generate image google/nano-banana-2/text-to-image \
  -p "minimal product photo on a white background" \
  --no-wait --json | jq -r '.id')
atlas generate wait "$PRED"
```

Prefer environment variables? Copy [`.env.example`](.env.example) to `.env` and set `ATLASCLOUD_API_KEY`.

More API caller scripts (discovery-first call → cost-aware generation → scripted pipeline) live in [`examples/`](examples/).

## Commands

| Command | Purpose |
|---|---|
| `atlas auth` | Log in, log out, inspect local auth state |
| `atlas chat` | Send a chat completion request |
| `atlas models` | List and inspect available models |
| `atlas generate` | Generate images and videos, poll job status |
| `atlas account` | Manage account selection |
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

<!-- TODO(hero): add a terminal recording or screenshot showing atlas CLI generating an image or video. -->
