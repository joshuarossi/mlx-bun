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
  const source = provider.open({ sampler });
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
    // ---- prefill (both models, chunked) ----
    const t0 = performance.now();
    source.prefill(promptIds);
    let lastLogits: MlxArray | null = null;
    for (let off = 0; off < promptIds.length; off += PREFILL_CHUNK) {
      const chunk = promptIds.slice(off, off + PREFILL_CHUNK);
      const ids = ops.fromInt32(chunk, [1, chunk.length]);
      const h = model.forwardHidden(ids, caches);
      ids.dispose();
      if (off + PREFILL_CHUNK >= promptIds.length) {
        const L = h.shape[1]!;
        const H = h.shape[2]!;
        const hLast = h.slice([0, L - 1, 0], [1, L, H]);
        const lg = model.logitsFromHidden(hLast);
        hLast.dispose();
        const V = lg.shape[lg.shape.length - 1]!;
        lastLogits = ops.reshape(lg, [1, V]);
        lg.dispose();
      }
      h.dispose();
      clearCache();
    }
    extras.targetCalls++;
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
        const flat = ops.reshape(lg, [1, V]);
        lg.dispose();
        extras.targetCalls++;
        const tok = await samplePos(flat, stats.generatedTokens);
        flat.dispose();
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

      // (a) draft n tokens (request sampler, mlx-lm parity)
      const drafts = source.draft(feed, n, stats.generatedTokens);
      extras.drafted += n;

      // (b) ONE target forward over [pending, ...drafts]
      const vIds = ops.fromInt32([pending, ...drafts], [1, n + 1]);
      const vHidden = model.forwardHidden(vIds, caches);
      vIds.dispose();
      extras.targetCalls++;
      const vLogits = model.logitsFromHidden(vHidden); // batched lm-head, ONE matmul
      vHidden.dispose();

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
      for (let i = 0; i <= n; i++) {
        const row = logitsRow(vLogits, i);
        const tok = await samplePos(row, stats.generatedTokens + emitted.length);
        row.dispose();
        if (i < n && tok === drafts[i]) {
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
      vLogits.dispose();
      extras.accepted += kAccept;
      clearCache();

      // (d) emit the round's tokens through onToken, one at a time
      for (const tok of emitted) {
        stats.generatedTokens++;
        if ((await onToken(tok)) === false) { halted = true; break; }
        if (stats.generatedTokens >= maxTokens) break;
      }
      if (sawEos || halted || grammarDone || stats.generatedTokens >= maxTokens) break decode;

      // (e) roll back the rejected suffix on the target (the pre-round gate
      // guarantees trimmability here)
      if (kAccept < n) for (const c of caches) c.trim(n - kAccept);
      source.commit(n, kAccept);

      // (f) chain: mlx-lm's re-feed rule (generate.py:645-648)
      const emit = correction!; // non-null: the walk always sets it unless it broke on EOS/max inside accepts
      if (kAccept === n) feed = [drafts[n - 1]!, emit];
      else feed = [emit];
      pending = emit;
    }

    stats.decodeMs = performance.now() - tDecode;
    stats.decodeTps = stats.decodeMs
      ? (stats.generatedTokens / stats.decodeMs) * 1000
      : 0;
    return stats;
  } finally {
    for (const c of caches) c.dispose();
    source.dispose();
    history?.dispose();
    options.grammar?.dispose(); // Phase C will consume it; never leak either way
    clearCache();
  }
}
