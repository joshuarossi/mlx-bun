// Replay the production Qwen tail split, then force each lazy token-zero
// component separately. This distinguishes the final one-token transformer
// forward from the output head and sampler.
//
//   MODEL=/path/to/snapshot PROMPT_TOKENS=1125 \
//     bun scripts/experiments/qwen-token-zero-replay.ts

import { loadModelConfig } from "../../src/config";
import { dlopen } from "bun:ffi";
import { Weights } from "../../src/weights";
import { createModel } from "../../src/model/factory";
import { Qwen35Model } from "../../src/model/qwen3_5";
import { KVCache, type Cache } from "../../src/model/gemma4-base";
import { SSMCache } from "../../src/model/qwen3-delta";
import { MlxArray } from "../../src/mlx/array";
import { gpuStream } from "../../src/mlx/array";
import {
  activeMemory, cacheMemory, clearCache, maxRecommendedWorkingSetSize,
  peakMemory, synchronize,
} from "../../src/mlx/ffi";
import * as ops from "../../src/mlx/ops";
import {
  modelNeedsWiredLimit, wiredWorkingSetBytes, withModelWiredLimit,
} from "../../src/generate";

const MODEL = process.env.MODEL;
if (!MODEL) throw new Error("set MODEL to a local Qwen3.8 snapshot");
const PROMPT_TOKENS = Number(process.env.PROMPT_TOKENS ?? 1125);
const CHUNK = Number(process.env.CHUNK ?? 512);
const DETACH = process.env.DETACH ?? "0";
const SYNC = process.env.SYNC === "1";
const FLUSH = process.env.FLUSH === "1";
const GPU_FLUSH = process.env.GPU_FLUSH === "1";
const GC = process.env.GC === "1";
const detachLib = process.env.MLX_ARRAY_DETACH_LIB
  ? dlopen(process.env.MLX_ARRAY_DETACH_LIB, {
      mlx_bun_array_detach: { args: ["u64"], returns: "i32" },
    })
  : null;

const config = await loadModelConfig(MODEL);
const weights = await Weights.open(MODEL);
const runtimeModel = createModel(weights, config);
if (!(runtimeModel instanceof Qwen35Model))
  throw new Error(`expected Qwen35Model, got ${runtimeModel.constructor.name}`);
const model = runtimeModel;
console.error(JSON.stringify({
  wiredWorkingSetBytes: wiredWorkingSetBytes(model),
  maxRecommendedWorkingSetSize: maxRecommendedWorkingSetSize(),
  modelNeedsWiredLimit: modelNeedsWiredLimit(model),
}));

const prompt = Array.from({ length: PROMPT_TOKENS }, (_, i) => 1000 + (i % 10000));

function detachQwenCache(cache: Cache[]): void {
  if (DETACH === "native") {
    if (!detachLib) throw new Error("DETACH=native requires MLX_ARRAY_DETACH_LIB");
    for (const value of cache.flatMap((c) => c.state())) {
      const status = detachLib.symbols.mlx_bun_array_detach(value.handle);
      if (status !== 0) throw new Error(`mlx_bun_array_detach failed: ${status}`);
    }
    return;
  }
  if (DETACH === "roundtrip") {
    const leaves: MlxArray[] = [];
    const devices: MlxArray[] = [];
    const installs: Array<() => void> = [];
    const prepare = (old: MlxArray, install: (next: MlxArray) => void) => {
      const leaf = old.detachCopy();
      const device = ops.copyOf(leaf);
      leaves.push(leaf);
      devices.push(device);
      installs.push(() => {
        install(device);
        old.dispose();
      });
    };
    for (const c of cache) {
      if (c instanceof KVCache) {
        if (c.keys) prepare(c.keys, (next) => { c.keys = next; });
        if (c.values) prepare(c.values, (next) => { c.values = next; });
      } else if (c instanceof SSMCache) {
        if (c.conv) prepare(c.conv, (next) => { c.conv = next; });
        if (c.recurrent) prepare(c.recurrent, (next) => { c.recurrent = next; });
      }
    }
    ops.evalAll(devices);
    synchronize(gpuStream);
    for (const install of installs) install();
    for (const leaf of leaves) leaf.dispose();
    return;
  }
  const detach = (a: MlxArray): MlxArray =>
    DETACH === "stop" ? ops.stopGradient(a) : a.detachCopy();
  const replacements: MlxArray[] = [];
  for (const c of cache) {
    if (c instanceof KVCache) {
      if (!c.keys || !c.values) continue;
      const oldKeys = c.keys;
      const oldValues = c.values;
      c.keys = detach(oldKeys);
      c.values = detach(oldValues);
      replacements.push(c.keys, c.values);
      oldKeys.dispose();
      oldValues.dispose();
    } else if (c instanceof SSMCache) {
      if (!c.conv || !c.recurrent) continue;
      const oldConv = c.conv;
      const oldRecurrent = c.recurrent;
      c.conv = detach(oldConv);
      c.recurrent = detach(oldRecurrent);
      replacements.push(c.conv, c.recurrent);
      oldConv.dispose();
      oldRecurrent.dispose();
    }
  }
  ops.evalAll(replacements);
}

async function replay(label: string, tokens: number[]): Promise<void> {
  const cache = model.makeCache();
  let pos = 0;
  const chunks: number[] = [];
  const chunkActiveBytes: number[] = [];
  const flushGpu = () => {
    if (!GPU_FLUSH) return;
    const leaf = ops.fromInt32([1], [1]);
    const submitted = ops.mulScalar(leaf, 1);
    ops.evalAll([submitted]);
    submitted.dispose();
    leaf.dispose();
  };
  try {
    while (tokens.length - pos - 1 > CHUNK) {
      const chunk = tokens.slice(pos, pos + CHUNK);
      const ids = ops.fromInt32(chunk, [1, chunk.length]);
      const started = performance.now();
      const h = model.forwardHidden(ids, cache);
      ids.dispose();
      h.dispose();
      ops.evalAll(cache.flatMap((c) => c.state()));
      if (SYNC) synchronize(gpuStream);
      if (DETACH !== "0") detachQwenCache(cache);
      if (FLUSH) {
        const flush = ops.fromInt32([0], [1]);
        ops.evalAll([flush]);
        flush.dispose();
      }
      flushGpu();
      if (GC) Bun.gc(true);
      chunks.push(performance.now() - started);
      clearCache();
      chunkActiveBytes.push(activeMemory());
      pos += chunk.length;
    }
    if (pos < tokens.length - 1) {
      const chunk = tokens.slice(pos, tokens.length - 1);
      const ids = ops.fromInt32(chunk, [1, chunk.length]);
      const started = performance.now();
      const h = model.forwardHidden(ids, cache);
      ids.dispose();
      h.dispose();
      ops.evalAll(cache.flatMap((c) => c.state()));
      if (SYNC) synchronize(gpuStream);
      if (DETACH !== "0") detachQwenCache(cache);
      if (FLUSH) {
        const flush = ops.fromInt32([0], [1]);
        ops.evalAll([flush]);
        flush.dispose();
      }
      flushGpu();
      if (GC) Bun.gc(true);
      chunks.push(performance.now() - started);
      clearCache();
      chunkActiveBytes.push(activeMemory());
      pos = tokens.length - 1;
    }

    const ids = ops.fromInt32(tokens.slice(pos), [1, tokens.length - pos]);
    const graphStarted = performance.now();
    const h = model.forwardHidden(ids, cache);
    const graphMs = performance.now() - graphStarted;
    ids.dispose();

    const forwardStarted = performance.now();
    const memoryBeforeForward = {
      activeBytes: activeMemory(), cacheBytes: cacheMemory(), peakBytes: peakMemory(),
      cacheStateBytes: cache.flatMap((c) => c.state()).reduce((n, a) => n + a.nbytes, 0),
    };
    ops.evalAll([h, ...cache.flatMap((c) => c.state())]);
    const forwardMs = performance.now() - forwardStarted;
    const memoryAfterForward = {
      activeBytes: activeMemory(), cacheBytes: cacheMemory(), peakBytes: peakMemory(),
    };

    const [, L, H] = h.shape as [number, number, number];
    const hLast = h.slice([0, L - 1, 0], [1, L, H]);
    h.dispose();
    const headStarted = performance.now();
    const logits = model.logitsFromHidden(hLast);
    hLast.dispose();
    ops.evalAll([logits]);
    const headMs = performance.now() - headStarted;

    const sampleStarted = performance.now();
    const lse = ops.logsumexpAxis(logits, -1, true);
    const logprobs = ops.sub(logits, lse);
    const tok = ops.argmaxAxis(logprobs, -1);
    ops.evalAll([tok]);
    const token = ops.itemUint32(tok);
    const sampleMs = performance.now() - sampleStarted;

    for (const a of [tok, logprobs, lse, logits]) a.dispose();
    console.log(JSON.stringify({
      label,
      promptTokens: tokens.length,
      chunkMs: chunks,
      chunkActiveBytes,
      finalForwardGraphMs: graphMs,
      finalForwardEvalMs: forwardMs,
      headMs,
      sampleMs,
      tokenZeroForcedMs: forwardMs + headMs + sampleMs,
      memoryBeforeForward,
      memoryAfterForward,
      token,
    }));
  } finally {
    for (const c of cache) c.dispose();
    clearCache();
  }
}

const run = async () => {
  await replay("warmup", prompt.slice(0, 2));
  await replay("measured", prompt);
};
if (process.env.WIRED === "0") await run();
else await withModelWiredLimit(model, run);

weights.dispose();
clearCache();
