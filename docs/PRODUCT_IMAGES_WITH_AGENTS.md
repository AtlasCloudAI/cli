# Generate product images with Claude Code or Codex

Use the Atlas Cloud CLI and its agent skill to create product photography from a
text description or a reference image. The agent checks model inputs and cost,
then saves the generated image in your project.

## Install and connect Atlas

Follow the [installation instructions](https://github.com/AtlasCloudAI/cli#install),
then run:

```sh
atlas auth ensure --non-interactive --json
# If credentials are missing or cannot be refreshed:
atlas auth login

# Choose your agent:
atlas skills install --agent claude
# Or:
atlas skills install --agent codex
```

Start a new Claude Code or Codex session after installing the skill. Setup does
not submit a paid generation. [Full agent setup guide](AGENT_QUICKSTART_EN.md).

## Ask for a product photo

For a new product concept:

> Use Atlas to create a square studio product photo of a matte black water bottle
> on a beige pedestal. Use soft side lighting and no text. Inspect an appropriate
> image model and show me the estimated cost before generating. After I approve,
> submit one task and save the result under outputs/.

For an existing product, attach the reference image or give its actual path:

> Use Atlas to create a studio product photo from this reference. Keep the shape,
> packaging, colors, and logo. Choose a model that accepts the reference image,
> inspect its required inputs, and show me the cost estimate before generating.
> After I approve, submit one task and save the result under outputs/.

A text-to-image model does not accept a reference just because the prompt mentions
one. Let the agent inspect an image-editing model for the second task. Check the
result yourself: a request to preserve a logo is not a guarantee of exact fidelity.

## See a real result

![Atlas-generated matte black water bottle on a beige pedestal](https://raw.githubusercontent.com/AtlasCloudAI/cli/main/demo/product.png)

This image was generated and downloaded with CLI v0.1.36 on 2026-10-06 using
`google/nano-banana-2/text-to-image`. The recorded estimate was $0.08 for that run;
it is not a current price quote. The [terminal demo](https://github.com/AtlasCloudAI/cli#readme)
shows cost estimation and retrieval of the same accepted task.
For executable text-to-image commands, see [the product image example](https://github.com/AtlasCloudAI/cli/blob/main/docs/MEDIA_EXAMPLES.md#product-image).

## Check the delivery and recover

Ask the agent to report the model, prediction ID, final status, and saved file
paths. Open the image and inspect it before requesting another paid revision.
If the local wait or download fails, ask:

> Continue this Atlas prediction ID and save its result. Do not generate it again.

The agent can use `atlas generate get` or `atlas generate wait` to retrieve the
existing task. If its ID is missing, inspect `atlas generate ops list` first.

[Animate the image from your terminal](IMAGE_TO_VIDEO.md) ·
[CLI documentation](https://www.atlascloud.ai/docs/cli) ·
[Back to README](https://github.com/AtlasCloudAI/cli#readme)
