// The host builds and runs with no other module in its import closure: every
// import reachable from its entry, static or dynamic, following workspace
// packages through their exports, reaches exactly one module package.
import { expect, test } from "bun:test";
import { readFileSync, realpathSync } from "node:fs";
import { dirname, relative, resolve } from "node:path";

const root = realpathSync(resolve(import.meta.dir, "../../.."));

/** Workspace packages (by directory name) whose files the entry can reach. */
function reachedPackages(entry: string): Set<string> {
  const transpiler = new Bun.Transpiler({ loader: "ts" }), seen = new Set<string>(), packages = new Set<string>();
  const visit = (file: string) => {
    if (seen.has(file) || !/\.(ts|tsx|js|mjs)$/.test(file)) return;
    seen.add(file);
    const owner = /^(apps|packages)\/([^/]+)\//.exec(relative(root, file));
    if (owner) packages.add(`${owner[1]}/${owner[2]}`);
    for (const { path } of transpiler.scanImports(readFileSync(file, "utf8").replace(/^#!.*\n/, ""))) {
      if (path.startsWith("node:") || path === "bun" || path.startsWith("bun:")) continue;
      if (!path.startsWith(".") && !path.startsWith("@mlx-bun/")) continue;
      visit(realpathSync(Bun.resolveSync(path, dirname(file))));
    }
  };
  visit(entry);
  return packages;
}

test("the transcription-only host reaches the transcription module and no other module or app", () => {
  const reached = reachedPackages(resolve(root, "apps/transcribe/src/cli/main.ts"));
  expect([...reached].filter(name => name.startsWith("packages/module-")).sort()).toEqual(["packages/module-transcription"]);
  expect([...reached].filter(name => name.startsWith("apps/"))).toEqual(["apps/transcribe"]);
  // The core services it composes, and nothing that names the chat, models, training or memory features.
  expect(reached.has("packages/app-services")).toBe(true);
  for (const absent of ["packages/training", "packages/quantize"]) expect(reached.has(absent)).toBe(false);
});
