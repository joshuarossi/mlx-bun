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
import { clearCache, Dtype } from "../mlx/ffi";
import * as ops from "../mlx/ops";
import { Registry } from "../registry";
import { Weights } from "../weights";
import { loadModelConfig, type ModelConfig, type TurboQuantScheme } from "../config";
import { createModel, type RuntimeModel } from "../model/factory";
import { loadTokenizer, type LoadedTokenizer } from "../tokenizer";
import { evalCacheState, maybeQuantizeKv } from "../generate";
import { ReferenceLogitsDump, type ReferenceRecords } from "./reference-logits";
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
 *  (scripts/turboquant/eval-turboquant-curve.ts). Unlike evaluateKlServingDecode (env-flag
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

// --- saved-teacher KL (--reference-logits) --------------------------------
// The two-model mode above needs both arms resident; a bf16 teacher never
// fits beside a candidate on 32 GB. So the teacher is dumped ONCE from
// Python (top-k logits + full-vocab logsumexp per position; format and
// rationale in reference-logits.ts) and every candidate is scored against
// the dump through OUR engine.
//
// Per position, with the teacher's top-k slice j ∈ K:
//   p_j     = exp(ref_logit_j − ref_logsumexp)        (full-vocab softmax)
//   log q_j = cand_logit_j − logsumexp(cand, FULL vocab)
//   KL      = Σ_j p_j · (log p_j − log q_j)
// The sum is truncated to K, so it under-counts by the tail p carries
// outside the top-k — `meanCapturedMass` (Σ_j p_j) reports exactly how much
// of p the number covers, and a run with low captured mass is not a
// comparable KL. Everything is float32; the candidate's logsumexp is over
// its FULL vocab (never the top-k slice), so log q is a real log-probability.
//
// The forward is the SERVING path (model.makeCache + chunked forwardHidden +
// logitsFromHidden), NOT trainForward: trainForward's cache stub has no
// DeltaNet SSMCache.advance, which is why `mlx-bun perplexity` cannot score
// qwen3_5 at all (docs/design/turboquant.md, "Known engine gaps"). KV stays
// bf16 — this is a weights-only instrument.

export interface RefLogitsKLResult extends KLResult {
  /** Positions actually scored (Σ over sequences). */
  nPositions: number;
  /** Fraction of positions where argmax(ref) == argmax(cand) over full vocab. */
  top1Agreement: number;
  /** Mean Σ_{j∈topK} p_j — how much of the teacher's mass the KL sum covers. */
  meanCapturedMass: number;
  topK: number;
  /** manifest.model — the teacher these numbers are against. */
  refModel: string;
}

/** Teacher-forced candidate logits for one sequence, emitted in
 *  position-ordered chunks: `onChunk(startPos, logits[1, C, V])`. The callee
 *  owns the array and disposes it after `onChunk` returns. This is the seam
 *  the model-free test replaces (no weights, no registry). */
export type TeacherForcedLogits = (
  tokens: number[],
  onChunk: (startPos: number, logits: MlxArray) => void,
) => void;

/** The real engine forward: one cache for the whole sequence, prefilled in
 *  chunks, lm_head applied per chunk so full-vocab logits for a 4k context
 *  never exist at once (4096 × 151k × 4 B ≈ 2.5 GB). */
export function engineTeacherForcedLogits(
  model: RuntimeModel,
  chunkSize: number,
): TeacherForcedLogits {
  return (tokens, onChunk) => {
    const cache = model.makeCache();
    try {
      for (let pos = 0; pos < tokens.length; pos += chunkSize) {
        const end = Math.min(pos + chunkSize, tokens.length);
        const ids = ops.fromInt32(tokens.slice(pos, end), [1, end - pos]);
        let h: MlxArray;
        try {
          h = model.forwardHidden(ids, cache);
        } finally {
          ids.dispose();
        }
        let logits: MlxArray;
        try {
          logits = model.logitsFromHidden(h);
        } finally {
          h.dispose();
        }
        try {
          onChunk(pos, logits);
        } finally {
          logits.dispose();
        }
        evalCacheState(cache);
        clearCache(); // mlx-lm _prefill cadence: don't let chunk transients pile up
      }
    } finally {
      for (const c of cache) c.dispose();
    }
  };
}

interface ChunkScore {
  kl: Float32Array;   // [rows]
  mass: Float32Array; // [rows]
  top1: Uint8Array;   // [rows] 1 = candidate argmax == teacher argmax
}

/** Score `rows` candidate positions against the matching teacher records.
 *  `logits` is [1, C, V]; rows [rowLo, rowHi) of it line up with
 *  `records` rows [0, count). */
function scoreChunkAgainstRecords(
  logits: MlxArray, rowLo: number, rowHi: number, records: ReferenceRecords,
): ChunkScore {
  const rows = rowHi - rowLo;
  const K = records.topK;
  const V = logits.shape[2]!;
  if (records.count !== rows)
    throw new Error(`reference-logits: ${records.count} records for ${rows} candidate rows`);

  // Teacher indices must exist in the candidate's vocabulary.
  let maxIdx = -1;
  for (const v of records.indices) if (v > maxIdx) maxIdx = v;
  if (maxIdx >= V || records.indices.some((v) => v < 0))
    throw new Error(
      `reference-logits: teacher index ${maxIdx} out of range for candidate vocab ${V} ` +
      `— the dump was made with a different tokenizer`,
    );

  const owned: MlxArray[] = [];
  try {
    const sliced = logits.slice([0, rowLo, 0], [1, rowHi, V]);
    owned.push(sliced);
    const f32 = sliced.dtype === Dtype.float32 ? sliced : sliced.astype(Dtype.float32);
    if (f32 !== sliced) owned.push(f32);

    const lse = ops.logsumexpAxis(f32, -1, false); // [1, rows], full vocab
    owned.push(lse);
    const argmax = ops.argmaxAxis(f32, -1);        // [1, rows], full vocab
    owned.push(argmax);
    const idx = MlxArray.fromInt32(records.indices, [1, rows, K]);
    owned.push(idx);
    const gathered = ops.takeAlongAxis(f32, idx, 2); // [1, rows, K]
    owned.push(gathered);

    const candTop = gathered.toFloat32();
    const candLse = lse.toFloat32();
    const candArgmax = argmax.toIntTokens();

    const kl = new Float32Array(rows);
    const mass = new Float32Array(rows);
    const top1 = new Uint8Array(rows);
    for (let r = 0; r < rows; r++) {
      const refLse = records.logsumexp[r]!;
      const qLse = candLse[r]!;
      const base = r * K;
      let acc = 0;
      let m = 0;
      for (let j = 0; j < K; j++) {
        const logP = records.logits[base + j]! - refLse;
        const p = Math.exp(logP);
        if (p === 0) continue;
        m += p;
        acc += p * (logP - (candTop[base + j]! - qLse));
      }
      kl[r] = acc;
      mass[r] = m;
      top1[r] = candArgmax[r] === records.indices[base]! ? 1 : 0;
    }
    return { kl, mass, top1 };
  } finally {
    for (const a of owned) a.dispose();
  }
}

/** KL(saved bf16 teacher ‖ candidate) at EVERY teacher-forced position. */
export async function evaluateKlVsReferenceLogits(opts: {
  candidate: string;
  /** Dump directory (runs/kl-teacher/<tag>). */
  referenceDir: string;
  /** Cap on sequences scored (default: all in the manifest). */
  nSeqs?: number;
  /** Positions per candidate forward (default 512 — see the memory note). */
  chunkSize?: number;
  /** Test seam: use this forward instead of loading `candidate`. */
  forward?: TeacherForcedLogits;
}): Promise<RefLogitsKLResult> {
  const t0 = Date.now();
  const dump = ReferenceLogitsDump.open(opts.referenceDir);
  const chunkSize = Math.max(1, opts.chunkSize ?? 512);
  const nSeqs = Math.max(1, Math.min(opts.nSeqs ?? dump.nSeqs, dump.nSeqs));

  const forward = opts.forward
    ?? engineTeacherForcedLogits((await loadRunnable(opts.candidate)).model, chunkSize);

  try {
    const perSeq: Float32Array[] = [];
    let nPositions = 0;
    let top1Hits = 0;
    let massSum = 0;

    for (let s = 0; s < nSeqs; s++) {
      const tokens = dump.tokens(s);
      const scored = Math.min(dump.positionsPerSeq, tokens.length - 1);
      const kls = new Float32Array(scored);
      let filled = 0;

      forward(tokens, (startPos, logits) => {
        const chunkLen = logits.shape[1]!;
        const lo = startPos;
        const hi = Math.min(startPos + chunkLen, scored);
        if (hi <= lo) return; // trailing positions have no teacher record
        const records = dump.readRecords(s, lo, hi);
        const sc = scoreChunkAgainstRecords(logits, lo - startPos, hi - startPos, records);
        for (let r = 0; r < sc.kl.length; r++) {
          kls[lo + r] = sc.kl[r]!;
          massSum += sc.mass[r]!;
          top1Hits += sc.top1[r]!;
        }
        filled += hi - lo;
      });

      if (filled !== scored)
        throw new Error(
          `reference-logits: candidate forward covered ${filled} of ${scored} positions ` +
          `on sequence ${s}`,
        );
      perSeq.push(kls);
      nPositions += scored;
    }

    const agg = aggregate(perSeq);
    return {
      nPrompts: perSeq.length,
      seqLen: dump.ctxLen,
      meanKl: agg.mean,
      medianKl: agg.median,
      p95Kl: agg.p95,
      elapsedSec: (Date.now() - t0) / 1000,
      refLabel: `ref-logits:${dump.manifest.model} top${dump.topK} (${opts.referenceDir})`,
      nPositions,
      top1Agreement: nPositions ? top1Hits / nPositions : 0,
      meanCapturedMass: nPositions ? massSum / nPositions : 0,
      topK: dump.topK,
      refModel: dump.manifest.model,
    };
  } finally {
    dump.close();
  }
}
