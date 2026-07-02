// gc planning + execution (fast tier — synthetic hub tree, no network).
//
// Layout under test is the real HF cache shape:
//   models--<org>--<name>/blobs/<sha>
//   models--<org>--<name>/snapshots/<commit>/<file> -> ../../blobs/<sha>
//   models--<org>--<name>/refs/main                 (commit)
//
// Invariants: refs/* snapshots are never deleted; an unreferenced snapshot
// carrying files the kept set lacks is skipped (warn) unless force; blobs
// survive while ANY surviving snapshot links to them.

import { afterAll, describe, expect, test } from "bun:test";
import { existsSync, mkdirSync, mkdtempSync, rmSync, symlinkSync, writeFileSync } from "node:fs";
import { tmpdir } from "node:os";
import { join } from "node:path";
import { executeGc, planGc, planRepoGc } from "../src/registry";

const hubs: string[] = [];
afterAll(() => { for (const h of hubs) rmSync(h, { recursive: true, force: true }); });

interface RepoSpec {
  refs?: Record<string, string>;
  /** commit -> { filename -> blob name }; blob content = blob name padded. */
  snapshots: Record<string, Record<string, string>>;
}

function makeRepo(hub: string, repo: string, spec: RepoSpec): string {
  const repoDir = join(hub, `models--${repo.replaceAll("/", "--")}`);
  const blobsDir = join(repoDir, "blobs");
  mkdirSync(blobsDir, { recursive: true });
  for (const [commit, files] of Object.entries(spec.snapshots)) {
    const snap = join(repoDir, "snapshots", commit);
    mkdirSync(snap, { recursive: true });
    for (const [file, blob] of Object.entries(files)) {
      const blobPath = join(blobsDir, blob);
      if (!existsSync(blobPath)) writeFileSync(blobPath, blob.padEnd(100, "x")); // 100 B each
      const depth = file.split("/").length - 1;
      const linkPath = join(snap, file);
      mkdirSync(join(linkPath, ".."), { recursive: true });
      symlinkSync(join("../".repeat(depth + 2), "blobs", blob), linkPath);
    }
  }
  for (const [ref, commit] of Object.entries(spec.refs ?? {})) {
    mkdirSync(join(repoDir, "refs"), { recursive: true });
    writeFileSync(join(repoDir, "refs", ref), commit);
  }
  return repoDir;
}

describe("gc planning", () => {
  test("stale snapshot with files the canonical lacks: skipped without force, pruned with", () => {
    const hub = mkdtempSync(join(tmpdir(), "mlx-bun-gc-"));
    hubs.push(hub);
    // The live case shape: stale snapshot has optiq_vision.safetensors (blob E)
    // + its own weights (M1); canonical dropped the sidecar, new weights (M2);
    // shared config blob (SH) linked from both.
    const repoDir = makeRepo(hub, "t/warn", {
      refs: { main: "bbb" },
      snapshots: {
        aaa: { "model.safetensors": "M1", "config.json": "SH", "optiq_vision.safetensors": "E" },
        bbb: { "model.safetensors": "M2", "config.json": "SH" },
      },
    });

    const plan = planRepoGc(repoDir);
    expect(plan.keepSnapshots).toEqual([join(repoDir, "snapshots", "bbb")]);
    expect(plan.pruneSnapshots).toEqual([]);
    expect(plan.skippedSnapshots).toHaveLength(1);
    expect(plan.skippedSnapshots[0]!.extraFiles).toEqual(["optiq_vision.safetensors"]);
    // skipped snapshot's blobs stay live — nothing reclaimed without force
    expect(plan.deadBlobs).toEqual([]);
    expect(plan.reclaimBytes).toBe(0);

    const forced = planRepoGc(repoDir, { force: true });
    expect(forced.pruneSnapshots).toEqual([join(repoDir, "snapshots", "aaa")]);
    expect(forced.skippedSnapshots).toEqual([]);
    expect(forced.deadBlobs.map((b) => b.split("/").pop()).sort()).toEqual(["E", "M1"]);
    expect(forced.reclaimBytes).toBe(200); // two 100 B blobs; SH + M2 survive
  });

  test("stale snapshot with the same file set: pruned, only its unique blobs die", () => {
    const hub = mkdtempSync(join(tmpdir(), "mlx-bun-gc-"));
    hubs.push(hub);
    const repoDir = makeRepo(hub, "t/plain", {
      refs: { main: "new" },
      snapshots: {
        old: { "model.safetensors": "OLD", "config.json": "CFG", "nested/tok.json": "TOK" },
        new: { "model.safetensors": "NEW", "config.json": "CFG", "nested/tok.json": "TOK" },
      },
    });
    const plan = planRepoGc(repoDir);
    expect(plan.pruneSnapshots).toEqual([join(repoDir, "snapshots", "old")]);
    expect(plan.skippedSnapshots).toEqual([]);
    expect(plan.deadBlobs.map((b) => b.split("/").pop())).toEqual(["OLD"]);
    expect(plan.reclaimBytes).toBe(100);

    // execution: snapshot dir + dead blob gone, canonical + shared blobs intact
    const res = executeGc([plan]);
    expect(res).toEqual({ snapshots: 1, blobs: 1, reclaimedBytes: 100 });
    expect(existsSync(join(repoDir, "snapshots", "old"))).toBe(false);
    expect(existsSync(join(repoDir, "snapshots", "new"))).toBe(true);
    expect(existsSync(join(repoDir, "blobs", "OLD"))).toBe(false);
    expect(existsSync(join(repoDir, "blobs", "CFG"))).toBe(true);
    expect(existsSync(join(repoDir, "blobs", "NEW"))).toBe(true);
    expect(existsSync(join(repoDir, "blobs", "TOK"))).toBe(true);
  });

  test("no usable refs → nothing is pruned (conservative)", () => {
    const hub = mkdtempSync(join(tmpdir(), "mlx-bun-gc-"));
    hubs.push(hub);
    // no refs dir at all
    const noRefs = makeRepo(hub, "t/norefs", {
      snapshots: { aaa: { "model.safetensors": "A" }, bbb: { "model.safetensors": "B" } },
    });
    const p1 = planRepoGc(noRefs);
    expect(p1.pruneSnapshots).toEqual([]);
    expect(p1.deadBlobs).toEqual([]);
    // refs point at a snapshot dir that doesn't exist
    const dangling = makeRepo(hub, "t/dangling", {
      refs: { main: "gone" },
      snapshots: { aaa: { "model.safetensors": "A2" } },
    });
    const p2 = planRepoGc(dangling);
    expect(p2.keepSnapshots).toEqual([]);
    expect(p2.pruneSnapshots).toEqual([]);
    expect(p2.deadBlobs).toEqual([]);
  });

  test("resume artifacts (.incomplete/.lock) and truly orphaned blobs", () => {
    const hub = mkdtempSync(join(tmpdir(), "mlx-bun-gc-"));
    hubs.push(hub);
    const repoDir = makeRepo(hub, "t/orphan", {
      refs: { main: "aaa" },
      snapshots: { aaa: { "model.safetensors": "LIVE" } },
    });
    // an orphan blob no snapshot links to (e.g. from an aborted revision)
    writeFileSync(join(repoDir, "blobs", "ORPHAN"), "o".repeat(40));
    // in-flight download artifacts must never be touched
    writeFileSync(join(repoDir, "blobs", "PART.incomplete"), "p".repeat(10));
    writeFileSync(join(repoDir, "blobs", "PART.lock"), "123");
    const plan = planRepoGc(repoDir);
    expect(plan.deadBlobs.map((b) => b.split("/").pop())).toEqual(["ORPHAN"]);
    expect(plan.reclaimBytes).toBe(40);
  });

  test("planGc walks every models--* dir in the hub", () => {
    const hub = mkdtempSync(join(tmpdir(), "mlx-bun-gc-"));
    hubs.push(hub);
    makeRepo(hub, "a/one", {
      refs: { main: "n" },
      snapshots: { o: { "f.safetensors": "X" }, n: { "f.safetensors": "Y" } },
    });
    makeRepo(hub, "b/two", { refs: { main: "s" }, snapshots: { s: { "f.safetensors": "Z" } } });
    mkdirSync(join(hub, "not-a-model"), { recursive: true }); // ignored
    const plans = planGc(hub);
    expect(plans.map((p) => p.repoId).sort()).toEqual(["a/one", "b/two"]);
    const one = plans.find((p) => p.repoId === "a/one")!;
    expect(one.pruneSnapshots).toHaveLength(1);
    expect(plans.find((p) => p.repoId === "b/two")!.pruneSnapshots).toEqual([]);
  });
});
