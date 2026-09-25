import { describe, expect, test } from "bun:test";
import { createHash } from "node:crypto";
import { MlxArray } from "@mlx-bun/mlx/array";
import * as ops from "@mlx-bun/mlx/ops";
import { Dtype, MLX_VERSION } from "@mlx-bun/mlx/ffi";
import { UniversalDenseModel } from "../../../src/models/universal/dense";
import type { ModelConfig } from "../../../src/artifacts/config";
import type { Weights } from "../../../src/artifacts/weights";
import type { Cache, Mask } from "../../../src/contracts/mlx/cache";
import { BatchedKVCache } from "../../../src/state/batched-kv";
import { createCausalMask } from "../../../src/kernels/attention/masks";

// Native numerical tests are explicit: CPU-only planning/CI never initializes
// model tensors. All synthetic weights exist in memory, not tracked fixtures.
const native = process.env.MLX_BUN_GEMMA2_NATIVE === "1";
function fixture() {
  const raw = { model_type: "gemma2", hidden_size: 32, num_hidden_layers: 1,
    num_attention_heads: 8, num_key_value_heads: 4, head_dim: 4,
    intermediate_size: 64, vocab_size: 96, rms_norm_eps: 1e-6,
    query_pre_attn_scalar: 16, attn_logit_softcapping: 50, final_logit_softcapping: 30 };
  const config = { modelType: "gemma2", raw, quantization: null } as unknown as ModelConfig;
  const arrays = new Map<string, MlxArray>();
  const add = (name: string, shape: number[]) => {
    using values = MlxArray.fromFloat32(Float32Array.from({ length: shape.reduce((a, b) => a * b, 1) },
      (_, index) => Math.sin(index * 0.73 + name.length) * 0.07), shape);
    arrays.set(name, values.astype(Dtype.bfloat16));
  };
  add("model.embed_tokens.weight", [96, 32]); add("model.norm.weight", [32]);
  const prefix = "model.layers.0";
  for (const [name, shape] of Object.entries({
    "self_attn.q_proj": [32, 32], "self_attn.k_proj": [16, 32], "self_attn.v_proj": [16, 32],
    "self_attn.o_proj": [32, 32], "mlp.gate_proj": [64, 32], "mlp.up_proj": [64, 32], "mlp.down_proj": [32, 64],
    "input_layernorm": [32], "post_attention_layernorm": [32], "pre_feedforward_layernorm": [32], "post_feedforward_layernorm": [32],
  })) add(`${prefix}.${name}.weight`, shape);
  const weights = { shards: { files: new Map() }, tensorNames: [...arrays.keys()],
    has: (name: string) => arrays.has(name), tensor: (name: string) => arrays.get(name)! } as unknown as Weights;
  const models: UniversalDenseModel[] = [];
  return { make(legacy = false) { const model = legacy ? new LegacyMaskModel(weights, config) : new UniversalDenseModel(weights, config);
    models.push(model); return model; },
    dispose() {
      // Own the synthetic model's transposed views and folded norm weights too.
      const owned = new Set<MlxArray>(arrays.values()), seen = new Set<object>();
      const visit = (value: unknown) => {
        if (!value || typeof value !== "object" || seen.has(value)) return;
        seen.add(value);
        if (value instanceof MlxArray) { owned.add(value); return; }
        for (const child of Object.values(value)) visit(child);
      };
      models.forEach(visit); for (const value of owned) value.dispose();
    } };
}

// Main's original explicit-mask path; only this mask selection is duplicated.
// Every projection, norm and attention operation remains the production graph.
class LegacyMaskModel extends UniversalDenseModel {
  protected override forwardLayers(hidden: MlxArray, caches: Cache[]): MlxArray {
    const length = hidden.shape[1]!;
    const mask: Mask = length === 1 ? { mode: "", arr: null }
      : { mode: "array", arr: createCausalMask(length, caches[0]!.offset, null) };
    let current = hidden;
    try {
      for (const [index, layer] of this.layers.entries()) {
        const next = layer.forward(current, mask, caches[index]!); current.dispose(); current = next;
      }
      return this.finalNorm.forward(current);
    } finally { current.dispose(); mask.arr?.dispose(); }
  }
}
const dispose = (caches: Cache[]) => { for (const cache of caches) cache.dispose(); };

describe.skipIf(!native)("Gemma2 manual attention native masks", () => {
  test("ordinary B1 prefill, continuation chunks and decode preserve main's complete logits", () => {
    const f = fixture(), actual = f.make(), legacy = f.make(true);
    const current = actual.makeCache(), reference = legacy.makeCache();
    try {
      for (const tokens of [[2, 4, 7], [8, 3], [6], [5, 9]]) {
        using a = actual.forward(tokens, current), b = legacy.forward(tokens, reference);
        expect(a.rawBytes()).toEqual(b.rawBytes());
      }
    } finally { dispose(current); dispose(reference); f.dispose(); }
  });

  for (const batch of [2, 4]) test(`B${batch} ragged GQA preserves row validity for chunks and singleton decode`, () => {
    const f = fixture(), model = f.make();
    const solos = [2, 5, 3, 7].slice(0, batch).map(length => {
      const cache = model.makeCache();
      using logits = model.forward(Array.from({ length }, (_, index) => index + 2), cache);
      logits.eval(); return cache;
    });
    const actual = new BatchedKVCache(), reference = new BatchedKVCache();
    let maskCalls = 0;
    try {
      actual.mergeRows(solos.map(row => row[0]!)); reference.mergeRows(solos.map(row => row[0]!));
      // Same physical B/S shapes; only forbidden padding differs. Independently
      // form the expected five-dimensional row mask without the cache builder.
      for (const name of ["keys", "values"] as const) {
        for (let row = 0; row < batch; row++) {
          const pad = reference.leftPad[row]!; if (!pad) continue;
          const plane = reference[name]!;
          using floats = MlxArray.fromFloat32(new Float32Array(plane.shape[1]! * pad * plane.shape[3]!).fill(100),
            [1, plane.shape[1]!, pad, plane.shape[3]!]);
          using poison = floats.astype(plane.dtype);
          reference[name] = ops.sliceUpdate(plane, poison, [row, 0, 0, 0], [row + 1, plane.shape[1]!, pad, plane.shape[3]!]);
          plane.dispose();
        }
      }
      reference.makeMask = (length: number): Mask => {
        maskCalls++;
        const width = reference.offset + length;
        const bits = reference.rowOffsets.flatMap((offset, row) => Array.from({ length }, (_, query) =>
          Array.from({ length: width }, (_, key) => Number(key >= reference.leftPad[row]! &&
            key <= reference.leftPad[row]! + offset + query)))).flat();
        using integers = ops.fromInt32(bits, [reference.rowOffsets.length, 1, 1, length, width]);
        return { mode: "array", arr: integers.astype(Dtype.bool) };
      };
      for (const length of [2, 1]) {
        using ids = ops.fromInt32(Array.from({ length: batch * length }, (_, index) => index + 10), [batch, length]);
        using a = model.forward(ids, [actual]), b = model.forward(ids, [reference]);
        expect(a.shape).toEqual([batch, length, 96]);
        expect(a.rawBytes()).toEqual(b.rawBytes());
      }
      expect(maskCalls).toBe(2);
      actual.filterRows([0]); reference.filterRows([0]);
      using a = model.forward([25], [actual]), b = model.forward([25], [reference]);
      expect(a.rawBytes()).toEqual(b.rawBytes());
    } finally { actual.dispose(); reference.dispose(); solos.forEach(dispose); f.dispose(); }
  });
});

const artifact = process.env.MLX_BUN_GEMMA2_MODEL;
test.skipIf(!native || !artifact)("cached Gemma2 preserves B1 and serves ragged B2/B4 with joins, retirement and cancellation", async () => {
  const { Weights, loadModelConfig, createModel } = await import("../../../src/index");
  const { bindMlxGateway, createRuntimeConfig } = await import("../../../src/execution");
  const weights = await Weights.open(artifact!);
  try {
    const config = await loadModelConfig(artifact!);
    expect(config.modelType).toBe("gemma2");
    const model = createModel(weights, config) as UniversalDenseModel;
    const binding = bindMlxGateway(model);
    expect(binding.cachesBatchable()).toBe(true);
    // Main's Gemma2 L1 descriptor deliberately uses full attention, matching
    // the pinned mlx-lm implementation even if HF config lists a window.
    expect(model.args.layerTypes).toBeNull(); expect(model.args.slidingWindow).toBeNull();
    const prompts = [
      [2, 651, 6037, 576, 6081, 603], [2, 651, 6037],
      [2, 651, 6037, 576], [2, 651, 6037, 576, 6081], [2, 651],
    ];
    const steps = 10;
    const forced = [5231, 29437, 168428, 235248, 108, 107, 1, 1, 1, 107];
    const direct = (prompt: number[]) => {
      const caches = model.makeCache(), logits: Float32Array[] = [];
      try {
        // Default prefill tail split: head first, then token zero at L=1.
        using prefix = model.forward(prompt.slice(0, -1), caches); prefix.eval();
        for (let step = 0; step < steps; step++) {
          using result = model.forward([step ? forced[step - 1]! : prompt.at(-1)!], caches);
          logits.push(result.toFloat32());
        }
        return logits;
      } finally { dispose(caches); }
    };
    const baseline = prompts.map(direct);
    const runtime = createRuntimeConfig({ MLX_BUN_PREFILL_TAIL_SPLIT: "1", MLX_BUN_COMPILED_DECODE: "0" });
    for (const capacity of [1, 2, 4]) {
      let held = true, joined = false, highWater = 0;
      const group = binding.createBatchGroup({ maxBatch: capacity, admissionHeld: () => held,
        prefillChunkSize: 64, runtime });
      const abort = new AbortController();
      const actual = new Map<number, Float32Array[]>(), emitted = new Map<number, number[]>();
      const pending: Promise<unknown>[] = [];
      const submit = (id: number, maxTokens: number, signal?: AbortSignal) => {
        actual.set(id, []); emitted.set(id, []);
        const request = group.submit({ promptIds: prompts[id]!, maxTokens, eosTokenIds: [], signal,
          sample(logits, step) {
            highWater = Math.max(highWater, group.activeRows);
            actual.get(id)!.push(logits.toFloat32());
            return ops.fromInt32([forced[step]!], [1]);
          },
          onToken(token) {
            emitted.get(id)!.push(token);
            if (capacity > 1 && id === 0 && emitted.get(id)!.length === 2 && !joined) {
              joined = true; submit(4, 4);
            }
            if (capacity === 4 && id === 2 && emitted.get(id)!.length === 3)
              abort.abort(new Error("Gemma2 client left"));
          },
        });
        // Attach rejection handling immediately, including the late join.
        pending.push(request.then(stats => ({ id, stats }), error => ({ id, error })));
      };
      try {
        for (let id = 0; id < capacity; id++) submit(id, [10, 5, 8, 4][id]!, id === 2 ? abort.signal : undefined);
        held = false; group.kick();
        const completed = await Promise.all(pending);
        if (joined) completed.push(...await Promise.all(pending.slice(capacity)));
        expect(highWater).toBe(capacity);
        expect(group.activeRows + group.pendingRows).toBe(0);
        for (const result of completed as { id: number; error?: unknown; stats?: { generatedTokens: number } }[]) {
          if (result.id === 2 && capacity === 4) {
            expect(result.error).toHaveProperty("message", "Gemma2 client left");
            expect(emitted.get(2)).toEqual(forced.slice(0, 3));
          } else {
            expect(result.error).toBeUndefined();
            expect(result.stats!.generatedTokens).toBe(emitted.get(result.id)!.length);
          }
          for (const [step, logits] of actual.get(result.id)!.entries()) {
            expect(logits.every(Number.isFinite)).toBe(true);
            if (capacity === 1) expect(logits).toEqual(baseline[result.id]![step]!);
            // B changes quantized matmul dispatch. Cross-B equality is not the
            // numerical oracle; the separate same-shaped Python gate is.
            if (capacity === 2 && result.id === 1 && step === 1) {
              const reference = baseline[result.id]![step]!;
              let unequal = 0, maxAbs = 0, first = -1;
              for (let i = 0; i < logits.length; i++) if (logits[i] !== reference[i]) {
                unequal++; if (first < 0) first = i;
                maxAbs = Math.max(maxAbs, Math.abs(logits[i]! - reference[i]!));
              }
              console.info("Gemma2 cross-B diagnostic", { unequal, maxAbs, first,
                direct: reference[first], batched: logits[first] });
            }
          }
        }
        if (capacity > 1) expect(joined).toBe(true);
      } finally { await group.close(); }
    }
  } finally { weights.dispose(); }
}, 600_000);


const referencePath = process.env.MLX_BUN_GEMMA2_REFERENCE;
test.skipIf(!native || !artifact || !referencePath)("real Gemma2 ragged B2/B4 logits and KV match the external same-shaped Python reference", async () => {
  const { Weights, loadModelConfig, createModel } = await import("../../../src/index");
  const reference = await Bun.file(referencePath!).json();
  const hash = (value: Uint8Array) => createHash("sha256").update(value).digest("hex");
  expect(reference.runtime).toBe(MLX_VERSION);
  expect(reference.configSha256).toBe(hash(new Uint8Array(await Bun.file(`${artifact}/config.json`).arrayBuffer())));
  expect(reference.rows.map((row: { batch: number }) => row.batch)).toEqual([2, 4]);
  const encoded = (value: MlxArray) => {
    using contiguous = ops.contiguous(value);
    return { shape: [...value.shape], dtype: value.dtypeName, sha256: hash(contiguous.rawBytes()) };
  };
  const weights = await Weights.open(artifact!);
  try {
    const model = createModel(weights, await loadModelConfig(artifact!)) as UniversalDenseModel;
    expect(model.config.modelType).toBe("gemma2");
    for (const expected of reference.rows) {
      const batch: number = expected.batch;
      const lengths = [2, 5, 3, 7].slice(0, batch);
      expect(expected.lengths).toEqual(lengths);
      expect(expected.steps).toHaveLength(3);
      const solos = lengths.map(length => {
        const caches = model.makeCache();
        using logits = model.forward(Array.from({ length }, (_, i) => i + 2), caches); logits.eval();
        return caches;
      });
      const caches = model.layers.map((_, layer) => {
        const cache = new BatchedKVCache(); cache.mergeRows(solos.map(row => row[layer]!)); return cache;
      });
      try {
        for (const [step, length] of [2, 1, 1].entries()) {
          if (step === 2) for (const cache of caches) cache.filterRows([0]);
          const rows = step === 2 ? 1 : batch;
          const tokens = step === 2 ? [25] : Array.from({ length: rows * length }, (_, i) => i + 10);
          expect(expected.steps[step].ids).toEqual(Array.from({ length: rows }, (_, row) => tokens.slice(row * length, (row + 1) * length)));
          using ids = ops.fromInt32(tokens, [rows, length]);
          using logits = model.forward(ids, caches);
          expect(encoded(logits), `B${batch} step ${step} logits`).toEqual(expected.steps[step].logits);
          const state = caches.map(cache => {
            const view = cache.captureDonorRows();
            try { return [encoded(view.keys), encoded(view.values)]; }
            finally { view.keys.dispose(); view.values.dispose(); }
          });
          expect(state, `B${batch} step ${step} KV`).toEqual(expected.steps[step].state);
        }
      } finally { dispose(caches); solos.forEach(dispose); }
    }
  } finally { weights.dispose(); }
}, 600_000);
