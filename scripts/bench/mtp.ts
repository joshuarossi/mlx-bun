import { strict as assert } from "node:assert";

export interface MtpVariant { id: string; depth: number; env?: Record<string, string> }
export interface MtpPlan {
  target: string;
  draft: string;
  artifactRevision: string;
  prompts: string[];
  variants: MtpVariant[];
  maxTokens: number;
  repetitions: number;
  warmupTokens: number;
}
export function parseMtpPlan(value: unknown): MtpPlan {
  const p = value as MtpPlan;
  assert(p && typeof p === "object", "expected a plan object");
  for (const key of ["target", "draft", "artifactRevision"] as const)
    assert(typeof p[key] === "string" && p[key].length, `${key} is required`);
  for (const key of ["maxTokens", "repetitions", "warmupTokens"] as const)
    assert(Number.isSafeInteger(p[key]) && p[key] > 0, `${key} must be a positive integer`);
  assert(p.repetitions >= 2 && p.repetitions % 2 === 0, "use an even repetition count >= 2 for reversed-order pairs");
  assert(Array.isArray(p.prompts) && p.prompts.length && p.prompts.every(x => typeof x === "string" && x.length), "prompts must be nonempty strings");
  assert(Array.isArray(p.variants) && p.variants.length >= 2, "provide a baseline and at least one candidate");
  const ids = new Set<string>();
  for (const v of p.variants) {
    assert(/^[a-z0-9_-]+$/.test(v.id) && !ids.has(v.id), "variant IDs must be unique safe names"); ids.add(v.id);
    assert(Number.isSafeInteger(v.depth) && v.depth >= 1 && v.depth < p.maxTokens, "depth must be >= 1 and < maxTokens");
    for (const [k, val] of Object.entries(v.env ?? {})) {
      assert(k.startsWith("MLX_BUN_") && typeof val === "string", "variant overrides must be MLX_BUN_* strings");
      assert(!["MLX_BUN_LIBMLXC", "MLX_BUN_SPEC_PHASE_TIMING", "MLX_BUN_SPEC_LAYER_PROFILE", "MLX_BUN_SPEC_OP_INVENTORY"].includes(k), `reserved override ${k}`);
    }
  }
  return p;
}

export interface MtpSample {
  variant: string; mode: "throughput" | "diagnostic"; repetition: number; prompt: number;
  tokens: number[]; promptTokens: number; requestMs: number; prefillMs: number; decodeMs: number;
  steps: { ms: number; emitted: number }[];
  spec: { drafted: number; accepted: number; rounds?: number; acceptanceLengths?: number[];
    draftedByPos?: number[]; acceptedByPos?: number[]; phaseMs?: { draft: number; verify: number; sample: number; commit: number; rounds: number } };
  peakBytes: number;
}

/** Ratio of sums, never the average of per-step rates. Accepted excludes the
 * correction/bonus token; emitted is counted at actual output delivery. */
export function mtpMetrics(samples: readonly MtpSample[]) {
  assert(samples.length, "no samples");
  const mode = samples[0]!.mode;
  assert(samples.every(s => s.mode === mode), "never combine diagnostic and throughput timings");
  const sum = (f: (s: MtpSample) => number) => samples.reduce((n, s) => n + f(s), 0);
  const rounds = sum(s => s.steps.length), stepMs = sum(s => s.steps.reduce((n, x) => n + x.ms, 0));
  const emitted = sum(s => s.steps.reduce((n, x) => n + x.emitted, 0));
  const accepted = sum(s => s.spec.accepted), drafted = sum(s => s.spec.drafted);
  assert(rounds > 0 && stepMs > 0, "no timed steps");
  for (const s of samples) {
    assert(s.steps.every(x => Number.isFinite(x.ms) && x.ms >= 0 && Number.isSafeInteger(x.emitted) && x.emitted >= 0), "invalid step");
    assert(s.spec.rounds === s.steps.length, "round counter differs from timed advances");
    assert(s.spec.accepted >= 0 && s.spec.accepted <= s.spec.drafted, "invalid acceptance counters");
  }
  const phase = mode === "diagnostic" ? Object.fromEntries((["draft", "verify", "sample", "commit"] as const).map(k => [k,
    sum(s => { assert(s.spec.phaseMs, "diagnostic phases missing"); return s.spec.phaseMs[k]; }) / rounds])) : null;
  return { mode, rounds, stepMs, accepted, drafted, emitted,
    acceptedDraftsPerRound: accepted / rounds, emittedPerRound: emitted / rounds,
    acceptanceRate: drafted ? accepted / drafted : 0,
    acceptedDraftsPerSecond: accepted * 1000 / stepMs, emittedPerSecond: emitted * 1000 / stepMs,
    requestTokensPerSecond: sum(s => s.tokens.length) * 1000 / sum(s => s.requestMs),
    meanStepMs: stepMs / rounds, phaseMsPerRound: phase,
    peakBytes: Math.max(...samples.map(s => s.peakBytes)) };
}

export function pairedMtpComparison(baseline: readonly MtpSample[], candidate: readonly MtpSample[]) {
  assert(baseline.length === candidate.length && baseline.length > 0, "incomplete pair");
  const ratios: number[] = [];
  let identicalTokens = true;
  for (const a of baseline) {
    const matches = candidate.filter(b => b.prompt === a.prompt && b.repetition === a.repetition && b.mode === a.mode);
    assert(matches.length === 1, "missing or duplicate paired sample");
    const b = matches[0]!;
    assert(a.promptTokens === b.promptTokens, "paired prompt token counts differ");
    identicalTokens &&= JSON.stringify(a.tokens) === JSON.stringify(b.tokens);
    ratios.push(mtpMetrics([b]).emittedPerSecond / mtpMetrics([a]).emittedPerSecond);
  }
  return { identicalTokens, pairedSpeedups: ratios, minSpeedup: Math.min(...ratios),
    geometricMeanSpeedup: Math.exp(ratios.reduce((n, r) => n + Math.log(r), 0) / ratios.length),
    // Screening criterion only. A kernel still needs its full numerical/state gates.
    screenPass: identicalTokens && ratios.every(r => r > 1) };
}
