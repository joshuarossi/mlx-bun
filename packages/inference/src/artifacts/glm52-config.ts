// Dedicated GLM-5.2 / glm_moe_dsa configuration.
//
// This intentionally does not extend the universal dense descriptor. GLM-5.2
// has a different attention state (compressed MLA + DSA), a correction-biased
// sigmoid router, a native MTP row, and a converted Colibri container whose
// quantization metadata is carried by tensor byte geometry rather than the
// source checkpoint's FP8 quantization_config.

export type Glm52IndexerType = "full" | "shared";

export interface Glm52Config {
  readonly modelDir: string;
  readonly modelType: "glm_moe_dsa";
  readonly architectures: string[];
  readonly hiddenSize: number;
  readonly numHiddenLayers: number;
  readonly numAttentionHeads: number;
  readonly numKeyValueHeads: number;
  readonly qLoraRank: number;
  readonly kvLoraRank: number;
  readonly qkNopeHeadDim: number;
  readonly qkRopeHeadDim: number;
  readonly qkHeadDim: number;
  readonly vHeadDim: number;
  readonly firstKDenseReplace: number;
  readonly intermediateSize: number;
  readonly moeIntermediateSize: number;
  readonly numRoutedExperts: number;
  readonly numExpertsPerToken: number;
  readonly numSharedExperts: number;
  readonly nGroup: number;
  readonly topkGroup: number;
  readonly normTopkProb: boolean;
  readonly routedScalingFactor: number;
  readonly rmsNormEps: number;
  readonly ropeTheta: number;
  readonly ropeInterleave: boolean;
  readonly vocabSize: number;
  readonly maxPositionEmbeddings: number;
  readonly indexTopk: number;
  readonly indexNumHeads: number;
  readonly indexHeadDim: number;
  readonly indexerRopeInterleave: boolean;
  readonly indexerTypes: Glm52IndexerType[];
  readonly numNextnPredictLayers: number;
  readonly indexShareForMtpIteration: boolean;
  readonly eosTokenIds: number[];
  readonly padTokenId: number;
  readonly raw: Record<string, unknown>;
}

function integer(
  raw: Record<string, any>,
  key: string,
  options: { min?: number; max?: number; fallback?: number } = {},
): number {
  const value = raw[key] ?? options.fallback;
  if (!Number.isInteger(value))
    throw new Error(`GLM-5.2 config: ${key} must be an integer (got ${String(value)})`);
  if (options.min !== undefined && value < options.min)
    throw new Error(`GLM-5.2 config: ${key}=${value} is below ${options.min}`);
  if (options.max !== undefined && value > options.max)
    throw new Error(`GLM-5.2 config: ${key}=${value} exceeds ${options.max}`);
  return value;
}

function finite(
  raw: Record<string, any>,
  key: string,
  options: { min?: number; fallback?: number } = {},
): number {
  const value = raw[key] ?? options.fallback;
  if (typeof value !== "number" || !Number.isFinite(value))
    throw new Error(`GLM-5.2 config: ${key} must be finite (got ${String(value)})`);
  if (options.min !== undefined && value < options.min)
    throw new Error(`GLM-5.2 config: ${key}=${value} is below ${options.min}`);
  return value;
}

function boolean(raw: Record<string, any>, key: string, fallback = false): boolean {
  const value = raw[key] ?? fallback;
  if (typeof value !== "boolean")
    throw new Error(`GLM-5.2 config: ${key} must be boolean (got ${String(value)})`);
  return value;
}

function tokenIds(value: unknown, source: string): number[] {
  if (value === undefined || value === null) return [];
  const values = Array.isArray(value) ? value : [value];
  return values.map((id) => {
    if (!Number.isInteger(id) || id < 0)
      throw new Error(`GLM-5.2 config: ${source} contains invalid token id ${String(id)}`);
    return id as number;
  });
}

function unionTokenIds(...groups: number[][]): number[] {
  const seen = new Set<number>();
  const out: number[] = [];
  for (const group of groups) {
    for (const id of group) {
      if (seen.has(id)) continue;
      seen.add(id);
      out.push(id);
    }
  }
  return out;
}

function indexerSchedule(raw: Record<string, any>, layers: number): Glm52IndexerType[] {
  const explicit = raw.indexer_types;
  if (explicit !== undefined) {
    if (!Array.isArray(explicit) || explicit.length !== layers)
      throw new Error(
        `GLM-5.2 config: indexer_types must have ${layers} entries ` +
        `(got ${Array.isArray(explicit) ? explicit.length : typeof explicit})`,
      );
    return explicit.map((entry, layer) => {
      if (entry !== "full" && entry !== "shared")
        throw new Error(`GLM-5.2 config: indexer_types[${layer}]=${String(entry)}`);
      return entry;
    });
  }

  const frequency = integer(raw, "index_topk_freq", { min: 1, fallback: 1 });
  const offset = integer(raw, "index_skip_topk_offset", { min: 0, fallback: 2 });
  // Exact pinned-Colibri fallback:
  //   v = max(layer - offset + 1, 0); full iff v % frequency == 0.
  return Array.from({ length: layers }, (_, layer) => {
    const v = Math.max(layer - offset + 1, 0);
    return v % frequency === 0 ? "full" : "shared";
  });
}

export function parseGlm52Config(
  modelDir: string,
  raw: Record<string, any>,
  generation: Record<string, any> | null = null,
): Glm52Config {
  if (raw.model_type !== "glm_moe_dsa")
    throw new Error(`expected model_type "glm_moe_dsa" (got ${String(raw.model_type)})`);

  const hiddenSize = integer(raw, "hidden_size", { min: 1, max: 1 << 20 });
  const numHiddenLayers = integer(raw, "num_hidden_layers", { min: 1, max: 128 });
  const numAttentionHeads = integer(raw, "num_attention_heads", { min: 1, max: 1024 });
  const numKeyValueHeads = integer(raw, "num_key_value_heads", {
    min: 1,
    max: 1024,
    fallback: numAttentionHeads,
  });
  const qLoraRank = integer(raw, "q_lora_rank", { min: 1, max: 1 << 20 });
  const kvLoraRank = integer(raw, "kv_lora_rank", { min: 1, max: 1 << 20 });
  const qkNopeHeadDim = integer(raw, "qk_nope_head_dim", { min: 1, max: 1 << 16 });
  const qkRopeHeadDim = integer(raw, "qk_rope_head_dim", { min: 1, max: 1 << 16 });
  const qkHeadDim = integer(raw, "qk_head_dim", {
    min: 1,
    max: 1 << 16,
    fallback: qkNopeHeadDim + qkRopeHeadDim,
  });
  if (qkHeadDim !== qkNopeHeadDim + qkRopeHeadDim)
    throw new Error(
      `GLM-5.2 config: qk_head_dim=${qkHeadDim} != qk_nope_head_dim + ` +
      `qk_rope_head_dim (${qkNopeHeadDim + qkRopeHeadDim})`,
    );

  const numRoutedExperts = integer(raw, "n_routed_experts", { min: 1, max: 4096 });
  const numExpertsPerToken = integer(raw, "num_experts_per_tok", {
    min: 1,
    max: numRoutedExperts,
  });
  const nGroup = integer(raw, "n_group", { min: 1 });
  const topkGroup = integer(raw, "topk_group", { min: 1 });
  // The pinned GLM engine implements the n_group=1 noaux_tc router exactly.
  // Refuse a future grouped-router architecture instead of silently selecting
  // from the wrong candidate set.
  if (nGroup !== 1 || topkGroup !== 1)
    throw new Error(`GLM-5.2 config: only n_group=1/topk_group=1 is supported`);

  const indexTopk = integer(raw, "index_topk", { min: 0, max: 1 << 20, fallback: 0 });
  const indexNumHeads = integer(raw, "index_n_heads", { min: 0, max: 1024, fallback: 0 });
  const indexHeadDim = integer(raw, "index_head_dim", { min: 0, max: 1 << 16, fallback: 0 });
  if ((indexTopk === 0) !== (indexNumHeads === 0 || indexHeadDim === 0))
    throw new Error(
      `GLM-5.2 config: incomplete DSA geometry ` +
      `(topk=${indexTopk}, heads=${indexNumHeads}, head_dim=${indexHeadDim})`,
    );

  const eosTokenIds = unionTokenIds(
    tokenIds(raw.eos_token_id, "config.json:eos_token_id"),
    tokenIds(generation?.eos_token_id, "generation_config.json:eos_token_id"),
  );
  if (eosTokenIds.length === 0)
    throw new Error("GLM-5.2 config: no EOS token ids in config or generation config");

  return {
    modelDir,
    modelType: "glm_moe_dsa",
    architectures: Array.isArray(raw.architectures)
      ? raw.architectures.map((entry: unknown) => String(entry))
      : [],
    hiddenSize,
    numHiddenLayers,
    numAttentionHeads,
    numKeyValueHeads,
    qLoraRank,
    kvLoraRank,
    qkNopeHeadDim,
    qkRopeHeadDim,
    qkHeadDim,
    vHeadDim: integer(raw, "v_head_dim", { min: 1, max: 1 << 16 }),
    firstKDenseReplace: integer(raw, "first_k_dense_replace", {
      min: 0,
      max: numHiddenLayers,
    }),
    intermediateSize: integer(raw, "intermediate_size", { min: 1, max: 1 << 24 }),
    moeIntermediateSize: integer(raw, "moe_intermediate_size", { min: 1, max: 1 << 20 }),
    numRoutedExperts,
    numExpertsPerToken,
    numSharedExperts: integer(raw, "n_shared_experts", { min: 0, max: 64, fallback: 0 }),
    nGroup,
    topkGroup,
    normTopkProb: boolean(raw, "norm_topk_prob", false),
    routedScalingFactor: finite(raw, "routed_scaling_factor", { min: 0, fallback: 1 }),
    rmsNormEps: finite(raw, "rms_norm_eps", { min: 0, fallback: 1e-5 }),
    ropeTheta: finite(raw.rope_parameters ?? raw, "rope_theta", {
      min: Number.MIN_VALUE,
      fallback: 10000,
    }),
    ropeInterleave: boolean(raw, "rope_interleave", true),
    vocabSize: integer(raw, "vocab_size", { min: 1, max: 1 << 24 }),
    maxPositionEmbeddings: integer(raw, "max_position_embeddings", {
      min: 1,
      max: 1 << 30,
    }),
    indexTopk,
    indexNumHeads,
    indexHeadDim,
    indexerRopeInterleave: boolean(raw, "indexer_rope_interleave", true),
    indexerTypes: indexerSchedule(raw, numHiddenLayers),
    numNextnPredictLayers: integer(raw, "num_nextn_predict_layers", {
      min: 0,
      max: 8,
      fallback: 0,
    }),
    indexShareForMtpIteration: boolean(raw, "index_share_for_mtp_iteration", false),
    eosTokenIds,
    padTokenId: integer(raw, "pad_token_id", { min: 0, fallback: eosTokenIds[0] }),
    raw,
  };
}

export async function loadGlm52Config(modelDir: string): Promise<Glm52Config> {
  const configFile = Bun.file(`${modelDir}/config.json`);
  if (!(await configFile.exists()))
    throw new Error(`${modelDir}: missing config.json`);
  const raw = (await configFile.json()) as Record<string, any>;
  const generationFile = Bun.file(`${modelDir}/generation_config.json`);
  const generation = await generationFile.exists()
    ? await generationFile.json() as Record<string, any>
    : null;
  return parseGlm52Config(modelDir, raw, generation);
}
