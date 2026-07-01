// DSpark speculative decode loop — a fork of src/spec/generate.ts
// (specGenerate). Same γ-draft / verify-in-one-pass / accept-longest-prefix /
// rollback spine, but the drafter is the trainable DSpark module: one PARALLEL
// backbone pass + a cheap SEQUENTIAL Markov head produce the γ-block, instead
// of γ sequential KV-borrowing drafter calls. DSpark needs only the target's
// final hidden as context (the tap), so the donor-K/V plumbing is gone.
//
// Two lossless verify modes — both leave the OUTPUT DISTRIBUTION exactly equal
// to vanilla e4b decode; the drafter only moves τ (speed), never WHAT is
// emitted:
//   - GREEDY (temperature 0): accept a draft iff it equals the target's argmax
//     (longest-prefix). Bit-identical to vanilla greedy e4b.
//   - SAMPLING (temperature > 0): the speculative-sampling rule — accept x_k
//     w.p. min(1, p_k(x_k)/q_k(x_k)); on rejection resample from the residual
//     norm(relu(p−q)) and stop; if the whole block is accepted, sample a bonus
//     from p_{γ+1}. p and q use the SAME top-p/top-k/temperature processing
//     (sample.ts), so the emitted stream is distributed exactly as if e4b
//     sampled token-by-token at that temperature — independent of draft quality.
//
// Verify the corresponding gate before chasing τ (scripts/dspark-ab.ts): greedy
// output must match model.generate; the sampling rule's correctness is the
// statistical "emit distribution == target" check in scripts/dspark-smoke.ts.
// If a gate fails, the accept/reject or KV rollback is wrong — fix that first.

import { MlxArray } from "../../mlx/array";
import { Dtype } from "../../mlx/ffi";
import * as ops from "../../mlx/ops";
import { Gemma4Model } from "../../model/gemma4";
import type { DSparkDrafter } from "./module";
import { KeyStream, processLogits, probsOf, probAtToken, sampleToken, sampleResidual, type DSparkSampleConfig } from "./sample";

export interface DSparkOptions {
  gamma?: number;
  maxTokens?: number;
  eosTokenIds?: number[];
  /** Sampling config; omit (or temperature 0) ⇒ greedy. */
  sample?: DSparkSampleConfig;
}

export interface DSparkStats {
  emitted: number;
  drafted: number;
  accepted: number;
  targetCalls: number;
  decodeMs: number;
  prefillMs: number;
  acceptanceRate: number;
  /** Mean accepted length per verify round (τ), incl. the bonus/correction token. */
  meanAcceptLen: number;
  /** Mean predicted confidence over drafted tokens (diagnostic). */
  meanConf: number;
  decodeTps: number;
}

export interface DSparkResult {
  tokens: number[];
  stats: DSparkStats;
}

/** Greedy pick from one hidden position [1,1,H]. */
function pickFromHidden(model: Gemma4Model, hidden: MlxArray, pos: number): number {
  const H = hidden.shape[2]!;
  const hSl = hidden.slice([0, pos, 0], [1, pos + 1, H]);
  const logits = model.logitsFromHidden(hSl);
  hSl.dispose();
  const V = logits.shape[2]!;
  const flat = ops.reshape(logits, [1, V]);
  logits.dispose();
  const am = ops.argmaxAxis(flat, -1);
  flat.dispose();
  const t = ops.itemUint32(am);
  am.dispose();
  return t;
}

/** Batched verify: one lm-head over the γ+1 window, argmax per position. */
function picksBatched(model: Gemma4Model, hidden: MlxArray, count: number): number[] {
  const logits = model.logitsFromHidden(hidden); // [1, L, V]
  const V = logits.shape[2]!;
  const out: number[] = [];
  for (let k = 0; k < count; k++) {
    const sl = logits.slice([0, k, 0], [1, k + 1, V]);
    const flat = ops.reshape(sl, [1, V]);
    sl.dispose();
    const am = ops.argmaxAxis(flat, -1);
    flat.dispose();
    out.push(ops.itemUint32(am));
    am.dispose();
  }
  logits.dispose();
  return out;
}

/** Result of one verify round: how many leading drafts were accepted, and the
 *  correction/bonus token to emit after them. */
interface RoundVerdict { kAccept: number; emit: number }

/** GREEDY verify: longest prefix where draft == target argmax. */
function verifyGreedy(model: Gemma4Model, vHidden: MlxArray, drafts: number[], gamma: number): RoundVerdict {
  const gt = picksBatched(model, vHidden, gamma + 1);
  let kAccept = 0;
  while (kAccept < gamma && drafts[kAccept] === gt[kAccept]) kAccept++;
  return { kAccept, emit: gt[kAccept]! };
}

/** SAMPLING verify (speculative sampling): accept x_k w.p. min(1, p/q); on the
 *  first rejection resample from norm(relu(p−q)); if all accepted sample a bonus
 *  from p_{γ+1}. p,q processed identically (top-p/top-k/temperature). */
function verifySampling(
  model: Gemma4Model, vHidden: MlxArray, draftLogits: MlxArray, drafts: number[],
  gamma: number, cfg: DSparkSampleConfig, keys: KeyStream,
): RoundVerdict {
  const V = draftLogits.shape[2]!;
  const targetLogits = model.logitsFromHidden(vHidden); // [1,γ+1,V]
  // γ uniforms for the accept tests, drawn together.
  const uArr = ops.randomUniform([gamma], Dtype.float32, 0, 1, keys.next());
  const us = uArr.toFloat32();
  uArr.dispose();

  let verdict: RoundVerdict | null = null;
  for (let k = 0; k < gamma; k++) {
    const x = drafts[k]!;
    const tScaled = processLogits(sliceTmp(targetLogits, k, V), cfg);
    const P = probsOf(tScaled);
    const dScaled = processLogits(sliceTmp(draftLogits, k, V), cfg);
    const Q = probsOf(dScaled);
    tScaled.dispose(); dScaled.dispose();
    const pX = probAtToken(P, x);
    const qX = probAtToken(Q, x);
    const accept = us[k]! < Math.min(1, qX > 0 ? pX / qX : 1);
    if (accept) {
      P.dispose(); Q.dispose();
      continue;
    }
    // reject at k → resample correction from the residual, stop.
    const corrected = sampleResidual(P, Q, keys.next());
    P.dispose(); Q.dispose();
    verdict = { kAccept: k, emit: corrected };
    break;
  }
  if (!verdict) {
    // all γ accepted → bonus from p_{γ+1}
    const bScaled = processLogits(sliceTmp(targetLogits, gamma, V), cfg);
    const bonus = sampleToken(bScaled, keys.next());
    bScaled.dispose();
    verdict = { kAccept: gamma, emit: bonus };
  }
  targetLogits.dispose();
  return verdict;
}

/** [1,L,V] → [1,V] at position k (a fresh owned array). */
function sliceTmp(logits: MlxArray, k: number, V: number): MlxArray {
  const sl = logits.slice([0, k, 0], [1, k + 1, V]);
  const flat = ops.reshape(sl, [1, V]);
  sl.dispose();
  return flat;
}

export function dsparkGenerate(
  model: Gemma4Model,
  drafter: DSparkDrafter,
  promptTokens: number[],
  options: DSparkOptions = {},
): DSparkResult {
  const gamma = options.gamma ?? drafter.cfg.gamma;
  const { maxTokens = 256, eosTokenIds = model.config.eosTokenIds } = options;
  if (gamma < 1) throw new Error("gamma must be >= 1");
  if (gamma > drafter.cfg.gamma)
    throw new Error(`gamma ${gamma} exceeds drafter max ${drafter.cfg.gamma}`);
  const sampleCfg = options.sample && options.sample.temperature > 0 ? options.sample : null;
  const keys = new KeyStream(options.sample?.seed ?? 0);

  const caches = model.makeCache();
  const stats: DSparkStats = {
    emitted: 0, drafted: 0, accepted: 0, targetCalls: 0,
    decodeMs: 0, prefillMs: 0, acceptanceRate: 0,
    meanAcceptLen: 0, meanConf: 0, decodeTps: 0,
  };
  const out: number[] = [];
  let confSum = 0;
  let rounds = 0;
  let acceptLenSum = 0;

  try {
    // 1. prefill → first token. For sampling, the first token must also be
    // sampled from the target dist (not argmax) to stay lossless.
    const t0 = performance.now();
    const ids = ops.fromInt32(promptTokens, [1, promptTokens.length]);
    const hidden = model.forwardHidden(ids, caches);
    ids.dispose();
    stats.targetCalls++;
    const H = hidden.shape[2]!;
    const Lp = hidden.shape[1]!;
    let next: number;
    if (sampleCfg) {
      const hSl = hidden.slice([0, Lp - 1, 0], [1, Lp, H]);
      const logits = model.logitsFromHidden(hSl);
      hSl.dispose();
      const flat = ops.reshape(logits, [1, logits.shape[2]!]);
      logits.dispose();
      const scaled = processLogits(flat, sampleCfg);
      flat.dispose();
      next = sampleToken(scaled, keys.next());
      scaled.dispose();
    } else {
      next = pickFromHidden(model, hidden, Lp - 1);
    }
    let lastHidden = hidden.slice([0, Lp - 1, 0], [1, Lp, H]); // [1,1,H]
    hidden.dispose();
    stats.prefillMs = performance.now() - t0;

    const nextIsEos = eosTokenIds.includes(next);
    if (!nextIsEos) out.push(next);
    stats.emitted++;
    if (nextIsEos) { lastHidden.dispose(); return finalize(stats, out, rounds, acceptLenSum, confSum); }

    // 2. outer loop
    const tDecode = performance.now();
    outer: while (stats.emitted < maxTokens) {
      // 2a. draft the γ-block: one backbone pass + sequential Markov head
      const hCtx = ops.reshape(lastHidden, [1, H]); // [1,H]
      const block = drafter.forwardInfer(model, hCtx, next, gamma, { sample: sampleCfg ?? undefined, keys });
      hCtx.dispose();
      const drafts = block.tokens;
      stats.drafted += gamma;
      for (const c of block.conf) confSum += c;

      // 2b. verify all γ drafts (+ the pending token) in one forward
      const vIds = ops.fromInt32([next, ...drafts], [1, gamma + 1]);
      const vHidden = model.forwardHidden(vIds, caches);
      vIds.dispose();
      stats.targetCalls++;

      // 2c. accept (greedy longest-prefix OR speculative sampling)
      const { kAccept, emit } = sampleCfg
        ? verifySampling(model, vHidden, block.draftLogits, drafts, gamma, sampleCfg, keys)
        : verifyGreedy(model, vHidden, drafts, gamma);
      block.draftLogits.dispose();
      stats.accepted += kAccept;
      rounds++;
      acceptLenSum += kAccept + 1; // accepted drafts + bonus/correction token

      // 2d. emit accepted drafts
      for (let k = 0; k < kAccept; k++) {
        const isEos = eosTokenIds.includes(drafts[k]!);
        if (!isEos) out.push(drafts[k]!);
        stats.emitted++;
        if (isEos || stats.emitted >= maxTokens) { vHidden.dispose(); break outer; }
      }

      // 2e. emit the correction (or bonus when all accepted)
      const emitIsEos = eosTokenIds.includes(emit);
      if (!emitIsEos) out.push(emit);
      stats.emitted++;

      // 2f. roll back rejected entries. bypass=true: we always trim the last
      // n = gamma - kAccept (≤ γ) tips immediately after the verify concat
      // write, which is the one case where trimming past the sliding window is
      // sound (the newest tokens are intact at the buffer tail). See
      // RotatingKVCache.trim.
      if (kAccept < gamma) {
        const n = gamma - kAccept;
        for (const c of caches) c.trim(n, true);
      }

      if (emitIsEos || stats.emitted >= maxTokens) { vHidden.dispose(); break; }

      // 2g. chain state
      next = emit;
      lastHidden.dispose();
      lastHidden = vHidden.slice([0, kAccept, 0], [1, kAccept + 1, H]);
      vHidden.dispose();
    }
    stats.decodeMs = performance.now() - tDecode;
    lastHidden.dispose();
  } finally {
    for (const c of caches) c.dispose();
  }

  return finalize(stats, out, rounds, acceptLenSum, confSum);
}

function finalize(stats: DSparkStats, out: number[], rounds: number, acceptLenSum: number, confSum: number): DSparkResult {
  stats.acceptanceRate = stats.drafted ? stats.accepted / stats.drafted : 0;
  stats.meanAcceptLen = rounds ? acceptLenSum / rounds : 0;
  stats.meanConf = stats.drafted ? confSum / stats.drafted : 0;
  stats.decodeTps = stats.decodeMs ? ((stats.emitted - 1) / stats.decodeMs) * 1000 : 0;
  return { tokens: out, stats };
}
