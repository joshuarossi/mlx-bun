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

HTTP/configuration inventories and the complete generated library API are
follow-up work. Pages explain this scope and link to the owning package docs.
