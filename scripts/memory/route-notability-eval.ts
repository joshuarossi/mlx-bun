// ROUTE acceptance (b): the CREATE gate on goldens/notability.json.
//
// Single model load. For each gold subject we put its evidence (the curated
// `reason`) to the subject-engagement binary, then run the CREATE gate at
// routedChunks=1 — so a single-mention decision rides entirely on the model's
// "is this a genuine subject?" call. Per Lucien's policy there is NO ownership
// gate and nothing is dropped: a non-subject single mention is CAPTURED (kept in
// its chunk, still searchable). The gold's `notable` items should CREATE; the
// `trivia` items should CAPTURE. Target ≥18/20.
//
// This is NOT a bucket-gold F1. It grades the gate's judgment against a small
// hand-curated oracle (the notability seed), per the methodology: the LoRA
// decision keys off judge/gold quality like this, never a topic-bin F1.
//
//   bun scripts/memory/route-notability-eval.ts

import { readFileSync } from "node:fs";
import { join } from "node:path";

import { createGate, engagesAsSubject } from "../../src/memory/route";

interface GoldItem {
  name: string;
  reason: string;
  signals: { owned: boolean; decided: boolean; recurring: boolean; opinion: boolean };
}
interface Notability {
  notable: GoldItem[];
  trivia: GoldItem[];
}

const gold = JSON.parse(
  readFileSync(join(import.meta.dir, "..", "..", "goldens", "notability.json"), "utf8"),
) as Notability;

async function decide(item: GoldItem): Promise<"create" | "capture"> {
  // The reason IS the subject evidence for this name-only gold.
  const subject = await engagesAsSubject(item.name, `${item.name}: ${item.reason}`);
  return createGate({ routedChunks: 1, subjectEngagement: subject });
}

let correct = 0;
const rows: string[] = [];

for (const item of gold.notable) {
  const action = await decide(item);
  const ok = action === "create";
  if (ok) correct++;
  rows.push(`  ${ok ? "OK " : "XX "} notable  ${action.padEnd(7)} ${item.name}`);
}
for (const item of gold.trivia) {
  const action = await decide(item);
  const ok = action === "capture";
  if (ok) correct++;
  rows.push(`  ${ok ? "OK " : "XX "} trivia   ${action.padEnd(7)} ${item.name}`);
}

const total = gold.notable.length + gold.trivia.length;
console.log(rows.join("\n"));
console.log(`\nnotabilityScore: ${correct}/${total} (target >=18)`);
console.log(JSON.stringify({ notabilityScore: correct, total }));
