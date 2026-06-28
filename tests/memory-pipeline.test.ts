// P6-T4 — pipeline DAG wiring: the pure orchestration helpers (kind/alias map +
// CREATE-target selection). The model stages (ENTITY-EXTRACT / ROUTE / CREATE)
// reach the GPU through the live `callLocal` ESM binding, so the real end-to-end
// cold-start is the one-load smoke in
// scripts/experiments/dreaming-coldstart-smoke.ts — not a unit test.

import { describe, expect, it } from "bun:test";

import { buildEntityMeta, selectCreateTargets, type RouteDecision } from "../src/memory/pipeline";
import { entityStem } from "../src/memory/synthesize";

describe("entityStem", () => {
  it("maps an f-stop slash to a hyphen so the stem stays a bare filename", () => {
    const stem = entityStem("50mm f/1.8");
    expect(stem).toBe("50mm_f-1.8");
    expect(stem).not.toContain("/");
  });

  it("leaves a separator-free name as plain underscored stem", () => {
    expect(entityStem("Panasonic Lumix S5IIX")).toBe("Panasonic_Lumix_S5IIX");
  });

  it("strips filesystem-hostile characters and leading dots", () => {
    expect(entityStem('..\\weird:name?')).toBe("weirdname");
  });
});

function dec(entity: string, action: RouteDecision["action"], routedChunks: number): RouteDecision {
  return { entity, action, stats: { routedChunks, subjectEngagement: false } };
}

describe("buildEntityMeta", () => {
  it("maps gold canonicals to their kind and folds aliases", () => {
    const meta = buildEntityMeta();
    expect(meta.kindByCanonical.get("L-Mount")).toBe("standard");
    expect(meta.kindByCanonical.get("Panasonic Lumix S5IIX")).toBe("thing");
    expect(meta.kindByCanonical.get("Igor Telyatnikov")).toBe("person");
    expect(meta.aliasesByCanonical.get("Panasonic Lumix S5IIX")).toContain("S5IIX");
  });
});

describe("selectCreateTargets", () => {
  const decisions = [
    dec("L-Mount", "create", 5),
    dec("Helios 44-2", "create", 4),
    dec("Sankor 16C", "create", 2),
    dec("Captured Subject", "capture", 1),
    dec("Panasonic Lumix S5IIX", "create", 3),
  ];

  it("ranks creatable entities by routed-chunk count then name, and caps", () => {
    expect(selectCreateTargets(decisions, 2)).toEqual(["L-Mount", "Helios 44-2"]);
  });

  it("never selects a captured entity", () => {
    expect(selectCreateTargets(decisions, 10)).not.toContain("Captured Subject");
  });

  it("force-includes mustInclude even past the natural ranking, honoring the cap", () => {
    const out = selectCreateTargets(decisions, 2, ["Panasonic Lumix S5IIX"]);
    expect(out[0]).toBe("Panasonic Lumix S5IIX");
    expect(out.length).toBe(2);
  });

  it("ignores a mustInclude that did not earn a create", () => {
    expect(selectCreateTargets(decisions, 5, ["Captured Subject"])).not.toContain("Captured Subject");
  });
});
