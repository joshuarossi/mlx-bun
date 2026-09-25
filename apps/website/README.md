# Public website

Owns the static documentation site at mlx-bun.dev: navigation, presentation,
and short user explanations. App behavior and library interfaces remain in
`apps/mlx-bun` and their owning packages. This workspace never loads MLX.

From the repository root, run `bun run --cwd apps/website build` or `dev`.
The Bun workspace lockfile is the only dependency lock. `dist/` is the deployable
GitHub Pages artifact; this migration adds build checks, not deployment.
Deploy the site and its installer only after a compatible application release
exists; the installer validates the complete new bundle, including its notices.

The build generates the CLI inventory from the application's command table.
It also copies the canonical app installer to `public/install.sh`. Neither output
is committed. The coverage test compares the inventory to the real CLI's help,
including every command and flag. Examples link to executable package examples;
this site does not keep a second copy of them.

The library API uses TypeDoc to render exported types, overloads, members,
JSDoc, and source links at `/api/`. Package manifests supply the entry points;
an independent TypeScript-checker coverage implementation runs inside the
API generator and compares its output against every public subpath and exported
symbol, including aliases and star re-exports. It is not a standalone command.
Current manifests use string `.ts` export targets; conditional exports and
wildcards fail loudly until the coverage implementation supports them.
Source links use a valid `GITHUB_SHA` in CI or the local Git commit; only source
trees outside Git fall back to the refactor branch.
HTML and reflection JSON are build output, never committed. Generation parses
source without importing library code or loading native libraries. TypeDoc can
warn about references to non-exported types; their owning source remains linked.

HTTP/configuration inventories remain follow-up work. Pages explain this scope
and link to the owning package docs.
