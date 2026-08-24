// docs-surface gate — the served surface and its canonical docs cannot drift.
//
// One fact, one home (CONTRIBUTING.md):
//   - every `serve` flag in src/cli.ts SERVER_FLAGS has a row in
//     docs/reference/server-config.md, and NO other doc states a flag default;
//   - every HTTP route registered in src/server.ts + src/serve/*-routes.ts
//     appears in docs/reference/server-api.md.
// Model-free; runs in CI. Internal-only surfaces are listed explicitly below —
// adding to the allowlist is a reviewed decision, not a default.
import { describe, expect, test } from "bun:test";
import { readFileSync, readdirSync, statSync } from "node:fs";
import { join } from "node:path";

const ROOT = join(import.meta.dir, "..");
const read = (p: string) => readFileSync(join(ROOT, p), "utf8");

/** Serve flags parsed from the help template — one `  --name` per line. */
function serveFlags(): string[] {
  const cli = read("src/cli.ts");
  const start = cli.indexOf("const SERVER_FLAGS = `");
  const end = cli.indexOf("`;", start);
  const block = cli.slice(start, end);
  return [...new Set([...block.matchAll(/^\s{2}(--[a-z][a-z0-9-]*)/gm)].map((m) => m[1]!))];
}

/** Routes registered in code: string literals used in pathname checks. */
function registeredRoutes(): string[] {
  const files = ["src/server.ts", ...readdirSync(join(ROOT, "src/serve"))
    .filter((f) => f.endsWith("-routes.ts")).map((f) => `src/serve/${f}`)];
  const out = new Set<string>();
  for (const f of files) {
    const src = read(f);
    for (const m of src.matchAll(/(?:pathname === |case |startsWith\(|LEGACY_PATHS = new Set\(\[)"(\/[a-zA-Z0-9/_.-]*)"/g))
      out.add(m[1]!);
    // Set literals: "/a", "/b", ...
    for (const m of src.matchAll(/new Set\(\[((?:\s*"\/[a-zA-Z0-9/_.-]*",?)+)\s*\]\)/g))
      for (const p of m[1]!.matchAll(/"(\/[a-zA-Z0-9/_.-]*)"/g)) out.add(p[1]!);
  }
  return [...out].filter((p) => p !== "/").sort();
}

/** Surfaces that are internal by decision and intentionally undocumented. */
const INTERNAL_ROUTES = new Set<string>([
  "/signal",            // CLI ↔ server control channel
  "/generate",          // legacy in-process generation hook
]);
/** Accepted spellings parsed in src/cli.ts but absent from the help block. */
const ALIAS_FLAGS = ["--query", "--l3" /* recognized, exits with a pointer */];
const INTERNAL_FLAGS = new Set<string>([
  "--unix",             // marked "(internal)" in the help text
]);

function mdFiles(dir: string): string[] {
  const out: string[] = [];
  for (const e of readdirSync(join(ROOT, dir))) {
    const p = `${dir}/${e}`;
    if (statSync(join(ROOT, p)).isDirectory()) out.push(...mdFiles(p));
    else if (e.endsWith(".md")) out.push(p);
  }
  return out;
}

describe("docs-surface: serve flags", () => {
  const doc = read("docs/reference/server-config.md");
  test("every serve flag has a row in server-config.md", () => {
    const missing = serveFlags().filter((f) => !INTERNAL_FLAGS.has(f) && !doc.includes(`\`${f}`));
    expect(missing).toEqual([]);
  });
  test("server-config.md documents no flag that code lacks", () => {
    const code = new Set([...serveFlags(), ...ALIAS_FLAGS]);
    // Rows in the "Removed" record are history, not surface.
    const live = doc.split(/^##+\s+Removed/m)[0]!;
    const documented = [...new Set([...live.matchAll(/^\|\s*`(--[a-z][a-z0-9-]*)/gm)].map((m) => m[1]!))];
    expect(documented.filter((f) => !code.has(f))).toEqual([]);
  });
  test("only server-config.md states a serve-flag default", () => {
    const serve = new Set(serveFlags());
    const offenders: string[] = [];
    for (const f of [...mdFiles("docs/reference"), ...mdFiles("docs/design"), "README.md"]) {
      if (f.endsWith("server-config.md")) continue;
      for (const line of read(f).split("\n")) {
        const m = line.match(/^\|\s*`(--[a-z][a-z0-9-]*)`.*\|.*default/i);
        if (m && serve.has(m[1]!)) offenders.push(`${f}: ${line.slice(0, 80)}`);
      }
    }
    expect(offenders).toEqual([]);
  });
});

describe("docs-surface: HTTP routes", () => {
  const doc = read("docs/reference/server-api.md");
  test("every registered route appears in server-api.md", () => {
    const missing = registeredRoutes().filter((r) => !INTERNAL_ROUTES.has(r) && !doc.includes(r));
    expect(missing).toEqual([]);
  });
});
