# Atlas Cloud CLI — Examples

Three layered, copy-pasteable scripts. Each is self-contained and uses only
documented `atlas` commands (`auth`, `chat`, `models`, `generate`).

| Script | Layer | What it shows |
|---|---|---|
| [`01-minimal.sh`](01-minimal.sh) | Minimal call | The smallest possible chat + image generation. |
| [`02-product-shot.sh`](02-product-shot.sh) | Real-world scenario | E-commerce: generate a product hero image, then write its marketing copy with an LLM. |
| [`03-pipeline.sh`](03-pipeline.sh) | Pipeline | Idea → LLM storyboard → image **and** video, chained end-to-end. |

## Prerequisites

1. Install the CLI — see the [root README](../README.md#install).
2. Authenticate once:

   ```bash
   atlas auth login                              # interactive
   atlas auth login --token "$ATLASCLOUD_API_KEY"   # CI / non-interactive
   ```

   Get a free key at the [Atlas Cloud console](https://www.atlascloud.ai/console/api-keys?utm_source=github&utm_campaign=cli).

## Run

```bash
chmod +x examples/*.sh
./examples/01-minimal.sh
```
