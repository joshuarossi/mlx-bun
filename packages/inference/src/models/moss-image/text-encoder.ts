// MOSS-Image's conditioner, the family's generic graph for its text encoder:
// the Qwen3.5-9B language model (transformers' `Qwen3_5Model` without a head)
// run once over the prompt rendered with the tokenizer's chat template,
// returning the final-norm hidden states. It binds one decoder layer per entry
// of the artifact's `layer_types` at construction (each projection dense or
// MLX-quantized as the artifact's quantization table states); `encode` runs
// them in order. The vision tower (`visual.*`) is never read.

import { MlxArray } from "@mlx-bun/mlx/array";
import { loadModelConfig, type ModelConfig } from "../../artifacts/config";
import { Weights } from "../../artifacts/weights";
import type { ImageConditioner } from "../../contracts/mlx/image-generation";
import { ChatTemplate } from "../../input/chat-template";
import { loadTokenizer, type LoadedTokenizer } from "../../input/tokenizer";
import { MossSilu, bindMossLinear, storedAffineSpec, type MossLinear } from "./layers";
import {
  MossFloat32RmsNorm, MossTextCausalConv, MossTextL2Norm, MossQuantizedTextEmbedding, MossTextAttention, MossTextAttentionLayer, MossTextDeltaLayer, MossTextDeltaMixer, MossTextDeltaRecurrence,
  MossTextEmbedding, MossTextGatedNorm, MossTextLogDecay, MossTextMlp, MossTextRmsNorm, MossTextRope,
} from "./text-layers";

/** The reference tokenizer call's `max_length`: prompts are truncated to it. */
export const MOSS_IMAGE_MAX_PROMPT_TOKENS = 4096;

const PREFIX = "language_model";

export class MossImageConditioner implements ImageConditioner {
  readonly activation: MossSilu;
  readonly embedding: MossTextEmbedding | MossQuantizedTextEmbedding;
  readonly rope: MossTextRope;
  readonly layers: readonly (MossTextDeltaLayer | MossTextAttentionLayer)[];
  readonly norm: MossTextRmsNorm;

  /** The language model's tensors. */
  static usesTensor(name: string): boolean {
    return name.startsWith(`${PREFIX}.`);
  }

  static async open(textDir: string, tokenizerDir: string): Promise<MossImageConditioner> {
    const [config, tokenizer, template] = await Promise.all([loadModelConfig(textDir), loadTokenizer(tokenizerDir), ChatTemplate.load(tokenizerDir)]);
    const weights = await Weights.open(textDir);
    try { return new MossImageConditioner(weights, config, tokenizer, template); }
    catch (error) { weights.dispose(); throw error; }
  }

  constructor(readonly weights: Weights, config: ModelConfig, readonly tokenizer: LoadedTokenizer, readonly template: ChatTemplate) {
    const t = config.text, eps = t.rmsNormEps;
    // Register resource-owning leaves only. Composite layers dispose these same
    // leaves after successful construction; registering both would release them twice on failure.
    const built: { dispose(): void }[] = [];
    const own = <T extends { dispose(): void }>(layer: T): T => { built.push(layer); return layer; };
    const linear = (path: string): MossLinear => own(bindMossLinear(weights, config, path));
    const normalization = new MossFloat32RmsNorm(eps);
    const norm = (path: string) => own(new MossTextRmsNorm(weights.tensor(`${path}.weight`), normalization));
    const mlp = (prefix: string) => new MossTextMlp(linear(`${prefix}.gate_proj`), linear(`${prefix}.up_proj`), linear(`${prefix}.down_proj`), this.activation);
    try {
      this.activation = own(new MossSilu());
      const embedding = `${PREFIX}.embed_tokens`, embeddingSpec = storedAffineSpec(weights, config, embedding);
      this.embedding = embeddingSpec
        ? new MossQuantizedTextEmbedding(weights.tensor(`${embedding}.weight`), weights.tensor(`${embedding}.scales`),
          weights.tensor(`${embedding}.biases`), embeddingSpec)
        : new MossTextEmbedding(weights.tensor(`${embedding}.weight`));
      this.rope = new MossTextRope(Math.trunc(t.headDim * t.partialRotaryFactor), t.ropeParameters.full_attention!.ropeTheta);
      const attentionShape = { heads: t.numAttentionHeads, kvHeads: t.numKeyValueHeads, headDim: t.headDim };
      const deltaShape = { keyHeads: t.linearNumKeyHeads, valueHeads: t.linearNumValueHeads, keyDim: t.linearKeyHeadDim, valueDim: t.linearValueHeadDim };
      const layers: (MossTextDeltaLayer | MossTextAttentionLayer)[] = [];
      if (t.layerTypes.length !== t.numHiddenLayers) throw new Error(`text encoder config: ${t.layerTypes.length} layer_types for ${t.numHiddenLayers} layers`);
      for (let i = 0; i < t.numHiddenLayers; i++) {
        const prefix = `${PREFIX}.layers.${i}`, kind = t.layerTypes[i];
        if (kind === "linear_attention") {
          const mixer = `${prefix}.linear_attn`;
          layers.push(new MossTextDeltaLayer(norm(`${prefix}.input_layernorm`),
            new MossTextDeltaMixer(linear(`${mixer}.in_proj_qkv`), linear(`${mixer}.in_proj_z`), linear(`${mixer}.in_proj_b`), linear(`${mixer}.in_proj_a`),
              linear(`${mixer}.out_proj`), new MossTextCausalConv(weights.tensor(`${mixer}.conv1d.weight`)),
              new MossTextDeltaRecurrence(own(new MossTextLogDecay(weights.tensor(`${mixer}.A_log`), weights.tensor(`${mixer}.dt_bias`))), new MossTextL2Norm()),
              new MossTextGatedNorm(weights.tensor(`${mixer}.norm.weight`), normalization, this.activation), deltaShape, this.activation),
            norm(`${prefix}.post_attention_layernorm`), mlp(`${prefix}.mlp`)));
        } else if (kind === "full_attention") {
          const attention = `${prefix}.self_attn`;
          layers.push(new MossTextAttentionLayer(norm(`${prefix}.input_layernorm`),
            new MossTextAttention(linear(`${attention}.q_proj`), linear(`${attention}.k_proj`), linear(`${attention}.v_proj`), linear(`${attention}.o_proj`),
              norm(`${attention}.q_norm`), norm(`${attention}.k_norm`), this.rope, attentionShape),
            norm(`${prefix}.post_attention_layernorm`), mlp(`${prefix}.mlp`)));
        } else {
          throw new Error(`text encoder config: layer ${i} has unknown type ${String(kind)}`);
        }
      }
      this.layers = layers;
      this.norm = norm(`${PREFIX}.norm`);
    } catch (error) {
      for (const layer of built.reverse()) layer.dispose();
      throw error;
    }
  }

  /** The prompt's token ids: the user turn rendered with the generation prompt
   * and thinking enabled, truncated to the reference's 4096. */
  tokens(prompt: string): number[] {
    const rendered = this.template.render([{ role: "user", content: prompt }], { addGenerationPrompt: true, enableThinking: true });
    return this.tokenizer.encode(rendered, false).slice(0, MOSS_IMAGE_MAX_PROMPT_TOKENS);
  }

  encode(prompt: string): MlxArray {
    const ids = this.tokens(prompt);
    using idArray = MlxArray.fromInt32(Int32Array.from(ids), [1, ids.length]);
    let h = this.embedding.forward(idArray);
    try {
      for (const layer of this.layers) {
        using previous = h;
        h = layer.forward(previous);
        h.eval();
      }
      const out = this.norm.forward(h);
      try { out.eval(); } catch (error) { out.dispose(); throw error; }
      return out;
    } finally {
      h.dispose();
    }
  }

  dispose(): void {
    for (const layer of this.layers) layer.dispose();
    this.norm.dispose();
    this.activation.dispose();
    this.weights.dispose();
  }
}
