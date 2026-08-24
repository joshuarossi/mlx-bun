#!/usr/bin/env bun
// Reclaim machine-local build/experiment output (working-tree only; never
// touches git-tracked files). Everything removed here is regenerable:
// runs/ + adapters/ are experiment scratch (CONTRIBUTING "What goes where"),
// dist*/ rebuild via scripts/build-*.sh, goldens .bin/.npz blobs regenerate
// via scripts/regen-*.ts against the oracle venv, website build output
// rebuilds via `bun install && bun run build` in website/.
//
// Usage:
//   bun scripts/clean.ts          # dry run — list targets + sizes
//   bun scripts/clean.ts --force  # actually delete
import { $ } from "bun";
import { existsSync } from "node:fs";

const TARGETS = [
  "runs",
  "adapters",
  "dist",
  "dist-native",
  "dist-release",
  "reports",
  "website/dist",
  "website/.astro",
  "website/node_modules",
  "scripts/__pycache__",
  "scripts/experiments/__pycache__",
];
const GLOBS = ["goldens/**/*.bin", "goldens/**/*.npz", "benchmarks-*.md"];

const force = process.argv.includes("--force");
let any = false;

for (const t of TARGETS) {
  if (!existsSync(t)) continue;
  any = true;
  const size = (await $`du -sh ${t}`.text()).split("\t")[0];
  if (force) {
    await $`rm -rf ${t}`;
    console.log(`removed  ${t} (${size})`);
  } else console.log(`would remove  ${t} (${size})`);
}
for (const g of GLOBS) {
  const files = [...new Bun.Glob(g).scanSync(".")];
  if (!files.length) continue;
  any = true;
  if (force) {
    for (const f of files) await $`rm -f ${f}`;
    console.log(`removed  ${files.length} × ${g}`);
  } else console.log(`would remove  ${files.length} × ${g}`);
}

if (!any) console.log("nothing to clean");
else if (!force) console.log("\ndry run — pass --force to delete");
