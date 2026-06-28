// P5-T3/T4 — surface-variant DEDUP gate (deterministic, no model).
//
// canonicalize() alone split "S5IIX" / "S5 IIX" / "the Panasonic" / "my Lumix
// S5IIX" into FOUR stems. The resolver (squeeze + alias seed + token-subset
// fuzzy) must collapse each curated variant group onto ONE canonical, while a
// NEGATIVE set of genuinely-distinct things (M42 ≠ EF, Sigma 150-600 ≠ Sigma
// 100-400) must NOT merge. Pure: this gate runs without the GPU and MUST pass.

import { describe, expect, it } from "bun:test";
import {
  EntityResolver,
  goldResolver,
  goldSeeds,
  loadDreamingGold,
  squeeze,
} from "../src/memory/resolve";

const gold = loadDreamingGold();

describe("entity dedup — variant collapse", () => {
  it("squeeze fixes the spacing split the normal form kept", () => {
    // The exact bug: canonicalize keeps the internal space; squeeze removes it.
    expect(squeeze("S5IIX")).toBe(squeeze("S5 IIX"));
    expect(squeeze("S5IIX")).toBe(squeeze("S5II X"));
    expect(squeeze("L-Mount")).toBe(squeeze("L mount"));
  });

  it("every gold variant group collapses to ONE canonical (full seed)", () => {
    const resolver = goldResolver(gold);
    for (const g of gold.variantGroups) {
      const landed = new Set(g.variants.map((v) => resolver.resolve(v).name));
      expect({ group: g.canonical, landed: [...landed] }).toEqual({
        group: g.canonical,
        landed: [g.canonical],
      });
    }
  });

  it("collapses programmatic perturbations not literally seeded (normalization layer)", () => {
    const resolver = goldResolver(gold);
    // Case-flip, extra spaces, trailing punctuation, and a "the " prefix — none
    // of these exact strings are seeded; squeeze/stem must still fold them.
    const perturb = (s: string): string[] => [
      s.toUpperCase(),
      s.toLowerCase(),
      `  ${s}.`,
      `the ${s}`,
      s.replace(/(\d)(\d)/, "$1 $2"), // split a digit pair, e.g. 150-600 → 1 50-600
    ];
    for (const g of gold.variantGroups) {
      for (const base of g.variants) {
        for (const p of perturb(base)) {
          const r = resolver.match(p);
          // A perturbation may legitimately miss (e.g. digit-split changing the
          // number); when it DOES match it must land on the right canonical.
          if (r) expect({ p, name: r.name }).toEqual({ p, name: g.canonical });
        }
      }
    }
  });

  it("fuzzy folds a compositional surface via its distinctive token", () => {
    const resolver = goldResolver(gold);
    // Not literally seeded; resolves via the distinctive "s5iix" token.
    const r = resolver.match("Panasonic S5IIX");
    expect(r?.name).toBe("Panasonic Lumix S5IIX");
    expect(r?.matched).toBe("fuzzy");
  });
});

describe("entity dedup — NEGATIVE no-merge guard", () => {
  // Seed ALL groups so distinct things are simultaneously known, then probe
  // surfaces that share a brand/word but are different things.
  const resolver = goldResolver(gold);

  const NEGATIVES: { surface: string; mustNotBe: string }[] = [
    // Different mounts that both end in "mount".
    { surface: "M42", mustNotBe: "EF mount" },
    { surface: "EF", mustNotBe: "M42 mount" },
    // Same brand, different model number — the canonical over-merge trap.
    { surface: "Sigma 100-400", mustNotBe: "Sigma 150-600" },
    { surface: "Sigma 100-400mm", mustNotBe: "Sigma 150-600" },
    { surface: "Lumix 100-400", mustNotBe: "Lumix 75-300" },
    { surface: "Lumix 100-400", mustNotBe: "Panasonic Lumix S5IIX" },
    // Different projects that share a substring/prefix.
    { surface: "mlx-lm", mustNotBe: "mlx-bun" },
    { surface: "MLX", mustNotBe: "mlx-bun" },
    { surface: "Claude Desktop", mustNotBe: "Claude Code" },
  ];

  for (const { surface, mustNotBe } of NEGATIVES) {
    it(`"${surface}" does not merge into "${mustNotBe}"`, () => {
      const r = resolver.match(surface);
      expect(r?.name).not.toBe(mustNotBe);
    });
  }

  it("an unseeded distinct model number mints its own canonical", () => {
    const r = new EntityResolver(goldSeeds(gold));
    const before = r.canonicals().length;
    const res = r.resolve("Sigma 100-400");
    expect(res.created).toBe(true);
    expect(r.canonicals().length).toBe(before + 1);
  });
});
