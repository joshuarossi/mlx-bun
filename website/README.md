# mlx-bun.dev — docs site

The marketing landing page + documentation site for mlx-bun, published to
**https://mlx-bun.dev**. Built with [Astro Starlight](https://starlight.astro.build).

## Develop

Requires Node ≥ 20 (the repo's default toolchain is Bun, but this site uses the
Node/Astro toolchain — use `nvm use 22`).

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
- The four reference pages (`reference/server-api`, `reference/server-config`,
  `guides/library`, `guides/embedding`) are **adapted copies** of the repo's
  `docs/reference/*.md`. If you change the source docs, refresh these.
- Sidebar + site config: `astro.config.mjs`. Brand CSS: `src/styles/custom.css`.

## Deploy

Automatic. `.github/workflows/deploy-site.yml` builds and publishes to GitHub
Pages on every push to `main` that touches `website/**`. One-time repo setup:
**Settings → Pages → Source = GitHub Actions**.

The custom domain is configured by `public/CNAME` (`mlx-bun.dev`). The installer
served at `mlx-bun.dev/install.sh` is `public/install.sh`.
