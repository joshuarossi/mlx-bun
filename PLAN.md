# Refactor plan

Open work only; delete a block when its exit criteria are met. Josh has authorized the library and application migration through a first full
draft; keep changes focused and reviewed. Standalone Pi integration is deferred. Ownership and documentation rules live in [ARCHITECTURE.md](ARCHITECTURE.md).

## Verify the migrated library

- [ ] Establish real-weight parity for Qwen Trellis and Gemma, and extend MiniCPM
  beyond the [verified basic decode path](packages/inference/README.md#external-parity-evidence),
  against their applicable external oracle and main. Keep Python environments, setup,
  and reference generation outside this repository. Cover logits, state
  continuation, and relevant specialized paths under identical artifacts and
  settings. Exit: reproducible comparisons meet the numerical contracts, with
  source revisions, external oracle versions, and curated evidence in approved
  docs; synthetic tests alone do not close this item.
- [ ] Confirm the long-term mixed-KV reference contract for single-query decode:
  the documented stock mlx-lm path or OptiQ serve's fused default. The
  [state record](packages/inference/measurements/2026-09-25-runtime-state.json)
  verifies the existing composition; keep that implementation unchanged during
  this refactor and do not imply blanket OptiQ serve compatibility.
## Optimize after the full draft

- [ ] Run paired same-machine performance comparisons against main using the
  same artifacts and configuration. Exit: decode, prefill, complete-request time,
  and memory evidence is recorded; regressions are resolved or explicitly reviewed.

## Migrate the application

- [ ] Wire the migrated chat backend into the server and browser; inject memory
  tools, skill paths, and prompt context from their real app owner. The chat
  adapter currently leaves memory disabled and starts no server by itself.
- [ ] Migrate the server, engine host, web app, and job orchestration into
  `apps/mlx-bun`, keeping their interfaces in the consuming domains. CLI hub
  commands are the first slice. Exit: app consumers use public library APIs;
  application contracts and policy stay out of the inference library.
- [ ] Complete shared-execution support for all shapes main supported through its
  serial fallback: model caches without batch conversion (including Gemma2 masks
  and sliding-attention caches); media without a batched input binding; adapters
  without batched adapter support; non-batchable quantized KV and TurboQuant KV;
  grammar with batching disabled; paged KV without a batched implementation;
  speculative decoding without a grouped draft; and denoising. These are migration
  gaps to support, not dropped capabilities. The app currently reports a typed
  capability error for these shapes. Exit: each uses the shared scheduler and
  preserves main's behavior, verified with real weights and cancellation/streaming
  coverage, without a hidden serial fallback.
- [ ] Preserve continuous batching as the serving default, including single
  requests. Keep compilation choices inside specialized graph layers, without
  serial-only or compilation switches on the new app surface. Exit: the full
  draft preserves main's behavior and cancellation/streaming contracts before
  the subsequent performance pass.
- [ ] Preserve the `mlx-bun` terminal experience and Bun, Homebrew, curl-script,
  and source-checkout installation paths. Add generated surface reference and
  coverage checks with the CLI/server migration. Exit: the app and its install
  paths work from release artifacts, with documented public surfaces matching code.
