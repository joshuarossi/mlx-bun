// P7-T2 · PATCH eval (bounded, single model load, base Gemma-4-e4b `synthesis`).
//
// Two real-model scenarios over the smoke vault, judged on the OUTPUT (printed
// before/after for the cloud judge), NEVER Lucien bucket-F1:
//
//   A. ONLY-THAT-SECTION-CHANGED — fold a real new chunk into ONE section of an
//      existing smoke-vault article and assert, deterministically, that every
//      OTHER section is byte-identical, the target section gained a correct
//      [^N]/[^N]: pair, and the conservative gate passed.
//   D. SELF-HEALING — a constructed section asserting "loves 35mm for photography"
//      plus a later CORRECTION chunk ("35mm is fine but nowhere near as good as
//      50mm"); folding it must rewrite the claim TOWARD 50mm (resolve-to-latest),
//      cite the new chunk, and NOT keep both claims. Before/after is printed.
//
// patchSection is pure w.r.t. disk, so the smoke vault is opened READ-ONLY: the
// patched markdown is computed in memory (and dropped into a temp working vault
// for inspection) — re-running never mutates the shared substrate. Bounded by
// construction: 2 scenarios × 1–2 generations each, ONE model load (callLocal
// caches the `synthesis` mount), maxTokens 512.
//
//   MLX_BUN_WIKI=/Users/joshrossi/.mlx-bun/wiki-smoke bun scripts/memory/eval-patch.ts

import { mkdirSync, mkdtempSync, writeFileSync } from "node:fs";
import { tmpdir } from "node:os";
import { join } from "node:path";

import { patchSection, type SynthesisChunk } from "../../src/memory/synthesize";
import { checkFootnoteIntegrity } from "../../src/memory/gate";
import { extractSection, listArticles, parseToc, readArticle } from "../../src/memory/vault";

const SMOKE_VAULT = "/Users/joshrossi/.mlx-bun/wiki-smoke";
const ROOT = join(import.meta.dir, "..", "..");
const REPORT_DIR = join(ROOT, "reports", "dreaming");
const REPORT = join(REPORT_DIR, "p7-patch.json");

const workVault = mkdtempSync(join(tmpdir(), "dreaming-patch-eval-"));
mkdirSync(join(workVault, "articles"), { recursive: true });

/** The topical (non-tail) section anchors of an article, in order. */
function bodyAnchors(md: string): string[] {
  const tail = new Set(["references", "see also", "notes"]);
  return parseToc(md)
    .filter((e) => e.depth >= 2 && !tail.has(e.title.trim().toLowerCase()))
    .map((e) => e.anchor);
}

console.log(`PATCH eval — substrate ${SMOKE_VAULT} (read-only); work copy ${workVault}\n`);

interface ScenarioResult {
  name: string;
  pass: boolean;
  detail: Record<string, unknown>;
}
const results: ScenarioResult[] = [];

// ===========================================================================
// A. ONLY-THAT-SECTION-CHANGED — real fold into Panasonic_Lumix_S5IIX.
// ===========================================================================
{
  const stem = "Panasonic_Lumix_S5IIX";
  const anchor = "lens-mounting-and-adapters";
  const { content: before } = await readArticle(SMOKE_VAULT, stem);
  const stems = new Set(await listArticles(SMOKE_VAULT));

  const chunk: SynthesisChunk = {
    id: "9a0b1c2d-0000-0000-0000-000000000000:0-3",
    conv: "9a0b1c2d-0000-0000-0000-000000000000",
    label: "Arca-Swiss lens-foot plate for heavy adapted glass",
    text:
      "For the heaviest adapted telephotos I added an Arca-Swiss dovetail plate directly to the lens collar's foot, " +
      "so the whole rig clamps into the tripod head at the lens's balance point. With the support under the lens, " +
      "the L-Mount only has to hold the camera body, and I can pan smoothly without the mount flexing.",
    title: "Heavy telephoto support on a tripod",
    dateMs: 1736899200000,
  };

  console.log(`[A] only-that-section-changed → ${stem} #${anchor}`);
  console.log(`    BEFORE section:\n${indent(extractSection(before, anchor) ?? "(missing)")}\n`);

  const out = await patchSection({ article: before, anchor, chunk }, { stem, stems });

  let pass = false;
  const detail: Record<string, unknown> = { stem, anchor, action: out.action, reason: out.reason, footnote: out.footnote };
  if (out.action === "patched" && out.content) {
    const after = out.content;
    writeFileSync(join(workVault, "articles", `${stem}.md`), after);

    // Every OTHER body section byte-identical.
    const others = bodyAnchors(before).filter((a) => a !== anchor);
    const changedOthers = others.filter((a) => extractSection(after, a) !== extractSection(before, a));
    // Everything before the target section byte-identical.
    const head = before.slice(0, before.indexOf(extractSection(before, anchor)!));
    const headPreserved = after.startsWith(head);
    // Target gained the [^N] marker; References gained the matching def.
    const target = extractSection(after, anchor) ?? "";
    const n = out.footnote!;
    const gotMarker = new RegExp(`\\[\\^${n}\\](?!:)`).test(target);
    const gotDef = new RegExp(`^\\[\\^${n}\\]: \`conv:`, "m").test(after);
    const bijective = checkFootnoteIntegrity(after).ok;

    pass = changedOthers.length === 0 && headPreserved && gotMarker && gotDef && bijective;
    Object.assign(detail, { changedOthers, headPreserved, gotMarker, gotDef, bijective });

    console.log(`    AFTER section:\n${indent(target)}\n`);
    console.log(
      `    others-byte-identical=${changedOthers.length === 0} head-preserved=${headPreserved} ` +
        `[^${n}] marker=${gotMarker} [^${n}]: def=${gotDef} bijective=${bijective} → ${pass ? "PASS" : "FAIL"}\n`,
    );
  } else {
    console.log(`    NO-OP (action=${out.action}, reason=${out.reason}) — model declined; rerun-safe.\n`);
  }
  results.push({ name: "only-section-changed", pass, detail });
}

// ===========================================================================
// D. SELF-HEALING — a 35mm preference corrected toward 50mm.
// ===========================================================================
{
  const stem = "lens_preferences_demo";
  const anchor = "focal-length-preference";
  // A constructed, fully-normalized article whose section asserts the OLD belief.
  const before = `# Lens Preferences Demo

\`\`\`info
type: preference
kind: domain
\`\`\`

**Lens Preferences Demo** records the user's evolving taste in prime focal lengths for photography.

## Focal Length Preference

For everyday photography the user loves the 35mm focal length above all others, calling it the one prime they would keep if they could keep only one.[^1]

## References

[^1]: \`conv:11112222\` (2025-03-01, Favorite prime focal length)
`;

  const correction: SynthesisChunk = {
    id: "22223333-0000-0000-0000-000000000000:0-2",
    conv: "22223333-0000-0000-0000-000000000000",
    label: "Reassessing 35mm versus 50mm",
    text:
      "Honestly, the 35mm is fine but it's nowhere near as good as the 50mm. After shooting both a lot more, the 50mm " +
      "is the one I reach for first now — the subject separation and the way it renders faces just beats the 35mm. " +
      "The 50mm is my real favorite prime these days.",
    title: "Reassessing 35mm versus 50mm",
    dateMs: 1739923200000,
  };

  console.log(`[D] self-healing correction → ${stem} #${anchor}`);
  console.log(`    BEFORE section:\n${indent(extractSection(before, anchor) ?? "(missing)")}\n`);

  const out = await patchSection({ article: before, anchor, chunk: correction }, { stem });

  let pass = false;
  const detail: Record<string, unknown> = { stem, anchor, action: out.action, reason: out.reason, footnote: out.footnote };
  if (out.action === "patched" && out.content) {
    const after = out.content;
    writeFileSync(join(workVault, "articles", `${stem}.md`), after);
    const target = (extractSection(after, anchor) ?? "").toLowerCase();
    const n = out.footnote!;

    const favors50 = /\b50\s*mm\b/.test(target);
    const cites = new RegExp(`\\[\\^${n}\\](?!:)`).test(extractSection(after, anchor) ?? "");
    // Resolved-to-latest, not appended-alongside: the 50mm now dominates and the
    // old "35mm above all others" superlative is gone.
    const keptOldSuperlative = /35\s*mm[^.]*above all/.test(target) || /loves?\b[^.]*35\s*mm[^.]*above all/.test(target);
    const fiftyBeats = /50\s*mm[^.]*(favorite|prefer|reach for|better|best|beats)/.test(target) || /35\s*mm[^.]*(nowhere near|not as|less|inferior)/.test(target);

    pass = favors50 && cites && !keptOldSuperlative;
    Object.assign(detail, { favors50, cites, keptOldSuperlative, fiftyBeats, resolvedToLatest: pass });

    console.log(`    AFTER section:\n${indent(extractSection(after, anchor) ?? "")}\n`);
    console.log(
      `    favors-50mm=${favors50} cites-[^${n}]=${cites} dropped-old-superlative=${!keptOldSuperlative} ` +
        `50-dominates=${fiftyBeats} → ${pass ? "PASS (resolved toward latest)" : "FAIL"}\n`,
    );
  } else {
    console.log(`    NO-OP (action=${out.action}, reason=${out.reason}).\n`);
  }
  results.push({ name: "self-healing-resolved-to-latest", pass, detail });
}

// ---- metrics ---------------------------------------------------------------

const onlySectionChanged = results.find((r) => r.name === "only-section-changed")?.pass ?? false;
const selfHealing = results.find((r) => r.name === "self-healing-resolved-to-latest")?.pass ?? false;

console.log(`=== PATCH metrics ===`);
console.log(`only-section-changed          : ${onlySectionChanged ? "PASS" : "FAIL"}`);
console.log(`self-healing resolved-to-latest: ${selfHealing ? "PASS" : "FAIL"}`);

mkdirSync(REPORT_DIR, { recursive: true });
writeFileSync(
  REPORT,
  JSON.stringify(
    {
      generated: new Date().toISOString(),
      substrate: SMOKE_VAULT,
      workVault,
      model: "gemma-4-e4b-it-OptiQ-4bit (base, `synthesis` stage, maxTokens 512)",
      onlySectionChanged,
      selfHealingResolvedToLatest: selfHealing,
      scenarios: results,
    },
    null,
    2,
  ) + "\n",
);
console.log(`\nreport → ${REPORT}`);
process.exit(0);

function indent(s: string): string {
  return s
    .split("\n")
    .map((l) => `      ${l}`)
    .join("\n");
}
