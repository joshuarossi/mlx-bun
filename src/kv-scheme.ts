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
      return `turbo-k${turbo.kBits}v${turbo.vBits}`;
    }
    if (this.kind === "affine-uniform") return `kv${this.options.kvBits}`;
    if (this.kind === "affine-config") return "config";
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

  /** The current batch engine accepts only per-layer affine schemes whose
   * named cache instances can perform the required conversion. The capability
   * probe is mandatory for quantized schemes so config shape alone can never
   * authorize placement. */
  batchable(config: ModelConfig, canConvert?: (layerIdx: number) => boolean): boolean {
    if (this.kind === "bf16") return true;
    if (this.kind !== "affine-config") return false;
    if (!canConvert) return false;
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
}): KvScheme {
  if (input.turboQuant) {
    return new KvScheme("turbo", {
      turboQuant: input.turboQuant,
      quantizedKvStart: 0,
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
    return new KvScheme("affine-config", { kvConfig: [...input.config] });
  }
  return new KvScheme("affine-uniform", {
    kvBits: input.override,
    quantizedKvStart: 0,
  });
}
