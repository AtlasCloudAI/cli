#!/usr/bin/env bash
# 04 - CI JSON: authenticate from ATLASCLOUD_API_KEY and emit machine-readable output.
# Prerequisites: atlas, jq, and ATLASCLOUD_API_KEY in the environment.
set -euo pipefail

: "${ATLASCLOUD_API_KEY:?Set ATLASCLOUD_API_KEY before running this script.}"

CHAT_MODEL="${CHAT_MODEL:-deepseek-ai/DeepSeek-V3-0324}"
PROMPT="${1:-Return only a compact JSON object with status=ok and source=atlas-cli.}"
WORKDIR="${RUNNER_TEMP:-${TMPDIR:-/tmp}}/atlas-cli-ci-${RANDOM}"

mkdir -p "$WORKDIR"
export XDG_CONFIG_HOME="$WORKDIR/config"
trap 'rm -rf "$WORKDIR"' EXIT

echo "== 1/3  Authenticate =="
atlas auth login --token "$ATLASCLOUD_API_KEY" --json >/dev/null
atlas auth status --json

echo
echo "== 2/3  Validate model =="
atlas models get "$CHAT_MODEL" --json | jq '{id, type, provider, status}'

echo
echo "== 3/3  Call chat API =="
atlas chat --model "$CHAT_MODEL" --json "$PROMPT" \
  | jq '{id, model, content: .choices[0].message.content, usage}'
