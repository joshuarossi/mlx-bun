import host.ts.Source
namespace Host.Ts.Sources.Inference.Generation.Autoregressive
set_option maxRecDepth 100000

/-- Verbatim `packages/inference/src/generation/autoregressive.ts`; `host/ts/SourceBinding.ts` checks the bytes. -/
def source : String := r#"// Streaming generation — port of mlx-lm's generate_step:
// - prefill in chunks; cache state evaluated per chunk (bounded transient
//   memory), logits never computed for non-final prefill positions
// - decode pipelining via mx.async_eval: step n+1's graph is built and
//   dispatched before step n's token is read back, so the GPU never idles
//   on the JS round-trip
// - opt-in early token-zero yield reduces latency before that pipeline starts
// - sampling stays on-device; only the chosen token id crosses to JS

import { MlxArray,gpuStream } from "@mlx-bun/mlx/array";
import {
Dtype,
activeMemory,
clearCache,
peakMemory,
synchronize
} from "@mlx-bun/mlx/ffi";
import * as ops from "@mlx-bun/mlx/ops";
import { appendFileSync } from "node:fs";
import { type Cache } from "../contracts/mlx/cache";
import { type MlxKnownSpans } from "../contracts/mlx/graph";
import { nextPrefillStep } from "../contracts/portable/prefill";
import {
assertMlxAutoregressiveBinding,
type MlxAutoregressiveBinding,
type MlxDecodeStep
} from "./bindings/autoregressive";
import { runtimeConfig,type RuntimeConfig } from "../runtime/config";
import { appendFillHidden } from "./fill-append";
import { appendGrammarSpan } from "./grammar-step";
import { adapterScoped,modelNeedsWiredLimit,usageScoped,wiredScoped } from "./scopes";
import { evalCacheState,executeMlxPrefillStep } from "./prefill";
import {
disposeStepExtras,
makeStepSampler,
readStepExtras,
stepExtrasArrays,
type StepExtras
} from "../sampling/index";
import { BF16_KV, COMPOSITION_DEFAULTS, type KvStorageScheme } from "../contracts/portable/composition";
import { maybePageKv } from "../state/request-policy";
import { rollbackVerifyBlock, rollsBackVerifyBlock } from "../state/rollback";
import {
fillTraceEnabled,
fillTracePath,
resolveFillMode,
type FillTraceRecord,
type Proposal
} from "./fill/session";
import { Generation } from "./result";
import { GenerateDiagnostics,GenerateOptions,GenerateStats,GeneratedToken } from "./types";

/** Jump-forward decoding for this request under a composition whose
 * `grammarJump` is `composed`: grammar requests that return no logprobs. */
export function shouldUseGrammarJump(
  options: Pick<GenerateOptions, "grammar" | "logprobs" | "topLogprobs">,
  composed: boolean = COMPOSITION_DEFAULTS.grammarJump,
): boolean {
  return options.grammar !== undefined &&
    composed &&
    !options.logprobs &&
    !(options.topLogprobs && options.topLogprobs > 0);
}

/** Composition gate for token fast-forwarding, enforced inside the engine
 *  The serving planner owns request-level eligibility, including explicit
 *  seeds in serial execution and mounted draft models. Shared strict fill
 *  has its own grouped method. The composition's KV scheme is no gate: every
 *  cache lego takes known tokens, one position at a time or through the
 *  graph's committed spans.
 *   - grammar: forced-token production is the grammar's job; two producers in
 *     one iteration is forbidden (asserted in the loop).
 *   - logprobs/top_logprobs: injected tokens are never sampled, so they have
 *     no distribution row (same rule as shouldUseGrammarJump).
 *   - promptEmbeddings: vision/audio prompts (and mRoPE) — untested shape. */
export function shouldUseFill(
  options: Pick<GenerateOptions, "fill" | "grammar" | "logprobs" | "topLogprobs" | "promptEmbeddings">,
  runtime: RuntimeConfig = runtimeConfig(),
): boolean {
  if (!options.fill) return false;
  if (resolveFillMode(runtime.value("MLX_BUN_FILL") ?? "off") === "off") return false;
  return options.grammar === undefined &&
    !options.logprobs &&
    !(options.topLogprobs && options.topLogprobs > 0) &&
    options.promptEmbeddings === undefined;
}

/** The rewind surface a verify-policy fill needs. `Cache` declares the
 *  spec-round trio as optional members, but the cache list is a UNION with
 *  GLM's MLACache (which declares none of them), so the union has no such
 *  property to read. One narrowing helper keeps the call sites honest — every
 *  use is still optional-chained. */
type RewindableCache = {
  isTrimmable(): boolean;
  trim(n: number, bypass?: boolean): void;
  specRoundBegin?(): void;
  specRoundCommit?(): void;
  specRoundRollback?(keep: number): void;
};
const rewindable = (c: unknown): RewindableCache => c as RewindableCache;

/** Execute a supplied backend binding through the same AR loop and resource
 * scopes as generate(). Callers serialize shared model/adapter access. Replacing
 * this binding replaces graph, cache construction, media, and optional decode
 * together; it never borrows another model's compiled execution implicitly. */
export function generateAutoregressive(
  binding: MlxAutoregressiveBinding,
  promptTokens: number[],
  options: GenerateOptions = {},
  diagnostics: GenerateDiagnostics = {},
): Generation {
  const runtime = binding.runtime ?? runtimeConfig();
  let inner = generateInner(binding, promptTokens, options, diagnostics, runtime);
  if (options.adapters?.length && binding.adapters) {
    inner = adapterScoped({ loraState: binding.adapters }, options.adapters, inner);
  }
  if (binding.memory.expertRuntime?.finishUsage || binding.memory.expertRuntime?.flushUsage)
    inner = usageScoped(binding.memory, inner);
  return new Generation(modelNeedsWiredLimit(binding.memory, undefined,
    runtime.value("MLX_BUN_FORCE_WIRE") === "1") ? wiredScoped(inner) : inner, runtime);
}

async function* generateInner(
  binding: MlxAutoregressiveBinding,
  promptTokens: number[],
  options: GenerateOptions,
  diagnostics: GenerateDiagnostics,
  runtime: RuntimeConfig,
): AsyncGenerator<GeneratedToken, GenerateStats> {
  if (options.signal?.aborted) {
    options.grammar?.dispose();
    options.signal.throwIfAborted();
  }
  const {
    maxTokens = 512,
    eosTokenIds = binding.eosTokenIds,
    prefillChunkSize = binding.prefillPolicy?.chunkSize(promptTokens.length) ?? 2048,
  } = options;

  try {
    assertMlxAutoregressiveBinding(binding);
    if (options.promptEmbeddings && !binding.prefillEmbeddings)
      throw new Error("AR binding does not support prompt embeddings");
    if (options.adapters?.length && !binding.adapters)
      throw new Error("AR binding does not support adapters");
  } catch (error) {
    options.grammar?.dispose();
    throw error;
  }
  const phases = binding.phases;

  // logprobs capture (mlx_lm.server semantics — see GenerateOptions.logprobs).
  // Everything below is gated: when neither flag is set, no extra ops, evals,
  // or readbacks happen on the hot path.
  const captureSelLp = options.logprobs === true;
  const captureTopK =
    options.topLogprobs && options.topLogprobs > 0 ? options.topLogprobs : 0;
  const stepSampler = makeStepSampler(options, {
    tokenRepresentation: "device",
    grammarWait: "external",
    historyUpdate: "manual",
    captureSelectedLogprob: captureSelLp,
    captureTopLogprobs: captureTopK,
  });
  const needsTokenHistory = stepSampler.needsHistory;

  const closePrefill = diagnostics.trace?.begin("prefill.total", {
    mechanism: diagnostics.mechanism ?? "serial",
    promptTokens: promptTokens.length,
    cachedTokens: options.cache?.[0]?.offset ?? 0,
  });
  const closeBatchSetup = diagnostics.trace?.begin("prefill.batch_setup", {
    mechanism: diagnostics.mechanism ?? "serial",
  });
  const ownsCache = !options.cache;
  const resuming = options.initialPendingToken !== undefined;
  let cache: Cache[] = options.cache ?? [];
  // The composition's KV scheme, which every request stores.
  const kv = binding.kv ?? BF16_KV;
  let appender: MlxKnownSpans | null = null;
  try {
    if (ownsCache) cache = binding.makeCache();
    if (!cache.length) throw new Error("AR binding returned an empty cache");
    const cached = cache[0]!.offset;
    if ((!resuming && cached >= promptTokens.length) ||
        (resuming && cached !== promptTokens.length))
      throw new Error(
        resuming
          ? `resumed cache (${cached} tokens) must exactly cover the resume prefix (${promptTokens.length})`
          : `pre-warmed cache (${cached} tokens) must be a strict prefix of the prompt (${promptTokens.length})`,
      );
    // Replace fresh full-attention caches before any forward. The deepest
    // write is prompt + maxTokens - 1, so capacity covers every decode step.
    maybePageKv(cache, kv, binding.pagedKv ?? null, promptTokens.length + maxTokens);
    // Committed known-token spans, where the graph declares them and the run
    // mounts no adapter; otherwise known tokens append one position at a time.
    appender = options.fill && binding.knownSpans && !options.adapters?.length
      ? binding.knownSpans : null;
  } catch (error) {
    if (ownsCache) for (const state of cache) state.dispose();
    stepSampler.dispose();
    options.grammar?.dispose();
    closeBatchSetup?.();
    closePrefill?.();
    throw error;
  }
  const cachedTokens = cache[0]!.offset;
  // Token fast-forwarding gate (see shouldUseFill). Sliding-window layers take
  // part: a multi-token append is one concat write, and a rejected verify tail
  // leaves the ring by the bypass trim that write allows (see rewind below).
  const fillOn = shouldUseFill(options, runtime);
  const fillTrace = fillOn && fillTraceEnabled();
  const fillTraceFile = fillOn ? fillTracePath() : null;
  // Verify-policy proposals (echo tier) need the rejected tail rewound. That
  // is the SAME contract the spec lane's rounds use: trimmable caches drop the
  // tail; recurrent caches (SSMCache — gated-DeltaNet state, untrimmable)
  // restore a pre-round snapshot and bit-exactly replay the accepted prefix.
  // A model whose caches can do neither still gets assert-policy fills; verify
  // proposals are dropped and counted (stats.verifyUnsupported).
  const verifyCapable = fillOn && rollsBackVerifyBlock(kv, cache);
  closeBatchSetup?.();

  // logits [1,1,V] → sampled token array [1] (+ optional logprob capture,
  // all on-device)
  const sampleStep = (
    logits3d: MlxArray,
    step: number,
  ): { tok: MlxArray; extras: StepExtras | null } => {
    const result = stepSampler.sample(logits3d, step);
    return { tok: result.token, extras: result.extras };
  };

  const pushHistory = (tok: MlxArray): void => stepSampler.commitDevice(tok);

  // Decode-loop state lives at function scope so the finally can still
  // report stats and dispose in-flight arrays when the consumer
  // terminates the generator early (break on a stop sequence — the
  // forced .return() resumes at the yield and runs the finally).
  let prefillMs = 0;
  let tDecode = 0;
  let decodeMs = 0;
  let generated = options.initialGeneratedTokens ?? 0;
  let finishReason: GenerateStats["finishReason"];
  const forwarded: number[] = [];
  let pending: MlxArray | null = null;
  let nextPending: MlxArray | null = null;
  let pendingExtras: StepExtras | null = null;
  let nextExtras: StepExtras | null = null;
  let decoder: MlxDecodeStep | null = null;
  let finished = false;
  let threw = false;
  let executionError: unknown;
  let earlyUnforwardedToken: number | null = null;
  let closeTokenZero: (() => void) | undefined;
  const makeStats = (): GenerateStats => ({
    promptTokens: options.originalPromptTokens ?? promptTokens.length,
    cachedTokens: Math.min(cachedTokens, options.originalPromptTokens ?? promptTokens.length),
    generatedTokens: generated,
    ...(finishReason ? { finishReason } : {}),
    prefillMs,
    decodeMs,
    prefillTps: prefillMs > 0
      ? ((promptTokens.length - cachedTokens) / prefillMs) * 1000
      : 0,
    decodeTps: (generated / decodeMs) * 1000,
    cacheTokens: [...promptTokens, ...forwarded],
    ...(fillOn ? { fill: options.fill!.stats } : {}),
  });

  /** The one invariant that makes fill safe: the caches hold exactly
   *  prompt + everything `forwarded` records, so a fill append must forward
   *  ONLY the injected ids — the normal step already consumed `cur` and wrote
   *  its KV. Forwarding [token, ...ids] would duplicate a position and
   *  silently corrupt both the KV and PromptCache.put's key. Checked under
   *  MLX_BUN_FILL_TRACE=1 on both sides of the append. */
  const assertFillAlignment = (where: string): void => {
    const offset = cache[0]!.offset;
    const want = promptTokens.length + forwarded.length;
    if (offset !== want)
      throw new Error(
        `[fill] cache misalignment ${where}: cache offset ${offset} != ` +
        `prompt ${promptTokens.length} + forwarded ${forwarded.length}`,
      );
  };

  /** THE apply primitive for token fast-forwarding — ONE chunked forward
   *  carries a proposal into the KV (and the recurrent state), and BOTH
   *  policies ride it (packages/inference/src/generation/fill/proposal.ts):
   *
   *   - assert: the span is determined (a template scaffold). Append and move
   *     on. No readback, no checkpoint, no rewind. The in-flight sample for
   *     the position after `token` is dropped UNEXAMINED — a discarded
   *     pipeline dispatch, not a rejected draft.
   *   - verify: the span is likely (a copy from earlier in the session).
   *     Position 0 is checked BEFORE the forward against the in-flight sample
   *     (free, and a mismatch costs nothing — nothing has been written).
   *     Positions 1..m-1 are checked against the argmax already sitting in
   *     THIS forward's logits, so verification adds no pass over the weights.
   *     The rejected tail is rewound through the same cache contract the spec
   *     lane's rounds use, and decode resumes at the first disagreement.
   *
   *  Returns the ids the engine must now emit (empty = no fill happened).
   *  Mutates nextPending/nextExtras/forwarded, exactly like the normal step. */
  /** One trace record: the proposal next to the model's own token at every
   *  span position (`actual[0]` = in-flight sample, `actual[j]` = argmax after
   *  ids[j-1]). Appended as JSONL to MLX_BUN_FILL_TRACE=<file>. */
  const traceProposal = (
    proposal: Proposal, generatedNow: number, accepted: number, actual: number[],
  ): void => {
    const ids = proposal.ids;
    let firstMismatch = -1;
    for (let j = 0; j < ids.length && j < actual.length; j++)
      if (actual[j] !== ids[j]) { firstMismatch = j; break; }
    const dec = options.fill!.decode;
    const rec: FillTraceRecord = {
      ts: new Date().toISOString(), origin: proposal.origin, policy: proposal.policy,
      generated: generatedNow, proposedLen: ids.length, accepted, firstMismatch,
      proposed: ids, actual,
      ...(dec ? { proposedText: dec(ids), actualText: dec(actual) } : {}),
    };
    try { appendFileSync(fillTraceFile!, JSON.stringify(rec) + "\n"); } catch { /* trace is best-effort */ }
  };

  const applyProposal = async (
    proposal: Proposal, generatedNow: number,
  ): Promise<number[]> => {
    const fill = options.fill!;
    const ids = proposal.ids;
    const verify = proposal.policy === "verify";
    if (verify && !verifyCapable) {
      fill.noteVerifyUnsupported();
      fill.commit(proposal, 0);
      return [];
    }
    // The in-flight sample IS the model's own choice for position 0 (read for
    // the trace under both policies; the served assert path never checks it).
    const inFlight = verify || fillTraceFile ? ops.itemUint32(nextPending!) : -1;
    if (verify) {
      if (inFlight !== ids[0]) {
        if (fillTraceFile) traceProposal(proposal, generatedNow, 0, [inFlight]);
        fill.commit(proposal, 0);
        return []; // nextPending survives; this becomes an ordinary step
      }
    } else {
      fill.noteWastedSample();
    }
    if (fillTrace) assertFillAlignment("at fill entry");
    nextPending!.dispose();
    nextPending = null;
    disposeStepExtras(nextExtras);
    nextExtras = null;

    let checkpointMs = 0;
    let roundOpen = false;
    if (verify) {
      const t0 = performance.now();
      for (const c of cache) rewindable(c).specRoundBegin?.();
      roundOpen = true;
      checkpointMs += performance.now() - t0;
    }
    let accepted = ids.length;
    let hf: MlxArray | null = null;
    let logitsAll: MlxArray | null = null;
    try {
      // A committed span stops at any composed cache's pending transition,
      // which that cache then runs inside its append.
      const chunkSize = (state: readonly Cache[]) => {
        const maxChunk = Math.min(appender?.maxChunkSize(state) ?? 1,
          ...state.map(c => c.maxAppendTokens?.() ?? Number.POSITIVE_INFINITY));
        return fill.appendChunkSize > 0 ? Math.min(fill.appendChunkSize, maxChunk) : maxChunk;
      };
      // A verified proposal is one verify window (one position decodes); an
      // asserted span appends known tokens, through the committed read under
      // the graph's known spans, one decoded position at a time otherwise.
      const forward = (part: MlxArray, state: Cache[], positions: number) => positions === 1 && (verify || !appender)
        ? phases.decode(1)(part, state, null)
        : verify ? phases.verify(1, positions)(part, state, null) : phases.known(positions)(part, state);
      hf = await appendFillHidden(forward, cache, ids, verify ? () => ids.length : chunkSize);
      const [, Lf, Hf] = hf.shape as [number, number, number];
      let pred: number[] | null = null;
      if (verify || fillTraceFile) {
        // Free logits: this forward already computed every span position's
        // hidden state. argmax at j is the model's continuation after ids[j],
        // so it verifies ids[j+1]. (Under assert this readback is trace-only.)
        logitsAll = phases.logits(ids.length)(hf);
        const argmax = ops.argmaxAxis(logitsAll, -1);
        pred = argmax.toIntTokens();
        argmax.dispose();
      }
      if (verify && pred) {
        for (let j = 0; j + 1 < ids.length; j++) {
          if (pred[j] !== ids[j + 1]) { accepted = j + 1; break; }
        }
      }
      if (fillTraceFile && pred)
        traceProposal(proposal, generatedNow, accepted, [inFlight, ...pred.slice(0, ids.length - 1)]);
      const t1 = performance.now();
      if (accepted < ids.length) {
        // The state drops the rejected tail (trim, a ring's rollback trim, or
        // a recurrence's restore and replay).
        rollbackVerifyBlock(cache, accepted, ids.length);
        roundOpen = false;
      } else if (roundOpen) {
        for (const c of cache) rewindable(c).specRoundCommit?.();
        roundOpen = false;
      }
      if (verify) checkpointMs += performance.now() - t1;
      forwarded.push(...ids.slice(0, accepted));
      if (fillTrace) assertFillAlignment("after fill append");
      // The sampler's token history gets the ACCEPTED ids only, before the
      // resume sample — so logits processors (repetition/presence/frequency)
      // see exactly the sequence that was emitted.
      stepSampler.commitNumbers(ids.slice(0, accepted));
      // Resume from the LAST ACCEPTED position's logits: the bonus token on a
      // full accept, the correction on a partial one. Same sampler and step
      // index as an ordinary step — the correction's KV is written by the next
      // iteration's forward, like any sampled token.
      const willGen = generatedNow + accepted;
      if (willGen < maxTokens) {
        let logits: MlxArray;
        if (logitsAll) {
          const V = logitsAll.shape[2]!;
          logits = logitsAll.slice([0, accepted - 1, 0], [1, accepted, V]);
        } else {
          const hLast = hf.slice([0, Lf - 1, 0], [1, Lf, Hf]);
          logits = phases.logits(1)(hLast);
          hLast.dispose();
        }
        const sn = sampleStep(logits, willGen);
        nextPending = sn.tok;
        nextExtras = sn.extras;
        logits.dispose();
        ops.asyncEvalAll([nextPending, ...stepExtrasArrays(nextExtras)]);
      }
    } finally {
      // A throw mid-round would otherwise leave the recurrent caches armed
      // (their next forward raises "spec round already recorded").
      if (roundOpen) for (const c of cache) rewindable(c).specRoundCommit?.();
      logitsAll?.dispose();
      hf?.dispose();
    }
    if (verify) fill.noteVerifyEvent(checkpointMs);
    fill.commit(proposal, accepted);
    if (fillTrace)
      console.error(
        `[fill] ${proposal.origin}/${proposal.policy} ${accepted}/${ids.length} ` +
        `after ${generatedNow} generated (events ${fill.stats.events}, ` +
        `injected ${fill.stats.injected}, checkpoint ${checkpointMs.toFixed(2)}ms)`,
      );
    return ids.slice(0, accepted);
  };

  let nextCheckpoint = options.checkpointEveryTokens && options.checkpointEveryTokens > 0
    ? (Math.floor(generated / options.checkpointEveryTokens) + 1) * options.checkpointEveryTokens
    : Number.POSITIVE_INFINITY;
  let tPrefill = performance.now();

  try {
    if (resuming) {
      // The checkpoint cache already covers the complete replay prefix. Its
      // pending token was sampled from that exact state before the snapshot,
      // so resume starts directly at the decode loop without another forward.
      if (needsTokenHistory) stepSampler.seedHistory(promptTokens);
      // Device samplers return uint32. Preserve that signature on restore so
      // compiled decode does not trace a different signed-token graph first.
      using restoredToken = ops.fromInt32([options.initialPendingToken!], [1]);
      pending = restoredToken.astype(Dtype.uint32);
      ops.asyncEvalAll([pending]);
      prefillMs = 0;
      closePrefill?.();
      tDecode = performance.now();
    } else {
    // ---- prefill ---- (composed caches convert inside their own appends)
    tPrefill = performance.now();
    let h0: MlxArray;
    if (options.promptEmbeddings) {
      if (cachedTokens !== 0)
        throw new Error("promptEmbeddings cannot be combined with a pre-warmed cache");
      if (needsTokenHistory)
        stepSampler.seedHistory(promptTokens);
      // e2b/e4b need the spliced token ids to build per-layer inputs
      // (multimodal soft-token positions zeroed inside forwardEmbeddings).
      const embedIds = ops.fromInt32(promptTokens, [1, promptTokens.length]);
      h0 = binding.prefillEmbeddings!(
        options.promptEmbeddings, cache, options.imageMask ?? null, embedIds,
        options.multimodalMask ?? null, (promptTokens.length),
      );
      embedIds.dispose();
    } else {
      let pos = cachedTokens;
      const snapshotAt = options.onPrefillDone && options.snapshotAt !== undefined
        ? Math.min(Math.max(options.snapshotAt, cachedTokens), promptTokens.length)
        : undefined;
      const tailSplit = binding.prefillTailSplit ?? COMPOSITION_DEFAULTS.prefillTailSplit;

      while (true) {
        options.signal?.throwIfAborted();
        const step = nextPrefillStep({ length: promptTokens.length, position: pos,
          chunkSize: prefillChunkSize, tailSplit, snapshotAt });
        if (step.kind === "final" && needsTokenHistory) stepSampler.seedHistory(promptTokens);
        const closeChunk = diagnostics.trace?.begin("prefill.chunk", {
          mechanism: diagnostics.mechanism ?? "serial", startToken: step.start,
          tokens: step.end - step.start, ...(step.kind === "final" ? { final: true } : {}),
        });
        let hidden: MlxArray | null;
        try { hidden = await executeMlxPrefillStep(phases, cache, promptTokens, step); }
        finally { closeChunk?.(); }
        pos = step.end;
        if (hidden) { h0 = hidden; break; }
        if (runtime.value("MLX_BUN_PREFILL_MEM_LOG") === "1")
          console.error(`[prefill-mem] ${pos} active ${(activeMemory() / 2 ** 30).toFixed(2)} peak ${(peakMemory() / 2 ** 30).toFixed(2)}`);
        await new Promise<void>((resolve) => setImmediate(resolve));
        if (step.snapshot) options.onPrefillDone?.();
      }
    }
    if (options.snapshotAt === undefined || options.snapshotAt >= promptTokens.length)
      options.onPrefillDone?.();
    // The trace's prefill span is the uncached model-forward portion only.
    // Token-0 lm-head, sampling, and readback are a separate additive stage.
    if (diagnostics.trace && runtime.value("MLX_BUN_P2R_SYNC") === "1")
      synchronize(gpuStream);
    closePrefill?.();
    closeTokenZero = diagnostics.trace?.begin("token_zero.total", {
      mechanism: diagnostics.mechanism ?? "serial",
    });
    const [, L0, H] = h0.shape as [number, number, number];
    const hLast = h0.slice([0, L0 - 1, 0], [1, L0, H]);
    h0.dispose();
    const logits0 = phases.logits(1)(hLast);
    hLast.dispose();
    const s0 = sampleStep(logits0, 0); // token array [1] (+ optional extras)
    pending = s0.tok;
    pendingExtras = s0.extras;
    logits0.dispose();
    // mirror mlx-lm generate_step: async-dispatch the first token's
    // compute; the prefill clock keeps running until the token ARRIVES
    // (first itemUint32 below). mlx-lm stops its prompt clock at the
    // first yielded token, which bills the prefill→decode boundary
    // (allocator reclaim of prefill transients + first-step dispatch)
    // to prompt_time, not decode — replicated so cross-stack decode
    // tok/s measure the same quantity. The boundary cost is real and
    // scales with prompt length; it belongs to "having prefilled".
    ops.asyncEvalAll([pending, ...stepExtrasArrays(pendingExtras)]);
    }

    // ---- decode (pipelined) ----
    // The compiled step is the graph binding's, chosen once for this run's caches; it has no fallback.
    decoder = options.decodePolicy?.compiledDecode === false ? null
      : binding.createDecode?.({ hasAdapters: !!options.adapters?.length }) ?? null;
    let stop = false;
    /** Token id read eagerly at the top of the loop for grammar (reused for
     *  the yield, avoiding a second readback). -1 when grammar is off — the
     *  pipelined path keeps its deferred itemUint32 below. */
    let grammarTok = -1;
    // Jump-forward decoding in this direct loop (opt-in, the composition's
    // grammarJump; the scheduler's grammar rows jump through the span method
    // the planner binds): when the grammar forces a unique continuation, emit its retokenized ids without
    // per-token forwards — ONE multi-token forward carries them into the KV
    // (see GrammarController.jumpForward for the contract + the fidelity
    // note on why this is opt-in). Excluded when logprobs are requested
    // (jumped tokens are never sampled, so they'd have no logprobs rows).
    const grammarJump = options.decodePolicy?.grammarJump ?? shouldUseGrammarJump(options, binding.grammarJump);
    // Yield token zero before its own decode forward. The captured runtime
    // keeps this scheduling choice stable across consumer awaits.
    const earlyFirstToken = runtime.flag("MLX_BUN_EARLY_FIRST_TOKEN", true) &&
      maxTokens > 1 && !resuming && !fillOn && !options.grammar;
    while (!stop) {
      options.signal?.throwIfAborted();
      const cur = pending!;
      const stepIndex = generated;
      let curExtras = pendingExtras;
      let yieldedEarly = false;
      if (earlyFirstToken && stepIndex === 0) {
        const firstToken = ops.itemUint32(cur);
        options.signal?.throwIfAborted();
        if (!eosTokenIds.includes(firstToken)) {
          prefillMs = performance.now() - tPrefill;
          closeTokenZero?.();
          closeTokenZero = undefined;
          tDecode = performance.now();
          const logprobs = readStepExtras(curExtras);
          curExtras = null;
          pendingExtras = null;
          // Count before yielding so an early return reports this token. Its
          // KV is still absent; forwarded describes the prompt-only cache.
          generated++;
          yieldedEarly = true;
          earlyUnforwardedToken = firstToken;
          yield { token: firstToken, index: stepIndex, ...(logprobs ? { logprobs } : {}) };
          earlyUnforwardedToken = null;
          options.signal?.throwIfAborted();
        }
      }
      // Keep current extras owned by the run until readback succeeds. A
      // forward/grammar failure must leave them reachable by finally.
      // Grammar advance (packages/inference/src/sampling/grammar.ts): acceptToken needs the token id as a
      // JS number, which the pipelined loop defers (it operates on device
      // arrays). So grammar requests eager-read cur here, advance the matcher,
      // and await the async mask precompute — which overlaps the GPU forward
      // dispatched just below. This trades the readback/forward overlap for
      // correctness (the mask for step n+1 must reflect token n). Non-grammar
      // requests keep the fast pipelined loop untouched.
      //
      // F1 fix (batched-lane plan): always eager-read `grammarTok` when
      // grammar is on, even at the max_tokens boundary — the emitted token
      // reuses it unconditionally. The OLD code gated the READ on
      // generated+1 < maxTokens but emitted grammarTok regardless, so the LAST
      // iteration skipped the refresh and emitted a stale/garbage token (the
      // previous step's token, or -1 when max_tokens=1) → truncated JSON ended
      // on a corrupted token + cacheTokens recorded the wrong id. Now only
      // accept()/ready() (which prepare the NEXT step's mask) are gated.
      /** Forced ids to emit after cur this iteration (jump-forward), else null. */
      let jumpEmit: number[] | null = null;
      if (options.grammar) {
        grammarTok = ops.itemUint32(cur);
        if (stepIndex + 1 < maxTokens) {
          options.grammar.accept(grammarTok);
          await options.grammar.ready();
          if (grammarJump && !options.grammar.isTerminated) {
            jumpEmit = options.grammar.jumpForward(maxTokens - (stepIndex + 1));
            // jumpForward advanced the matcher and fired the post-jump mask
            // fill; it must be ready before this iteration's sampleStep.
            if (jumpEmit) await options.grammar.ready();
          }
        }
      }
      // build step n+1's graph from the *unread* pending token
      nextPending = null;
      nextExtras = null;
      // When the grammar has terminated (a complete valid JSON/schema
      // accepted), there are no valid tokens left — skip building the next
      // step so the sampler never sees an all--inf distribution.
      if (jumpEmit) {
        // JUMP iteration: one [1, 1+m] forward carries cur AND the forced ids
        // into the KV (they are all committed content — jumpForward's
        // contract); the next sampled token, if the budget and grammar allow
        // one, comes from its last position. Compiled decode resumes on the
        // following iteration over the same caches.
        pushHistory(cur);
        stepSampler.commitNumbers(jumpEmit);
        const chunk = [grammarTok, ...jumpEmit];
        const willGen = stepIndex + 1 + jumpEmit.length;
        await appendGrammarSpan(phases, cache, chunk,
          ids => { forwarded.push(...ids); },
          willGen < maxTokens && !options.grammar!.isTerminated ? logits => {
            const sampled = sampleStep(logits, willGen);
            nextPending = sampled.tok;
            nextExtras = sampled.extras;
          } : undefined);
        if (nextPending) ops.asyncEvalAll([nextPending, ...stepExtrasArrays(nextExtras)]);
      } else if (stepIndex + 1 < maxTokens && !options.grammar?.isTerminated) {
        pushHistory(cur);
        let logits: MlxArray;
        let evalWith: MlxArray[] = [];
        if (decoder) ({ logits, evalWith } = decoder.step(cur, cache));
        else {
          const ids = ops.reshape(cur, [1, 1]);
          const h = await phases.decode(1)(ids, cache, null);
          ids.dispose();
          logits = phases.logits(1)(h);
          h.dispose();
        }
        const sn = sampleStep(logits, stepIndex + 1);
        nextPending = sn.tok;
        nextExtras = sn.extras;
        logits.dispose();
        ops.asyncEvalAll([nextPending, ...stepExtrasArrays(nextExtras), ...evalWith]);
      }

      // sync-read step n's token while n+1 computes
      // sync-read step n's token while n+1 computes (grammar already read it
      // eagerly above — reuse to avoid a second GPU sync)
      const token = options.grammar ? grammarTok : ops.itemUint32(cur);
      options.signal?.throwIfAborted();
      if (generated === 0) {
        // first token arrived: prompt clock stops, decode clock starts
        // (mlx-lm stream_generate's n==0 clock swap; the first token is
        // "free" on the decode clock there too)
        prefillMs = performance.now() - tPrefill;
        closeTokenZero?.();
        closeTokenZero = undefined;
        tDecode = performance.now();
      }
      cur.dispose();
      pending = null;
      if (!yieldedEarly) generated++;
      // if a next-step graph was built, this token's KV entered the cache
      // (jump iterations pushed the whole chunk already)
      if (nextPending !== null && !jumpEmit) forwarded.push(token);

      if (eosTokenIds.includes(token)) {
        finishReason = "stop";
        disposeStepExtras(curExtras);
        pendingExtras = null;
        nextPending?.dispose();
        nextPending = null;
        disposeStepExtras(nextExtras);
        nextExtras = null;
        stop = true;
      } else {
        // ---- token fast-forwarding (K3): APPEND, then yield ----------------
        // The engine already knows the next m tokens, so it writes them into
        // the KV itself with an append and resumes sampling after them. No
        // draft, no verify, no rollback: an injected token is indistinguishable
        // to the model from one it sampled. The append happens BEFORE any of
        // the burst's yields, which is what makes a consumer break mid-burst
        // safe — `forwarded` already describes the cache exactly.
        let fillEmit: number[] | null = null;
        if (fillOn) {
          if (jumpEmit)
            throw new Error("fill and grammar jump-forward cannot share an iteration");
          // A fill needs an in-flight step to ride; with nextPending null this
          // token's KV was never written and the generation ends here. push()
          // still runs so the session's history (and echo index) stay exact.
          const proposal = options.fill!.push(
            token, nextPending !== null ? maxTokens - generated : 0,
          );
          if (proposal && nextPending !== null) {
            const emitted = await applyProposal(proposal, generated);
            if (emitted.length) fillEmit = emitted;
          } else if (proposal) {
            options.fill!.commit(proposal, 0); // unreachable at budget 0; belt
          }
        }
        // readExtras before the yield: if the consumer breaks at this yield,
        // the extras are already read and disposed.
        const logprobs = readStepExtras(curExtras);
        pendingExtras = null;
        if (!yieldedEarly) yield { token, index: generated - 1, ...(logprobs ? { logprobs } : {}) };
        options.signal?.throwIfAborted();
        // mlx-lm generate_step: clear_cache after token 0 (drops the
        // remaining prefill transients) and every 256 tokens after
        if ((generated - 1) % 256 === 0) clearCache();
        // Jump-forward burst: the forced ids follow cur, one yield each (the
        // consumer's stop-sequence matcher and detokenizer see the same
        // one-at-a-time stream shape as always). Their KV is already in the
        // cache (the chunk forward above); a consumer break mid-burst is
        // safe — `forwarded` already reflects the cache exactly.
        if (jumpEmit) {
          for (const jt of jumpEmit) {
            options.signal?.throwIfAborted();
            generated++;
            yield { token: jt, index: generated - 1 };
            if ((generated - 1) % 256 === 0) clearCache();
          }
        }
        // Fill burst: same one-yield-per-token shape as the jump burst, so
        // CompletionSink / StopMatcher / StreamDecoder see an ordinary stream
        // (a stop sequence inside an injected span fires exactly where it
        // would have in an unfilled run).
        if (fillEmit) {
          for (const ft of fillEmit) {
            options.signal?.throwIfAborted();
            generated++;
            yield { token: ft, index: generated - 1 };
            if ((generated - 1) % 256 === 0) clearCache();
          }
        }
        if (nextPending === null) {
          stop = true;
        } else {
          pending = nextPending;
          nextPending = null;
          pendingExtras = nextExtras;
          nextExtras = null;
        }
        if (
          pending !== null &&
          options.onDecodeCheckpoint &&
          generated >= nextCheckpoint
        ) {
          const pendingToken = ops.itemUint32(pending);
          await options.onDecodeCheckpoint({
            cacheTokens: [...promptTokens, ...forwarded],
            caches: cache,
            generatedTokens: generated,
            pendingToken,
          });
          const every = options.checkpointEveryTokens!;
          while (nextCheckpoint <= generated) nextCheckpoint += every;
        }
      }
    }
    decodeMs = performance.now() - tDecode;
    finished = true;
    return makeStats();
  } catch (e) {
    threw = true;
    executionError = e;
    throw e;
  } finally {
    try {
      // An early consumer return leaves token zero outside the retained KV.
      // Finish that one M=1 forward before handing caller-owned caches back,
      // matching the ordinary pipeline's boundary. Otherwise a later prefix
      // hit folds the token into an M>1 prefill and changes native reductions.
      // Aborted requests and caches owned by this run need no retained state.
      if (!ownsCache && !threw && !options.signal?.aborted && earlyUnforwardedToken !== null) {
        const ids = ops.reshape(pending!, [1, 1]);
        try {
          const hidden = await phases.decode(1)(ids, cache, null);
          try { evalCacheState(cache); }
          finally { hidden.dispose(); }
        } finally { ids.dispose(); }
        forwarded.push(earlyUnforwardedToken);
      }
    } catch (error) {
      threw = true;
      executionError = error;
      throw error;
    } finally {
      if (!finished) {
        pending?.dispose();
        nextPending?.dispose();
        disposeStepExtras(pendingExtras);
        disposeStepExtras(nextExtras);
      }
      try {
        const closing = decoder?.close();
        if (closing) await closing;
      } catch (error) {
        if (threw) throw new AggregateError([executionError, error],
          "AR execution and decoder cleanup failed", { cause: executionError });
        throw error;
      } finally {
        if (ownsCache) for (const c of cache) c.dispose();
        // TokenizerInfo is process-cached; this request owns the matcher.
        options.grammar?.dispose();
        stepSampler.dispose();
      }
      if (!finished && !threw) {
        // forced early return (consumer break at a yield): still report
        // stats — `forwarded` only lists tokens whose KV actually entered
        // the cache, so cacheTokens stays exact for PromptCache.put().
        decodeMs = performance.now() - tDecode;
        return makeStats();
      }
    }
  }
}
"#

source_parse source

/-- Lean's lexer and parser accept the whole file (kernel-checked chunks). -/
theorem parses : (parse chars).isSome = true := parse_isSome lex_eq parsesTokens

theorem sourceParses : (parse source.toList).isSome = true := chars.eq ▸ parses

end Host.Ts.Sources.Inference.Generation.Autoregressive
