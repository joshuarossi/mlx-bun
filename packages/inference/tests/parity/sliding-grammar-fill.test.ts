// Grammar, grammar proposals and supplied fill on a sliding-window Universal
// graph, on real weights, through the gateway's real placement path (the
// binding's plan, then methodRequest or row sampling, then the binding's
// execution group, composed as the app's generation gateway composes them),
// against this tree's direct token-by-token generation. Every case runs past the
// sliding window. Checked:
// - Grammar (JSON schema, choice, EBNF) without jump: at B1 the gateway equals
//   direct generation in tokens, every forward (IDs and the row's valid K/V
//   before it) and every projection's complete logits; the scheduler may add
//   one discarded single-token lookahead step. Rows prepared together or
//   joining late (B2) each equal their B1 direct output.
// - Grammar with MLX_BUN_GRAMMAR_JUMP=1: the graph binds grammar proposals, so
//   the gateway places the request on the speculative group, which verifies
//   the matcher's forced string rather than committing it (no forced span is
//   taken from the matcher). At B1 and B2 its tokens equal direct
//   token-by-token generation, every forward continues the row's history
//   (rejected proposals are rolled back out of the ring), and across the cases
//   proposals are verified, some accepted and some rejected.
// - Supplied fill (strict assert rows; echo verify proposals), with MLX_BUN_FILL
//   set: the gateway applies it through the shared fill binding. Strict rows
//   assert the fill-off control's own continuation and echo proposals are
//   verified, so B1 and B2 output equals the fill-off direct control while the
//   session records the injected and accepted tokens, and echo proposals reach
//   verify forwards.
// - For each of those three shapes, a B2 group in which one row is cancelled at
//   its third token: it emits exactly those three tokens and rejects with the
//   cancellation; its peer runs to its end equal to its B1 output; the drained
//   group then serves the cancelled request again, equal to its B1 run (direct
//   generation for grammar, a fresh group for proposals and fill) in tokens,
//   forwards and projections.
// Compiled decode is off and the prompt tail is split on both paths, so every
// step is observed and both issue the same calls.
// Opt in with both of
//   MLX_BUN_TEST_SLIDING_GRAMMAR_FILL_MODEL=/llama-family/snapshot
//   MLX_BUN_TEST_SLIDING_GRAMMAR_FILL_WINDOW=<sliding window, at least 4; e.g. 8>
// The window builds the custom graph the rotating-join and continuation
// consumers use: alternating sliding and full layers over the artifact's
// unchanged weights (not a published model). None skips; a partial, blank or
// invalid opt-in fails before native libraries load.
import { afterAll, beforeAll, describe, expect, test } from "bun:test";
import { strict as assert } from "node:assert";
import { existsSync, readFileSync } from "node:fs";
import { join } from "node:path";
import type { MlxArray } from "@mlx-bun/mlx/array";
import type { Cache } from "../../src/contracts/mlx/cache";
import type { GenerateOptions } from "../../src/generation/types";
import type { FillSession, ProposalSource } from "../../src/generation/fill/session";
import type { GrammarRequest } from "../../src/sampling/grammar";
import { applyDescriptor, descriptorFor, optInAll, releaseAll, type WindowDescriptor } from "./real-weight-inputs";
import { rotatingRowReader, type RowState } from "./rotating-rows";

const MODEL = "MLX_BUN_TEST_SLIDING_GRAMMAR_FILL_MODEL", WINDOW = "MLX_BUN_TEST_SLIDING_GRAMMAR_FILL_WINDOW";
const CHUNK = 2048, FILL_TOKENS = 32, CANCEL_AT = 3;

// ---- opt-in and prompts (no native libraries) ---------------------------------------------
export function optIn(env: Record<string, string | undefined>) {
  const values = optInAll(env, [MODEL, WINDOW], "the sliding-window grammar and fill consumer");
  if (!values) return null;
  const window = values[WINDOW].trim();
  if (!/^\d+$/.test(window) || Number(window) < 4) throw new Error(`${WINDOW} must be an integer >= 4, so a prompt can start below it`);
  const model = values[MODEL];
  assert(existsSync(join(model, "config.json")), `${MODEL}: no config.json in ${model}`);
  const raw = JSON.parse(readFileSync(join(model, "config.json"), "utf8"));
  assert(["llama", "mistral"].includes(raw.model_type), `a custom window needs a Llama-family artifact, not ${raw.model_type}`);
  return { model, window: Number(window), descriptor: descriptorFor((raw.text_config ?? raw).num_hidden_layers, Number(window)) };
}

/** Prompts around the window: two past it (the ring wraps in prefill), each its
 * encoding repeated without the leading BOS until it exceeds the window, and one
 * below it (the ring wraps in decode), a prefix of the first. */
export function planPrompts(a: readonly number[], b: readonly number[], window: number) {
  const past = (ids: readonly number[]) => {
    const out = [...ids];
    while (out.length <= window) out.push(...ids.slice(1));
    return out;
  };
  return { long: past(a), other: past(b), short: a.slice(0, Math.floor(window / 2)) };
}
type PromptName = keyof ReturnType<typeof planPrompts>;

// ---- records and their checks (pure; no native libraries) ----------------------------------
export interface Forward { B: number; L: number; ids: number[][]; state: RowState | { unreadable: string } | null }
export interface Projection { B: number; L: number; dtype: string; rows: string[] }
export interface Run { tokens: number[]; spans: number[][]; forwards: Forward[]; projections: Projection[] }

/** The gateway's B1 run equals direct generation's: the same tokens and forced
 * spans, and every forward (IDs, the row's valid state before it) and projection
 * direct generation made, in order. The scheduler may dispatch one decode step
 * past the end and discard it: at most one trailing single-row, single-position
 * forward and projection. */
export function checkSameRun(label: string, shared: Run, direct: Run): void {
  assert.deepEqual(shared.tokens, direct.tokens, `${label}: tokens`);
  assert.deepEqual(shared.spans, direct.spans, `${label}: forced spans`);
  for (const kind of ["forwards", "projections"] as const) {
    direct[kind].forEach((item, index) => assert.deepEqual(shared[kind][index], item, `${label}: ${kind} ${index}`));
    const extra = shared[kind].slice(direct[kind].length);
    assert(extra.length <= 1 && extra.every(item => item.B === 1 && item.L === 1),
      `${label}: ${extra.length} ${kind} past direct generation's (${JSON.stringify(extra.map(item => [item.B, item.L]))})`);
  }
}

/** Each B1 forward continues the row's history (prompt + tokens) from what the
 * cache holds. A forward may carry unverified positions past the prompt
 * (proposals): its IDs match the history up to the first rejected one, and only
 * the matching prefix stays in the cache. Every projection covers one position
 * unless proposals are verified. Returns the decode forwards (those starting at
 * or after the prompt's end) and the proposed and accepted positions. */
export function walk(label: string, run: Run, prompt: readonly number[]) {
  const history = [...prompt, ...run.tokens], decode: number[][] = [];
  let cursor = 0, proposed = 0, accepted = 0;
  run.forwards.forEach((forward, index) => {
    const ids = forward.ids[0]!;
    assert(forward.B === 1 && forward.ids.length === 1 && ids.length === forward.L, `${label}: forward ${index} is not one row`);
    let kept = 0;
    while (kept < ids.length && ids[kept] === history[cursor + kept]) kept++;
    assert(kept > 0 && (kept === ids.length || cursor + kept >= prompt.length),
      `${label}: forward ${index} does not continue the history at ${cursor}`);
    const verified = Math.max(0, ids.length - Math.max(1, prompt.length - cursor));
    proposed += verified; accepted += Math.max(0, verified - (ids.length - kept));
    if (cursor >= prompt.length) decode.push(ids);
    cursor += kept;
  });
  return { decode, proposed, accepted };
}

/** The token-by-token run: no forced span, every forward continues the
 * history in full with no verified position, and every projection covers one. */
export function checkTokenByToken(label: string, run: Run, prompt: readonly number[]): void {
  assert.equal(run.spans.length, 0, `${label}: the token-by-token run forced a span`);
  const { proposed } = walk(label, run, prompt);
  assert.equal(proposed, 0, `${label}: ${proposed} positions were verified`);
  run.projections.forEach((projection, index) =>
    assert(projection.B === 1 && projection.L === 1, `${label}: projection ${index} covers ${projection.B}x${projection.L} positions`));
}

export const REVIEW_SCHEMA = { type: "object", properties: { city: { type: "string", maxLength: 16 },
  rating: { enum: [1, 2, 3, 4, 5] } }, required: ["city", "rating"], additionalProperties: false };
type GrammarName = "json" | "choice" | "ebnf";
/** The compact JSON schema (fixed layout, so forced spans occur), a choice and an EBNF. */
export const GRAMMARS: Record<GrammarName, { request: GrammarRequest; maxTokens: number }> = {
  json: { request: { responseFormat: { type: "json_schema",
    json_schema: { name: "review", schema: REVIEW_SCHEMA, strict: true, any_whitespace: false } } }, maxTokens: 80 },
  choice: { request: { guidedChoice: ["Paris", "Lisbon", "Kyoto"] }, maxTokens: 8 },
  ebnf: { request: { guidedGrammar: 'root ::= ("yes" | "no") ", " [a-z] [a-z] [a-z]*' }, maxTokens: 16 },
};

/** The decoded output satisfies its grammar. */
export function checkGrammarOutput(label: string, grammar: GrammarName, text: string): void {
  if (grammar === "json") {
    const value = JSON.parse(text) as Record<string, unknown>;
    assert.deepEqual(Object.keys(value).toSorted(), ["city", "rating"], `${label}: keys`);
    assert(typeof value.city === "string" && value.city.length <= 16, `${label}: city ${JSON.stringify(value.city)}`);
    assert([1, 2, 3, 4, 5].includes(value.rating as number), `${label}: rating ${JSON.stringify(value.rating)}`);
  } else if (grammar === "choice") assert(["Paris", "Lisbon", "Kyoto"].includes(text), `${label}: ${JSON.stringify(text)} is not a choice`);
  else assert(/^(yes|no), [a-z]{2,}$/.test(text), `${label}: ${JSON.stringify(text)} does not match the EBNF`);
}

/** A strict assert row of `length` tokens that restates the fill-off control:
 * its trigger is the control's pair (control[t-1], control[t]) at the first
 * t >= 4 whose every occurrence in the session's history (the prompt's last
 * token, then the control) is followed by the same `length` tokens, which it
 * emits. Applied, it cannot change the output; it only commits those tokens
 * without sampling them. */
export function strictRow(prompt: readonly number[], control: readonly number[], length = 4) {
  const history = [prompt.at(-1)!, ...control];
  for (let t = 4; t + length < control.length; t++) {
    const [a, b] = [control[t - 1]!, control[t]!], emit = control.slice(t + 1, t + 1 + length);
    if (history.every((token, i) => token !== a || history[i + 1] !== b ||
        history.slice(i + 2, i + 2 + length).every((id, j) => id === emit[j])))
      return { trigger: [a, b], emit, kind: "scaffold" as const };
  }
  throw new Error(`the control (${control.length} tokens) has no usable strict trigger`);
}

// ---- real weights ------------------------------------------------------------------------
const inputs = optIn(Bun.env);

type Shape = "grammar" | "jump" | "fill";
type FillMode = "strict" | "echo" | "reject";
interface Request { prompt: PromptName; grammar?: GrammarName; fill?: FillMode }
interface Outcome { tokens: number[]; spans: number[][]; status: "fulfilled" | "rejected"; error?: unknown; fill?: FillSession }
/** The graph operations the recorder wraps. */
interface Graph { forwardHidden(ids: MlxArray, caches: Cache[]): MlxArray; logitsFromHidden(hidden: MlxArray): MlxArray; args?: WindowDescriptor }
/** MLX_BUN_FILL for a set of rows: echo (which a rejected-proposal row also needs) is additive to strict. */
const fillMode = (rows: readonly Request[]): "strict" | "echo" | undefined =>
  rows.some(row => row.fill === "echo" || row.fill === "reject") ? "echo" : rows.some(row => row.fill === "strict") ? "strict" : undefined;

async function setup() {
  const { loadModelConfig, Weights, createModel, generate } = await import("@mlx-bun/inference");
  const { bindMlxGateway, createRowSampling, configureRuntime } = await import("@mlx-bun/inference/execution");
  const { makeStepSampler } = await import("@mlx-bun/inference/sampling");
  const { compileGrammarRequest } = await import("@mlx-bun/inference/sampling/grammar");
  const { loadTokenizer } = await import("@mlx-bun/inference/input");
  const { FillSession: Session } = await import("@mlx-bun/inference/generation/fill");
  const { clearCache } = await import("@mlx-bun/mlx/ffi");
  const { hash, rowStates } = await rotatingRowReader();
  const { model: dir, window, descriptor } = inputs!;
  const config = await loadModelConfig(dir);
  applyDescriptor(config, descriptor);
  const weights = await Weights.open(dir);
  const releaseWeights = () => {
    try { weights.dispose(); }
    finally { releaseAll([...weights.shards.files.values()].map(file => () => file.mmap.unmap())); clearCache(); }
  };
  const { model, graph, tokenizer, prompts } = await (async () => {
    const model = createModel(weights, config), graph = model as unknown as Graph;
    expect({ layerTypes: graph.args?.layerTypes, slidingWindow: graph.args?.slidingWindow }).toEqual(descriptor);
    const tokenizer = await loadTokenizer(dir);
    const prompts = planPrompts(tokenizer.encode("Name one city you like and rate it from 1 to 5 as JSON.", true),
      tokenizer.encode("Answer yes or no, then add one lowercase word.", true), window);
    assert(prompts.long.length > window && prompts.other.length > window && prompts.short.length < window, "prompts do not bracket the window");
    return { model, graph, tokenizer, prompts };
  })().catch(error => { releaseWeights(); throw error; });

  // One recorder for both paths, installed before any binding or group binds
  // the graph's operations: every forward (IDs; at B1, the row's valid state
  // before it) and every projection's complete logits, per row and position.
  let trace: { forwards: Forward[]; projections: Projection[]; states: boolean } | null = null;
  const forwardHidden = graph.forwardHidden, logitsFromHidden = graph.logitsFromHidden;
  graph.forwardHidden = function (this: Graph, ids: MlxArray, caches: Cache[]) {
    if (trace) {
      const [B, L] = ids.shape as [number, number], flat = ids.toIntTokens();
      let state: Forward["state"] = null;
      if (trace.states && B === 1 && caches[0]!.offset > 0) {
        // A cache the reader does not know is recorded as such, so the
        // comparison names it rather than aborting the row.
        try { state = rowStates(caches, 1)[0]!; }
        catch (error) { state = { unreadable: (error as Error).message }; }
      }
      trace.forwards.push({ B, L, ids: Array.from({ length: B }, (_, r) => flat.slice(r * L, (r + 1) * L)), state });
    }
    return forwardHidden.call(this, ids, caches);
  };
  graph.logitsFromHidden = function (this: Graph, hidden: MlxArray) {
    const out = logitsFromHidden.call(this, hidden);
    if (trace) try {
      const [B, L, V] = out.shape as [number, number, number], rows: string[] = [];
      for (let b = 0; b < B; b++) for (let l = 0; l < L; l++) { using row = out.slice([b, l, 0], [b + 1, l + 1, V]); rows.push(hash(row)); }
      trace.projections.push({ B, L, dtype: out.dtypeName, rows });
    } catch (error) { out.dispose(); throw error; }
    return out;
  };
  const traced = async <T>(states: boolean, run: () => Promise<T>) => {
    trace = { forwards: [], projections: [], states };
    try { const value = await run(); return { value, forwards: trace.forwards, projections: trace.projections }; }
    finally { trace = null; }
  };

  /** The scenario's runtime, active while `run` binds and generates. */
  const under = async <T>(shape: Shape, fill: FillMode | undefined, run: () => Promise<T>) => {
    const restore = configureRuntime({ MLX_BUN_PREFILL_TAIL_SPLIT: "1", MLX_BUN_COMPILED_DECODE: "0", MLX_BUN_GRAMMAR: "1",
      MLX_BUN_GRAMMAR_JUMP: shape === "jump" ? "1" : "0", MLX_BUN_FILL: fill === "reject" ? "echo" : fill ?? "off" });
    try { return await run(); } finally { restore(); clearCache(); }
  };
  /** A matcher that reports each forced span it commits (none is expected on
   * the gateway, which verifies proposals instead). */
  const grammarFor = async (name: GrammarName, spans: number[][]) => {
    const compiled = await compileGrammarRequest(GRAMMARS[name].request, tokenizer, config.text.vocabSize);
    if (!compiled?.controller) throw new Error(`grammar ${name} did not compile: ${compiled?.degradeHint}`);
    const controller = compiled.controller, jump = controller.jumpForward.bind(controller);
    controller.jumpForward = (budget: number) => { const ids = jump(budget); if (ids) spans.push([...ids]); return ids; };
    return controller;
  };
  const controls = new Map<PromptName, number[]>();
  /** Fresh request options; a fill session is built from its prompt's fill-off control. */
  const optionsFor = async (request: Request, spans: number[][]) => {
    const prompt = prompts[request.prompt];
    if (request.grammar) {
      const { maxTokens } = GRAMMARS[request.grammar];
      return { prompt, options: { temperature: 0, maxTokens, eosTokenIds: config.eosTokenIds, prefillChunkSize: CHUNK,
        grammar: await grammarFor(request.grammar, spans) } as GenerateOptions };
    }
    const options = { temperature: 0, maxTokens: FILL_TOKENS, eosTokenIds: [] as number[], prefillChunkSize: CHUNK } as GenerateOptions;
    if (request.fill) {
      const control = controls.get(request.prompt);
      if (!control) throw new Error(`no fill-off control for ${request.prompt}`);
      // Besides the echo index, a proposal the model accepts (after 2 tokens).
      const scripted: ProposalSource = { name: "scripted-echo", propose: view =>
        view.length - prompt.length === 2 ? { ids: control.slice(2, 6), policy: "verify", origin: "echo" } : null };
      // One verify proposal whose last position the model rejects, with the ring wrapped.
      const rejected: ProposalSource = { name: "scripted-reject", propose: view =>
        view.length - prompt.length === 10 ? { ids: [...control.slice(10, 13), control[13]! + 1], policy: "verify", origin: "echo" } : null };
      options.fill = request.fill === "strict"
        ? new Session({ rows: [strictRow(prompt, control)], echo: null, eos: [] }, prompt, { maxSpan: 8, appendChunkSize: 0 })
        : request.fill === "reject"
          ? new Session({ rows: [], echo: null, eos: [] }, prompt, { maxSpan: 8, appendChunkSize: 0, sources: [rejected] })
          : new Session({ rows: [], echo: { k: 4, maxSpan: 8, maxCandidates: 24, indexMax: 131072 }, eos: [] }, prompt,
            { maxSpan: 8, appendChunkSize: 0, sources: [scripted] });
    }
    return { prompt, options };
  };
  /** The session was applied: strict rows committed tokens; echo proposals
   * reached a verify forward and some were accepted. */
  const checkFillApplied = (label: string, fill: FillSession | undefined) => {
    if (!fill) return;
    const { events, strict, verifyEvents, verifyAccepted, verifyUnsupported } = fill.stats;
    const applied: Record<string, boolean> = fill.plan.rows.length ? { events: events > 0, strict: strict > 0 }
      : { verifyEvents: verifyEvents > 0, verifyAccepted: verifyAccepted > 0 };
    expect({ label, applied, verifyUnsupported })
      .toEqual({ label, applied: Object.fromEntries(Object.keys(applied).map(key => [key, true])), verifyUnsupported: 0 });
  };

  /** Direct token-by-token generation, recorded at B1: grammar masking without
   * jump, or the fill-off control. */
  const direct = (request: Request) => under("grammar", undefined, async () => {
    const spans: number[][] = [];
    const { prompt, options } = await optionsFor({ prompt: request.prompt, grammar: request.grammar }, spans);
    try {
      const { value, forwards, projections } = await traced(true, async () => {
        const tokens: number[] = [];
        const generation = generate(model, prompt, { ...options, decodePolicy: { compiledDecode: false, grammarJump: false } });
        for await (const step of generation) tokens.push(step.token);
        return tokens;
      });
      return { tokens: value, spans, forwards, projections } satisfies Run;
    } finally { options.grammar?.dispose(); }
  });
  /** Direct generation with the request's supplied fill applied, recorded at B1. */
  const directFill = (request: Request) => under("fill", request.fill, async () => {
    const { prompt, options } = await optionsFor(request, []);
    const { value, forwards, projections } = await traced(true, async () => {
      const tokens: number[] = [];
      for await (const step of generate(model, prompt, { ...options, decodePolicy: { compiledDecode: false, grammarJump: false } }))
        tokens.push(step.token);
      return tokens;
    });
    return { run: { tokens: value, spans: [], forwards, projections } satisfies Run, fill: options.fill as FillSession };
  });
  const references = new Map<string, Promise<Run>>();
  /** Direct B1 references, each generated once: a grammar request's
   * token-by-token run, or a fill request's fill-off control. */
  const reference = (request: Request): Promise<Run> => {
    const key = JSON.stringify([request.prompt, request.grammar ?? null]);
    if (!references.has(key)) references.set(key, (async () => {
      const run = await direct(request);
      const prompt = prompts[request.prompt];
      checkTokenByToken(key, run, prompt);
      // Past the window: the ring wrapped before or during decode.
      assert(prompt.length + run.tokens.length > window + 1, `${key}: ${run.tokens.length} tokens stay within the window`);
      assert(run.forwards.some(forward => forward.state && "layers" in forward.state &&
        forward.state.layers.some(layer => layer.kind === "rotating" && layer.offset > window)), `${key}: no forward read a wrapped ring`);
      if (request.grammar) checkGrammarOutput(key, request.grammar, tokenizer.decode(run.tokens, true));
      else {
        if (run.tokens.length !== FILL_TOKENS) throw new Error(`${key}: the control ended after ${run.tokens.length} tokens`);
        controls.set(request.prompt, run.tokens);
      }
      return run;
    })());
    return references.get(key)!;
  };

  /** A gateway binding and its execution group under the scenario's runtime.
   * `prepare` builds a request's options (compiling its grammar) and returns
   * `start`, which places, binds and samples it as the app's gateway does and
   * submits it; `hold` holds admission so rows started together prefill together. */
  const gateway = <T>(shape: Shape, fill: FillMode | undefined, maxBatch: number, run: (lane: {
    prepare(request: Request, end?: { cancelAt?: number; onToken?: (emitted: number) => void }): Promise<{ start(): Promise<Outcome> }>;
    hold(held: boolean): void;
    drained(): Promise<void>;
  }) => Promise<T>) => under(shape, fill, async () => {
    const binding = bindMlxGateway(model);
    let held = false;
    const group = binding.createBatchGroup({ maxBatch, runtime: binding.runtime, prefillChunkSize: CHUNK, admissionHeld: () => held });
    const prepare = async (request: Request, end: { cancelAt?: number; onToken?: (emitted: number) => void } = {}) => {
      const spans: number[][] = [], tokens: number[] = [], abort = new AbortController();
      const { prompt, options } = await optionsFor(request, spans);
      const start = async (): Promise<Outcome> => {
        const shape = { hasVision: false, hasAdapters: false, hasRepetitionPenalty: false, userSeed: false, kvQuant: false,
          turboQuant: false, hasLogitsExtras: false, hasGrammar: !!options.grammar, wantsLogprobs: false, hasDraft: false };
        let sampling: ReturnType<typeof createRowSampling> | undefined;
        try {
          const execution = binding.plan(shape, options, { continuous: binding.cachesBatchable(), quantizedBatch: false, checkpoints: false });
          assert.equal(execution.mechanism, "continuous", `placement refused ${JSON.stringify(request)}: ${execution.reasons.join(", ")}`);
          const method = binding.methodRequest?.(execution, options);
          const sink = (token: number) => {
            tokens.push(token); end.onToken?.(tokens.length);
            if (tokens.length === end.cancelAt) abort.abort(new Error("client left"));
          };
          sampling = method ? undefined : createRowSampling(makeStepSampler(options, { tokenRepresentation: "device",
            grammarWait: "external", historyUpdate: "after-sample", initialHistory: prompt }), sink);
          await group.submit({ promptIds: prompt, prefillChunkSize: CHUNK, compiledDecode: execution.compiledDecode,
            maxTokens: options.maxTokens!, eosTokenIds: options.eosTokenIds!, cacheNamespace: "", signal: abort.signal,
            statePolicy: binding.statePolicy?.(execution, options, prompt.length + options.maxTokens!),
            ...(method ? { method, onToken: sink } : { sample: sampling!.sample, plainGreedy: sampling!.plainGreedy, onToken: sampling!.onToken }),
            ...(options.grammar ? { grammar: options.grammar } : {}) });
          return { tokens, spans, status: "fulfilled", fill: options.fill };
        } catch (error) { return { tokens, spans, status: "rejected", error, fill: options.fill }; }
        finally { sampling?.dispose(); options.grammar?.dispose(); }
      };
      return { start };
    };
    const drained = async () => {
      const deadline = Date.now() + 10_000;
      while (group.activeRows || group.pendingRows) {
        if (Date.now() > deadline) throw new Error("the group did not drain");
        await new Promise<void>(resolve => setImmediate(resolve));
      }
    };
    try { return await run({ prepare, hold: value => { held = value; if (!value) group.kick(); }, drained }); }
    finally { await group.close(); }
  });
  /** One request alone through the gateway, recorded at B1. */
  const alone = (shape: Shape, request: Request) => gateway(shape, request.fill, 1, async lane => {
    const { start } = await lane.prepare(request);
    const { value, forwards, projections } = await traced(true, start);
    assert.equal(value.status, "fulfilled", `gateway ${JSON.stringify(request)}: ${String(value.error)}`);
    checkFillApplied(`gateway ${JSON.stringify(request)}`, value.fill);
    return { tokens: value.tokens, spans: value.spans, forwards, projections } satisfies Run;
  });
  const b1 = new Map<string, Promise<Run>>();
  /** Each request's B1 run, generated once: direct generation for grammar;
   * a fresh gateway group, once its prompt's reference exists, for grammar
   * proposals and fill. */
  const single = (shape: Shape, request: Request): Promise<Run> => {
    if (shape === "grammar") return reference(request);
    const key = JSON.stringify([shape, request]);
    if (!b1.has(key)) b1.set(key, reference(request).then(() => alone(shape, request)));
    return b1.get(key)!;
  };
  return {
    prompts, reference, single, alone, directFill, gateway, traced, checkFillApplied,
    release() {
      graph.forwardHidden = forwardHidden; graph.logitsFromHidden = logitsFromHidden;
      releaseWeights();
    },
  };
}

describe.skipIf(!inputs)("sliding-window Universal grammar, grammar proposals and fill: the gateway against direct generation", () => {
  let env: Awaited<ReturnType<typeof setup>>;
  beforeAll(async () => { env = await setup(); }, 600_000);
  afterAll(() => { env?.release(); });

  const GRAMMAR_CASES: Request[] = [{ prompt: "long", grammar: "json" }, { prompt: "short", grammar: "json" },
    { prompt: "other", grammar: "ebnf" }, { prompt: "long", grammar: "choice" }];
  /** Two rows prepared together, and a joiner admitted after the first row's second token. */
  const GRAMMAR_PAIRS: { together: boolean; rows: [Request, Request] }[] = [
    { together: true, rows: [{ prompt: "long", grammar: "json" }, { prompt: "short", grammar: "json" }] },
    { together: false, rows: [{ prompt: "long", grammar: "json" }, { prompt: "other", grammar: "ebnf" }] },
  ];

  /** B2 rows each equal their B1 run in tokens and forced spans. */
  async function pairs(shape: Shape, cases: { together: boolean; rows: [Request, Request] }[]) {
    for (const { together, rows } of cases) {
      const expected = await Promise.all(rows.map(request => env.single(shape, request)));
      const label = `${shape} B2 ${together ? "together" : "late join"} ${JSON.stringify(rows)}`;
      const { value, forwards } = await env.gateway(shape, fillMode(rows), 2, async lane => {
        const second = await lane.prepare(rows[1]);
        const outcomes: Promise<Outcome>[] = [];
        const first = await lane.prepare(rows[0], together ? {} : { onToken: emitted => { if (emitted === 2) outcomes.push(second.start()); } });
        return env.traced(false, async () => {
          if (together) lane.hold(true);
          outcomes.push(first.start());
          if (together) { outcomes.push(second.start()); lane.hold(false); }
          for (let seen = 0; seen !== outcomes.length;) { seen = outcomes.length; await Promise.all(outcomes); }
          return Promise.all(outcomes);
        });
      });
      expect(value, `${label}: both rows ran`).toHaveLength(2);
      expect(forwards.some(forward => forward.B === 2), `${label}: the rows never shared a forward`).toBe(true);
      value.forEach((outcome, index) => {
        // Outcomes are in start order: the first row, then the second.
        expect({ label, index, status: outcome.status, error: String(outcome.error ?? "") })
          .toEqual({ label, index, status: "fulfilled", error: "" });
        expect({ label, index, tokens: outcome.tokens, spans: outcome.spans })
          .toEqual({ label, index, tokens: expected[index]!.tokens, spans: expected[index]!.spans });
        env.checkFillApplied(`${label} row ${index}`, outcome.fill);
      });
    }
  }

  test("grammar without jump: B1 equals direct generation in every step; B2 rows equal their B1 output", async () => {
    for (const request of GRAMMAR_CASES) {
      const label = `grammar ${JSON.stringify(request)}`;
      checkSameRun(label, await env.alone("grammar", request), await env.reference(request));
    }
    await pairs("grammar", GRAMMAR_PAIRS);
  }, 900_000);

  test("grammar jump verifies proposals: B1 and B2 equal direct token-by-token generation", async () => {
    let proposed = 0, accepted = 0;
    for (const request of GRAMMAR_CASES) {
      const label = `jump ${JSON.stringify(request)}`;
      const tokenwise = await env.reference(request), run = await env.single("jump", request);
      expect({ label, tokens: run.tokens, spans: run.spans }).toEqual({ label, tokens: tokenwise.tokens, spans: [] });
      const walked = walk(label, run, env.prompts[request.prompt]);
      proposed += walked.proposed; accepted += walked.accepted;
    }
    expect({ proposed: proposed > 0, accepted: accepted > 0, rejected: proposed > accepted }, "verified grammar proposals")
      .toEqual({ proposed: true, accepted: true, rejected: true });
    await pairs("jump", GRAMMAR_PAIRS);
  }, 900_000);

  test("supplied strict and echo fill are applied: B1 and B2 equal the fill-off control", async () => {
    // Every request also runs through direct generation, which applies the same
    // fill (a rejected proposal leaves the wrapped ring by the bypass trim).
    for (const prompt of ["long", "short"] as const) for (const fill of ["strict", "echo", "reject"] as const) {
      const request = { prompt, fill }, label = `fill ${JSON.stringify(request)}`;
      const control = await env.reference(request), gateway = await env.single("fill", request), direct = await env.directFill(request);
      for (const [path, run] of [["gateway", gateway], ["direct", direct.run]] as const) {
        expect({ label: `${label} ${path}`, tokens: run.tokens }).toEqual({ label: `${label} ${path}`, tokens: control.tokens });
        // Every forward continues the history; echo proposals reach verify forwards.
        const { proposed, accepted } = walk(`${label} ${path}`, run, env.prompts[prompt]);
        if (fill !== "strict") expect(proposed, `${label} ${path}: no verified position`).toBeGreaterThan(0);
        if (fill === "reject") expect(proposed, `${label} ${path}: no rejected position`).toBeGreaterThan(accepted);
      }
      env.checkFillApplied(`${label} direct`, direct.fill);
    }
    await pairs("fill", [{ together: true, rows: [{ prompt: "long", fill: "strict" }, { prompt: "short", fill: "echo" }] },
      { together: false, rows: [{ prompt: "other", fill: "echo" }, { prompt: "short", fill: "strict" }] }]);
  }, 900_000);

  test("a cancelled row leaves its peer equal to its B1 output, and the drained group serves the request again", async () => {
    const cases: [Shape, Request, Request][] = [
      ["grammar", { prompt: "long", grammar: "json" }, { prompt: "short", grammar: "json" }],
      ["jump", { prompt: "long", grammar: "json" }, { prompt: "short", grammar: "json" }],
      ["fill", { prompt: "long", fill: "strict" }, { prompt: "short", fill: "echo" }],
    ];
    for (const [shape, survivor, cancelled] of cases) {
      const label = `${shape} cancellation`;
      const kept = await env.single(shape, survivor), left = await env.single(shape, cancelled);
      assert(left.tokens.length > CANCEL_AT, `${label}: the cancelled request ends within ${CANCEL_AT} tokens`);
      const reused = await env.gateway(shape, fillMode([survivor, cancelled]), 2, async lane => {
        const peer = await lane.prepare(survivor), gone = await lane.prepare(cancelled, { cancelAt: CANCEL_AT });
        const { value: [kept2, left2], forwards } = await env.traced(false, async () => {
          lane.hold(true);
          const outcomes = [peer.start(), gone.start()];
          lane.hold(false);
          return Promise.all(outcomes);
        });
        expect(forwards.some(forward => forward.B === 2), `${label}: the rows never shared a forward`).toBe(true);
        expect({ label, status: left2!.status, error: String(left2!.error), tokens: left2!.tokens })
          .toEqual({ label, status: "rejected", error: "Error: client left", tokens: left.tokens.slice(0, CANCEL_AT) });
        expect({ label, status: kept2!.status, error: String(kept2!.error ?? ""), tokens: kept2!.tokens, spans: kept2!.spans })
          .toEqual({ label, status: "fulfilled", error: "", tokens: kept.tokens, spans: kept.spans });
        env.checkFillApplied(`${label} peer`, kept2!.fill);
        await lane.drained();
        // The same group serves the cancelled request again, alone.
        const again = await lane.prepare(cancelled);
        const { value, forwards: replayed, projections } = await env.traced(true, again.start);
        assert.equal(value.status, "fulfilled", `${label}: reuse ${String(value.error)}`);
        env.checkFillApplied(`${label} reuse`, value.fill);
        return { tokens: value.tokens, spans: value.spans, forwards: replayed, projections } satisfies Run;
      });
      checkSameRun(`${label} reuse`, reused, left);
    }
  }, 900_000);
});

// ---- CPU-only validation (no native libraries) ------------------------------------------
test("opt-in: none skips; a partial, blank or invalid opt-in fails (CPU only)", () => {
  expect(optIn({})).toBeNull();
  expect(() => optIn({ [MODEL]: "/m" })).toThrow(WINDOW);
  expect(() => optIn({ [WINDOW]: "8" })).toThrow(MODEL);
  expect(() => optIn({ [MODEL]: " ", [WINDOW]: "8" })).toThrow("missing or blank");
  for (const window of ["0", "3", "x", "-8", "8.5"]) expect(() => optIn({ [MODEL]: "/m", [WINDOW]: window })).toThrow("integer >= 4");
  expect(() => optIn({ [MODEL]: "/nonexistent-sliding-model", [WINDOW]: "8" })).toThrow("no config.json");
});

test("prompts bracket the window: two past it and a prefix below it (CPU only)", () => {
  const a = [1, 10, 11, 12], b = [1, 20, 21];
  const { long, other, short } = planPrompts(a, b, 8);
  expect(long).toEqual([1, 10, 11, 12, 10, 11, 12, 10, 11, 12]);
  expect(other).toEqual([1, 20, 21, 20, 21, 20, 21, 20, 21]);
  expect(short).toEqual([1, 10, 11, 12]);
  expect(planPrompts(a, b, 8)).toEqual({ long, other, short });
  const wide = planPrompts(a, b, 32);
  expect([wide.long.length > 32, wide.other.length > 32, wide.short.length]).toEqual([true, true, 4]);
});

const state = (offset: number, c = "a"): RowState => ({ offset, layers: [{ kind: "rotating", offset,
  keys: { shape: [1, 1, Math.min(offset, 2), 2], dtype: "bfloat16", sha: c.repeat(64) },
  values: { shape: [1, 1, Math.min(offset, 2), 2], dtype: "bfloat16", sha: c.repeat(64) } }] });
const projection = (c = "e", L = 1): Projection => ({ B: 1, L, dtype: "bfloat16", rows: Array(L).fill(c.repeat(64)) });
/** Prompt [10, 11, 12], tokens 1, 2, 3, 4: proposals [1, 9] after the prompt
 * (1 accepted, 9 rejected), then [3, 4] after 2 (both accepted). */
const verifyRun = (): Run => ({ tokens: [1, 2, 3, 4], spans: [], forwards: [
  { B: 1, L: 2, ids: [[10, 11]], state: null },
  { B: 1, L: 3, ids: [[12, 1, 9]], state: state(2) },
  { B: 1, L: 3, ids: [[2, 3, 4]], state: state(4) },
], projections: [projection("p", 3), projection("q", 3)] });
const tokenRun = (): Run => ({ tokens: [1, 2, 3], spans: [], forwards: [
  { B: 1, L: 2, ids: [[10, 11]], state: null }, { B: 1, L: 1, ids: [[12]], state: state(2) },
  { B: 1, L: 1, ids: [[1]], state: state(3) }, { B: 1, L: 1, ids: [[2]], state: state(4) },
], projections: [projection("p"), projection("q"), projection("r")] });
const PROMPT = [10, 11, 12];

test("the B1 comparison allows one discarded lookahead step and nothing else (CPU only)", () => {
  expect(() => checkSameRun("same", tokenRun(), tokenRun())).not.toThrow();
  const lookahead = tokenRun();
  lookahead.forwards.push({ B: 1, L: 1, ids: [[3]], state: state(5) }); lookahead.projections.push(projection("s"));
  expect(() => checkSameRun("lookahead", lookahead, tokenRun())).not.toThrow();
  const rejects = (change: (run: Run) => void, message: string) => {
    const run = tokenRun(); change(run);
    expect(() => checkSameRun("changed", run, tokenRun())).toThrow(message);
  };
  rejects(run => { run.tokens[2] = 9; }, "tokens");
  rejects(run => { run.spans.push([7]); }, "forced spans");
  rejects(run => { run.projections[1] = projection("x"); }, "projections 1");
  rejects(run => { run.forwards[3]!.state = state(4, "b"); }, "forwards 3");
  rejects(run => { run.forwards[2]!.state = { unreadable: "unsupported cache" }; }, "forwards 2");
  rejects(run => { run.forwards.pop(); }, "forwards 3");
  rejects(run => { run.forwards.push({ B: 1, L: 1, ids: [[3]], state: null }, { B: 1, L: 1, ids: [[9]], state: null }); }, "2 forwards past");
  rejects(run => { run.forwards.push({ B: 1, L: 2, ids: [[3, 9]], state: null }); }, "1 forwards past");
  rejects(run => { run.projections.push(projection("s", 2)); }, "1 projections past");
});

test("walks count verified proposals and keep only the accepted prefix; token-by-token runs verify none (CPU only)", () => {
  expect(walk("verify", verifyRun(), PROMPT)).toEqual({ decode: [[2, 3, 4]], proposed: 4, accepted: 3 });
  expect(walk("tokens", tokenRun(), PROMPT)).toEqual({ decode: [[1], [2]], proposed: 0, accepted: 0 });
  expect(() => checkTokenByToken("tokens", tokenRun(), PROMPT)).not.toThrow();
  const rejects = (make: () => Run, change: (run: Run) => void, check: (run: Run) => unknown, message: string) => {
    const run = make(); change(run); expect(() => check(run)).toThrow(message);
  };
  const walked = (run: Run) => walk("verify", run, PROMPT), tokens = (run: Run) => checkTokenByToken("tokens", run, PROMPT);
  // A rejected proposal is not in the cache: the next forward must not skip past it.
  rejects(verifyRun, run => { run.forwards[2]!.ids = [[3, 4]]; run.forwards[2]!.L = 2; }, walked, "forward 2 does not continue the history at 4");
  rejects(verifyRun, run => { run.forwards[0]!.ids = [[10, 99]]; }, walked, "forward 0 does not continue the history at 0");
  rejects(verifyRun, run => { run.forwards[1]!.B = 2; }, walked, "forward 1 is not one row");
  rejects(verifyRun, run => { run.forwards[1]!.ids = [[12, 1]]; }, walked, "forward 1 is not one row");
  rejects(verifyRun, () => {}, tokens, "4 positions were verified");
  rejects(tokenRun, run => { run.spans = [[2]]; }, tokens, "forced a span");
  rejects(tokenRun, run => { run.forwards.splice(2, 2, { B: 1, L: 2, ids: [[1, 2]], state: null }); }, tokens, "1 positions were verified");
  rejects(tokenRun, run => { run.projections[1] = projection("q", 2); }, tokens, "projection 1 covers 1x2");
});

test("grammar outputs and strict rows (CPU only)", () => {
  expect(() => checkGrammarOutput("json", "json", '{"city":"Kyoto","rating":5}')).not.toThrow();
  expect(() => checkGrammarOutput("json", "json", '{"city":"Kyoto","rating":6}')).toThrow("rating");
  expect(() => checkGrammarOutput("json", "json", '{"city":"Kyoto"')).toThrow();
  expect(() => checkGrammarOutput("choice", "choice", "Lisbon")).not.toThrow();
  expect(() => checkGrammarOutput("choice", "choice", "Rome")).toThrow("not a choice");
  expect(() => checkGrammarOutput("ebnf", "ebnf", "yes, ok")).not.toThrow();
  expect(() => checkGrammarOutput("ebnf", "ebnf", "maybe, ok")).toThrow("EBNF");
  // The first t >= 4 is taken unless an occurrence of its pair, including one
  // starting at the prompt's last token, is followed by other tokens.
  expect(strictRow([0, 9], [1, 2, 3, 1, 2, 6, 7, 8, 9, 10, 11], 2)).toEqual({ trigger: [2, 6], emit: [7, 8], kind: "scaffold" });
  expect(strictRow([0, 3], [4, 20, 21, 3, 4, 5, 6, 7, 8], 2)).toEqual({ trigger: [4, 5], emit: [6, 7], kind: "scaffold" });
  // A repeating control: every occurrence continues the same way.
  expect(strictRow([0, 9], [5, 6, 7, 5, 6, 7, 5, 6, 7, 5, 6, 7], 2)).toEqual({ trigger: [5, 6], emit: [7, 5], kind: "scaffold" });
  expect(() => strictRow([0, 9], [1, 2, 3, 4, 5])).toThrow("no usable strict trigger");
});
