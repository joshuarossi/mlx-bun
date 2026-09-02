// Pure metrics + verdict math for the fill A/B harness (K3d). No I/O, no
// server, no model — so the runner's conclusions are unit-testable
// (tests/research/fill-echo-replay.test.ts).
//
// TWO RATES, and the difference between them IS the feature:
//   decoded  = tokens the weights actually produced / wall second
//   emitted  = tokens the client received / wall second
// Injected tokens are billed as generated (they are real output) but never
// touched the weights, so emitted > decoded exactly by the fill fraction:
//   apparent = decoded / (1 − fillFrac)  ≡ emitted
// The identity is not a claim; it is arithmetic. What makes it interesting is
// the BANDWIDTH CEILING: a pure autoregressive decode reads every weight byte
// once per token, so decoded tok/s can never exceed memoryBandwidth ÷
// weightBytes. An emitted rate above that ceiling is proof — on the skeptic's
// own napkin — that those tokens never went through the weights.
import {
  pairedVerdict,
  renderReport,
  summarizeArm,
  type AbPromptResult,
  type AbVerdict,
} from "../../src/spec/dspark/ab-stats";

/** Telemetry the server reports as `usage.fill` (src/fill/fill-session.ts). */
export interface FillUsage {
  events: number;
  injected: number;
  strict: number;
  echo: number;
  spanLens: number[];
  wastedSamples: number;
  parseFallback: number;
  indexTruncated: number;
  decodeSteps: number;
  verifyEvents: number;
  verifyAccepted: number;
  verifyRejected: number;
  verifyUnsupported: number;
  checkpointMs: number;
  branchStops: number;
}

/** One replayed turn on one arm. This is the JSONL row `fill replay` writes
 *  and `fill report` aggregates. */
export interface TurnRecord {
  session: string;
  /** Assistant-message index within the session (the pairing unit). */
  turn: number;
  arm: string;
  /** Repetition index for interleaved runs. */
  rep: number;
  wallMs: number;
  /** Time to the first streamed byte (TTFT). */
  ttftMs: number | null;
  /** Time until the first tool-call delta appeared. */
  toolCallMs: number | null;
  promptTokens: number;
  completionTokens: number;
  fill: FillUsage | null;
  /** Recorded tool name for this turn (per-tool splits). */
  toolName: string | null;
  /** Did the replayed output make the same call / say the same thing? */
  taskMatch: boolean;
  /** Character index where the served text first differs from the recording. */
  firstDivergence: number | null;
  error?: string;
}

export const injectedOf = (r: TurnRecord): number => r.fill?.injected ?? 0;

/** Injected ÷ emitted for one turn (0 when nothing was filled). */
export function fillFraction(r: TurnRecord): number {
  return r.completionTokens > 0 ? injectedOf(r) / r.completionTokens : 0;
}

/** 1 / (1 − fillFrac) — how much faster the stream LOOKS than the weights ran. */
export function apparentMultiplier(fillFrac: number): number {
  return fillFrac >= 1 ? Infinity : 1 / (1 - fillFrac);
}

export interface ArmRates {
  turns: number;
  wallMs: number;
  completionTokens: number;
  injected: number;
  /** completionTokens − injected: what the weights produced. */
  decodedTokens: number;
  fillFrac: number;
  emittedTps: number;
  decodedTps: number;
  /** decodedTps × 1/(1−fillFrac); equals emittedTps by construction. */
  apparentTps: number;
  medianWallMs: number;
  taskAgreement: number;
  /** Verify-policy economics (echo tier); zero on a strict-only run. */
  verifyAccepted: number;
  verifyRejected: number;
  checkpointMs: number;
  branchStops: number;
}

export function median(xs: readonly number[]): number {
  if (xs.length === 0) return 0;
  const s = [...xs].sort((a, b) => a - b);
  const mid = s.length >> 1;
  return s.length % 2 ? s[mid]! : (s[mid - 1]! + s[mid]!) / 2;
}

export function armRates(records: readonly TurnRecord[]): ArmRates {
  const ok = records.filter((r) => !r.error);
  const sum = (f: (r: TurnRecord) => number) => ok.reduce((n, r) => n + f(r), 0);
  const wallMs = sum((r) => r.wallMs);
  const completionTokens = sum((r) => r.completionTokens);
  const injected = sum(injectedOf);
  const decodedTokens = completionTokens - injected;
  const fillFrac = completionTokens > 0 ? injected / completionTokens : 0;
  const secs = wallMs / 1000;
  const decodedTps = secs > 0 ? decodedTokens / secs : 0;
  return {
    turns: ok.length,
    wallMs,
    completionTokens,
    injected,
    decodedTokens,
    fillFrac,
    emittedTps: secs > 0 ? completionTokens / secs : 0,
    decodedTps,
    apparentTps: decodedTps * apparentMultiplier(fillFrac),
    medianWallMs: median(ok.map((r) => r.wallMs)),
    taskAgreement: ok.length ? ok.filter((r) => r.taskMatch).length / ok.length : 0,
    verifyAccepted: sum((r) => r.fill?.verifyAccepted ?? 0),
    verifyRejected: sum((r) => r.fill?.verifyRejected ?? 0),
    checkpointMs: sum((r) => r.fill?.checkpointMs ?? 0),
    branchStops: sum((r) => r.fill?.branchStops ?? 0),
  };
}

/** Map a fill run onto the shared A/B aggregates (src/spec/dspark/ab-stats.ts)
 *  so both programs report through one renderer. The mapping is exact, not
 *  metaphorical:
 *    drafted     → tokens PROPOSED by the fill table (injected + rejected)
 *    accepted    → tokens that survived (injected)
 *    targetCalls → model forwards (sampled steps + one per fill event)
 *  so `acceptance` is fill acceptance and `tau` is tokens per forward — the
 *  quantity the apparent multiplier is built on. */
export function toAbResults(records: readonly TurnRecord[]): AbPromptResult[] {
  return records.filter((r) => !r.error).map((r) => {
    const injected = injectedOf(r);
    const rejected = r.fill?.verifyRejected ?? 0;
    const events = r.fill?.events ?? 0;
    const sampled = r.fill?.decodeSteps ?? Math.max(0, r.completionTokens - injected);
    return {
      prompt: `${r.session}#${r.turn}`,
      generatedTokens: r.completionTokens,
      drafted: injected + rejected,
      accepted: injected,
      targetCalls: sampled + events,
      wallMs: r.wallMs,
      draftedByPos: [],
      acceptedByPos: [],
    };
  });
}

export interface FillVerdict {
  a: ArmRates;
  b: ArmRates;
  /** Paired turns compared (present on both arms). */
  paired: number;
  /** B agreed where A did not / A agreed where B did not (McNemar counts). */
  bOnlyAgree: number;
  aOnlyAgree: number;
  /** Agreement delta B − A, with its one-sided 95% bound. */
  agreementDelta: number;
  agreementLowerBound: number;
  /** Median of per-turn wall-clock ratios B/A (<1 = B faster). */
  medianWallRatio: number;
  agreementHolds: boolean;
  fasterOnMedian: boolean;
  pass: boolean;
  verdict: string;
  /** The shared drafter-style aggregate, for the token economics table. */
  tokens: AbVerdict;
}

/** THE echo-tier gate (PLAN K3): task-output agreement must NOT drop (within
 *  CI) AND median wall clock must strictly improve. Token identity is
 *  deliberately not the bar — sampling never guaranteed it, and an agent loop
 *  cares whether the same call was made.
 *
 *  Agreement uses McNemar's paired counts with a normal approximation: with
 *  `b` turns where only A agreed and `c` where only B did, the delta is
 *  (c − b)/n and its standard error sqrt(b + c)/n. "Does not drop" = the
 *  one-sided 95% lower bound is ≥ 0, so a tie or a small adverse swing inside
 *  the noise passes, and a real regression does not.
 *
 *  STRICT-tier runs use a different bar entirely (token identity at
 *  temperature 0) — that is `tests/parity/fill-strict.test.ts`, not this. */
export function fillVerdict(
  aRecords: readonly TurnRecord[],
  bRecords: readonly TurnRecord[],
  opts: { labelA?: string; labelB?: string } = {},
): FillVerdict {
  const key = (r: TurnRecord) => `${r.session}#${r.turn}#${r.rep}`;
  const bByKey = new Map(bRecords.map((r) => [key(r), r]));
  const pairs: [TurnRecord, TurnRecord][] = [];
  for (const ra of aRecords) {
    const rb = bByKey.get(key(ra));
    if (rb && !ra.error && !rb.error) pairs.push([ra, rb]);
  }
  const a = armRates(pairs.map(([x]) => x));
  const b = armRates(pairs.map(([, y]) => y));

  let bOnly = 0;
  let aOnly = 0;
  const ratios: number[] = [];
  for (const [ra, rb] of pairs) {
    if (rb.taskMatch && !ra.taskMatch) bOnly++;
    if (ra.taskMatch && !rb.taskMatch) aOnly++;
    if (ra.wallMs > 0) ratios.push(rb.wallMs / ra.wallMs);
  }
  const n = pairs.length;
  const agreementDelta = n ? (bOnly - aOnly) / n : 0;
  const se = n ? Math.sqrt(bOnly + aOnly) / n : 0;
  const agreementLowerBound = agreementDelta - 1.645 * se; // one-sided 95%
  const medianWallRatio = median(ratios);
  const agreementHolds = n === 0 ? false : agreementLowerBound >= 0;
  const fasterOnMedian = n > 0 && medianWallRatio < 1;
  const pass = agreementHolds && fasterOnMedian;

  const pct = (x: number) => `${(x * 100).toFixed(1)}%`;
  const verdict = n === 0
    ? "FAIL — no paired turns"
    : pass
      ? `PASS — agreement ${pct(a.taskAgreement)} → ${pct(b.taskAgreement)} ` +
        `(delta ${(agreementDelta * 100).toFixed(1)} pts, 95% lower bound ` +
        `${(agreementLowerBound * 100).toFixed(1)}), median wall ×${medianWallRatio.toFixed(3)}`
      : !agreementHolds
        ? `FAIL — task agreement not shown to hold: ${pct(a.taskAgreement)} → ${pct(b.taskAgreement)} ` +
          `(delta ${(agreementDelta * 100).toFixed(1)} pts, 95% lower bound ` +
          `${(agreementLowerBound * 100).toFixed(1)} pts${agreementDelta >= 0 ? " — more paired turns needed" : ""})`
        : `FAIL — agreement held but median wall clock did not improve ` +
          `(×${medianWallRatio.toFixed(3)})`;

  return {
    a, b, paired: n,
    bOnlyAgree: bOnly, aOnlyAgree: aOnly,
    agreementDelta, agreementLowerBound, medianWallRatio,
    agreementHolds, fasterOnMedian, pass, verdict,
    tokens: pairedVerdict(
      toAbResults(pairs.map(([x]) => x)),
      toAbResults(pairs.map(([, y]) => y)),
      { maxDropPts: 100 }, // fill acceptance is not the gate; see the doc above
    ),
  };
}

export interface BandwidthCheck {
  weightBytes: number;
  gbPerSec: number;
  /** Max tokens/s a pure autoregressive decode can reach: one full weight
   *  read per token. */
  ceilingTps: number;
  emittedTps: number;
  decodedTps: number;
  /** True when the stream out-ran what the weights could physically feed. */
  exceedsCeiling: boolean;
}

export function bandwidthCheck(
  weightBytes: number, gbPerSec: number, rates: ArmRates,
): BandwidthCheck {
  const ceilingTps = weightBytes > 0 ? (gbPerSec * 1e9) / weightBytes : Infinity;
  return {
    weightBytes,
    gbPerSec,
    ceilingTps,
    emittedTps: rates.emittedTps,
    decodedTps: rates.decodedTps,
    exceedsCeiling: rates.emittedTps > ceilingTps,
  };
}

const fixed = (x: number, n = 1) => (Number.isFinite(x) ? x.toFixed(n) : "∞");

export function renderArm(label: string, r: ArmRates): string {
  return [
    `  ${label.padEnd(22)} ${fixed(r.emittedTps)} tok/s emitted · ${fixed(r.decodedTps)} decoded ` +
    `(fill ${(r.fillFrac * 100).toFixed(1)}%, ×${fixed(apparentMultiplier(r.fillFrac), 2)} apparent)`,
    `  ${"".padEnd(22)} ${r.completionTokens} tok over ${r.turns} turns · median ` +
    `${fixed(r.medianWallMs, 0)} ms · agreement ${(r.taskAgreement * 100).toFixed(1)}%`,
    ...(r.verifyAccepted + r.verifyRejected > 0
      ? [`  ${"".padEnd(22)} verify ${r.verifyAccepted} accepted / ` +
         `${r.verifyRejected} rejected · ${r.branchStops} branch stops · ` +
         `${fixed(r.checkpointMs, 1)} ms checkpoint`]
      : []),
  ].join("\n");
}

export function renderFillReport(
  labelA: string, labelB: string, v: FillVerdict,
): string {
  return [
    renderArm(`A: ${labelA}`, v.a),
    renderArm(`B: ${labelB}`, v.b),
    `  paired ${v.paired} turns · B-only agreements ${v.bOnlyAgree} · A-only ${v.aOnlyAgree}`,
    "",
    "  token economics (shared A/B aggregate):",
    renderReport(labelA, labelB, v.tokens),
    "",
    `  ${v.verdict}`,
  ].join("\n");
}

export function renderBandwidth(b: BandwidthCheck): string {
  return [
    `  weights ${(b.weightBytes / 2 ** 30).toFixed(2)} GiB · memory bandwidth ${b.gbPerSec} GB/s`,
    `  autoregressive ceiling ${fixed(b.ceilingTps)} tok/s (one full weight read per token)`,
    `  emitted ${fixed(b.emittedTps)} tok/s · decoded ${fixed(b.decodedTps)} tok/s`,
    b.exceedsCeiling
      ? `  EMITTED RATE EXCEEDS THE CEILING — those tokens never touched the weights.`
      : `  emitted rate is under the ceiling; the fill fraction is the whole story.`,
  ].join("\n");
}

/** Per-tool split for `fill report`. */
export function byTool(records: readonly TurnRecord[]): Map<string, ArmRates> {
  const groups = new Map<string, TurnRecord[]>();
  for (const r of records) {
    const k = r.toolName ?? "(text)";
    const list = groups.get(k);
    if (list) list.push(r);
    else groups.set(k, [r]);
  }
  return new Map([...groups].map(([k, rs]) => [k, armRates(rs)]));
}

export { summarizeArm };
