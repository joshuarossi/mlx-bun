import { describe, expect, test } from "bun:test";
import { MlxArray } from "../src/mlx/array";
import * as ops from "../src/mlx/ops";
import { MLACache } from "../src/model/glm52-cache";
import type { Glm52Config } from "../src/model/glm52-config";
import {
  Glm52Mla,
  partialInterleavedRopeMlx,
  type Glm52MlaWeightSource,
} from "../src/model/glm52-mla";
import {
  matvecF32,
  partialInterleavedRopeF32,
  rmsNormF32,
} from "../src/model/glm52-reference";

const HIDDEN = 4;
const HEADS = 2;
const Q_RANK = 3;
const KV_RANK = 2;
const NOPE = 2;
const ROPE = 2;
const VALUE = 2;
const PREFIX = "model.layers.0.self_attn";

function matrix(rows: number, columns: number, seed: number): Float32Array {
  return Float32Array.from({ length: rows * columns }, (_, index) =>
    Math.fround(
      Math.sin((index + 1) * (seed + 0.37)) * 0.31 +
      Math.cos((index + 3) * 0.19) * 0.07,
    ),
  );
}

const hostWeights = new Map<string, { data: Float32Array; shape: number[] }>([
  [`${PREFIX}.q_a_proj.weight`, {
    data: matrix(Q_RANK, HIDDEN, 1),
    shape: [Q_RANK, HIDDEN],
  }],
  [`${PREFIX}.q_a_layernorm.weight`, {
    data: new Float32Array([0.9, 1.1, 0.8]),
    shape: [Q_RANK],
  }],
  [`${PREFIX}.q_b_proj.weight`, {
    data: matrix(HEADS * (NOPE + ROPE), Q_RANK, 2),
    shape: [HEADS * (NOPE + ROPE), Q_RANK],
  }],
  [`${PREFIX}.kv_a_proj_with_mqa.weight`, {
    data: matrix(KV_RANK + ROPE, HIDDEN, 3),
    shape: [KV_RANK + ROPE, HIDDEN],
  }],
  [`${PREFIX}.kv_a_layernorm.weight`, {
    data: new Float32Array([1.2, 0.75]),
    shape: [KV_RANK],
  }],
  [`${PREFIX}.kv_b_proj.weight`, {
    data: matrix(HEADS * (NOPE + VALUE), KV_RANK, 4),
    shape: [HEADS * (NOPE + VALUE), KV_RANK],
  }],
  [`${PREFIX}.o_proj.weight`, {
    data: matrix(HIDDEN, HEADS * VALUE, 5),
    shape: [HIDDEN, HEADS * VALUE],
  }],
]);

class TinyWeights implements Glm52MlaWeightSource {
  readonly arrays = new Map<string, MlxArray>();

  constructor() {
    for (const [name, value] of hostWeights)
      this.arrays.set(name, MlxArray.fromFloat32(value.data, value.shape));
  }

  tensor(name: string): MlxArray {
    const value = this.arrays.get(name);
    if (!value) throw new Error(`missing tiny tensor ${name}`);
    return value;
  }

  dequantized(name: string, outputRows: number, inputColumns: number): MlxArray {
    const source = this.tensor(name);
    expect(source.shape).toEqual([outputRows, inputColumns]);
    return ops.contiguous(source);
  }

  linear(
    input: MlxArray,
    name: string,
    outputRows: number,
    inputColumns: number,
  ): MlxArray {
    const weight = this.tensor(name);
    expect(weight.shape).toEqual([outputRows, inputColumns]);
    const transpose = ops.transposeAxes(weight, [1, 0]);
    const output = ops.matmul(input, transpose);
    transpose.dispose();
    return output;
  }

  dispose(): void {
    for (const array of this.arrays.values()) array.dispose();
    this.arrays.clear();
  }
}

const config: Glm52Config = {
  modelDir: "/tiny",
  modelType: "glm_moe_dsa",
  architectures: ["GlmMoeDsaForCausalLM"],
  hiddenSize: HIDDEN,
  numHiddenLayers: 1,
  numAttentionHeads: HEADS,
  numKeyValueHeads: 1,
  qLoraRank: Q_RANK,
  kvLoraRank: KV_RANK,
  qkNopeHeadDim: NOPE,
  qkRopeHeadDim: ROPE,
  qkHeadDim: NOPE + ROPE,
  vHeadDim: VALUE,
  firstKDenseReplace: 0,
  intermediateSize: 8,
  moeIntermediateSize: 4,
  numRoutedExperts: 8,
  numExpertsPerToken: 2,
  numSharedExperts: 1,
  nGroup: 1,
  topkGroup: 1,
  normTopkProb: true,
  routedScalingFactor: 1,
  rmsNormEps: 1e-5,
  ropeTheta: 10_000,
  ropeInterleave: true,
  vocabSize: 32,
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

function close(actual: Float32Array, expected: ArrayLike<number>, tolerance = 3e-5): void {
  expect(actual.length).toBe(expected.length);
  for (let index = 0; index < actual.length; index++)
    expect(Math.abs(actual[index]! - expected[index]!)).toBeLessThanOrEqual(tolerance);
}

function row(input: Float32Array, token: number): Float32Array {
  return input.slice(token * HIDDEN, (token + 1) * HIDDEN);
}

function weight(name: string): Float32Array {
  return hostWeights.get(name)!.data;
}

function rows(
  name: string,
  outputRows: number,
  inputColumns: number,
): Float32Array[] {
  const values = weight(name);
  return Array.from({ length: outputRows }, (_, output) =>
    values.slice(output * inputColumns, (output + 1) * inputColumns),
  );
}

/** Independent host implementation of reconstructed causal MLA. */
function hostMla(input: Float32Array, tokens: number): {
  output: Float32Array;
  latent: Float32Array;
  rope: Float32Array;
} {
  const qNope: Float32Array[][] = [];
  const qRope: Float32Array[][] = [];
  const latent: Float32Array[] = [];
  const rope: Float32Array[] = [];
  for (let token = 0; token < tokens; token++) {
    const hidden = row(input, token);
    const qA = matvecF32(
      hidden,
      rows(`${PREFIX}.q_a_proj.weight`, Q_RANK, HIDDEN),
    );
    const qNorm = rmsNormF32(
      qA,
      weight(`${PREFIX}.q_a_layernorm.weight`),
      config.rmsNormEps,
    );
    const q = matvecF32(
      qNorm,
      rows(`${PREFIX}.q_b_proj.weight`, HEADS * (NOPE + ROPE), Q_RANK),
    );
    qNope[token] = [];
    qRope[token] = [];
    for (let head = 0; head < HEADS; head++) {
      const start = head * (NOPE + ROPE);
      qNope[token]![head] = q.slice(start, start + NOPE);
      qRope[token]![head] = partialInterleavedRopeF32(
        q.slice(start + NOPE, start + NOPE + ROPE),
        token,
        ROPE,
        config.ropeTheta,
      );
    }

    const compressed = matvecF32(
      hidden,
      rows(`${PREFIX}.kv_a_proj_with_mqa.weight`, KV_RANK + ROPE, HIDDEN),
    );
    latent[token] = rmsNormF32(
      compressed.slice(0, KV_RANK),
      weight(`${PREFIX}.kv_a_layernorm.weight`),
      config.rmsNormEps,
    );
    rope[token] = partialInterleavedRopeF32(
      compressed.slice(KV_RANK),
      token,
      ROPE,
      config.ropeTheta,
    );
  }

  const kv = latent.map((value) => matvecF32(
    value,
    rows(`${PREFIX}.kv_b_proj.weight`, HEADS * (NOPE + VALUE), KV_RANK),
  ));
  const outputs = new Float32Array(tokens * HIDDEN);
  for (let queryToken = 0; queryToken < tokens; queryToken++) {
    const combined = new Float32Array(HEADS * VALUE);
    for (let head = 0; head < HEADS; head++) {
      const scores = new Float32Array(queryToken + 1);
      for (let keyToken = 0; keyToken <= queryToken; keyToken++) {
        const base = head * (NOPE + VALUE);
        let score = 0;
        for (let dimension = 0; dimension < NOPE; dimension++)
          score += qNope[queryToken]![head]![dimension]! * kv[keyToken]![base + dimension]!;
        for (let dimension = 0; dimension < ROPE; dimension++)
          score += qRope[queryToken]![head]![dimension]! * rope[keyToken]![dimension]!;
        scores[keyToken] = score / Math.sqrt(NOPE + ROPE);
      }
      const maximum = Math.max(...scores);
      const probabilities = Float32Array.from(scores, (score) => Math.exp(score - maximum));
      const denominator = probabilities.reduce((sum, value) => sum + value, 0);
      for (let keyToken = 0; keyToken <= queryToken; keyToken++) {
        const probability = probabilities[keyToken]! / denominator;
        const base = head * (NOPE + VALUE) + NOPE;
        for (let dimension = 0; dimension < VALUE; dimension++) {
          const index = head * VALUE + dimension;
          combined[index] =
            combined[index]! + probability * kv[keyToken]![base + dimension]!;
        }
      }
    }
    outputs.set(matvecF32(
      combined,
      rows(`${PREFIX}.o_proj.weight`, HIDDEN, HEADS * VALUE),
    ), queryToken * HIDDEN);
  }
  return {
    output: outputs,
    latent: Float32Array.from(latent.flatMap((value) => [...value])),
    rope: Float32Array.from(rope.flatMap((value) => [...value])),
  };
}

describe("GLM-5.2 MLX MLA", () => {
  test("implements pair-interleaved partial RoPE and preserves the tail", () => {
    const input = MlxArray.fromFloat32(
      new Float32Array([
        1, 2, 3, 4, 9,
        -2, 0.5, 1.5, -3, 8,
      ]),
      [1, 2, 5],
    );
    try {
      const output = partialInterleavedRopeMlx(input, 3, 4, 10_000);
      const expected = new Float32Array([
        ...partialInterleavedRopeF32([1, 2, 3, 4, 9], 3, 4, 10_000),
        ...partialInterleavedRopeF32([-2, 0.5, 1.5, -3, 8], 4, 4, 10_000),
      ]);
      close(output.toFloat32(), expected, 3e-6);
      output.dispose();
    } finally {
      input.dispose();
    }
  });

  test("reconstructs causal prefill while caching only latent plus RoPE state", () => {
    const values = new Float32Array([
      0.2, -0.4, 0.7, 0.1,
      -0.3, 0.8, 0.25, -0.6,
      0.9, -0.2, -0.1, 0.5,
    ]);
    const expected = hostMla(values, 3);
    const input = MlxArray.fromFloat32(values, [1, 3, HIDDEN]);
    const weights = new TinyWeights();
    const cache = new MLACache({ kvLoraRank: KV_RANK, ropeHeadDim: ROPE });
    const mla = new Glm52Mla(config, weights, 0);
    try {
      const output = mla.forward(input, cache, null, "reconstructed");
      close(output.toFloat32(), expected.output);
      expect(cache.offset).toBe(3);
      expect(cache.state().map((array) => array.shape)).toEqual([
        [1, 3, KV_RANK],
        [1, 3, ROPE],
      ]);
      const state = cache.fetch();
      close(state.latent.toFloat32(), expected.latent);
      close(state.rope.toFloat32(), expected.rope);
      state.latent.dispose();
      state.rope.dispose();
      output.dispose();
    } finally {
      input.dispose();
      cache.dispose();
      weights.dispose();
    }
  });

  test("absorbed single-token decode equals reconstructed MLA with a prefix", () => {
    const prefixValues = new Float32Array([
      0.2, -0.4, 0.7, 0.1,
      -0.3, 0.8, 0.25, -0.6,
    ]);
    const decodeValues = new Float32Array([0.9, -0.2, -0.1, 0.5]);
    const prefixInputA = MlxArray.fromFloat32(prefixValues, [1, 2, HIDDEN]);
    const prefixInputB = MlxArray.fromFloat32(prefixValues, [1, 2, HIDDEN]);
    const decodeInputA = MlxArray.fromFloat32(decodeValues, [1, 1, HIDDEN]);
    const decodeInputB = MlxArray.fromFloat32(decodeValues, [1, 1, HIDDEN]);
    const weightsA = new TinyWeights();
    const weightsB = new TinyWeights();
    const cacheA = new MLACache({ kvLoraRank: KV_RANK, ropeHeadDim: ROPE });
    const cacheB = new MLACache({ kvLoraRank: KV_RANK, ropeHeadDim: ROPE });
    const mlaA = new Glm52Mla(config, weightsA, 0);
    const mlaB = new Glm52Mla(config, weightsB, 0);
    try {
      const prefillA = mlaA.forward(prefixInputA, cacheA, null, "reconstructed");
      const prefillB = mlaB.forward(prefixInputB, cacheB, null, "reconstructed");
      prefillA.dispose();
      prefillB.dispose();
      const absorbed = mlaA.forward(decodeInputA, cacheA, null, "absorbed");
      const reconstructed = mlaB.forward(
        decodeInputB,
        cacheB,
        null,
        "reconstructed",
      );
      close(absorbed.toFloat32(), reconstructed.toFloat32(), 3e-5);
      const allValues = new Float32Array([...prefixValues, ...decodeValues]);
      const expected = hostMla(allValues, 3).output.slice(2 * HIDDEN);
      close(absorbed.toFloat32(), expected, 3e-5);
      expect(cacheA.offset).toBe(3);
      expect(cacheB.offset).toBe(3);
      absorbed.dispose();
      reconstructed.dispose();
    } finally {
      for (const input of [
        prefixInputA,
        prefixInputB,
        decodeInputA,
        decodeInputB,
      ]) {
        input.dispose();
      }
      cacheA.dispose();
      cacheB.dispose();
      weightsA.dispose();
      weightsB.dispose();
    }
  });

  test("rejects absorbed multi-token execution without mutating the cache", () => {
    const input = MlxArray.fromFloat32(
      new Float32Array([
        0.2, -0.4, 0.7, 0.1,
        -0.3, 0.8, 0.25, -0.6,
      ]),
      [1, 2, HIDDEN],
    );
    const weights = new TinyWeights();
    const cache = new MLACache({ kvLoraRank: KV_RANK, ropeHeadDim: ROPE });
    const mla = new Glm52Mla(config, weights, 0);
    try {
      expect(() => mla.forward(input, cache, null, "absorbed"))
        .toThrow(/single-token/);
      expect(cache.offset).toBe(0);
      expect(cache.byteLength).toBe(0);
    } finally {
      input.dispose();
      cache.dispose();
      weights.dispose();
    }
  });
});
