#!/usr/bin/env bun
// The paired fill A/B (K3d) — THE gate for the echo tier (PLAN K3).
//
//   bun scripts/fill.ts ab --sessions <file.jsonl|dir> \
//     --url-a http://127.0.0.1:8080 --url-b http://127.0.0.1:8081 \
//     [--label-a off] [--label-b echo] [--reps 1] [--max-turns 0] \
//     [--model <id>] [--max-tokens 512] [--out reports/fill-ab.jsonl] [--json <out.json>]
//
//   bun scripts/fill.ts ab --showcase fixtures/showcase-silicon-exchange.txt \
//     --url-a … --url-b … [--reps 3] [--weight-bytes <n>] [--bandwidth-gbps 400]
//
// ARMS. Fill is a PROCESS-WIDE lever (MLX_BUN_FILL), so the two arms are two
// servers: A started without it, B with `MLX_BUN_FILL=echo`. `--fill-header
// k=v` also rides on B's requests for a future build that honors a per-request
// toggle; today's server ignores unknown headers, so it is inert, not a lie.
//
// PAIRING. Arms interleave turn by turn (A, B, A, B …) so load drift and
// thermal state land on both. The verdict pairs on (session, turn, rep):
// task-output agreement must not drop within CI AND median wall clock must
// strictly improve (src/spec/dspark/ab-stats.ts + ./metrics.ts). Token
// identity is NOT the bar — that is the strict tier's gate
// (tests/parity/fill-strict.test.ts).
//
// GPU run — Josh's shell. All the math is model-free and unit-tested
// (tests/research/fill-echo-replay.test.ts).
import { appendFileSync, mkdirSync, readFileSync, writeFileSync } from "node:fs";
import { dirname } from "node:path";
import { arg, headersFor, loadSessions, num } from "./args";
import {
  armRates, bandwidthCheck, fillVerdict, renderBandwidth, renderFillReport,
  type TurnRecord,
} from "./metrics";
import { interleavedAb, showcaseSession, type LoadedSession } from "./runner";

const SESSIONS = arg("sessions");
const SHOWCASE = arg("showcase");
const URL_A = arg("url-a", arg("server-url", "http://127.0.0.1:8080"))!;
const URL_B = arg("url-b");
if ((!SESSIONS && !SHOWCASE) || !URL_B) {
  console.error(
    "usage: bun scripts/fill.ts ab (--sessions <file|dir> | --showcase <prompt.txt>) \\\n" +
    "         --url-a <off-arm> --url-b <fill-arm> [--label-a off] [--label-b echo]\n" +
    "         [--reps 1] [--max-turns 0] [--model <id>] [--max-tokens 512]\n" +
    "         [--fill-header k=v] [--out <file.jsonl>] [--json <out.json>]\n" +
    "         [--weight-bytes <n>] [--bandwidth-gbps 400]",
  );
  process.exit(2);
}
const LABEL_A = arg("label-a", "fill-off")!;
const LABEL_B = arg("label-b", SHOWCASE ? "fill-on" : "fill-echo")!;
const REPS = Math.max(1, num("reps", SHOWCASE ? 3 : 1));
const MODEL = arg("model");
const MAX_TOKENS = num("max-tokens", 512);
const MAX_TURNS = num("max-turns", 0);
const OUT = arg("out");
const JSON_OUT = arg("json");
const WEIGHT_BYTES = num("weight-bytes", 0);
const BANDWIDTH = num("bandwidth-gbps", 0);

if (OUT) mkdirSync(dirname(OUT), { recursive: true });

const sessions: LoadedSession[] = SHOWCASE
  ? [showcaseSession(SHOWCASE.split("/").pop()!, readFileSync(SHOWCASE, "utf8"))]
  : loadSessions(SESSIONS!);

const armA = { label: LABEL_A, url: URL_A };
const armB = { label: LABEL_B, url: URL_B, headers: headersFor(["fill-header"]) };

const turns = sessions.reduce(
  (n, s) => n + (MAX_TURNS > 0 ? Math.min(MAX_TURNS, s.turns.length) : s.turns.length), 0);
console.log(
  `paired A/B: ${turns} turn(s) × ${REPS} rep(s), interleaved\n` +
  `  A "${LABEL_A}" ${URL_A}\n  B "${LABEL_B}" ${URL_B}` +
  (Object.keys(armB.headers).length ? ` headers ${JSON.stringify(armB.headers)}` : ""),
);

const write = (r: TurnRecord) => { if (OUT) appendFileSync(OUT, `${JSON.stringify(r)}\n`); };
const { a, b } = await interleavedAb(sessions, armA, armB, REPS, {
  ...(MODEL ? { model: MODEL } : {}),
  maxTokens: MAX_TOKENS,
  temperature: 0,
  maxTurns: MAX_TURNS,
  onTurn: (r) => {
    write(r);
    console.log(
      `  ${r.arm.padEnd(10)} ${r.session}#${r.turn}r${r.rep} ${r.wallMs.toFixed(0)}ms ` +
      `${r.completionTokens} tok fill ${r.fill?.injected ?? 0}` +
      (r.error ? ` ERROR ${r.error}` : ""),
    );
  },
});

const verdict = fillVerdict(a, b, { labelA: LABEL_A, labelB: LABEL_B });
console.log("");
console.log(renderFillReport(LABEL_A, LABEL_B, verdict));

if (SHOWCASE) {
  const rb = armRates(b);
  console.log("");
  console.log("  showcase:");
  console.log(`  time to first tool call: A ${fmt(medianOf(a, (r) => r.toolCallMs))} ms · ` +
    `B ${fmt(medianOf(b, (r) => r.toolCallMs))} ms`);
  console.log(`  time to first token:     A ${fmt(medianOf(a, (r) => r.ttftMs))} ms · ` +
    `B ${fmt(medianOf(b, (r) => r.ttftMs))} ms`);
  if (WEIGHT_BYTES > 0 && BANDWIDTH > 0) {
    console.log("");
    console.log("  bandwidth-ceiling check (the skeptic's own napkin):");
    console.log(renderBandwidth(bandwidthCheck(WEIGHT_BYTES, BANDWIDTH, rb)));
  } else {
    console.log("  (pass --weight-bytes and --bandwidth-gbps for the ceiling check)");
  }
}

if (JSON_OUT) {
  writeFileSync(JSON_OUT, `${JSON.stringify({ verdict, a, b }, null, 2)}\n`);
  console.log(`\nwrote ${JSON_OUT}`);
}
if (OUT) console.log(`wrote ${a.length + b.length} rows to ${OUT}`);
process.exit(verdict.pass ? 0 : 1);

function medianOf(rs: TurnRecord[], f: (r: TurnRecord) => number | null): number | null {
  const xs = rs.map(f).filter((x): x is number => x !== null).sort((p, q) => p - q);
  if (!xs.length) return null;
  const mid = xs.length >> 1;
  return xs.length % 2 ? xs[mid]! : (xs[mid - 1]! + xs[mid]!) / 2;
}
function fmt(x: number | null): string {
  return x === null ? "n/a" : x.toFixed(0);
}
