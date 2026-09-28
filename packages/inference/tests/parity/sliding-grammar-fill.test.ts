// Grammar and supplied fill on a sliding-window Universal graph, on real weights,
// through the gateway's real placement path and through direct generation.
//
// Main served a Universal descriptor with sliding layers serially
// (`02d723a:src/backends/mlx/gateway-binding.ts`: `cachesBatchable` is false),
// so every request, alone or concurrent, ran main's direct generation
// (`02d723a:src/generate.ts`) under its serial plan: compiled decode as planned
// (off here), jump-forward when MLX_BUN_GRAMMAR_JUMP=1, and the supplied fill
// session for unseeded requests. This tree serves these graphs continuously.
// Its direct generation keeps main's serial semantics and is the reference;
// the gateway path is the binding's plan, then methodRequest or row sampling,
// then the binding's execution group, composed as the app's generation gateway
// composes them. Comparisons against main's own tree remain external. Every
// case runs past the sliding window. Checked:
// - Grammar (JSON schema, choice, EBNF) without jump: at B1 the gateway equals
//   direct generation in tokens, every forward (IDs and the row's valid K/V
//   before it) and every projection's complete logits; the scheduler may add
//   one discarded single-token lookahead step. Rows prepared together or
//   joining late (B2) each equal their B1 direct output, as main's serial lane
//   produced them one at a time.
// - Grammar with MLX_BUN_GRAMMAR_JUMP=1: main's serial jump commits each forced
//   span returned by the matcher with one unsplit [token, ...span] forward,
//   never samples it, and projects one position per step. Direct generation
//   must show exactly that, against the token-by-token run, which never jumps
//   and forwards one decode position at a time; both outputs satisfy the
//   grammar. The gateway must equal the direct jump run at B1 in tokens, forced
//   spans, forwards and projections, and at B2 in tokens and forced spans. As
//   in main's own consumer (`02d723a:tests/parity/grammar-jump.test.ts`), jump
//   and token-by-token output are not required to be equal: a forced span's
//   retokenization may legally differ from sampled tokens.
// - Supplied fill (strict assert rows; echo verify proposals), with MLX_BUN_FILL
//   set: main's generation skips token fast-forwarding whenever a cache is a
//   RotatingKVCache, so the session is never consulted. Runs with fill, direct
//   and through the gateway, must equal the fill-off control (B1: tokens,
//   forwards and projections; B2: tokens), and every session's statistics stay
//   untouched.
// - For each of those three shapes, a B2 group in which one row is cancelled at
//   its third token: it emits exactly those three tokens (main's generation
//   checks the signal after every token) and rejects with the cancellation;
//   its peer runs to its end equal to its B1 direct output; the drained group
//   then serves the cancelled request again, equal to direct generation at B1
//   in everything above.
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

/** Each B1 forward continues prompt + tokens; returns the decode forwards (those
 * starting at or after the prompt's end). Every projection covers one position. */
function walk(label: string, run: Run, prompt: readonly number[]) {
  const history = [...prompt, ...run.tokens], decode: number[][] = [];
  let cursor = 0;
  run.forwards.forEach((forward, index) => {
    const ids = forward.ids[0]!;
    assert(forward.B === 1 && forward.ids.length === 1 && ids.length === forward.L, `${label}: forward ${index} is not one row`);
    assert.deepEqual(ids, history.slice(cursor, cursor + ids.length), `${label}: forward ${index} does not continue the history at ${cursor}`);
    if (cursor >= prompt.length) decode.push(ids);
    cursor += ids.length;
  });
  run.projections.forEach((projection, index) =>
    assert(projection.B === 1 && projection.L === 1, `${label}: projection ${index} covers ${projection.B}x${projection.L} positions`));
  return decode;
}

/** Main's serial jump in one B1 run: the k-th forced span follows the token
 * sampled before it in exactly one unsplit [token, ...span] decode forward (the
 * k-th multi-position one), and is emitted right after it; any other decode
 * forward carries one position and no forced token is projected. Returns the
 * number of forced tokens. */
export function checkCommittedSpans(label: string, run: Run, prompt: readonly number[]): number {
  const wide = walk(label, run, prompt).filter(ids => ids.length > 1);
  assert.equal(wide.length, run.spans.length, `${label}: ${wide.length} multi-position decode forwards for ${run.spans.length} forced spans`);
  run.spans.forEach((span, k) => {
    assert(span.length > 0, `${label}: empty forced span ${k}`);
    assert.deepEqual(wide[k]!.slice(1), span, `${label}: forced span ${k} is not committed by one [token, ...span] forward`);
  });
  return run.spans.reduce((sum, span) => sum + span.length, 0);
}

/** The token-by-token run: no forced span and one position per decode forward. */
export function checkTokenByToken(label: string, run: Run, prompt: readonly number[]): void {
  assert.equal(run.spans.length, 0, `${label}: the token-by-token run forced a span`);
  const wide = walk(label, run, prompt).filter(ids => ids.length !== 1);
  assert.equal(wide.length, 0, `${label}: ${wide.length} decode forwards carry more than one position`);
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

/** A strict assert row that would fire exactly once if the session were
 * consulted: its trigger is the control's pair (control[t-1], control[t]) at the
 * first t >= 4 where that pair ends no earlier position of the session's history
 * (the prompt's last token, then the control), and its fixed emit differs from
 * what the control generated next. */
export function strictRow(prompt: readonly number[], control: readonly number[], emit: readonly number[]) {
  const history = [prompt.at(-1)!, ...control];
  const t = control.findIndex((_, t) => t >= 4 && t + emit.length < control.length &&
    !history.slice(0, t).some((token, i) => token === control[t - 1] && history[i + 1] === control[t]));
  if (t < 0) throw new Error(`the control (${control.length} tokens) has no usable strict trigger`);
  assert.notDeepEqual([...emit], control.slice(t + 1, t + 1 + emit.length), "the strict emit equals the control's continuation");
  return { trigger: [control[t - 1]!, control[t]!], emit: [...emit], kind: "scaffold" as const };
}

// ---- real weights ------------------------------------------------------------------------
const inputs = optIn(Bun.env);

type Shape = "grammar" | "jump" | "fill";
type FillMode = "strict" | "echo";
interface Request { prompt: PromptName; grammar?: GrammarName; fill?: FillMode }
interface Outcome { tokens: number[]; spans: number[][]; status: "fulfilled" | "rejected"; error?: unknown; fill?: FillSession }
/** The graph operations the recorder wraps. */
interface Graph { forwardHidden(ids: MlxArray, caches: Cache[]): MlxArray; logitsFromHidden(hidden: MlxArray): MlxArray; args?: WindowDescriptor }
/** MLX_BUN_FILL for a set of rows: echo is additive to strict. */
const fillMode = (rows: readonly Request[]): FillMode | undefined =>
  rows.some(row => row.fill === "echo") ? "echo" : rows.some(row => row.fill === "strict") ? "strict" : undefined;

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
      MLX_BUN_GRAMMAR_JUMP: shape === "jump" ? "1" : "0", MLX_BUN_FILL: fill ?? "off" });
    try { return await run(); } finally { restore(); clearCache(); }
  };
  /** A matcher that reports each forced span it returns. */
  const grammarFor = async (name: GrammarName, spans: number[][]) => {
    const compiled = await compileGrammarRequest(GRAMMARS[name].request, tokenizer, config.text.vocabSize);
    if (!compiled?.controller) throw new Error(`grammar ${name} did not compile: ${compiled?.degradeHint}`);
    const controller = compiled.controller, jump = controller.jumpForward.bind(controller);
    controller.jumpForward = (budget: number) => { const ids = jump(budget); if (ids) spans.push([...ids]); return ids; };
    return controller;
  };
  const controls = new Map<PromptName, number[]>();
  const emit = tokenizer.encode(" (a fixed scaffold span)", false).slice(0, 4);
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
      // Echo proposals the model would accept (at 2) and reject (at 7), if consulted.
      const wrong = (token: number) => [2000, 2001].find(id => id !== token)!;
      const script = new Map([[2, control.slice(2, 6)], [7, [wrong(control[7]!), control[8]!]]]);
      const scripted: ProposalSource = { name: "scripted-echo", propose: view => {
        const ids = script.get(view.length - prompt.length);
        return ids ? { ids: [...ids], policy: "verify", origin: "echo" } : null;
      } };
      options.fill = request.fill === "strict"
        ? new Session({ rows: [strictRow(prompt, control, emit)], echo: null, eos: [] }, prompt, { maxSpan: 8, appendChunkSize: 0 })
        : new Session({ rows: [], echo: { k: 4, maxSpan: 8, maxCandidates: 24, indexMax: 131072 }, eos: [] }, prompt,
          { maxSpan: 8, appendChunkSize: 0, sources: [scripted] });
    }
    return { prompt, options };
  };
  const untouched = JSON.stringify(new Session({ rows: [], echo: null, eos: [] }, [1]).stats);
  /** Main never consulted a supplied session on these graphs. */
  const checkFillUntouched = (label: string, fill: FillSession | undefined) => {
    if (fill) expect(JSON.stringify(fill.stats), `${label}: fill session statistics`).toBe(untouched);
  };

  /** Main's serial path: direct generation under the serial plan, recorded at B1. */
  const direct = (shape: Shape, request: Request) => under(shape, request.fill, async () => {
    const spans: number[][] = [];
    const { prompt, options } = await optionsFor(request, spans);
    try {
      const { value, forwards, projections } = await traced(true, async () => {
        const tokens: number[] = [];
        const generation = generate(model, prompt, { ...options,
          decodePolicy: { compiledDecode: false, grammarJump: shape === "jump" && !!options.grammar } });
        for await (const step of generation) tokens.push(step.token);
        return tokens;
      });
      checkFillUntouched(`direct ${JSON.stringify(request)}`, options.fill);
      return { tokens: value, spans, forwards, projections } satisfies Run;
    } finally { options.grammar?.dispose(); }
  });
  const references = new Map<string, Promise<Run>>();
  /** Direct B1 references, each generated once; a fill request's reference is
   * its prompt's fill-off control. */
  const reference = (shape: Shape, request: Request): Promise<Run> => {
    const key = JSON.stringify([shape === "fill" ? "fill-off" : shape, request.prompt, request.grammar ?? null]);
    if (!references.has(key)) references.set(key, (async () => {
      const run = await direct(shape, { prompt: request.prompt, grammar: request.grammar });
      const prompt = prompts[request.prompt];
      // Past the window: the ring wrapped before or during decode.
      assert(prompt.length + run.tokens.length > window + 1, `${key}: ${run.tokens.length} tokens stay within the window`);
      assert(run.forwards.some(forward => forward.state && "layers" in forward.state &&
        forward.state.layers.some(layer => layer.kind === "rotating" && layer.offset > window)), `${key}: no forward read a wrapped ring`);
      if (request.grammar) checkGrammarOutput(key, request.grammar, tokenizer.decode(run.tokens, true));
      if (shape === "fill") {
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
    checkFillUntouched(`gateway ${JSON.stringify(request)}`, value.fill);
    return { tokens: value.tokens, spans: value.spans, forwards, projections } satisfies Run;
  });
  return {
    prompts, reference, direct, alone, gateway, traced, checkFillUntouched,
    release() {
      graph.forwardHidden = forwardHidden; graph.logitsFromHidden = logitsFromHidden;
      releaseWeights();
    },
  };
}

describe.skipIf(!inputs)("sliding-window Universal grammar and fill preserve main's serial generation", () => {
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

  /** B2 rows each equal their B1 direct reference in tokens and forced spans. */
  async function pairs(shape: Shape, cases: { together: boolean; rows: [Request, Request] }[]) {
    for (const { together, rows } of cases) {
      const expected = await Promise.all(rows.map(request => env.reference(shape, request)));
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
        env.checkFillUntouched(`${label} row ${index}`, outcome.fill);
      });
    }
  }

  test("grammar without jump: B1 equals main's serial generation in every step; B2 rows equal their B1 output", async () => {
    for (const request of GRAMMAR_CASES) {
      const expected = await env.reference("grammar", request);
      checkTokenByToken(`grammar ${JSON.stringify(request)}`, expected, env.prompts[request.prompt]);
      checkSameRun(`grammar ${JSON.stringify(request)}`, await env.alone("grammar", request), expected);
    }
    await pairs("grammar", GRAMMAR_PAIRS);
  }, 900_000);

  test("grammar jump commits forced spans as main's serial jump did, at B1 in every step and at B2", async () => {
    let forced = 0;
    for (const request of GRAMMAR_CASES) {
      const label = `jump ${JSON.stringify(request)}`;
      const jump = await env.reference("jump", request), tokenwise = await env.reference("grammar", request);
      // Direct generation is main's serial jump; the token-by-token run never jumps.
      forced += checkCommittedSpans(label, jump, env.prompts[request.prompt]);
      checkTokenByToken(`grammar ${JSON.stringify(request)}`, tokenwise, env.prompts[request.prompt]);
      checkSameRun(label, await env.alone("jump", request), jump);
    }
    expect(forced, "no case forced a span").toBeGreaterThan(0);
    await pairs("jump", GRAMMAR_PAIRS);
  }, 900_000);

  test("supplied strict and echo fill are ignored as on main's serial path: B1 and B2 equal the fill-off control", async () => {
    for (const prompt of ["long", "short"] as const) for (const fill of ["strict", "echo"] as const) {
      const request = { prompt, fill }, control = await env.reference("fill", request);
      checkTokenByToken(`fill-off ${prompt}`, control, env.prompts[prompt]);
      // Main's serial executor handed the session to generation, which skipped it.
      checkSameRun(`direct fill ${JSON.stringify(request)}`, await env.direct("fill", request), control);
      checkSameRun(`gateway fill ${JSON.stringify(request)}`, await env.alone("fill", request), control);
    }
    await pairs("fill", [{ together: true, rows: [{ prompt: "long", fill: "strict" }, { prompt: "short", fill: "echo" }] },
      { together: false, rows: [{ prompt: "long", fill: "echo" }, { prompt: "short", fill: "strict" }] }]);
  }, 900_000);

  test("a cancelled row leaves its peer equal to main's serial output, and the drained group serves the request again", async () => {
    const cases: [Shape, Request, Request][] = [
      ["grammar", { prompt: "long", grammar: "json" }, { prompt: "short", grammar: "json" }],
      ["jump", { prompt: "long", grammar: "json" }, { prompt: "short", grammar: "json" }],
      ["fill", { prompt: "long", fill: "strict" }, { prompt: "short", fill: "echo" }],
    ];
    for (const [shape, survivor, cancelled] of cases) {
      const label = `${shape} cancellation`;
      const kept = await env.reference(shape, survivor), left = await env.reference(shape, cancelled);
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
        env.checkFillUntouched(`${label} peer`, kept2!.fill);
        await lane.drained();
        // The same group serves the cancelled request again, alone.
        const again = await lane.prepare(cancelled);
        const { value, forwards: replayed, projections } = await env.traced(true, again.start);
        assert.equal(value.status, "fulfilled", `${label}: reuse ${String(value.error)}`);
        env.checkFillUntouched(`${label} reuse`, value.fill);
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
/** Prompt [10, 11, 12], tokens 1, 2, 3, 4 with a forced span [2, 3] after 1. */
const jumpRun = (): Run => ({ tokens: [1, 2, 3, 4], spans: [[2, 3]], forwards: [
  { B: 1, L: 2, ids: [[10, 11]], state: null },
  { B: 1, L: 1, ids: [[12]], state: state(2) },
  { B: 1, L: 3, ids: [[1, 2, 3]], state: state(3) },
], projections: [projection("p"), projection("q")] });
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

test("committed spans are one unsplit forward each and never projected; token-by-token runs never jump (CPU only)", () => {
  expect(checkCommittedSpans("jump", jumpRun(), PROMPT)).toBe(2);
  expect(() => checkTokenByToken("tokens", tokenRun(), PROMPT)).not.toThrow();
  const rejects = (make: () => Run, change: (run: Run) => void, check: (run: Run) => unknown, message: string) => {
    const run = make(); change(run); expect(() => check(run)).toThrow(message);
  };
  const spans = (run: Run) => checkCommittedSpans("jump", run, PROMPT), tokens = (run: Run) => checkTokenByToken("tokens", run, PROMPT);
  // Verified proposals: the span split from its token, or every position projected.
  rejects(jumpRun, run => { run.forwards.splice(2, 1, { B: 1, L: 1, ids: [[1]], state: null }, { B: 1, L: 2, ids: [[2, 3]], state: null }); },
    spans, "forced span 0 is not committed");
  rejects(jumpRun, run => { run.projections[1] = projection("q", 3); }, spans, "projection 1 covers 1x3");
  rejects(jumpRun, run => { run.spans = []; }, spans, "1 multi-position decode forwards for 0 forced spans");
  rejects(jumpRun, run => { run.forwards[2]!.ids = [[1, 3, 2]]; }, spans, "does not continue the history");
  rejects(jumpRun, run => { run.forwards[1]!.B = 2; }, spans, "forward 1 is not one row");
  rejects(tokenRun, run => { run.spans = [[2]]; }, tokens, "forced a span");
  rejects(tokenRun, run => { run.forwards.splice(2, 2, { B: 1, L: 2, ids: [[1, 2]], state: null }); }, tokens, "1 decode forwards carry");
});

test("grammar outputs, strict rows and the fill statistics check (CPU only)", () => {
  expect(() => checkGrammarOutput("json", "json", '{"city":"Kyoto","rating":5}')).not.toThrow();
  expect(() => checkGrammarOutput("json", "json", '{"city":"Kyoto","rating":6}')).toThrow("rating");
  expect(() => checkGrammarOutput("json", "json", '{"city":"Kyoto"')).toThrow();
  expect(() => checkGrammarOutput("choice", "choice", "Lisbon")).not.toThrow();
  expect(() => checkGrammarOutput("choice", "choice", "Rome")).toThrow("not a choice");
  expect(() => checkGrammarOutput("ebnf", "ebnf", "yes, ok")).not.toThrow();
  expect(() => checkGrammarOutput("ebnf", "ebnf", "maybe, ok")).toThrow("EBNF");
  // The first t >= 4 is taken unless its pair already occurred: here (1, 2) ends
  // an earlier position, so t = 4 is skipped for (2, 6) at t = 5.
  const control = [1, 2, 3, 1, 2, 6, 7, 8, 9, 10, 11];
  expect(strictRow([0, 9], [3, 4, 5, 6, 7, 8, 9, 10, 11, 12], [50, 51])).toEqual({ trigger: [6, 7], emit: [50, 51], kind: "scaffold" });
  expect(strictRow([0, 9], control, [50, 51])).toEqual({ trigger: [2, 6], emit: [50, 51], kind: "scaffold" });
  expect(() => strictRow([0, 9], control, [7, 8])).toThrow("equals the control's continuation");
  expect(() => strictRow([0, 9], [1, 2, 3, 4, 5], [50, 51])).toThrow("no usable strict trigger");
});
