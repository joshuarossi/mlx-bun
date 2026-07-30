import { describe, expect, test } from "bun:test";
import type { ModelConfig } from "../src/config";
import { MlxArray } from "../src/mlx/array";
import * as ops from "../src/mlx/ops";
import {
  Glm52Model,
  type Glm52WeightSource,
} from "../src/model/glm52";
import type { Glm52Config } from "../src/model/glm52-config";
import {
  composeGlm52MoeOutputsMlx,
  type Glm52RoutedExpertOutput,
} from "../src/model/glm52-moe";
import type {
  Glm52ExpertExecutionArgs,
  Glm52ExpertExecutionBackend,
} from "../src/model/glm52-streamed-experts";
import {
  composeSharedRoutedSwiGluF32,
  matvecF32,
  rmsNormF32,
  routeTrueTopKF32,
  swiGluF32,
  type SwiGluWeights,
} from "../src/model/glm52-reference";
import { makeSampler } from "../src/sampler";
import {
  Glm52NativeMtpProvider,
  Glm52NativeMtpSource,
} from "../src/spec/glm52-mtp-source";

const HIDDEN = 4;
const HEADS = 2;
const Q_RANK = 3;
const KV_RANK = 2;
const NOPE = 2;
const ROPE = 2;
const VALUE = 2;
const VOCAB = 5;

function matrix(rows: number, columns: number, seed: number): Float32Array {
  return Float32Array.from({ length: rows * columns }, (_, index) =>
    Math.fround(
      Math.sin((index + 1) * (seed + 0.23)) * 0.27 +
      Math.cos((index + 2) * 0.31) * 0.09,
    ));
}

function rows(values: Float32Array, output: number, input: number): Float32Array[] {
  return Array.from({ length: output }, (_, row) =>
    values.slice(row * input, (row + 1) * input));
}

class TinyGlmWeights implements Glm52WeightSource {
  readonly arrays = new Map<string, MlxArray>();
  readonly host = new Map<string, { data: Float32Array; shape: number[] }>();
  readonly weightsBytes = 0;

  put(name: string, data: Float32Array, shape: number[]): void {
    this.host.set(name, { data, shape });
    this.arrays.set(name, MlxArray.fromFloat32(data, shape));
  }

  has(name: string): boolean {
    return this.arrays.has(name);
  }

  tensor(name: string): MlxArray {
    const value = this.arrays.get(name);
    if (!value) throw new Error(`missing tiny GLM tensor ${name}`);
    return value;
  }

  dequantized(name: string, outputRows: number, inputColumns: number): MlxArray {
    const value = this.tensor(name);
    expect(value.shape).toEqual([outputRows, inputColumns]);
    return ops.contiguous(value);
  }

  linear(
    input: MlxArray,
    name: string,
    outputRows: number,
    inputColumns: number,
  ): MlxArray {
    const weight = this.tensor(name);
    expect(weight.shape).toEqual([outputRows, inputColumns]);
    const transposed = ops.transposeAxes(weight, [1, 0]);
    const output = ops.matmul(input, transposed);
    transposed.dispose();
    return output;
  }

  embedding(
    ids: MlxArray,
    name: string,
    vocabSize: number,
    hiddenSize: number,
  ): MlxArray {
    const table = this.tensor(name);
    expect(table.shape).toEqual([vocabSize, hiddenSize]);
    return ops.takeAxis(table, ids, 0);
  }

  dispose(): void {
    for (const value of this.arrays.values()) value.dispose();
    this.arrays.clear();
  }
}

function config(sparse: boolean): Glm52Config {
  return {
    modelDir: "/tiny",
    modelType: "glm_moe_dsa",
    architectures: ["GlmMoeDsaForCausalLM"],
    hiddenSize: HIDDEN,
    numHiddenLayers: 1,
    numAttentionHeads: HEADS,
    numKeyValueHeads: HEADS,
    qLoraRank: Q_RANK,
    kvLoraRank: KV_RANK,
    qkNopeHeadDim: NOPE,
    qkRopeHeadDim: ROPE,
    qkHeadDim: NOPE + ROPE,
    vHeadDim: VALUE,
    firstKDenseReplace: sparse ? 0 : 1,
    intermediateSize: 6,
    moeIntermediateSize: 3,
    numRoutedExperts: 4,
    numExpertsPerToken: 2,
    numSharedExperts: 1,
    nGroup: 1,
    topkGroup: 1,
    normTopkProb: true,
    routedScalingFactor: 2.5,
    rmsNormEps: 1e-5,
    ropeTheta: 10_000,
    ropeInterleave: true,
    vocabSize: VOCAB,
    maxPositionEmbeddings: 128,
    indexTopk: 0,
    indexNumHeads: 0,
    indexHeadDim: 0,
    indexerRopeInterleave: true,
    indexerTypes: ["full"],
    numNextnPredictLayers: 0,
    indexShareForMtpIteration: false,
    eosTokenIds: [1, 2],
    padTokenId: 0,
    raw: {},
  };
}

function runtimeConfig(glm: Glm52Config): ModelConfig {
  return {
    modelDir: glm.modelDir,
    modelType: glm.modelType,
    architectures: glm.architectures,
    dtype: "float32",
    text: { numHiddenLayers: 1 } as ModelConfig["text"],
    quantization: null,
    kvQuant: null,
    hasVisionSidecar: false,
    eosTokenIds: glm.eosTokenIds,
    raw: {},
  };
}

function buildWeights(glm: Glm52Config): TinyGlmWeights {
  const weights = new TinyGlmWeights();
  weights.put("model.embed_tokens.weight", matrix(VOCAB, HIDDEN, 1), [VOCAB, HIDDEN]);
  weights.put("lm_head.weight", matrix(VOCAB, HIDDEN, 2), [VOCAB, HIDDEN]);
  weights.put("model.norm.weight", new Float32Array([0.9, 1.1, 0.8, 1.2]), [HIDDEN]);
  const p = "model.layers.0";
  weights.put(`${p}.input_layernorm.weight`, new Float32Array([1, 0.8, 1.2, 0.9]), [HIDDEN]);
  weights.put(`${p}.post_attention_layernorm.weight`, new Float32Array([0.7, 1.1, 0.95, 1.25]), [HIDDEN]);
  weights.put(`${p}.self_attn.q_a_proj.weight`, matrix(Q_RANK, HIDDEN, 3), [Q_RANK, HIDDEN]);
  weights.put(`${p}.self_attn.q_a_layernorm.weight`, new Float32Array([0.9, 1.2, 0.75]), [Q_RANK]);
  weights.put(`${p}.self_attn.q_b_proj.weight`, matrix(HEADS * (NOPE + ROPE), Q_RANK, 4), [HEADS * (NOPE + ROPE), Q_RANK]);
  weights.put(`${p}.self_attn.kv_a_proj_with_mqa.weight`, matrix(KV_RANK + ROPE, HIDDEN, 5), [KV_RANK + ROPE, HIDDEN]);
  weights.put(`${p}.self_attn.kv_a_layernorm.weight`, new Float32Array([1.1, 0.85]), [KV_RANK]);
  weights.put(`${p}.self_attn.kv_b_proj.weight`, matrix(HEADS * (NOPE + VALUE), KV_RANK, 6), [HEADS * (NOPE + VALUE), KV_RANK]);
  weights.put(`${p}.self_attn.o_proj.weight`, matrix(HIDDEN, HEADS * VALUE, 7), [HIDDEN, HEADS * VALUE]);

  if (glm.firstKDenseReplace === 1) {
    weights.put(`${p}.mlp.gate_proj.weight`, matrix(glm.intermediateSize, HIDDEN, 8), [glm.intermediateSize, HIDDEN]);
    weights.put(`${p}.mlp.up_proj.weight`, matrix(glm.intermediateSize, HIDDEN, 9), [glm.intermediateSize, HIDDEN]);
    weights.put(`${p}.mlp.down_proj.weight`, matrix(HIDDEN, glm.intermediateSize, 10), [HIDDEN, glm.intermediateSize]);
  } else {
    weights.put(`${p}.mlp.gate.weight`, matrix(glm.numRoutedExperts, HIDDEN, 11), [glm.numRoutedExperts, HIDDEN]);
    weights.put(`${p}.mlp.gate.e_score_correction_bias`, new Float32Array([0.1, -0.05, 0.2, -0.1]), [glm.numRoutedExperts]);
    for (let expert = 0; expert < glm.numRoutedExperts; expert++) {
      const e = `${p}.mlp.experts.${expert}`;
      weights.put(`${e}.gate_proj.weight`, matrix(glm.moeIntermediateSize, HIDDEN, 12 + expert * 3), [glm.moeIntermediateSize, HIDDEN]);
      weights.put(`${e}.up_proj.weight`, matrix(glm.moeIntermediateSize, HIDDEN, 13 + expert * 3), [glm.moeIntermediateSize, HIDDEN]);
      weights.put(`${e}.down_proj.weight`, matrix(HIDDEN, glm.moeIntermediateSize, 14 + expert * 3), [HIDDEN, glm.moeIntermediateSize]);
    }
    const s = `${p}.mlp.shared_experts`;
    weights.put(`${s}.gate_proj.weight`, matrix(glm.moeIntermediateSize, HIDDEN, 30), [glm.moeIntermediateSize, HIDDEN]);
    weights.put(`${s}.up_proj.weight`, matrix(glm.moeIntermediateSize, HIDDEN, 31), [glm.moeIntermediateSize, HIDDEN]);
    weights.put(`${s}.down_proj.weight`, matrix(HIDDEN, glm.moeIntermediateSize, 32), [HIDDEN, glm.moeIntermediateSize]);
  }
  return weights;
}

function addMtpWeights(
  weights: TinyGlmWeights,
  glm: Glm52Config,
): TinyGlmWeights {
  const p = `model.layers.${glm.numHiddenLayers}`;
  weights.put(`${p}.enorm.weight`, new Float32Array([1.1, 0.9, 1.2, 0.8]), [HIDDEN]);
  weights.put(`${p}.hnorm.weight`, new Float32Array([0.8, 1.2, 0.9, 1.1]), [HIDDEN]);
  weights.put(`${p}.shared_head.norm.weight`, new Float32Array([1, 0.95, 1.05, 0.9]), [HIDDEN]);
  weights.put(`${p}.eh_proj.weight`, matrix(HIDDEN, 2 * HIDDEN, 41), [HIDDEN, 2 * HIDDEN]);
  weights.put(`${p}.input_layernorm.weight`, new Float32Array([0.9, 1.1, 0.85, 1.15]), [HIDDEN]);
  weights.put(`${p}.post_attention_layernorm.weight`, new Float32Array([1.2, 0.8, 1.1, 0.9]), [HIDDEN]);
  weights.put(`${p}.self_attn.q_a_proj.weight`, matrix(Q_RANK, HIDDEN, 42), [Q_RANK, HIDDEN]);
  weights.put(`${p}.self_attn.q_a_layernorm.weight`, new Float32Array([1.1, 0.8, 1]), [Q_RANK]);
  weights.put(`${p}.self_attn.q_b_proj.weight`, matrix(HEADS * (NOPE + ROPE), Q_RANK, 43), [HEADS * (NOPE + ROPE), Q_RANK]);
  weights.put(`${p}.self_attn.kv_a_proj_with_mqa.weight`, matrix(KV_RANK + ROPE, HIDDEN, 44), [KV_RANK + ROPE, HIDDEN]);
  weights.put(`${p}.self_attn.kv_a_layernorm.weight`, new Float32Array([0.9, 1.1]), [KV_RANK]);
  weights.put(`${p}.self_attn.kv_b_proj.weight`, matrix(HEADS * (NOPE + VALUE), KV_RANK, 45), [HEADS * (NOPE + VALUE), KV_RANK]);
  weights.put(`${p}.self_attn.o_proj.weight`, matrix(HIDDEN, HEADS * VALUE, 46), [HIDDEN, HEADS * VALUE]);
  weights.put(`${p}.mlp.gate.weight`, matrix(glm.numRoutedExperts, HIDDEN, 47), [glm.numRoutedExperts, HIDDEN]);
  weights.put(`${p}.mlp.gate.e_score_correction_bias`, new Float32Array([0.05, 0.15, -0.1, 0.2]), [glm.numRoutedExperts]);
  for (let expert = 0; expert < glm.numRoutedExperts; expert++) {
    const e = `${p}.mlp.experts.${expert}`;
    weights.put(`${e}.gate_proj.weight`, matrix(glm.moeIntermediateSize, HIDDEN, 48 + expert * 3), [glm.moeIntermediateSize, HIDDEN]);
    weights.put(`${e}.up_proj.weight`, matrix(glm.moeIntermediateSize, HIDDEN, 49 + expert * 3), [glm.moeIntermediateSize, HIDDEN]);
    weights.put(`${e}.down_proj.weight`, matrix(HIDDEN, glm.moeIntermediateSize, 50 + expert * 3), [HIDDEN, glm.moeIntermediateSize]);
  }
  const shared = `${p}.mlp.shared_experts`;
  weights.put(`${shared}.gate_proj.weight`, matrix(glm.moeIntermediateSize, HIDDEN, 61), [glm.moeIntermediateSize, HIDDEN]);
  weights.put(`${shared}.up_proj.weight`, matrix(glm.moeIntermediateSize, HIDDEN, 62), [glm.moeIntermediateSize, HIDDEN]);
  weights.put(`${shared}.down_proj.weight`, matrix(HIDDEN, glm.moeIntermediateSize, 63), [HIDDEN, glm.moeIntermediateSize]);
  return weights;
}

function matrixRows(weights: TinyGlmWeights, name: string): Float32Array[] {
  const value = weights.host.get(name)!;
  return rows(value.data, value.shape[0]!, value.shape[1]!);
}

function swigluWeights(weights: TinyGlmWeights, prefix: string): SwiGluWeights {
  return {
    gate: matrixRows(weights, `${prefix}.gate_proj.weight`),
    up: matrixRows(weights, `${prefix}.up_proj.weight`),
    down: matrixRows(weights, `${prefix}.down_proj.weight`),
  };
}

function hostLogits(
  weights: TinyGlmWeights,
  glm: Glm52Config,
  token: number,
): Float32Array {
  const p = "model.layers.0";
  const embedding = matrixRows(weights, "model.embed_tokens.weight")[token]!;
  const normalized = rmsNormF32(
    embedding,
    weights.host.get(`${p}.input_layernorm.weight`)!.data,
    glm.rmsNormEps,
  );
  const compressed = matvecF32(
    normalized,
    matrixRows(weights, `${p}.self_attn.kv_a_proj_with_mqa.weight`),
  );
  const latent = rmsNormF32(
    compressed.slice(0, KV_RANK),
    weights.host.get(`${p}.self_attn.kv_a_layernorm.weight`)!.data,
    glm.rmsNormEps,
  );
  const reconstructed = matvecF32(
    latent,
    matrixRows(weights, `${p}.self_attn.kv_b_proj.weight`),
  );
  const values: number[] = [];
  for (let head = 0; head < HEADS; head++) {
    const start = head * (NOPE + VALUE) + NOPE;
    values.push(...reconstructed.slice(start, start + VALUE));
  }
  const attention = matvecF32(
    values,
    matrixRows(weights, `${p}.self_attn.o_proj.weight`),
  );
  const residual = Float32Array.from(embedding, (value, index) =>
    Math.fround(value + attention[index]!));
  const post = rmsNormF32(
    residual,
    weights.host.get(`${p}.post_attention_layernorm.weight`)!.data,
    glm.rmsNormEps,
  );
  let feedForward: Float32Array;
  if (glm.firstKDenseReplace === 1) {
    feedForward = swiGluF32(post, swigluWeights(weights, `${p}.mlp`));
  } else {
    const route = routeTrueTopKF32(
      matvecF32(post, matrixRows(weights, `${p}.mlp.gate.weight`)),
      weights.host.get(`${p}.mlp.gate.e_score_correction_bias`)!.data,
      glm.numExpertsPerToken,
      glm.normTopkProb,
      glm.routedScalingFactor,
    );
    feedForward = composeSharedRoutedSwiGluF32(
      post,
      route.indices.map((expertId, rank) => ({
        expert: swigluWeights(weights, `${p}.mlp.experts.${expertId}`),
        weight: route.executionWeights[rank]!,
      })),
      swigluWeights(weights, `${p}.mlp.shared_experts`),
    );
  }
  const layerOutput = Float32Array.from(residual, (value, index) =>
    Math.fround(value + feedForward[index]!));
  const final = rmsNormF32(
    layerOutput,
    weights.host.get("model.norm.weight")!.data,
    glm.rmsNormEps,
  );
  return matvecF32(final, matrixRows(weights, "lm_head.weight"));
}

function expectClose(actual: Float32Array, expected: Float32Array): void {
  expect(actual.length).toBe(expected.length);
  for (let index = 0; index < expected.length; index++)
    expect(Math.abs(actual[index]! - expected[index]!)).toBeLessThanOrEqual(5e-5);
}

function tinySwiGluMlx(
  weights: TinyGlmWeights,
  input: MlxArray,
  prefix: string,
  intermediate: number,
): MlxArray {
  const gate = weights.linear(
    input, `${prefix}.gate_proj.weight`, intermediate, HIDDEN,
  );
  const up = weights.linear(
    input, `${prefix}.up_proj.weight`, intermediate, HIDDEN,
  );
  const activated = ops.silu(gate);
  const product = ops.mul(activated, up);
  gate.dispose();
  up.dispose();
  activated.dispose();
  const output = weights.linear(
    product, `${prefix}.down_proj.weight`, HIDDEN, intermediate,
  );
  product.dispose();
  return output;
}

class TinyAsyncExpertBackend implements Glm52ExpertExecutionBackend {
  constructor(readonly weights: TinyGlmWeights, readonly glm: Glm52Config) {}

  async execute(args: Glm52ExpertExecutionArgs): Promise<MlxArray> {
    const [batch, tokens] = args.input.shape;
    const rows: MlxArray[] = [];
    try {
      for (let row = 0; row < args.plan.routes.length; row++) {
        const b = Math.floor(row / tokens!);
        const token = row % tokens!;
        const input = args.input.slice(
          [b, token, 0],
          [b + 1, token + 1, HIDDEN],
        );
        const routed: Array<Glm52RoutedExpertOutput<MlxArray>> = [];
        try {
          const route = args.plan.routes[row]!;
          for (const expertId of route.indices) {
            routed.push({
              expertId,
              output: tinySwiGluMlx(
                this.weights,
                input,
                `model.layers.${args.layer}.mlp.experts.${expertId}`,
                this.glm.moeIntermediateSize,
              ),
            });
          }
          const shared = args.shared?.slice(
            [b, token, 0],
            [b + 1, token + 1, HIDDEN],
          ) ?? null;
          rows.push(composeGlm52MoeOutputsMlx(route, routed, shared));
          shared?.dispose();
        } finally {
          input.dispose();
          for (const value of routed) value.output.dispose();
        }
      }
      if (rows.length === 1) return rows[0]!;
      const flat = ops.concatAxis(rows, 1);
      return ops.reshape(flat, [batch!, tokens!, HIDDEN]);
    } finally {
      if (rows.length > 1)
        for (const row of rows) row.dispose();
    }
  }
}

class FailingExpertBackend implements Glm52ExpertExecutionBackend {
  async execute(): Promise<MlxArray> {
    throw new Error("forced streamed expert failure");
  }
}

for (const sparse of [false, true]) {
  test(`dedicated GLM model matches the one-layer ${sparse ? "shared+routed MoE" : "dense"} oracle`, () => {
    const glm = config(sparse);
    const weights = buildWeights(glm);
    const expected = hostLogits(weights, glm, 2);
    const model = new Glm52Model(
      weights,
      runtimeConfig(glm),
      glm,
      { dsa: false, mtpMetadata: false },
    );
    const cache = model.makeCache();
    try {
      const logits = model.forward([2], cache);
      try {
        expect(logits.shape).toEqual([1, 1, VOCAB]);
        expectClose(logits.toFloat32(), expected);
      } finally {
        logits.dispose();
      }
      expect(cache[0]!.byteLength).toBe((KV_RANK + ROPE) * 4);
    } finally {
      for (const value of cache) value.dispose();
      model.dispose();
    }
  });
}

test("streamed GLM async model path matches the synchronous sparse reference", async () => {
  const glm = config(true);
  const syncWeights = buildWeights(glm);
  const asyncWeights = buildWeights(glm);
  const syncModel = new Glm52Model(
    syncWeights,
    runtimeConfig(glm),
    glm,
    { dsa: false, mtpMetadata: false },
  );
  const asyncModel = new Glm52Model(
    asyncWeights,
    runtimeConfig(glm),
    glm,
    { dsa: false, mtpMetadata: false },
    new TinyAsyncExpertBackend(asyncWeights, glm),
  );
  const syncCache = syncModel.makeCache();
  const asyncCache = asyncModel.makeCache();
  try {
    const expected = syncModel.forward([2], syncCache);
    const actual = await asyncModel.forwardAsync([2], asyncCache);
    try {
      expectClose(actual.toFloat32(), expected.toFloat32());
      expect(() => asyncModel.forward([2], asyncCache))
        .toThrow(/forwardAsync/);
    } finally {
      expected.dispose();
      actual.dispose();
    }
  } finally {
    for (const cache of syncCache) cache.dispose();
    for (const cache of asyncCache) cache.dispose();
    syncModel.dispose();
    asyncModel.dispose();
  }
});

test("native GLM MTP drafts to gamma and rolls target + MTP caches back exactly", async () => {
  const glm = {
    ...config(true),
    numNextnPredictLayers: 1,
    indexShareForMtpIteration: true,
  };
  const weights = addMtpWeights(buildWeights(glm), glm);
  const model = new Glm52Model(
    weights,
    runtimeConfig(glm),
    glm,
    { dsa: false, mtpMetadata: true },
  );
  const provider = new Glm52NativeMtpProvider(model);
  const source = provider.open({
    sampler: makeSampler({ temperature: 0 }),
    target: { model, caches: [] },
  });
  expect(source).toBeInstanceOf(Glm52NativeMtpSource);
  expect(source.prefillMode).toBe("full");
  expect(source.pinTargetKernelFamily).toBe(true);
  const mtp = source as Glm52NativeMtpSource;
  const targetCache = model.makeCache();
  let anchor: MlxArray | null = null;
  let verified: MlxArray | null = null;
  try {
    source.prefill([2, 3]);
    const anchorIds = ops.fromInt32([2], [1, 1]);
    try {
      anchor = model.forwardHidden(anchorIds, targetCache);
    } finally {
      anchorIds.dispose();
    }
    const drafts = await source.draft([3], 3, 0, anchor);
    expect(drafts).toHaveLength(3);
    expect(mtp.cacheOffset).toBe(3);

    const verifyIds = ops.fromInt32([3, ...drafts], [1, drafts.length + 1]);
    try {
      verified = model.forwardHidden(verifyIds, targetCache);
    } finally {
      verifyIds.dispose();
    }
    expect(targetCache[0]!.offset).toBe(5);
    targetCache[0]!.trim(2);
    await source.commit(3, 1, undefined, verified, drafts.slice(0, 1));
    expect(targetCache[0]!.offset).toBe(3);
    expect(mtp.cacheOffset).toBe(2);

    const nextAnchor = verified.slice([0, 1, 0], [1, 2, HIDDEN]);
    try {
      const rejected = await source.draft([4], 2, 2, nextAnchor);
      expect(rejected).toHaveLength(2);
      expect(mtp.cacheOffset).toBe(4);
      await source.commit(2, 0, undefined, verified, []);
      expect(mtp.cacheOffset).toBe(3);
    } finally {
      nextAnchor.dispose();
    }
  } finally {
    anchor?.dispose();
    verified?.dispose();
    for (const cache of targetCache) cache.dispose();
    source.dispose();
    provider.dispose();
    model.dispose();
  }
});

test("streamed GLM failure rolls every advanced cache layer back", async () => {
  const glm = config(true);
  const weights = buildWeights(glm);
  const model = new Glm52Model(
    weights,
    runtimeConfig(glm),
    glm,
    { dsa: false, mtpMetadata: false },
    new FailingExpertBackend(),
  );
  const cache = model.makeCache();
  try {
    await expect(model.forwardAsync([2], cache))
      .rejects.toThrow(/forced streamed expert failure/);
    expect(cache.map((layer) => layer.offset)).toEqual([0]);
  } finally {
    for (const value of cache) value.dispose();
    model.dispose();
  }
});

test("dedicated model carries one shared DSA key per token and applies sparse decode selection", () => {
  const glm = {
    ...config(false),
    indexTopk: 1,
    indexNumHeads: 2,
    indexHeadDim: 2,
  };
  const weights = buildWeights(glm);
  const p = "model.layers.0.self_attn.indexer";
  weights.put(`${p}.wq_b.weight`, matrix(4, Q_RANK, 41), [4, Q_RANK]);
  weights.put(`${p}.wk.weight`, matrix(2, HIDDEN, 42), [2, HIDDEN]);
  weights.put(`${p}.weights_proj.weight`, matrix(2, HIDDEN, 43), [2, HIDDEN]);
  weights.put(`${p}.k_norm.weight`, new Float32Array([1.1, 0.9]), [2]);
  weights.put(`${p}.k_norm.bias`, new Float32Array([0.05, -0.03]), [2]);
  const model = new Glm52Model(
    weights,
    runtimeConfig(glm),
    glm,
    { dsa: true, mtpMetadata: false },
  );
  const cache = model.makeCache();
  try {
    const first = model.forward([2], cache);
    first.dispose();
    const second = model.forward([3], cache);
    try {
      expect(second.shape).toEqual([1, 1, VOCAB]);
      expect(Array.from(second.toFloat32()).every(Number.isFinite)).toBe(true);
    } finally {
      second.dispose();
    }
    expect(cache[0]!.state().map((array) => array.shape)).toEqual([
      [1, 2, KV_RANK],
      [1, 2, ROPE],
      [1, 2, 2],
    ]);
    // Per token: latent 2 + MLA RoPE 2 + ONE shared DSA key 2, all f32.
    expect(cache[0]!.byteLength).toBe(2 * (KV_RANK + ROPE + 2) * 4);
  } finally {
    for (const value of cache) value.dispose();
    model.dispose();
  }
});

test("DSA prefill crossing index_topk falls back to exact row-wise selection", () => {
  const glm = {
    ...config(false),
    indexTopk: 1,
    indexNumHeads: 2,
    indexHeadDim: 2,
  };
  const weights = buildWeights(glm);
  const p = "model.layers.0.self_attn.indexer";
  weights.put(`${p}.wq_b.weight`, matrix(4, Q_RANK, 51), [4, Q_RANK]);
  weights.put(`${p}.wk.weight`, matrix(2, HIDDEN, 52), [2, HIDDEN]);
  weights.put(`${p}.weights_proj.weight`, matrix(2, HIDDEN, 53), [2, HIDDEN]);
  weights.put(`${p}.k_norm.weight`, new Float32Array([1.1, 0.9]), [2]);
  weights.put(`${p}.k_norm.bias`, new Float32Array([0.05, -0.03]), [2]);
  const model = new Glm52Model(
    weights,
    runtimeConfig(glm),
    glm,
    { dsa: true, mtpMetadata: false },
  );
  const cache = model.makeCache();
  try {
    const logits = model.forward([2, 3], cache);
    try {
      expect(logits.shape).toEqual([1, 2, VOCAB]);
      expect(Array.from(logits.toFloat32()).every(Number.isFinite)).toBe(true);
      expect(cache[0]!.offset).toBe(2);
    } finally {
      logits.dispose();
    }
  } finally {
    for (const value of cache) value.dispose();
    model.dispose();
  }
});

test("forwardEmbeddings leaves caller-owned embeddings alive", () => {
  const glm = config(false);
  const weights = buildWeights(glm);
  const model = new Glm52Model(
    weights,
    runtimeConfig(glm),
    glm,
    { dsa: false, mtpMetadata: false },
  );
  const cache = model.makeCache();
  const ids = ops.fromInt32([2], [1, 1]);
  const embeddings = weights.embedding(
    ids,
    "model.embed_tokens.weight",
    VOCAB,
    HIDDEN,
  );
  ids.dispose();
  try {
    const hidden = model.forwardEmbeddings(embeddings, cache, null);
    hidden.dispose();
    expect(embeddings.shape).toEqual([1, 1, HIDDEN]);
    expect(Array.from(embeddings.toFloat32()).every(Number.isFinite)).toBe(true);
  } finally {
    embeddings.dispose();
    for (const value of cache) value.dispose();
    model.dispose();
  }
});
