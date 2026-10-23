// The MOSS-Image oracle comparison's own checks, without weights or captures: a
// non-finite value never passes a comparison, input verification hashes bytes and
// rejects an unpinned file a loader could select (the shadow snapshot review
// built: every pinned file intact, an extra transformer index pointing at an
// unverified shard), a symlink's hash-like name is never trusted, and a run whose
// test stopped before recording its checks reports itself incomplete.
import { afterAll, expect, test } from "bun:test";
import { createHash } from "node:crypto";
import { mkdirSync, mkdtempSync, rmSync, symlinkSync, writeFileSync } from "node:fs";
import { tmpdir } from "node:os";
import { join } from "node:path";
import { compare, meets, runStatus, ulpBf16, ulpDistance, ulpFloat32, unpinnedEntries, verifyPinned } from "./moss-image-oracle-checks";

const root = mkdtempSync(join(tmpdir(), "mlx-moss-oracle-checks-"));
afterAll(() => rmSync(root, { recursive: true, force: true }));
const sha = (text: string) => createHash("sha256").update(text).digest("hex");

test("a non-finite value is a mismatch at an infinite distance, on either side, and fails every bound", () => {
  for (const ulp of [ulpBf16, ulpFloat32]) {
    for (const [actual, expected] of [[Number.NaN, 1], [1, Number.NaN], [Number.POSITIVE_INFINITY, Number.POSITIVE_INFINITY], [Number.NEGATIVE_INFINITY, 1]]) {
      expect(ulpDistance(new Float32Array([actual!]), new Float32Array([expected!]), ulp)).toEqual({ total: 1, mismatches: 1, maxUlps: Number.POSITIVE_INFINITY, nonFinite: 1 });
    }
    expect(ulpDistance(new Float32Array([1, 2]), new Float32Array([1, 2]), ulp)).toEqual({ total: 2, mismatches: 0, maxUlps: 0, nonFinite: 0 });
  }
  const stats = compare(new Float32Array([1, Number.NaN, 3, 4]), new Float32Array([1, 2, 3, 4]), 2);
  expect(stats.nonFinite).toBe(1);
  expect(meets(stats, { relative: 1, minCosine: -1 })).toBe(false);
  expect(meets(compare(new Float32Array([1, 2]), new Float32Array([1, 2]), 2), { relative: 0, minCosine: 1 })).toBe(true);
});

test("verification hashes every pinned file's bytes and rejects any unpinned file in a directory a loader reads", async () => {
  const snapshot = join(root, "snapshot");
  const files = { "transformer/config.json": "{}", "transformer/diffusion_pytorch_model.safetensors.index.json": "{\"weight_map\":{}}",
    "transformer/diffusion_pytorch_model.safetensors": "weights", "tokenizer/tokenizer.json": "{}" };
  for (const [file, text] of Object.entries(files)) { mkdirSync(join(snapshot, file, ".."), { recursive: true }); writeFileSync(join(snapshot, file), text); }
  // The top level is not a directory the loaders read: its files may be anything.
  writeFileSync(join(snapshot, "README.md"), "not read");
  const pins = Object.fromEntries(Object.entries(files).map(([file, text]) => [file, sha(text)]));
  const intact = await verifyPinned(snapshot, pins);
  expect([intact.mismatched, unpinnedEntries(snapshot, pins)]).toEqual([[], []]);
  // Every pinned file untouched, plus an index a loader prefers and the shard it names: verification fails before any load.
  writeFileSync(join(snapshot, "transformer/model.safetensors.index.json"), JSON.stringify({ weight_map: { unverified: "unverified.safetensors" } }));
  writeFileSync(join(snapshot, "transformer/unverified.safetensors"), "unverified");
  expect((await verifyPinned(snapshot, pins)).mismatched).toEqual([]);
  expect(unpinnedEntries(snapshot, pins)).toEqual(["transformer/model.safetensors.index.json", "transformer/unverified.safetensors"]);
  // A changed pinned file is caught by its bytes.
  writeFileSync(join(snapshot, "tokenizer/tokenizer.json"), "{\"changed\":true}");
  expect((await verifyPinned(snapshot, pins)).mismatched).toEqual([`tokenizer/tokenizer.json: ${sha("{\"changed\":true}")}, pinned ${sha("{}")}`]);
});

test("a symlink named after the pinned hash is recorded as provenance and verified by its target's bytes", async () => {
  const snapshot = join(root, "linked"), blobs = join(root, "blobs");
  mkdirSync(join(snapshot, "transformer"), { recursive: true });
  mkdirSync(blobs, { recursive: true });
  const claimed = sha("the pinned bytes");
  writeFileSync(join(blobs, claimed), "other bytes");
  symlinkSync(join(blobs, claimed), join(snapshot, "transformer/config.json"));
  const verification = await verifyPinned(snapshot, { "transformer/config.json": claimed });
  expect(verification.provenanceOnly).toEqual({ "transformer/config.json": claimed });
  expect(verification.mismatched).toEqual([`transformer/config.json: ${sha("other bytes")}, pinned ${claimed}`]);
});

test("a run whose test stopped before recording its checks, or whose inputs were not verified, is incomplete, never passed", () => {
  const tests = ["schedule", "conditioner", "dit"];
  expect(runStatus({ inputsVerified: true, tests, completed: new Set(["schedule", "conditioner"]), failures: [] }))
    .toEqual({ status: "incomplete", inputsVerified: true, incomplete: ["dit"] });
  expect(runStatus({ inputsVerified: false, tests, completed: new Set(tests), failures: [] }).status).toBe("incomplete");
  expect(runStatus({ inputsVerified: true, tests, completed: new Set(tests), failures: ["dit block 22"] }).status).toBe("checks failed");
  expect(runStatus({ inputsVerified: true, tests, completed: new Set(tests), failures: [] }).status).toBe("checks passed");
});
