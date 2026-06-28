// P9-T4 — migration parity / coverage eval.
//
// Asserts the migration invariant: 0 engaged-with things LOST. Every notable
// entity in the hand-curated gold (`goldens/dreaming-entities-gold.json`
// notableEntities) must resolve — by name or alias — to an article in the new
// vault, even though article count drops vs the old 385-bin taxonomy.
//
// Read-path only: reindex (file I/O) + alias resolution. No model, no embedder
// — the read-path tripwire (`getEmbedCounter`) is asserted == 0.
//
// On the 10-conv SMOKE vault this is PARTIAL coverage (most gold entities were
// never ingested); the FULL bootstrap (P6-T5, a USER action) is where the
// 0-lost invariant is actually asserted. This harness PROVES the measurement.
//
//   bun scripts/memory/eval-coverage.ts [--vault <dir>]

import { readFileSync } from "node:fs";
import { join } from "node:path";

import { getEmbedCounter, resetEmbedCounter } from "../../src/embed";
import { coverageReport, type EntitiesGold } from "../../src/memory/coverage";
import { MemoryStore } from "../../src/memory/db";
import { reindex } from "../../src/memory/reindex";

const REPO = join(import.meta.dir, "..", "..");
const GOLD_FILE = join(REPO, "goldens", "dreaming-entities-gold.json");
const SMOKE_VAULT = join(process.env.HOME ?? "", ".mlx-bun", "wiki-smoke");

function vaultArg(): string {
  const i = process.argv.indexOf("--vault");
  if (i >= 0 && process.argv[i + 1]) return process.argv[i + 1]!;
  return process.env.MLX_BUN_WIKI ?? SMOKE_VAULT;
}

const root = vaultArg();
const gold = JSON.parse(readFileSync(GOLD_FILE, "utf8")) as EntitiesGold;

resetEmbedCounter();
const store = new MemoryStore(":memory:");
const idx = reindex(store, root);
const report = coverageReport(store, gold.notableEntities, root);
const embedCalls = getEmbedCounter();

console.log(`vault: ${root}`);
console.log(`articles indexed: ${idx.articles}  aliases: ${idx.aliases}`);
console.log(
  `\ncoverage: ${report.coveredCount}/${report.goldNotable} gold notable entities ` +
    `present (${report.stubCount} stub), ${report.missingCount} missing\n`,
);

for (const r of report.covered) {
  const tag = r.stub ? "STUB" : "OK  ";
  const via = r.matchedVia === r.name ? "" : `  (via "${r.matchedVia}")`;
  console.log(`  ${tag}  ${r.name}  ->  ${r.stem}${via}`);
}
for (const r of report.missing) {
  console.log(`  MISS  ${r.name}  [${r.domain}]`);
}

if (embedCalls !== 0) {
  throw new Error(`read-path tripwire: expected 0 embed calls, got ${embedCalls}`);
}

console.log(
  `\nNOTE: 10-conv SMOKE → partial by construction. 0-LOST is asserted after ` +
    `the FULL bootstrap (P6-T5, user action).`,
);
console.log(
  JSON.stringify({
    goldNotable: report.goldNotable,
    coveredInSmoke: report.coveredCount,
    missingInSmoke: report.missingCount,
    stubInSmoke: report.stubCount,
    embedCalls,
  }),
);
