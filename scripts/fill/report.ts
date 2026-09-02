#!/usr/bin/env bun
// Aggregate replay/AB JSONL into the summary tables (K3d).
//
//   bun scripts/fill.ts report <runs.jsonl> [<more.jsonl> …] [--by-tool] [--json <out>]
//
// Reads the TurnRecord rows `fill replay` / `fill ab` write, groups by arm,
// and prints fill fraction, the apparent multiplier, and (with --by-tool) the
// per-tool split. Pure aggregation — no server, no model, so this runs
// anywhere the JSONL lands.
import { readFileSync, writeFileSync } from "node:fs";
import { arg, flag } from "./args";
import {
  apparentMultiplier, armRates, byTool, fillVerdict, renderArm, renderFillReport,
  type TurnRecord,
} from "./metrics";

/** Positional args only: a flag consumes the token after it (`--json <out>`),
 *  everything else is an input file. */
const VALUE_FLAGS = new Set(["--json"]);
const files: string[] = [];
for (let i = 2; i < process.argv.length; i++) {
  const a = process.argv[i]!;
  if (a.startsWith("--")) {
    if (VALUE_FLAGS.has(a)) i++;
    continue;
  }
  files.push(a);
}
if (files.length === 0) {
  console.error("usage: bun scripts/fill.ts report <runs.jsonl> [...] [--by-tool] [--json <out>]");
  process.exit(2);
}

const rows: TurnRecord[] = [];
for (const f of files) {
  for (const line of readFileSync(f, "utf8").split("\n")) {
    const s = line.trim();
    if (!s) continue;
    try { rows.push(JSON.parse(s) as TurnRecord); } catch { /* skip corrupt row */ }
  }
}
if (rows.length === 0) {
  console.error("no rows parsed");
  process.exit(1);
}

const arms = new Map<string, TurnRecord[]>();
for (const r of rows) {
  const list = arms.get(r.arm);
  if (list) list.push(r);
  else arms.set(r.arm, [r]);
}

console.log(`${rows.length} rows · ${arms.size} arm(s) · ` +
  `${new Set(rows.map((r) => r.session)).size} session(s)`);
console.log("");
const summary: Record<string, unknown> = {};
for (const [arm, rs] of arms) {
  const rates = armRates(rs);
  summary[arm] = rates;
  console.log(renderArm(arm, rates));
  const errors = rs.filter((r) => r.error).length;
  if (errors) console.log(`  ${"".padEnd(22)} ${errors} errored turn(s)`);
  if (flag("by-tool")) {
    for (const [tool, tr] of byTool(rs)) {
      console.log(
        `    ${tool.padEnd(20)} ${tr.turns} turns · fill ${(tr.fillFrac * 100).toFixed(1)}% ` +
        `· ×${apparentMultiplier(tr.fillFrac).toFixed(2)} apparent · ` +
        `agreement ${(tr.taskAgreement * 100).toFixed(1)}%`,
      );
    }
  }
  console.log("");
}

// Two arms in the input (an interleaved `ab` file, or two SERIAL `replay`
// files — one server restarted between arms when two 27B servers do not fit
// the wired ceiling): print the same paired verdict `ab` prints, pairing on
// (session, turn, rep). Order: the arm named first on the command line is A.
if (arms.size === 2) {
  const [ea, eb] = [...arms] as [[string, TurnRecord[]], [string, TurnRecord[]]];
  const v = fillVerdict(ea[1], eb[1], { labelA: ea[0], labelB: eb[0] });
  summary.verdict = v;
  console.log(renderFillReport(ea[0], eb[0], v));
  console.log("");
}

const out = arg("json");
if (out) {
  writeFileSync(out, `${JSON.stringify(summary, null, 2)}\n`);
  console.log(`wrote ${out}`);
}
