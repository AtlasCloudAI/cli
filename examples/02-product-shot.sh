#!/usr/bin/env bash
# 02 — Cost-aware generation: e-commerce product launch.
# Estimate an image request, then start an async product hero image job.
# Prerequisite: `atlas auth login` (once). See examples/README.md.
set -euo pipefail

PRODUCT="a matte-black stainless steel insulated water bottle"
MODEL="google/nano-banana-2/text-to-image"
PROMPT="studio product photo of ${PRODUCT}, on a marble surface, soft window light, shallow depth of field, e-commerce hero shot, 4k"

echo "== 1/3  Inspect image model =="
atlas models get "$MODEL" --json

echo
echo "== 2/3  Estimate image cost =="
atlas generate cost image "$MODEL" -p "$PROMPT" --json

echo
echo "== 3/3  Start async hero image job =="
JOB_JSON="$(atlas generate image "$MODEL" -p "$PROMPT" --no-wait --json)"
echo "$JOB_JSON"
PREDICTION_ID="$(printf '%s\n' "$JOB_JSON" | jq -r '.id')"

echo
echo "Prediction id: ${PREDICTION_ID}"
echo "Wait later with: atlas generate wait ${PREDICTION_ID}"
echo
echo "Optional copy draft:"
atlas chat "Write a 40-word product description and 5 bullet features for ${PRODUCT}. Tone: premium, minimal."
