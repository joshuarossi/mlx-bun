# mlx-bun.dev — docs site

The marketing landing page + documentation site for mlx-bun, published to
**https://mlx-bun.dev**. Built with [Astro Starlight](https://starlight.astro.build).

## Develop

Requires **Node ≥ 22.12** (Astro 6; enforced via `engines` in `package.json`) —
`nvm use 22` first, or skip Node entirely with `bunx --bun astro build`.

```sh
cd website
npm install
npm run dev       # local dev at http://localhost:4321
npm run build     # production build to ./dist (what CI runs)
npm run preview   # serve the built site locally
```

## Content

- Pages live in `src/content/docs/` (`.md` / `.mdx`); the file path is the route.
- The landing page is `src/content/docs/index.mdx` (`template: splash`).
- Several pages are **generated** from the repo's `docs/reference/*.md` by
  `scripts/sync-reference-docs.mjs` on every dev/build (see the MAP there for
  the full list; the copies are gitignored). Edit the source docs, never the
  generated files — they carry an `editUrl` pointing at the real source.
- Sidebar + site config: `astro.config.mjs`. Brand CSS: `src/styles/custom.css`.

## Deploy

Automatic. `.github/workflows/deploy-site.yml` builds and publishes to GitHub
Pages on every push to `main` that touches `website/**` or `docs/reference/**`
(the generated pages' sources). One-time repo setup:
**Settings → Pages → Source = GitHub Actions**.

The custom domain is configured by `public/CNAME` (`mlx-bun.dev`). The installer
served at `mlx-bun.dev/install.sh` is `public/install.sh`.
