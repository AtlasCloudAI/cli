# Changelog

User-facing history of Atlas CLI public releases. Dates below are the original GitHub publication dates in UTC. Entries describe behavior at that version; later releases may change or remove it.

Historical summaries were reconstructed from the existing release notes and source changes. Source-only milestones are listed separately and are not public downloads.

## [v0.1.32](https://github.com/AtlasCloudAI/cli/releases/tag/v0.1.32) — 2026-09-29

### Fixes

- Platform HTTP 401 responses now identify an authentication problem and suggest checking the API key or signing in again, instead of reporting a generic upstream failure.
- HTTP 413 responses now explain that the request is too large and suggest reducing its size or using a supported upload/URL input. This also works when the response body repeats `HTTP 413`.
- Credential refresh conflicts now suggest retrying authentication with `atlas auth ensure`, consistently across text, JSON, and telemetry. Revoked sessions still require a new login.

Provider authentication failures remain distinct from platform authentication failures. Existing HTTP status codes, command exit codes, and request/refresh behavior are preserved.

### Validation

Regression tests cover numeric API responses, gateway response bodies, provider-error precedence, refresh conflicts, revoked credentials, and output consistency. Linux, macOS, and Windows CI passed, including the full race test suites and Linux skill/telemetry user-flow checks.

### Upgrade

```sh
atlas update
```

For npm installations:

```sh
npm install -g atlascloud-cli@0.1.32
```

## [v0.1.31](https://github.com/AtlasCloudAI/cli/releases/tag/v0.1.31) — 2026-09-29

- Removed CLI-local `enhance`, `product-photoshoot`, and `marketplace-cards` commands and embedded enhancer recipes. Prompt enhancement belongs in a separate service.
- Standard generation commands and agent workflow guides remain available. The removed commands were introduced in v0.1.30.

## [v0.1.30](https://github.com/AtlasCloudAI/cli/releases/tag/v0.1.30) — 2026-09-29

- Added creative-brief workflows for product photos and marketplace image sets.
- Fixed the test harness for capturing large command output on Windows.

Historical note: the CLI-local enhancement and product/marketplace workflow commands were removed in v0.1.31.

## [v0.1.29](https://github.com/AtlasCloudAI/cli/releases/tag/v0.1.29) — 2026-09-29

- Improved cost guidance and separated price quotes from generation routing.
- Made balance, routing, schema, and download failures more actionable, with safer error details.
- Refined lifecycle telemetry to distinguish submission, observed results, waiting interruptions/timeouts, and artifact delivery.

## [v0.1.28](https://github.com/AtlasCloudAI/cli/releases/tag/v0.1.28) — 2026-09-24

- Fixed the MCP source implementation to preserve tool inputs and return a resumable result when the first prediction poll times out.

Packaging note: the public archives remain CLI-only; this release does not distribute an `atlas-mcp` binary.

## [v0.1.27](https://github.com/AtlasCloudAI/cli/releases/tag/v0.1.27) — 2026-09-24

- Reject media inputs whose type does not match the requested generation input.
- Preserve actionable download retry guidance when artifact delivery fails.

## [v0.1.26](https://github.com/AtlasCloudAI/cli/releases/tag/v0.1.26) — 2026-09-24

- Unified generation JSON output and made interrupted or timed-out waits recoverable using the existing prediction.
- Check catalog schema constraints, including `allOf`, `anyOf`, and `minItems`, before submitting generation requests.
- Show live model media requirements in generation help.
- Improved 3D artifact downloads and filenames, and upload support for local reference videos.
- Fixed Windows media paths and output-directory handling; improved token warning behavior.
- Queue the installation telemetry event before generation events.

## [v0.1.25](https://github.com/AtlasCloudAI/cli/releases/tag/v0.1.25) — 2026-09-18

- Added installable agent workflow guides covering setup, model discovery, generation, and result verification.
- Tightened skill triggers to match intended workflows.
- Expired tokens no longer appear as logged in.

## [v0.1.24](https://github.com/AtlasCloudAI/cli/releases/tag/v0.1.24) — 2026-09-16

- Added background updates for native CLI installations.
- Hardened update/install behavior around release availability and installation edge cases.
- Coordinate installation work with shared locks and honor configuration-directory overrides.

## [v0.1.23](https://github.com/AtlasCloudAI/cli/releases/tag/v0.1.23) — 2026-09-16

- Separate successful submission from an observed generation result in telemetry, so an accepted asynchronous job is not counted as a completed generation.

## [v0.1.22](https://github.com/AtlasCloudAI/cli/releases/tag/v0.1.22) — 2026-09-16

- Added PostHog CLI usage telemetry with an opt-out and diagnostic visibility in `atlas doctor`.
- Track command outcomes and model IDs without collecting prompts or credentials.
- Hardened model metadata handling and concurrent installation identity creation; installer version probes do not emit telemetry.

This is the first public release containing the telemetry work from the source-only v0.1.21 tag.

## [v0.1.20](https://github.com/AtlasCloudAI/cli/releases/tag/v0.1.20) — 2026-09-15

- Show the selected account and username after login.
- Improve device-login polling and the authorized waiting state.
- Use the console catalog for account information and generation schemas.
- Make account diagnostics use the supported console account endpoint.

## [v0.1.19](https://github.com/AtlasCloudAI/cli/releases/tag/v0.1.19) — 2026-09-15

- Open device verification in the browser during login.
- Improve handling of explicitly supplied generation parameters and reference images.

## [v0.1.18](https://github.com/AtlasCloudAI/cli/releases/tag/v0.1.18) — 2026-09-04

- Use the model schema's default aspect ratio when the caller does not supply `--aspect-ratio`.

## [v0.1.17](https://github.com/AtlasCloudAI/cli/releases/tag/v0.1.17) — 2026-09-04

- Added account-gated audio and 3D generation paths.
- Compile vendor inputs from model schemas and upload local media for models that require URL inputs.
- Improved schema handling for aspect ratios and audio models.
- Hardened long-running chat behavior, authentication/keychain handling, and provider-access error classification.
- Fixed flag values beginning with a dash and replaced a retired default chat model.

## [v0.1.16](https://github.com/AtlasCloudAI/cli/releases/tag/v0.1.16) — 2026-06-17

- Updated command-help and usage examples for API callers, scripts, CI, and product media workflows.
- Refreshed the npm package description and release version metadata.

This release primarily changes documentation and help text; the source diff does not introduce a new runtime feature.

## [v0.1.15](https://github.com/AtlasCloudAI/cli/releases/tag/v0.1.15) — 2026-06-15

- Made CLI output contracts more consistent across authentication, generation, and version commands.
- Corrected display of catalog video pricing units.

## [v0.1.14](https://github.com/AtlasCloudAI/cli/releases/tag/v0.1.14) — 2026-06-11

- Improved discovery of the embedded agent skills.
- Updated GitHub Actions to the Node.js 24 runtime.

## [v0.1.13](https://github.com/AtlasCloudAI/cli/releases/tag/v0.1.13) — 2026-06-05

- Added CLI source-attribution headers to API requests.
- Improved device-login progress feedback with an ASCII animation and title.

## [v0.1.12](https://github.com/AtlasCloudAI/cli/releases/tag/v0.1.12) — 2026-06-03

- Enabled device login in the interactive login menu and made it the recommended option.
- Exposed `atlas auth login --device` in help; API-key login remains available.
- Browser Web Flow remained marked as upcoming in this version.

## [v0.1.11](https://github.com/AtlasCloudAI/cli/releases/tag/v0.1.11) — 2026-06-03

- Added OAuth device-flow and account-selection support.
- Improved account context and authentication output.
- Isolated authentication state across internal environments.

The device flow became visible as the recommended interactive login option in v0.1.12.

## [v0.1.10](https://github.com/AtlasCloudAI/cli/releases/tag/v0.1.10) — 2026-05-19

- Removed the installer's dependency on the GitHub latest-release API when resolving the version to install.

## [v0.1.9](https://github.com/AtlasCloudAI/cli/releases/tag/v0.1.9) — 2026-05-19

- Added generation cost estimates so callers can inspect pricing before submitting a job.

## [v0.1.8](https://github.com/AtlasCloudAI/cli/releases/tag/v0.1.8) — 2026-05-19

- Omit prediction cost when the API does not return a cost, instead of displaying a misleading value.

## [v0.1.7](https://github.com/AtlasCloudAI/cli/releases/tag/v0.1.7) — 2026-05-19

- Refreshed the default chat model and examples.
- Honor an explicitly supplied generation seed and `--wait=false`.
- Return structured JSON with the prediction ID and resume command when a generation wait times out.
- Added explicit JSON output for `atlas version --json`.

## [v0.1.6](https://github.com/AtlasCloudAI/cli/releases/tag/v0.1.6) — 2026-05-18

- Added image, video, and audio inputs for multimodal chat models.
- Improved model discovery using the catalog.
- Added Windows installer support.
- Reject generation requests whose model type does not match the requested media type before submission.

## [v0.1.5](https://github.com/AtlasCloudAI/cli/releases/tag/v0.1.5) — 2026-05-14

- Emit structured JSON for generation submit/get/wait API errors when `--json` is enabled, while preserving nonzero exit codes.
- Includes the schema-driven video parameters introduced in v0.1.4.

Public archives are CLI-only.

## [v0.1.4](https://github.com/AtlasCloudAI/cli/releases/tag/v0.1.4) — 2026-05-14

- Added schema-driven video generation parameters and first-class flags for resolution, size, multiple images, end images, input video, and audio.
- Added `--params-json` and repeatable `--param key=value` for model-specific parameters.
- Avoid sending default video aspect ratio or duration unless explicitly requested.
- Fixed parsing of numeric schema enum values.

Public archives are CLI-only and do not include `atlas-mcp`.

## [v0.1.3](https://github.com/AtlasCloudAI/cli/releases/tag/v0.1.3) — 2026-05-13

- Marked `account` and `auth whoami` as upcoming while the required server endpoints were unavailable.
- Added model-list fallback for chat model details and static-schema fallback for image/video model details.
- Return JSON on `generate wait --json` timeouts.
- Print `atlas version` to stdout.

Public archives are CLI-only. These notes describe this historical version's behavior.

## [v0.1.2](https://github.com/AtlasCloudAI/cli/releases/tag/v0.1.2) — 2026-05-13

- Switched public release archives to CLI-only packaging, excluding `atlas-mcp`.
- Published prebuilt `atlas` binaries for macOS, Linux, and Windows on amd64/arm64, with `checksums.txt` for verification.

## [v0.1.1](https://github.com/AtlasCloudAI/cli/releases/tag/v0.1.1) — 2026-05-13

- Initial public installer release for AtlasCloud CLI.
- Published prebuilt `atlas` and `atlas-mcp` binaries for macOS, Linux, and Windows on amd64/arm64, with `checksums.txt` for verification.

## Source-only milestones

### v0.1.21 — not publicly released

- A source tag exists, but there is no corresponding public GitHub release, public distribution tag, or npm package version.
- Introduced CLI usage telemetry with opt-out; that work and the subsequent metadata/identity fixes first shipped publicly in v0.1.22.

### v0.1.0 — initial source release

- The source repository has an initial release covering early authentication, API compatibility, and release infrastructure work.
- The public installer release history begins at v0.1.1. There is no public v0.1.0 release in this distribution repository.
