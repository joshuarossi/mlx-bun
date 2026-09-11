import { afterEach, beforeEach, expect, spyOn, test } from "bun:test";
import { mkdtempSync, rmSync, writeFileSync } from "node:fs";
import { join } from "node:path";
import { tmpdir } from "node:os";
import { MlxArray, gpuStream } from "../../src/mlx/array";
import { activeMemory, clearCache, synchronize } from "../../src/mlx/ffi";
import { QwenMtpProvider } from "../../src/spec/qwen-mtp-source";
import { Weights } from "../../src/weights";
import type { DraftRowCheckpoint } from "../../src/spec/source";
import { applyStateChanges } from "../../src/engine/resources";
import { MlxStateRows } from "../../src/backends/mlx/state-rows";
import { BatchedKVCache } from "../../src/model/batched-kv";
import { KVCache } from "../../src/model/gemma4-base";

let directory: string;
let openSpy: ReturnType<typeof spyOn<typeof Weights, "open">>;
let arrays: MlxArray[];
let disposeCalls: number;
let failAt: string | undefined;
let quantizedPath: string | undefined;

beforeEach(async () => {
  // Drain finalizers from earlier test files before taking a global allocation
  // baseline. Assertions below never run GC, so missing provider disposal
  // cannot pass just because its arrays become unreachable.
  Bun.gc(true);
  await Bun.sleep(0);
  synchronize(gpuStream);
  clearCache();
  directory = mkdtempSync(join(tmpdir(), "mlx-bun-mtp-owner-"));
  writeFileSync(join(directory, "config.json"), JSON.stringify({
    model_type: "qwen3_5_mtp",
    text_config: {
      model_type: "qwen3_5_text", hidden_size: 8, intermediate_size: 16,
      num_hidden_layers: 1, num_attention_heads: 1, num_key_value_heads: 1,
      head_dim: 8, rms_norm_eps: 1e-6, vocab_size: 16,
    },
  }));
  arrays = [];
  disposeCalls = 0;
  failAt = undefined;
  quantizedPath = undefined;
  const shardPath = join(directory, "tiny.safetensors");
  writeFileSync(shardPath, new Uint8Array(4096));
  const weights = {
    shards: { files: new Map([["tiny", { path: shardPath, mmap: { size: 4096 } }]]) },
    has(name: string) { return name === `${quantizedPath}.scales`; },
    tensor(name: string) {
      if (name === failAt) throw new Error(`missing ${name}`);
      const shape = name.includes("norm") ? [8] : [8, 8];
      const array = MlxArray.fromFloat32(new Float32Array(shape.reduce((a, b) => a * b, 1)), shape);
      arrays.push(array);
      return array;
    },
    dispose() {
      disposeCalls++;
      for (const array of arrays) array.dispose();
    },
  };
  openSpy = spyOn(Weights, "open").mockResolvedValue(weights as unknown as Weights);
});

afterEach(() => {
  openSpy.mockRestore();
  for (const array of arrays) array.dispose();
  synchronize(gpuStream);
  clearCache();
  rmSync(directory, { recursive: true, force: true });
});

function liveBytes(): number {
  synchronize(gpuStream);
  clearCache();
  return activeMemory();
}

test("provider disposal releases weight maps and transpose views once", async () => {
  const baseline = liveBytes();
  const provider = await QwenMtpProvider.load(directory);
  expect(provider.weightsBytes).toBe(4096);
  expect(disposeCalls).toBe(0);
  expect(liveBytes()).toBeGreaterThan(baseline);
  provider.dispose();
  provider.dispose();
  expect(disposeCalls).toBe(1);
  expect(liveBytes()).toBe(baseline);
  expect(() => provider.open({} as Parameters<QwenMtpProvider["open"]>[0]))
    .toThrow("qwen MTP provider is disposed");
});

test("checkpoint identity survives provider reload and changes with draft bytes", async () => {
  const namespace = async () => {
    const provider = await QwenMtpProvider.load(directory);
    const unused = () => { throw new Error("identity inspection must not execute the model"); };
    const source = provider.open({ sampler: unused, target: { identity: {}, qwenMtp: {
      hiddenSize: 8, layerCount: 1, embed: unused, logitsFromHidden: unused,
    } } });
    try { return source.checkpoint!.namespace; }
    finally { source.dispose(); provider.dispose(); }
  };
  const original = await namespace();
  expect(await namespace()).toBe(original);
  writeFileSync(join(directory, "tiny.safetensors"), new Uint8Array(4096).fill(1));
  expect(await namespace()).not.toBe(original);
});

test("a late module-construction failure releases weights and earlier views", async () => {
  const baseline = liveBytes();
  failAt = "norm.weight";
  await expect(QwenMtpProvider.load(directory)).rejects.toThrow("missing norm.weight");
  expect(arrays.length).toBeGreaterThan(8);
  expect(disposeCalls).toBe(1);
  expect(liveBytes()).toBe(baseline);
});

test("a quantized projection without metadata releases earlier dense views", async () => {
  const baseline = liveBytes();
  quantizedPath = "layers.0.mlp.down_proj";
  await expect(QwenMtpProvider.load(directory)).rejects.toThrow("no quant spec");
  expect(arrays.length).toBeGreaterThan(8);
  expect(disposeCalls).toBe(1);
  expect(liveBytes()).toBe(baseline);
});

test("group membership borrows committed checkpoints and survives reorder, drain and rejoin", async () => {
  const provider = await QwenMtpProvider.load(directory);
  const unused = () => { throw new Error("membership must not execute the model"); };
  const target = { identity: {}, qwenMtp: {
    hiddenSize: 8, layerCount: 1, embed: unused, logitsFromHidden: unused,
  } };
  const checkpoint = (tokens: number, value: number): DraftRowCheckpoint => ({
    processedTokens: tokens,
    attachment: { schema: "qwen-mtp-v1", metadata: { draftOffset: tokens - 1 },
      tensors: [
        ...(tokens > 1 ? [0, 1].map(plane => MlxArray.fromFloat32(
          new Float32Array((tokens - 1) * 8).fill(value + plane), [1, 1, tokens - 1, 8])) : []),
        MlxArray.fromFloat32(new Float32Array(8).fill(value + 2), [1, 1, 8]),
      ] },
  });
  const donors = [checkpoint(1, 10), checkpoint(4, 20), checkpoint(7, 30)];
  const release = (state: DraftRowCheckpoint) => state.attachment.tensors.forEach(array => array.dispose());
  const values = (state: DraftRowCheckpoint) => ({ tokens: state.processedTokens,
    metadata: state.attachment.metadata,
    tensors: state.attachment.tensors.map(array => [...array.toFloat32()]) });
  const expected = donors.map(values);
  const group = provider.grouped.open({ target, sampling: { sample: unused }, checkpoints: [] });
  const source = provider.open({ target, sampler: unused });
  try {
    expect(group.rowCount).toBe(0);
    expect(group.namespace).toBe(source.checkpoint!.namespace);
    expect(group.tapLayers).toEqual([0]);
    group.append(donors.slice(0, 1));
    group.append(donors.slice(1));
    expect(group.rowCount).toBe(3);
    const inspect = (row: number, index: number) => {
      const state = group.capture(row);
      try { expect(values(state)).toEqual(expected[index]!); }
      finally { release(state); }
    };
    for (let row = 0; row < 3; row++) inspect(row, row);
    group.filterRows([2, 0]);
    inspect(0, 2); inspect(1, 0);
    // A failed join does not publish the preceding valid donor or alter
    // existing membership. Attachment validation is the existing restore rule.
    expect(() => group.append([donors[1]!, { ...donors[0]!, processedTokens: 9 }]))
      .toThrow("invalid paired Qwen MTP checkpoint alignment");
    expect(group.rowCount).toBe(2);
    inspect(0, 2); inspect(1, 0);
    const retained = group.capture(0);
    group.filterRows([]);
    expect(group.rowCount).toBe(0);
    group.append([retained]);
    release(retained);
    inspect(0, 2);
    expect(donors.map(values)).toEqual(expected);
    group.dispose();
    expect(disposeCalls).toBe(0);
    // The same attachment can move between grouped and request execution.
    source.checkpoint!.restore(donors[1]!.processedTokens, donors[1]!.attachment);
    const restored = { processedTokens: 4, attachment: source.checkpoint!.capture(4) };
    try { expect(values(restored)).toEqual(expected[1]!); }
    finally { release(restored); }
  } finally { group.dispose(); source.dispose(); donors.forEach(release); provider.dispose(); }
  expect(disposeCalls).toBe(1);
});

test("target and draft admission publish together after every state owner prepares", async () => {
  const baseline = liveBytes();
  const provider = await QwenMtpProvider.load(directory);
  const unused = () => { throw new Error("admission must not execute the model"); };
  const draft = provider.grouped.open({ target: { identity: {}, qwenMtp: {
    hiddenSize: 8, layerCount: 1, embed: unused, logitsFromHidden: unused,
  } }, sampling: { sample: unused }, checkpoints: [] });
  const target = new MlxStateRows([new BatchedKVCache()]);
  const pending = MlxArray.fromFloat32(new Float32Array(8).fill(17), [1, 1, 8]);
  const checkpoint: DraftRowCheckpoint = { processedTokens: 1,
    attachment: { schema: "qwen-mtp-v1", metadata: { draftOffset: 0 }, tensors: [pending] } };
  const seed = new KVCache();
  seed.restoreState(MlxArray.fromFloat32(new Float32Array(8).fill(11), [1, 1, 1, 8]),
    MlxArray.fromFloat32(new Float32Array(8).fill(13), [1, 1, 1, 8]), 1);
  try {
    applyStateChanges([() => target.prepareAppend([seed]), () => draft.prepareAppend([checkpoint])]);
    expect([target.rowCount, draft.rowCount]).toEqual([1, 1]);
    const live = target.caches[0];
    expect(() => applyStateChanges([
      () => target.prepareAppend([seed]),
      () => draft.prepareAppend([{ ...checkpoint, processedTokens: 99 }]),
    ])).toThrow("invalid paired Qwen MTP checkpoint alignment");
    expect(target.caches[0]).toBe(live);
    expect([target.rowCount, draft.rowCount]).toEqual([1, 1]);
    const failure = new Error("target preparation failed");
    expect(() => applyStateChanges([
      () => draft.prepareAppend([checkpoint]), () => { throw failure; },
    ])).toThrow(failure);
    expect([target.rowCount, draft.rowCount]).toEqual([1, 1]);
    const retained = draft.capture(0);
    try { expect(retained.attachment.tensors[0]!.toFloat32Host()).toEqual(pending.toFloat32Host()); }
    finally { for (const tensor of retained.attachment.tensors) tensor.dispose(); }
    applyStateChanges([() => target.prepareAppend([seed]), () => draft.prepareAppend([checkpoint])]);
    expect([target.rowCount, draft.rowCount]).toEqual([2, 2]);
    expect(target.caches[0]!.rowOffsets).toEqual([1, 1]);
    expect(seed.keys!.toFloat32Host()[0]).toBe(11);
  } finally { target.dispose(); draft.dispose(); seed.dispose(); pending.dispose(); provider.dispose(); }
  expect(liveBytes()).toBe(baseline);
});

test("prefill membership borrows the same checkpoints without constructing a sampler", async () => {
  const provider = await QwenMtpProvider.load(directory);
  const unused = () => { throw new Error("prefill membership must not execute the model"); };
  const target = { identity: {}, qwenMtp: { hiddenSize: 8, layerCount: 1,
    embed: unused, logitsFromHidden: unused } };
  const hidden = MlxArray.fromFloat32(new Float32Array(8).fill(7), [1, 1, 8]);
  const checkpoint: DraftRowCheckpoint = { processedTokens: 1,
    attachment: { schema: "qwen-mtp-v1", metadata: { draftOffset: 0 }, tensors: [hidden] } };
  const prefill = provider.grouped.openPrefill!({ target, checkpoints: [null, checkpoint] });
  try {
    expect(prefill.rowCount).toBe(2);
    expect(prefill.prefillMode).toBe("full");
    expect(prefill.tapLayers).toEqual([0]);
    const snapshot = prefill.capture(1);
    try {
      expect(snapshot.processedTokens).toBe(1);
      expect(snapshot.attachment.tensors[0]!.toFloat32Host()).toEqual(hidden.toFloat32Host());
    } finally { for (const tensor of snapshot.attachment.tensors) tensor.dispose(); }
    expect(() => prefill.append([null, { ...checkpoint, processedTokens: 3 }]))
      .toThrow("invalid paired Qwen MTP checkpoint alignment");
    expect(prefill.rowCount).toBe(2);
    const change = prefill.prepareAppend([checkpoint, null]); change.dispose();
    expect(prefill.rowCount).toBe(2);
    prefill.filterRows([1]);
    const restored = prefill.capture(0);
    const decode = provider.grouped.open({ target, sampling: { sample: unused }, checkpoints: [restored] });
    try {
      expect(decode.namespace).toBe(prefill.namespace);
      const captured = decode.capture(0);
      try { expect(captured.attachment.tensors[0]!.toFloat32Host()).toEqual(hidden.toFloat32Host()); }
      finally { for (const tensor of captured.attachment.tensors) tensor.dispose(); }
    } finally { decode.dispose(); for (const tensor of restored.attachment.tensors) tensor.dispose(); }
    expect(hidden.toFloat32Host()).toEqual(new Float32Array(8).fill(7));
  } finally { prefill.dispose(); hidden.dispose(); provider.dispose(); }
});
