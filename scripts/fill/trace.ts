#!/usr/bin/env bun
// The proposal list (K3): every span the fill mechanism proposed, next to what
// the model's own logits said at each position — written by the engine under
// MLX_BUN_FILL_TRACE=<file.jsonl> (src/generate.ts traceProposal).
//
//   bun scripts/fill.ts trace <fill-trace.jsonl> [--all] [--json <out>]
//
// Prints per-record `origin/policy accepted/len` with proposed → actual text
// (disagreements only unless --all), then agreement by origin/policy and by
// span position — the number that decides whether a span class can be
// ASSERTED (no verify pass) instead of verified.
import { readFileSync, writeFileSync } from "node:fs";
import { arg, flag } from "./args";
import type { FillTraceRecord } from "../../src/fill/fill-session";

const file = process.argv.slice(2).find((a) => !a.startsWith("--"));
if (!file) {
  console.error("usage: bun scripts/fill.ts trace <fill-trace.jsonl> [--all] [--json <out>]");
  process.exit(2);
}
const recs: FillTraceRecord[] = [];
for (const line of readFileSync(file, "utf8").split("\n")) {
  const s = line.trim();
  if (!s) continue;
  try { recs.push(JSON.parse(s) as FillTraceRecord); } catch { /* skip */ }
}
if (!recs.length) { console.error("no records"); process.exit(1); }

const show = (t: string | undefined, ids: number[]) => JSON.stringify(t ?? ids);
const all = flag("all");
console.log(`${recs.length} proposals`);
for (const r of recs) {
  const full = r.firstMismatch === -1;
  if (!all && full) continue;
  console.log(
    `  ${r.origin}/${r.policy} ${r.accepted}/${r.proposedLen} ` +
    `${full ? "AGREE" : `mismatch@${r.firstMismatch}`}  proposed ${show(r.proposedText, r.proposed)} → ` +
    `model ${show(r.actualText, r.actual)}`,
  );
}

type Agg = { n: number; fullAgree: number; proposed: number; agreedPrefix: number };
const by = new Map<string, Agg>();
const bump = (k: string, r: FillTraceRecord) => {
  const a = by.get(k) ?? { n: 0, fullAgree: 0, proposed: 0, agreedPrefix: 0 };
  a.n++; a.proposed += r.proposedLen;
  a.agreedPrefix += r.firstMismatch === -1 ? r.proposedLen : r.firstMismatch;
  if (r.firstMismatch === -1) a.fullAgree++;
  by.set(k, a);
};
for (const r of recs) { bump(`${r.origin}/${r.policy}`, r); bump("all", r); }
console.log("\n  agreement by source (would the model have produced the whole span?):");
for (const [k, a] of [...by].sort()) {
  console.log(
    `    ${k.padEnd(16)} ${String(a.n).padStart(5)} proposals · whole-span ${((a.fullAgree / a.n) * 100).toFixed(1)}% · ` +
    `tokens agreed-prefix ${a.agreedPrefix}/${a.proposed} (${((a.agreedPrefix / a.proposed) * 100).toFixed(1)}%) · ` +
    `mean span ${(a.proposed / a.n).toFixed(1)}`,
  );
}
// Per-position survival: of proposals at least j+1 long, how many agreed through j.
const maxLen = Math.max(...recs.map((r) => r.proposedLen));
const surv: string[] = [];
for (let j = 0; j < Math.min(maxLen, 32); j++) {
  const elig = recs.filter((r) => r.proposedLen > j);
  const ok = elig.filter((r) => r.firstMismatch === -1 || r.firstMismatch > j);
  if (!elig.length) break;
  surv.push(`${j}:${((ok.length / elig.length) * 100).toFixed(0)}%`);
}
console.log(`\n  survival by position (agreed through j / proposals longer than j):\n    ${surv.join(" ")}`);
const out = arg("json");
if (out) { writeFileSync(out, JSON.stringify({ records: recs.length, by: Object.fromEntries(by), survival: surv }, null, 2)); console.log(`wrote ${out}`); }
