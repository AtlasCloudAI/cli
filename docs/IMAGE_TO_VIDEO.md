# Turn an image into a video from your terminal

Use the Atlas Cloud CLI to animate an existing image with an image-to-video
model, check the estimated cost, and download the video. The example below uses
Seedance 2.0 Fast with a five-second duration at 720p and generated audio disabled.

The model schema and compiled input were checked with CLI **v0.1.36 on
2026-10-06**. No paid video task was submitted during this documentation check;
the commands below are a runnable workflow, not evidence of a generated video.

## Install and prepare an image

Follow the [installation instructions](https://github.com/AtlasCloudAI/cli#install)
and run `atlas auth login` once, or `atlas auth ensure --non-interactive` for an
existing session. Save your source image as `input.png` in the current directory.
Use an image you have permission to upload.

This model's checked schema accepts JPEG, PNG, WebP, BMP, TIFF, or GIF, with
width and height strictly between 300 and 6000 pixels, aspect ratio between
0.4 and 2.5, and a file smaller than 30 MB. Inspect the current schema before
submitting because model requirements and availability can change.

## Inspect inputs and estimate cost

```sh
atlas models get bytedance/seedance-2.0-fast/image-to-video --json
atlas generate video bytedance/seedance-2.0-fast/image-to-video --help

# Compile inputs only: no submission or upload.
atlas generate video bytedance/seedance-2.0-fast/image-to-video \
  --image @./input.png -p "A slow camera push in, gentle natural motion" \
  --duration 5 --resolution 720p --param generate_audio=false --explain --json

# Estimate only: no generation submission.
atlas generate cost video bytedance/seedance-2.0-fast/image-to-video \
  --image @./input.png -p "A slow camera push in, gentle natural motion" \
  --duration 5 --resolution 720p --param generate_audio=false --json
```

`@./input.png` identifies a local file. Generation uploads it as needed; an
HTTPS image URL is also supported. Cost estimates depend on the current model,
settings, and pricing. `--explain` validates the input shape, not provider acceptance
or the quality of a future video.

## Generate and save the video

The next command submits a **billable** task. It waits for completion and saves
the returned files under `outputs/`:

```sh
mkdir -p outputs
atlas generate video bytedance/seedance-2.0-fast/image-to-video \
  --image @./input.png -p "A slow camera push in, gentle natural motion" \
  --duration 5 --resolution 720p --param generate_audio=false -o ./outputs/
```

Inspect the reported status and local file paths, then open the saved video.
Using an output directory lets the CLI use the provider's returned file extension.

## Resume after a timeout or failed download

Find the original prediction ID in the submission receipt or local task list:

```sh
atlas generate ops list --json
```

Replace `PREDICTION_ID` below with that ID:

```sh
atlas generate get PREDICTION_ID --json
atlas generate wait PREDICTION_ID -o ./outputs/ --json
```

A local timeout does not mean the remote task failed. Retrieve the accepted task
before submitting another billable generation.

## Use Claude Code or Codex instead

[Install the Atlas agent skill](AGENT_QUICKSTART_EN.md), attach the image, and ask:

> Use Atlas to turn this image into a five-second video with a slow camera push.
> Inspect an image-to-video model and its required inputs. Show the cost estimate
> before submitting. After I approve, create one task and save the video under
> outputs/. If waiting fails, resume that task instead of generating it again.

[Product image guide](PRODUCT_IMAGES_WITH_AGENTS.md) ·
[CLI documentation](https://www.atlascloud.ai/docs/cli) ·
[Back to README](https://github.com/AtlasCloudAI/cli#readme)
