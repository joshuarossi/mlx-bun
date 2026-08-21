// KL-divergence drift eval — port of optiq/eval/kl.py, adapted for the
// fused-kernel head-to-head.
//
// KL(ref ‖ cand) per token = Σ_v softmax(ref)·(logsoftmax(ref) − logsoftmax(cand)),
// reported as mean (primary), median, and p95 over N prompts × seq tokens.
// Computation is TEACHER-FORCED: the same fixed prompt is fed to both
// arms and the per-position distributions are compared — the repo's rule
// (free-running greedy "measures chaos"; see teacher-forced-gating).
//
// Two reference modes:
//   * self-flag (DEFAULT, the kernel-drift gate): one model, one weight
//     load; forward each prompt twice with a runtime lever set to its
//     reference value vs its candidate value. Directly measures the drift
//     a perf lever introduces. Fits in RAM trivially (no second model).
//   * two-model (optiq-style absolute quality): a separate reference
//     model (bf16 if it fits, else uniform-4bit). Both resident.
//
// NOTE (M0 scope): this uses the compat forward() path (plain caches), so
// it gates the shared-ops fusions (gelu / norm+add) and the tiled-vs-
// unfused SDPA lever. A serving-path variant (quantized KV + the generated
// class, teacher-forced prefill) is the next step — see eval README.

import { existsSync } from "node:fs";
import { MlxArray } from "../mlx/array";
import { Dtype } from "../mlx/ffi";
import * as ops from "../mlx/ops";
import { Registry } from "../registry";
import { Weights } from "../weights";
import { loadModelConfig, type ModelConfig, type TurboQuantScheme } from "../config";
import { createModel, type RuntimeModel } from "../model/factory";
import { loadTokenizer, type LoadedTokenizer } from "../tokenizer";
import { maybeQuantizeKv } from "../generate";
import {
  configureRuntime,
  runtimeKey,
} from "../runtime-config";

export interface KLResult {
  nPrompts: number;
  seqLen: number;
  meanKl: number;   // mean of per-prompt mean KL — the primary scalar
  medianKl: number; // median over all pooled per-token KLs
  p95Kl: number;    // tail (long-distribution drift)
  elapsedSec: number;
  refLabel: string;
}

/** KL(p ‖ q) per token for logits [1, T, V]; returns a length-T array. */
export function klPerToken(pLogits: MlxArray, qLogits: MlxArray): Float32Array {
  const f32 = (a: MlxArray): { arr: MlxArray; owned: boolean } =>
    a.dtype === Dtype.float32 ? { arr: a, owned: false } : { arr: a.astype(Dtype.float32), owned: true };
  const pp = f32(pLogits);
  const qq = f32(qLogits);
  const p = pp.arr;
  const q = qq.arr;

  const lseP = ops.logsumexpAxis(p, -1, true);   // [1,T,1]
  const lseQ = ops.logsumexpAxis(q, -1, true);
  const logP = ops.sub(p, lseP);                  // [1,T,V]
  const logQ = ops.sub(q, lseQ);
  const pProbs = ops.softmaxAxis(p, -1, true);    // precise softmax
  const diff = ops.sub(logP, logQ);
  const prod = ops.mul(pProbs, diff);
  const kl = ops.sumAxis(prod, -1, false);        // [1,T]
  const out = kl.toFloat32();

  for (const a of [lseP, lseQ, logP, logQ, pProbs, diff, prod, kl]) a.dispose();
  if (pp.owned) p.dispose();
  if (qq.owned) q.dispose();
  return out;
}

const mean = (xs: number[]): number => (xs.length ? xs.reduce((a, b) => a + b, 0) / xs.length : 0);
function percentile(xs: number[], pct: number): number {
  if (!xs.length) return 0;
  const s = [...xs].sort((a, b) => a - b);
  const i = Math.min(s.length - 1, Math.max(0, Math.floor((pct / 100) * s.length)));
  return s[i]!;
}

function aggregate(perPrompt: Float32Array[]): { mean: number; median: number; p95: number } {
  const promptMeans = perPrompt.map((a) => mean(Array.from(a)));
  const pooled: number[] = [];
  for (const a of perPrompt) for (const v of a) pooled.push(v);
  return { mean: mean(promptMeans), median: percentile(pooled, 50), p95: percentile(pooled, 95) };
}

/** A local model dir if `query` is a path, else resolved via the registry. */
export function resolveModelDir(query: string): string {
  if (existsSync(query) && existsSync(`${query}/config.json`)) return query;
  return new Registry().resolve(query).path;
}

export interface Runnable {
  model: RuntimeModel;
  tokenizer: LoadedTokenizer;
  config: ModelConfig;
  dir: string;
}

export async function loadRunnable(query: string): Promise<Runnable> {
  const dir = resolveModelDir(query);
  const config = await loadModelConfig(dir);
  const weights = await Weights.open(dir);
  const model = createModel(weights, config);
  const tokenizer = await loadTokenizer(dir);
  return { model, tokenizer, config, dir };
}

/** Forward a fixed token sequence, return logits [1, L, V] (caller disposes). */
function forwardLogits(model: RuntimeModel, tokens: number[]): MlxArray {
  const cache = model.makeCache();
  try {
    return model.forward(tokens, cache);
  } finally {
    for (const c of cache) c.dispose();
  }
}

function prepPrompts(prompts: string[], tok: LoadedTokenizer, seqLen: number, n: number): number[][] {
  const tiled: string[] = [];
  while (tiled.length < n) tiled.push(...prompts);
  return tiled.slice(0, n).map((p) => tok.encode(p).slice(0, seqLen));
}

/** self-flag drift gate: ref = env[flag]=refValue, cand = env[flag]=candValue. */
export async function evaluateKlSelfFlag(opts: {
  candidate: string;
  flag: string;
  refValue: string;
  candValue: string;
  prompts: string[];
  nPrompts?: number;
  seqLen?: number;
}): Promise<KLResult> {
  const t0 = Date.now();
  const n = opts.nPrompts ?? 64;
  const seqLen = opts.seqLen ?? 256;
  const { model, tokenizer } = await loadRunnable(opts.candidate);
  const tokenized = prepPrompts(opts.prompts, tokenizer, seqLen, n);

  const key = runtimeKey(opts.flag);
  const perPrompt: Float32Array[] = [];
  for (const ids of tokenized) {
    let p: MlxArray;
    const restoreRef = configureRuntime({ [key]: opts.refValue });
    try {
      p = forwardLogits(model, ids);
    } finally {
      restoreRef();
    }
    let q: MlxArray;
    const restoreCandidate = configureRuntime({ [key]: opts.candValue });
    try {
      q = forwardLogits(model, ids);
    } finally {
      restoreCandidate();
    }
    const T = Math.min(p.shape[1]!, q.shape[1]!);
    const pT = p.slice([0, 0, 0], [1, T, p.shape[2]!]);
    const qT = q.slice([0, 0, 0], [1, T, q.shape[2]!]);
    perPrompt.push(klPerToken(pT, qT));
    for (const a of [p, q, pT, qT]) a.dispose();
  }

  const agg = aggregate(perPrompt);
  return {
    nPrompts: n, seqLen, meanKl: agg.mean, medianKl: agg.median, p95Kl: agg.p95,
    elapsedSec: (Date.now() - t0) / 1000,
    refLabel: `self:${opts.flag}=${opts.refValue}→${opts.candValue}`,
  };
}

/** two-model absolute drift: KL(reference ‖ candidate) on shared prompts. */
export async function evaluateKlTwoModel(opts: {
  candidate: string;
  reference: string;
  prompts: string[];
  nPrompts?: number;
  seqLen?: number;
}): Promise<KLResult> {
  const t0 = Date.now();
  const n = opts.nPrompts ?? 64;
  const seqLen = opts.seqLen ?? 256;
  const ref = await loadRunnable(opts.reference);
  const cand = await loadRunnable(opts.candidate);
  const tokenized = prepPrompts(opts.prompts, ref.tokenizer, seqLen, n);

  const perPrompt: Float32Array[] = [];
  for (const ids of tokenized) {
    const p = forwardLogits(ref.model, ids);
    const q = forwardLogits(cand.model, ids);
    const T = Math.min(p.shape[1]!, q.shape[1]!);
    const pT = p.slice([0, 0, 0], [1, T, p.shape[2]!]);
    const qT = q.slice([0, 0, 0], [1, T, q.shape[2]!]);
    perPrompt.push(klPerToken(pT, qT));
    for (const a of [p, q, pT, qT]) a.dispose();
  }

  const agg = aggregate(perPrompt);
  return {
    nPrompts: n, seqLen, meanKl: agg.mean, medianKl: agg.median, p95Kl: agg.p95,
    elapsedSec: (Date.now() - t0) / 1000,
    refLabel: opts.reference,
  };
}

// --- serving-path (decode) KL — the M0b gate -----------------------------
// The compat forward() KL above runs plain bf16 caches → it can't see the
// quantized-KV serving path. This variant reproduces serving exactly: bf16
// prefill, then maybeQuantizeKv (the generate.ts hook) converts the populated
// mixed-4/8-bit caches, then a TEACHER-FORCED decode over the prompt tail —
// where the generated quantized SDPA (and the fused kernels) actually run.

/** CPU KL(p ‖ q) for two logit vectors (same math as klPerToken, per step). */
function klScalar(p: Float32Array, q: Float32Array): number {
  const V = p.length;
  let mp = -Infinity;
  let mq = -Infinity;
  for (let i = 0; i < V; i++) { if (p[i]! > mp) mp = p[i]!; if (q[i]! > mq) mq = q[i]!; }
  let sp = 0;
  let sq = 0;
  for (let i = 0; i < V; i++) { sp += Math.exp(p[i]! - mp); sq += Math.exp(q[i]! - mq); }
  const lsep = mp + Math.log(sp);
  const lseq = mq + Math.log(sq);
  let kl = 0;
  for (let i = 0; i < V; i++) {
    const pp = Math.exp(p[i]! - lsep);
    if (pp > 0) kl += pp * ((p[i]! - lsep) - (q[i]! - lseq));
  }
  return kl;
}

/** Prefill (bf16) → quantize → teacher-forced decode; return per-step logit
 *  distributions for the last `tokens.length - prefillLen` positions.
 *  `kvOverride` replaces the default kvConfig-from-model-config scheme when
 *  given — the seam evaluateKlKvArm uses to run a TurboQuant (or bf16-null)
 *  arm instead of the env-flag self-flip. */
function decodeArm(
  model: RuntimeModel, config: ModelConfig, tokens: number[], prefillLen: number,
  flag: string, value: string,
  kvOverride?: Parameters<typeof maybeQuantizeKv>[1],
): Float32Array[] {
  const restore = configureRuntime({ [runtimeKey(flag)]: value });
  try {
    const cache = model.makeCache();
    try {
      const lp = model.forward(tokens.slice(0, prefillLen), cache); // bf16 prefill
      lp.dispose();
      // quantize the populated caches (mixed 4/8 per kv_config) — exactly
      // what generate() does between prefill and decode.
      maybeQuantizeKv(
        cache,
        kvOverride ?? { kvConfig: config.kvQuant ?? undefined, quantizedKvStart: 0 },
      );
      const out: Float32Array[] = [];
      for (let i = prefillLen; i < tokens.length; i++) {
        const logits = model.forward([tokens[i]!], cache); // [1,1,V] quantized decode
        out.push(logits.toFloat32());
        logits.dispose();
      }
      return out;
    } finally {
      for (const c of cache) c.dispose();
    }
  } finally {
    restore();
  }
}

/** Serving-path drift gate: KL between two arms of a perf lever, measured on
 *  the teacher-forced quantized-decode path (the real e4b serving path). */
export async function evaluateKlServingDecode(opts: {
  candidate: string;
  flag: string;
  refValue: string;
  candValue: string;
  prompts: string[];
  nPrompts?: number;
  seqLen?: number;
  decodeSteps?: number;
}): Promise<KLResult> {
  const t0 = Date.now();
  const n = opts.nPrompts ?? 64;
  const seqLen = opts.seqLen ?? 256;
  const decodeSteps = opts.decodeSteps ?? 32;
  const { model, tokenizer, config } = await loadRunnable(opts.candidate);
  const tokenized = prepPrompts(opts.prompts, tokenizer, seqLen, n);

  const perPrompt: Float32Array[] = [];
  for (const tokens of tokenized) {
    if (tokens.length < 2) continue;
    const prefillLen = Math.max(1, tokens.length - decodeSteps);
    const refSteps = decodeArm(model, config, tokens, prefillLen, opts.flag, opts.refValue);
    const candSteps = decodeArm(model, config, tokens, prefillLen, opts.flag, opts.candValue);
    const m = Math.min(refSteps.length, candSteps.length);
    const kls = new Float32Array(m);
    for (let s = 0; s < m; s++) kls[s] = klScalar(refSteps[s]!, candSteps[s]!);
    perPrompt.push(kls);
  }

  const agg = aggregate(perPrompt);
  return {
    nPrompts: perPrompt.length, seqLen, meanKl: agg.mean, medianKl: agg.median, p95Kl: agg.p95,
    elapsedSec: (Date.now() - t0) / 1000,
    refLabel: `serving-decode self:${opts.flag}=${opts.refValue}→${opts.candValue} (${decodeSteps} steps)`,
  };
}

/** KV-scheme A/B on the teacher-forced serving-decode path: bf16 baseline
 *  (no kvOverride) vs an explicit KV scheme (e.g. TurboQuant), same model /
 *  same prompts / same weight load — the quality-vs-bpw curve gate
 *  (scripts/eval-turboquant-curve.ts). Unlike evaluateKlServingDecode (env-flag
 *  self-flip), the two arms differ by an actual GenerateOptions kv scheme
 *  object, so this is the seam for schemes that aren't env-lever-shaped. */
export async function evaluateKlKvArm(opts: {
  candidate: string;
  /** Undefined ⇒ bf16 (no quantization). */
  candidateScheme?: { turboQuant?: TurboQuantScheme; kvBits?: number; kvConfig?: ModelConfig["kvQuant"] };
  prompts: string[];
  nPrompts?: number;
  seqLen?: number;
  decodeSteps?: number;
}): Promise<KLResult> {
  const t0 = Date.now();
  const n = opts.nPrompts ?? 64;
  const seqLen = opts.seqLen ?? 256;
  const decodeSteps = opts.decodeSteps ?? 32;
  const { model, tokenizer, config } = await loadRunnable(opts.candidate);
  const tokenized = prepPrompts(opts.prompts, tokenizer, seqLen, n);
  const noopFlag = "MLX_BUN_EVAL_KV_ARM_NOOP"; // decodeArm always flips a flag; this one is inert
  const refKv = {}; // bf16: maybeQuantizeKv no-ops with no kvBits/kvConfig/turboQuant
  const candKv = opts.candidateScheme
    ? { ...opts.candidateScheme, quantizedKvStart: 0, kvConfig: opts.candidateScheme.kvConfig ?? undefined }
    : {};

  const perPrompt: Float32Array[] = [];
  for (const tokens of tokenized) {
    if (tokens.length < 2) continue;
    const prefillLen = Math.max(1, tokens.length - decodeSteps);
    const refSteps = decodeArm(model, config, tokens, prefillLen, noopFlag, "0", refKv);
    const candSteps = decodeArm(model, config, tokens, prefillLen, noopFlag, "0", candKv);
    const m = Math.min(refSteps.length, candSteps.length);
    const kls = new Float32Array(m);
    for (let s = 0; s < m; s++) kls[s] = klScalar(refSteps[s]!, candSteps[s]!);
    perPrompt.push(kls);
  }

  const agg = aggregate(perPrompt);
  return {
    nPrompts: perPrompt.length, seqLen, meanKl: agg.mean, medianKl: agg.median, p95Kl: agg.p95,
    elapsedSec: (Date.now() - t0) / 1000,
    refLabel: opts.candidateScheme?.turboQuant
      ? `bf16 vs turbo k${opts.candidateScheme.turboQuant.kBits}v${opts.candidateScheme.turboQuant.vBits} (${decodeSteps} steps)`
      : `bf16 vs kv-scheme (${decodeSteps} steps)`,
  };
}
