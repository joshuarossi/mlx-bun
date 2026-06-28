// P5-T4 — ROUTE deterministic gate (no model).
//
// Covers everything reachable WITHOUT the GPU: dedup-driven resolve-to-one,
// chunk fan-out to multiple entities, the trigram shortlist, and the CREATE-gate
// arithmetic + park/route accumulation. The model disambiguation + substantive
// paths are exercised by the parent's GPU smoke (single model load), not here.

import { describe, expect, it } from "bun:test";
import { goldResolver, loadDreamingGold } from "../src/memory/resolve";
import {
  RouteAccumulator,
  CAPTURED_BUCKET,
  createGate,
  routeChunkSurfaces,
  trigramShortlist,
} from "../src/memory/route";

const gold = loadDreamingGold();

describe("route — dedup-driven resolve-to-one", () => {
  it("two surface variants of the S5IIX route to ONE entity", async () => {
    const resolver = goldResolver(gold);
    const routes = await routeChunkSurfaces(
      resolver,
      [{ surface: "Panasonic S5IIX" }, { surface: "Lumix S5 IIX" }],
      "camera talk",
      { noModel: true },
    );
    const entities = new Set(routes.map((r) => r.entity));
    expect(entities.size).toBe(1);
    expect([...entities][0]).toBe("Panasonic Lumix S5IIX");
  });
});

describe("route — fan-out", () => {
  it("a chunk fans out to every distinct entity it mentions", async () => {
    const resolver = goldResolver(gold);
    const routes = await routeChunkSurfaces(
      resolver,
      [{ surface: "S5IIX" }, { surface: "anamorphic" }, { surface: "L-Mount" }],
      "shooting anamorphic on the body",
      { noModel: true },
    );
    const entities = routes.map((r) => r.entity).sort();
    expect(entities).toEqual(
      ["Panasonic Lumix S5IIX", "anamorphic adapter", "L-Mount"].sort(),
    );
  });

  it("the accumulator records the fan-in per entity for one chunk", () => {
    const resolver = goldResolver(gold);
    const acc = new RouteAccumulator(resolver.canonicals());
    const chunk = "convA:0-3";
    for (const e of ["Panasonic Lumix S5IIX", "anamorphic adapter", "L-Mount"]) {
      acc.enqueue(e, chunk);
    }
    const decisions = acc.decisions();
    // All three are known entities → routed, each with one chunk.
    expect(decisions.map((d) => d.entity).sort()).toEqual(
      ["Panasonic Lumix S5IIX", "anamorphic adapter", "L-Mount"].sort(),
    );
    for (const d of decisions) {
      expect(d.action).toBe("routed");
      expect(d.stats.routedChunks).toBe(1);
    }
  });
});

describe("route — CREATE gate (Bucketing.md: surface everything, no ownership)", () => {
  it("creates when the subject RECURS (≥ the recurrence threshold), no substance needed", () => {
    expect(createGate({ routedChunks: 2, subjectEngagement: false })).toBe("create");
    expect(createGate({ routedChunks: 9, subjectEngagement: false })).toBe("create");
  });

  it("creates a stub on a single genuine-subject chunk", () => {
    expect(createGate({ routedChunks: 1, subjectEngagement: true })).toBe("create");
  });

  it("captures a thin single fleeting mention (never dropped)", () => {
    expect(createGate({ routedChunks: 1, subjectEngagement: false })).toBe("capture");
  });

  it("minted candidates run the gate; the captured ones go to _captured", () => {
    const acc = new RouteAccumulator([]); // nothing known → all minted candidates
    // A subject that recurs across chunks earns an article.
    for (const c of ["c0", "c1", "c2"]) acc.enqueue("Recurring Subject", c);
    // A single chunk that engages a subject genuinely earns a stub.
    acc.enqueue("Emerging Topic", "c3", { subjectEngagement: true });
    // A single fleeting mention with no home is captured, not dropped.
    acc.enqueue("Drive-by Mention", "c4");

    const byEntity = new Map(acc.decisions().map((d) => [d.entity, d.action]));
    expect(byEntity.get("Recurring Subject")).toBe("create");
    expect(byEntity.get("Emerging Topic")).toBe("create");
    expect(byEntity.get("Drive-by Mention")).toBe("capture");

    const captured = acc.decisions().filter((d) => d.action === "capture").map((d) => d.entity);
    expect(captured).toEqual(["Drive-by Mention"]); // → CAPTURED_BUCKET upstream
    expect(CAPTURED_BUCKET).toBe("_captured");
  });
});

describe("route — trigram shortlist", () => {
  it("shortlists existing canonicals by surface overlap, best first", () => {
    const resolver = goldResolver(gold);
    // A typo'd surface the resolver would miss; the shortlist must surface the
    // right canonical as a candidate for the model to confirm.
    const list = trigramShortlist(resolver, "DaVinci Resolv", 5);
    expect(list).toContain("DaVinci Resolve");
    expect(list.length).toBeLessThanOrEqual(5);
  });

  it("returns nothing for a surface with no lexical neighbors", () => {
    const resolver = goldResolver(gold);
    expect(trigramShortlist(resolver, "zzzqxv", 5)).toEqual([]);
  });
});
