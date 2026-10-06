# Create with Atlas and your AI coding agent

Describe a task in natural language. Your agent uses Atlas to discover models,
check inputs and cost, generate media, and save the result.

[中文指南](AGENT_QUICKSTART.md) · [Install and command reference](https://github.com/AtlasCloudAI/cli#readme)

## 1. Install Atlas

macOS / Linux:

```sh
curl -fsSL https://raw.githubusercontent.com/AtlasCloudAI/cli/main/install.sh | sh
```

Windows PowerShell:

```powershell
irm https://raw.githubusercontent.com/AtlasCloudAI/cli/main/install.ps1 | iex
```

Or use `npm install -g atlascloud-cli`. Verify with `atlas version`.
If the shell installer reports a missing PATH entry, add `~/.local/bin`.

## 2. Use your existing login

```sh
atlas auth ensure --non-interactive --json
# If credentials are missing or can no longer be refreshed:
atlas auth login
```

`auth ensure` checks the existing session and refreshes it when needed. It does
not open a browser or submit a generation. `auth status` only inspects local
credentials; an expired access token can still have a usable refresh token.
If a network or provider request fails, diagnose it before replacing credentials.

Use device login to authorize your AtlasCloud account. You do not need to give
your agent an API key. Reuse your current account and environment.

## 3. Connect your agent

Choose one command:

```sh
atlas skills install --agent claude
# Or:
atlas skills install --agent codex
```

Start a new agent session afterward. The installed entry reads its detailed
instructions from your CLI, so updating Atlas also updates the operating guide.
For project-level installation, use `atlas skills install --dir .claude/skills`.
This writes a skill entry only; it does not log in or create paid content.

## Give your agent a setup request

> Help me configure AtlasCloud. Check whether atlas is installed, and use the
> official installer if needed. Check my existing login with `atlas auth ensure
> --non-interactive --json`; guide me through `atlas auth login` only if credentials
> are missing or cannot be refreshed. Keep my existing account and environment.
> Install the Atlas skill for my current Claude Code or Codex, then verify
> `atlas skills read atlas --raw`. Do not submit billable calls during setup.

## Start with a task

| Ask your agent | Expected result |
|---|---|
| Create a product photo from this reference; keep the packaging and logo. Show the model and cost first. | A model that accepts the actual reference, an estimate, then verified local files after approval. |
| Turn this image into a 5-second vertical video with a slow camera push. | An image-to-video model, checked parameters, one submitted task, and a saved video. |
| Continue this Atlas prediction ID; do not generate it again. | Retrieval of the existing task without another submission. |
| Read this sentence aloud; find the available voices first. | An audio model with the required text and voice fields. |
| Use this exact model to analyze my image. | Your chosen model with the actual image included. |

Attach the reference file or give its real path. State any budget, dimensions,
quantity, and whether you allow revisions. Model calls are billable; setup,
model discovery, and cost estimation do not submit a generation.

The delivery should include the model, task status, and actual saved file paths
or remote results. A task ID means submission, a local wait timeout does not
mean remote failure, and remote success does not prove that files were saved.

## If something fails

Start with `atlas doctor --json`. Keep the original prediction ID and resume
with `atlas generate get` or `atlas generate wait`; local receipts are available
through `atlas generate ops list`. If submission is unknown, inspect the receipt
before creating a replacement. Do not switch accounts or environments to hide
provider errors.

This integration uses terminal commands. Public CLI packages contain `atlas`;
for clients that need MCP tools instead, see the separate
[Atlas Cloud MCP Server](https://github.com/AtlasCloudAI/mcp-server).
