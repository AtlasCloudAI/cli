# API Caller Workflows

Atlas CLI is useful when you want API calls from shell scripts, backend jobs, CI,
or human-operated terminals without writing a small SDK wrapper first. This
guide focuses on repeatable command patterns, JSON output, and safe discovery
before billable calls.

## 1. Authenticate for the environment

For a developer machine, use the interactive login:

```bash
atlas auth login
atlas auth status
```

For CI or a service job, pass an API key explicitly:

```bash
export ATLASCLOUD_API_KEY="..."
atlas auth login --token "$ATLASCLOUD_API_KEY" --json
```

In ephemeral runners, isolate credentials so the job does not depend on a
cached login:

```bash
export XDG_CONFIG_HOME="${RUNNER_TEMP:-/tmp}/atlas-cli-config"
atlas auth login --token "$ATLASCLOUD_API_KEY" --json
```

## 2. Discover models instead of hard-coding them

Model availability, input fields, and pricing can change. Use the live catalog
before wiring a model into an automation path.

```bash
atlas models list --type chat --json | jq -r '.models[].id'
atlas models list --type image --json | jq -r '.models[].id'
atlas models list --type video --json | jq -r '.models[].id'

atlas models search seedance --type video --json
atlas models get bytedance/seedance-2.0-fast/text-to-video --json
```

## 3. Estimate cost before generation

Cost checks call the pricing endpoint. They are the right preflight for CI,
batch generation, and user-facing tools that need budget controls.

```bash
atlas generate cost image google/nano-banana-2/text-to-image \
  -p "minimal product photo on a white background" \
  --json

atlas generate cost video bytedance/seedance-2.0-fast/text-to-video \
  -p "A product shot slowly rotates on a clean white background" \
  --duration 5 \
  --resolution 720p \
  --param generate_audio=false \
  --json
```

## 4. Use JSON for scripts and CI

Use `--json` whenever another process consumes the output. Extract stable IDs
with `jq`, then pass them to follow-up commands.

```bash
JOB_JSON="$(atlas generate image google/nano-banana-2/text-to-image \
  -p "minimal product photo on a white background" \
  --no-wait \
  --json)"

PREDICTION_ID="$(printf '%s\n' "$JOB_JSON" | jq -r '.id')"
atlas generate wait "$PREDICTION_ID" --json
```

For chat calls, the JSON output is the raw chat completion response:

```bash
atlas chat --model deepseek-ai/DeepSeek-V3-0324 \
  --json \
  "Return only a compact JSON object with status=ok"
```

## 5. Recommended script shape

Use this order for production-like automation:

1. Validate `ATLASCLOUD_API_KEY`.
2. Set an isolated `XDG_CONFIG_HOME` for CI runners.
3. Log in with `atlas auth login --token ... --json`.
4. Fetch model metadata with `atlas models get ... --json`.
5. Estimate generation cost before creating image or video jobs.
6. Start long-running generation with `--no-wait --json`.
7. Store the prediction ID and resume with `atlas generate get` or `atlas generate wait`.

Runnable examples are in [`../examples`](../examples):

- [`01-minimal.sh`](../examples/01-minimal.sh) - discovery-first chat call.
- [`02-product-shot.sh`](../examples/02-product-shot.sh) - cost-aware image generation.
- [`03-pipeline.sh`](../examples/03-pipeline.sh) - LLM prompt expansion plus image/video jobs.
- [`04-ci-json.sh`](../examples/04-ci-json.sh) - non-interactive CI JSON call.
