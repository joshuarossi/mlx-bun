#!/usr/bin/env bun
// Builds src/web/src/main.ts -> src/web/app.js — the bundled frontend the
// server serves at GET /assets/app.js (src/server.ts, same
// `with { type: "text" }` pattern as /assets/hljs.js).
//
// src/web/app.js is COMMITTED (generated, not gitignored): the compiled
// single binary and the npm package both need it present without a build
// step at install/run time — same reasoning as the vendored assets in
// src/web/vendor/.
//
// Run this after editing anything under src/web/src/*.ts:
//   bun scripts/build-web.ts
//
// tests/web-build.test.ts re-runs this exact Bun.build() in-memory and
// byte-compares against the committed file, so a stale bundle fails CI
// with a clear "run: bun scripts/build-web.ts" message instead of silently
// serving drifted JS.

import { mkdir } from "node:fs/promises";
import { dirname, join } from "node:path";

const ROOT = join(import.meta.dir, "..");
export const ENTRYPOINT = join(ROOT, "src/web/src/main.ts");
export const OUTFILE = join(ROOT, "src/web/app.js");

const HEADER = `// GENERATED — do not edit by hand.
// Source: src/web/src/*.ts (entrypoint main.ts). To regenerate:
//   bun scripts/build-web.ts
// tests/web-build.test.ts enforces that this file matches the source.
`;

/** Runs the actual Bun.build() for the web bundle. Exported so
 *  tests/web-build.test.ts can call the identical build in-memory and
 *  byte-compare instead of duplicating the Bun.build() call/options. */
export async function buildWebBundle(): Promise<string> {
  const result = await Bun.build({
    entrypoints: [ENTRYPOINT],
    minify: false,
    target: "browser",
  });
  if (!result.success) {
    const msgs = result.logs.map((l) => l.message).join("\n");
    throw new Error("bun build failed for the web frontend:\n" + msgs);
  }
  if (result.outputs.length !== 1) {
    throw new Error(
      `expected exactly one output chunk from the web build (got ${result.outputs.length}) — ` +
      "main.ts should have no dynamic import() splitting; check for one before treating this as a bug.",
    );
  }
  const code = await result.outputs[0]!.text();
  return HEADER + code;
}

if (import.meta.main) {
  const code = await buildWebBundle();
  await mkdir(dirname(OUTFILE), { recursive: true });
  await Bun.write(OUTFILE, code);
  console.log(`wrote ${OUTFILE} (${(code.length / 1024).toFixed(1)} KB)`);
}
