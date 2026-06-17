#!/usr/bin/env bash
# 01 — Discovery-first call: inspect the API surface, then make one chat call.
# Prerequisite: `atlas auth login` (once). See examples/README.md.
set -euo pipefail

echo "== Auth status =="
atlas auth status

echo
echo "== Catalog sample =="
atlas models list --type chat --json

echo
echo "== Model schema =="
atlas models get deepseek-ai/DeepSeek-V3-0324 --json

echo
echo "== Chat API call =="
atlas chat --model deepseek-ai/DeepSeek-V3-0324 \
  "Return only a JSON object with status=ok and source=atlas-cli"
