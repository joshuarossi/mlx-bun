// Freshness gate for the web frontend bundle (plan §7/§9 Phase 2): runs the
// exact same Bun.build() scripts/build-web.ts uses, in-memory, and
// byte-compares against the committed src/web/app.js. A stale bundle
// (edited src/web/src/*.ts without rerunning the build) fails here with a
// clear fix instruction rather than silently serving drifted JS.
//
// NOTE: this byte-compare assumes the SAME Bun version produced both sides
// (Bun.build's output is not guaranteed byte-stable across Bun versions —
// e.g. minor formatting/codegen changes). This repo pins a Bun version
// (CLAUDE.md: "Bun pinned at >= 1.4.0"; package.json engines.bun) so a
// mismatch here in CI should mean "rerun the build on the pinned Bun", not
// "the test is flaky."
import { describe, expect, it } from "bun:test";
import { readFileSync } from "node:fs";
import { buildWebBundle, OUTFILE } from "../scripts/build-web";

describe("web frontend bundle freshness", () => {
  it("src/web/app.js matches a fresh build of src/web/src/*.ts", async () => {
    const fresh = await buildWebBundle();
    let committed: string;
    try {
      committed = readFileSync(OUTFILE, "utf8");
    } catch {
      throw new Error(
        `${OUTFILE} does not exist — run: bun scripts/build-web.ts`,
      );
    }
    if (fresh !== committed) {
      throw new Error(
        `${OUTFILE} is stale relative to src/web/src/*.ts — run: bun scripts/build-web.ts`,
      );
    }
    expect(fresh).toBe(committed);
  });
});
