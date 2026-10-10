/** How a composition's attention caches store keys and values. A quantized
 * scheme carries `quantizedKvStart` only when it is nonzero: storage stays
 * bf16 until a sequence holds that many tokens, then converts in place. */
export type KvStorageScheme =
  | { readonly kind: "bf16" }
  /** Every attention layer, affine-quantized with one bit width and group size. */
  | { readonly kind: "affine"; readonly bits: number; readonly groupSize: number; readonly quantizedKvStart?: number }
  /** The layers listed (cache index), each with its own bit width and group size; the others stay bf16. */
  | { readonly kind: "affine-layers"; readonly layers: readonly AffineKvLayer[]; readonly quantizedKvStart?: number }
  /** Full-attention layers TurboQuant-encoded; sliding-window layers stay bf16. */
  | { readonly kind: "turbo"; readonly kBits: number; readonly vBits: number; readonly quantizedKvStart?: number };

export interface AffineKvLayer {
  readonly layer: number;
  readonly bits: number;
  readonly groupSize: number;
}

/** Drafted tokens per verify round: a fixed count (0 when the composition has
 * no drafter), or adaptive, where the scheduler picks each round's count up to
 * `max`. */
export type DraftDepth = number | { readonly adaptive: true; readonly max: number };

/** The facts that fix one served configuration, resolved once by the
 * application before the loader builds the graph and consumed as data. Every
 * field holds a resolved value; nothing here is "unset" or "auto". */
export interface Composition {
  /** The GPU's architecture identifier as MLX reports it (for example `applegpu_g16s`). */
  readonly device: string;
  /** The Neural Engine bridge loaded and compiles programs on this machine. */
  readonly aneBridge: boolean;
  readonly kv: KvStorageScheme;
  readonly draftDepth: DraftDepth;
  /** The prefill chunk size, in prompt tokens, the composition is built for.
   * The prefill planner may hand the graph fewer rows than this as a prompt's
   * tail. Its per-prompt halving for a graph with a bounded prefill workspace
   * is the planner's business and does not change what the composition built. */
  readonly prefillChunkTokens: number;
  /** LoRA adapters are mounted when the model loads. */
  readonly adapters: boolean;
  /** The most rows one forward carries (`--batch`, mlx-lm's `--batch-size`). */
  readonly maxRows: number;
}
