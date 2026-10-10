// C1 bit-identity gate. The Qwen 3.5 graph whose blocks read through the cache
// for the phase their caller names (models/qwen/blocks.ts) against the frozen
// pre-C1 graph (qwen3_5-reference.ts, deleted with this test after the merge),
// on small synthetic weights: 64 layers in the 27B pattern (48 DeltaNet, 16
// attention), once with Trellis MLPs and once with affine MLPs. Every hidden
// output, every logit row and every cache tensor must agree to the bit, for
// bf16 KV and for affine 4- and 8-bit KV converted after the first forward by
// kv-maintenance with MLX_BUN_NO_FUSED_SDPA unset (tiled kernel set) and set to
// 1 (unfused set). The phase operations (prefillChunk, prefillTail, decode,
// verify) run a third cache set and are held to the same bits. No model, no
// download.
import { afterAll, describe, expect, test } from "bun:test";
import { MlxArray } from "@mlx-bun/mlx/array";
import { Dtype, deviceArchitecture } from "@mlx-bun/mlx/ffi";
import * as ops from "@mlx-bun/mlx/ops";
import { parseQuantization, type ModelConfig } from "../../src/artifacts/config";
import type { Weights } from "../../src/artifacts/weights";
import type { BatchableCache, Cache, PaddedPrefillCache } from "../../src/contracts/mlx/cache";
import type { TokenGroup } from "../../src/contracts/mlx/token-work";
import { createRuntimeConfig, runtimeConfig, withRuntimeConfig } from "../../src/runtime/config";
import { createKvMaintenance } from "../../src/state/kv-maintenance";
import { targetCacheLayout } from "../../src/state/layout";
import { Qwen35Model } from "../../src/models/qwen/qwen3_5";
import { Qwen35Model as FrozenQwen35Model } from "./qwen3_5-reference";

const HIDDEN = 512, INTER = 256, VOCAB = 256, LAYERS = 64, HEADS = 4, KV_HEADS = 2, HEAD_DIM = 128;
const HK = 2, HV = 4, DK = 64, DV = 32, KERNEL = 4;
const KEY_DIM = HK * DK, VALUE_DIM = HV * DV, CONV_DIM = 2 * KEY_DIM + VALUE_DIM;
const PREFIX = "language_model.model";

const owned: MlxArray[] = [];
afterAll(() => { for (const array of owned) array.dispose(); });
const keep = (array: MlxArray) => { owned.push(array); return array; };

const noise = (count: number, phase: number, scale: number, shift = 0) => Float32Array.from({ length: count },
  (_, i) => shift + Math.sin(i * 0.37 + phase) * scale + Math.cos(i * 0.11 + 2.3 * phase) * scale);
const tensor = (values: Float32Array, shape: number[], dtype = Dtype.bfloat16): MlxArray => {
  using wide = MlxArray.fromFloat32(values, shape);
  return keep(wide.astype(dtype));
};

type MlpKind = "trellis" | "affine";

/** The synthetic artifact: tensors under the graph's canonical names and the
 *  config the graph reads. */
function artifact(kind: MlpKind): { weights: Weights; config: ModelConfig } {
  const tensors = new Map<string, MlxArray>();
  let seed = 1;
  const affine = (path: string, rows: number, cols: number, scale = 0.06) => {
    using w = tensor(noise(rows * cols, ++seed, scale), [rows, cols]);
    const q = ops.quantize(w, 64, 4);
    tensors.set(`${path}.weight`, keep(q.packed));
    tensors.set(`${path}.scales`, keep(q.scales));
    tensors.set(`${path}.biases`, keep(q.biases));
  };
  const norm = (path: string, width: number) => tensors.set(path, tensor(noise(width, ++seed, 0.05, 1), [width]));
  const quant: Record<string, unknown> = { bits: 4, group_size: 64, mode: "affine" };
  /** Packed Trellis codes: `stored` rows of `cols * k / 32` words (the layout
   *  tests/models/verify-layers.test.ts builds). */
  const trellis = (path: string, stored: number, cols: number, axis: 0 | 1, k: number) => {
    let state = ++seed * 7919;
    const words = cols * k / 32;
    using ints = MlxArray.fromInt32(Int32Array.from({ length: stored * words },
      () => state = Math.imul(state, 1664525) + 1013904223), [stored, words]);
    tensors.set(`${path}.weight`, keep(ints.astype(Dtype.uint32)));
    tensors.set(`${path}.scales`, tensor(Float32Array.from({ length: stored }, (_, i) => (i % 17 + 1) / 400), [stored], Dtype.float16));
    quant[path] = { bits: k, group_size: 256, mode: "trellis", trellis: { L: 12, code: "1mad", axis } };
  };

  affine(`${PREFIX}.embed_tokens`, VOCAB, HIDDEN, 0.5);
  affine("language_model.lm_head", VOCAB, HIDDEN, 0.05);
  norm(`${PREFIX}.norm.weight`, HIDDEN);
  for (let layer = 0; layer < LAYERS; layer++) {
    const prefix = `${PREFIX}.layers.${layer}`;
    norm(`${prefix}.input_layernorm.weight`, HIDDEN);
    norm(`${prefix}.post_attention_layernorm.weight`, HIDDEN);
    if ((layer + 1) % 4 !== 0) {
      const p = `${prefix}.linear_attn`;
      affine(`${p}.in_proj_qkv`, CONV_DIM, HIDDEN);
      affine(`${p}.in_proj_z`, VALUE_DIM, HIDDEN);
      affine(`${p}.in_proj_b`, HV, HIDDEN);
      affine(`${p}.in_proj_a`, HV, HIDDEN);
      affine(`${p}.out_proj`, HIDDEN, VALUE_DIM);
      tensors.set(`${p}.conv1d.weight`, tensor(noise(CONV_DIM * KERNEL, ++seed, 0.3), [CONV_DIM, KERNEL, 1]));
      tensors.set(`${p}.A_log`, tensor(noise(HV, ++seed, 0.5), [HV], Dtype.float32));
      tensors.set(`${p}.dt_bias`, tensor(noise(HV, ++seed, 0.5), [HV]));
      norm(`${p}.norm.weight`, DV);
    } else {
      const p = `${prefix}.self_attn`;
      affine(`${p}.q_proj`, HEADS * HEAD_DIM * 2, HIDDEN);
      affine(`${p}.k_proj`, KV_HEADS * HEAD_DIM, HIDDEN);
      affine(`${p}.v_proj`, KV_HEADS * HEAD_DIM, HIDDEN);
      affine(`${p}.o_proj`, HIDDEN, HEADS * HEAD_DIM);
      norm(`${p}.q_norm.weight`, HEAD_DIM);
      norm(`${p}.k_norm.weight`, HEAD_DIM);
    }
    const m = `${prefix}.mlp`;
    if (kind === "trellis") {
      // Same width on gate and up: the fused gate/up kernel serves M <= 4.
      trellis(`${m}.gate_proj`, INTER, HIDDEN, 1, 3);
      trellis(`${m}.up_proj`, INTER, HIDDEN, 1, 3);
      trellis(`${m}.down_proj`, INTER, HIDDEN, 0, 2);
    } else {
      affine(`${m}.gate_proj`, INTER, HIDDEN);
      affine(`${m}.up_proj`, INTER, HIDDEN);
      affine(`${m}.down_proj`, HIDDEN, INTER);
    }
  }
  const weights = {
    tensorNames: [...tensors.keys()],
    info: (name: string) => ({ shape: tensors.get(name)!.shape }),
    has: (name: string) => tensors.has(name),
    tensor: (name: string) => {
      const found = tensors.get(name);
      if (!found) throw new Error(`synthetic artifact has no ${name}`);
      return found;
    },
    shards: { files: new Map() },
    setView: () => { throw new Error("canonical names need no view"); },
  } as unknown as Weights;
  const config = {
    modelDir: "", modelType: "qwen3_5_text", architectures: [], dtype: "bfloat16", kvQuant: null,
    hasVisionSidecar: false, eosTokenIds: [], raw: {},
    quantization: parseQuantization(quant),
    text: {
      hiddenSize: HIDDEN, numHiddenLayers: LAYERS, numAttentionHeads: HEADS, numKeyValueHeads: KV_HEADS,
      headDim: HEAD_DIM, intermediateSize: INTER, rmsNormEps: 1e-6, vocabSize: VOCAB,
      linearNumKeyHeads: HK, linearNumValueHeads: HV, linearKeyHeadDim: DK, linearValueHeadDim: DV,
      linearConvKernelDim: KERNEL, fullAttentionInterval: 4, partialRotaryFactor: 0.25,
      ropeParameters: { full_attention: { ropeTheta: 10_000_000, ropeType: "default", partialRotaryFactor: 0.25, factor: 1 } },
      tieWordEmbeddings: false,
    },
  } as unknown as ModelConfig;
  return { weights, config };
}

/** createAppend's eligibility reads the 27B geometry from the config. Both
 *  graphs get the same stand-in so its committed-append forward runs on these
 *  weights; nothing else in a text forward reads these fields. */
function as27b(model: { config: ModelConfig }): void {
  const config = model.config;
  (model as { config: ModelConfig }).config = { ...config, text: { ...config.text,
    hiddenSize: 5120, intermediateSize: 17408, headDim: 256, numAttentionHeads: 24, numKeyValueHeads: 4 } };
}

// ── Comparison ──────────────────────────────────────────────────────────────

const results = new Map<string, { worst: number; tensors: number }>();
const record = (label: string, diff: number, tensors: number) => {
  const prior = results.get(label) ?? { worst: 0, tensors: 0 };
  results.set(label, { worst: Math.max(prior.worst, diff), tensors: prior.tensors + tensors });
};
afterAll(() => {
  for (const [label, { worst, tensors }] of results)
    console.log(`qwen35-identity ${label}: maxDiff ${worst} over ${tensors} tensors`);
});

/** Largest absolute difference after requiring equal shape, dtype and bytes. */
function maxDiff(actual: MlxArray, expected: MlxArray, what: string): number {
  expect(actual.shape, what).toEqual(expected.shape);
  expect(actual.dtype, what).toBe(expected.dtype);
  using left = ops.contiguous(actual);
  using right = ops.contiguous(expected);
  const a = left.rawBytesView(), b = right.rawBytesView();
  if (Buffer.from(a.buffer, a.byteOffset, a.byteLength).equals(Buffer.from(b.buffer, b.byteOffset, b.byteLength))) return 0;
  using leftWide = left.astype(Dtype.float32);
  using rightWide = right.astype(Dtype.float32);
  const x = leftWide.toFloat32(), y = rightWide.toFloat32();
  let worst = 0;
  for (let i = 0; i < x.length; i++) worst = Math.max(worst, Math.abs(x[i]! - y[i]!));
  throw new Error(`${what}: bytes differ, maxDiff ${worst}`);
}

/** Every tensor of every layer's cache, with its signature and offset. */
function stateDiff(label: string, actual: readonly Cache[], expected: readonly Cache[]): void {
  expect(actual.length).toBe(expected.length);
  let worst = 0, count = 0;
  for (let layer = 0; layer < expected.length; layer++) {
    const a = actual[layer]!, b = expected[layer]!;
    expect(a.signature(), `${label} layer ${layer}`).toBe(b.signature());
    expect(a.offset, `${label} layer ${layer}`).toBe(b.offset);
    expect((a as Partial<BatchableCache>).rowOffsets, `${label} layer ${layer}`).toEqual((b as Partial<BatchableCache>).rowOffsets);
    const left = a.state(), right = b.state();
    try {
      expect(left.length, `${label} layer ${layer}`).toBe(right.length);
      for (let i = 0; i < right.length; i++) { worst = Math.max(worst, maxDiff(left[i]!, right[i]!, `${label} layer ${layer} state ${i}`)); count++; }
    } finally {
      if (a.stateNeedsDispose) for (const array of left) array.dispose();
      if (b.stateNeedsDispose) for (const array of right) array.dispose();
    }
  }
  record(`${label} cache`, worst, count);
}

/** Hidden rows and their logits (both owned by the caller and disposed here). */
function outputDiff(label: string, model: Qwen35Model, actual: MlxArray, expected: MlxArray): void {
  try {
    const hidden = maxDiff(actual, expected, `${label} hidden`);
    using la = model.logitsFromHidden(actual);
    using lb = model.logitsFromHidden(expected);
    const logits = maxDiff(la, lb, `${label} logits`);
    using wide = lb.astype(Dtype.float32);
    expect(wide.toFloat32().every(Number.isFinite), `${label} logits finite`).toBe(true);
    record(`${label} hidden+logits`, Math.max(hidden, logits), 2);
  } finally { actual.dispose(); expected.dispose(); }
}

// ── Running both graphs ─────────────────────────────────────────────────────

const prompt = (n: number, salt: number) => Array.from({ length: n }, (_, i) => (i * 37 + salt * 11 + 5) % VOCAB);
const ids = (rows: number[][]) => ops.fromInt32(rows.flat(), [rows.length, rows[0]!.length]);

type Scheme = { name: string; kvBits: number | null; flag: string | undefined };
const SCHEMES: Scheme[] = [
  { name: "bf16", kvBits: null, flag: undefined },
  { name: "affine4 flag=unset", kvBits: 4, flag: undefined },
  { name: "affine4 flag=1", kvBits: 4, flag: "1" },
  { name: "affine8 flag=unset", kvBits: 8, flag: undefined },
  { name: "affine8 flag=1", kvBits: 8, flag: "1" },
];

/** The frozen and current graphs over one synthetic artifact. */
interface Pair { kind: MlpKind; old: FrozenQwen35Model; current: Qwen35Model }
const pairs = new Map<MlpKind, Pair>();
function pair(kind: MlpKind): Pair {
  let found = pairs.get(kind);
  if (!found) {
    const { weights, config } = artifact(kind);
    found = { kind, old: new FrozenQwen35Model(weights, config), current: new Qwen35Model(weights, config) };
    as27b(found.old); as27b(found.current);
    pairs.set(kind, found);
  }
  return found;
}

function withScheme<T>(scheme: Scheme, run: () => T): T {
  return withRuntimeConfig(createRuntimeConfig({ ...runtimeConfig().values, MLX_BUN_NO_FUSED_SDPA: scheme.flag }), run);
}

/** Convert after a forward, as the served path does (quantized_kv_start 0). */
function convert(scheme: Scheme, ...sets: Cache[][]): void {
  if (scheme.kvBits === null) return;
  const maintain = createKvMaintenance({ kvBits: scheme.kvBits, quantizedKvStart: 0 });
  for (const caches of sets) maintain(caches);
}

/** The old graph's and the current graph's deprecated entry point on the same input. */
function both(label: string, p: Pair, oldCaches: Cache[], newCaches: Cache[],
  run: (model: Qwen35Model | FrozenQwen35Model, caches: Cache[]) => MlxArray): void {
  const expected = run(p.old, oldCaches);
  const actual = run(p.current, newCaches);
  outputDiff(label, p.current, actual, expected);
  stateDiff(label, newCaches, oldCaches);
}

const forwardHidden = (rows: number[][]) => (model: Qwen35Model | FrozenQwen35Model, caches: Cache[]) => {
  using input = ids(rows);
  return model.forwardHidden(input, caches);
};

/** A capturing verify forward through `forwardHiddenMixed`; returns the final
 *  hidden and every captured layer (copies). */
function mixedVerify(model: Qwen35Model | FrozenQwen35Model, caches: Cache[], rows: number[][]): { hidden: MlxArray; taps: MlxArray[] } {
  using input = ids(rows);
  const taps: MlxArray[] = [];
  const group: TokenGroup = { ids: input, cache: caches, preserveTokenGeometry: true,
    captureLayer: (_layer, hidden) => { taps.push(ops.contiguous(hidden)); } };
  const [hidden] = model.forwardHiddenMixed([group]);
  return { hidden: hidden!, taps };
}

function tapsDiff(label: string, actual: MlxArray[], expected: MlxArray[]): void {
  try {
    expect(actual.length, label).toBe(LAYERS + 1);
    expect(expected.length, label).toBe(LAYERS + 1);
    let worst = 0;
    for (let i = 0; i < expected.length; i++) worst = Math.max(worst, maxDiff(actual[i]!, expected[i]!, `${label} layer ${i}`));
    record(`${label} captured layers`, worst, expected.length);
  } finally { for (const array of [...actual, ...expected]) array.dispose(); }
}

/** One committed append through the graph's createAppend (B=1, 1 to 4
 *  positions, or one position per row). */
function fill(model: Qwen35Model | FrozenQwen35Model, caches: Cache[], rows: number[][]): MlxArray {
  const append = model.createAppend({ hasAdapters: false, pagedKv: false });
  expect(append).not.toBeNull();
  using input = ids(rows);
  return append!.forwardHidden(input, caches);
}

/** Target row layouts holding `sources` (one serial cache list per row), the
 *  fill and speculative paths' storage. */
function rowsOf(sources: Cache[][]): Cache[] {
  return sources[0]!.map((cache, layer) => {
    const layout = targetCacheLayout(cache) as unknown as BatchableCache;
    layout.mergeRows(sources.map(source => source[layer]!));
    return layout;
  });
}

const disposeAll = (...sets: Cache[][]) => { for (const set of sets) for (const cache of set) cache.dispose(); };
const g16s = deviceArchitecture() === "applegpu_g16s";

for (const kind of ["trellis", "affine"] as const) {
  describe(`Qwen 3.5 blocks read through the cache: ${kind} MLP`, () => {
    for (const scheme of SCHEMES) {
      const tag = `${kind} ${scheme.name}`;

      test(`${tag}: prefill 37, decodes, window, verify with capture, rollback and replay, fill 1-4, phase operations`, () => withScheme(scheme, () => {
        const p = pair(kind);
        const oldCaches = p.old.makeCache(), newCaches = p.current.makeCache();
        // The phase operations run their own cache set against the old graph's
        // deprecated entry point on a reference set.
        const refCaches = p.old.makeCache(), phaseCaches = p.current.makeCache();
        const phased = (label: string, rows: number[][], operation: (input: MlxArray, caches: Cache[]) => MlxArray) => {
          using input = ids(rows);
          const expected = p.old.forwardHidden(input, refCaches);
          const actual = operation(input, phaseCaches);
          outputDiff(`${label} (phase operation)`, p.current, actual, expected);
          stateDiff(`${label} (phase operation)`, phaseCaches, refCaches);
        };
        try {
          const prefill = prompt(37, 1);
          both(`${tag} prefill37`, p, oldCaches, newCaches, forwardHidden([prefill]));
          phased(`${tag} prefillChunk37`, [prefill], (input, caches) => p.current.prefillChunk(input, caches));
          convert(scheme, oldCaches, newCaches, refCaches, phaseCaches);
          stateDiff(`${tag} converted`, newCaches, oldCaches);
          stateDiff(`${tag} converted (phase operation)`, phaseCaches, refCaches);

          for (let step = 0; step < 3; step++) {
            const token = [[300 % VOCAB + step]];
            both(`${tag} decode`, p, oldCaches, newCaches, forwardHidden(token));
            phased(`${tag} decode`, token, (input, caches) => p.current.decode.one(input, caches) as MlxArray);
          }

          both(`${tag} window5`, p, oldCaches, newCaches, forwardHidden([prompt(5, 2)]));
          phased(`${tag} prefillTail5`, [prompt(5, 2)], (input, caches) => p.current.prefillTail(input, caches));

          {
            const rows = [prompt(4, 3)];
            const expected = mixedVerify(p.old, oldCaches, rows);
            const actual = mixedVerify(p.current, newCaches, rows);
            tapsDiff(`${tag} verify4`, actual.taps, expected.taps);
            outputDiff(`${tag} verify4`, p.current, actual.hidden, expected.hidden);
            stateDiff(`${tag} verify4`, newCaches, oldCaches);
            // `verify` against the same capturing forward on the reference set.
            const reference = mixedVerify(p.old, refCaches, rows);
            using input = ids(rows);
            const taps: MlxArray[] = [];
            const hidden = p.current.verify.twoToFour(input, phaseCaches, (_layer, h) => { taps.push(ops.contiguous(h)); }) as MlxArray;
            tapsDiff(`${tag} verify4 (phase operation)`, taps, reference.taps);
            outputDiff(`${tag} verify4 (phase operation)`, p.current, hidden, reference.hidden);
            stateDiff(`${tag} verify4 (phase operation)`, phaseCaches, refCaches);
          }

          // A speculative round: arm, verify 5, keep 2 (recurrent replay, KV trim), decode.
          for (const set of [oldCaches, newCaches]) for (const cache of set) cache.specRoundBegin?.();
          {
            const rows = [prompt(5, 4)];
            const expected = mixedVerify(p.old, oldCaches, rows);
            const actual = mixedVerify(p.current, newCaches, rows);
            tapsDiff(`${tag} spec verify5`, actual.taps, expected.taps);
            outputDiff(`${tag} spec verify5`, p.current, actual.hidden, expected.hidden);
          }
          for (const set of [oldCaches, newCaches]) for (const cache of set) {
            if (cache.specRoundRollback) cache.specRoundRollback(2);
            else cache.trim(3);
          }
          stateDiff(`${tag} spec rollback keep 2`, newCaches, oldCaches);
          both(`${tag} decode after rollback`, p, oldCaches, newCaches, forwardHidden([[77]]));

          if (g16s) for (const span of [1, 2, 3, 4])
            both(`${tag} fill${span}`, p, oldCaches, newCaches, (model, caches) => fill(model, caches, [prompt(span, 5 + span)]));
          both(`${tag} decode after fill`, p, oldCaches, newCaches, forwardHidden([[91]]));

          // The fill path's storage: target row layouts of one row.
          if (g16s) {
            const oldRows = rowsOf([oldCaches]), newRows = rowsOf([newCaches]);
            try {
              stateDiff(`${tag} target rows`, newRows, oldRows);
              for (const span of [1, 2, 3, 4])
                both(`${tag} fill${span} (target rows)`, p, oldRows, newRows, (model, caches) => fill(model, caches, [prompt(span, 9 + span)]));
              both(`${tag} decode (target rows)`, p, oldRows, newRows, forwardHidden([[33]]));
            } finally { disposeAll(oldRows, newRows); }
          }
        } finally { disposeAll(oldCaches, newCaches, refCaches, phaseCaches); }
      }), 120_000);

      test(`${tag}: prefill 200, decodes, a window across the 256-position step`, () => withScheme(scheme, () => {
        const p = pair(kind);
        const oldCaches = p.old.makeCache(), newCaches = p.current.makeCache();
        try {
          both(`${tag} prefill200`, p, oldCaches, newCaches, forwardHidden([prompt(200, 6)]));
          convert(scheme, oldCaches, newCaches);
          for (let step = 0; step < 2; step++)
            both(`${tag} decode`, p, oldCaches, newCaches, forwardHidden([[11 + step]]));
          both(`${tag} window60 across 256`, p, oldCaches, newCaches, forwardHidden([prompt(60, 7)]));
          both(`${tag} decode`, p, oldCaches, newCaches, forwardHidden([[19]]));
        } finally { disposeAll(oldCaches, newCaches); }
      }), 120_000);

      test(`${tag}: two groups packed in one mixed forward`, () => withScheme(scheme, () => {
        const p = pair(kind);
        const oldA = p.old.makeCache(), newA = p.current.makeCache(), oldB = p.old.makeCache(), newB = p.current.makeCache();
        try {
          both(`${tag} group A prefill`, p, oldA, newA, forwardHidden([prompt(13, 8)]));
          both(`${tag} group B prefill`, p, oldB, newB, forwardHidden([prompt(7, 9)]));
          convert(scheme, oldA, newA, oldB, newB);
          const run = (model: Qwen35Model | FrozenQwen35Model, a: Cache[], b: Cache[]) => {
            using first = ids([[23]]);
            using second = ids([prompt(3, 10)]);
            return model.forwardHiddenMixed([{ ids: first, cache: a }, { ids: second, cache: b }]);
          };
          const expected = run(p.old, oldA, oldB);
          const actual = run(p.current, newA, newB);
          outputDiff(`${tag} mixed group A (decode)`, p.current, actual[0]!, expected[0]!);
          outputDiff(`${tag} mixed group B (window)`, p.current, actual[1]!, expected[1]!);
          stateDiff(`${tag} mixed group A`, newA, oldA);
          stateDiff(`${tag} mixed group B`, newB, oldB);
        } finally { disposeAll(oldA, newA, oldB, newB); }
      }), 120_000);

      test(`${tag}: padded batched prefill of three unequal rows, batched decode, batched rollback`, () => withScheme(scheme, () => {
        const p = pair(kind);
        const lengths = [9, 14, 6];
        const oldSources = lengths.map(() => p.old.makeCache()), newSources = lengths.map(() => p.current.makeCache());
        let oldRows: Cache[] = [], newRows: Cache[] = [];
        try {
          lengths.forEach((length, row) =>
            both(`${tag} row ${row} prefill`, p, oldSources[row]!, newSources[row]!, forwardHidden([prompt(length, 11 + row)])));
          convert(scheme, ...oldSources, ...newSources);
          oldRows = rowsOf(oldSources); newRows = rowsOf(newSources);
          stateDiff(`${tag} merged rows`, newRows, oldRows);

          // Right-padded window: real lengths 5, 3 and 7 in a width of 7.
          const real = [5, 3, 7], width = 7;
          for (const set of [oldRows, newRows]) for (const cache of set)
            (cache as unknown as PaddedPrefillCache).preparePrefill({ lengths: real, rightPadding: real.map(n => width - n) });
          const window = real.map((n, row) => [...prompt(n, 14 + row), ...Array(width - n).fill(0)]);
          both(`${tag} padded prefill 5/3/7`, p, oldRows, newRows, forwardHidden(window));
          for (const set of [oldRows, newRows]) for (const cache of set) (cache as unknown as PaddedPrefillCache).finalizePrefill();
          stateDiff(`${tag} padded prefill finalized`, newRows, oldRows);

          for (let step = 0; step < 2; step++)
            both(`${tag} batched decode`, p, oldRows, newRows, forwardHidden([[40 + step], [50 + step], [60 + step]]));

          for (const set of [oldRows, newRows]) for (const cache of set) cache.specRoundBegin?.();
          {
            const rows = [prompt(4, 20), prompt(4, 21), prompt(4, 22)];
            const expected = mixedVerify(p.old, oldRows, rows);
            const actual = mixedVerify(p.current, newRows, rows);
            tapsDiff(`${tag} batched verify4`, actual.taps, expected.taps);
            outputDiff(`${tag} batched verify4`, p.current, actual.hidden, expected.hidden);
          }
          for (const set of [oldRows, newRows]) for (const cache of set) (cache as unknown as { specRoundRollback(keep: readonly number[]): void }).specRoundRollback([1, 3, 2]);
          stateDiff(`${tag} batched rollback keep 1/3/2`, newRows, oldRows);
          both(`${tag} batched decode after rollback`, p, oldRows, newRows, forwardHidden([[70], [71], [72]]));
          if (g16s) both(`${tag} batched fill (one position per row)`, p, oldRows, newRows, (model, caches) => fill(model, caches, [[80], [81], [82]]));
        } finally { disposeAll(...oldSources, ...newSources, oldRows, newRows); }
      }), 120_000);
    }

    test(`${kind} bf16: padded batched prefill of three unequal rows from empty layouts`, () => {
      const p = pair(kind);
      const layouts = (model: Qwen35Model | FrozenQwen35Model) => {
        const serial = model.makeCache();
        try { return serial.map(cache => targetCacheLayout(cache) as unknown as Cache); }
        finally { disposeAll(serial); }
      };
      const oldRows = layouts(p.old), newRows = layouts(p.current);
      try {
        const real = [6, 2, 4], width = 6;
        for (const set of [oldRows, newRows]) for (const cache of set)
          (cache as unknown as PaddedPrefillCache).preparePrefill({ lengths: real, rightPadding: real.map(n => width - n) });
        const window = real.map((n, row) => [...prompt(n, 30 + row), ...Array(width - n).fill(0)]);
        both(`${kind} bf16 empty padded prefill 6/2/4`, p, oldRows, newRows, forwardHidden(window));
        for (const set of [oldRows, newRows]) for (const cache of set) (cache as unknown as PaddedPrefillCache).finalizePrefill();
        for (let step = 0; step < 2; step++)
          both(`${kind} bf16 empty batched decode`, p, oldRows, newRows, forwardHidden([[3 + step], [5 + step], [7 + step]]));
      } finally { disposeAll(oldRows, newRows); }
    }, 120_000);
  });
}

// Recorded, not identical (reported in the C1 PR). The pre-C1 block read a
// TurboQuant cache through `updateAndFetch`: values decoded back to their own
// domain, then the fused SDPA. The TurboQuant caches' own reads (B1c) run the
// fused SDPA on rotated values and un-rotate its output, Gemma's arithmetic.
// The first forward reads bf16 storage on both sides; reads after the
// conversion differ. Whether the TurboQuant lego composed for Qwen keeps the
// decoded read or Qwen takes the rotated one is open.
test("recorded: TurboQuant k8v3 KV reads differ after the conversion", () => {
  const p = pair("affine");
  const oldCaches = p.old.makeCache(), newCaches = p.current.makeCache();
  const measure = (label: string, rows: number[][]) => {
    using input = ids(rows);
    using expected = p.old.forwardHidden(input, oldCaches);
    using actual = p.current.forwardHidden(input, newCaches);
    using la = p.old.logitsFromHidden(expected);
    using lb = p.current.logitsFromHidden(actual);
    using x = la.astype(Dtype.float32);
    using y = lb.astype(Dtype.float32);
    const a = x.toFloat32(), b = y.toFloat32();
    let worst = 0;
    for (let i = 0; i < a.length; i++) worst = Math.max(worst, Math.abs(a[i]! - b[i]!));
    expect(Number.isFinite(worst)).toBe(true);
    console.log(`qwen35-identity recorded turbo k8v3 ${label}: logits maxDiff ${worst}`);
    return worst;
  };
  try {
    expect(measure("prefill37 (bf16 storage)", [prompt(37, 1)])).toBe(0);
    const maintain = createKvMaintenance({ turboQuant: { kBits: 8, vBits: 3 }, quantizedKvStart: 0 });
    maintain(oldCaches); maintain(newCaches);
    for (let step = 0; step < 2; step++) measure(`decode${step}`, [[40 + step]]);
    measure("window5", [prompt(5, 2)]);
  } finally { disposeAll(oldCaches, newCaches); }
}, 120_000);
