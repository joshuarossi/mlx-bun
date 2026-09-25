// In-test entity gold for the resolver/route/pipeline tests.
//
// Main read `goldens/dreaming-entities-gold.json` (a published dataset, not a
// repository file). The groups below are the slice those tests assert on — the
// camera/lens cluster plus the software projects — written here so no golden
// file is committed. `loadDreamingGold()` with no file present yields an empty
// gold; every test passes this one explicitly.

import type { DreamingGold } from "../../../src/memory/resolve";

export const TEST_GOLD: DreamingGold = {
  variantGroups: [
    { canonical: "Panasonic Lumix S5IIX", kind: "thing", domain: "photography",
      variants: ["S5IIX", "S5IIx", "S5 IIX", "the S5IIx", "Lumix S5IIX", "LUMIX S5IIx", "the Panasonic", "my Lumix S5IIX", "the Lumix", "S5II X"] },
    { canonical: "L-Mount", kind: "standard", domain: "photography",
      variants: ["L-Mount", "L-mount", "L mount", "L Mount", "the L mount", "AF (L Mount)", "L-mount glass"] },
    { canonical: "Sigma 150-600", kind: "thing", domain: "photography",
      variants: ["Sigma 150-600", "Sigma 150-600mm", "the Sigma 150-600", "150-600", "the Sigma", "Sigma 150 600"] },
    { canonical: "Lumix 75-300", kind: "thing", domain: "photography",
      variants: ["Lumix 75-300", "Lumix 75-300mm", "the Lumix 75-300", "75-300", "the 75-300"] },
    { canonical: "Sankor 16C", kind: "thing", domain: "vintage-optics-anamorphic",
      variants: ["Sankor 16C", "Sankor 16-C", "Sankor 16D", "Sankor 16-D", "Sankor", "the Sankor", "16C", "the Sankor adapter", "the 16C"] },
    { canonical: "M42 mount", kind: "standard", domain: "vintage-optics-anamorphic",
      variants: ["M42", "M42 mount", "the M42 mount", "M-42", "M42 primes", "M42 glass"] },
    { canonical: "EF mount", kind: "standard", domain: "photography",
      variants: ["EF", "EF mount", "the EF mount", "EF glass", "Canon EF", "adapted EF"] },
    { canonical: "anamorphic adapter", kind: "thing", domain: "vintage-optics-anamorphic",
      variants: ["anamorphic", "anamorphic adapter", "anamorphic lens", "anamorphics", "anamorphic projection lens", "projection anamorphic", "anamorphic lens adapter"] },
    { canonical: "Helios 44-2", kind: "thing", domain: "vintage-optics-anamorphic",
      variants: ["Helios 44-2", "Helios", "the Helios", "Helios 44", "44-2", "my Helios"] },
    { canonical: "Claude Code", kind: "project", domain: "ai-tooling",
      variants: ["Claude Code", "Claude Code CLI", "the Claude Code runtime", "claude code", "CC", "Claude Code (CLI)"] },
    { canonical: "mlx-bun", kind: "project", domain: "local-inference",
      variants: ["mlx-bun", "the mlx-bun project", "mlx-bun runtime", "mlxbun", "mlx bun", "the mlx-bun runtime"] },
    { canonical: "DaVinci Resolve", kind: "project", domain: "color-science",
      variants: ["DaVinci Resolve", "Resolve", "Davinci Resolve", "DaVinci", "Resolve Studio", "da vinci resolve"] },
    { canonical: "Igor Telyatnikov", kind: "person", domain: "work",
      variants: ["Igor Telyatnikov", "Igor", "Telyatnikov", "the CEO"] },
  ],
  notableEntities: [
    { name: "Panasonic Lumix S5IIX", kind: "thing", domain: "photography", aliases: ["S5IIX", "S5IIx", "S5 IIX", "Lumix S5IIX", "the Panasonic"], whyNotable: "owned camera body" },
    { name: "L-Mount", kind: "standard", domain: "photography", aliases: ["L-Mount", "L mount", "L-mount glass"], whyNotable: "the lens standard in use" },
    { name: "M42 mount", kind: "standard", domain: "vintage-optics-anamorphic", aliases: ["M42", "M42 mount", "M42 primes"], whyNotable: "adapted mount" },
    { name: "EF mount", kind: "standard", domain: "photography", aliases: ["EF", "EF mount", "Canon EF"], whyNotable: "adapted mount" },
    { name: "Sigma 150-600", kind: "thing", domain: "photography", aliases: ["Sigma 150-600", "150-600"], whyNotable: "owned lens" },
    { name: "Lumix 75-300", kind: "thing", domain: "photography", aliases: ["Lumix 75-300", "75-300"], whyNotable: "owned lens" },
    { name: "Sankor 16C", kind: "thing", domain: "vintage-optics-anamorphic", aliases: ["Sankor 16C", "Sankor", "16C", "Sankor 16-D"], whyNotable: "owned adapter" },
    { name: "Helios 44-2", kind: "thing", domain: "vintage-optics-anamorphic", aliases: ["Helios 44-2", "Helios", "44-2"], whyNotable: "owned lens" },
    { name: "DaVinci Resolve", kind: "project", domain: "color-science", aliases: ["DaVinci Resolve", "Resolve", "DaVinci"], whyNotable: "grading tool in use" },
    { name: "Claude Code", kind: "project", domain: "ai-tooling", aliases: ["Claude Code", "Claude Code CLI", "CC"], whyNotable: "daily tool" },
    { name: "mlx-bun", kind: "project", domain: "local-inference", aliases: ["mlx-bun", "the mlx-bun project"], whyNotable: "the project" },
    { name: "MLX", kind: "standard", domain: "local-inference", aliases: ["MLX", "Apple MLX"], whyNotable: "the framework" },
    { name: "mlx-lm", kind: "project", domain: "local-inference", aliases: ["mlx-lm", "MLX-LM"], whyNotable: "the oracle" },
    { name: "Igor Telyatnikov", kind: "person", domain: "work", aliases: ["Igor Telyatnikov", "Igor", "the CEO"], whyNotable: "recurring named colleague" },
  ],
};
