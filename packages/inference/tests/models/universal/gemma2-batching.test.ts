import { describe, expect, test } from "bun:test";
import { createHash } from "node:crypto";
import { mkdir, mkdtemp, rm, writeFile } from "node:fs/promises";
import { tmpdir } from "node:os";
import { join } from "node:path";
import type { MlxArray } from "@mlx-bun/mlx/array";
import type { UniversalDenseModel } from "../../../src/models/universal/dense";
import type { ModelConfig } from "../../../src/artifacts/config";
import type { Weights } from "../../../src/artifacts/weights";
import type { Cache, Mask } from "../../../src/contracts/mlx/cache";
import type { DraftProvider } from "../../../src/generation/speculative/source";
import type { GenerateOptions } from "../../../src/generation/index";

// Native numerical tests are explicit: CPU-only planning/CI never initializes
// model tensors. All synthetic weights exist in memory, not tracked fixtures.
const native = process.env.MLX_BUN_GEMMA2_NATIVE === "1";
const artifact = process.env.MLX_BUN_GEMMA2_MODEL;
const referencePath = process.env.MLX_BUN_GEMMA2_REFERENCE;
if ((artifact !== undefined || referencePath !== undefined) && !native)
  throw new Error("Gemma2 MODEL/REFERENCE requires MLX_BUN_GEMMA2_NATIVE=1");
if (referencePath !== undefined && !artifact)
  throw new Error("MLX_BUN_GEMMA2_REFERENCE requires MLX_BUN_GEMMA2_MODEL");
if (artifact !== undefined) {
  if (!artifact || !await Bun.file(`${artifact}/config.json`).exists())
    throw new Error(`unavailable Gemma2 model config: ${artifact}`);
  let config: unknown;
  try { config = await Bun.file(`${artifact}/config.json`).json(); }
  catch { throw new Error(`invalid Gemma2 model config JSON: ${artifact}`); }
  if (!config || typeof config !== "object" || !("model_type" in config) || config.model_type !== "gemma2")
    throw new Error(`Gemma2 acceptance requires model_type gemma2: ${artifact}`);
}
if (referencePath !== undefined) {
  if (!referencePath || !await Bun.file(referencePath).exists())
    throw new Error(`unavailable Gemma2 reference: ${referencePath}`);
  try { await Bun.file(referencePath).json(); }
  catch { throw new Error(`invalid Gemma2 reference JSON: ${referencePath}`); }
}

test("Gemma2 opt-in errors fail before native initialization", async () => {
  const directory = await mkdtemp(join(tmpdir(), "gemma2-opt-in-"));
  const env = { ...process.env, MLX_BUN_LIBMLXC: "/nonexistent/mlx-native-must-not-load",
    MLX_BUN_GEMMA2_NATIVE: undefined, MLX_BUN_GEMMA2_MODEL: undefined,
    MLX_BUN_GEMMA2_REFERENCE: undefined };
  const probe = (overrides: NodeJS.ProcessEnv) => Bun.spawnSync([process.execPath,
    "--no-env-file", "test", import.meta.path, "--test-name-pattern", "^Gemma2 native acceptance requires"],
    { env: { ...env, ...overrides }, stdout: "pipe", stderr: "pipe", timeout: 10_000 });
  try {
    const malformed = join(directory, "malformed"), wrong = join(directory, "wrong"), valid = join(directory, "valid");
    for (const path of [malformed, wrong, valid]) await mkdir(path);
    await writeFile(join(malformed, "config.json"), "{");
    await writeFile(join(wrong, "config.json"), '{"model_type":"llama"}');
    await writeFile(join(valid, "config.json"), '{"model_type":"gemma2"}');
    const badReference = join(directory, "reference.json"); await writeFile(badReference, "{");
    const absent = probe({});
    expect(absent.exitCode, absent.stderr.toString()).toBe(0);
    expect(absent.stderr.toString()).toContain("skip");
    for (const [overrides, message] of [
      [{ MLX_BUN_GEMMA2_MODEL: valid }, "requires MLX_BUN_GEMMA2_NATIVE=1"],
      [{ MLX_BUN_GEMMA2_REFERENCE: badReference }, "requires MLX_BUN_GEMMA2_NATIVE=1"],
      [{ MLX_BUN_GEMMA2_NATIVE: "1", MLX_BUN_GEMMA2_REFERENCE: badReference }, "REFERENCE requires MLX_BUN_GEMMA2_MODEL"],
      [{ MLX_BUN_GEMMA2_NATIVE: "1", MLX_BUN_GEMMA2_MODEL: directory }, "unavailable Gemma2 model config"],
      [{ MLX_BUN_GEMMA2_NATIVE: "1", MLX_BUN_GEMMA2_MODEL: malformed }, "invalid Gemma2 model config JSON"],
      [{ MLX_BUN_GEMMA2_NATIVE: "1", MLX_BUN_GEMMA2_MODEL: wrong }, "requires model_type gemma2"],
      [{ MLX_BUN_GEMMA2_NATIVE: "1", MLX_BUN_GEMMA2_MODEL: valid, MLX_BUN_GEMMA2_REFERENCE: directory + "/missing" }, "unavailable Gemma2 reference"],
      [{ MLX_BUN_GEMMA2_NATIVE: "1", MLX_BUN_GEMMA2_MODEL: valid, MLX_BUN_GEMMA2_REFERENCE: badReference }, "invalid Gemma2 reference JSON"],
    ] as const) {
      const child = probe(overrides), output = child.stdout.toString() + child.stderr.toString();
      expect(child.exitCode).not.toBe(0);
      expect(output).toContain(message);
      expect(output).not.toContain("mlx-native-must-not-load");
    }
  } finally { await rm(directory, { recursive: true, force: true }); }
});

if (!native) {
  test.skip("Gemma2 native acceptance requires MLX_BUN_GEMMA2_NATIVE=1", () => {});
} else {
const { MlxArray } = await import("@mlx-bun/mlx/array");
const ops = await import("@mlx-bun/mlx/ops");
const { Dtype, MLX_VERSION } = await import("@mlx-bun/mlx/ffi");
const { UniversalDenseModel } = await import("../../../src/models/universal/dense");
const { BatchedKVCache } = await import("../../../src/state/batched-kv");
const { createCausalMask } = await import("../../../src/kernels/attention/masks");
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

test.skipIf(!native)("a fill group's last row leaving with a pipelined token drains the same scheduler for reuse", async () => {
  const { bindMlxGateway, createRuntimeConfig } = await import("../../../src/execution");
  const { FillSession } = await import("../../../src/generation/fill");
  const { activeMemory, synchronize } = await import("@mlx-bun/mlx/ffi");
  const { gpuStream } = await import("@mlx-bun/mlx/array");
  // Pipelined work still in flight holds buffers until it completes.
  const settled = () => { synchronize(gpuStream); return activeMemory(); };
  const f = fixture(), model = f.make();
  const binding = bindMlxGateway(model);
  const shape = { hasVision: false, hasAdapters: false, hasRepetitionPenalty: false, userSeed: false, kvQuant: false,
    turboQuant: false, hasLogitsExtras: false, hasGrammar: false, wantsLogprobs: false, hasDraft: false };
  // One scheduler for every request: a poisoned drain would surface on reuse.
  const group = binding.createBatchGroup({ maxBatch: 2, prefillChunkSize: 64,
    runtime: createRuntimeConfig({ MLX_BUN_PREFILL_TAIL_SPLIT: "1", MLX_BUN_COMPILED_DECODE: "0" }) });
  const prompt = [2, 4, 7, 9, 3];
  // A consumer stop or a cancellation ends the last row in an ordinary step
  // whose next token is already pipelined: the group filters to no rows while
  // a token is pending.
  const run = async (end?: { stopAfter?: number; cancelAfter?: number }) => {
    const options = { maxTokens: 8, temperature: 0, fill: new FillSession({ rows: [], eos: [], echo: null }, prompt) };
    const plan = binding.plan(shape, options, { continuous: binding.cachesBatchable(), quantizedBatch: false, checkpoints: false });
    expect(plan).toMatchObject({ mechanism: "continuous", fill: true });
    const tokens: number[] = [], abort = new AbortController();
    const outcome = await group.submit({ promptIds: prompt, maxTokens: 8, eosTokenIds: [], method: binding.methodRequest!(plan, options)!,
      signal: abort.signal, onToken(token) {
        tokens.push(token);
        if (tokens.length === end?.cancelAfter) abort.abort(new DOMException("client left", "AbortError"));
        return tokens.length === end?.stopAfter ? false : undefined;
      } }).then(stats => stats.finishReason, (error: Error) => error.name);
    expect(group.activeRows + group.pendingRows).toBe(0);
    return { tokens, outcome };
  };
  try {
    const full = await run();
    expect(full.tokens).toHaveLength(8);
    expect(full.outcome).toBe("length");
    const memory: number[] = [settled()];
    for (let cycle = 0; cycle < 3; cycle++) {
      expect(await run({ stopAfter: 3 })).toEqual({ tokens: full.tokens.slice(0, 3), outcome: "stop" });
      // The abort lands inside the third token's delivery; nothing follows it.
      expect(await run({ cancelAfter: 3 })).toEqual({ tokens: full.tokens.slice(0, 3), outcome: "AbortError" });
      expect(await run()).toEqual(full);
      memory.push(settled());
    }
    // Released with its row: no growth across stop, cancel and full cycles.
    expect(memory.every(bytes => bytes === memory[0])).toBe(true);
  } finally { await group.close(); f.dispose(); }
});

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


test.skipIf(!native || !artifact)("cached Gemma2 plain fill matches main's serial fill at B1 and keeps every row through B2/B3/B4 joins and cancellation", async () => {
  const { Weights, loadModelConfig, createModel } = await import("../../../src/index");
  const { bindMlxGateway, createRuntimeConfig } = await import("../../../src/execution");
  const { FillSession } = await import("../../../src/generation/fill");
  const { loadTokenizer } = await import("../../../src/input");
  type Session = InstanceType<typeof FillSession>;
  const weights = await Weights.open(artifact!);
  try {
    const model = createModel(weights, await loadModelConfig(artifact!)) as UniversalDenseModel;
    const tokenizer = await loadTokenizer(artifact!);
    const eos = model.config.eosTokenIds, maxTokens = 32;
    const prompts = ["Write three short sentences about the ocean at night.",
      "Summarize in three sentences why tide pools interest biologists.",
      "Explain step by step how bread dough rises overnight in a bakery.",
      "List four facts about the Moon, one per line, with no introduction and no closing remark."]
      .map(text => [2, ...tokenizer.encode(`<start_of_turn>user\n${text}<end_of_turn>\n<start_of_turn>model\n`, false)]);
    const hashRows = (logits: MlxArray) => {
      const [rows, positions, vocab] = logits.shape as [number, number, number];
      return Array.from({ length: rows * positions }, (_, i) => {
        using row = logits.slice([Math.floor(i / positions), i % positions, 0], [Math.floor(i / positions) + 1, i % positions + 1, vocab]);
        using flat = ops.contiguous(row);
        return createHash("sha256").update(flat.rawBytes()).digest("hex");
      });
    };
    const argmaxAt = (logits: MlxArray, position: number) => {
      using row = logits.slice([0, position, 0], [1, position + 1, logits.shape[2]!]);
      using best = ops.argmaxAxis(row, -1);
      return best.toIntTokens()[0]!;
    };
    // Main 02d723a's serial fill, operation for operation at B=1: tail-split
    // prefill, one-position assert appends (Gemma2 declares no multi-position
    // append), one forward per verify span, and a trim after a rejection.
    const serial = (prompt: number[], fill: Session | null) => {
      const caches = model.makeCache(), logits: string[] = [], tokens: number[] = [];
      const forward = (ids: number[]) => { using input = ops.fromInt32(ids, [1, ids.length]); return model.forwardHidden(input, caches); };
      const project = (hidden: MlxArray) => { const out = model.logitsFromHidden(hidden); logits.push(...hashRows(out)); return out; };
      try {
        { using head = forward(prompt.slice(0, -1)); head.eval(); }
        let pending: number | null, generated = 0, finish = "length";
        { using hidden = forward([prompt.at(-1)!]); using out = project(hidden); pending = argmaxAt(out, 0); }
        while (pending !== null) {
          const current: number = pending;
          let next: number | null = null;
          if (generated + 1 < maxTokens) { using hidden = forward([current]); using out = project(hidden); next = argmaxAt(out, 0); }
          generated++;
          if (eos.includes(current)) { finish = "stop"; break; }
          tokens.push(current);
          const proposal: ReturnType<Session["push"]> | undefined = fill?.push(current, next !== null ? maxTokens - generated : 0);
          if (proposal && next !== null) {
            if (proposal.policy === "assert") {
              let last: MlxArray | null = null;
              for (const id of proposal.ids) { last?.dispose(); last = forward([id]); }
              using hidden = last!;
              fill!.commit(proposal, proposal.ids.length);
              tokens.push(...proposal.ids); generated += proposal.ids.length;
              if (generated < maxTokens) { using out = project(hidden); next = argmaxAt(out, 0); } else next = null;
            } else if (next === proposal.ids[0]) {
              using hidden = forward(proposal.ids);
              using out = project(hidden);
              let accepted: number = proposal.ids.length;
              for (let j = 0; j + 1 < proposal.ids.length; j++) if (argmaxAt(out, j) !== proposal.ids[j + 1]) { accepted = j + 1; break; }
              for (const cache of caches) cache.trim(proposal.ids.length - accepted);
              fill!.commit(proposal, accepted);
              tokens.push(...proposal.ids.slice(0, accepted)); generated += accepted;
              next = generated < maxTokens ? argmaxAt(out, accepted - 1) : null;
            } else fill!.commit(proposal, 0);
          }
          pending = next;
        }
        return { tokens, logits, finish };
      } finally { dispose(caches); }
    };
    // Verify spans come from each prompt's plain greedy run: accepted, rolled
    // back after two positions, and rejected before any forward. A verify
    // span's bonus token comes from a multi-position forward, so the assert
    // row's trigger pair (seen once) is chosen from the verify-only run.
    const fixed = tokenizer.encode(" (a fixed scaffold span)", false).slice(0, 5);
    const wrong = (token: number) => [2000, 2001].find(id => id !== token)!;
    type Plan = { rows: { trigger: number[]; emit: number[]; kind: "scaffold" }[]; scripted: Map<number, number[]> };
    const session = (index: number, plan: Plan) => new FillSession({ rows: plan.rows, echo: null, eos }, prompts[index]!, {
      maxSpan: 8, appendChunkSize: 0, sources: [{ name: "scripted-echo", propose: view => {
        const ids = plan.scripted.get(view.length - prompts[index]!.length);
        return ids ? { ids: [...ids], policy: "verify" as const, origin: "echo" as const } : null;
      } }] });
    const plans = prompts.map((prompt, index): Plan => {
      const g = serial(prompt, null).tokens;
      if (g.length < 20) throw new Error(`prompt ${index} ended after ${g.length} tokens`);
      const scripted = new Map([[2, g.slice(2, 6)], [7, [g[7]!, g[8]!, wrong(g[9]!), g[10]!]], [11, [wrong(g[11]!), g[12]!]]]);
      const h = serial(prompt, session(index, { rows: [], scripted })).tokens, history = [prompt.at(-1)!, ...h];
      // The pair (h[t-1], h[t]) is history[t..t+1]; it must not end any earlier position.
      const t = h.findIndex((_, t) => t >= 16 && !history.slice(0, t).some((token, i) => token === h[t - 1] && history[i + 1] === h[t]));
      if (t < 0 || t + 6 >= maxTokens) throw new Error(`prompt ${index} has no usable trigger`);
      return { rows: [{ trigger: [h[t - 1]!, h[t]!], emit: fixed, kind: "scaffold" }], scripted };
    });
    const expected = prompts.map((prompt, index) => {
      const fill = session(index, plans[index]!), run = serial(prompt, fill);
      expect(fill.stats.strict).toBeGreaterThan(0);
      expect(fill.stats.verifyAccepted).toBeGreaterThan(0);
      expect(fill.stats.verifyRejected).toBeGreaterThan(2);
      return { ...run, stats: fill.stats };
    });

    const binding = bindMlxGateway(model);
    const runtime = createRuntimeConfig({ MLX_BUN_PREFILL_TAIL_SPLIT: "1", MLX_BUN_COMPILED_DECODE: "0" });
    const shape = { hasVision: false, hasAdapters: false, hasRepetitionPenalty: false, userSeed: false, kvQuant: false,
      turboQuant: false, hasLogitsExtras: false, hasGrammar: false, wantsLogprobs: false, hasDraft: false };
    const logitsFromHidden = model.logitsFromHidden;
    // Each row joins after the previous row's first token. The B4 case cancels
    // its third row, which is live when the fourth joins, so four rows share
    // the batch; the observed high water must equal the capacity.
    for (const [capacity, order, cancelled] of [[1, [0], -1], [1, [1], -1], [1, [2], -1], [1, [3], -1], [2, [0, 1], -1],
      [3, [2, 0, 1], 0], [4, [2, 0, 1, 3], 1]] as const) {
      const logits: string[] = [];
      // The fill group binds the projection when it opens, after this hook.
      model.logitsFromHidden = function (this: UniversalDenseModel, hidden: MlxArray) {
        const out = logitsFromHidden.call(this, hidden);
        if (capacity === 1) logits.push(...hashRows(out));
        return out;
      };
      const group = binding.createBatchGroup({ maxBatch: capacity, prefillChunkSize: 512, runtime });
      const emitted = new Map<number, number[]>(), sessions = new Map<number, Session>(), pending: Promise<unknown>[] = [];
      const abort = new AbortController();
      let highWater = 0;
      const submit = (position: number) => {
        const index = order[position]!, fill = session(index, plans[index]!), options = { maxTokens, temperature: 0, fill };
        const plan = binding.plan(shape, options, { continuous: binding.cachesBatchable(), quantizedBatch: false, checkpoints: false });
        expect(plan).toMatchObject({ method: "autoregressive", mechanism: "continuous", fill: true });
        emitted.set(index, []); sessions.set(index, fill);
        pending.push(group.submit({ promptIds: prompts[index]!, maxTokens, eosTokenIds: eos, method: binding.methodRequest!(plan, options)!,
          signal: index === cancelled ? abort.signal : undefined,
          onToken(token) {
            highWater = Math.max(highWater, group.activeRows);
            const tokens = emitted.get(index)!; tokens.push(token);
            if (tokens.length === 1 && position + 1 < order.length) submit(position + 1);
            if (index === cancelled && tokens.length === 12) abort.abort(new Error("Gemma2 fill client left"));
          } }).then(stats => ({ index, stats }), error => ({ index, error })));
      };
      try {
        submit(0);
        let settled: { index: number; stats?: { finishReason: string }; error?: unknown }[] = [];
        for (let seen = 0; seen !== pending.length;) { seen = pending.length; settled = await Promise.all(pending) as typeof settled; }
        expect(settled).toHaveLength(order.length);
        expect(highWater).toBe(capacity);
        for (const { index, stats, error } of settled) {
          const want = expected[index]!, tokens = emitted.get(index)!;
          if (index === cancelled) {
            expect(error).toHaveProperty("message", "Gemma2 fill client left");
            expect(tokens).toEqual(want.tokens.slice(0, 12));
            continue;
          }
          expect(error).toBeUndefined();
          expect(tokens).toEqual(want.tokens);
          expect(stats!.finishReason).toBe(want.finish);
          const { strict, echo, injected, verifyAccepted, verifyRejected, spanLens } = sessions.get(index)!.stats;
          expect({ strict, echo, injected, verifyAccepted, verifyRejected, spanLens }).toEqual({ strict: want.stats.strict,
            echo: want.stats.echo, injected: want.stats.injected, verifyAccepted: want.stats.verifyAccepted,
            verifyRejected: want.stats.verifyRejected, spanLens: want.stats.spanLens });
          // B1 is the preserved lane: every logits row is main's, bit for bit.
          if (capacity === 1) expect(logits).toEqual(want.logits);
        }
      } finally { model.logitsFromHidden = logitsFromHidden; await group.close(); }
    }
  } finally { weights.dispose(); }
}, 600_000);


test.skipIf(!native || !artifact)("cached Gemma2 two-model speculation keeps B1 deterministic and serves ragged joins, cancellation and a clean follow-on", async () => {
  const { Weights, loadModelConfig, createModel } = await import("../../../src/index");
  const { bindMlxGateway, createRuntimeConfig } = await import("../../../src/execution");
  const { TwoModelProvider } = await import("../../../src/generation/speculative");
  const { loadTokenizer } = await import("../../../src/input");
  const { compileGrammarRequest, makeStepSampler } = await import("../../../src/sampling");
  const { createRowSampling } = await import("../../../src/execution");
  // The target and the draft are two independently loaded instances of the artifact.
  const weights = await Weights.open(artifact!);
  let draft: Awaited<ReturnType<typeof TwoModelProvider.load>> | undefined;
  try {
    draft = await TwoModelProvider.load(artifact!);
    const model = createModel(weights, await loadModelConfig(artifact!)) as UniversalDenseModel;
    expect(draft!.model).not.toBe(model);
    const tokenizer = await loadTokenizer(artifact!);
    const eos = model.config.eosTokenIds;
    const prompt = (text: string) => [2, ...tokenizer.encode(`<start_of_turn>user\n${text}<end_of_turn>\n<start_of_turn>model\n`, false)];
    const prompts = [prompt("Write three short sentences about the ocean at night."),
      prompt("Summarize in three sentences why tide pools interest biologists, with one example species."),
      prompt("List four facts about the Moon, one per line.")];
    // Target forward geometry, measured (the draft instance is separate).
    const widths: number[] = [];
    const forwardHidden = model.forwardHidden.bind(model);
    model.forwardHidden = (ids: MlxArray, caches: Cache[]) => { widths.push(ids.shape[0]!); return forwardHidden(ids, caches); };
    const binding = bindMlxGateway(model, { provider: draft!, numDraftTokens: 3 });
    const shape = { hasVision: false, hasAdapters: false, hasRepetitionPenalty: false, userSeed: false, kvQuant: false,
      turboQuant: false, hasLogitsExtras: false, hasGrammar: false, wantsLogprobs: false, hasDraft: true };
    const options = { maxTokens: 32, temperature: 0 };
    const plan = binding.plan(shape, options, { continuous: binding.cachesBatchable(), quantizedBatch: false, checkpoints: false });
    expect(plan).toMatchObject({ method: "speculative", mechanism: "continuous" });
    const runtime = createRuntimeConfig({ MLX_BUN_PREFILL_TAIL_SPLIT: "1", MLX_BUN_COMPILED_DECODE: "0" });
    const group = binding.createBatchGroup({ maxBatch: 4, prefillChunkSize: 512, runtime });
    const submit = (index: number, hooks: { signal?: AbortSignal; onToken?: (tokens: number[]) => void } = {}) => {
      const tokens: number[] = [];
      const done = group.submit({ promptIds: prompts[index]!, maxTokens: options.maxTokens, eosTokenIds: eos,
        method: binding.methodRequest!(plan, options)!, signal: hooks.signal,
        onToken(token) { tokens.push(token); hooks.onToken?.(tokens); } })
        .then(stats => ({ tokens, stats, error: undefined as unknown }), error => ({ tokens, stats: undefined, error }));
      return done;
    };
    try {
      // B1: one request alone, twice; the second must reproduce the first.
      const solo = await submit(0), again = await submit(0);
      expect(solo.error).toBeUndefined();
      expect(again.error).toBeUndefined();
      expect(again.tokens).toEqual(solo.tokens);
      const soloWidths = new Set(widths); widths.length = 0;
      expect([...soloWidths]).toEqual([1]);
      // Ragged join: row 1 (a longer prompt) joins after row 0's first token;
      // row 2 joins after row 1's first token and is cancelled after 6 tokens.
      const abort = new AbortController();
      const joined1 = Promise.withResolvers<ReturnType<typeof submit>>(), joined2 = Promise.withResolvers<ReturnType<typeof submit>>();
      const first = submit(0, { onToken: tokens => { if (tokens.length === 1) joined1.resolve(submit(1, { onToken: next => {
        if (next.length === 1) joined2.resolve(submit(2, { signal: abort.signal,
          onToken: third => { if (third.length === 6) abort.abort(new DOMException("client left", "AbortError")); } }));
      } })); } });
      const [survivor, row1, row2] = await Promise.all([first, joined1.promise.then(row => row), joined2.promise.then(row => row)]);
      expect(survivor.error).toBeUndefined(); expect(row1.error).toBeUndefined();
      expect(survivor.stats!.generatedTokens).toBe(survivor.tokens.length);
      expect(row1.stats!.generatedTokens).toBe(row1.tokens.length);
      expect(row2.error).toBeInstanceOf(DOMException);
      expect((row2.error as DOMException).name).toBe("AbortError");
      expect(row2.tokens.length).toBeGreaterThanOrEqual(6);
      // The pair really shared target forwards; the width is measured, not assumed.
      const shared = Math.max(...widths);
      expect(shared).toBeGreaterThanOrEqual(2);
      console.info("Gemma2 two-model ragged group", { maxTargetBatch: shared,
        survivorEqualsSolo: JSON.stringify(survivor.tokens) === JSON.stringify(solo.tokens) });
      // A clean follow-on: alone again, it reproduces the fresh B1 run exactly.
      widths.length = 0;
      const followOn = await submit(0);
      expect(followOn.error).toBeUndefined();
      expect(followOn.tokens).toEqual(solo.tokens);
      expect([...new Set(widths)]).toEqual([1]);
      // Main's gate: greedy grammar with speculation equals greedy grammar alone.
      // Drafts run free; the target's mask rides the verifier's accept walk, so
      // grammar-invalid drafts are genuinely rejected.
      let rejected = 0;
      for (const [body, valid, terminates] of [
        [{ guided_choice: ["Paris", "Lisbon", "Kyoto"] }, /^(Paris|Lisbon|Kyoto)$/, true],
        [{ guided_grammar: 'root ::= ("yes" | "no") ", " [a-z] [a-z] [a-z]*' }, /^(yes|no), [a-z]{2,}$/, false],
      ] as const) {
        const constrained = async (speculate: boolean) => {
          const compiled = await compileGrammarRequest(body as never, tokenizer, model.config.text.vocabSize);
          const grammar = compiled?.controller;
          if (!grammar) throw new Error(`grammar did not compile: ${compiled?.degradeHint}`);
          const tokens: number[] = [];
          try {
            const request = { ...options, maxTokens: 16, grammar };
            const grammarShape = { ...shape, hasGrammar: true, hasDraft: speculate };
            const placed = binding.plan(grammarShape, request, { continuous: true, quantizedBatch: false, checkpoints: false });
            expect(placed).toMatchObject({ method: speculate ? "speculative" : "autoregressive", mechanism: "continuous" });
            const ordinary = speculate ? undefined : createRowSampling(makeStepSampler(request, { tokenRepresentation: "device",
              grammarWait: "external", historyUpdate: "after-sample", initialHistory: prompts[2]! }), token => { tokens.push(token); });
            try {
              const stats = await group.submit({ promptIds: prompts[2]!, maxTokens: 16, eosTokenIds: eos, grammar,
                ...(speculate ? { method: binding.methodRequest!(placed, request)!, onToken: (token: number) => { tokens.push(token); } }
                  : { sample: ordinary!.sample, plainGreedy: ordinary!.plainGreedy, onToken: ordinary!.onToken }) });
              return { tokens, finish: stats.finishReason, terminated: grammar.isTerminated, spec: stats.spec };
            } finally { ordinary?.dispose(); }
          } finally { grammar.dispose(); }
        };
        const alone = await constrained(false), speculated = await constrained(true);
        const { spec, ...output } = speculated, { spec: ordinary, ...plain } = alone;
        expect(ordinary).toBeUndefined();
        expect(output).toEqual(plain);
        expect(valid.test(tokenizer.decode(alone.tokens, true))).toBe(true);
        if (terminates) expect({ finish: alone.finish, terminated: alone.terminated }).toEqual({ finish: "stop", terminated: true });
        else {
          // The longer grammar really speculated: drafted tokens over verify rounds.
          expect(spec!.drafted).toBeGreaterThan(0);
          expect(spec!.rounds ?? spec!.targetCalls).toBeGreaterThan(0);
        }
        rejected += spec!.rejected ?? spec!.drafted - spec!.accepted;
        console.info("Gemma2 grammar speculation", { grammar: Object.keys(body)[0], tokens: alone.tokens.length,
          text: tokenizer.decode(alone.tokens, true), spec });
      }
      // Across the constrained corpus at least one proposal was rejected.
      expect(rejected).toBeGreaterThan(0);
      expect(group.activeRows + group.pendingRows).toBe(0);
    } finally { await group.close(); }
  } finally { draft?.dispose(); weights.dispose(); }
}, 900_000);


test.skipIf(!native || !artifact)("cached Gemma2 n-gram speculation mixes empty and nonempty proposals, isolates a padded peer, and serves ragged joins, cancellation, grammar and seeded rows", async () => {
  const { Weights, loadModelConfig, createModel } = await import("../../../src/index");
  const { bindMlxGateway, createRuntimeConfig, createRowSampling } = await import("../../../src/execution");
  const { NgramProvider } = await import("../../../src/generation/speculative");
  const { loadTokenizer } = await import("../../../src/input");
  const { compileGrammarRequest, makeStepSampler } = await import("../../../src/sampling");
  const weights = await Weights.open(artifact!);
  try {
    const model = createModel(weights, await loadModelConfig(artifact!)) as UniversalDenseModel;
    const tokenizer = await loadTokenizer(artifact!);
    const eos = model.config.eosTokenIds;
    const turn = (user: number[]) => [2, ...tokenizer.encode("<start_of_turn>user\n", false), ...user,
      ...tokenizer.encode("<end_of_turn>\n<start_of_turn>model\n", false)];
    const prompt = (text: string) => turn(tokenizer.encode(text, false));
    // Swapped peers have one length: the first 16 user tokens of different text.
    const peer = (text: string) => {
      const ids = tokenizer.encode(text, false);
      if (ids.length < 16) throw new Error(`peer text is shorter than 16 tokens: ${text}`);
      return turn(ids.slice(0, 16));
    };
    const copy = prompt("Copy this list exactly, keeping every comma: red apples, green pears, warm bread, a blue kite, " +
      "seven paper boats, an old clock, a quiet train, fresh snow, two owls, a tall pine, a stone bridge.");
    const story = peer("Write a long, winding story about a lighthouse keeper who discovers an old map hidden inside a wall.");
    const glass = peer("Describe in rich detail how glassblowers in Venice shaped molten sand into delicate vases and bowls.");
    const bread = prompt("Explain step by step how bread dough rises overnight in a bakery.");
    const moon = prompt("List four facts about the Moon, one per line.");
    // Measured, not assumed: every target forward's rows x positions, each
    // round's proposal length per row, and (while capturing) a hash of row 0's
    // logits at every projected position. The gateway binds these methods, so
    // the hooks go in first.
    const forwards: string[] = [], rounds: number[][] = [], rowZero: string[] = [];
    let capture = false;
    const forwardHidden = model.forwardHidden.bind(model), logitsFromHidden = model.logitsFromHidden.bind(model);
    model.forwardHidden = (...args: Parameters<typeof forwardHidden>) => {
      forwards.push(`${args[0].shape[0]}x${args[0].shape[1]}`);
      return forwardHidden(...args);
    };
    model.logitsFromHidden = (...args: Parameters<typeof logitsFromHidden>) => {
      const out = logitsFromHidden(...args);
      if (capture) {
        using row = out.slice([0, 0, 0], [1, out.shape[1]!, out.shape[2]!]);
        using flat = ops.contiguous(row);
        rowZero.push(createHash("sha256").update(flat.rawBytes()).digest("hex"));
      }
      return out;
    };
    const recorded = (policy?: { max: number; min: number }) => {
      const provider = new NgramProvider(policy), open = provider.grouped.open.bind(provider.grouped);
      Object.assign(provider.grouped, { open: (options: Parameters<typeof open>[0]) => {
        const rows = open(options), draft = rows.draft.bind(rows);
        rows.draft = (pending, depth, steps) => {
          const proposals = draft(pending, depth, steps);
          if (proposals instanceof Promise) throw new Error("n-gram lookup proposes synchronously");
          rounds.push(proposals.map(ids => ids.length));
          return proposals;
        };
        return rows;
      } });
      return provider;
    };
    // Lookup policies are served knobs: the default (3..1), and a 4-gram policy
    // under which novel-text peers propose nothing. Ten draft tokens is the
    // served n-gram default.
    const lookup = bindMlxGateway(model, { provider: recorded(), numDraftTokens: 10 });
    const strict = bindMlxGateway(model, { provider: recorded({ max: 4, min: 4 }), numDraftTokens: 10 });
    const runtime = createRuntimeConfig({ MLX_BUN_PREFILL_TAIL_SPLIT: "1", MLX_BUN_COMPILED_DECODE: "0" });
    const shape = { hasVision: false, hasAdapters: false, hasRepetitionPenalty: false, userSeed: false, kvQuant: false,
      turboQuant: false, hasLogitsExtras: false, hasGrammar: false, wantsLogprobs: false, hasDraft: true };
    const greedy: GenerateOptions = { maxTokens: 32, temperature: 0 };
    const seeded: GenerateOptions = { maxTokens: 32, temperature: 0.7, seed: 7 };
    type Row = { prompt: number[]; options?: GenerateOptions; joinOnFirst?: number; cancelAt?: number; stopAt?: number };
    // One group per scenario. A row may join at another row's first token and
    // may be cancelled or stopped at an emitted count. Each row's mark records
    // what had been measured when it emitted its last token.
    const scenario = async (binding: typeof lookup, spec: Row[]) => {
      forwards.length = 0; rounds.length = 0; rowZero.length = 0;
      const group = binding.createBatchGroup({ maxBatch: 4, prefillChunkSize: 512, runtime });
      const outcomes = spec.map(() => ({ tokens: [] as number[], error: undefined as unknown,
        stats: undefined as Awaited<ReturnType<typeof group.submit>> | undefined, mark: { forwards: 0, rounds: 0, projections: 0 } }));
      const started: Promise<void>[] = [];
      const start = (index: number) => {
        const row = spec[index]!, outcome = outcomes[index]!, options = row.options ?? greedy, abort = new AbortController();
        const plan = binding.plan({ ...shape, userSeed: options.seed !== undefined }, options,
          { continuous: binding.cachesBatchable(), quantizedBatch: false, checkpoints: false });
        expect(plan).toMatchObject({ method: "speculative", mechanism: "continuous" });
        started.push(group.submit({ promptIds: row.prompt, maxTokens: options.maxTokens!, eosTokenIds: eos, signal: abort.signal,
          method: binding.methodRequest!(plan, options)!,
          onToken(token) {
            outcome.tokens.push(token);
            outcome.mark = { forwards: forwards.length, rounds: rounds.length, projections: rowZero.length };
            if (outcome.tokens.length === 1) spec.forEach((other, joiner) => { if (other.joinOnFirst === index) start(joiner); });
            if (row.cancelAt === outcome.tokens.length) abort.abort(new DOMException("client left", "AbortError"));
            return row.stopAt === outcome.tokens.length ? false : undefined;
          } }).then(stats => { outcome.stats = stats; }, error => { outcome.error = error; }));
      };
      spec.forEach((row, index) => { if (row.joinOnFirst === undefined) start(index); });
      try {
        for (let seen = -1; seen !== started.length;) { seen = started.length; await Promise.all([...started]); }
        return { outcomes, forwards: [...forwards], rounds: rounds.map(round => [...round]), rowZero: [...rowZero],
          leftover: group.activeRows + group.pendingRows };
      } finally { await group.close(); }
    };
    const width = (run: Awaited<ReturnType<typeof scenario>>) => Math.max(...run.forwards.map(forward => Number(forward.split("x")[0])));
    // Every row settled with statistics and output; an unstarted join would not.
    const succeeded = (run: Awaited<ReturnType<typeof scenario>>) => {
      for (const outcome of run.outcomes) {
        expect(outcome.error).toBeUndefined();
        expect(outcome.stats).toBeDefined();
        expect(outcome.tokens.length).toBeGreaterThan(0);
      }
      expect(run.leftover).toBe(0);
    };

    // B1: alone, greedy and seeded, twice each; the repeat reproduces the first.
    const solo: Record<string, number[]> = {};
    for (const [label, options] of [["greedy", greedy], ["seeded", seeded]] as const) {
      const first = await scenario(lookup, [{ prompt: copy, options }]), again = await scenario(lookup, [{ prompt: copy, options }]);
      for (const run of [first, again]) { succeeded(run); expect(width(run)).toBe(1); }
      expect(again.outcomes[0]!.tokens).toEqual(first.outcomes[0]!.tokens);
      expect(first.outcomes[0]!.stats!.spec!.drafted).toBeGreaterThan(0);
      solo[label] = first.outcomes[0]!.tokens;
    }

    // A padded peer: the copying target proposes spans while a novel-text peer
    // (joined at the target's first token) proposes nothing and is padded.
    // Swapping the peer's content leaves the target's geometry, proposals,
    // tokens and every logits row it was projected in unchanged.
    capture = true;
    const peers: Record<string, number[]> = {};
    for (const [label, options, peerOptions] of [["greedy", greedy, greedy], ["seeded", seeded, { ...seeded, seed: 9 }]] as const) {
      const base = await scenario(strict, [{ prompt: copy, options }, { prompt: story, options: peerOptions, joinOnFirst: 0 }]);
      const swap = await scenario(strict, [{ prompt: copy, options }, { prompt: glass, options: peerOptions, joinOnFirst: 0 }]);
      for (const run of [base, swap]) { succeeded(run); expect(width(run)).toBe(2); }
      const target = base.outcomes[0]!.mark;
      expect(swap.outcomes[0]!.mark).toEqual(target);
      expect(swap.forwards.slice(0, target.forwards)).toEqual(base.forwards.slice(0, target.forwards));
      expect(swap.rounds.slice(0, target.rounds)).toEqual(base.rounds.slice(0, target.rounds));
      expect(swap.outcomes[0]!.tokens).toEqual(base.outcomes[0]!.tokens);
      expect(swap.rowZero.slice(0, target.projections)).toEqual(base.rowZero.slice(0, target.projections));
      expect(swap.outcomes[1]!.tokens).not.toEqual(base.outcomes[1]!.tokens);
      peers[label] = base.outcomes[1]!.tokens;
      const shared = base.rounds.slice(0, target.rounds).filter(round => round.length === 2);
      const padded = shared.filter(([target, peer]) => target! > 0 && peer === 0).length;
      const empty = shared.filter(round => round.every(length => length === 0)).length;
      console.info("Gemma2 n-gram padded peer", { label, sharedRounds: shared.length, padded, empty,
        forwards: [...new Set(base.forwards.slice(0, target.forwards))] });
      // Mixed lengths including empty, and all-empty rounds, both at two rows.
      expect(padded).toBeGreaterThan(0);
      expect(empty).toBeGreaterThan(0);
      expect(base.forwards.slice(0, target.forwards)).toContain("2x1");
    }
    // Seeded sampling is live: the same peer, joined at the same point, samples
    // a different continuation than greedy decoding.
    expect(peers.seeded).not.toEqual(peers.greedy);
    capture = false;

    // Ragged joins: the peer joins at the target's first token and a third row
    // at the peer's first token; the third is cancelled at its third token. A
    // control stops it at that count: survivors, every forward and every
    // round's proposals match, the group drains, and B1 afterwards is unchanged.
    const three = (last: Partial<Row>): Row[] => [{ prompt: copy }, { prompt: story, joinOnFirst: 0 }, { prompt: bread, joinOnFirst: 1, ...last }];
    const cancelled = await scenario(lookup, three({ cancelAt: 3 })), stopped = await scenario(lookup, three({ stopAt: 3 }));
    succeeded(stopped);
    expect(cancelled.leftover).toBe(0);
    expect(cancelled.outcomes[2]!.error).toBeInstanceOf(DOMException);
    expect((cancelled.outcomes[2]!.error as DOMException).name).toBe("AbortError");
    // Publication checks the signal first: nothing is emitted after the abort.
    expect(stopped.outcomes[2]!.tokens).toHaveLength(3);
    expect(cancelled.outcomes[2]!.tokens).toEqual(stopped.outcomes[2]!.tokens);
    for (const survivor of [0, 1]) {
      expect(cancelled.outcomes[survivor]!.error).toBeUndefined();
      expect(cancelled.outcomes[survivor]!.tokens).toEqual(stopped.outcomes[survivor]!.tokens);
    }
    expect(width(cancelled)).toBe(3);
    expect(cancelled.forwards).toEqual(stopped.forwards);
    expect(cancelled.rounds).toEqual(stopped.rounds);
    console.info("Gemma2 n-gram ragged join", { rounds: cancelled.rounds.length,
      mixed: cancelled.rounds.filter(round => round.some(length => length === 0) && round.some(length => length > 0)).length });
    const followOn = await scenario(lookup, [{ prompt: copy }]);
    succeeded(followOn);
    expect(width(followOn)).toBe(1);
    expect(followOn.outcomes[0]!.tokens).toEqual(solo.greedy!);

    // Main's gate: greedy grammar with speculation equals greedy grammar alone.
    // Lookup drafts run free; the target's mask rides the verifier's accept
    // walk, so grammar-invalid drafts are rejected, and the grammar changes
    // what the same speculative request emits without it.
    const group = lookup.createBatchGroup({ maxBatch: 4, prefillChunkSize: 512, runtime });
    try {
      let rejected = 0;
      const unconstrained: number[] = [];
      await group.submit({ promptIds: moon, maxTokens: 16, eosTokenIds: eos, onToken: token => { unconstrained.push(token); },
        method: lookup.methodRequest!(lookup.plan(shape, { maxTokens: 16, temperature: 0 },
          { continuous: true, quantizedBatch: false, checkpoints: false }), { maxTokens: 16, temperature: 0 })! });
      for (const [body, valid, terminates] of [
        [{ guided_choice: ["Paris", "Lisbon", "Kyoto"] }, /^(Paris|Lisbon|Kyoto)$/, true],
        [{ guided_grammar: 'root ::= ("yes" | "no") ", " [a-z] [a-z] [a-z]*' }, /^(yes|no), [a-z]{2,}$/, false],
      ] as const) {
        const constrained = async (speculate: boolean) => {
          const compiled = await compileGrammarRequest(body as never, tokenizer, model.config.text.vocabSize);
          const grammar = compiled?.controller;
          if (!grammar) throw new Error(`grammar did not compile: ${compiled?.degradeHint}`);
          const tokens: number[] = [];
          try {
            const request = { maxTokens: 16, temperature: 0, grammar };
            const placed = lookup.plan({ ...shape, hasGrammar: true, hasDraft: speculate }, request,
              { continuous: true, quantizedBatch: false, checkpoints: false });
            expect(placed).toMatchObject({ method: speculate ? "speculative" : "autoregressive", mechanism: "continuous" });
            const ordinary = speculate ? undefined : createRowSampling(makeStepSampler(request, { tokenRepresentation: "device",
              grammarWait: "external", historyUpdate: "after-sample", initialHistory: moon }), token => { tokens.push(token); });
            try {
              const stats = await group.submit({ promptIds: moon, maxTokens: 16, eosTokenIds: eos, grammar,
                ...(speculate ? { method: lookup.methodRequest!(placed, request)!, onToken: (token: number) => { tokens.push(token); } }
                  : { sample: ordinary!.sample, plainGreedy: ordinary!.plainGreedy, onToken: ordinary!.onToken }) });
              return { tokens, finish: stats.finishReason, terminated: grammar.isTerminated, spec: stats.spec };
            } finally { ordinary?.dispose(); }
          } finally { grammar.dispose(); }
        };
        const alone = await constrained(false), speculated = await constrained(true);
        const { spec, ...output } = speculated, { spec: ordinary, ...plain } = alone;
        expect(ordinary).toBeUndefined();
        expect(output).toEqual(plain);
        expect(valid.test(tokenizer.decode(alone.tokens, true))).toBe(true);
        expect(speculated.tokens).not.toEqual(unconstrained.slice(0, speculated.tokens.length));
        if (terminates) expect({ finish: alone.finish, terminated: alone.terminated }).toEqual({ finish: "stop", terminated: true });
        else {
          expect(spec!.drafted).toBeGreaterThan(0);
          expect(spec!.rounds ?? spec!.targetCalls).toBeGreaterThan(0);
        }
        rejected += spec!.rejected ?? spec!.drafted - spec!.accepted;
        console.info("Gemma2 n-gram grammar speculation", { grammar: Object.keys(body)[0], tokens: alone.tokens.length,
          text: tokenizer.decode(alone.tokens, true), spec });
      }
      expect(rejected).toBeGreaterThan(0);
      expect(group.activeRows + group.pendingRows).toBe(0);
    } finally { await group.close(); }
  } finally { weights.dispose(); }
}, 900_000);


test.skipIf(!native || !artifact)("a structurally equivalent delegating provider reproduces direct n-gram speculation through joins, cancellation and drain", async () => {
  const { Weights, loadModelConfig, createModel } = await import("../../../src/index");
  const { bindMlxGateway, createRuntimeConfig } = await import("../../../src/execution");
  const { NgramProvider } = await import("../../../src/generation/speculative");
  const { loadTokenizer } = await import("../../../src/input");
  const weights = await Weights.open(artifact!);
  try {
    const model = createModel(weights, await loadModelConfig(artifact!)) as UniversalDenseModel;
    const tokenizer = await loadTokenizer(artifact!);
    const eos = model.config.eosTokenIds;
    const prompt = (text: string) => [2, ...tokenizer.encode(`<start_of_turn>user\n${text}<end_of_turn>\n<start_of_turn>model\n`, false)];
    const prompts = [prompt("Copy this list exactly: red apples, green pears, warm bread, a blue kite, seven paper boats, an old clock."),
      prompt("Write a long, winding story about a lighthouse keeper who discovers an old map hidden inside a wall."),
      prompt("Explain step by step how bread dough rises overnight in a bakery.")];
    // Every target forward's geometry and every projection's exact bytes.
    const forwards: string[] = [], logits: string[] = [];
    const forwardHidden = model.forwardHidden.bind(model), logitsFromHidden = model.logitsFromHidden.bind(model);
    model.forwardHidden = (...args: Parameters<typeof forwardHidden>) => { forwards.push(args[0].shape.join("x")); return forwardHidden(...args); };
    model.logitsFromHidden = (...args: Parameters<typeof logitsFromHidden>) => {
      const out = logitsFromHidden(...args);
      using flat = ops.contiguous(out);
      logits.push(createHash("sha256").update(flat.rawBytes()).digest("hex"));
      return out;
    };
    /** The n-gram provider's operations behind a plain object: no class identity, same contracts. */
    const delegating = (): DraftProvider => {
      const inner = new NgramProvider(), grouped = inner.grouped;
      return { id: "ngram-delegate", weightsBytes: 0, open: options => inner.open(options), dispose: () => inner.dispose(),
        grouped: { checkpointNamespace: () => grouped.checkpointNamespace!(), supportsTargetAdapters: grouped.supportsTargetAdapters,
          open: options => grouped.open(options), openPrefill: options => grouped.openPrefill(options) } };
    };
    const runtime = createRuntimeConfig({ MLX_BUN_PREFILL_TAIL_SPLIT: "1", MLX_BUN_COMPILED_DECODE: "0" });
    const shape = { hasVision: false, hasAdapters: false, hasRepetitionPenalty: false, userSeed: false, kvQuant: false,
      turboQuant: false, hasLogitsExtras: false, hasGrammar: false, wantsLogprobs: false, hasDraft: true };
    const options = { maxTokens: 24, temperature: 0 };
    // Row 0 first runs alone (the fresh B1 baseline). Then row 0 leads again,
    // row 1 joins at its first token and row 2 at row 1's first token, cancelled
    // at its third; the group drains, and row 0 reruns alone (the recovery).
    const run = async (provider: DraftProvider) => {
      const binding = bindMlxGateway(model, { provider, numDraftTokens: 10 });
      const plan = binding.plan(shape, options, { continuous: binding.cachesBatchable(), quantizedBatch: false, checkpoints: false });
      expect(plan).toMatchObject({ method: "speculative", mechanism: "continuous" });
      const group = binding.createBatchGroup({ maxBatch: 4, prefillChunkSize: 512, runtime });
      forwards.length = 0; logits.length = 0;
      const rows = prompts.map(() => ({ tokens: [] as number[], error: null as string | null, spec: undefined as unknown }));
      const alone = async () => {
        const tokens: number[] = [];
        forwards.length = 0; logits.length = 0;
        const stats = await group.submit({ promptIds: prompts[0]!, maxTokens: options.maxTokens, eosTokenIds: eos,
          method: binding.methodRequest!(plan, options)!, onToken: token => { tokens.push(token); } });
        return { tokens, spec: stats.spec, forwards: [...forwards], logits: [...logits] };
      };
      try {
        const reference = await alone();
        forwards.length = 0; logits.length = 0;
        const abort = new AbortController(), started: Promise<void>[] = [];
        const submit = (index: number) => {
          started.push(group.submit({ promptIds: prompts[index]!, maxTokens: options.maxTokens, eosTokenIds: eos,
            method: binding.methodRequest!(plan, options)!, signal: index === 2 ? abort.signal : undefined,
            onToken(token) {
              const row = rows[index]!; row.tokens.push(token);
              if (row.tokens.length === 1 && index < 2) submit(index + 1);
              if (index === 2 && row.tokens.length === 3) abort.abort(new DOMException("client left", "AbortError"));
            } }).then(stats => { rows[index]!.spec = stats.spec; }, error => { rows[index]!.error = (error as Error).name; }));
        };
        submit(0);
        for (let seen = -1; seen !== started.length;) { seen = started.length; await Promise.all([...started]); }
        const drained = group.activeRows + group.pendingRows;
        const grouped = { forwards: [...forwards], logits: [...logits] };
        const recovery = await alone();
        return { reference, rows, drained, recovery, ...grouped };
      } finally { await group.close(); }
    };
    const direct = await run(new NgramProvider()), delegated = await run(delegating());
    // Speculation actually ran: proposals were drafted, and some accepted and some rejected.
    const completed = [direct.reference.spec, direct.rows[0]!.spec, direct.rows[1]!.spec, direct.recovery.spec] as
      ({ drafted: number; accepted: number; rejected?: number; rounds?: number } | undefined)[];
    const total = (field: "drafted" | "accepted" | "rejected") => completed.reduce((sum, spec) =>
      sum + (field === "rejected" ? spec?.rejected ?? (spec ? spec.drafted - spec.accepted : 0) : spec?.[field] ?? 0), 0);
    const leadEqualsReference = JSON.stringify(direct.rows[0]!.tokens) === JSON.stringify(direct.reference.tokens);
    console.info("Gemma2 delegating provider", { maxTargetBatch: Math.max(...direct.forwards.map(forward => Number(forward.split("x")[0]))),
      drafted: total("drafted"), accepted: total("accepted"), rejected: total("rejected"), leadEqualsReference,
      recoveryEqualsLead: JSON.stringify(direct.recovery.tokens) === JSON.stringify(direct.rows[0]!.tokens),
      recoveryEqualsReference: JSON.stringify(direct.recovery.tokens) === JSON.stringify(direct.reference.tokens),
      delegatedEqualsDirect: JSON.stringify(delegated) === JSON.stringify(direct) });
    expect(delegated).toEqual(direct);
    expect(direct.rows.map(row => row.error)).toEqual([null, null, "AbortError"]);
    expect(direct.rows[2]!.tokens).toHaveLength(3);
    expect(direct.drained).toBe(0);
    expect(Math.max(...direct.forwards.map(forward => Number(forward.split("x")[0])))).toBe(3);
    expect(completed.every(spec => (spec?.rounds ?? spec?.drafted ?? 0) > 0)).toBe(true);
    expect([total("drafted") > 0, total("accepted") > 0, total("rejected") > 0]).toEqual([true, true, true]);
    // Recovery after the drain reproduces the fresh B1 run exactly: tokens, every
    // forward and every logits row. The lead inside the ragged group is only recorded.
    expect(direct.recovery).toEqual(direct.reference);
  } finally { weights.dispose(); }
}, 900_000);

}
