import type { KvQuantSpec, ModelConfig, TurboQuantScheme } from "./config";

const BF16_BYTES = 2;

export type KvQuantOverride = "off" | "config" | number | undefined;

export interface KvSchemeOptions {
  kvBits?: number;
  kvGroupSize?: number;
  kvConfig?: KvQuantSpec[];
  quantizedKvStart?: number;
  turboQuant?: TurboQuantScheme;
}

interface ResolvedKvSchemeOptions extends Omit<KvSchemeOptions, "kvConfig" | "turboQuant"> {
  readonly kvConfig?: readonly Readonly<KvQuantSpec>[];
  readonly turboQuant?: Readonly<TurboQuantScheme>;
}

export type KvSchemeKind = "bf16" | "affine-uniform" | "affine-config" | "turbo";

export interface KvGeometry {
  fullBytesPerToken: number;
  slidingBytesPerToken: number;
  linearStateBytes: number;
  window: number;
}

/** Bytes per stored affine-quantized KV element, including scale and bias. */
export function kvQuantBytesPerElement(bits: number, groupSize: number): number {
  return bits / 8 + 4 / groupSize;
}

export function kvGeometry(config: ModelConfig, options: KvSchemeOptions = {}): KvGeometry {
  const text = config.text;
  const byLayer = options.kvConfig?.length
    ? new Map(options.kvConfig.map((entry) => [entry.layerIdx, entry]))
    : null;
  const uniformBytes = options.kvBits
    ? kvQuantBytesPerElement(options.kvBits, options.kvGroupSize ?? 64)
    : BF16_BYTES;
  const elementBytes = (layer: number): number => {
    const entry = byLayer?.get(layer);
    return entry
      ? kvQuantBytesPerElement(entry.bits, entry.groupSize)
      : byLayer ? BF16_BYTES : uniformBytes;
  };

  let linearLayers = 0;
  let fullBytesPerToken = 0;
  let slidingBytesPerToken = 0;
  for (let layer = 0; layer < text.numHiddenLayers; layer++) {
    const type = text.layerTypes[layer] ?? "full_attention";
    if (type === "linear_attention") {
      linearLayers++;
    } else if (type === "sliding_attention") {
      slidingBytesPerToken +=
        2 * text.numKeyValueHeads * text.headDim * elementBytes(layer);
    } else {
      fullBytesPerToken +=
        2 * text.numGlobalKeyValueHeads * text.globalHeadDim * elementBytes(layer);
    }
  }
  const convDim = 2 * text.linearNumKeyHeads * text.linearKeyHeadDim +
    text.linearNumValueHeads * text.linearValueHeadDim;
  const linearStateBytes = linearLayers === 0 ? 0 : linearLayers * (
    text.linearNumValueHeads * text.linearValueHeadDim * text.linearKeyHeadDim * 4 +
    Math.max(0, text.linearConvKernelDim - 1) * convDim * BF16_BYTES
  );
  return {
    fullBytesPerToken,
    slidingBytesPerToken,
    linearStateBytes,
    window: text.slidingWindow,
  };
}

export function kvBytesAt(
  config: ModelConfig,
  tokens: number,
  options: KvSchemeOptions = {},
): number {
  const value = kvGeometry(config, options);
  return value.fullBytesPerToken * tokens +
    value.slidingBytesPerToken * Math.min(tokens, value.window) +
    value.linearStateBytes;
}

/** Head dims MLX 0.32.2's fused multi-query SDPA kernel serves for L > 8
 *  queries on M1–M4 GPUs (mlx/backend/metal/scaled_dot_product_attention.cpp
 *  `use_fallback`: 192 and 256 always fall back off-NAX; `has_fused_kernel`
 *  lists 64/72/80/96/128 for the full kernel). Every other head dim runs
 *  mlx/fast.cpp's composed fallback, which materializes the bf16 scores
 *  tensor [heads, L, S] plus a bool mask per full-attention layer. The
 *  decode kernel (L ≤ 8) fuses 256, so this term is a prefill-only cost. */
export const FUSED_SDPA_HEAD_DIMS: ReadonlySet<number> = new Set([64, 72, 80, 96, 128]);
const SDPA_SCORES_BYTES = 2; // bf16 scores in q's dtype
const SDPA_FUSED_MAX_QUERIES = 8;

/** Peak bytes of the SDPA-fallback scores tensor live during one prefill
 *  chunk of `chunk` queries against a `ctx`-token context: the last chunk
 *  sees the longest keys, and the lazy graph keeps one layer's scores live
 *  at a time. Zero when every attention layer's head dim fuses. Sliding
 *  layers see at most `window + L` keys. Admission-only (fit and the
 *  in-flight memory guard); nothing here changes what is computed. */
export function sdpaFallbackBytes(config: ModelConfig, chunk: number, ctx: number): number {
  const text = config.text;
  const heads = text.numAttentionHeads || 0;
  const queries = Math.min(chunk, ctx);
  if (heads <= 0 || queries <= SDPA_FUSED_MAX_QUERIES) return 0;
  let peak = 0;
  const layers = text.numHiddenLayers || text.layerTypes.length;
  for (let layer = 0; layer < layers; layer++) {
    const type = text.layerTypes[layer] ?? "full_attention";
    if (type === "linear_attention") continue;
    const sliding = type === "sliding_attention" && text.slidingWindow > 0;
    const headDim = sliding ? text.headDim : text.globalHeadDim;
    if (FUSED_SDPA_HEAD_DIMS.has(headDim)) continue;
    const keys = sliding ? Math.min(ctx, text.slidingWindow + queries) : ctx;
    peak = Math.max(peak, heads * queries * keys * SDPA_SCORES_BYTES);
  }
  return peak;
}

export class KvScheme {
  readonly kind: KvSchemeKind;
  readonly options: Readonly<ResolvedKvSchemeOptions>;

  constructor(kind: KvSchemeKind, options: KvSchemeOptions) {
    this.kind = kind;
    const kvConfig = options.kvConfig?.map((entry) =>
      Object.freeze({ ...entry }),
    );
    const turboQuant = options.turboQuant
      ? Object.freeze({ ...options.turboQuant })
      : undefined;
    this.options = Object.freeze({
      ...options,
      ...(kvConfig ? { kvConfig: Object.freeze(kvConfig) } : {}),
      ...(turboQuant ? { turboQuant } : {}),
    });
  }

  get quantized(): boolean {
    return this.kind !== "bf16";
  }

  get cacheKey(): string {
    if (this.kind === "turbo") {
      const turbo = this.options.turboQuant!;
      const start = this.options.quantizedKvStart ?? 0;
      return `turbo-k${turbo.kBits}v${turbo.vBits}${start > 0 ? `-start${start}` : ""}`;
    }
    if (this.kind === "affine-uniform") {
      const start = this.options.quantizedKvStart ?? 5000, group = this.options.kvGroupSize ?? 64;
      return `kv${this.options.kvBits}${group !== 64 ? `-g${group}` : ""}${start > 0 ? `-start${start}` : ""}`;
    }
    if (this.kind === "affine-config") {
      const start = this.options.quantizedKvStart ?? 0;
      return `config${start > 0 ? `-start${start}` : ""}`;
    }
    return "bf16";
  }

  get label(): string {
    if (this.kind === "turbo") {
      const turbo = this.options.turboQuant!;
      return `turbo k${turbo.kBits}v${turbo.vBits}`;
    }
    if (this.kind === "affine-uniform") return `uniform-kv${this.options.kvBits}`;
    if (this.kind === "affine-config") return "mixed (kv_config.json)";
    return "bf16";
  }

  /** Configured attention storage, not live allocator occupancy. Recurrent
   * layers retain their own state and never acquire an attention KV codec. */
  describe(config: ModelConfig) {
    const layers: Record<string, number> = {};
    const attention = { global: 0, sliding_window: 0 };
    let recurrent_layers = 0;
    const perLayer = new Map(this.options.kvConfig?.map(entry => [entry.layerIdx, entry.bits]));
    for (let layer = 0; layer < config.text.numHiddenLayers; layer++) {
      const type = config.text.layerTypes[layer] ?? "full_attention";
      if (type === "linear_attention") { recurrent_layers++; continue; }
      const sliding = type === "sliding_attention";
      attention[sliding ? "sliding_window" : "global"]++;
      const bits = this.kind === "affine-config" ? perLayer.get(layer)
        : this.kind === "affine-uniform" ? this.options.kvBits : undefined;
      const codec = this.kind === "turbo" && !sliding
        ? `turbo-k${this.options.turboQuant!.kBits}v${this.options.turboQuant!.vBits}`
        : bits ? `kv${bits}` : "bf16";
      layers[codec] = (layers[codec] ?? 0) + 1;
    }
    return { mode: this.label, layers, attention, recurrent_layers };
  }

  bytesAt(config: ModelConfig, tokens: number): number {
    // TurboQuant stays conservatively billed as bf16 until its packed layout
    // exposes a stable projector.
    return kvBytesAt(config, tokens, this.fitOptions);
  }

  /** Mutable compatibility value for the numerical generator. The scheme
   *  keeps its declaration immutable and hands legacy consumers owned copies. */
  get generationOptions(): KvSchemeOptions {
    const { kvConfig, turboQuant, ...scalar } = this.options;
    return {
      ...scalar,
      ...(kvConfig
        ? { kvConfig: kvConfig.map((entry) => ({ ...entry })) }
        : {}),
      ...(turboQuant
        ? { turboQuant: { ...turboQuant } }
        : {}),
    };
  }

  get fitOptions(): KvSchemeOptions {
    return this.kind === "turbo" ? {} : this.generationOptions;
  }

  /** Affine layouts convert during solo prefill. TQ also has a transitional
   * row layout that preserves each request's delayed conversion boundary. */
  batchable(config: ModelConfig, canConvert?: (layerIdx: number) => boolean,
    cacheLayerCount = config.text.numHiddenLayers, capabilities: { delayedAffine?: boolean } = {}): boolean {
    if (this.kind === "bf16") return true;
    if (this.kind !== "affine-config" && this.kind !== "affine-uniform" && this.kind !== "turbo") return false;
    if (!canConvert) return false;
    const start = this.options.quantizedKvStart ?? (this.kind === "affine-uniform" ? 5000 : 0);
    if (start > 0 && this.kind !== "turbo" && !capabilities.delayedAffine) return false;
    if (this.kind === "affine-uniform" || this.kind === "turbo") {
      // Some models share the donor prefix's KV in later layers. Probe the
      // actual cache list, just as uniform conversion does.
      for (let layer = 0; layer < cacheLayerCount; layer++) {
        if (config.text.layerTypes[layer] === "linear_attention") continue;
        if (!canConvert(layer)) return false;
      }
      return true;
    }
    return this.options.kvConfig!.every((entry) => {
      if (entry.layerIdx < 0 || entry.layerIdx >= config.text.numHiddenLayers) return false;
      return (config.text.layerTypes[entry.layerIdx] ?? "full_attention") !== "linear_attention" &&
        canConvert(entry.layerIdx);
    });
  }
}

export function resolveKvScheme(input: {
  override?: KvQuantOverride;
  turboQuant?: TurboQuantScheme;
  config?: readonly KvQuantSpec[] | null;
  missingConfig?: "bf16" | "error";
  quantizedKvStart?: number;
}): KvScheme {
  const start = input.quantizedKvStart;
  if (start !== undefined && (!Number.isSafeInteger(start) || start < 0))
    throw new Error("quantizedKvStart must be a nonnegative integer");
  if (input.turboQuant) {
    return new KvScheme("turbo", {
      turboQuant: input.turboQuant,
      quantizedKvStart: start ?? 0,
    });
  }
  if (input.override === "off" || input.override === undefined)
    return new KvScheme("bf16", {});
  if (input.override === "config") {
    if (!input.config?.length) {
      if (input.missingConfig === "error")
        throw new Error("model has no kv_config.json (--kv-quant config)");
      return new KvScheme("bf16", {});
    }
    return new KvScheme("affine-config", { kvConfig: [...input.config],
      ...(start === undefined ? {} : { quantizedKvStart: start }) });
  }
  return new KvScheme("affine-uniform", {
    kvBits: input.override,
    quantizedKvStart: start ?? 0,
  });
}
