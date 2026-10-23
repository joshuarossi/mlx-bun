// MOSS-Image's conditioner: the Qwen3.5-9B language model (`Qwen3_5Model`
// without a head) over the prompt rendered with the tokenizer's chat template,
// returning the final-norm hidden states. The stack is composed from the Qwen
// family's public blocks (Gated DeltaNet and gated attention layers) with dense
// or MLX-quantized projections; the checkpoint's HF layout (stored gamma - 1
// norms, `[C, 1, K]` convolutions) is normalized by the Qwen 3.5 weights view.

import { MlxArray } from "@mlx-bun/mlx/array";
import * as ops from "@mlx-bun/mlx/ops";
import { loadModelConfig, type ModelConfig } from "../../artifacts/config";
import { Weights } from "../../artifacts/weights";
import type { Cache } from "../../contracts/mlx/cache";
import type { ImageConditioner } from "../../contracts/mlx/image-generation";
import { ChatTemplate } from "../../input/chat-template";
import { loadTokenizer, type LoadedTokenizer } from "../../input/tokenizer";
import { DenseEmbedding } from "../../layers/dense-embedding";
import { DenseLinear } from "../../layers/dense-linear";
import { RMSNorm } from "../../layers/normalization";
import { QuantizedEmbedding } from "../../layers/quantized-embedding";
import { QuantizedLinear } from "../../layers/quantized-linear";
import { compiledSwiglu } from "../../layers/swiglu";
import { KVCache } from "../../state/kv";
import { SSMCache } from "../../state/ssm";
import { GatedDeltaNet, Qwen3Attention, QwenAttentionLayer, QwenDeltaLayer } from "../qwen/blocks";
import { qwen35WeightsView } from "../qwen/checkpoint";

/** The reference tokenizer call's `max_length` (prompts are truncated to it). */
export const MOSS_IMAGE_MAX_PROMPT_TOKENS = 4096;

type TextLinear = DenseLinear | QuantizedLinear;

/** Dense SwiGLU feed-forward: `down(silu(gate(x)) * up(x))` with the compiled swiglu. */
class SwigluMlp {
  constructor(readonly gate: TextLinear, readonly up: TextLinear, readonly down: TextLinear) {}
  forward(x: MlxArray): MlxArray {
    using hidden = compiledSwiglu(this.gate.forward(x), this.up.forward(x));
    return this.down.forward(hidden);
  }
}

interface EncoderLayer {
  forward(x: MlxArray, cache: Cache, phase: "window"): MlxArray;
}

export class MossImageConditioner implements ImageConditioner {
  readonly embed: DenseEmbedding | QuantizedEmbedding;
  readonly layers: readonly EncoderLayer[];
  readonly recurrent: readonly boolean[];
  readonly norm: RMSNorm;
  readonly #linears: TextLinear[] = [];

  /** The language model's tensors; the vision tower (`visual.*`) is never read. */
  static usesTensor(name: string): boolean {
    return name.startsWith("language_model.");
  }

  static async open(textDir: string, tokenizerDir: string): Promise<MossImageConditioner> {
    const [config, tokenizer, template] = await Promise.all([loadModelConfig(textDir), loadTokenizer(tokenizerDir), ChatTemplate.load(tokenizerDir)]);
    const weights = await Weights.open(textDir);
    try {
      const view = qwen35WeightsView(weights);
      if (view) weights.setView(view);
      return new MossImageConditioner(weights, config, tokenizer, template);
    } catch (error) {
      weights.dispose();
      throw error;
    }
  }

  constructor(readonly weights: Weights, readonly config: ModelConfig, readonly tokenizer: LoadedTokenizer, readonly template: ChatTemplate) {
    const t = config.text;
    if (!(t.fullAttentionInterval > 0)) throw new Error("text encoder config: full_attention_interval must be positive");
    const linear = (w: Weights, path: string, c: ModelConfig): TextLinear => {
      const layer = w.has(`${path}.scales`) ? QuantizedLinear.load(w, path, c)
        : new DenseLinear(w.tensor(`${path}.weight`), w.has(`${path}.bias`) ? w.tensor(`${path}.bias`) : null);
      this.#linears.push(layer);
      return layer;
    };
    this.embed = weights.has("language_model.embed_tokens.scales")
      ? QuantizedEmbedding.load(weights, "language_model.embed_tokens", config)
      : new DenseEmbedding(weights.tensor("language_model.embed_tokens.weight"));
    const layers: EncoderLayer[] = [], recurrent: boolean[] = [];
    for (let i = 0; i < t.numHiddenLayers; i++) {
      const prefix = `language_model.layers.${i}`;
      const mlp = new SwigluMlp(linear(weights, `${prefix}.mlp.gate_proj`, config), linear(weights, `${prefix}.mlp.up_proj`, config),
        linear(weights, `${prefix}.mlp.down_proj`, config));
      const isRecurrent = (i + 1) % t.fullAttentionInterval !== 0;
      recurrent.push(isRecurrent);
      layers.push(isRecurrent
        ? new QwenDeltaLayer(weights, config, prefix, new GatedDeltaNet<TextLinear>(weights, config, `${prefix}.linear_attn`, linear), mlp)
        : new QwenAttentionLayer(weights, config, prefix, new Qwen3Attention<TextLinear>(weights, config, `${prefix}.self_attn`, linear), mlp));
    }
    this.layers = layers;
    this.recurrent = recurrent;
    this.norm = new RMSNorm(weights.tensor("language_model.norm.weight"), t.rmsNormEps);
  }

  /** The prompt's token ids: the user turn rendered with the generation prompt
   * and thinking enabled, truncated to the reference's 4096. */
  tokens(prompt: string): number[] {
    const rendered = this.template.render([{ role: "user", content: prompt }], { addGenerationPrompt: true, enableThinking: true });
    return this.tokenizer.encode(rendered, false).slice(0, MOSS_IMAGE_MAX_PROMPT_TOKENS);
  }

  encode(prompt: string): MlxArray {
    const ids = this.tokens(prompt);
    if (ids.length === 0) throw new Error("the rendered prompt has no tokens");
    const caches: Cache[] = this.recurrent.map(isRecurrent => isRecurrent ? new SSMCache() : new KVCache());
    using idArray = MlxArray.fromInt32(Int32Array.from(ids), [1, ids.length]);
    let h = this.embed.encode(idArray);
    try {
      for (let i = 0; i < this.layers.length; i++) {
        const next = this.layers[i]!.forward(h, caches[i]!, "window");
        h.dispose();
        h = next;
        // Bound the graph per layer; the recurrent state is not a dependency of `h`.
        const state = caches[i]!.state();
        try { ops.evalAll([h, ...state]); }
        finally { if (caches[i]!.stateNeedsDispose) for (const array of state) array.dispose(); }
      }
      const out = this.norm.forward(h);
      out.eval();
      return out;
    } finally {
      h.dispose();
      for (const cache of caches) cache.dispose();
    }
  }

  dispose(): void {
    for (const linear of this.#linears) if (linear instanceof DenseLinear) linear.dispose();
    this.#linears.length = 0;
    if (this.embed instanceof DenseEmbedding) this.embed.wT.dispose();
    this.weights.dispose();
  }
}
