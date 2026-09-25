---
title: Installation
description: Released app installation and monorepo development setup.
---

mlx-bun targets Apple Silicon Macs. The existing release supports four entry
paths: the [curl installer](/install.sh), Homebrew, Bun, and a source checkout.
The monorepo refactor is not published yet. Bun and Homebrew commands below
install the existing release. This site's new curl installer requires a compatible
monorepo release bundle and must not be deployed before that bundle is available.

## Released app

Run `brew install joshuarossi/tap/mlx-bun` or `bun install -g mlx-bun`.
Each supplies the `mlx-bun` command. `bunx mlx-bun` runs it without a permanent
installation. Use Bun, rather than Node's `npx`, for the Bun distribution.

For a standalone installation, keep the executable and its native sidecars
together. The [canonical installer](https://github.com/joshuarossi/mlx-bun/blob/refactor/monorepo/scripts/install.sh)
owns installation options; this site serves the same script, copied during its
build. Once a compatible release is available, use
`curl -fsSL https://mlx-bun.dev/install.sh | sh`. The installer downloads release
artifacts and does not publish anything.

`MLX_BUN_VERSION` selects a release tag; `MLX_BUN_INSTALL_DIR` changes the bundle
installation root (default `~/.mlx-bun`), not the app's data location. The command
is linked at `~/.local/bin/mlx-bun`; that directory must precede older installations
on `PATH`. Restart a running app after upgrading to use the new version.

## Refactor source checkout

Check out `refactor/monorepo` from the
[repository](https://github.com/joshuarossi/mlx-bun). Follow its
[root development instructions](https://github.com/joshuarossi/mlx-bun/blob/refactor/monorepo/README.md#development)
for the Bun version, dependency installation, and native build or staging steps.
Unlike an installed release, a development checkout needs those native inputs.

The app's [source entry and verification instructions](https://github.com/joshuarossi/mlx-bun/blob/refactor/monorepo/apps/mlx-bun/README.md)
are kept beside the implementation. Run its `--help` to see what this checkout
supports. Native libraries are bundled in package artifacts, not committed to
Git or downloaded by library imports.
