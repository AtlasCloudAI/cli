#!/usr/bin/env bash
# 02 — Real-world scenario: e-commerce product launch.
# Generate a hero image for a product, then write its marketing copy with an LLM.
# Prerequisite: `atlas auth login` (once). See examples/README.md.
set -euo pipefail

PRODUCT="a matte-black stainless steel insulated water bottle"

echo "== 1/2  Hero image =="
atlas generate image bytedance/seedream-v4.5 \
  -p "studio product photo of ${PRODUCT}, on a marble surface, soft window light, shallow depth of field, e-commerce hero shot, 4k"

echo
echo "== 2/2  Marketing copy =="
atlas chat "Write a 40-word product description and 5 bullet features for ${PRODUCT}. Tone: premium, minimal."
