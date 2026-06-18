---
title: Troubleshooting
description: Common issues and their fixes.
---

### `dlopen` / `libmlxc.dylib` not found

The MLX runtime auto-downloads on first `serve` into
`~/Library/Caches/mlx-bun/`. If a download was interrupted, just rerun `serve` —
it resumes. To point at your own copy instead, set
`MLX_BUN_LIBMLXC=/path/to/libmlxc.dylib`.

### `no models match`

Run `mlx-bun scan` after downloading. Models must be in the standard Hugging
Face cache (`~/.cache/huggingface/hub`).

### Hugging Face download stalls at 0%

Use `mlx-bun get <org/repo>` — plain HTTPS, no Xet, and it resumes where it left
off. For the Python CLI, set `HF_HUB_DISABLE_XET=1` before the download command.

### Slow decode on a model near your RAM ceiling

Close memory-heavy apps. A model that doesn't fit the wired-memory budget pages
weights every token. Check with `mlx-bun fit <model>`.

### Gatekeeper / "unidentified developer"

The released binaries are Developer-ID signed and notarized, so this shouldn't
happen. If you built the binary yourself and hit it, the bundle's dylibs need to
be (re)signed — see [Embedding in a Mac app](/guides/embedding/).

### Bun version

Requires Bun ≥ 1.3.14 (`bun upgrade`). The version is pinned for `Bun.Image` and
verified FFI behavior.
