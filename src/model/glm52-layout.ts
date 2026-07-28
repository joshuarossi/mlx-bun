// Exact logical tensor contract for the direct Colibri GLM-5.2 container.

import type { Glm52Config } from "./glm52-config";
import {
  ColibriGlm52Container,
  type ColibriTensorInfo,
} from "./glm52-container";

export interface Glm52LayoutValidation {
  readonly quantizedTensors: number;
  readonly floatTensors: number;
  readonly routedExperts: number;
  readonly hasDsa: boolean;
  readonly hasMtp: boolean;
}

function sameShape(actual: readonly number[], expected: readonly number[]): boolean {
  return actual.length === expected.length &&
    actual.every((dimension, index) => dimension === expected[index]);
}

function validateFloatTensor(
  container: ColibriGlm52Container,
  name: string,
  shape: number[],
): ColibriTensorInfo {
  const tensor = container.info(name);
  if (tensor.dtype !== "F32")
    throw new Error(`${name}: resident tensor must be F32 (got ${tensor.dtype})`);
  if (!sameShape(tensor.shape, shape)) {
    throw new Error(
      `${name}: shape ${JSON.stringify(tensor.shape)} != ${JSON.stringify(shape)}`,
    );
  }
  return tensor;
}

export function validateGlm52ContainerLayout(
  container: ColibriGlm52Container,
  config: Glm52Config,
): Glm52LayoutValidation {
  let quantizedTensors = 0;
  let floatTensors = 0;
  let routedExperts = 0;
  const q = (name: string, output: number, input: number): void => {
    container.quantized(name, output, input);
    quantizedTensors++;
  };
  const f = (name: string, shape: number[]): void => {
    validateFloatTensor(container, name, shape);
    floatTensors++;
  };
  const D = config.hiddenSize;
  const H = config.numAttentionHeads;
  const indexCapabilities = container.capabilities(config);

  q("model.embed_tokens.weight", config.vocabSize, D);
  q("lm_head.weight", config.vocabSize, D);
  f("model.norm.weight", [D]);

  const validateAttention = (layer: number): void => {
    const p = `model.layers.${layer}`;
    f(`${p}.input_layernorm.weight`, [D]);
    f(`${p}.post_attention_layernorm.weight`, [D]);
    q(`${p}.self_attn.q_a_proj.weight`, config.qLoraRank, D);
    f(`${p}.self_attn.q_a_layernorm.weight`, [config.qLoraRank]);
    q(
      `${p}.self_attn.q_b_proj.weight`,
      H * config.qkHeadDim,
      config.qLoraRank,
    );
    q(
      `${p}.self_attn.kv_a_proj_with_mqa.weight`,
      config.kvLoraRank + config.qkRopeHeadDim,
      D,
    );
    f(`${p}.self_attn.kv_a_layernorm.weight`, [config.kvLoraRank]);
    q(
      `${p}.self_attn.kv_b_proj.weight`,
      H * (config.qkNopeHeadDim + config.vHeadDim),
      config.kvLoraRank,
    );
    q(`${p}.self_attn.o_proj.weight`, D, H * config.vHeadDim);
  };

  const validateSparseMlp = (layer: number): void => {
    const p = `model.layers.${layer}.mlp`;
    f(`${p}.gate.weight`, [config.numRoutedExperts, D]);
    f(`${p}.gate.e_score_correction_bias`, [config.numRoutedExperts]);
    const sharedIntermediate =
      config.moeIntermediateSize * config.numSharedExperts;
    if (sharedIntermediate > 0) {
      q(`${p}.shared_experts.gate_proj.weight`, sharedIntermediate, D);
      q(`${p}.shared_experts.up_proj.weight`, sharedIntermediate, D);
      q(`${p}.shared_experts.down_proj.weight`, D, sharedIntermediate);
    }
    for (let expert = 0; expert < config.numRoutedExperts; expert++) {
      const e = `${p}.experts.${expert}`;
      q(`${e}.gate_proj.weight`, config.moeIntermediateSize, D);
      q(`${e}.up_proj.weight`, config.moeIntermediateSize, D);
      q(`${e}.down_proj.weight`, D, config.moeIntermediateSize);
      routedExperts++;
    }
  };

  for (let layer = 0; layer < config.numHiddenLayers; layer++) {
    validateAttention(layer);
    const p = `model.layers.${layer}.mlp`;
    if (layer < config.firstKDenseReplace) {
      q(`${p}.gate_proj.weight`, config.intermediateSize, D);
      q(`${p}.up_proj.weight`, config.intermediateSize, D);
      q(`${p}.down_proj.weight`, D, config.intermediateSize);
    } else {
      validateSparseMlp(layer);
    }
  }

  if (indexCapabilities.hasDsa) {
    for (let layer = 0; layer < config.numHiddenLayers; layer++) {
      if (config.indexerTypes[layer] !== "full") continue;
      const p = `model.layers.${layer}.self_attn.indexer`;
      q(
        `${p}.wq_b.weight`,
        config.indexNumHeads * config.indexHeadDim,
        config.qLoraRank,
      );
      q(`${p}.wk.weight`, config.indexHeadDim, D);
      q(`${p}.weights_proj.weight`, config.indexNumHeads, D);
      f(`${p}.k_norm.weight`, [config.indexHeadDim]);
      f(`${p}.k_norm.bias`, [config.indexHeadDim]);
    }
  }

  if (indexCapabilities.hasMtp) {
    const layer = config.numHiddenLayers;
    const p = `model.layers.${layer}`;
    validateAttention(layer);
    validateSparseMlp(layer);
    q(`${p}.eh_proj.weight`, D, 2 * D);
    f(`${p}.enorm.weight`, [D]);
    f(`${p}.hnorm.weight`, [D]);
    f(`${p}.shared_head.norm.weight`, [D]);
  }

  return {
    quantizedTensors,
    floatTensors,
    routedExperts,
    hasDsa: indexCapabilities.hasDsa,
    hasMtp: indexCapabilities.hasMtp,
  };
}
