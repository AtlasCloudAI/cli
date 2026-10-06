#!/usr/bin/env bash
# 01 — Discovery-first call: inspect the API surface, then make one chat call.
# Prerequisite: `atlas auth login` (once). See examples/README.md.
set -euo pipefail

echo "== Auth status =="
atlas auth ensure --non-interactive

echo
echo "== Catalog sample =="
atlas models list --type chat --json | jq '[.models[:3][] | {id, type}]'

echo
echo "== Model schema =="
atlas models get deepseek-ai/deepseek-v3.2 --json

echo
echo "== Chat API call =="
atlas chat --model deepseek-ai/deepseek-v3.2 \
  "Return only a JSON object with status=ok and source=atlas-cli"
