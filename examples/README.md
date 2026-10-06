# Atlas CLI script examples

These scripts target public CLI **v0.1.36** and require `atlas` and `jq`.
Run from this repository after `atlas auth login`; each script submits the
billable calls listed below. An estimate is informational and does not enforce
an account spending limit.

| Script | Billable calls |
|---|---|
| [01-minimal.sh](01-minimal.sh) | One chat request |
| [02-product-shot.sh](02-product-shot.sh) | One image generation, returned asynchronously |
| [03-pipeline.sh](03-pipeline.sh) | Two chat requests, one image generation, and one video generation |
| [04-ci-json.sh](04-ci-json.sh) | One chat request after API-key login |

```sh
bash examples/01-minimal.sh
bash examples/02-product-shot.sh
```

For CI, inject `ATLASCLOUD_API_KEY` through the runner's secret store, then run
`bash examples/04-ci-json.sh`. That script uses a temporary `ATLAS_TOKEN_FILE`
and removes it on exit; it does not replace a developer's stored login.

Generation IDs are read from `.data.prediction.id`. Chat text is read from
`.choices[0].message.content`; command substitution is noninteractive and returns
JSON, not plain text. Read the [JSON and recovery guide](../docs/api-caller-workflows.md)
before changing these expressions or upgrading your CLI.

The shell flow and field extraction are tested against v0.1.36 response shapes.
The README demo is a live generated/downloaded image; video, audio, and 3D
[complete inputs](../docs/MEDIA_EXAMPLES.md) are checked with live schema and
`--explain`, without submitting those paid tasks.

[Install](../README.md#install) · [Agent guide](../docs/AGENT_QUICKSTART_EN.md)
