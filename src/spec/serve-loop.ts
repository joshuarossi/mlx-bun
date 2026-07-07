// Serve-time speculative decoding — the ONE verify/accept executor behind
// `serve --draft-model` (docs/design/mlx-lm-tool-parity-plan.md §7; sequenced
// by docs/design/grammar-spec-batching-integration.md Phase B).
//
// Faithful to mlx-lm's speculative_generate_step (generate.py:473-654, read
// from the oracle venv): per round, draft n tokens from the DraftSource, run
// ONE target forward over [pending, ...drafts] (n+1 positions), sample the
// target per position over the BATCHED lm-head logits (one matmul — matches
// both oracles; see src/spec/generate.ts header on why this legitimately
// diverges from stock decode at bf16 knife-edges), accept the longest prefix
// where target token == draft token (exact token-match acceptance, NOT
// distribution-level rejection sampling), emit the correction (or bonus)
// token, and trim the target caches by the rejected count.
//
// Deviations from upstream, deliberate and documented:
//  - Rotating-cache ring wrap: upstream RAISES when a cache stops being
//    trimmable mid-generation; a serve endpoint must not 500 mid-stream, so
//    we STOP SPECULATING and finish the generation with plain single-token
//    decode (bit-equivalent continuation — the target's own samples).
//  - Prompt-cache reuse is BYPASSED in v1 (fresh caches per spec request,
//    cachedTokens=0). mlx-lm composes spec with its LRU prompt cache
//    (target+draft caches per entry); wiring that through our PromptCache +
//    SSD tier is a tracked follow-up in the integration plan, not silently
//    absent.
//
// Grammar × spec (Phase C, the constrained verify walk — novel: NO runtime
// serves both; mlx-lm has no grammar, oMLX no spec): the drafter runs FREE
// (drafts are proposals; a grammar-invalid draft is simply rejected at
// verify), and the grammar mask rides the per-position accept walk in
// samplePos — mask before sample, matcher advances on emitted tokens only,
// so rejected drafts never touch grammar state and no matcher rollback is
// needed. Grammar termination mid-burst truncates the round (the all--inf
// guarantee). Gates (no oracle): greedy grammar+spec ≡ greedy grammar-only
// long-prefix + 100% schema validity (tests/spec-serve.test.ts).
//
// Emission discipline: tokens flow through the caller's onToken ONE AT A
// TIME, in order (bursts of ≤ n+1 per round) — the server's stop-sequence
// matcher and detokenizer see exactly the stream they'd see from generate().
// EOS is never emitted as content (generate() parity). onToken returning
// false halts the generation mid-burst.

import { MlxArray } from "../mlx/array";
import * as ops from "../mlx/ops";
import { clearCache } from "../mlx/ffi";
import type { RuntimeModel } from "../model/factory";
import type { Cache } from "../model/gemma4";
import type { GenerateOptions, GenerateStats } from "../generate";
import { makeSampler, makeLogitsProcessors, toLogprobs } from "../sampler";
import type { OnToken } from "../serve/generation-gateway";
import type { DraftProvider } from "./source";

const PREFILL_CHUNK = 2048;

/** Run one target forward, and when `tapLayers` is set (⟹ a Gemma4 target — a
 *  DSpark-style source), also return the captured multi-layer context
 *  [1,L,m*H] (tapLayers concatenated on the feature axis; index nLayers is the
 *  post-finalNorm sentinel). Non-tapping sources get ctxML=null and never
 *  touch model.hiddenTap. Mirrors generate-dflash.ts forwardTapped. */
function forwardMaybeTap(
  model: RuntimeModel,
  ids: MlxArray,
  caches: Cache[],
  tapLayers: number[] | undefined,
): { hidden: MlxArray; ctxML: MlxArray | null } {
  if (!tapLayers) return { hidden: model.forwardHidden(ids, caches), ctxML: null };
  const m = model as unknown as {
    hiddenTap: { layers: Set<number>; captured: Map<number, MlxArray> } | null;
  };
  const cap = new Map<number, MlxArray>();
  m.hiddenTap = { layers: new Set(tapLayers), captured: cap };
  let hidden: MlxArray | null = null;
  try {
    hidden = model.forwardHidden(ids, caches);
    const perLayer = tapLayers.map((li) => {
      const a = cap.get(li);
      if (!a) throw new Error(`spec tap: layer ${li} not captured`);
      return a;
    });
    const ctxML = ops.concatAxis(perLayer, 2); // [1,L,m*H]
    for (const [, a] of cap) a.dispose();
    cap.clear(); // consumed — the finally must not double-dispose
    const out = { hidden, ctxML };
    hidden = null; // ownership returned to the caller
    return out;
  } finally {
    // On any throw (forward mid-capture, missing layer, concat), free the
    // partially-captured tap tensors and the orphaned hidden. On success both
    // are already gone (cap cleared, hidden nulled).
    hidden?.dispose();
    for (const [, a] of cap) a.dispose();
    m.hiddenTap = null;
  }
}

export interface SpecServeExtras {
  drafted: number;
  accepted: number;
  targetCalls: number;
}

export async function specServeRun(
  model: RuntimeModel,
  provider: DraftProvider,
  numDraftTokens: number,
  promptIds: number[],
  options: GenerateOptions & { stopSequences?: string[] },
  onToken: OnToken,
): Promise<GenerateStats> {
  const maxTokens = options.maxTokens ?? 512;
  const eos = options.eosTokenIds ?? model.config.eosTokenIds;
  const sampler = makeSampler(options);
  const processors = makeLogitsProcessors(options);
  const gamma = Math.max(1, numDraftTokens);

  const caches: Cache[] = model.makeCache();
  const source = provider.open({ sampler, target: { model, caches } });
  const tapLayers = source.tapLayers;
  // Target final hidden [1,1,H] at the anchor position — the assistant source
  // borrows it for its first draft step of each round; two-model/dflash ignore
  // it. Retained across rounds, disposed in finally.
  let anchorHidden: MlxArray | null = null;
  // Round/prefill scratch tensors, hoisted so the finally disposes them on ANY
  // throw mid-round/prefill (grammar WASM reject, awaited onToken reject, a GPU
  // error). Each is nulled the instant its in-body disposal or ownership
  // transfer runs, so the finally never double-frees. (A serve endpoint hits
  // these throw seams per request; a try-body local would leak GPU memory.)
  let lastLogits: MlxArray | null = null;
  let prefillCtx: MlxArray | null = null;
  const ctxParts: MlxArray[] = []; // per-chunk tapped context (DSpark only)
  let vHidden: MlxArray | null = null;
  let vCtxML: MlxArray | null = null;
  let vLogits: MlxArray | null = null;
  let roundRow: MlxArray | null = null; // the in-flight verify/continuation row
  // Device-side token history for the logits processors (repetition/presence/
  // frequency penalties, logit_bias) — generate()'s pushHistory discipline.
  let history: MlxArray | null =
    processors.length > 0 ? ops.fromInt32(promptIds, [promptIds.length]) : null;

  const extras: SpecServeExtras = { drafted: 0, accepted: 0, targetCalls: 0 };
  const stats: GenerateStats = {
    promptTokens: promptIds.length,
    cachedTokens: 0,
    generatedTokens: 0,
    prefillMs: 0, decodeMs: 0, prefillTps: 0, decodeTps: 0,
    cacheTokens: [],
    spec: extras,
  };

  /** Sample ONE verify position from a [1,V] logits row: processors →
   *  grammar mask (Phase C: the constrained verify walk — the mask has the
   *  final say, same ordering as serial sampleStep and the batch closure) →
   *  log-softmax → sampler. The GRAMMAR walk is inherently sequential: the
   *  mask at position i reflects every token emitted before it, so this
   *  awaits the matcher's async fill (fired by the previous accept) before
   *  masking, samples, then advances the matcher — the matcher only ever
   *  moves on tokens that are (about to be) EMITTED, which is what makes
   *  rollback-free v1 correct: rejected DRAFTS never touch grammar state.
   *  Appends the sampled token to the processor history. */
  const grammar = options.grammar;
  const samplePos = async (logits1V: MlxArray, step: number): Promise<number> => {
    let cur = logits1V;
    for (const p of processors) {
      const next = p(history, cur);
      if (cur !== logits1V) cur.dispose();
      cur = next;
    }
    if (grammar && !grammar.isTerminated) {
      await grammar.ready();
      const masked = grammar.applyMask(cur);
      if (cur !== logits1V) cur.dispose();
      cur = masked;
    }
    const lp = toLogprobs(cur);
    if (cur !== logits1V) cur.dispose();
    const tokArr = sampler(lp, step);
    lp.dispose();
    const tok = ops.itemUint32(tokArr);
    tokArr.dispose();
    // Advance the matcher on the emitted token (fires the next async fill).
    // EOS is never content and never grammar-valid — don't feed it.
    if (grammar && !eos.includes(tok)) grammar.accept(tok);
    if (history) {
      const t1 = ops.fromInt32([tok], [1]);
      const prev = history;
      history = ops.concatAxis([prev, t1], 0);
      prev.dispose();
      t1.dispose();
    }
    return tok;
  };

  /** The [1,V] logits row at position `pos` of a hidden window — batched
   *  lm-head is applied by the caller ONCE; this slices its output. */
  const logitsRow = (logitsWindow: MlxArray, pos: number): MlxArray => {
    const V = logitsWindow.shape[logitsWindow.shape.length - 1]!;
    const sl = logitsWindow.slice([0, pos, 0], [1, pos + 1, V]);
    const flat = ops.reshape(sl, [1, V]);
    sl.dispose();
    return flat;
  };

  try {
    // ---- prefill (target, chunked; optionally tapped for DSpark), then seed
    // the source. Order: the source's prefill needs the tapped context that the
    // target prefill produces, so target-first (two-model's own draft prefill
    // and the assistant no-op are order-independent). ----
    const t0 = performance.now();
    for (let off = 0; off < promptIds.length; off += PREFILL_CHUNK) {
      const chunk = promptIds.slice(off, off + PREFILL_CHUNK);
      const ids = ops.fromInt32(chunk, [1, chunk.length]);
      const { hidden: h, ctxML } = forwardMaybeTap(model, ids, caches, tapLayers);
      ids.dispose();
      if (ctxML) ctxParts.push(ctxML);
      if (off + PREFILL_CHUNK >= promptIds.length) {
        const L = h.shape[1]!;
        const H = h.shape[2]!;
        anchorHidden = h.slice([0, L - 1, 0], [1, L, H]); // [1,1,H], retained
        const lg = model.logitsFromHidden(anchorHidden);
        const V = lg.shape[lg.shape.length - 1]!;
        lastLogits = ops.reshape(lg, [1, V]);
        lg.dispose();
      }
      h.dispose();
      clearCache();
    }
    extras.targetCalls++;
    // Seed the source: two-model prefills its own draft cache; DSpark seeds
    // H_ctx from the tapped prompt context (ownership transfers to prefill);
    // the assistant is a no-op.
    if (tapLayers) {
      if (ctxParts.length === 1) prefillCtx = ctxParts[0]!;
      else if (ctxParts.length > 1) {
        prefillCtx = ops.concatAxis(ctxParts, 1); // [1,Lp,m*H]
        for (const p of ctxParts) p.dispose();
      }
      ctxParts.length = 0; // parts consumed (transferred as prefillCtx or disposed)
      source.prefill(promptIds, prefillCtx ?? undefined); // takes ownership of prefillCtx
      prefillCtx = null; // ownership transferred
    } else {
      source.prefill(promptIds);
    }
    stats.prefillMs = performance.now() - t0;
    stats.prefillTps = (promptIds.length / Math.max(stats.prefillMs, 1e-6)) * 1000;

    // ---- token 0 ----
    const tDecode = performance.now();
    let pending = await samplePos(lastLogits!, 0);
    lastLogits!.dispose();
    lastLogits = null;
    if (eos.includes(pending)) {
      stats.decodeMs = performance.now() - tDecode;
      return stats;
    }
    stats.generatedTokens++;
    if (
      (await onToken(pending)) === false ||
      stats.generatedTokens >= maxTokens ||
      // grammar satisfied at token 0 (a 1-token grammar) — finish "stop"
      grammar?.isTerminated
    ) {
      stats.decodeMs = performance.now() - tDecode;
      return stats;
    }

    let feed: number[] = [pending];
    let speculating = true;

    // ---- rounds ----
    decode: while (stats.generatedTokens < maxTokens) {
      if (!speculating) {
        // plain single-token continuation (post-ring-wrap fallback)
        const ids = ops.fromInt32([pending], [1, 1]);
        const h = model.forwardHidden(ids, caches);
        ids.dispose();
        const lg = model.logitsFromHidden(h);
        h.dispose();
        const V = lg.shape[lg.shape.length - 1]!;
        roundRow = ops.reshape(lg, [1, V]);
        lg.dispose();
        extras.targetCalls++;
        const tok = await samplePos(roundRow, stats.generatedTokens);
        roundRow.dispose();
        roundRow = null;
        clearCache();
        if (eos.includes(tok)) break;
        stats.generatedTokens++;
        pending = tok;
        if ((await onToken(tok)) === false) break;
        if (grammar?.isTerminated) break; // grammar closed — finish "stop"
        continue;
      }

      const n = Math.min(gamma, Math.max(1, maxTokens - stats.generatedTokens));

      // Ring-wrap gate, BEFORE the round writes anything: a rejected-draft
      // rollback needs trim(), and a RotatingKVCache stops being trimmable
      // once its ring wraps (offset ≥ maxSize) — at which point the rejected
      // KV would be woven into the live window (unrecoverable, upstream
      // RAISES here, generate.py:529-533). Degrade to plain decode while the
      // caches are still clean instead of 500ing a stream.
      const roundFits = caches.every((c) =>
        "maxSize" in c && typeof (c as { maxSize?: number }).maxSize === "number"
          ? c.offset + n + 1 < (c as { maxSize: number }).maxSize
          : c.isTrimmable(),
      );
      if (!roundFits) {
        console.warn(
          "spec: sliding window nearly wrapped — finishing without speculation",
        );
        speculating = false;
        continue;
      }

      // (a) draft UP TO n tokens (request sampler, mlx-lm parity). The return
      // length d is authoritative — DSpark's confidence scheduler may prune the
      // block short (source.ts contract; never zero). The assistant source
      // borrows the target's anchor hidden; two-model/dflash ignore it.
      const drafts = source.draft(feed, n, stats.generatedTokens, anchorHidden ?? undefined);
      const d = drafts.length;
      if (d < 0 || d > n) throw new Error(`DraftSource returned ${d} drafts (contract: 0..${n})`);
      // d === 0 (a confidence scheduler skipping the round, DeepSpec ℓ=0
      // semantics) needs NO special case: the verify window degenerates to
      // [pending] alone, the accept walk to the single bonus position, commit
      // to a 0-accept round (tapped sources still grow context by the anchor
      // row — lockstep with the target cache).
      extras.drafted += d;

      // (b) ONE target forward over [pending, ...drafts] (optionally tapped for
      // DSpark's H_ctx). vHidden is retained past the accept walk: its slice at
      // the emitted position is the next round's anchor hidden.
      const vIds = ops.fromInt32([pending, ...drafts], [1, d + 1]);
      const ft = forwardMaybeTap(model, vIds, caches, tapLayers);
      vHidden = ft.hidden;
      vCtxML = ft.ctxML;
      vIds.dispose();
      extras.targetCalls++;
      vLogits = model.logitsFromHidden(vHidden); // batched lm-head, ONE matmul

      // (c) per-position accept walk: sample the target at each position,
      // accept while it reproduces the draft. Sampling is sequential because
      // the processor history (and, in Phase C, the grammar mask) at position
      // i depends on the tokens accepted at positions < i.
      let kAccept = 0;
      let correction: number | null = null; // target's token at first mismatch (or bonus)
      let sawEos = false;
      let halted = false;
      const emitted: number[] = [];
      let grammarDone = false;
      for (let i = 0; i <= d; i++) {
        roundRow = logitsRow(vLogits!, i);
        const tok = await samplePos(roundRow, stats.generatedTokens + emitted.length);
        roundRow.dispose();
        roundRow = null;
        if (i < d && tok === drafts[i]) {
          kAccept++;
          emitted.push(tok);
          if (eos.includes(tok)) { sawEos = true; break; }
          // grammar termination mid-burst truncates the round — nothing may
          // be sampled past a satisfied grammar (the all--inf guarantee).
          if (grammar?.isTerminated) { grammarDone = true; break; }
          if (stats.generatedTokens + emitted.length >= maxTokens) break;
          continue;
        }
        // mismatch (target replaces the draft) or bonus (i === n)
        correction = tok;
        if (!eos.includes(tok)) emitted.push(tok);
        else sawEos = true;
        if (grammar?.isTerminated) grammarDone = true;
        break;
      }
      vLogits!.dispose();
      vLogits = null;
      extras.accepted += kAccept;
      clearCache();

      // (d) emit the round's tokens through onToken, one at a time
      for (const tok of emitted) {
        stats.generatedTokens++;
        if ((await onToken(tok)) === false) { halted = true; break; }
        if (stats.generatedTokens >= maxTokens) break;
      }
      const stop = sawEos || halted || grammarDone || stats.generatedTokens >= maxTokens;

      // (e) roll back the rejected suffix + commit to the source (skipped on
      // stop — the target caches are about to be disposed). commit takes
      // ownership of vCtxML (DSpark grows H_ctx by the accepted window; the
      // others ignore it). The next anchor = the target hidden at the emitted
      // position (the assistant borrows it; generate.ts:230 pattern — the slice
      // outlives its parent's dispose).
      if (!stop) {
        if (kAccept < d) for (const c of caches) c.trim(d - kAccept);
        source.commit(d, kAccept, vCtxML ?? undefined); // takes ownership of vCtxML
        vCtxML = null;
        const H = vHidden!.shape[2]!;
        anchorHidden?.dispose();
        anchorHidden = vHidden!.slice([0, kAccept, 0], [1, kAccept + 1, H]); // [1,1,H]
      } else {
        vCtxML?.dispose();
        vCtxML = null;
      }
      vHidden!.dispose();
      vHidden = null;
      if (stop) break decode;

      // (f) chain: mlx-lm's re-feed rule (generate.py:645-648)
      const emit = correction!; // non-null: the walk always sets it unless it broke on EOS/max inside accepts
      if (d > 0 && kAccept === d) feed = [drafts[d - 1]!, emit]; // d=0 has no last draft to re-feed
      else feed = [emit];
      pending = emit;
    }

    stats.decodeMs = performance.now() - tDecode;
    stats.decodeTps = stats.decodeMs
      ? (stats.generatedTokens / stats.decodeMs) * 1000
      : 0;
    return stats;
  } finally {
    // Dispose whatever a mid-round/prefill throw left live (each is nulled the
    // instant its normal disposal or ownership transfer ran, so no double-free).
    anchorHidden?.dispose();
    lastLogits?.dispose();
    prefillCtx?.dispose();
    for (const p of ctxParts) p.dispose();
    vLogits?.dispose();
    roundRow?.dispose();
    vHidden?.dispose();
    vCtxML?.dispose();
    for (const c of caches) c.dispose();
    source.dispose();
    history?.dispose();
    options.grammar?.dispose(); // Phase C will consume it; never leak either way
    clearCache();
  }
}
