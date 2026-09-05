import { describe, expect, test } from "bun:test";
import type { ModelConfig } from "../../src/config";
import { MlxArray } from "../../src/mlx/array";
import * as ops from "../../src/mlx/ops";
import {
  Glm52DecoderLayer,
  Glm52Model,
  type Glm52WeightSource,
} from "../../src/model/glm52";
import { MLACache } from "../../src/model/glm52-cache";
import type { Glm52Config } from "../../src/model/glm52-config";
import type { Glm52ExpertRuntime } from "../../src/model/glm52-residency";
import type { Glm52PilotTracker } from "../../src/model/glm52-pilot";
import {
  composeGlm52MoeOutputsMlx,
  type Glm52RoutedExpertOutput,
} from "../../src/model/glm52-moe";
import type {
  Glm52ExpertExecutionArgs,
  Glm52ExpertExecutionBackend,
} from "../../src/model/glm52-streamed-experts";
import {
  composeSharedRoutedSwiGluF32,
  matvecF32,
  rmsNormF32,
  routeTrueTopKF32,
  swiGluF32,
  type SwiGluWeights,
} from "../../src/model/glm52-reference";
import { makeSampler } from "../../src/sampler";
import {
  Glm52NativeMtpProvider,
  Glm52NativeMtpSource,
} from "../../src/spec/glm52-mtp-source";
import { BatchScheduler } from "../../src/serve/batch-scheduler";
import { resolveModelProfile } from "../../src/model/profile";
import { GenerationGateway } from "../../src/serve/generation-gateway";
import { generate } from "../../src/generate";
import { createServer } from "../../src/server";
import { AdapterManager } from "../../src/lora";
import { renderGlm52Chat, type ChatTemplate } from "../../src/chat-template";
import type { LoadedTokenizer } from "../../src/tokenizer";
import { planGlm52Memory } from "../../src/model/glm52-memory";

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
    text: {
      hiddenSize: glm.hiddenSize,
      numHiddenLayers: glm.numHiddenLayers,
      numAttentionHeads: glm.numAttentionHeads,
      numKeyValueHeads: glm.numKeyValueHeads,
      headDim: glm.qkHeadDim,
      numGlobalKeyValueHeads: glm.numKeyValueHeads,
      globalHeadDim: glm.qkHeadDim,
      attentionKEqV: false,
      intermediateSize: glm.intermediateSize,
      hiddenActivation: "silu",
      rmsNormEps: glm.rmsNormEps,
      vocabSize: glm.vocabSize,
      maxPositionEmbeddings: glm.maxPositionEmbeddings,
      slidingWindow: 0,
      layerTypes: Array.from(
        { length: glm.numHiddenLayers },
        () => "full_attention",
      ),
      hiddenSizePerLayerInput: 0,
      vocabSizePerLayerInput: 0,
      numKvSharedLayers: 0,
      enableMoeBlock: glm.firstKDenseReplace < glm.numHiddenLayers,
      numExperts: glm.numRoutedExperts,
      topKExperts: glm.numExpertsPerToken,
      moeIntermediateSize: glm.moeIntermediateSize,
      decoderSparseStep: 1,
      mlpOnlyLayers: [],
      normTopkProb: glm.normTopkProb,
      linearNumValueHeads: 0,
      linearNumKeyHeads: 0,
      linearKeyHeadDim: 0,
      linearValueHeadDim: 0,
      linearConvKernelDim: 0,
      fullAttentionInterval: 1,
      attnOutputGate: false,
      partialRotaryFactor: 1,
      ropeParameters: {},
      finalLogitSoftcapping: null,
      tieWordEmbeddings: false,
      bosTokenId: 0,
      eosTokenId: glm.eosTokenIds,
    },
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

function cloneLayer(
  weights: TinyGlmWeights,
  source: number,
  target: number,
): void {
  const sourcePrefix = `model.layers.${source}.`;
  const targetPrefix = `model.layers.${target}.`;
  for (const [name, value] of [...weights.host.entries()]) {
    if (!name.startsWith(sourcePrefix)) continue;
    weights.put(
      `${targetPrefix}${name.slice(sourcePrefix.length)}`,
      value.data.slice(),
      [...value.shape],
    );
  }
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
  calls = 0;
  readonly tokenCounts: number[] = [];
  readonly routeCounts: number[] = [];

  constructor(readonly weights: TinyGlmWeights, readonly glm: Glm52Config) {}

  setFixedKernelFamily(_enabled: boolean): void {}

  async execute(args: Glm52ExpertExecutionArgs): Promise<MlxArray> {
    const [batch, tokens] = args.input.shape;
    this.calls++;
    this.tokenCounts.push(tokens!);
    this.routeCounts.push(args.plan.routes.length);
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

test("shared generate() preserves the streamed GLM greedy trajectory", async () => {
  const glm = config(true);
  const syncWeights = buildWeights(glm);
  const streamedWeights = buildWeights(glm);
  const syncModel = new Glm52Model(
    syncWeights,
    runtimeConfig(glm),
    glm,
    { dsa: false, mtpMetadata: false },
  );
  const backend = new TinyAsyncExpertBackend(streamedWeights, glm);
  const streamedModel = new Glm52Model(
    streamedWeights,
    runtimeConfig(glm),
    glm,
    { dsa: false, mtpMetadata: false },
    backend,
  );
  const trajectory = async (model: Glm52Model): Promise<{
    tokens: number[];
    generated: number;
  }> => {
    const generation = generate(model, [2, 3, 4], {
      maxTokens: 4,
      temperature: 0,
      eosTokenIds: [],
    });
    const tokens: number[] = [];
    for await (const token of generation) tokens.push(token.token);
    return { tokens, generated: generation.stats!.generatedTokens };
  };
  try {
    const expected = await trajectory(syncModel);
    const actual = await trajectory(streamedModel);
    expect(actual).toEqual(expected);
    expect(actual.tokens).toHaveLength(4);
    expect(backend.calls).toBeGreaterThan(0);
  } finally {
    syncModel.dispose();
    streamedModel.dispose();
  }
});

test("streamed GLM serves every generative HTTP protocol and truthful discovery", async () => {
  const glm = config(true);
  const weights = buildWeights(glm);
  const backend = new TinyAsyncExpertBackend(weights, glm);
  const model = new Glm52Model(
    weights,
    runtimeConfig(glm),
    glm,
    { dsa: false, mtpMetadata: false },
    backend,
  );
  const tokenizer: LoadedTokenizer = {
    encode: () => [2, 3, 4],
    decode: (ids) => ids.map((id) => `t${id}`).join(" "),
    idToToken: (id) => `t${id}`,
    bosTokenId: null,
    eosTokenId: null,
  };
  const template = {
    render: renderGlm52Chat,
    supportsThinking: true,
    thinkingFormat: "think-tag",
  } as unknown as ChatTemplate;
  const glmMemoryPlan = planGlm52Memory({
    ...glm,
    residentWeightBytes: 1024,
    mainExpertSlotBytes: 1024,
    sparseLayers: glm.numHiddenLayers - glm.firstKDenseReplace,
  }, {
    machineBytes: 32 * 2 ** 30,
    processLimitBytes: 25 * 2 ** 30,
    contextTokens: 64,
    maxGenerationTokens: 8,
    batchSize: 2,
    enableMtp: false,
  });
  const server = createServer({
    model,
    profile: resolveModelProfile(model.config),
    tokenizer,
    template,
    modelId: "tiny-glm52-http",
    vision: null,
    loadVision: null,
    visionTokenIds: { imageTokenId: 90, boiTokenId: 91, eoiTokenId: 92 },
    audio: null,
    loadAudio: null,
    audioTokenIds: null,
    adapters: new AdapterManager(model),
    kvConfig: null,
    genDefaults: {},
    draft: null,
    glmMemoryPlan,
  }, 0, { batch: 2, promptCacheBytes: 0 });
  const base = `http://localhost:${server.port}/v1`;
  const post = (path: string, body: Record<string, unknown>) =>
    fetch(`${base}${path}`, {
      method: "POST",
      headers: { "content-type": "application/json" },
      body: JSON.stringify(body),
    });
  try {
    const models = await (await fetch(`${base}/models`)).json() as any;
    expect(models.data[0]).toMatchObject({
      id: "tiny-glm52-http",
      batch_mode: "batch",
      tools: true,
      structured_output: true,
      embeddings: false,
      adapters: false,
      training: false,
      dsa: false,
      mtp: false,
    });
    expect(models.data[0].capabilities).toMatchObject({
      chat_completions: true,
      text_completions: true,
      anthropic_messages: true,
      responses: true,
      streaming: true,
      embeddings: false,
      vision: false,
      audio: false,
      adapters: false,
      training: false,
    });

    const fit = await (await fetch(`http://localhost:${server.port}/fit`))
      .json() as any;
    expect(fit).toMatchObject({
      context_tokens: 64,
      measured_decode_tps: 0.149,
      report: {
        fits: true,
        total_bytes: glmMemoryPlan.plannedProcessBytes,
        usable_bytes: 25 * 2 ** 30,
        max_safe_context: 64,
        predicted_decode_tps: null,
      },
      glm52: {
        artifact_disk_bytes: null,
        main_expert_slab_bytes:
          glmMemoryPlan.lineItems.mainExpertSlabBytes,
        mtp_expert_slab_bytes: 0,
        max_generation_tokens: 8,
        direct_oracle_warm_decode_tps: 0.27,
        aspirational_decode_tps: 2,
      },
    });

    const stats = await (await fetch(`http://localhost:${server.port}/stats`))
      .json() as any;
    expect(stats.glm52).toMatchObject({
      planned_process_bytes: glmMemoryPlan.plannedProcessBytes,
      process_limit_bytes: 25 * 2 ** 30,
      context_tokens: 64,
      max_generation_tokens: 8,
      expert_runtime: null,
    });

    const chat = await post("/chat/completions", {
      messages: [{ role: "user", content: "hi" }],
      max_tokens: 2,
      temperature: 0,
    });
    expect(chat.status).toBe(200);
    expect((await chat.json() as any).object).toBe("chat.completion");

    const completion = await post("/completions", {
      prompt: "hi",
      max_tokens: 2,
      temperature: 0,
    });
    expect(completion.status).toBe(200);
    expect((await completion.json() as any).object).toBe("text_completion");

    const message = await post("/messages", {
      model: "tiny-glm52-http",
      messages: [{ role: "user", content: "hi" }],
      max_tokens: 2,
      temperature: 0,
    });
    expect(message.status).toBe(200);
    expect((await message.json() as any).type).toBe("message");

    const response = await post("/responses", {
      model: "tiny-glm52-http",
      input: "hi",
      max_output_tokens: 2,
      temperature: 0,
    });
    expect(response.status).toBe(200);
    expect((await response.json() as any).object).toBe("response");

    const stream = await post("/chat/completions", {
      messages: [{ role: "user", content: "stream" }],
      max_tokens: 2,
      temperature: 0,
      stream: true,
    });
    expect(stream.status).toBe(200);
    expect(await stream.text()).toContain("data: [DONE]");
    expect(backend.calls).toBeGreaterThan(0);
  } finally {
    server.stop(true);
    model.dispose();
  }
});

test("PILOT variants observe the next streamed layer without changing output", async () => {
  const glm: Glm52Config = {
    ...config(true),
    numHiddenLayers: 2,
    indexerTypes: ["full", "full"],
  };
  const controlWeights = buildWeights(glm);
  const pilotWeights = buildWeights(glm);
  cloneLayer(controlWeights, 0, 1);
  cloneLayer(pilotWeights, 0, 1);
  const control = new Glm52Model(
    controlWeights,
    runtimeConfig(glm),
    glm,
    { dsa: false, mtpMetadata: false },
    new TinyAsyncExpertBackend(controlWeights, glm),
  );
  let attached: Glm52PilotTracker | null = null;
  const pilotRuntime = {
    pilotMeasureEnabled: true,
    pilotHintK: 0,
    pilotTwoStep: true,
    attachPilot: (value: Glm52PilotTracker) => { attached = value; },
    close: () => {},
  } as unknown as Glm52ExpertRuntime;
  const measured = new Glm52Model(
    pilotWeights,
    runtimeConfig(glm),
    glm,
    { dsa: false, mtpMetadata: false },
    new TinyAsyncExpertBackend(pilotWeights, glm),
    pilotRuntime,
  );
  const controlCache = control.makeCache();
  const measuredCache = measured.makeCache();
  try {
    const expected = await control.forwardAsync([2], controlCache);
    const actual = await measured.forwardAsync([2], measuredCache);
    try {
      expectClose(actual.toFloat32(), expected.toFloat32());
      expect(attached).not.toBeNull();
      expect(attached!.drainTelemetry()).toMatchObject({
        mode: "measure-only",
        predictionCalls: 1,
        observedCalls: 1,
        rows: 1,
        skippedWideCalls: 0,
        abandonedPredictions: 0,
        twoStep: {
          predictionCalls: 1,
          observedCalls: 1,
          rows: 1,
        },
      });
    } finally {
      expected.dispose();
      actual.dispose();
    }
  } finally {
    for (const cache of controlCache) cache.dispose();
    for (const cache of measuredCache) cache.dispose();
    control.dispose();
    measured.dispose();
  }
});

test("native GLM MTP provider rejects incomplete model wiring", () => {
  const cases = [
    {
      capabilities: { dsa: false, mtpMetadata: false },
      nextLayers: 1,
      streamed: false,
      message: /does not contain a complete MTP row/,
    },
    {
      capabilities: {
        dsa: false,
        mtpMetadata: true,
        mtpEnabled: false,
      },
      nextLayers: 1,
      streamed: false,
      message: /MTP is disabled/,
    },
    {
      capabilities: { dsa: false, mtpMetadata: true },
      nextLayers: 2,
      streamed: false,
      message: /requires exactly one next-token layer; got 2/,
    },
    {
      capabilities: { dsa: false, mtpMetadata: true },
      nextLayers: 1,
      streamed: true,
      message: /requires the bounded int8 MTP expert tier/,
    },
  ] as const;

  for (const entry of cases) {
    const glm = {
      ...config(true),
      numNextnPredictLayers: entry.nextLayers,
      indexShareForMtpIteration: true,
    };
    const weights = buildWeights(glm);
    const model = new Glm52Model(
      weights,
      runtimeConfig(glm),
      glm,
      entry.capabilities,
      entry.streamed ? new TinyAsyncExpertBackend(weights, glm) : null,
    );
    try {
      expect(() => new Glm52NativeMtpProvider(model)).toThrow(entry.message);
    } finally {
      model.dispose();
    }
  }
});

test("native GLM MTP serves through the serial speculative lane", async () => {
  const glm = {
    ...config(true),
    numNextnPredictLayers: 1,
    indexShareForMtpIteration: true,
  };
  const weights = addMtpWeights(buildWeights(glm), glm);
  const targetBackend = new TinyAsyncExpertBackend(weights, glm);
  const mtpBackend = new TinyAsyncExpertBackend(weights, glm);
  const runtime = {
    plan: { plannedBytes: 0 },
    executor: targetBackend,
    mtpExecutor: mtpBackend,
    close: () => {},
  } as unknown as Glm52ExpertRuntime;
  const model = new Glm52Model(
    weights,
    runtimeConfig(glm),
    glm,
    { dsa: false, mtpMetadata: true, mtpEnabled: true },
    targetBackend,
    runtime,
  );
  const provider = new Glm52NativeMtpProvider(model);
  const tokenizer: LoadedTokenizer = {
    encode: () => [2, 3, 4],
    decode: (ids) => ids.map((id) => `t${id}`).join(" "),
    idToToken: (id) => `t${id}`,
    bosTokenId: null,
    eosTokenId: null,
  };
  const server = createServer({
    model,
    profile: resolveModelProfile(model.config),
    tokenizer,
    template: {
      render: renderGlm52Chat,
      supportsThinking: true,
      thinkingFormat: "think-tag",
    } as unknown as ChatTemplate,
    modelId: "tiny-glm52-mtp-http",
    vision: null,
    loadVision: null,
    visionTokenIds: { imageTokenId: 90, boiTokenId: 91, eoiTokenId: 92 },
    audio: null,
    loadAudio: null,
    audioTokenIds: null,
    adapters: new AdapterManager(model),
    kvConfig: null,
    genDefaults: {},
    draft: { provider, numDraftTokens: 2 },
  }, 0, { batch: 4, promptCacheBytes: 0 });
  const base = `http://localhost:${server.port}/v1`;
  try {
    const models = await (await fetch(`${base}/models`)).json() as any;
    expect(models.data[0]).toMatchObject({
      // Capability stays batch; native MTP is a per-request serial route and
      // is reported authoritatively in usage.lane below.
      batch_mode: "batch",
      mtp: true,
    });
    const response = await fetch(`${base}/chat/completions`, {
      method: "POST",
      headers: { "content-type": "application/json" },
      body: JSON.stringify({
        messages: [{ role: "user", content: "hi" }],
        max_tokens: 3,
        temperature: 0,
      }),
    });
    const body = await response.json() as any;
    expect({ status: response.status, body }).toMatchObject({
      status: 200,
      body: { object: "chat.completion" },
    });
    expect(body.usage.lane).toBe("serial+spec");
    expect(targetBackend.calls).toBeGreaterThan(0);
    expect(mtpBackend.calls).toBeGreaterThan(0);
  } finally {
    server.stop(true);
    provider.dispose();
    model.dispose();
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
    target: { identity: model },
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
    // Direct Colibri has no MTP prompt prefill: the first draft starts its
    // decode-only cache at the target anchor.
    expect(mtp.cacheOffset).toBe(0);
    const anchorIds = ops.fromInt32([2], [1, 1]);
    try {
      anchor = model.forwardHidden(anchorIds, targetCache);
    } finally {
      anchorIds.dispose();
    }
    const malformedAnchor = MlxArray.fromFloat32(
      new Float32Array(2 * HIDDEN),
      [1, 2, HIDDEN],
    );
    try {
      await expect(source.draft([3], 1, 0, malformedAnchor))
        .rejects.toThrow(/native MTP anchor must be \[1,1,4\]/);
    } finally {
      malformedAnchor.dispose();
    }
    const drafts = await source.draft([3], 3, 0, anchor);
    expect(drafts).toHaveLength(3);
    expect(mtp.cacheOffset).toBe(3);
    await expect(source.draft([drafts.at(-1)!], 1, 3, anchor))
      .rejects.toThrow(/prior round committed/);

    const verifyIds = ops.fromInt32([3, ...drafts], [1, drafts.length + 1]);
    try {
      verified = model.forwardHidden(verifyIds, targetCache);
    } finally {
      verifyIds.dispose();
    }
    expect(targetCache[0]!.offset).toBe(5);
    targetCache[0]!.trim(2);
    await expect(source.commit(3, 4, undefined, verified, drafts))
      .rejects.toThrow(/outside \[0,3\]/);
    await expect(source.commit(3, 1, undefined, verified, []))
      .rejects.toThrow(/0 accepted tokens for k=1/);
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

test("native MTP compressed row restores to the same next draft", async () => {
  const { mkdtempSync, rmSync } = await import("node:fs");
  const { tmpdir } = await import("node:os");
  const { join } = await import("node:path");
  const { loadKvCache, readKvHeader, saveKvCache } = await import("../../src/kv-store");
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
  const open = () => provider.open({
    sampler: makeSampler({ temperature: 0 }),
    target: { identity: model },
  }) as Glm52NativeMtpSource;
  const live = open();
  const resumed = open();
  const targetCache = model.makeCache();
  const anchorIds = ops.fromInt32([2], [1, 1]);
  const dir = mkdtempSync(join(tmpdir(), "mlx-bun-glm-mtp-kv-"));
  let anchor: MlxArray | null = null;
  try {
    anchor = model.forwardHidden(anchorIds, targetCache);
    live.prefill([2, 3]);
    const first = await live.draft([3], 2, 0, anchor);
    await live.commit(first.length, 0, undefined, undefined, []);
    expect(live.cacheOffset).toBe(1);

    const snapshot = live.clonePersistentCache();
    const file = join(dir, "mtp.mlxkv");
    try {
      saveKvCache(file, [2, 3], [snapshot], {
        modelId: "tiny-glm-mtp",
        configFingerprint: "tiny-glm-mtp-v1",
      });
    } finally {
      snapshot.dispose();
    }
    expect(readKvHeader(file).caches.map((entry) => entry.kind))
      .toEqual(["mtp-mla"]);

    const loaded = loadKvCache(file, {
      makeCache: () => [new MLACache({
        kvLoraRank: KV_RANK,
        ropeHeadDim: ROPE,
        maxTokens: glm.maxPositionEmbeddings,
        role: "mtp",
      })],
    }, {
      configFingerprint: "tiny-glm-mtp-v1",
      verify: true,
    });
    resumed.restorePersistentCache(loaded.caches[0] as MLACache);
    expect(resumed.cacheOffset).toBe(live.cacheOffset);

    const nextLive = await live.draft([4], 2, 2, anchor);
    const nextResumed = await resumed.draft([4], 2, 2, anchor);
    expect(nextResumed).toEqual(nextLive);
    expect(resumed.cacheOffset).toBe(live.cacheOffset);
    await live.commit(nextLive.length, 0, undefined, undefined, []);
    await resumed.commit(nextResumed.length, 0, undefined, undefined, []);
    expect(resumed.cacheOffset).toBe(live.cacheOffset);
  } finally {
    anchorIds.dispose();
    anchor?.dispose();
    for (const cache of targetCache) cache.dispose();
    live.dispose();
    resumed.dispose();
    provider.dispose();
    model.dispose();
    rmSync(dir, { recursive: true, force: true });
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

test("compressed target cache restore matches uninterrupted DSA continuation", async () => {
  const { mkdtempSync, rmSync } = await import("node:fs");
  const { tmpdir } = await import("node:os");
  const { join } = await import("node:path");
  const { loadKvCache, readKvHeader, saveKvCache } = await import("../../src/kv-store");
  const glm = {
    ...config(false),
    indexTopk: 1,
    indexNumHeads: 2,
    indexHeadDim: 2,
  };
  const weights = buildWeights(glm);
  const p = "model.layers.0.self_attn.indexer";
  weights.put(`${p}.wq_b.weight`, matrix(4, Q_RANK, 81), [4, Q_RANK]);
  weights.put(`${p}.wk.weight`, matrix(2, HIDDEN, 82), [2, HIDDEN]);
  weights.put(`${p}.weights_proj.weight`, matrix(2, HIDDEN, 83), [2, HIDDEN]);
  weights.put(`${p}.k_norm.weight`, new Float32Array([1.1, 0.9]), [2]);
  weights.put(`${p}.k_norm.bias`, new Float32Array([0.05, -0.03]), [2]);
  const model = new Glm52Model(
    weights,
    runtimeConfig(glm),
    glm,
    { dsa: true, mtpMetadata: false },
  );
  const dir = mkdtempSync(join(tmpdir(), "mlx-bun-glm-continuation-"));
  try {
    for (const prompt of [[2], [2, 3]]) {
      const live = model.makeCache();
      const ids = ops.fromInt32(prompt, [1, prompt.length]);
      try {
        const hidden = model.forwardHidden(ids, live);
        hidden.dispose();
        ops.evalAll(live.flatMap((cache) => cache.state()));
      } finally {
        ids.dispose();
      }

      const file = join(dir, `prefix-${prompt.length}.mlxkv`);
      saveKvCache(file, prompt, live, {
        modelId: "tiny-glm-dsa",
        configFingerprint: "tiny-glm-dsa-v1",
      });
      const header = readKvHeader(file);
      expect(header.caches.map((entry) => entry.kind)).toEqual(["mla-dsa"]);
      expect(header.caches[0]!.tensors.map((tensor) => tensor.shape)).toEqual([
        [1, prompt.length, KV_RANK],
        [1, prompt.length, ROPE],
        [1, prompt.length, 2],
      ]);

      const restored = loadKvCache(file, model, {
        configFingerprint: "tiny-glm-dsa-v1",
        verify: true,
      });
      const next = ops.fromInt32([4], [1, 1]);
      try {
        const uninterrupted = model.forwardHidden(next, live);
        const resumed = model.forwardHidden(next, restored.caches);
        try {
          expect(resumed.toFloat32()).toEqual(uninterrupted.toFloat32());
          expect(restored.caches.map((cache) => cache.offset)).toEqual(
            live.map((cache) => cache.offset),
          );
          expect(restored.caches[0]!.offset).toBe(prompt.length + 1);
        } finally {
          uninterrupted.dispose();
          resumed.dispose();
        }
      } finally {
        next.dispose();
        for (const cache of live) cache.dispose();
        for (const cache of restored.caches) cache.dispose();
      }
    }
  } finally {
    rmSync(dir, { recursive: true, force: true });
    model.dispose();
  }
});

test("mixed-length batched DSA decode matches serial rows and extracts exact tips", async () => {
  const glm = {
    ...config(false),
    indexTopk: 1,
    indexNumHeads: 2,
    indexHeadDim: 2,
  };
  const weights = buildWeights(glm);
  const p = "model.layers.0.self_attn.indexer";
  weights.put(`${p}.wq_b.weight`, matrix(4, Q_RANK, 91), [4, Q_RANK]);
  weights.put(`${p}.wk.weight`, matrix(2, HIDDEN, 92), [2, HIDDEN]);
  weights.put(`${p}.weights_proj.weight`, matrix(2, HIDDEN, 93), [2, HIDDEN]);
  weights.put(`${p}.k_norm.weight`, new Float32Array([1.1, 0.9]), [2]);
  weights.put(`${p}.k_norm.bias`, new Float32Array([0.05, -0.03]), [2]);
  const model = new Glm52Model(
    weights,
    runtimeConfig(glm),
    glm,
    { dsa: true, mtpMetadata: false },
  );
  const rowA = model.makeCache();
  const rowB = model.makeCache();
  const merged = model.makeCache();
  const prefixA = ops.fromInt32([2], [1, 1]);
  const prefixB = ops.fromInt32([2, 3], [1, 2]);
  let expectedA: MlxArray | null = null;
  let expectedB: MlxArray | null = null;
  let actual: MlxArray | null = null;
  try {
    model.forwardHidden(prefixA, rowA).dispose();
    model.forwardHidden(prefixB, rowB).dispose();
    merged[0]!.mergeRows([rowA[0]!, rowB[0]!]);

    const nextA = ops.fromInt32([4], [1, 1]);
    const nextB = ops.fromInt32([5], [1, 1]);
    const nextBatch = ops.fromInt32([4, 5], [2, 1]);
    try {
      expectedA = model.forwardHidden(nextA, rowA);
      expectedB = model.forwardHidden(nextB, rowB);
      actual = await model.forwardHiddenAsync(nextBatch, merged);
    } finally {
      nextA.dispose();
      nextB.dispose();
      nextBatch.dispose();
    }

    const row0 = actual.slice([0, 0, 0], [1, 1, HIDDEN]);
    const row1 = actual.slice([1, 0, 0], [2, 1, HIDDEN]);
    try {
      expect(row0.toFloat32()).toEqual(expectedA.toFloat32());
      expect(row1.toFloat32()).toEqual(expectedB.toFloat32());
    } finally {
      row0.dispose();
      row1.dispose();
    }
    expect(merged[0]!.rowOffsets).toEqual([2, 3]);
    expect(merged[0]!.leftPad).toEqual([1, 0]);

    const extractedA = merged[0]!.extractRow(0);
    const extractedB = merged[0]!.extractRow(1);
    try {
      expect(extractedA.offset).toBe(rowA[0]!.offset);
      expect(extractedB.offset).toBe(rowB[0]!.offset);
      const a = extractedA.fetch();
      const b = extractedB.fetch();
      const serialA = rowA[0]!.fetch();
      const serialB = rowB[0]!.fetch();
      try {
        expect(a.latent.toFloat32()).toEqual(serialA.latent.toFloat32());
        expect(a.dsa!.toFloat32()).toEqual(serialA.dsa!.toFloat32());
        expect(b.latent.toFloat32()).toEqual(serialB.latent.toFloat32());
        expect(b.dsa!.toFloat32()).toEqual(serialB.dsa!.toFloat32());
      } finally {
        for (const state of [a, b, serialA, serialB]) {
          state.latent.dispose();
          state.rope.dispose();
          state.dsa?.dispose();
        }
      }
    } finally {
      extractedA.dispose();
      extractedB.dispose();
    }
  } finally {
    prefixA.dispose();
    prefixB.dispose();
    expectedA?.dispose();
    expectedB?.dispose();
    actual?.dispose();
    for (const cache of [...rowA, ...rowB, ...merged]) cache.dispose();
    model.dispose();
  }
});

test("streamed batched GLM forms one cross-row expert union", async () => {
  const glm = config(true);
  const weights = buildWeights(glm);
  const backend = new TinyAsyncExpertBackend(weights, glm);
  const model = new Glm52Model(
    weights,
    runtimeConfig(glm),
    glm,
    { dsa: false, mtpMetadata: false },
    backend,
  );
  const first = model.makeCache();
  const second = model.makeCache();
  const batch = model.makeCache();
  try {
    await model.forwardAsync([2], first).then((value) => value.dispose());
    await model.forwardAsync([3], second).then((value) => value.dispose());
    batch[0]!.mergeRows([first[0]!, second[0]!]);
    backend.calls = 0;
    backend.tokenCounts.length = 0;
    backend.routeCounts.length = 0;
    const ids = ops.fromInt32([4, 5], [2, 1]);
    try {
      const hidden = await model.forwardHiddenAsync(ids, batch);
      hidden.dispose();
    } finally {
      ids.dispose();
    }
    expect(backend.calls).toBe(1);
    expect(backend.tokenCounts).toEqual([1]);
    expect(backend.routeCounts).toEqual([2]);
  } finally {
    for (const cache of [...first, ...second, ...batch]) cache.dispose();
    model.dispose();
  }
});

test("GLM scheduler joins, cancels, extracts, and admits compressed bytes", async () => {
  const glm = {
    ...config(true),
    indexTopk: 1,
    indexNumHeads: 2,
    indexHeadDim: 2,
  };
  const weights = buildWeights(glm);
  const p = "model.layers.0.self_attn.indexer";
  weights.put(`${p}.wq_b.weight`, matrix(4, Q_RANK, 101), [4, Q_RANK]);
  weights.put(`${p}.wk.weight`, matrix(2, HIDDEN, 102), [2, HIDDEN]);
  weights.put(`${p}.weights_proj.weight`, matrix(2, HIDDEN, 103), [2, HIDDEN]);
  weights.put(`${p}.k_norm.weight`, new Float32Array([1.1, 0.9]), [2]);
  weights.put(`${p}.k_norm.bias`, new Float32Array([0.05, -0.03]), [2]);
  const backend = new TinyAsyncExpertBackend(weights, glm);
  const model = new Glm52Model(
    weights,
    runtimeConfig(glm),
    glm,
    { dsa: true, mtpMetadata: false },
    backend,
  );
  const scheduler = new BatchScheduler(model, {
    maxBatch: 2,
    kvBudgetBytes: 1_000,
  });
  const controller = new AbortController();
  const cancelled = new Error("cancelled GLM row");
  const gotA: number[] = [];
  const gotB: number[] = [];
  let peakProjected = 0;
  const sample = (logits: MlxArray): MlxArray => {
    peakProjected = Math.max(peakProjected, scheduler.projectedKvBytes);
    return ops.argmaxAxis(logits, -1);
  };
  try {
    const a = scheduler.submit({
      promptIds: [2],
      maxTokens: 4,
      eosTokenIds: [],
      signal: controller.signal,
      sample,
      onToken: (token) => {
        gotA.push(token);
        if (gotA.length === 1) controller.abort(cancelled);
      },
    });
    const b = scheduler.submit({
      promptIds: [2, 3],
      maxTokens: 4,
      eosTokenIds: [],
      sample,
      onToken: (token) => { gotB.push(token); },
    });
    await expect(a).rejects.toBe(cancelled);
    const stats = await b;
    expect(stats.generatedTokens).toBe(4);
    expect(gotA).toHaveLength(1);
    expect(gotB).toHaveLength(4);
    expect(scheduler.activeRows).toBe(0);
    expect(scheduler.pendingRows).toBe(0);
    // One layer, f32 latent+RoPE+DSA widths 2+2+2. Projection is logical
    // compressed bytes for (prompt + max_tokens), not reconstructed K/V.
    expect(peakProjected).toBe(
      ((1 + 4) + (2 + 4)) * (KV_RANK + ROPE + 2) * 4,
    );
    expect(backend.routeCounts.some((rows) => rows === 2)).toBe(true);

    const overflow = new BatchScheduler(model, { maxBatch: 2 });
    await expect(overflow.submit({
      promptIds: new Array(glm.maxPositionEmbeddings).fill(2),
      maxTokens: 1,
      eosTokenIds: [],
      sample,
      onToken: () => {},
    })).rejects.toThrow(/context limit.*exceeds 128/);
  } finally {
    model.dispose();
  }
});

test("GLM gateway truthfully reports batch mode while native MTP stays serial", () => {
  const glm = config(false);
  const model = new Glm52Model(
    buildWeights(glm),
    runtimeConfig(glm),
    glm,
    { dsa: false, mtpMetadata: false },
  );
  const gateway = new GenerationGateway(model, 2, async () => ({
    promptTokens: 0,
    cachedTokens: 0,
    generatedTokens: 0,
    prefillMs: 0,
    decodeMs: 0,
    prefillTps: 0,
    decodeTps: 0,
    cacheTokens: [],
  }));
  const shape = {
    hasVision: false,
    hasAdapters: false,
    hasRepetitionPenalty: false,
    hasLogitsExtras: false,
    wantsLogprobs: false,
    userSeed: false,
    kvQuant: false,
    turboQuant: false,
    hasGrammar: false,
    hasDraft: false,
  };
  try {
    expect(gateway.batchMode).toBe("batch");
    expect(gateway.batchingEnabled).toBe(true);
    expect(gateway.place(shape).mechanism).toBe("continuous");
    expect(gateway.place({ ...shape, hasDraft: true }).mechanism).toBe("serial");
  } finally {
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

test("small sparse DSA verify windows keep the streamed MLP batched", async () => {
  const glm = {
    ...config(true),
    indexTopk: 1,
    indexNumHeads: 2,
    indexHeadDim: 2,
  };
  const weights = buildWeights(glm);
  const p = "model.layers.0.self_attn.indexer";
  weights.put(`${p}.wq_b.weight`, matrix(4, Q_RANK, 71), [4, Q_RANK]);
  weights.put(`${p}.wk.weight`, matrix(2, HIDDEN, 72), [2, HIDDEN]);
  weights.put(`${p}.weights_proj.weight`, matrix(2, HIDDEN, 73), [2, HIDDEN]);
  weights.put(`${p}.k_norm.weight`, new Float32Array([1.1, 0.9]), [2]);
  weights.put(`${p}.k_norm.bias`, new Float32Array([0.05, -0.03]), [2]);
  const backend = new TinyAsyncExpertBackend(weights, glm);
  const model = new Glm52Model(
    weights,
    runtimeConfig(glm),
    glm,
    { dsa: true, mtpMetadata: false },
    backend,
  );
  const cache = model.makeCache();
  try {
    const logits = await model.forwardAsync([2, 3], cache);
    try {
      expect(Array.from(logits.toFloat32()).every(Number.isFinite)).toBe(true);
    } finally {
      logits.dispose();
    }
    expect(cache[0]!.offset).toBe(2);
    expect(backend.calls).toBe(1);
    expect(backend.tokenCounts).toEqual([2]);
  } finally {
    for (const value of cache) value.dispose();
    model.dispose();
  }
});

test("DSA decode benchmark mode batches long dense prefill without changing the default", () => {
  const glm = {
    ...config(false),
    indexTopk: 1,
    indexNumHeads: 2,
    indexHeadDim: 2,
  };
  const weights = buildWeights(glm);
  const p = "model.layers.0.self_attn.indexer";
  weights.put(`${p}.wq_b.weight`, matrix(4, Q_RANK, 61), [4, Q_RANK]);
  weights.put(`${p}.wk.weight`, matrix(2, HIDDEN, 62), [2, HIDDEN]);
  weights.put(`${p}.weights_proj.weight`, matrix(2, HIDDEN, 63), [2, HIDDEN]);
  weights.put(`${p}.k_norm.weight`, new Float32Array([1.1, 0.9]), [2]);
  weights.put(`${p}.k_norm.bias`, new Float32Array([0.05, -0.03]), [2]);
  const model = new Glm52Model(
    weights,
    runtimeConfig(glm),
    glm,
    { dsa: true, mtpMetadata: false },
    null,
    null,
    "dense-benchmark",
    2,
  );
  const observed: unknown[] = [];
  model.setDsaSelectionObserver((selection) => observed.push(selection));
  const cache = model.makeCache();
  try {
    const logits = model.forward([2, 3], cache);
    logits.dispose();
    expect(cache[0]!.offset).toBe(2);
    expect(observed).toEqual([{
      mode: "dense",
      layer: 0,
      ownerLayer: 0,
      contextLength: 2,
      positions: null,
      threshold: null,
    }]);
    const verified = model.forward([4, 5], cache);
    verified.dispose();
    expect(cache[0]!.offset).toBe(4);
    expect(observed).toHaveLength(3);
    expect(observed.slice(1).every((selection) =>
      (selection as { mode: string }).mode === "sparse"
    )).toBe(true);
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
