# atlascloud-cli

AtlasCloud CLI — call LLM, image, and video models from your terminal.

## Install

```bash
npm install -g atlascloud-cli
```

The postinstall step downloads the prebuilt `atlas` binary for your platform from the public GitHub release and verifies the archive against `checksums.txt`.

Supported npm platforms: macOS and Linux on x64 or arm64. Windows package-manager support will be added separately.

## Usage

```bash
atlas auth login
atlas chat "explain UUID v7"
atlas generate image google/nano-banana-2/text-to-image -p "a cat"
atlas --help
```

## Links

- Releases: https://github.com/AtlasCloudAI/cli/releases
- AtlasCloud: https://atlascloud.ai
