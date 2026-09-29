// Fold plan for the HF (transformers 5) Qwen3.5-family layout: tensors named
// `model.language_model.*` / `model.visual.*` / top-level `lm_head.weight` /
// in-repo `mtp.*`. `planQwen35Fold` (rotate.ts) covers the older
// `language_model.model.*` naming; this plan is its sibling for checkpoints
// that store RMSNorm gains as γ−1.
//
// Gain convention: the stored gain is γ−1 (the loader adds 1 for this family),
// so the fold uses `stored + 1` and writes every folded norm back as ZEROS —
// the loader's shift then yields the gain-free norm the rotation needs.
//
// Corridors match planQwen35Fold: R1-only (+γ). Readers fold the input dim with
// the preceding norm's γ, writers fold the output dim; the attention output
// gate does not commute with a per-head rotation, so there is no R2.

import type { FoldOp } from "./rotate";
import { LM_PREFIX, MTP_PREFIX, VISION_PREFIX } from "./trellis-allocation";

export interface Qwen35HfFoldPlan {
  ops: Map<string, FoldOp>;
  /** γ tensors the fold context preloads (stored+1 applied by the executor). */
  gammaNames: string[];
  /** Norm tensors written back as zeros (every folded γ, plus `mtp.norm.weight`). */
  zeroNorms: Set<string>;
}

export interface Qwen35HfFoldSource {
  readonly tensorNames: readonly string[];
  has(name: string): boolean;
  info(name: string): { shape: readonly number[] };
}

/** Plan the fold of every tensor of `source`. The vision merger and the MTP
 *  companion are folded when present. Throws when a trunk tensor the plan needs
 *  is missing, or when a 2-D trunk tensor is left unplanned. */
export function planQwen35HfFold(
  source: Qwen35HfFoldSource,
  arch: { numHiddenLayers: number; layerTypes: readonly string[] },
): Qwen35HfFoldPlan {
  const ops = new Map<string, FoldOp>();
  const gammaNames: string[] = [];
  const zeroNorms = new Set<string>();
  const addGamma = (name: string): void => { gammaNames.push(name); zeroNorms.add(name); };
  const readers = (block: string, gamma: string, tensors: string[]) => {
    for (const t of tensors) ops.set(`${block}.${t}.weight`, { kind: "input", gamma });
  };

  const finalNorm = `${LM_PREFIX}norm.weight`;
  addGamma(finalNorm);
  ops.set(`${LM_PREFIX}embed_tokens.weight`, { kind: "input" });
  ops.set("lm_head.weight", { kind: "input", gamma: finalNorm });

  for (let i = 0; i < arch.numHiddenLayers; i++) {
    const block = `${LM_PREFIX}layers.${i}`;
    const inNorm = `${block}.input_layernorm.weight`;
    const postNorm = `${block}.post_attention_layernorm.weight`;
    addGamma(inNorm);
    addGamma(postNorm);
    const linear = arch.layerTypes[i] === "linear_attention";
    readers(block, inNorm, linear
      ? ["linear_attn.in_proj_qkv", "linear_attn.in_proj_z", "linear_attn.in_proj_b", "linear_attn.in_proj_a"]
      : ["self_attn.q_proj", "self_attn.k_proj", "self_attn.v_proj"]);
    ops.set(`${block}.${linear ? "linear_attn.out_proj" : "self_attn.o_proj"}.weight`, { kind: "output" });
    readers(block, postNorm, ["mlp.gate_proj", "mlp.up_proj"]);
    ops.set(`${block}.mlp.down_proj.weight`, { kind: "output" });
  }

  if (source.has(`${VISION_PREFIX}merger.linear_fc2.weight`)) {
    ops.set(`${VISION_PREFIX}merger.linear_fc2.weight`, { kind: "output" });
    ops.set(`${VISION_PREFIX}merger.linear_fc2.bias`, { kind: "bias" });
  }

  if (source.has(`${MTP_PREFIX}fc.weight`)) {
    const embedNorm = `${MTP_PREFIX}pre_fc_norm_embedding.weight`;
    const hiddenNorm = `${MTP_PREFIX}pre_fc_norm_hidden.weight`;
    addGamma(embedNorm);
    addGamma(hiddenNorm);
    zeroNorms.add(`${MTP_PREFIX}norm.weight`);
    ops.set(`${MTP_PREFIX}fc.weight`, { kind: "mtp-fc", gammaEmbed: embedNorm, gammaHidden: hiddenNorm });
    const block = `${MTP_PREFIX}layers.0`;
    const inNorm = `${block}.input_layernorm.weight`;
    const postNorm = `${block}.post_attention_layernorm.weight`;
    addGamma(inNorm);
    addGamma(postNorm);
    readers(block, inNorm, ["self_attn.q_proj", "self_attn.k_proj", "self_attn.v_proj"]);
    ops.set(`${block}.self_attn.o_proj.weight`, { kind: "output" });
    readers(block, postNorm, ["mlp.gate_proj", "mlp.up_proj"]);
    ops.set(`${block}.mlp.down_proj.weight`, { kind: "output" });
  }

  for (const name of ops.keys())
    if (!source.has(name)) throw new Error(`fold plan: missing source tensor ${name}`);
  for (const name of gammaNames)
    if (!source.has(name)) throw new Error(`fold plan: missing γ tensor ${name}`);
  const unplanned = source.tensorNames.filter(
    (n) => n.endsWith(".weight") && !ops.has(n) && !zeroNorms.has(n) &&
      (n.startsWith(LM_PREFIX) || n.startsWith(MTP_PREFIX)) &&
      source.info(n).shape.length === 2 && !n.includes("_norm.") && !n.endsWith("attn.norm.weight"),
  );
  if (unplanned.length) throw new Error(`fold plan: unplanned 2-D trunk tensors ${unplanned.join(", ")}`);
  return { ops, gammaNames, zeroNorms };
}
