# Complete media examples

These model IDs and inputs were checked against the live account catalog with
Atlas CLI **v0.1.36 on 2026-10-06**. The image example was generated and downloaded;
the video, audio, and 3D inputs passed `--explain` without submitting paid tasks.
Availability and required fields can change; inspect the live schema first.

Run `atlas auth login` once. Generation calls below are billable. Cost commands
only estimate; `--explain` checks the compiled input without submission or upload.
Outputs are saved under `./outputs/`.

## Product image

```sh
mkdir -p outputs
atlas models get google/nano-banana-2/text-to-image --json
atlas generate cost image google/nano-banana-2/text-to-image \
  -p "Studio product photograph of a matte black water bottle on a pale beige pedestal, soft side lighting, no text, square composition" \
  --resolution 1k --param output_format=png --json
atlas generate image google/nano-banana-2/text-to-image \
  -p "Studio product photograph of a matte black water bottle on a pale beige pedestal, soft side lighting, no text, square composition" \
  --resolution 1k --param output_format=png -o ./outputs/product.png
```

[View the actual demo result](../demo/product.png).

## Five-second video

```sh
mkdir -p outputs
atlas models get bytedance/seedance-2.0-fast/text-to-video --json
atlas generate cost video bytedance/seedance-2.0-fast/text-to-video \
  -p "A slow camera push toward a mountain" \
  --duration 5 --resolution 720p --param generate_audio=false --json
atlas generate video bytedance/seedance-2.0-fast/text-to-video \
  -p "A slow camera push toward a mountain" \
  --duration 5 --resolution 720p --param generate_audio=false -o ./outputs/
```

## Speech

This model requires `text`, not `prompt`. Its live schema offers the `Kore` voice.

```sh
mkdir -p outputs
atlas models get google/gemini-2.5-flash-tts --json
atlas generate cost audio google/gemini-2.5-flash-tts \
  --param 'text=Welcome to our store' --param voice=Kore --json
atlas generate audio google/gemini-2.5-flash-tts \
  --param 'text=Welcome to our store' --param voice=Kore -o ./outputs/
```

Using a directory lets the CLI choose the audio extension from the returned media.

## 3D mesh preview

`mode=preview` requests a mesh without the texture stage. The selected output
format is GLB; use an output directory for any additional returned artifacts.

```sh
mkdir -p outputs
atlas models get meshy-v7/text-to-3d --json
atlas generate cost 3d meshy-v7/text-to-3d \
  -p "A low-poly chair" --param mode=preview --param 'target_formats=["glb"]' --json
atlas generate 3d meshy-v7/text-to-3d \
  -p "A low-poly chair" --param mode=preview --param 'target_formats=["glb"]' -o ./outputs/
```

## Recover instead of resubmitting

For v0.1.36 generation JSON, the prediction ID is in `data.prediction.id`, and
file results are in `data.artifacts[].local`. Keep the original receipt. After
a local timeout, resume that prediction with `atlas generate wait`; do not
submit the same prompt again just to retrieve its result.

[Back to README](../README.md) · [Script and CI guide](api-caller-workflows.md)
