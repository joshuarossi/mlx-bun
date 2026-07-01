// Faithful DFlash decode loop — the draft attends to a GROWING multi-layer
// context H_ctx (the target's tapped hiddens over the accepted stream), per
// paper §3.1 / Eq 3 + §5.1 runtime. Parallel to generate.ts (v1 single-vector).
//
// Each verify pass is TAPPED (captures the m layers at the verified positions);
// after accepting kAccept drafts, the anchor + accepted tokens' m-layer hiddens
// are appended to H_ctx (rejected tips are never added — mirrors the KV trim).
// Losslessness is unchanged: greedy = longest-prefix match; temp>0 = min(1,p/q)
// + residual resample. H_ctx only affects WHICH tokens get drafted (τ), never
// what is emitted.

import { MlxArray } from "../../mlx/array";
import { Dtype } from "../../mlx/ffi";
import * as ops from "../../mlx/ops";
import { Gemma4Model } from "../../model/gemma4";
import type { DflashDrafter } from "./module-dflash";
import { KeyStream, processLogits, probsOf, probAtToken, sampleToken, sampleResidual, type DSparkSampleConfig } from "./sample";

export interface DflashGenOptions {
  gamma?: number;
  maxTokens?: number;
  eosTokenIds?: number[];
  sample?: DSparkSampleConfig;
}
export interface DflashStats {
  emitted: number; drafted: number; accepted: number; targetCalls: number;
  decodeMs: number; prefillMs: number; acceptanceRate: number; meanAcceptLen: number; meanConf: number; decodeTps: number;
}
export interface DflashResult { tokens: number[]; stats: DflashStats }

/** Tapped forward: run the target over `ids`, returning the final post-norm
 *  hidden [1,L,H] AND the m-layer context [1,L,m*H] (tapLayers concatenated on
 *  the feature axis). */
function forwardTapped(model: Gemma4Model, ids: MlxArray, caches: import("../../model/gemma4").Cache[], tapLayers: number[]): { finalH: MlxArray; ctxML: MlxArray } {
  model.hiddenTap = { layers: new Set(tapLayers), captured: new Map() };
  let finalH: MlxArray;
  let ctxML: MlxArray;
  try {
    finalH = model.forwardHidden(ids, caches);
    const cap = model.hiddenTap.captured;
    const perLayer = tapLayers.map((li) => { const a = cap.get(li); if (!a) throw new Error(`layer ${li} not captured`); return a; });
    ctxML = ops.concatAxis(perLayer, 2); // [1,L,m*H]
    for (const [, a] of cap) a.dispose();
  } finally {
    model.hiddenTap = null;
  }
  return { finalH, ctxML };
}

function sampleFromHidden(model: Gemma4Model, hidden: MlxArray, pos: number, cfg: DSparkSampleConfig | null, keys: KeyStream): number {
  const H = hidden.shape[2]!;
  const hSl = hidden.slice([0, pos, 0], [1, pos + 1, H]);
  const logits = model.logitsFromHidden(hSl); hSl.dispose();
  const V = logits.shape[2]!;
  const flat = ops.reshape(logits, [1, V]); logits.dispose();
  let tok: number;
  if (cfg) { const sc = processLogits(flat, cfg); tok = sampleToken(sc, keys.next()); sc.dispose(); }
  else { const am = ops.argmaxAxis(flat, -1); tok = ops.itemUint32(am); am.dispose(); }
  flat.dispose();
  return tok;
}

function picksBatched(model: Gemma4Model, hidden: MlxArray, count: number): number[] {
  const logits = model.logitsFromHidden(hidden);
  const V = logits.shape[2]!;
  const out: number[] = [];
  for (let k = 0; k < count; k++) {
    const sl = logits.slice([0, k, 0], [1, k + 1, V]);
    const flat = ops.reshape(sl, [1, V]); sl.dispose();
    const am = ops.argmaxAxis(flat, -1); flat.dispose();
    out.push(ops.itemUint32(am)); am.dispose();
  }
  logits.dispose();
  return out;
}

interface Verdict { kAccept: number; emit: number }

function verifyGreedy(model: Gemma4Model, vHidden: MlxArray, drafts: number[], gamma: number): Verdict {
  const gt = picksBatched(model, vHidden, gamma + 1);
  let k = 0; while (k < gamma && drafts[k] === gt[k]) k++;
  return { kAccept: k, emit: gt[k]! };
}
function verifySampling(model: Gemma4Model, vHidden: MlxArray, draftLogits: MlxArray, drafts: number[], gamma: number, cfg: DSparkSampleConfig, keys: KeyStream): Verdict {
  const V = draftLogits.shape[2]!;
  const tl = model.logitsFromHidden(vHidden);
  const us = ops.randomUniform([gamma], Dtype.float32, 0, 1, keys.next());
  const u = us.toFloat32(); us.dispose();
  const slice = (a: MlxArray, i: number) => { const s = a.slice([0, i, 0], [1, i + 1, V]); const f = ops.reshape(s, [1, V]); s.dispose(); return f; };
  let verdict: Verdict | null = null;
  for (let k = 0; k < gamma; k++) {
    const x = drafts[k]!;
    const ps = processLogits(slice(tl, k), cfg); const P = probsOf(ps); ps.dispose();
    const qs = processLogits(slice(draftLogits, k), cfg); const Q = probsOf(qs); qs.dispose();
    const pX = probAtToken(P, x), qX = probAtToken(Q, x);
    if (u[k]! < Math.min(1, qX > 0 ? pX / qX : 1)) { P.dispose(); Q.dispose(); continue; }
    const corr = sampleResidual(P, Q, keys.next()); P.dispose(); Q.dispose();
    verdict = { kAccept: k, emit: corr }; break;
  }
  if (!verdict) { const bs = processLogits(slice(tl, gamma), cfg); verdict = { kAccept: gamma, emit: sampleToken(bs, keys.next()) }; bs.dispose(); }
  tl.dispose();
  return verdict;
}

export function dflashGenerate(model: Gemma4Model, drafter: DflashDrafter, promptTokens: number[], options: DflashGenOptions = {}): DflashResult {
  const gamma = options.gamma ?? drafter.cfg.gamma;
  const { maxTokens = 256, eosTokenIds = model.config.eosTokenIds } = options;
  const sampleCfg = options.sample && options.sample.temperature > 0 ? options.sample : null;
  const keys = new KeyStream(options.sample?.seed ?? 0);
  const tapLayers = drafter.cfg.tapLayers;

  const caches = model.makeCache();
  const stats: DflashStats = { emitted: 0, drafted: 0, accepted: 0, targetCalls: 0, decodeMs: 0, prefillMs: 0, acceptanceRate: 0, meanAcceptLen: 0, meanConf: 0, decodeTps: 0 };
  const out: number[] = [];
  let confSum = 0, rounds = 0, acceptLenSum = 0;
  let H_ctx: MlxArray | null = null;

  try {
    // 1. prefill (tapped): seed H_ctx with the prompt's m-layer hiddens.
    const t0 = performance.now();
    const ids = ops.fromInt32(promptTokens, [1, promptTokens.length]);
    const { finalH, ctxML } = forwardTapped(model, ids, caches, tapLayers);
    ids.dispose();
    stats.targetCalls++;
    H_ctx = ctxML; // [1, Lp, m*H]
    const Lp = finalH.shape[1]!;
    let next = sampleFromHidden(model, finalH, Lp - 1, sampleCfg, keys);
    finalH.dispose();
    stats.prefillMs = performance.now() - t0;

    if (eosTokenIds.includes(next)) return finalize(stats, out, rounds, acceptLenSum, confSum);
    out.push(next); stats.emitted++;

    const tDecode = performance.now();
    outer: while (stats.emitted < maxTokens) {
      // 2a. draft against the current (growing) H_ctx.
      const block = drafter.forwardInfer(model, H_ctx!, next, gamma, { sample: sampleCfg ?? undefined, keys });
      const drafts = block.tokens;
      stats.drafted += gamma;
      for (const c of block.conf) confSum += c;

      // 2b. verify (tapped) — get accepted tokens' m-layer hiddens to append.
      const vIds = ops.fromInt32([next, ...drafts], [1, gamma + 1]);
      const { finalH: vHidden, ctxML: vCtxML } = forwardTapped(model, vIds, caches, tapLayers);
      vIds.dispose();
      stats.targetCalls++;

      const { kAccept, emit } = sampleCfg
        ? verifySampling(model, vHidden, block.draftLogits, drafts, gamma, sampleCfg, keys)
        : verifyGreedy(model, vHidden, drafts, gamma);
      block.draftLogits.dispose();
      stats.accepted += kAccept; rounds++; acceptLenSum += kAccept + 1;

      // 2c. emit accepted drafts
      for (let k = 0; k < kAccept; k++) {
        const isEos = eosTokenIds.includes(drafts[k]!);
        if (!isEos) out.push(drafts[k]!);
        stats.emitted++;
        if (isEos || stats.emitted >= maxTokens) { vHidden.dispose(); vCtxML.dispose(); break outer; }
      }
      const emitIsEos = eosTokenIds.includes(emit);
      if (!emitIsEos) out.push(emit);
      stats.emitted++;

      // 2d. append accepted stream's m-layer hiddens (anchor + kAccept drafts =
      // vCtxML[:, 0..kAccept]) to H_ctx; never the rejected tips.
      const add = vCtxML.slice([0, 0, 0], [1, kAccept + 1, vCtxML.shape[2]!]);
      const grown = ops.concatAxis([H_ctx!, add], 1);
      H_ctx!.dispose(); add.dispose(); vCtxML.dispose();
      H_ctx = grown;

      // 2e. roll back rejected KV tips (bypass trim, past-window safe)
      if (kAccept < gamma) { const n = gamma - kAccept; for (const c of caches) c.trim(n, true); }

      vHidden.dispose();
      if (emitIsEos || stats.emitted >= maxTokens) break;
      next = emit;
    }
    stats.decodeMs = performance.now() - tDecode;
  } finally {
    H_ctx?.dispose();
    for (const c of caches) c.dispose();
  }
  return finalize(stats, out, rounds, acceptLenSum, confSum);
}

function finalize(stats: DflashStats, out: number[], rounds: number, acceptLenSum: number, confSum: number): DflashResult {
  stats.acceptanceRate = stats.drafted ? stats.accepted / stats.drafted : 0;
  stats.meanAcceptLen = rounds ? acceptLenSum / rounds : 0;
  stats.meanConf = stats.drafted ? confSum / stats.drafted : 0;
  stats.decodeTps = stats.decodeMs ? ((stats.emitted - 1) / stats.decodeMs) * 1000 : 0;
  return { tokens: out, stats };
}
