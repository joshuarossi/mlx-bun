// Serve-time speculative decoding — the ONE verify/accept executor behind
// `serve --draft-model` (docs/reference/cli.md §7; sequenced
// by docs/design/batching.md Phase B).
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
//  - Sources with checkpoint support use the injected prefix-cache service.
//    Target and companion state share the existing RAM/SSD lifecycle. Other
//    sources begin with fresh state until they supply a checkpoint codec.
//
// Grammar × spec (Phase C, the constrained verify walk — novel: NO runtime
// serves both; mlx-lm has no grammar, oMLX no spec): the drafter runs FREE
// (drafts are proposals; a grammar-invalid draft is simply rejected at
// verify), and the grammar mask rides the per-position accept walk in
// samplePos — mask before sample, matcher advances on emitted tokens only,
// so rejected drafts never touch grammar state and no matcher rollback is
// needed. Grammar termination mid-burst truncates the round (the all--inf
// guarantee). Gates (no oracle): greedy grammar+spec ≡ greedy grammar-only
// long-prefix + 100% schema validity (tests/parity/spec-serve.test.ts).
//
// Emission discipline: tokens flow through the caller's onToken ONE AT A
// TIME, in order (bursts of ≤ n+1 per round) — the server's stop-sequence
// matcher and detokenizer see exactly the stream they'd see from generate().
// EOS is never emitted as content (generate() parity). onToken returning
// false halts the generation mid-burst.

import { MlxArray } from "../mlx/array";
import { sampleSpeculativeRows } from "../backends/mlx/speculative-round";
import * as ops from "../mlx/ops";
import { clearCache } from "../mlx/ffi";
import { cleanupFailure, disposeResources } from "../engine/resources";
import type { DisposableResource } from "../contracts/resources";
import { assertMlxSpeculativeBinding, bindLegacySpeculativeModel, type MlxSpeculativeBinding } from "../backends/mlx/speculative";
import type { RuntimeModel } from "../model/factory";
import { cloneKvCaches } from "../kv-store";
import { disposeAttachments, type CheckpointAttachment } from "../backends/mlx/checkpoint-state";
import type { Cache } from "../model/gemma4";
import { withModelUsageFlush, withModelWiredLimit, type GenerateOptions, type GenerateStats } from "../generate";
import { createKvMaintenance } from "../backends/mlx/kv-maintenance";
import { runtimeConfig, withRuntimeConfig } from "../runtime-config";
import { makeSampler, makeStepSampler } from "../sampler";
import type { OnToken } from "../serve/generation-gateway";
import type { DraftProvider } from "./source";

const PREFILL_CHUNK = 2048;

export interface SpecServeExtras {
  drafted: number;
  accepted: number;
  rejected: number;
  targetCalls: number;
  rounds: number;
  acceptanceLengths: number[];
  tokensPerForward: number;
  forwardsSaved: number;
  /** Per-draft-position counters (index = position within a round's block,
   *  0..γ-1): how many rounds drafted/accepted at that position. Drives the
   *  Phase-1c per-position acceptance report (scripts/dspark.ts ab)
   *  — near-zero cost, always populated. */
  draftedByPos: number[];
  acceptedByPos: number[];
}

export interface SpecRunServices {
  readonly prefixCache?: import("../backends/mlx/checkpoint-state").MlxPrefixCache;
  /** Mounted adapter revision, resolved while the execution lease is held. */
  readonly cacheNamespace?: string;
  readonly cloneState?: (caches: Cache[]) => Cache[];
}

export async function specServeRun(
  model: RuntimeModel,
  provider: DraftProvider,
  numDraftTokens: number,
  promptIds: number[],
  options: GenerateOptions & { stopSequences?: string[] },
  onToken: OnToken,
  services: SpecRunServices = {},
): Promise<GenerateStats> {
  return specRun(bindLegacySpeculativeModel(model, provider), numDraftTokens, promptIds, options, onToken, services);
}

/** The verifier consumes a bound target and source factory, independent of
 * concrete model classes. Compatibility callers use specServeRun above. */
export async function specRun(
  binding: MlxSpeculativeBinding,
  numDraftTokens: number,
  promptIds: number[],
  options: GenerateOptions & { stopSequences?: string[] },
  onToken: OnToken,
  services: SpecRunServices = {},
): Promise<GenerateStats> {
  return withRuntimeConfig(binding.runtime ?? runtimeConfig(), () => {
    const run = () => specRunInner(binding, numDraftTokens, promptIds, options, onToken, services);
    return binding.memory
      ? withModelWiredLimit(binding.memory, () => withModelUsageFlush(binding.memory!, run))
      : run();
  });
}

async function specRunInner(
  binding: MlxSpeculativeBinding,
  numDraftTokens: number,
  promptIds: number[],
  options: GenerateOptions & { stopSequences?: string[] },
  onToken: OnToken,
  services: SpecRunServices = {},
): Promise<GenerateStats> {
  const maxTokens = options.maxTokens ?? 512;
  const maintainKv = createKvMaintenance(options);
  const eos = options.eosTokenIds ?? [...binding.eosTokenIds];
  const sampler = makeSampler(options);
  const stepSampler = makeStepSampler(options, {
    tokenRepresentation: "number",
    grammarWait: "before-sample",
    historyUpdate: "after-sample",
    initialHistory: promptIds,
    acceptGrammar: true,
    eosTokenIds: eos,
    sampler,
  });
  const gamma = Math.max(1, numDraftTokens);
  const trace = runtimeConfig().value("MLX_BUN_SPEC_TRACE") === "1";
  const prefillChunk = options.prefillChunkSize ??
    binding.prefillPolicy?.chunkSize(promptIds.length) ??
    runtimeConfig().number("MLX_BUN_RD_PREFILL_CHUNK", PREFILL_CHUNK);

  // Allocated INSIDE the try below (2026-07-07 review): provider.open()
  // throws on a mismatched (target, drafter) pairing — as pre-try consts a
  // throw leaked options.grammar (a live WASM matcher) and the fresh caches,
  // and turned a config error into a per-request 500. loadContext now
  // probe-opens the pairing at startup, so a throw here is belt+suspenders.
  let caches: Cache[] = [];
  let prefixRetain: (() => void) | undefined;
  let source: import("./source").DraftSource | null = null;
  let tapLayers: number[] | undefined;
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
  const extras: SpecServeExtras = {
    drafted: 0,
    accepted: 0,
    rejected: 0,
    targetCalls: 0,
    rounds: 0,
    acceptanceLengths: [],
    tokensPerForward: 0,
    forwardsSaved: 0,
    draftedByPos: [],
    acceptedByPos: [],
  };
  const stats: GenerateStats = {
    promptTokens: promptIds.length,
    cachedTokens: 0,
    generatedTokens: 0,
    prefillMs: 0, decodeMs: 0, prefillTps: 0, decodeTps: 0,
    cacheTokens: [],
    spec: extras,
  };

  /** The speculative walk needs eager token ids and waits for each grammar
   * mask. StepSampler keeps its processor, mask, sample, and history ordering
   * identical to the serial and batched lanes. */
  const grammar = options.grammar;
  const samplePos = async (logits1V: MlxArray, step: number): Promise<number> =>
    (await stepSampler.sample(logits1V, step)).token;

  const forwardTokens = async (tokens: number[], taps?: number[]) => {
    const ids = ops.fromInt32(tokens, [1, tokens.length]);
    try { return await binding.forward(ids, caches, taps); }
    finally { ids.dispose(); }
  };
  let failure: { error: unknown } | undefined;

  try {
    options.signal?.throwIfAborted();
    if (!Number.isSafeInteger(prefillChunk) || prefillChunk < 1)
      throw new Error("speculative prefill chunk must be a positive integer");
    assertMlxSpeculativeBinding(binding);
    if (options.kvConfig?.length ||
        (options.turboQuant && (options.quantizedKvStart ?? 0) !== 0) ||
        (options.kvBits && ((options.kvBits !== 4 && options.kvBits !== 8) || options.quantizedKvStart !== 0)))
      throw new Error("speculative KV requires uniform KV4/KV8 or TurboQuant start=0");
    caches = binding.makeCache();
    const src = binding.openDraft(sampler, caches);
    source = src;
    tapLayers = src.tapLayers;
    const checkpoint = src.prefillMode === "full" ? src.checkpoint : undefined;
    const prefixCache = checkpoint ? services.prefixCache : undefined;
    const prefixNamespace = JSON.stringify({ method: checkpoint?.namespace,
      adapters: services.cacheNamespace ?? options.adapters ?? [], kvBits: options.kvBits ?? null,
      kvGroupSize: options.kvGroupSize ?? 64, quantizedKvStart: options.quantizedKvStart ?? null,
      turboQuant: options.turboQuant ?? null });
    let cached = 0;
    const hit = prefixCache?.take(promptIds, prefixNamespace, options.cacheSessionId);
    if (hit) {
      try {
        disposeResources(caches);
        caches.splice(0, caches.length, ...hit.caches.splice(0));
        prefixRetain = hit.retain;
        hit.retain = undefined;
        checkpoint!.restore(hit.tokens.length, hit.attachments![0]!);
        cached = hit.tokens.length;
      } finally {
        disposeResources([...hit.caches, { dispose: () => disposeAttachments(hit.attachments) },
          { dispose: () => hit.retain?.() }]);
      }
    }
    stats.cachedTokens = cached;
    const capture = (tokens: number[]) => {
      let state: Cache[] = [];
      let attachments: CheckpointAttachment[] = [];
      try {
        state = (services.cloneState ?? cloneKvCaches)(caches);
        attachments.push(checkpoint!.capture(tokens.length));
        prefixCache!.put(tokens, state, prefixNamespace, undefined, attachments, options.cacheSessionId);
        state = []; attachments = [];
      } finally {
        disposeResources([...state, { dispose: () => disposeAttachments(attachments) }]);
      }
    };
    const snapshotAt = prefixCache
      ? Math.min(options.snapshotAt ?? promptIds.length, promptIds.length - 1) : -1;
    const seedSource = async (end: number) => {
      if (ctxParts.length === 1) prefillCtx = ctxParts[0]!;
      else if (ctxParts.length > 1) {
        prefillCtx = ops.concatAxis(ctxParts, 1);
        for (const part of ctxParts) part.dispose();
      }
      ctxParts.length = 0;
      const context = prefillCtx;
      prefillCtx = null; // source.prefill owns context on both success and failure
      await src.prefill(promptIds.slice(0, end), context ?? undefined);
    };
    // ---- prefill (target, chunked; optionally tapped for DSpark), then seed
    // the source. Order: the source's prefill needs the tapped context that the
    // target prefill produces, so target-first (two-model's own draft prefill
    // and the assistant no-op are order-independent). ----
    //
    // Oracle prefill convention (re-anchored 2026-07-07 after PR #18; then
    // corrected to the SPEC oracle's true shape after a live gate vs
    // speculative_generate_step still flipped a knife-edge): mlx-lm's
    // speculative path drains BOTH models to len-1 (`_prefill: while y.size >
    // 1`) and has NO separate step-0 at all — the un-drained last prompt
    // token HEADS THE FIRST VERIFY WINDOW ([lastPromptToken, ...drafts]),
    // and the first emitted token is that window's position-0 sample
    // (generate.py:578-618). A separate L=1 step-0 (the serial-lane
    // convention) is ulp-different from the (1+γ)-window GEMM head and still
    // flips near-ties. So under the flag: drain to len-1, pending = the last
    // prompt token, straight into the rounds. Gated live: 4/4 token-for-token
    // vs the oracle venv (γ∈{2,3} × 2 prompts, incl. the knife-edge cell).
    // MLX_BUN_PREFILL_TAIL_SPLIT=0 reverts to the legacy full-chunk + sampled
    // token0 shape (kill switch; also the 1-token-prompt degenerate path).
    //
    // Seam interaction: the tapped seed covers rows 0..len-2 only — the last
    // prompt token's row arrives via the FIRST verify round's vCtxML (it is
    // that round's anchor row, which commit() appends) — so context sources
    // stay in exact lockstep, and DSpark's round-1 anchor IS the last prompt
    // token at position len-1, matching DeepSpec's reference loop. The
    // assistant source's first-round anchor hidden = "the hidden that
    // produced pending" = position len-2, the last drain chunk's final row.
    const t0 = performance.now();
    const tailSplit =
      src.prefillMode !== "full" &&
      binding.prefillTailSplit;
    const oracleShape = tailSplit && promptIds.length > 1;
    if (oracleShape) {
      let pos = 0;
      const end = promptIds.length - 1; // last prompt token NEVER prefilled
      while (pos < end) {
        options.signal?.throwIfAborted();
        const n = Math.min(prefillChunk, end - pos);
        const chunk = promptIds.slice(pos, pos + n);
        const { hidden: h, ctxML } = await forwardTokens(chunk, tapLayers);
        if (ctxML) ctxParts.push(ctxML);
        try {
          if (pos + n >= end) {
            const L = h.shape[1]!;
            const H = h.shape[2]!;
            anchorHidden = h.slice([0, L - 1, 0], [1, L, H]); // position len-2
          }
        } finally { h.dispose(); } // no logits during the drain
        maintainKv(caches);
        clearCache();
        pos += n;
        if (pos < end) await new Promise<void>((resolve) => setImmediate(resolve));
      }
    } else {
      // Legacy shape: full chunked prefill (final chunk included), token0
      // sampled from the last position below.
      for (let off = cached; off < promptIds.length;) {
        options.signal?.throwIfAborted();
        const end = Math.min(off + prefillChunk, promptIds.length,
          snapshotAt > off ? snapshotAt : Infinity);
        const chunk = promptIds.slice(off, end);
        const { hidden: h, ctxML } = await forwardTokens(chunk, tapLayers);
        if (ctxML) ctxParts.push(ctxML);
        try { if (end >= promptIds.length) {
          const L = h.shape[1]!;
          const H = h.shape[2]!;
          anchorHidden = h.slice([0, L - 1, 0], [1, L, H]); // [1,1,H], retained
          const lg = binding.projectLogits(anchorHidden);
          try {
            const V = lg.shape[lg.shape.length - 1]!;
            lastLogits = ops.reshape(lg, [1, V]);
          } finally { lg.dispose(); }
        } } finally { h.dispose(); }
        maintainKv(caches);
        if (end === snapshotAt && snapshotAt > cached) {
          await seedSource(end);
          capture(promptIds.slice(0, end));
        }
        clearCache();
        off = end;
        if (off < promptIds.length)
          await new Promise<void>((resolve) => setImmediate(resolve));
      }
    }
    extras.targetCalls++;
    options.signal?.throwIfAborted();
    // Seed the source: two-model prefills its own draft cache; DSpark seeds
    // H_ctx from the tapped prompt context (ownership transfers to prefill);
    // the assistant is a no-op.
    await seedSource(promptIds.length);
    // Conversion replaces plain cache objects. Bind only after prefill has
    // converted every attention layer; rollback must own the active objects.
    const rollback = binding.bindRollback(caches);
    stats.prefillMs = performance.now() - t0;
    stats.prefillTps = ((promptIds.length - cached) / Math.max(stats.prefillMs, 1e-6)) * 1000;

    // ---- first pending token ----
    // Oracle shape: pending = the UNPROCESSED last prompt token — never
    // emitted (it's prompt), it heads the first verify window; the first
    // generated token is that window's position-0 sample, inside the walk.
    // Legacy shape: sample + emit token0 from the prefill logits (old
    // convention, kill-switch / 1-token prompts).
    const tDecode = performance.now();
    let pending: number;
    if (oracleShape) {
      pending = promptIds[promptIds.length - 1]!;
    } else {
      pending = await samplePos(lastLogits!, 0);
      lastLogits!.dispose();
      lastLogits = null;
      stats.generatedTokens++;
      if (eos.includes(pending)) {
        stats.finishReason = "stop";
        stats.decodeMs = performance.now() - tDecode;
        return stats;
      }
      if (
        (await onToken(pending)) === false ||
        stats.generatedTokens >= maxTokens ||
        // grammar satisfied at token 0 (a 1-token grammar) — finish "stop"
        grammar?.isTerminated
      ) {
        stats.decodeMs = performance.now() - tDecode;
        return stats;
      }
    }

    let feed: number[] = [pending];
    let speculating = true;

    // ---- rounds ----
    decode: while (stats.generatedTokens < maxTokens) {
      options.signal?.throwIfAborted();
      if (!speculating) {
        // plain single-token continuation (post-ring-wrap fallback)
        const { hidden: h } = await forwardTokens([pending], undefined);
        try {
          const lg = binding.projectLogits(h);
          try {
            const V = lg.shape[lg.shape.length - 1]!;
            roundRow = ops.reshape(lg, [1, V]);
          } finally { lg.dispose(); }
        } finally { h.dispose(); }
        extras.targetCalls++;
        const tok = await samplePos(roundRow, stats.generatedTokens);
        roundRow.dispose();
        roundRow = null;
        clearCache();
        stats.generatedTokens++;
        if (eos.includes(tok)) { stats.finishReason = "stop"; break; }
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
      // Non-trimmable recurrent caches (SSMCache — gated-DeltaNet state) are
      // spec-eligible through the round snapshot/replay contract instead:
      // specRoundBegin before the verify forward, then commit or a bit-exact
      // rollback(keep) after the accept walk.
      const roundFits = rollback.canBegin(n);
      if (!roundFits) {
        console.warn(
          "spec: sliding window nearly wrapped — finishing without speculation",
        );
        speculating = false;
        continue;
      }

      // (a) draft UP TO n tokens (request sampler, mlx-lm parity). The return
      // length d is authoritative — DSpark's confidence scheduler may prune the
      // block short or skip it entirely. The assistant source
      // borrows the target's anchor hidden; two-model/dflash ignore it.
      const drafts = await src.draft(
        feed,
        n,
        stats.generatedTokens,
        anchorHidden ?? undefined,
      );
      const d = drafts.length;
      if (d < 0 || d > n) throw new Error(`DraftSource returned ${d} drafts (contract: 0..${n})`);
      if (trace) {
        console.error(
          `[SPEC_TRACE] round=${extras.rounds + 1} ` +
          `feed=${feed.join(",")} drafts=${drafts.join(",")}`,
        );
      }
      // d === 0 (a confidence scheduler skipping the round, DeepSpec ℓ=0
      // semantics) needs NO special case: the verify window degenerates to
      // [pending] alone, the accept walk to the single bonus position, commit
      // to a 0-accept round (tapped sources still grow context by the anchor
      // row — lockstep with the target cache).
      extras.drafted += d;
      for (let i = 0; i < d; i++)
        extras.draftedByPos[i] = (extras.draftedByPos[i] ?? 0) + 1;

      // (b) ONE target forward over [pending, ...drafts] (optionally tapped for
      // DSpark's H_ctx). vHidden is retained past the accept walk: its slice at
      // the emitted position is the next round's anchor hidden.
      // Arm recurrent caches' spec round around the verify forward (no-op for
      // trimmable caches, which roll back via trim() below).
      rollback.begin(d);
      const vIds = ops.fromInt32([pending, ...drafts], [1, d + 1]);
      let pin: { close(): void } | undefined;
      try {
        pin = src.pinTargetKernelFamily ? binding.pinVerify?.() : undefined;
        const ft = await binding.forward(vIds, caches, tapLayers);
        // Assign these before the lm-head call so the outer cleanup owns them
        // even if logits construction throws.
        vHidden = ft.hidden;
        vCtxML = ft.ctxML;
        vLogits = binding.projectLogits(vHidden);
      } finally {
        vIds.dispose();
        pin?.close();
      }
      extras.targetCalls++;
      // The lm-head remains one logical batched operation. Native GLM MTP's
      // SPEC_PIN implementation evaluates its rows through the same M=1
      // quantized family before concatenating them.

      // (c) per-position accept walk: sample the target at each position,
      // accept while it reproduces the draft. Sampling is sequential because
      // the processor history (and, in Phase C, the grammar mask) at position
      // i depends on the tokens accepted at positions < i.
      const [result] = await sampleSpeculativeRows([{
        pending, step: stats.generatedTokens, remaining: maxTokens - stats.generatedTokens,
        eosTokenIds: eos, sampling: stepSampler, grammarDone: () => grammar?.isTerminated ?? false,
      }], [drafts], vLogits!);
      const { accepted: kAccept, correction, sawEos, emitted, grammarDone } = result!.acceptance;
      let halted = false;
      vLogits!.dispose();
      vLogits = null;
      extras.accepted += kAccept;
      extras.rejected = extras.drafted - extras.accepted;
      extras.rounds++;
      extras.acceptanceLengths.push(kAccept);
      for (let i = 0; i < kAccept; i++)
        extras.acceptedByPos[i] = (extras.acceptedByPos[i] ?? 0) + 1;
      clearCache();

      // (d) emit the round's tokens through onToken, one at a time
      for (const tok of emitted) {
        options.signal?.throwIfAborted();
        stats.generatedTokens++;
        if ((await onToken(tok)) === false) { halted = true; break; }
        if (stats.generatedTokens >= maxTokens) break;
      }
      // Native generation and mlx-lm count the stopping EOS in usage while
      // keeping it out of content. A callback or budget may stop earlier in
      // this verified burst; that unused suffix must not enter usage.
      if (sawEos && !halted && stats.generatedTokens < maxTokens) {
        stats.generatedTokens++;
        stats.finishReason = "stop";
      }
      extras.tokensPerForward = extras.rounds > 0
        ? stats.generatedTokens / extras.rounds
        : 0;
      extras.forwardsSaved = Math.max(
        0,
        Math.max(0, stats.generatedTokens - 1) - extras.rounds,
      );
      const stop = sawEos || halted || grammarDone || stats.generatedTokens >= maxTokens;

      // (e) roll back the rejected suffix + commit to the source (skipped on
      // stop — the target caches are about to be disposed). commit takes
      // ownership of vCtxML (DSpark grows H_ctx by the accepted window; the
      // others ignore it). The next anchor = the target hidden at the emitted
      // position (the assistant borrows it; generate.ts:230 pattern — the slice
      // outlives its parent's dispose).
      if (!stop) {
        // The verify window kept positions 0..kAccept (pending + accepted
        // drafts). Trimmable caches drop the rejected tail; recurrent caches
        // restore their pre-round snapshot and bit-exactly replay those
        // kAccept+1 kept tokens. On full accept the round just commits.
        rollback.resolve(kAccept);
        await src.commit(
          d,
          kAccept,
          vCtxML ?? undefined,
          vHidden,
          drafts.slice(0, kAccept),
        ); // takes ownership of vCtxML; verifiedHidden stays caller-owned
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
  } catch (error) {
    failure = { error };
    throw error;
  } finally {
    const resources = [anchorHidden, lastLogits, prefillCtx, ...ctxParts,
      vLogits, roundRow, vHidden, vCtxML, ...caches, source, stepSampler,
      options.grammar, { dispose: () => prefixRetain?.() }, { dispose: clearCache }]
      .filter((resource): resource is DisposableResource => resource != null);
    if (failure) cleanupFailure(failure.error, () => disposeResources(resources));
    else disposeResources(resources);
  }
}
