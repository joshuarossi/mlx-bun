// P7-T1 · SECTION-ROUTE eval (judge-style, bounded, single model load).
//
// Proxy gold: ~3–4 multi-section synthesized articles from the smoke vault, and a
// FROZEN set of obvious (chunk, article) pairs that ROUTE matched — each chunk
// hand-labeled (cloud-judge-style, frozen here) with the ONE section it belongs
// to. We run the real SECTION-ROUTE M×N binary grid (base Gemma-4-e4b, the
// `section` stage, maxTokens 4) over each pair and report:
//   - per-pair section accuracy (predicted set == gold set)
//   - per-chunk section-set Jaccard (target mean ≥ 0.6)
//   - that a chunk fitting NO existing section yields a NAMED new section, not a drop.
//
// Bounded by construction: ≤20 pairs, ~4 binary calls each + a handful of
// new-section calls, ONE model load (callLocal caches the mount). Quality is
// judged on the routing OUTPUT vs the frozen gold — never Lucien bucket-F1.
//
// Substrate is READ-ONLY: we read the smoke vault articles, construct synthetic
// chunks in-memory, and never write the prod DB or the vault.
//
//   MLX_BUN_WIKI=/Users/joshrossi/.mlx-bun/wiki-smoke bun scripts/memory/eval-section-route.ts

import { mkdirSync } from "node:fs";
import { join } from "node:path";

import {
  firstSentences,
  routeSections,
  type SectionRouteArticle,
  type SectionRouteChunk,
} from "../../src/memory/cluster";
import { readArticle } from "../../src/memory/vault";

const SMOKE_VAULT = "/Users/joshrossi/.mlx-bun/wiki-smoke";
const ROOT = join(import.meta.dir, "..", "..");
const REPORT_DIR = join(ROOT, "reports", "dreaming");
const REPORT = join(REPORT_DIR, "p7-section-route.json");

// ---- FROZEN proxy gold -----------------------------------------------------
// Each entry: a synthetic chunk + the article ROUTE matched + the ONE gold
// section anchor it belongs to (cloud-judge-style label, frozen). `gold: []`
// marks a deliberately no-fit chunk that must yield a NAMED new section.

interface GoldPair {
  stem: string;
  label: string;
  gist: string;
  gold: string[];
}

const GOLD: GoldPair[] = [
  // — Panasonic_Lumix_S5IIX —
  {
    stem: "Panasonic_Lumix_S5IIX",
    label: "Relieving mount torque with a lens clamp",
    gist: "Mounting a heavy adapted telephoto torques the L-Mount; moving the tripod support to a foot on the lens clamp takes the load off the camera's mount.",
    gold: ["lens-mounting-and-adapters"],
  },
  {
    stem: "Panasonic_Lumix_S5IIX",
    label: "Hot shoe XLR audio adapter",
    gist: "The hot shoe carries electronic contacts that power and feed the DMW-XLR1 XLR microphone adapter for professional audio input.",
    gold: ["camera-features-and-accessories"],
  },
  {
    stem: "Panasonic_Lumix_S5IIX",
    label: "IBIS and card support for manual shooting",
    gist: "The body's in-body image stabilization steadies handheld manual-lens shooting, and it records to SDXC UHS-II cards.",
    gold: ["camera-body-compatibility"],
  },
  {
    stem: "Panasonic_Lumix_S5IIX",
    label: "Pairing the Helios with the body",
    gist: "Pairing the vintage Helios 44-2 with the S5IIX blends swirly-bokeh character with modern capture; focus peaking helps nail manual focus.",
    gold: ["lens-pairing-considerations"],
  },
  // — photography —
  {
    stem: "photography",
    label: "Vintage swirly-bokeh primes",
    gist: "The Biotar 75mm f/1.5 and the Meyer-Optik Trioplan 100mm are vintage lenses famous for dramatic swirly and soap-bubble out-of-focus rendering.",
    gold: ["swirly-bokeh-lenses"],
  },
  {
    stem: "photography",
    label: "Budget supertelephoto reach",
    gist: "To get reach past 85mm, the Sigma 150-600mm f/5-6.3 Sports gives long focal lengths and strong compression on a budget.",
    gold: ["telephoto-lens-selection"],
  },
  {
    stem: "photography",
    label: "Helios preset aperture rings",
    gist: "The Helios 44-2 has a two-ring preset aperture: one ring presets the minimum opening, the other stops down from f/2 to it for a bright focusing image.",
    gold: ["lens-characteristics"],
  },
  {
    stem: "photography",
    label: "Helios on the S5IIX body",
    gist: "Pairing the Helios 44-2 with the Panasonic S5IIX joins vintage character to modern imaging, with IBIS smoothing handheld manual work.",
    gold: ["camera-body-pairing"],
  },
  // — 50mm_f-1.8 —
  {
    stem: "50mm_f-1.8",
    label: "Nifty fifty as a portrait lens",
    gist: "The 50mm f/1.8 is a classic portrait lens: flattering for faces with shallow depth of field and good subject isolation in low light.",
    gold: ["using-50mm-f-1-8-for-portraits"],
  },
  {
    stem: "50mm_f-1.8",
    label: "Anamorphic adapter on the fifty",
    gist: "Putting a 2x anamorphic adapter in front of the 50mm taking lens gives a cinematic squeeze, though autofocus through the adapter is unreliable.",
    gold: ["attaching-anamorphic-lenses"],
  },
  {
    stem: "50mm_f-1.8",
    label: "Squeezed field of view math",
    gist: "With a 2x anamorphic adapter the 58mm taking lens yields a much wider horizontal field of view, roughly equivalent to a 29mm lens once de-squeezed.",
    gold: ["focal-length-equivalence"],
  },
  {
    stem: "50mm_f-1.8",
    label: "Fifty vs Sigma 50 Art",
    gist: "Against the owned 50mm f/1.8, the Sigma 50mm f/1.4 Art is sharper with better bokeh and low-light, but larger and heavier.",
    gold: ["50mm-f-1-8-characteristics"],
  },
  // — anamorphic_adapter —
  {
    stem: "anamorphic_adapter",
    label: "Building the anamorphic rig",
    gist: "Building the rig means clamping the adapter to the taking lens, balancing it on rails, and adding a diopter for closer focus.",
    gold: ["anamorphic-rig-setup"],
  },
  {
    stem: "anamorphic_adapter",
    label: "Sankor 16C taking-lens needs",
    gist: "The Sankor 16C is a 2x projection anamorphic; it needs a taking lens around 50mm or longer to avoid vignetting in the corners.",
    gold: ["sankor-adapter-compatibility"],
  },
  {
    stem: "anamorphic_adapter",
    label: "Oval bokeh from the Helios",
    gist: "Behind the anamorphic, the Helios 44-2 wide open at f/2 throws oval out-of-focus highlights and its signature swirl.",
    gold: ["helios-bokeh-characteristics"],
  },
  {
    stem: "anamorphic_adapter",
    label: "Desqueeze in post workflow",
    gist: "A dual-clamp setup holds the adapter rigid while shooting, and in post the 2x squeeze is de-squeezed to restore correct proportions.",
    gold: ["workflow-and-mounting-options"],
  },
  // — deliberately NO-FIT (must yield a NAMED new section, not a drop) —
  {
    stem: "Panasonic_Lumix_S5IIX",
    label: "Firmware update bricked the body",
    gist: "A botched firmware flash bricked the camera mid-update and it had to go to a service center for recovery.",
    gold: [],
  },
  {
    stem: "photography",
    label: "Archival print framing",
    gist: "Choosing acid-free archival mats and frame moulding for displaying finished prints on a gallery wall.",
    gold: [],
  },
];

// ---- per-chunk Jaccard -----------------------------------------------------

function jaccard(pred: Set<string>, gold: Set<string>): number {
  let inter = 0;
  for (const p of pred) if (gold.has(p)) inter++;
  const union = pred.size + gold.size - inter;
  return union === 0 ? 1 : inter / union;
}

// ---- run -------------------------------------------------------------------

const articleCache = new Map<string, SectionRouteArticle>();
async function loadArticle(stem: string): Promise<SectionRouteArticle> {
  const hit = articleCache.get(stem);
  if (hit) return hit;
  const { content } = await readArticle(SMOKE_VAULT, stem);
  const a: SectionRouteArticle = { stem, content };
  articleCache.set(stem, a);
  return a;
}

console.log(`SECTION-ROUTE eval — substrate ${SMOKE_VAULT} (read-only)`);
console.log(`frozen proxy gold: ${GOLD.length} (chunk, article) pairs over ${new Set(GOLD.map((g) => g.stem)).size} articles\n`);

interface PairOutcome {
  stem: string;
  label: string;
  gold: string[];
  predicted: string[];
  newSection: string | null;
  jaccard: number;
  exact: boolean;
  noFit: boolean;
}

const outcomes: PairOutcome[] = [];
let i = 0;
for (const g of GOLD) {
  const article = await loadArticle(g.stem);
  const chunk: SectionRouteChunk = {
    id: `gold:${i}`,
    label: g.label,
    gist: firstSentences(g.gist, 2),
  };
  const res = await routeSections(chunk, article); // real callLocal("section", …)
  const noFit = g.gold.length === 0;
  const predicted = res.matchedAnchors;
  const goldSet = new Set(g.gold);
  const predSet = new Set(predicted);
  const j = jaccard(predSet, goldSet);
  const exact = predSet.size === goldSet.size && [...predSet].every((p) => goldSet.has(p));
  outcomes.push({
    stem: g.stem,
    label: g.label,
    gold: g.gold,
    predicted,
    newSection: res.newSection?.anchor ?? null,
    jaccard: j,
    exact,
    noFit,
  });
  const tag = noFit ? (res.newSection ? `NEW→${res.newSection.title}` : "DROPPED(!)") : `J=${j.toFixed(2)}${exact ? " ✓" : ""}`;
  console.log(`[${++i}/${GOLD.length}] ${g.stem} :: ${g.label}`);
  console.log(`        gold=${JSON.stringify(g.gold)} pred=${JSON.stringify(predicted)} ${tag}`);
}

// ---- metrics ---------------------------------------------------------------

const fitPairs = outcomes.filter((o) => !o.noFit);
const noFitPairs = outcomes.filter((o) => o.noFit);
const meanJaccard = fitPairs.reduce((s, o) => s + o.jaccard, 0) / Math.max(1, fitPairs.length);
const exactAcc = fitPairs.filter((o) => o.exact).length / Math.max(1, fitPairs.length);
const newSectionWhenNoFit = noFitPairs.length > 0 && noFitPairs.every((o) => o.newSection != null);

console.log(`\n=== SECTION-ROUTE metrics ===`);
console.log(`pairs evaluated      : ${outcomes.length} (${fitPairs.length} fit + ${noFitPairs.length} no-fit)`);
console.log(`mean section Jaccard : ${meanJaccard.toFixed(3)}  (target ≥ 0.60)  → ${meanJaccard >= 0.6 ? "PASS" : "FAIL"}`);
console.log(`exact section-set acc: ${exactAcc.toFixed(3)}`);
console.log(`no-fit → named new   : ${newSectionWhenNoFit ? "PASS" : "FAIL"} (${noFitPairs.filter((o) => o.newSection).length}/${noFitPairs.length} named, 0 dropped)`);

mkdirSync(REPORT_DIR, { recursive: true });
await Bun.write(
  REPORT,
  JSON.stringify(
    {
      generated: new Date().toISOString(),
      substrate: SMOKE_VAULT,
      model: "gemma-4-e4b-it-OptiQ-4bit (base, `section` stage, maxTokens 4)",
      pairsEvaluated: outcomes.length,
      fitPairs: fitPairs.length,
      noFitPairs: noFitPairs.length,
      meanJaccard,
      exactAccuracy: exactAcc,
      newSectionWhenNoFit,
      jaccardTargetMet: meanJaccard >= 0.6,
      outcomes,
    },
    null,
    2,
  ) + "\n",
);
console.log(`\nreport → ${REPORT}`);
process.exit(0);
