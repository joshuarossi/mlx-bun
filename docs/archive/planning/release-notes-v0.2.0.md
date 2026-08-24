# mlx-bun v0.2.0

Version 0.2.0 is the first release with the complete Qwen3.8 serving path:
text, images, video, thinking controls, tool calls, and native MTP speculation.
It also ships the serving and memory work completed since v0.0.13.

## Highlights

- Qwen3.8 image input now runs through the dedicated vision tower and mRoPE
  path. Video content parts decode through the bundled AVFoundation helper,
  sample frames at 2 fps, and use the gated Qwen video pipeline.
- Qwen native MTP can mount from a separate companion or an artifact's `mtp/`
  directory. Rejected drafts restore recurrent DeltaNet state correctly.
- The default continuous scheduler now shares request planning, sampling,
  usage accounting, cache selection, and protocol events with the strict
  serial executor. `--batch 1` remains the explicit serial pin.
- Memory admission treats `max_tokens` as a ceiling. If the prompt fits, the
  server caps generation to the safe remaining context instead of rejecting a
  broad client default.
- `convert --rotate-weights` folds supported rotations before quantization.
  The offline pipeline also gained streamed shard handling, 3-bit GPTQ, and
  atomic output publication.

## Reliability and performance fixes

- Large Qwen models now enter the same wired-memory scope as mlx-lm during
  serial and continuous execution. This removes the token-zero residency
  stall on machines whose recommended working set grew beyond the old cutoff.
- DeltaNet prefill and batch-row extraction now copy owned cache state instead
  of pinning whole chunk buffers.
- SSD prompt-cache snapshots stay dirty until atomic storage completes.
  `POST /admin/cache/flush` and normal SIGINT/SIGTERM shutdown provide an
  explicit durability boundary.
- Rotating-cache batch joins now dispatch by cache capability and preserve the
  correct rotating signature.
- Qwen and GLM MTP sampling no longer passes a rank-3 logits tensor into the
  rank-2 sampler.

## Distribution

- macOS on Apple Silicon remains the supported platform.
- Source and npm installs require Bun 1.4.0 or newer.
- Direct downloads and Homebrew use the signed, notarized self-contained
  archive.
- npm and `bunx` use native pack v0.3.0, which includes MLX, the bounded expert
  I/O helper, and the AVFoundation frame extractor.

Upgrade with `brew upgrade joshuarossi/tap/mlx-bun`, `bun update -g mlx-bun`,
or rerun the direct installer.
