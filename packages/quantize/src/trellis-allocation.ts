// Which tensors the packed-Trellis producer codes, along which axis and at how
// many bits. Pure: names, shapes and an allocation file in, treatments out.
//
// Shipped-compact layout for the Qwen3.5-family MLP: gate/up/down are
// trellis-coded, embed/lm_head/attention stay affine at the protection tier,
// everything else rides the base tier, and the vision tower stays bf16.

/** Affine base tier and the protection tier (embed, lm_head, attention). */
export const TRELLIS_BASE_BITS = 3;
export const TRELLIS_PROTECT_BITS = 4;
/** Affine group size of the non-trellis tiers. */
export const TRELLIS_AFFINE_GROUP = 64;

/** Language-model tensor prefix of the HF (transformers 5) Qwen3.5 layout. */
export const LM_PREFIX = "model.language_model.";
export const VISION_PREFIX = "model.visual.";
export const MTP_PREFIX = "mtp.";

/** Which dim of down_proj the trellis runs along: `out` codes the ROTATED dim
 *  (the fold's R1 acts on down's output) and decodes through a column gather;
 *  `in` codes the un-rotated intermediate dim so down decodes with the same
 *  plain reduce kernel as gate/up. */
export type DownAxis = "out" | "in";

export type Treatment =
  | { kind: "bf16" }
  | { kind: "affine"; bits: number }
  | { kind: "trellis"; axis: 0 | 1; k: number };

/** Per-tensor allocation read from an allocation file's budget block. Keys are
 *  module base names in the artifact's tensor space (`model.language_model.…`). */
export interface TrellisKMap {
  /** Trellis bits per coded tensor. */
  k: Map<string, number>;
  /** Affine bit overrides for protected (non-MLP) modules. */
  affineBits: Map<string, number>;
}

/** Parse `budgets[budget]` of an allocation document. The file names tensors
 *  `model.layers.N.…`; they are mapped into the language-model prefix. */
export function parseKMap(doc: unknown, budget: string, source = "k-map"): TrellisKMap {
  const budgets = (doc as { budgets?: Record<string, { kmap?: Record<string, number>; affine_map?: Record<string, number> }> } | null)?.budgets;
  const selected = budgets?.[budget];
  if (!selected?.kmap)
    throw new Error(`${source}: no budgets["${budget}"].kmap (have ${Object.keys(budgets ?? {}).join(", ")})`);
  const rename = (name: string) => name.replace(/^model\.layers\./, `${LM_PREFIX}layers.`);
  const k = new Map<string, number>();
  for (const [name, bits] of Object.entries(selected.kmap)) {
    if (!Number.isInteger(bits) || bits < 1 || bits > 8) throw new Error(`${source}: bad k=${bits} for ${name}`);
    k.set(rename(name), bits);
  }
  const affineBits = new Map<string, number>(
    Object.entries(selected.affine_map ?? {}).map(([name, bits]) => [rename(name), bits]),
  );
  return { k, affineBits };
}

export interface TreatmentPolicy {
  /** Trellis bits for every coded tensor without a k-map entry. */
  bits: number;
  kMap?: TrellisKMap;
  downAxis: DownAxis;
  /** Only the first N decoder layers are trellis-coded; the rest ride the affine base tier. */
  layers?: number;
}

/** The treatment of module `base` (no `.weight` suffix) under `policy`. The
 *  trellis axis is the ROTATED axis: R1 acts on the input dim of gate/up and on
 *  the output dim of down_proj, so the coded sequence runs along the direction
 *  the Hadamard gaussianized. */
export function treatmentFor(base: string, policy: TreatmentPolicy): Treatment {
  if (base.startsWith(VISION_PREFIX)) return { kind: "bf16" };
  const kOf = (): number => {
    if (!policy.kMap) return policy.bits;
    const k = policy.kMap.k.get(base);
    if (k === undefined) throw new Error(`k-map: no entry for in-scope trellis tensor ${base}`);
    return k;
  };
  if (base.startsWith(`${LM_PREFIX}layers.`)) {
    const rest = base.slice(`${LM_PREFIX}layers.`.length);
    const layer = Number(rest.slice(0, rest.indexOf(".")));
    const mod = rest.slice(rest.indexOf(".") + 1);
    const inScope = policy.layers === undefined || layer < policy.layers;
    if (mod === "mlp.gate_proj" || mod === "mlp.up_proj")
      return inScope ? { kind: "trellis", axis: 1, k: kOf() } : { kind: "affine", bits: TRELLIS_BASE_BITS };
    if (mod === "mlp.down_proj")
      return inScope
        ? { kind: "trellis", axis: policy.downAxis === "in" ? 1 : 0, k: kOf() }
        : { kind: "affine", bits: TRELLIS_BASE_BITS };
    const mapped = policy.kMap?.affineBits.get(base);
    return { kind: "affine", bits: mapped ?? TRELLIS_PROTECT_BITS };
  }
  if (base === "lm_head" || base === `${LM_PREFIX}embed_tokens`) return { kind: "affine", bits: TRELLIS_PROTECT_BITS };
  return { kind: "affine", bits: TRELLIS_BASE_BITS }; // mtp.* rides the base tier
}

/** Packed cost of a coded tensor in bits per weight: k bits (the tail-biting
 *  block carries no initial state) plus one fp16 scale per coded row. */
export function trellisBpw(cols: number, k: number): number {
  return k + 16 / cols;
}

/** The mlx-lm key space of a tensor base: our qwen3_5 graph resolves module
 *  paths there (`language_model.model.layers…`) while the artifact stores
 *  tensors in the HF space (`model.language_model.layers…`). Null when the
 *  module has no mlx-lm counterpart (vision tower, mtp). */
export function mlxLmPath(base: string): string | null {
  if (base.startsWith(VISION_PREFIX) || base.startsWith(MTP_PREFIX)) return null;
  if (base.startsWith("model.language_model")) return base.replace("model.language_model", "language_model.model");
  return `language_model.${base}`;
}
