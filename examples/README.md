# Atlas Cloud CLI — Examples

Three layered, copy-pasteable API caller workflows. Each is self-contained and
uses documented `atlas` commands (`auth`, `models`, `generate`, `chat`).

| Script | Layer | What it shows |
|---|---|---|
| [`01-minimal.sh`](01-minimal.sh) | Discovery-first call | Check auth, list model catalog entries, inspect a schema, then make one chat call. |
| [`02-product-shot.sh`](02-product-shot.sh) | Cost-aware generation | Estimate an image request, then start an async product hero image job. |
| [`03-pipeline.sh`](03-pipeline.sh) | Scripted pipeline | Idea → LLM prompts → cost checks → async image and video jobs. |

## Prerequisites

1. Install the CLI — see the [root README](../README.md#install).
2. Install `jq` if you want to run the JSON automation examples unchanged.
3. Authenticate once:

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
