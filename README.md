# Atlas Cloud CLI

Call AtlasCloud LLM, image, video, audio, and 3D APIs from your terminal, scripts,
or AI coding agent. Create product images, animate reference photos, generate
speech, or analyze media with a model of your choice.

<p>
  <a href="https://github.com/AtlasCloudAI/cli/releases"><img src="https://img.shields.io/github/v/release/AtlasCloudAI/cli?style=flat&colorA=18181B&colorB=28CF8D" alt="release" /></a>
  <a href="https://www.npmjs.com/package/atlascloud-cli"><img src="https://img.shields.io/npm/dm/atlascloud-cli.svg?style=flat&colorA=18181B&colorB=28CF8D" alt="npm downloads" /></a>
  <a href="https://github.com/AtlasCloudAI/cli/blob/main/LICENSE"><img src="https://img.shields.io/github/license/AtlasCloudAI/cli?style=flat&colorA=18181B&colorB=28CF8D" alt="license" /></a>
  <a href="https://github.com/AtlasCloudAI/cli/stargazers"><img src="https://img.shields.io/github/stars/AtlasCloudAI/cli?style=flat&colorA=18181B&colorB=28CF8D" alt="stars" /></a>
  <a href="https://github.com/AtlasCloudAI/cli/pulls"><img src="https://img.shields.io/badge/PRs-welcome-28CF8D.svg?style=flat&colorA=18181B" alt="PRs welcome" /></a>
</p>

[Install](#install) · [Quick start](#quick-start) · [Examples](#examples) · [Troubleshooting](#troubleshooting) · [Releases](https://github.com/AtlasCloudAI/cli/releases)

## Install

Choose one installation method.

### macOS / Linux

```sh
curl -fsSL https://raw.githubusercontent.com/AtlasCloudAI/cli/main/install.sh | sh
```

The default executable is `~/.local/bin/atlas`. If your shell cannot find it,
add the directory to your PATH, then add the same line to your shell profile:

```sh
export PATH="$HOME/.local/bin:$PATH"
```

For a custom prefix, pass `--prefix=/your/prefix` to `sh -s --`. To select an
initial version, pass `--version=X.Y.Z`. Native installs can update automatically;
see [Updating](#updating) to retain a specific version.

### Windows PowerShell

```powershell
irm https://raw.githubusercontent.com/AtlasCloudAI/cli/main/install.ps1 | iex
```

The default directory is `%LOCALAPPDATA%\AtlasCloud\bin`. The installer adds it
to your user PATH; open a new terminal afterward. Set `ATLAS_INSTALL_DIR` for a
custom directory or `ATLAS_VERSION` for a specific initial version.

### Homebrew or npm

```sh
# Homebrew: the formula installs the atlas command
brew install AtlasCloudAI/tap/atlascloud

# Or npm
npm install -g atlascloud-cli
```

The shell and Windows installers resolve the latest stable version from
[`VERSION`](https://github.com/AtlasCloudAI/cli/blob/main/VERSION). Installers and
the npm wrapper download a prebuilt release archive and verify its checksum.
For manual installation, download your platform's archive from
[Releases](https://github.com/AtlasCloudAI/cli/releases) and put `atlas` in your PATH.

Verify the installation:

```sh
atlas version
```

## Quick start

### 1. Sign in

```sh
atlas auth login
atlas auth status
```

Device login is recommended: follow the authorization instructions to sign in
with your AtlasCloud account. The CLI stores credentials locally. You can also
choose to paste an [API key](https://www.atlascloud.ai/console/api-keys).
Chat and generation calls incur model usage charges; discovery and cost
estimation do not submit a billable generation.

### 2. Choose how to use Atlas

**With Claude Code or Codex**, install the Atlas skill for your agent:

```sh
atlas skills install --agent claude
# Or, for Codex:
atlas skills install --agent codex
```

Start a new agent session and ask:

> Use Atlas to create a product photo from this reference. Keep the packaging
> and logo intact. Show me the model and cost estimate before generating, then
> save the result in this project.

The skill guides your agent through model discovery, parameter checks, generation,
and file delivery. Its detailed instructions come from your installed CLI and
update with it. See the [Agent quickstart / Agent 上手指南](https://github.com/AtlasCloudAI/cli/blob/main/docs/AGENT_QUICKSTART.md)
for setup and more tasks.

**Directly from your terminal**, inspect the model and estimate cost before generating:

```sh
atlas models get google/nano-banana-2/text-to-image --json
atlas generate cost image google/nano-banana-2/text-to-image \
  -p "A minimal product photo on a white background" --json

# This call is billable. Wait for completion and save the files in ./outputs/.
mkdir -p outputs
atlas generate image google/nano-banana-2/text-to-image \
  -p "A minimal product photo on a white background" -o ./outputs/
```

Generation waits and downloads by default. The result reports the task status
and saved file paths. Use `--no-download` for remote results only.
Model availability, required inputs, and pricing depend on your account's live
catalog; inspect it before relying on an example model.

## Examples

### Discover models and parameters

```sh
atlas models list --type video --json
atlas models list --type audio --json
atlas models list --type 3d --json
atlas models search seedance --type video --json
atlas models get MODEL_ID --json
```

Replace `MODEL_ID` with a model from your catalog. Types include `chat`, `image`,
`video`, `audio`, and `3d`. Audio and 3D generation require the selected model and
schema to be exposed in your account catalog; unsupported routes stop before submission.

### Chat and media analysis

```sh
atlas chat --model MODEL_ID "Summarize this paragraph: ..."
atlas chat --model VISION_MODEL_ID --image @product.png "Describe this product"
```

Use a model that supports your input. Multimodal chat also accepts `--video`
and `--audio`. Chat returns the full response when ready; it currently buffers
responses rather than streaming tokens. Use `--timeout 15m` for a longer request.

### Video, audio, and 3D

```sh
# Check the selected model's schema first; replace the model placeholders.
atlas generate cost video VIDEO_MODEL_ID -p "A slow camera push toward a mountain" --json
atlas generate video VIDEO_MODEL_ID -p "A slow camera push toward a mountain"
atlas generate audio AUDIO_MODEL_ID -p "Welcome to our store"
atlas generate 3d THREE_D_MODEL_ID -p "A low-poly chair"
```

Models may require a reference image, audio, voice, or other fields. Use
`atlas generate video MODEL_ID --help` to inspect the live schema, and pass
local media as `@file`, for example `--image @reference.png`.
Cost estimation supports image, video, audio, and 3D; it never uploads local files.
If pricing requires a media URL, provide an HTTP(S) URL.

### Async tasks, scripts, and CI

```sh
atlas generate image google/nano-banana-2/text-to-image \
  -p "A minimal product photo on a white background" --no-wait --json

# Use the prediction ID returned by that submission.
atlas generate get PREDICTION_ID --json
atlas generate wait PREDICTION_ID -o ./outputs/ --json
```

`--no-wait` returns a submission receipt, not a finished file. After a timeout or
interruption, continue the same task with `get` or `wait`; a new generation can
incur another charge. Local receipts are available through `atlas generate ops list`;
`atlas generate ops resume OPERATION_ID` resumes an accepted task without resubmitting it.
If the submission outcome is unknown, inspect the receipt and contact support
before starting a replacement.

Use `--json` for scripts. Output is also JSON by default when stdout is not a terminal.
For CI, inject `ATLASCLOUD_API_KEY` through your CI secret store and authenticate explicitly:

```sh
atlas auth login --token "$ATLASCLOUD_API_KEY"
```

The CLI does not automatically load `.env` or use `ATLASCLOUD_API_KEY` as credentials.
In a local shell, export the variable yourself before the login command; merely
writing it in `.env` is insufficient.
See the [API caller guide](https://github.com/AtlasCloudAI/cli/blob/main/docs/api-caller-workflows.md)
and [script examples](https://github.com/AtlasCloudAI/cli/tree/main/examples) for more workflows.

## Commands

| Command | Purpose |
|---|---|
| `atlas auth` | Sign in, sign out, and inspect authentication |
| `atlas models` | Discover models and inspect their schemas |
| `atlas chat` | Chat with an LLM or analyze supported media |
| `atlas generate` | Generate image/video/audio/3D outputs, estimate cost, and retrieve tasks |
| `atlas generate ops` | Inspect local receipts and resume accepted tasks |
| `atlas skills` | Install or read the embedded Atlas agent skill |
| `atlas account` | Show, list, or switch accounts |
| `atlas doctor` | Diagnose local installation, authentication, and configuration |
| `atlas update` | Update an official native installation |
| `atlas version` | Show the installed version |

Run `atlas --help` or `atlas <command> --help` for details.
Global flags include `--json`, `--quiet`, `--no-color`, and `--verbose`.

## Updating

Official native installations update in the background during interactive use,
at most once every 24 hours. The next invocation uses the new version after
installation finishes. JSON commands and CI do not start background updates.

```sh
atlas update          # Update an official native install now
atlas update --check  # Check without installing
atlas doctor          # Inspect install method and update status

# For package-manager installations:
brew upgrade atlascloud
npm install -g atlascloud-cli@latest
```

To disable background updates, set `ATLAS_AUTO_UPDATE=0` in your shell profile
(PowerShell: `$env:ATLAS_AUTO_UPDATE="0"`). Manual `atlas update` still works.
Homebrew/npm installations stay managed by their package manager. Manually copied
binaries need manual replacement. See the [changelog](https://github.com/AtlasCloudAI/cli/blob/main/CHANGELOG.md)
for release changes.

## Troubleshooting

- **Command not found:** check PATH and reopen your terminal after installation.
- **Not logged in:** run `atlas auth login`; for CI, pass `--token` explicitly.
- **Unknown model or unsupported input:** use `atlas models search` and `atlas models get` to inspect your account catalog.
- **Wait timed out or terminal closed:** reuse the prediction ID with `atlas generate get` or `atlas generate wait`.
- **Generation succeeded but download failed:** retrieve the same task again and check the reported local file result.
- **Installer checksum failure:** retry the official installer or report the URL and version to support.

Start with `atlas doctor --json` for local diagnostics. Do not include credentials
in a bug report.

## Privacy

Atlas stores authentication in your platform's credential storage or a protected
local fallback. Use `atlas auth logout` to clear local authentication.

Official releases send product usage events by default: command, version,
platform, duration, outcome/error metadata, and model ID for model calls. Events
are associated with a random local installation ID. They do not include prompts,
auth/API tokens, media content, or file paths. Installers also send an installation ping.

To opt out of usage telemetry and the installation ping, set `ATLAS_TELEMETRY=0`
before installation and keep it set in your shell profile:

```sh
export ATLAS_TELEMETRY=0
```

In PowerShell: `$env:ATLAS_TELEMETRY="0"`. Model API requests still send the inputs
needed to execute your request, regardless of the telemetry setting.

## Uninstall

Optionally run `atlas auth logout` first to clear stored credentials.

```sh
# Shell installer, default prefix:
rm -f "$HOME/.local/bin/atlas"

# Or, for package-manager installations:
brew uninstall atlascloud
npm uninstall -g atlascloud-cli
```

For a custom install, remove `atlas` from your chosen install directory.
For the default Windows install:

```powershell
Remove-Item "$env:LOCALAPPDATA\AtlasCloud\bin\atlas.exe"
```

Remove that directory from your user PATH if it is no longer needed.

## Supported Models

<!-- ATLAS-MODELS:START lang=en campaign=cli groups=video,image,3d,llm -->
<!-- ⚠️ Auto-generated from the live model catalog by AtlasCloudAI/.github/scripts/update-models-readme.mjs — do not edit by hand. -->
- 🎬 **Video** (216) — MiniMax H3 Max · MiniMax H3 Fast · Gemini Omni 1.1 Flash · MiniMax H3 · Wan-3.0-Prime · Wan-3.0
- 🎨 **Image** (138) — GPT Image 2.5 Sunburst · GPT Image 2.5 Flare · Seedream v4.7 · MAI-Image-2.6-Flash
- 🧊 **3D** (14) — Seed3D 2.0 · Tripo H3.1 · Hunyuan 3D Rapid · Hunyuan 3D Pro
- 💬 **LLM** (72) — DeepSeek V4.1 Flash · DeepSeek V4 Pro 0813 · Grok 4.6 · DeepSeek V4 Flash 0731

- 📚 **Explore more** — [all 485 live models »](https://www.atlascloud.ai/models?utm_source=github&utm_campaign=cli)
<!-- ATLAS-MODELS:END -->

Model availability, parameters, and pricing vary by account and model. Use
`atlas models get` and `atlas generate cost` against the live catalog.

## Guides and support

- [Agent quickstart / Agent 上手指南](https://github.com/AtlasCloudAI/cli/blob/main/docs/AGENT_QUICKSTART.md)
- [CLI documentation](https://www.atlascloud.ai/docs/cli)
- [API caller workflows](https://github.com/AtlasCloudAI/cli/blob/main/docs/api-caller-workflows.md)
- [GitHub Issues](https://github.com/AtlasCloudAI/cli/issues) — include version, OS/arch, install method, and the failing command, with secrets removed.
- [Discord](https://discord.gg/MWmMr4q9es)

This public repository hosts installers, release artifacts, and package-manager
wrappers. The Go source repository is maintained separately.

## More Atlas Cloud tools

For Claude Code and Codex users of this CLI, start with the built-in Atlas skill above.
Other integrations:

- [Atlas Cloud MCP Server](https://github.com/AtlasCloudAI/mcp-server)
- [Atlas Cloud Skills](https://github.com/AtlasCloudAI/atlas-cloud-skills)
- [ComfyUI nodes](https://github.com/AtlasCloudAI/atlascloud_comfyui)
- [n8n nodes](https://github.com/AtlasCloudAI/n8n-nodes-atlascloud)
- [AtlasCloud website](https://www.atlascloud.ai)

## License

MIT
