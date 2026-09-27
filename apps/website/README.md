# Public website

Owns the static documentation site at mlx-bun.dev: navigation, presentation,
and short user explanations. App behavior and library interfaces remain in
`apps/mlx-bun` and their owning packages. This workspace never loads MLX.

From the repository root, run `bun run --cwd apps/website build` or `dev`.
The Bun workspace lockfile is the only dependency lock. `dist/` is the deployable
GitHub Pages artifact; this migration adds build checks, not deployment.
Deploy the site and its installer only after a compatible application release
exists; the installer validates the complete new bundle, including its notices.
Source links currently target `refactor/monorepo` in the authored pages and CLI
generator. Before deployment, update them to the published release's source ref
and verify their targets; the static build check covers only local links.

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

The HTTP inventory is generated the same way from the route handlers in
`apps/mlx-bun/src/server` and their composition in `apps/mlx-bun/src/cli`: each
server mode's routes, status, and source links, never committed. Generation
fails on a routing predicate or composition shape it does not recognize; the
reviewed exceptions are `NON_ROUTE_SITES` in its generator. Its source links
follow the library API's revision rule.

The configuration inventory is generated the same way from `parseServeOptions`
and every `MLX_BUN_*` read under `apps/mlx-bun/src` and `packages/*/src`:
literal serve defaults, ranges, and accepted values; the keys `serve` writes
from its flags; and each runtime key's read form and per-site fallback, grouped
by owning package, never committed. Tests and scripts are not scanned.
Generation fails on a non-literal runtime key, a computed environment read, a
direct `MLX_BUN_*` environment read outside `DIRECT_ENV_READS`, a help
`[default: X]` that differs from the parser's literal, or a note in `NOTES`
whose key or flag is gone.
