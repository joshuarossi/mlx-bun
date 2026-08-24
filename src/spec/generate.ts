// Speculative decoding loop — port of optiq runtime/spec/runtime.py
// (γ-draft / verify-in-one-pass / accept-longest-prefix / rollback).
//
// Correctness oracle: OPTIQ's spec_generate, NOT stock decode. Assistant-
// drafter speculation is an optiq feature (mlx-lm has only generic
// two-model spec, and can't drive a KV-borrowing drafter). Both optiq AND
// mlx-lm BATCH the verify lm-head (one matmul over the whole γ+1 window,
// then argmax per position) — so neither is bit-exact to stock token-at-
// a-time decode; they diverge from it at bf16 knife-edges. We do the same
// (picksBatched): greedy spec is bit-exact to optiq's spec, and agrees
// with stock only on tie-free prompts (where batched == per-position).
// An earlier version verified per-position to stay bit-exact to STOCK —
// that matched no real oracle and cost an extra γ× read of the lm-head
// weight per step; superseded. See docs/design/speculative-decoding.md.
//
// Limitation (same as the reference): partial-accept rollback requires
// trimmable caches; RotatingKVCache loses trimability once its ring
// wraps (offset ≥ sliding_window). We throw, as the reference does.

import { MlxArray } from "../mlx/array";
import * as ops from "../mlx/ops";
import { Gemma4Model, type Cache } from "../model/gemma4";
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

/** Single greedy pick from one hidden position [1,1,H] (lm-head + argmax).
 *  Used for the NON-speculative prefill token (matches stock there). */
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

/** optiq-faithful batched verify: ONE lm-head over the whole γ+1 window
 *  (reads the lm-head weight ONCE, as optiq and mlx-lm both do), then
 *  argmax per position. This is what makes greedy spec bit-exact to
 *  optiq's spec_generate. argmax is invariant to the logsumexp shift and
 *  to the monotone final-logit softcap, so raw-logit argmax here picks the
 *  same token optiq does. */
function picksBatched(model: Gemma4Model, hidden: MlxArray, count: number): number[] {
  const logits = model.logitsFromHidden(hidden); // [1, L, V] — one matmul
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

  // Round/prefill scratch tensors, hoisted so the finally frees them on a
  // mid-round throw (the 2f not-trimmable throw, or any mlx op) — try-body
  // locals are invisible to the finally. Each is nulled at its normal
  // disposal, so the finally never double-frees. Same discipline as
  // src/spec/serve-loop.ts / generate-dflash.ts (2026-07-06 review fix);
  // see memory [[mlx-inline-slice-leak-pattern]].
  let prefillH: MlxArray | null = null;
  let lastHidden: MlxArray | null = null;
  let vHidden: MlxArray | null = null;

  try {
    // 1. prefill — FULL-prompt single forward, deliberately. Per-oracle
    // convention (2026-07-07 re-anchor): mlx-lm's speculative path drains to
    // len-1 with no step-0 (the SERVE loop, whose oracle it is, now mirrors
    // that — src/spec/serve-loop.ts); THIS loop's oracle is optiq
    // spec_generate, which prefills the whole prompt in one forward and
    // samples token0 from it (runtime/spec/runtime.py:162-170, read from the
    // installed oracle venv) — the 2026-06-14 bit-exact gate was established
    // against exactly that shape. Do not tail-split here.
    const t0 = performance.now();
    const ids = ops.fromInt32(promptTokens, [1, promptTokens.length]);
    prefillH = model.forwardHidden(ids, caches);
    ids.dispose();
    stats.targetCalls++;
    const H = prefillH.shape[2]!;
    const Lp = prefillH.shape[1]!;
    let next = pickFromHidden(model, prefillH, Lp - 1);
    lastHidden = prefillH.slice([0, Lp - 1, 0], [1, Lp, H]);
    prefillH.dispose();
    prefillH = null;
    stats.prefillMs = performance.now() - t0;

    // EOS convention: an EOS id stops generation and counts toward
    // stats.emitted (reference-faithful: optiq runtime.py counts it) but
    // is NOT part of the returned content — matching our generate(),
    // which never yields EOS. optiq's spec yields it only as a stream
    // EVENT (clients see the stop); its token array role here is content.
    const nextIsEos = eosTokenIds.includes(next);
    if (!nextIsEos) out.push(next);
    stats.emitted++;
    if (nextIsEos) return { tokens: out, stats };

    // 2. outer loop
    const tDecode = performance.now();
    outer: while (stats.emitted < maxTokens) {
      const position = caches[0]!.offset - 1;
      const shared = readDonors();

      // 2a. draft γ tokens against the frozen donor views. try/finally so a
      // mid-draft throw still frees the chained hiddens + donor views + the
      // in-flight emb (assistant-source.ts draft() discipline).
      const drafts: number[] = [];
      let dTok = next;
      let dHid = lastHidden!; // borrowed for k=0
      const ownedHiddens: MlxArray[] = [];
      let emb: MlxArray | null = null;
      try {
        for (let k = 0; k < gamma; k++) {
          emb = embedScaled(dTok);
          const step = drafter.forward(emb, dHid, shared, position + k);
          emb.dispose();
          emb = null;
          drafts.push(step.token);
          stats.drafted++;
          ownedHiddens.push(step.nextHidden);
          dTok = step.token;
          dHid = step.nextHidden;
        }
      } finally {
        emb?.dispose();
        for (const a of ownedHiddens) a.dispose();
        for (const [k, v] of [shared.sliding, shared.full]) {
          k.dispose();
          v.dispose();
        }
      }

      // 2b. verify all γ drafts (+ the pending token) in one forward
      const vIds = ops.fromInt32([next, ...drafts], [1, gamma + 1]);
      vHidden = model.forwardHidden(vIds, caches);
      vIds.dispose();
      stats.targetCalls++;

      // 2c. accept the longest matching prefix. Batched verify lm-head
      // (optiq-faithful — see picksBatched).
      const gt = picksBatched(model, vHidden, gamma + 1);
      let kAccept = 0;
      while (kAccept < gamma && drafts[kAccept] === gt[kAccept]) kAccept++;
      stats.accepted += kAccept;

      // 2d. emit accepted drafts
      for (let k = 0; k < kAccept; k++) {
        const isEos = eosTokenIds.includes(drafts[k]!);
        if (!isEos) out.push(drafts[k]!);
        stats.emitted++;
        if (isEos || stats.emitted >= maxTokens) {
          vHidden.dispose();
          vHidden = null;
          break outer;
        }
      }

      // 2e. emit the correction (or bonus when all accepted)
      const emit = gt[kAccept]!;
      const emitIsEos = eosTokenIds.includes(emit);
      if (!emitIsEos) out.push(emit);
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

      if (emitIsEos || stats.emitted >= maxTokens) {
        vHidden.dispose();
        vHidden = null;
        break;
      }

      // 2g. chain state
      next = emit;
      lastHidden!.dispose();
      lastHidden = vHidden.slice([0, kAccept, 0], [1, kAccept + 1, H]);
      vHidden.dispose();
      vHidden = null;
    }
    stats.decodeMs = performance.now() - tDecode;
    lastHidden.dispose();
    lastHidden = null;
  } finally {
    // Survivors of a mid-round throw (each nulled at its normal disposal).
    prefillH?.dispose();
    lastHidden?.dispose();
    vHidden?.dispose();
    for (const c of caches) c.dispose();
  }

  stats.acceptanceRate = stats.drafted ? stats.accepted / stats.drafted : 0;
  stats.decodeTps = stats.decodeMs ? ((stats.emitted - 1) / stats.decodeMs) * 1000 : 0;
  return { tokens: out, stats };
}
