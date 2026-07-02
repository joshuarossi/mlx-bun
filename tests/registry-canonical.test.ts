// Registry canonical-revision collapsing + vision-capability detection
// (fast tier — synthetic hub dir, in-memory db, no models, no network).
//
// The HF cache keeps one snapshots/<commit> dir per downloaded revision and
// never deletes old ones, so a repo that upstream pushed to shows up as
// several registry rows. listCanonical() collapses to the refs/main snapshot.

import { afterAll, describe, expect, test } from "bun:test";
import { mkdtempSync, mkdirSync, rmSync, writeFileSync } from "node:fs";
import { tmpdir } from "node:os";
import { join } from "node:path";
import { Registry, visionCapable } from "../src/registry";

const hubs: string[] = [];
afterAll(() => { for (const h of hubs) rmSync(h, { recursive: true, force: true }); });

function makeSnapshot(
  hub: string, repo: string, commit: string,
  config: Record<string, unknown>, opts: { sidecar?: boolean } = {},
): string {
  const snap = join(hub, `models--${repo.replaceAll("/", "--")}`, "snapshots", commit);
  mkdirSync(snap, { recursive: true });
  writeFileSync(join(snap, "config.json"), JSON.stringify(config));
  writeFileSync(join(snap, "model.safetensors"), new Uint8Array(512));
  if (opts.sidecar) writeFileSync(join(snap, "optiq_vision.safetensors"), new Uint8Array(64));
  return snap;
}

function setRef(hub: string, repo: string, ref: string, commit: string): void {
  const refs = join(hub, `models--${repo.replaceAll("/", "--")}`, "refs");
  mkdirSync(refs, { recursive: true });
  writeFileSync(join(refs, ref), commit);
}

describe("Registry.listCanonical", () => {
  test("collapses multi-revision repos to the refs/main snapshot", async () => {
    const hub = mkdtempSync(join(tmpdir(), "mlx-bun-canon-"));
    hubs.push(hub);
    const cfg = { model_type: "llama", num_hidden_layers: 2, hidden_size: 64, vocab_size: 100 };
    makeSnapshot(hub, "test/multi", "aaa111", cfg);
    const canonical = makeSnapshot(hub, "test/multi", "bbb222", cfg);
    setRef(hub, "test/multi", "main", "bbb222");
    makeSnapshot(hub, "test/single", "ccc333", cfg);
    setRef(hub, "test/single", "main", "ccc333");

    const reg = new Registry(":memory:");
    expect(await reg.scan(hub)).toBe(3); // every snapshot is a row

    expect(reg.list()).toHaveLength(3);
    const collapsed = reg.listCanonical();
    expect(collapsed).toHaveLength(2); // one row per repo
    const multi = collapsed.find((m) => m.repoId === "test/multi")!;
    expect(multi.path).toBe(canonical); // the refs/main snapshot wins

    // filters pass through
    expect(reg.listCanonical({ query: "multi" })).toHaveLength(1);
    // resolve() collapses the same way (no "ambiguous" from stale revisions)
    expect(reg.resolve("multi").path).toBe(canonical);
    reg.close();
  });
});

describe("vision-capability detection", () => {
  test("unified (encoder-free), sidecar (SigLIP), nested-text-config, and text-only", async () => {
    const hub = mkdtempSync(join(tmpdir(), "mlx-bun-vision-"));
    hubs.push(hub);
    // 12B flavor: gemma4_unified_vision in config, NO sidecar file upstream
    makeSnapshot(hub, "v/unified", "u1", {
      model_type: "gemma4_unified",
      text_config: { num_hidden_layers: 2, hidden_size: 64, vocab_size: 100 },
      vision_config: { model_type: "gemma4_unified_vision" },
    });
    // e4b/26B flavor: gemma4_vision + the bf16 SigLIP sidecar
    makeSnapshot(hub, "v/sidecar", "s1", {
      model_type: "gemma4",
      text_config: { num_hidden_layers: 2, hidden_size: 64, vocab_size: 100 },
      vision_config: { model_type: "gemma4_vision" },
    }, { sidecar: true });
    // gemma4_vision WITHOUT its sidecar: the tower can't load — not capable
    makeSnapshot(hub, "v/sidecar-missing", "m1", {
      model_type: "gemma4",
      text_config: { num_hidden_layers: 2, hidden_size: 64, vocab_size: 100 },
      vision_config: { model_type: "gemma4_vision" },
    });
    // Qwen3.5 nests a copy of its own TEXT config under vision_config —
    // key presence alone must not read as vision
    makeSnapshot(hub, "v/qwen", "q1", {
      model_type: "qwen3_5", num_hidden_layers: 2, hidden_size: 64, vocab_size: 100,
      vision_config: { model_type: "qwen3_5" },
    });
    makeSnapshot(hub, "v/text-only", "t1", {
      model_type: "llama", num_hidden_layers: 2, hidden_size: 64, vocab_size: 100,
    });

    const reg = new Registry(":memory:");
    await reg.scan(hub);
    const by = (q: string) => reg.resolve(q);

    const unified = by("unified");
    expect(unified.hasVisionSidecar).toBe(false);
    expect(unified.visionConfigType).toBe("gemma4_unified_vision");
    expect(visionCapable(unified)).toBe(true); // vision WITHOUT a sidecar

    expect(visionCapable(by("sidecar-missing"))).toBe(false);
    const sc = reg.list({ query: "v/sidecar" }).find((m) => m.repoId === "v/sidecar")!;
    expect(sc.hasVisionSidecar).toBe(true);
    expect(visionCapable(sc)).toBe(true);

    expect(by("qwen").visionConfigType).toBeNull();
    expect(visionCapable(by("qwen"))).toBe(false);
    expect(visionCapable(by("text-only"))).toBe(false);

    // list({vision:true}) matches capability, not just sidecar presence
    const vis = reg.list({ vision: true }).map((m) => m.repoId).sort();
    expect(vis).toEqual(["v/sidecar", "v/unified"]);
    // ...and vision:false is its exact complement (NULL vision_config_type
    // must not poison the NOT branch)
    const noVis = reg.list({ vision: false }).map((m) => m.repoId).sort();
    expect(noVis).toEqual(["v/qwen", "v/sidecar-missing", "v/text-only"]);
    reg.close();
  });
});
