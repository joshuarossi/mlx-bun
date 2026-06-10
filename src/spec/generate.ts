// Speculative decoding loop — port of optiq runtime/spec/runtime.py
// (γ-draft / verify-in-one-pass / accept-longest-prefix / rollback).
//
// Correctness contract: greedy spec output is token-for-token identical
// to greedy non-spec decode — the verify step re-derives every emitted
// token with the SAME pick function as the stock path (logprobs argmax
// over [1, V]); drafts only ever skip target forwards, never change
// what the target would emit.
//
// Limitation (same as the reference): partial-accept rollback requires
// trimmable caches; RotatingKVCache loses trimability once its ring
// wraps (offset ≥ sliding_window). We throw, as the reference does.

import { MlxArray } from "../mlx/array";
import * as ops from "../mlx/ops";
import { Gemma4Model, type Cache } from "../model/gemma4";
import { toLogprobs } from "../sampler";
import type { GemmaAssistantDrafter } from "./drafter";

export interface SpecOptions {
  gamma?: number;
  maxTokens?: number;
  eosTokenIds?: number[];
}

export interface SpecStats {
  emitted: number;
  drafted: number;
  accepted: number;
  targetCalls: number;
  decodeMs: number;
  prefillMs: number;
  acceptanceRate: number;
  decodeTps: number;
}

export interface SpecResult {
  tokens: number[];
  stats: SpecStats;
}

/** The stock path's greedy pick, bit-identical shapes: slice ONE hidden
 *  position [1,1,H], lm-head on it (exactly what generate() does for a
 *  decode step), then logprobs argmax over [1, V]. Computing the lm-head
 *  per position (instead of batched over the verify window) keeps every
 *  pick in the same kernel shapes as stock decode — batched lm-head
 *  rounds differently and flips bf16 knife-edges. */
function pickFromHidden(model: Gemma4Model, hidden: MlxArray, pos: number): number {
  const H = hidden.shape[2]!;
  const hSl = hidden.slice([0, pos, 0], [1, pos + 1, H]);
  const logits = model.logitsFromHidden(hSl);
  hSl.dispose();
  const V = logits.shape[2]!;
  const flat = ops.reshape(logits, [1, V]);
  logits.dispose();
  const lp = toLogprobs(flat);
  flat.dispose();
  const am = ops.argmaxAxis(lp, -1);
  lp.dispose();
  const t = ops.itemUint32(am);
  am.dispose();
  return t;
}

/** Donor caches: the target's LAST sliding and LAST full cache owners
 *  (port of optiq kv_view.find_donor_layers). */
function donorIndices(model: Gemma4Model): { sliding: number; full: number } {
  let sliding = -1;
  let full = -1;
  for (let i = 0; i < model.numDonors; i++) {
    if (model.layers[i]!.layerType === "sliding_attention") sliding = i;
    else full = i;
  }
  if (sliding < 0 || full < 0) throw new Error("missing donor layer type");
  return { sliding, full };
}

export function specGenerate(
  model: Gemma4Model,
  drafter: GemmaAssistantDrafter,
  promptTokens: number[],
  options: SpecOptions = {},
): SpecResult {
  const { gamma = 2, maxTokens = 256, eosTokenIds = model.config.eosTokenIds } = options;
  if (gamma < 1) throw new Error("gamma must be >= 1");

  const caches = model.makeCache();
  const donors = donorIndices(model);
  const stats: SpecStats = {
    emitted: 0, drafted: 0, accepted: 0, targetCalls: 0,
    decodeMs: 0, prefillMs: 0, acceptanceRate: 0, decodeTps: 0,
  };
  const out: number[] = [];

  const embedScaled = (token: number): MlxArray => {
    const ids = ops.fromInt32([token], [1, 1]);
    const e = model.embed.encode(ids);
    ids.dispose();
    const s = ops.mulScalar(e, model.embedScale);
    e.dispose();
    return s;
  };

  const readDonors = () => ({
    sliding: (caches[donors.sliding] as never as { temporalView(): [MlxArray, MlxArray] }).temporalView(),
    full: (caches[donors.full] as never as { temporalView(): [MlxArray, MlxArray] }).temporalView(),
  });

  try {
    // 1. prefill
    const t0 = performance.now();
    const ids = ops.fromInt32(promptTokens, [1, promptTokens.length]);
    const hidden = model.forwardHidden(ids, caches);
    ids.dispose();
    stats.targetCalls++;
    const H = hidden.shape[2]!;
    const Lp = hidden.shape[1]!;
    let next = pickFromHidden(model, hidden, Lp - 1);
    let lastHidden = hidden.slice([0, Lp - 1, 0], [1, Lp, H]);
    hidden.dispose();
    stats.prefillMs = performance.now() - t0;

    out.push(next);
    stats.emitted++;
    if (eosTokenIds.includes(next)) return { tokens: out, stats };

    // 2. outer loop
    const tDecode = performance.now();
    outer: while (stats.emitted < maxTokens) {
      const position = caches[0]!.offset - 1;
      const shared = readDonors();

      // 2a. draft γ tokens against the frozen donor views
      const drafts: number[] = [];
      let dTok = next;
      let dHid = lastHidden; // borrowed for k=0
      const ownedHiddens: MlxArray[] = [];
      for (let k = 0; k < gamma; k++) {
        const emb = embedScaled(dTok);
        const step = drafter.forward(emb, dHid, shared, position + k);
        emb.dispose();
        drafts.push(step.token);
        stats.drafted++;
        ownedHiddens.push(step.nextHidden);
        dTok = step.token;
        dHid = step.nextHidden;
      }
      for (const a of ownedHiddens) a.dispose();
      for (const [k, v] of [shared.sliding, shared.full]) {
        k.dispose();
        v.dispose();
      }

      // 2b. verify all γ drafts (+ the pending token) in one forward
      const vIds = ops.fromInt32([next, ...drafts], [1, gamma + 1]);
      const vHidden = model.forwardHidden(vIds, caches);
      vIds.dispose();
      stats.targetCalls++;

      // 2c. accept the longest matching prefix (per-position lm-head —
      // see pickFromHidden)
      const gt: number[] = [];
      for (let k = 0; k <= gamma; k++) gt.push(pickFromHidden(model, vHidden, k));
      let kAccept = 0;
      while (kAccept < gamma && drafts[kAccept] === gt[kAccept]) kAccept++;
      stats.accepted += kAccept;

      // 2d. emit accepted drafts
      for (let k = 0; k < kAccept; k++) {
        out.push(drafts[k]!);
        stats.emitted++;
        if (eosTokenIds.includes(drafts[k]!) || stats.emitted >= maxTokens) {
          vHidden.dispose();
          break outer;
        }
      }

      // 2e. emit the correction (or bonus when all accepted)
      const emit = gt[kAccept]!;
      out.push(emit);
      stats.emitted++;

      // 2f. roll back rejected entries
      if (kAccept < gamma) {
        const n = gamma - kAccept;
        for (const c of caches) {
          if (!c.isTrimmable())
            throw new Error(`${c.constructor.name} not trimmable — context exceeded the sliding window during spec decode`);
          c.trim(n);
        }
      }

      if (eosTokenIds.includes(emit) || stats.emitted >= maxTokens) {
        vHidden.dispose();
        break;
      }

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

  stats.acceptanceRate = stats.drafted ? stats.accepted / stats.drafted : 0;
  stats.decodeTps = stats.decodeMs ? ((stats.emitted - 1) / stats.decodeMs) * 1000 : 0;
  return { tokens: out, stats };
}
