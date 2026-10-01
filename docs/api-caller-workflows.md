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
atlas models get bytedance/seedance-2.5/text-to-video --json
```

## 3. Estimate cost before generation

Cost checks call the pricing endpoint. They are the right preflight for CI,
batch generation, and user-facing tools that need budget controls.

```bash
atlas generate cost image google/nano-banana-2/text-to-image \
  -p "minimal product photo on a white background" \
  --json

atlas generate cost video bytedance/seedance-2.5/text-to-video \
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

## 6. Recover after an interrupted wait

Keep the prediction ID returned by a successful submission. If the terminal
closes or the local wait times out, inspect that same job before creating
another generation:

```bash
atlas generate get "$PREDICTION_ID" --json --no-download
atlas generate wait "$PREDICTION_ID" --timeout 10m --json --no-download
```

`get` inspects the existing prediction; `wait` is an alias for `get --wait`.
`--timeout` limits how long this CLI invocation waits. A local timeout alone
does not establish that the remote prediction failed or was cancelled. Reusing
the ID avoids submitting another job merely to check the first one.

Once the existing prediction completes, retrieve its output to an explicit path:

```bash
atlas generate get "$PREDICTION_ID" --wait --output ./result.mp4
```

Choose an output path appropriate for the generated media. `--no-download`
keeps the command focused on status/response handling; omit it when requesting
a download. Use `--overwrite` only when intentionally replacing an existing
local file. Check the exit status and returned response before the next pipeline
step. If submission failed before you received an ID, this recovery path cannot
identify a job on its own; inspect the original error and account state before
retrying.

### Common automation questions

- **Why is a model in the catalog but generation stops before submission?**
  The command needs the corresponding generation route and schema for the
  selected model. Inspect `atlas models get MODEL_ID --json` and the installed
  version's command help; catalog membership alone is not a route guarantee.
- **Does `generate cost` create a job?** It calls the pricing endpoint. It is an
  estimate for the chosen inputs; creating a prediction is a separate command.
- **Which version should a bug report describe?** Record `atlas version`, the
  installation method and exact command. The npm package wraps a prebuilt CLI;
  this distribution repository does not contain the Go source or an SDK.

[Back to installation and support](../README.md) · [Release changes](../CHANGELOG.md)
