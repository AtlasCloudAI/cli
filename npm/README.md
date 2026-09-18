# atlascloud-cli

AtlasCloud CLI — call Atlas Cloud LLM, image, video, and audio APIs from your terminal, scripts, and CI jobs.

## Install

```bash
npm install -g atlascloud-cli
```

The postinstall step downloads the prebuilt `atlas` binary for your platform from the public GitHub release and verifies the archive against `checksums.txt`. This package installs the CLI binary; it is not a JavaScript SDK.

## Usage

### Use Atlas with your coding agent

```sh
atlas auth status --json
atlas auth login                    # only if not already logged in
atlas skills install --agent claude # or: --agent codex
```

Start a new agent session and ask: "Use Atlas to create a product photo from
this reference. Preserve the logo and estimate the cost first."
The installed entry reads the task guide from your CLI, so detailed instructions
stay aligned with the installed version. Existing custom skills are preserved.
For project skills use `atlas skills install --dir .claude/skills`.

[Agent setup, examples and MCP support](https://github.com/AtlasCloudAI/cli/blob/main/docs/AGENT_QUICKSTART.md).
This package includes `atlas` only; the experimental local stdio MCP server
requires a separate source build. No public remote MCP endpoint is provided.

### Use Atlas directly

Authenticate once, then choose the command path for the API task:

```bash
atlas auth login
atlas auth status
```

```bash
# Discover models and parameters without creating model calls.
atlas models list --type video --json
atlas models list --type audio --json
atlas models list --type 3d --json
atlas models get bytedance/seedance-2.0-fast/text-to-video --json

# Estimate cost before generation.
atlas generate cost video bytedance/seedance-2.0-fast/text-to-video \
  -p "A product shot slowly rotates on a clean white background" \
  --duration 5 \
  --resolution 720p \
  --json

# Make a chat request.
atlas chat --model deepseek-ai/deepseek-v3.2 "Return only status=ok"

# Chat buffers the response with a bounded 10-minute default; override per request.
atlas chat --timeout 15m --max-tokens 6500 --model anthropic/claude-sonnet-4.5-20250929 "Write a detailed report"

# Start async generation for scripts.
atlas generate image google/nano-banana-2/text-to-image \
  -p "minimal product photo on a white background" \
  --no-wait --json

# Account-catalog-gated audio and 3D workflows.
atlas generate audio AUDIO_MODEL -p "Read this sentence" --no-download
atlas generate 3d THREE_D_MODEL -p "A low-poly chair" --no-download
```

Audio and 3D commands stop before submission if the current account catalog
does not expose the selected model and schema. Cost commands never upload
local files; provide an HTTP(S) URL for URL-only cost inputs.

Run `atlas --help` or `atlas <command> --help` for the full command reference.

## Links

- Releases: https://github.com/AtlasCloudAI/cli/releases
- AtlasCloud: https://atlascloud.ai
