# Scripts and CI with Atlas CLI

Examples in this guide target the current public release, **v0.1.36**. Check
`atlas version` before using JSON paths in automation. Model inputs and pricing
come from the live catalog; generation calls are billable.

## Authenticate

For a developer machine, run `atlas auth login` once, then use
`atlas auth ensure --non-interactive --json` to check and refresh the existing
session. `auth status` only reads local credentials.

For CI, inject `ATLASCLOUD_API_KEY` through the runner's secret store. Isolate
credentials with `ATLAS_TOKEN_FILE`, which works across supported platforms:

```sh
export ATLAS_TOKEN_FILE="${RUNNER_TEMP:-/tmp}/atlas-cli-token.json"
atlas auth login --token "$ATLASCLOUD_API_KEY" --json >/dev/null
```

Remove that file when the job ends. The complete [CI example](../examples/04-ci-json.sh)
uses a temporary directory and an exit trap. `XDG_CONFIG_HOME` controls the Linux
fallback location; it does not isolate the macOS or Windows credential store.
The CLI does not automatically load `.env`: exporting a variable alone is also
insufficient without the explicit `auth login --token` command.

## Discover and estimate

```sh
atlas models list --type image --json | jq -r '.models[].id'
atlas models search seedance --type video --json
atlas models get google/nano-banana-2/text-to-image --json
atlas generate cost image google/nano-banana-2/text-to-image \
  -p "A matte black water bottle on a beige pedestal, studio lighting" --json
```

Cost checks do not submit a generation or upload local files. For media URL inputs,
use an existing HTTP(S) URL. `--explain` prints compiled input without submission
or upload. See [complete media inputs](MEDIA_EXAMPLES.md) for other types.

## Read the right JSON fields

In v0.1.36, generation and operation results use an envelope. Several older
command surfaces still return their data directly:

| Command | JSON path in v0.1.36 |
|---|---|
| `models list/search` | `.models[]` |
| `models get` | `.id`, `.params` |
| `generate cost` | `.price` |
| `chat` | `.choices[0].message.content` |
| `generate image/video/audio/3d/get/wait` | `.outcome`, `.data.prediction.id`, `.data.artifacts[]` |
| `generate ops list` | `.data.operations[]` |

Generation fields include `schema_version`, `command`, `outcome`, `data`,
`errors`, and `warnings`. `outcome=pending` means the job is accepted but not
complete. `outcome=partial` can mean remote success with a local delivery problem.
Check the exit status as well as the receipt. After upgrading, consult that
version's embedded guide (`atlas skills read atlas --raw`) before assuming the
same JSON paths. These examples do not add fallback parsing for other versions.

## Submit once, then resume

```sh
set -euo pipefail
mkdir -p outputs
atlas generate image google/nano-banana-2/text-to-image \
  -p "A matte black water bottle on a beige pedestal, studio lighting" \
  --no-wait --json > outputs/submission.json

PREDICTION_ID=$(jq -er '.data.prediction.id' outputs/submission.json)
atlas generate wait "$PREDICTION_ID" -o ./outputs/ --json > outputs/result.json
jq '{outcome, files: [.data.artifacts[].local]}' outputs/result.json
```

Save the receipt before extracting its ID so an error or interrupted wait does
not lose the original task. `jq -e` makes a missing field fail instead of passing
`null` to another command. A successful submission is not a downloaded file.

## Chat output in pipelines

Non-terminal stdout is JSON even without `--json`. Extract the actual text
before passing a chat response into another request:

```sh
set -euo pipefail
IMAGE_PROMPT=$(atlas chat --model deepseek-ai/deepseek-v3.2 --json \
  "Write one short product photography prompt for a black water bottle" \
  | jq -er '.choices[0].message.content')
atlas generate cost image google/nano-banana-2/text-to-image -p "$IMAGE_PROMPT" --json
```

The chat call is billable; the cost check does not generate an image. Use
`--max-tokens` and `--timeout` when you need a specific response limit or deadline.

## Recover after a timeout

```sh
atlas generate get "$PREDICTION_ID" --json --no-download
atlas generate wait "$PREDICTION_ID" --timeout 10m -o ./outputs/ --json
```

These query the existing task. They do not submit a replacement. Local receipts
can also be inspected with `atlas generate ops list` and resumed with
`atlas generate ops resume OPERATION_ID`. If no prediction ID was acknowledged,
inspect the operation receipt and contact support before creating a new job.

## Installation options

For the shell installer, pass custom options to `sh`:

```sh
INSTALLER=https://raw.githubusercontent.com/AtlasCloudAI/cli/main/install.sh
curl -fsSL "$INSTALLER" | sh -s -- --prefix="$HOME/bin/atlas-install"
curl -fsSL "$INSTALLER" | sh -s -- --version=0.1.36
```

The prefix gets a `bin/atlas` executable; add that `bin` directory to PATH.
On Windows, set `ATLAS_INSTALL_DIR` or `ATLAS_VERSION` before running the installer.
A version-selected native install can still auto-update; set `ATLAS_AUTO_UPDATE=0`
to retain it. For manual installs, download the matching archive from
[Releases](https://github.com/AtlasCloudAI/cli/releases) and add `atlas` to PATH.

## Runnable scripts

- [Discovery-first chat](../examples/01-minimal.sh): existing-session check, catalog, schema, one chat call.
- [Product image](../examples/02-product-shot.sh): one cost-aware async image submission.
- [Prompt pipeline](../examples/03-pipeline.sh): chat text extraction, then image/video submissions.
- [CI JSON](../examples/04-ci-json.sh): isolated API-key login and JSON chat output.

Scripts use the v0.1.36 JSON paths above. See [examples/README.md](../examples/README.md)
for prerequisites, charges, and verification scope.

[Back to README](../README.md)
