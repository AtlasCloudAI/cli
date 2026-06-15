#!/usr/bin/env bash
# 03 — Pipeline: one idea -> LLM storyboard -> image AND video, chained.
# Uses the LLM to expand a single idea into detailed prompts, then feeds those
# prompts straight into image + video generation. Only documented commands.
# Prerequisite: `atlas auth login` (once). See examples/README.md.
set -euo pipefail

IDEA="${1:-a cozy independent coffee shop on a rainy evening}"
echo "Idea: ${IDEA}"
echo

echo "== 1/4  Expand idea into an image prompt (LLM) =="
IMAGE_PROMPT="$(atlas chat "Turn this idea into ONE vivid text-to-image prompt (single line, no preamble): ${IDEA}")"
echo "Image prompt: ${IMAGE_PROMPT}"

echo
echo "== 2/4  Generate the still =="
atlas generate image google/nano-banana-2/text-to-image -p "${IMAGE_PROMPT}"

echo
echo "== 3/4  Expand idea into a 5s cinematic video prompt (LLM) =="
VIDEO_PROMPT="$(atlas chat "Turn this idea into ONE 5-second cinematic text-to-video prompt with a camera move (single line, no preamble): ${IDEA}")"
echo "Video prompt: ${VIDEO_PROMPT}"

echo
echo "== 4/4  Generate the clip =="
atlas generate video bytedance/seedance-2.0-fast/text-to-video -p "${VIDEO_PROMPT}"

echo
echo "Done. Tip: add --json to any command to capture IDs/URLs for further automation."
