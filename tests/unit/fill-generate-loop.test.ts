// Token fast-forwarding through the REAL generate() decode loop (K3a).
//
// Model-free but not MLX-free: a stub RuntimeModel drives the actual loop with
// real MLX arrays, caches, and sampler, so the append mechanism is exercised
// end to end — including the invariant that makes it safe.
//
// THE INVARIANT. The fill forward carries ONLY the injected ids: the normal
// step already consumed the trigger token and wrote its KV. Forwarding
// [trigger, ...ids] would duplicate a position and silently corrupt both the
// cache and PromptCache.put's key. `model.forwards` records every id sequence
// the loop pushed through the model, so the test can see it directly.
import { describe, expect, test } from "bun:test";
import { generate, type GenerateOptions, type GenerateStats } from "../../src/generate";
import {
  FillSession, type FillRow, type Proposal, type ProposalSource,
} from "../../src/fill/fill-session";
import { KVCache, type Cache } from "../../src/model/gemma4";
import type { RuntimeModel } from "../../src/model/factory";
import { MlxArray } from "../../src/mlx/array";
import { configureRuntime } from "../../src/runtime-config";

const VOCAB = 128;
const EOS = 2;
const PROMPT = [1, 41, 42];
/** The trigger the stub emits at step 0, and the span a row fills after it. */
const TRIGGER = 7;
const SPAN = [11, 12, 13];
/** Sampled at the trigger's own forward and DISCARDED by the fill — an
 *  in-flight pipeline dispatch, never inspected. It must never be emitted. */
const WASTED = 61;

/** last forwarded id → next greedy token. */
const SCRIPT = new Map<number, number>([
  [42, TRIGGER],   // end of prompt → open the "tool call"
  [TRIGGER, WASTED],
  [13, 20],        // after the injected span
  [20, EOS],
]);

class StubModel {
  constructor(
    readonly script: Map<number, number> = SCRIPT,
    private readonly makeCacheImpl: () => Cache[] = () => [new KVCache()],
  ) {}

  readonly config = {
    eosTokenIds: [EOS],
    modelType: "stub-fill",
    text: { vocabSize: VOCAB, enableMoeBlock: false },
  };
  readonly weightsBytes = 1;
  /** Every id sequence pushed through forwardHidden, in order. */
  readonly forwards: number[][] = [];

  makeCache(): Cache[] {
    return this.makeCacheImpl();
  }

  forwardHidden(ids: MlxArray, cache: Cache[]): MlxArray {
    const list = ids.toIntTokens();
    this.forwards.push(list);
    const L = list.length;
    const k = MlxArray.fromFloat32(new Float32Array(L * 4), [1, 1, L, 4]);
    const v = MlxArray.fromFloat32(new Float32Array(L * 4), [1, 1, L, 4]);
    const [outK, outV] = cache[0]!.updateAndFetch(k, v);
    for (const a of [k, v, outK, outV]) a.dispose();
    // The "hidden state" carries each position's token id, so logits can be
    // produced PER POSITION — which is what the verify policy reads.
    return MlxArray.fromFloat32(Float32Array.from(list), [1, L, 1]);
  }

  logitsFromHidden(hidden: MlxArray): MlxArray {
    const ids = hidden.toFloat32Host();
    const rows = new Float32Array(ids.length * VOCAB);
    for (let j = 0; j < ids.length; j++)
      rows[j * VOCAB + (this.script.get(Math.round(ids[j]!)) ?? EOS)!] = 10;
    return MlxArray.fromFloat32(rows, [1, ids.length, VOCAB]);
  }
}

const row = (trigger: number[], emit: number[]): FillRow =>
  ({ trigger, emit, kind: "scaffold" });

const session = (rows: FillRow[], maxSpan?: number) =>
  new FillSession(
    { rows, echo: null, eos: [EOS] },
    PROMPT,
    maxSpan === undefined ? {} : { maxSpan },
  );

async function run(
  options: GenerateOptions,
  breakAfter = Number.POSITIVE_INFINITY,
  model: StubModel = new StubModel(),
): Promise<{ model: StubModel; tokens: number[]; stats: GenerateStats }> {
  const gen = generate(
    model as unknown as RuntimeModel,
    PROMPT,
    { temperature: 0, maxTokens: 32, ...options },
  );
  const tokens: number[] = [];
  for await (const t of gen) {
    tokens.push(t.token);
    if (tokens.length >= breakAfter) break;
  }
  return { model, tokens, stats: gen.stats! };
}

const withFill = async <T>(env: Record<string, string | undefined>, fn: () => Promise<T>) => {
  const restore = configureRuntime(env as never);
  try { return await fn(); } finally { restore(); }
};

describe("generate(): the fill append", () => {
  test("injected tokens stream in order and the discarded sample never appears", async () => {
    const fill = session([row([TRIGGER], SPAN)]);
    const { model, tokens, stats } = await withFill(
      { MLX_BUN_FILL: "strict" }, () => run({ fill }));
    expect(tokens).toEqual([TRIGGER, ...SPAN, 20]);
    expect(tokens).not.toContain(WASTED);
    // ONE forward carried the whole span — that is the entire point.
    expect(model.forwards).toEqual([
      [1, 41], [42],       // prefill (mlx-lm's drain-to-len-1 + L=1 step 0)
      [TRIGGER],           // ordinary decode step
      SPAN,                // the fill: injected ids ONLY, never [TRIGGER, ...SPAN]
      [20], [EOS],
    ]);
    expect(stats.cacheTokens).toEqual([...PROMPT, TRIGGER, ...SPAN, 20, EOS]);
    expect(stats.generatedTokens).toBe(6); // 5 emitted + the unyielded EOS
  });

  test("telemetry: events, injected tokens, discarded samples, real decode steps", async () => {
    const fill = session([row([TRIGGER], SPAN)]);
    const { stats } = await withFill({ MLX_BUN_FILL: "strict" }, () => run({ fill }));
    expect(stats.fill).toMatchObject({
      events: 1, injected: 3, strict: 3, echo: 0,
      spanLens: [3], wastedSamples: 1, parseFallback: 0,
    });
    // decodeSteps counts the SAMPLED tokens the session saw: the trigger and
    // 20. A terminal EOS stops the loop before the fill hook, by design.
    expect(stats.fill!.decodeSteps).toBe(2);
  });

  test("MLX_BUN_FILL unset: the same request decodes every token", async () => {
    const fill = session([row([TRIGGER], SPAN)]);
    const { model, tokens, stats } = await withFill(
      { MLX_BUN_FILL: undefined }, () => run({ fill }));
    expect(tokens).toEqual([TRIGGER, WASTED]); // WASTED → not in SCRIPT → EOS
    expect(model.forwards).toEqual([[1, 41], [42], [TRIGGER], [WASTED], [EOS]]);
    expect(stats.fill).toBeUndefined();
  });

  test("MLX_BUN_FILL_TRACE=1 asserts cache alignment on both sides of the append", async () => {
    const fill = session([row([TRIGGER], SPAN)]);
    const { tokens } = await withFill(
      { MLX_BUN_FILL: "strict", MLX_BUN_FILL_TRACE: "1" }, () => run({ fill }));
    expect(tokens).toEqual([TRIGGER, ...SPAN, 20]);
  });

  test("max_tokens clamps the span; the burst never overshoots the budget", async () => {
    const fill = session([row([TRIGGER], SPAN)]);
    const { model, tokens, stats } = await withFill(
      { MLX_BUN_FILL: "strict" }, () => run({ fill, maxTokens: 3 }));
    expect(tokens).toEqual([TRIGGER, 11, 12]);
    expect(stats.generatedTokens).toBe(3);
    expect(model.forwards).toEqual([[1, 41], [42], [TRIGGER], [11, 12]]);
    expect(stats.fill!.injected).toBe(2);
  });

  test("MLX_BUN_FILL_MAX_SPAN caps one injection", async () => {
    const fill = session([row([TRIGGER], SPAN)], 2);
    const { tokens } = await withFill({ MLX_BUN_FILL: "strict" }, () => run({ fill }));
    // 11,12 injected; the next sample comes from position 12 → not scripted → EOS.
    expect(tokens).toEqual([TRIGGER, 11, 12]);
  });

  test("a consumer break mid-burst leaves cacheTokens exact (the append precedes the yields)", async () => {
    const fill = session([row([TRIGGER], SPAN)]);
    const { stats } = await withFill(
      { MLX_BUN_FILL: "strict" }, () => run({ fill }, 2));
    // Broke after the 2nd emitted token, but the whole span's KV is committed.
    expect(stats.cacheTokens).toEqual([...PROMPT, TRIGGER, ...SPAN]);
  });

  test("an EOS inside a row is never injected — ending the turn stays the model's call", async () => {
    const fill = session([row([TRIGGER], [11, EOS, 12, 13])]);
    const { model, tokens } = await withFill(
      { MLX_BUN_FILL: "strict" }, () => run({ fill }));
    // Only one id survives the EOS cut → below the 2-token floor → no fill.
    expect(tokens).toEqual([TRIGGER, WASTED]);
    expect(model.forwards).toEqual([[1, 41], [42], [TRIGGER], [WASTED], [EOS]]);
  });

  test("composition: a request that asks for logprobs never fills", async () => {
    const fill = session([row([TRIGGER], SPAN)]);
    const { tokens, stats } = await withFill(
      { MLX_BUN_FILL: "strict" }, () => run({ fill, logprobs: true }));
    expect(tokens).toEqual([TRIGGER, WASTED]);
    expect(stats.fill).toBeUndefined();
  });

  test("an assert fill takes no checkpoint and never rewinds", async () => {
    const fill = session([row([TRIGGER], SPAN)]);
    const { stats } = await withFill({ MLX_BUN_FILL: "strict" }, () => run({ fill }));
    expect(stats.fill).toMatchObject({
      verifyEvents: 0, verifyAccepted: 0, verifyRejected: 0, checkpointMs: 0,
    });
  });
});

// --- verify policy (K3c) --------------------------------------------------
// Same apply primitive, same single forward; the difference is that the span's
// own logits are read back to decide how much of it survives.
const V0 = 70, V1 = 71, V2 = 72, AFTER = 73, WRONG = 80, TAIL = 81;
const VERIFY_SCRIPT = new Map<number, number>([
  [42, TRIGGER], [TRIGGER, V0], [V0, V1], [V1, V2], [V2, AFTER], [AFTER, EOS],
]);

/** A source that proposes `ids` under policy "verify" once, after TRIGGER. */
function verifySession(ids: number[]): FillSession {
  let fired = false;
  const source: ProposalSource = {
    name: "test-verify",
    windowNeeded: 1,
    propose: (view) => {
      if (fired || view.tail(1)[0] !== TRIGGER) return null;
      fired = true;
      return { ids: [...ids], policy: "verify", origin: "echo" } as Proposal;
    },
  };
  return new FillSession(
    { rows: [], echo: null, eos: [EOS] }, PROMPT, { sources: [source] });
}

/** Trimmable=false, but round-capable — the shape SSMCache has. Records the
 *  round calls so the test can prove the spec-round contract is driven. */
class RoundCache extends KVCache {
  static calls: string[] = [];
  #saved = 0;
  override isTrimmable(): boolean { return false; }
  specRoundBegin(): void { RoundCache.calls.push("begin"); this.#saved = this.offset; }
  specRoundCommit(): void { RoundCache.calls.push("commit"); }
  specRoundRollback(keep: number): void {
    RoundCache.calls.push(`rollback(${keep})`);
    this.offset = this.#saved + keep;
  }
}

/** Neither trimmable nor round-capable: verify has nowhere to rewind to. */
class UnrewindableCache extends KVCache {
  override isTrimmable(): boolean { return false; }
}

describe("generate(): the verify policy", () => {
  test("full accept: the whole span survives and decode resumes after it", async () => {
    const fill = verifySession([V0, V1, V2]);
    const { model, tokens, stats } = await withFill(
      { MLX_BUN_FILL: "echo" },
      () => run({ fill }, Infinity, new StubModel(VERIFY_SCRIPT)));
    expect(tokens).toEqual([TRIGGER, V0, V1, V2, AFTER]);
    expect(model.forwards).toEqual([
      [1, 41], [42], [TRIGGER], [V0, V1, V2], [AFTER], [EOS],
    ]);
    expect(stats.fill).toMatchObject({
      events: 1, injected: 3, echo: 3, strict: 0,
      verifyEvents: 1, verifyAccepted: 3, verifyRejected: 0,
      // Verify consumes the in-flight sample as position 0's check, so
      // nothing is discarded unexamined.
      wastedSamples: 0,
    });
  });

  test("partial accept: the rejected tail is rewound and never reaches the stream", async () => {
    const fill = verifySession([V0, WRONG, TAIL]);
    const { model, tokens, stats } = await withFill(
      // TRACE on: the cache-alignment invariant is ASSERTED across the rewind.
      { MLX_BUN_FILL: "echo", MLX_BUN_FILL_TRACE: "1" },
      () => run({ fill }, Infinity, new StubModel(VERIFY_SCRIPT)));
    // The model's own continuation after V0 is V1, so WRONG/TAIL are dropped
    // and decode resumes at the first disagreement — producing EXACTLY the
    // stream an unfilled run produces. A wrong guess costs a rewind, never a
    // wrong token.
    expect(tokens).toEqual([TRIGGER, V0, V1, V2, AFTER]);
    expect(tokens).not.toContain(WRONG);
    expect(model.forwards).toEqual([
      [1, 41], [42], [TRIGGER], [V0, WRONG, TAIL], [V1], [V2], [AFTER], [EOS],
    ]);
    // cacheTokens is the sequence the KV actually holds — the rewound tail is
    // absent, which is the whole point of the rollback.
    expect(stats.cacheTokens).toEqual([...PROMPT, TRIGGER, V0, V1, V2, AFTER, EOS]);
    expect(stats.fill).toMatchObject({
      events: 1, injected: 1, echo: 1,
      verifyEvents: 1, verifyAccepted: 1, verifyRejected: 2,
    });
  });

  test("rejected at position 0: no forward, no rewind, no cost", async () => {
    const fill = verifySession([WRONG, V1, V2]);
    const { model, tokens, stats } = await withFill(
      { MLX_BUN_FILL: "echo" },
      () => run({ fill }, Infinity, new StubModel(VERIFY_SCRIPT)));
    // The in-flight sample already disagreed, so the span never reached the
    // model: the generation is exactly the unfilled one.
    expect(tokens).toEqual([TRIGGER, V0, V1, V2, AFTER]);
    expect(model.forwards).toEqual([
      [1, 41], [42], [TRIGGER], [V0], [V1], [V2], [AFTER], [EOS],
    ]);
    expect(stats.fill).toMatchObject({
      events: 0, injected: 0, verifyEvents: 0, verifyRejected: 3, checkpointMs: 0,
    });
  });

  test("an untrimmable but round-capable cache rewinds through specRound*", async () => {
    RoundCache.calls = [];
    const fill = verifySession([V0, WRONG, TAIL]);
    const { tokens, stats } = await withFill(
      { MLX_BUN_FILL: "echo", MLX_BUN_FILL_TRACE: "1" },
      () => run({ fill }, Infinity,
        new StubModel(VERIFY_SCRIPT, () => [new RoundCache()])),
    );
    // Same contract the spec lane uses: arm before the forward, then roll back
    // to the accepted window length (SSMCache replays that prefix bit-exactly).
    expect(RoundCache.calls).toEqual(["begin", "rollback(1)"]);
    expect(tokens).toEqual([TRIGGER, V0, V1, V2, AFTER]);
    expect(stats.fill!.verifyAccepted).toBe(1);
  });

  test("a full accept commits the round instead of rolling it back", async () => {
    RoundCache.calls = [];
    const fill = verifySession([V0, V1, V2]);
    await withFill(
      { MLX_BUN_FILL: "echo" },
      () => run({ fill }, Infinity,
        new StubModel(VERIFY_SCRIPT, () => [new RoundCache()])),
    );
    expect(RoundCache.calls).toEqual(["begin", "commit"]);
  });

  test("a cache that can neither trim nor checkpoint drops verify proposals", async () => {
    const fill = verifySession([V0, V1, V2]);
    const { model, tokens, stats } = await withFill(
      { MLX_BUN_FILL: "echo" },
      () => run({ fill }, Infinity,
        new StubModel(VERIFY_SCRIPT, () => [new UnrewindableCache()])),
    );
    expect(tokens).toEqual([TRIGGER, V0, V1, V2, AFTER]);
    expect(model.forwards.some((f) => f.length > 1 && f[0] === V0)).toBe(false);
    expect(stats.fill).toMatchObject({
      verifyUnsupported: 1, verifyEvents: 0, events: 0, injected: 0,
    });
  });
});
