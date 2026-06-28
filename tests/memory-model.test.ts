// P0-T1 — local-model call seam (src/memory/model.ts).
//
// Covers everything reachable WITHOUT loading the GPU: MODEL_ID snapshot
// resolution, per-stage adapter resolution, and the (stage, adapter-present)
// cache-key input that decides whether a symlink flip yields a fresh mount.
// The live-inference assertions (callLocal returns text; adapter flip changes
// output) are test.skip — the parent runs those serially on the GPU.

import { afterEach, describe, expect, test } from "bun:test";
import { existsSync, mkdirSync, rmSync } from "node:fs";
import { MODEL_ID, adapterDirFor } from "../src/memory/model";
import { snapshotE4bAvailable } from "./paths";

const haveE4b = await snapshotE4bAvailable();

// A stage whose adapter dir we create/destroy in-test to exercise the flip.
const TEST_STAGE = "p0t1-fixture";
const TEST_ADAPTER = `${process.env.HOME}/.cache/mlx-bun/adapters/memory-${TEST_STAGE}`;

describe("memory model seam", () => {
  afterEach(() => {
    rmSync(TEST_ADAPTER, { recursive: true, force: true });
  });

  test.skipIf(!haveE4b)("MODEL_ID resolves to a real dir containing config.json", () => {
    expect(existsSync(`${MODEL_ID}/config.json`)).toBe(true);
  });

  test("adapterDirFor returns undefined when no adapter is symlinked", () => {
    // A stage with no adapter on disk runs base — must resolve to undefined.
    expect(adapterDirFor("definitely-no-such-stage-xyz")).toBeUndefined();
    expect(adapterDirFor(TEST_STAGE)).toBeUndefined();
  });

  test("adapterDirFor returns the dir once an adapter is present, and the key input flips", () => {
    // The cache key is `${stage}:${adapterDir !== undefined}`. Adding the dir
    // must flip that boolean so the next mount is fresh, not a stale base hit.
    const before = adapterDirFor(TEST_STAGE) !== undefined;
    expect(before).toBe(false);

    mkdirSync(TEST_ADAPTER, { recursive: true });
    expect(adapterDirFor(TEST_STAGE)).toBe(TEST_ADAPTER);

    const after = adapterDirFor(TEST_STAGE) !== undefined;
    expect(after).toBe(true);
    expect(after).not.toBe(before); // the cache-key input changed → fresh mount
  });

  // DEFERRED TO PARENT (GPU): loads the model.
  // callLocal(stage, prompt) returns non-empty decoded text for the base model.
  test.skip("callLocal returns text from the base model", async () => {
    const { callLocal } = await import("../src/memory/model");
    const out = await callLocal("chunk", { user: "Say hello." }, { maxTokens: 8 });
    expect(out.length).toBeGreaterThan(0);
  });

  // DEFERRED TO PARENT (GPU): symlink e4b-chunk-300 in as memory-chunk and
  // confirm the adapter mount changes the output vs base (cache keyed on
  // adapter-presence so the flip is observed, not cached away).
  test.skip("adapter flip changes callLocal output", async () => {
    expect(true).toBe(true);
  });
});
