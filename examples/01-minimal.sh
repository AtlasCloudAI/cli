#!/usr/bin/env bash
# 01 — Minimal call: one chat completion + one image.
# Prerequisite: `atlas auth login` (once). See examples/README.md.
set -euo pipefail

echo "== Chat =="
atlas chat "Give me three taglines for a productivity app. One line each."

echo
echo "== Image =="
atlas generate image google/nano-banana-2/text-to-image \
  -p "a minimalist productivity app icon, soft gradient, rounded square, 3D"
