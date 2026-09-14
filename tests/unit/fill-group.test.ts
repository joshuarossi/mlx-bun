import { expect, test } from "bun:test";
import { MlxArray } from "../../src/mlx/array";
import * as ops from "../../src/mlx/ops";
import { KVCache, type Cache } from "../../src/model/gemma4-base";
import type { RuntimeModel } from "../../src/model/factory";
import { FillSession } from "../../src/fill/fill-session";
import { bindFillGroupRequests } from "../../src/backends/mlx/fill-group";
import { MlxBatchExecutionGroup, type RowPromptCache } from "../../src/backends/mlx/batch-group";

class Model {
  constructor(readonly specializedAppend = false) {}
  readonly weightsBytes = 0;
  readonly config = { modelType: "fill-fixture", eosTokenIds: [16], text: {
    numHiddenLayers: 1, layerTypes: ["full_attention"], numGlobalKeyValueHeads: 1,
    globalHeadDim: 4, slidingWindow: 0, vocabSize: 32 } };
  readonly events: string[] = [];
  readonly heads: number[][] = [];
  readonly batches: number[] = [];
  makeCache() { return [new KVCache()]; }
  createAppend() {
    return this.specializedAppend ? { maxChunkSize: (_state: readonly Cache[], rows = 1) => rows === 1 ? 4 : 1,
      forwardHidden: this.forwardHidden.bind(this) } : null;
  }
  forwardHidden(input: MlxArray, caches: Cache[]): MlxArray {
    using ids = ops.contiguous(input);
    const [B, L] = ids.shape as [number, number], tokens = ids.toIntTokens();
    this.events.push(`forward:${tokens.join(",")}`); this.batches.push(B);
    const values = Float32Array.from(tokens.flatMap(token => [token, token, token, token]));
    using k = MlxArray.fromFloat32(values, [B, 1, L, 4]);
    using v = MlxArray.fromFloat32(values, [B, 1, L, 4]);
    const result = caches[0]!.updateAndFetch(k, v); result.forEach(array => array.dispose());
    return MlxArray.fromFloat32(Float32Array.from(tokens), [B, L, 1]);
  }
  logitsFromHidden(hidden: MlxArray): MlxArray {
    using packed = ops.contiguous(hidden);
    const tokens = [...packed.toFloat32Host()]; this.heads.push(tokens);
    const scores = new Float32Array(tokens.length * 32);
    tokens.forEach((token, index) => { scores[index * 32 + Math.min(token + 1, 16)] = 100; });
    return MlxArray.fromFloat32(scores, [hidden.shape[0]!, hidden.shape[1]!, 32]);
  }
}

function fixture(cache?: RowPromptCache, specializedAppend = false) {
  const model = new Model(specializedAppend);
  let held = true;
  const group = new MlxBatchExecutionGroup(model as unknown as RuntimeModel,
    { maxBatch: 4, admissionHeld: () => held, promptCache: cache });
  const method = bindFillGroupRequests(model as unknown as RuntimeModel);
  return { model, group,
    start() { held = false; group.kick(); },
    submit(prompt: number[], options: { fill?: boolean; maxTokens?: number;
      verify?: number[]; verifyAfter?: number;
      onToken?: (token: number) => boolean | void; signal?: AbortSignal } = {}) {
      const fill = new FillSession({ rows: options.fill === false || options.verify ? [] : [{ trigger: [7], emit: [11, 12, 13], kind: "scaffold" }],
        echo: null, eos: [16] }, prompt, options.verify ? { sources: [{ name: "verified-copy", propose: view =>
          view.length === prompt.length + (options.verifyAfter ?? 3) ? { ids: options.verify!, policy: "verify", origin: "echo" } : null }] } : undefined);
      const output: number[] = [];
      const completion = group.submit({ promptIds: prompt, maxTokens: options.maxTokens ?? 32,
        eosTokenIds: [16], method: method({ fill, temperature: 0 }), signal: options.signal,
        onToken(token) { model.events.push(`emit:${token}`); output.push(token); return options.onToken?.(token); } });
      return { fill, output, completion };
    } };
}

test.each(["eos", "limit", "stop", "failure", "cancel"] as const)("verified shared outputs align row state at %s", async end => {
  const stored: number[][] = [];
  const f = fixture({ take: () => null, put(tokens, caches) {
    try {
      expect(caches[0]!.offset).toBe(tokens.length);
      const planes = caches[0]!.state();
      using live = planes[0]!.slice([0, 0, 0, 0], [1, 1, tokens.length, 4]);
      expect([...live.toFloat32()]).toEqual(tokens.flatMap(token => [token, token, token, token]));
      stored.push([...tokens]);
    } finally { caches.forEach(cache => cache.dispose()); }
  } });
  const cancellation = new AbortController();
  const verify = [8, 9, 10, 11, 12, 13, 14, 15];
  const run = f.submit([1, 4], { verify, maxTokens: end === "limit" ? 5 : 32, signal: cancellation.signal,
    onToken(token) {
      if (token !== 9) return;
      if (end === "stop") return false;
      if (end === "failure") throw new Error("consumer failed");
      if (end === "cancel") cancellation.abort(new Error("consumer cancelled"));
    } });
  const sibling = f.submit([1, 4], { verify });
  const results = Promise.allSettled([run.completion, sibling.completion]);
  f.start();
  try {
    const [first, second] = await results;
    expect(second.status).toBe("fulfilled");
    expect(sibling.output).toEqual([5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15]);
    expect(sibling.fill.stats.verifyAccepted).toBe(8);
    expect(sibling.fill.stats.verifyEvents).toBeGreaterThan(0);
    expect(first.status).toBe(end === "failure" || end === "cancel" ? "rejected" : "fulfilled");
    if (first.status === "fulfilled") {
      expect(first.value.generatedTokens).toBe(end === "eos" ? 12 : 5);
      expect(first.value.finishReason).toBe(end === "limit" ? "length" : "stop");
      expect(run.fill.stats.verifyAccepted).toBe(end === "eos" ? 8 : 2);
    }
    expect(stored.length).toBe(end === "failure" || end === "cancel" ? 1 : 2);
    expect(run.output).toEqual(end === "eos" ? sibling.output : [5, 6, 7, 8, 9]);
  } finally { await f.group.close(); }
});

test("an ordinary row discovering a strict span keeps its append policy beside an echo row", async () => {
  const f = fixture();
  const echo = f.submit([1, 4], { verify: [8, 9, 10, 11, 12, 13, 14, 15] });
  const strict = f.submit([1, 3]);
  f.start();
  try {
    await Promise.all([echo.completion, strict.completion]);
    expect(echo.output).toEqual([5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15]);
    expect(strict.output).toEqual([4, 5, 6, 7, 11, 12, 13, 14, 15]);
    expect(echo.fill.stats.verifyAccepted).toBe(8);
    expect(strict.fill.stats.strict).toBe(3);
  } finally { await f.group.close(); }
});

test("a newly discovered echo keeps the declared token work and its remaining continuation", async () => {
  const f = fixture();
  const first = f.submit([1, 4], { verify: [8, 9, 10] });
  const next = f.submit([1, 4], { verifyAfter: 4, verify: [9, 10, 11, 12, 13, 14, 15] });
  f.start();
  try {
    await Promise.all([first.completion, next.completion]);
    expect(first.output).toEqual([5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15]);
    expect(next.output).toEqual(first.output);
    expect(first.fill.stats.verifyAccepted).toBe(3);
    expect(next.fill.stats.verifyAccepted).toBe(7);
    expect(f.model.events).toContain("forward:8,9,10,8,9,10");
  } finally { await f.group.close(); }
});

test.each([false, true])("shared fill preserves pipelining and bypasses heads, specialized append=%s", async specialized => {
  const stored: number[][] = [];
  const f = fixture({ take: () => null, put(tokens, caches) {
    expect(caches[0]!.offset).toBe(tokens.length); stored.push([...tokens]); caches.forEach(cache => cache.dispose());
  } }, specialized);
  const run = f.submit([1, 4]); f.start();
  try {
    const stats = await run.completion;
    expect(run.output).toEqual([5, 6, 7, 11, 12, 13, 14, 15]);
    expect(stats.generatedTokens).toBe(9); expect(stats.finishReason).toBe("stop");
    expect(run.fill.stats.injected).toBe(3); expect(run.fill.stats.wastedSamples).toBe(1);
    expect(stats.fill).toBe(run.fill.stats);
    expect(f.model.events.includes("forward:11,12,13")).toBe(specialized);
    expect(f.model.heads.flat()).not.toContain(11);
    expect(f.model.heads.flat()).not.toContain(12);
    expect(f.model.events.indexOf("forward:6")).toBeLessThan(f.model.events.indexOf("emit:6"));
    expect(stored).toEqual([[1, 4, 5, 6, 7, 11, 12, 13, 14, 15, 16]]);
  } finally { await f.group.close(); }
});

test("different shared rows can fill and sample independently through retirement", async () => {
  const f = fixture();
  const filled = f.submit([1, 4]);
  const sampled = f.submit([1, 2, 5], { fill: false });
  f.start();
  try {
    await Promise.all([filled.completion, sampled.completion]);
    expect(filled.output).toEqual([5, 6, 7, 11, 12, 13, 14, 15]);
    expect(sampled.output).toEqual([6, 7, 8, 9, 10, 11, 12, 13, 14, 15]);
    expect(filled.fill.stats.injected).toBe(3); expect(sampled.fill.stats.injected).toBe(0);
    expect(f.model.batches).toContain(2);
    await f.group.close();
    expect(f.group.activeRows).toBe(0);
  } finally { await f.group.close(); }
});

test("the last non-EOS sampled token counts toward fill statistics", async () => {
  const f = fixture(); const run = f.submit([1, 4], { maxTokens: 1 }); f.start();
  try {
    const result = await run.completion;
    expect(run.output).toEqual([5]); expect(result.fill?.decodeSteps).toBe(1);
    expect(result.fill?.injected).toBe(0);
  } finally { await f.group.close(); }
});

test.each([false, true])("consumer stop inside a filled span settles its emitted prefix, specialized append=%s", async specialized => {
  const f = fixture(undefined, specialized);
  const stopped = f.submit([1, 4], { onToken: token => token !== 12 });
  const sibling = f.submit([1, 2, 5], { fill: false }); f.start();
  try {
    const [stats] = await Promise.all([stopped.completion, sibling.completion]);
    expect(stats.finishReason).toBe("stop");
    expect(stopped.output).toEqual([5, 6, 7, 11, 12]);
    expect(stopped.fill.stats.injected).toBe(2);
    expect(sibling.output.at(-1)).toBe(15);
  } finally { await f.group.close(); }
});

test("a consumer stop during specialized append retains the full cache-covered span", async () => {
  const stored: number[][] = [];
  const f = fixture({ take: () => null, put(tokens, caches) {
    expect(caches[0]!.offset).toBe(tokens.length); stored.push([...tokens]); caches.forEach(cache => cache.dispose());
  } }, true);
  const run = f.submit([1, 4], { onToken: token => token !== 11 }); f.start();
  try {
    const stats = await run.completion;
    expect(run.output).toEqual([5, 6, 7, 11]); expect(stats.fill?.injected).toBe(1);
    expect(stored).toEqual([[1, 4, 5, 6, 7, 11, 12, 13]]);
  } finally { await f.group.close(); }
});

test("length ending inside a filled span preserves per-row token budgets", async () => {
  const f = fixture();
  const short = f.submit([1, 4], { maxTokens: 5 });
  const long = f.submit([1, 2, 5], { fill: false }); f.start();
  try {
    const [stats] = await Promise.all([short.completion, long.completion]);
    expect(stats.finishReason).toBe("length"); expect(stats.generatedTokens).toBe(5);
    expect(short.output).toEqual([5, 6, 7, 11, 12]);
    expect(short.fill.stats.injected).toBe(2); expect(long.output.at(-1)).toBe(15);
  } finally { await f.group.close(); }
});

test("a failing filled-row consumer does not discard a sibling", async () => {
  const f = fixture();
  const failure = new Error("consumer failure");
  const stopped = f.submit([1, 4], { onToken: token => { if (token === 12) throw failure; } });
  const caught = stopped.completion.catch(error => error);
  const sibling = f.submit([1, 2, 5], { fill: false }); f.start();
  try {
    expect(await caught).toBe(failure); await sibling.completion;
    expect(stopped.fill.stats.injected).toBe(2); expect(sibling.output.at(-1)).toBe(15);
  } finally { await f.group.close(); }
});

test("a late join flushes pending sampled and known tokens exactly once", async () => {
  const f = fixture();
  let late: ReturnType<typeof f.submit> | undefined;
  const first = f.submit([1, 4], { onToken: token => {
    if (token === 7) late = f.submit([1, 2, 5]);
  } }); f.start();
  try {
    await first.completion; await late!.completion;
    expect(first.output).toEqual([5, 6, 7, 11, 12, 13, 14, 15]);
    expect(late!.output).toEqual([6, 7, 11, 12, 13, 14, 15]);
    expect(first.fill.stats.injected).toBe(3); expect(late!.fill.stats.injected).toBe(3);
    expect(f.model.batches).toContain(2);
  } finally { await f.group.close(); }
});

test("abort inside a known span settles its emitted prefix and leaves siblings running", async () => {
  const f = fixture(), abort = new AbortController();
  const failure = new Error("cancelled by client");
  const stopped = f.submit([1, 4], { signal: abort.signal,
    onToken: token => { if (token === 12) abort.abort(failure); } });
  const caught = stopped.completion.catch(error => error);
  const sibling = f.submit([1, 2, 5], { fill: false }); f.start();
  try {
    expect(await caught).toBe(failure); await sibling.completion;
    expect(stopped.output).toEqual([5, 6, 7, 11, 12]);
    expect(stopped.fill.stats.injected).toBe(2); expect(sibling.output.at(-1)).toBe(15);
  } finally { await f.group.close(); }
});
