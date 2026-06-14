// Auto-model selection (mlx-bun pi / serve with no query). Pure logic — no
// registry, no weights. Encodes the rule: prefer e4b; otherwise the largest
// model that leaves the machine usable for other apps; never auto-grab the
// 26B "dedicate the machine" model on a small Mac (it's --query only), but
// fall back to it if it's the only thing downloaded.

import { describe, expect, it } from "bun:test";
import { chooseAutoModel, DEFAULT_REPO_ID } from "../src/fit";

const E4B = DEFAULT_REPO_ID;
const c = (repoId: string, sizeBytes: number) => ({ repoId, sizeBytes });
// Rough OptiQ-4bit footprints (bytes): cpm ~1G, e4b ~9G, 12B ~10G, 26B ~17G.
const CPM = c("mlx-community/MiniCPM5-1B-OptiQ-4bit", 1e9);
const E = c(E4B, 9e9);
const B12 = c("mlx-community/gemma-4-12B-it-OptiQ-4bit", 10e9);
const B26 = c("mlx-community/gemma-4-26B-A4B-it-OptiQ-4bit", 17e9);

// 24 GB coexistence budget excludes the 26B (~17G) but keeps e4b/12B (~10G).
const coexist24 = (x: { sizeBytes: number }) => x.sizeBytes <= 14e9;
const fitsAll = () => true;

describe("chooseAutoModel", () => {
  it("prefers e4b whenever it's downloaded and fits (every machine)", () => {
    expect(chooseAutoModel([CPM, E, B12, B26], E4B, fitsAll, coexist24)?.repoId).toBe(E4B);
  });

  it("without e4b on a 24 GB Mac, picks 12B — not the 26B", () => {
    expect(chooseAutoModel([CPM, B12, B26], E4B, fitsAll, coexist24)?.repoId).toBe(B12.repoId);
  });

  it("never auto-picks CPM over a real model (CPM is the instant starter, not a default)", () => {
    // CPM fits everything, but 12B is the largest coexistence-safe choice.
    expect(chooseAutoModel([CPM, B12], E4B, fitsAll, coexist24)?.repoId).toBe(B12.repoId);
  });

  it("last resort: if the 26B is the only model, load it (fits full budget, not coexist)", () => {
    const onlyHeavy = chooseAutoModel([B26], E4B, fitsAll, () => false);
    expect(onlyHeavy?.repoId).toBe(B26.repoId);
  });

  it("on a big-RAM Mac the 26B clears coexistence and wins when e4b is absent", () => {
    // big RAM: everything is coexistence-safe → largest wins.
    expect(chooseAutoModel([CPM, B12, B26], E4B, fitsAll, fitsAll)?.repoId).toBe(B26.repoId);
  });

  it("returns undefined when nothing fits at all", () => {
    expect(chooseAutoModel([E, B26], E4B, () => false, () => false)).toBeUndefined();
  });
});
