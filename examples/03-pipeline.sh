#!/usr/bin/env bash
# 03 — Pipeline: one idea -> LLM prompts -> image and video jobs.
# Uses discovery, JSON-friendly calls, cost checks, and async generation.
# Prerequisite: `atlas auth login` (once). See examples/README.md.
set -euo pipefail

IDEA="${1:-a cozy independent coffee shop on a rainy evening}"
CHAT_MODEL="deepseek-ai/DeepSeek-V3-0324"
IMAGE_MODEL="google/nano-banana-2/text-to-image"
VIDEO_MODEL="bytedance/seedance-2.0-fast/text-to-video"

echo "Idea: ${IDEA}"
echo

echo "== 1/6  Inspect selected models =="
atlas models get "$IMAGE_MODEL" --json
atlas models get "$VIDEO_MODEL" --json

echo
echo "== 2/6  Expand idea into an image prompt (LLM) =="
IMAGE_PROMPT="$(atlas chat --model "$CHAT_MODEL" "Turn this idea into ONE vivid text-to-image prompt (single line, no preamble): ${IDEA}")"
echo "Image prompt: ${IMAGE_PROMPT}"

echo
echo "== 3/6  Estimate and start the still image job =="
atlas generate cost image "$IMAGE_MODEL" -p "$IMAGE_PROMPT" --json
IMAGE_JOB_JSON="$(atlas generate image "$IMAGE_MODEL" -p "$IMAGE_PROMPT" --no-wait --json)"
echo "$IMAGE_JOB_JSON"
IMAGE_PREDICTION_ID="$(printf '%s\n' "$IMAGE_JOB_JSON" | jq -r '.id')"

echo
echo "== 4/6  Expand idea into a 5s cinematic video prompt (LLM) =="
VIDEO_PROMPT="$(atlas chat --model "$CHAT_MODEL" "Turn this idea into ONE 5-second cinematic text-to-video prompt with a camera move (single line, no preamble): ${IDEA}")"
echo "Video prompt: ${VIDEO_PROMPT}"

echo
echo "== 5/6  Estimate and start the video job =="
atlas generate cost video "$VIDEO_MODEL" -p "$VIDEO_PROMPT" --duration 5 --resolution 720p --json
VIDEO_JOB_JSON="$(atlas generate video "$VIDEO_MODEL" -p "$VIDEO_PROMPT" --duration 5 --resolution 720p --no-wait --json)"
echo "$VIDEO_JOB_JSON"
VIDEO_PREDICTION_ID="$(printf '%s\n' "$VIDEO_JOB_JSON" | jq -r '.id')"

echo
echo "== 6/6  Next step =="
jq -n \
  --arg image_prediction_id "$IMAGE_PREDICTION_ID" \
  --arg video_prediction_id "$VIDEO_PREDICTION_ID" \
  '{
    image_prediction_id: $image_prediction_id,
    video_prediction_id: $video_prediction_id,
    wait_commands: [
      "atlas generate wait " + $image_prediction_id,
      "atlas generate wait " + $video_prediction_id
    ]
  }'
