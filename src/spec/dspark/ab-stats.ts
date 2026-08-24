// Model-free math for the Phase-1c drafter acceptance A/B
// (docs/design/speculative-decoding.md; runner:
// scripts/dspark.ts ab). THE gate for every drafter-quantization
// experiment: same target, same prompts, temp 0 — drafter A vs drafter B.
//
// Paired design: prompts are the pairing unit, so per-prompt deltas cancel
// prompt difficulty AND machine-load drift between arms (the
// dirty-machine-numbers rule: paired deltas survive memory pressure,
// absolutes don't — final pre/post pairs still belong on a clean machine).

/** One prompt × one drafter arm. */
export interface AbPromptResult {
  prompt: string;
  generatedTokens: number;
  drafted: number;
  accepted: number;
  targetCalls: number;
  wallMs: number;
  draftedByPos: number[];
  acceptedByPos: number[];
}

/** Aggregates over one arm's prompt set. */
export interface AbArmSummary {
  nPrompts: number;
  generatedTokens: number;
  /** accepted / drafted over the whole set (per-token acceptance). */
  acceptance: number;
  /** committed tokens per target forward (τ). */
  tau: number;
  /** generated tokens per wall second over the whole set. */
  tokPerSec: number;
  /** acceptance at each draft position (0..γ-1). */
  acceptanceByPos: number[];
}

export interface AbVerdict {
  a: AbArmSummary;
  b: AbArmSummary;
  /** B − A, absolute points (e.g. -2.1 = B accepts 2.1 points less). */
  acceptanceDeltaPts: number;
  /** B / A wall-clock throughput ratio (>1 = B faster). */
  speedRatio: number;
  /** Prompts where B's per-prompt acceptance ≥ A's − tolerance. */
  pairedAcceptanceHolds: number;
  /** Phase-1d exit criteria: acceptance drop ≤ `maxDropPts` AND
   *  wall-clock strictly improves. */
  pass: boolean;
  verdict: string;
}

export function summarizeArm(results: AbPromptResult[]): AbArmSummary {
  const total = (f: (r: AbPromptResult) => number) => results.reduce((s, r) => s + f(r), 0);
  const generatedTokens = total((r) => r.generatedTokens);
  const drafted = total((r) => r.drafted);
  const accepted = total((r) => r.accepted);
  const targetCalls = total((r) => r.targetCalls);
  const wallMs = total((r) => r.wallMs);

  const gamma = Math.max(0, ...results.map((r) => r.draftedByPos.length));
  const acceptanceByPos: number[] = [];
  for (let i = 0; i < gamma; i++) {
    const d = total((r) => r.draftedByPos[i] ?? 0);
    const a = total((r) => r.acceptedByPos[i] ?? 0);
    acceptanceByPos.push(d > 0 ? a / d : 0);
  }

  return {
    nPrompts: results.length,
    generatedTokens,
    acceptance: drafted > 0 ? accepted / drafted : 0,
    tau: targetCalls > 0 ? generatedTokens / targetCalls : 0,
    tokPerSec: wallMs > 0 ? (generatedTokens / wallMs) * 1000 : 0,
    acceptanceByPos,
  };
}

/** Phase-1d exit: acceptance drop ≤ maxDropPts absolute AND wall-clock
 *  strictly improves (docs/design/speculative-decoding.md 1d). */
export function pairedVerdict(
  aResults: AbPromptResult[],
  bResults: AbPromptResult[],
  opts: { maxDropPts?: number } = {},
): AbVerdict {
  if (aResults.length !== bResults.length)
    throw new Error(`pairedVerdict: arm sizes differ (${aResults.length} vs ${bResults.length})`);
  const maxDropPts = opts.maxDropPts ?? 3;
  const a = summarizeArm(aResults);
  const b = summarizeArm(bResults);

  const acceptanceDeltaPts = (b.acceptance - a.acceptance) * 100;
  const speedRatio = a.tokPerSec > 0 ? b.tokPerSec / a.tokPerSec : 0;

  let pairedAcceptanceHolds = 0;
  for (let i = 0; i < aResults.length; i++) {
    const ra = aResults[i]!;
    const rb = bResults[i]!;
    const accA = ra.drafted > 0 ? ra.accepted / ra.drafted : 0;
    const accB = rb.drafted > 0 ? rb.accepted / rb.drafted : 0;
    if (accB >= accA - maxDropPts / 100) pairedAcceptanceHolds++;
  }

  const acceptanceOk = acceptanceDeltaPts >= -maxDropPts;
  const speedOk = speedRatio > 1;
  const pass = acceptanceOk && speedOk;
  const verdict = pass
    ? `PASS — acceptance ${fmtDelta(acceptanceDeltaPts)} pts (within ${maxDropPts}), wall-clock ×${speedRatio.toFixed(2)}`
    : !acceptanceOk
      ? `FAIL — acceptance dropped ${fmtDelta(acceptanceDeltaPts)} pts (limit ${maxDropPts}); B does not preserve A's acceptance`
      : `FAIL — acceptance held (${fmtDelta(acceptanceDeltaPts)} pts) but wall-clock did not improve (×${speedRatio.toFixed(2)})`;

  return { a, b, acceptanceDeltaPts, speedRatio, pairedAcceptanceHolds, pass, verdict };
}

function fmtDelta(x: number): string {
  return `${x >= 0 ? "+" : ""}${x.toFixed(1)}`;
}

/** Render the two-arm report (pure string — unit-testable, printed by the
 *  runner). */
export function renderReport(labelA: string, labelB: string, v: AbVerdict): string {
  const pct = (x: number) => `${(x * 100).toFixed(1)}%`;
  const row = (label: string, s: AbArmSummary) =>
    `  ${label.padEnd(28)} acceptance ${pct(s.acceptance).padStart(6)}  τ ${s.tau.toFixed(2)}  ` +
    `${s.tokPerSec.toFixed(1)} tok/s  (${s.generatedTokens} tok over ${s.nPrompts} prompts)`;
  const posRow = (label: string, s: AbArmSummary) =>
    `  ${label.padEnd(28)} by-pos [${s.acceptanceByPos.map(pct).join(" ")}]`;
  return [
    row(`A: ${labelA}`, v.a),
    row(`B: ${labelB}`, v.b),
    posRow(`A: ${labelA}`, v.a),
    posRow(`B: ${labelB}`, v.b),
    `  paired: B holds A's acceptance on ${v.pairedAcceptanceHolds}/${v.a.nPrompts} prompts`,
    `  ${v.verdict}`,
  ].join("\n");
}
