#!/usr/bin/env bash
# Run from the repository root. Requires atlas, jq, and an existing login.
# Submits one billable image on the first run; subsequent runs resume its receipt.
# --overwrite replaces the committed demo photo at this specific sample path.
set -euo pipefail
trap 'printf "\nDEMO_STOPPED\n"' EXIT
export ATLAS_AUTO_UPDATE=0 ATLAS_TELEMETRY=0

MODEL="google/nano-banana-2/text-to-image"
PROMPT="Studio product photograph of a matte black water bottle on a pale beige pedestal, soft side lighting, no text, square composition"

printf '$ atlas version\n'
atlas version
printf '\nRequest: %s\n\n' "$PROMPT"
# shellcheck disable=SC2016 # Display the same variable used by the command below.
printf '$ atlas generate cost image %s -p "$PROMPT" --resolution 1k --param output_format=png --json\n' "$MODEL"
atlas generate cost image "$MODEL" -p "$PROMPT" --resolution 1k --param output_format=png --json | jq -c '{model, price}'

if [[ -s demo/receipt.json ]]; then
  PREDICTION_ID=$(jq -er '.data.prediction.id' demo/receipt.json)
  printf '\nResuming the accepted task; no new generation is submitted.\n'
  printf '$ atlas generate wait %s -o demo/product.png --overwrite --json\n' "$PREDICTION_ID"
  atlas generate wait "$PREDICTION_ID" -o demo/product.png --overwrite --json \
    | jq -c '{outcome, files: [.data.artifacts[].local | {status, path, bytes}]}'
else
  # Keep the receipt even if waiting fails. Do not rerun a submission just to retrieve it.
  # shellcheck disable=SC2016 # Display the same variable used by the command below.
  printf '\n$ atlas generate image %s -p "$PROMPT" --resolution 1k --param output_format=png -o demo/product.png --overwrite --json\n' "$MODEL"
  atlas generate image "$MODEL" -p "$PROMPT" --resolution 1k --param output_format=png -o demo/product.png --overwrite --json > demo/receipt.json
  jq -c '{outcome, files: [.data.artifacts[].local | {status, path, bytes}]}' demo/receipt.json
fi
printf '\nDEMO_COMPLETE\n'
