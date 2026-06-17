# atlascloud-cli

AtlasCloud CLI — call Atlas Cloud LLM, image, video, and audio APIs from your terminal, scripts, and CI jobs.

## Install

```bash
npm install -g atlascloud-cli
```

The postinstall step downloads the prebuilt `atlas` binary for your platform from the public GitHub release and verifies the archive against `checksums.txt`. This package installs the CLI binary; it is not a JavaScript SDK.

## Usage

Authenticate once, then choose the command path for the API task:

```bash
atlas auth login
atlas auth status
```

```bash
# Discover models and parameters without creating model calls.
atlas models list --type video --json
atlas models get bytedance/seedance-2.0-fast/text-to-video --json

# Estimate cost before generation.
atlas generate cost video bytedance/seedance-2.0-fast/text-to-video \
  -p "A product shot slowly rotates on a clean white background" \
  --duration 5 \
  --resolution 720p \
  --json

# Make a chat request.
atlas chat --model deepseek-ai/DeepSeek-V3-0324 "Return only status=ok"

# Start async generation for scripts.
atlas generate image google/nano-banana-2/text-to-image \
  -p "minimal product photo on a white background" \
  --no-wait --json
```

Run `atlas --help` or `atlas <command> --help` for the full command reference.

## Links

- Releases: https://github.com/AtlasCloudAI/cli/releases
- AtlasCloud: https://atlascloud.ai
