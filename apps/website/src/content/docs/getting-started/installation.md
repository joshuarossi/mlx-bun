---
title: Installation
description: Install the mlx-bun app, or build it from source.
---

mlx-bun requires an Apple Silicon Mac running macOS 14 or later. Install the
standalone bundle with the installer or Homebrew, or the npm package with Bun.

## Standalone bundle

```sh
curl -fsSL https://mlx-bun.dev/install.sh | sh
```

The [installer](/install.sh) downloads the signed, notarized release bundle,
which includes its runtime and native libraries. Keep the executable and its
native sidecars together.

`MLX_BUN_VERSION` selects a release tag (default `latest`); `MLX_BUN_INSTALL_DIR` changes the bundle
installation root (default `~/.mlx-bun`), not the app's data location. The app writes
its data (converted models, adapters, datasets, job history, chats) under `~/.mlx-bun`,
or `MLX_BUN_HOME` when set; the Hugging Face cache holds only downloads. The command
is linked at `~/.local/bin/mlx-bun`, with `mlx-bun.server`, `mlx-bun.generate`,
`mlx-bun.convert`, `mlx-bun.fuse`, `mlx-bun.lora` and `mlx-bun.upload` beside it: mlx-lm's
commands under mlx-bun's names, accepting `mlx_lm`'s arguments (see the app's
[mlx-lm compatibility notes](https://github.com/joshuarossi/mlx-bun/blob/main/apps/mlx-bun/README.md#mlx-lm-compatibility-mlx-buncmd)
for the flag mapping and what is not supported). That directory must precede older installations
on `PATH`. Restart a running app after upgrading to use the new version.

## Homebrew

```sh
brew install joshuarossi/tap/mlx-bun
```

Homebrew installs the same bundle and links the `mlx-bun` command.

## npm package

Run `bun install -g mlx-bun`, or `bunx mlx-bun` to run it without a permanent
installation. The package requires Bun 1.4.2 or later; use Bun rather than
Node's `npx`.

## Build from source

Clone `main` from the [repository](https://github.com/joshuarossi/mlx-bun) and follow its
[development instructions](https://github.com/joshuarossi/mlx-bun/blob/main/README.md#development)
for the Bun version, dependency installation, and native build or staging steps.
Unlike an installed release, a source checkout needs those native inputs.

The app's [source entry and verification instructions](https://github.com/joshuarossi/mlx-bun/blob/main/apps/mlx-bun/README.md)
are kept beside the implementation. Run `mlx-bun --help` to see the commands
it supports. Native libraries are bundled in package artifacts, not committed to
Git or downloaded by library imports.
