// Header-only artifact inventory for benchmark manifests. No MLX imports,
// tensor reads, downloads, or GPU work. Reuse the production safetensors and
// quantization parsers so aliases in config.json never double-count weights.
// bun scripts/bench/model-inventory.ts <model-dir> [<model-dir> ...] > reports/inventory.json
import { createHash } from "node:crypto";
import { existsSync, readFileSync, realpathSync } from "node:fs";
import { join } from "node:path";
import { parseQuantization, quantFor } from "../../src/config";
import { DTYPE_SIZE, SafetensorsFile, type TensorInfo } from "../../src/safetensors";

const sha256 = (data: string | Uint8Array) => createHash("sha256").update(data).digest("hex");

function role(name: string): string {
  if (/(^|\.)(visual|vision_tower|vision_model)\./.test(name)) return "vision";
  if (/(^|\.)mtp\./.test(name)) return "mtp";
  if (/embed_tokens\./.test(name)) return "embedding";
  if (/lm_head\./.test(name)) return "lm_head";
  return name.match(/\.(mlp|linear_attn|self_attn)\.([^.]+)\./)?.slice(1).join(".") ?? "other";
}

export interface MatrixInventory {
  name: string;
  role: string;
  storedShape: number[];
  logicalShape: number[];
  parameters: number;
  payloadBytes: number;
  mode: string;
  bits: number;
  groupSize: number | null;
  axis: number | null;
}

/** Infer only dense and supported packed matrices. Unknown layouts fail instead
 * of producing a plausible but false effective bits-per-weight measurement. */
export function matrixInventory(
  weight: TensorInfo,
  tensors: Map<string, TensorInfo>,
  quantization: ReturnType<typeof parseQuantization>,
): MatrixInventory | null {
  if (!weight.name.endsWith(".weight") || weight.shape.length !== 2) return null;
  const module = weight.name.slice(0, -7);
  const scales = tensors.get(`${module}.scales`);
  const biases = tensors.get(`${module}.biases`);
  const spec = scales ? quantFor(quantization, module) : null;
  const logicalShape = [...weight.shape];
  if (scales) {
    if (!spec || !["affine", "trellis", "mxfp4", "nvfp4", "mxfp8"].includes(spec.mode) ||
        !["U32", "U8"].includes(weight.dtype) || !(spec.bits > 0))
      throw new Error(`${weight.name}: cannot infer packed matrix layout`);
    logicalShape[1] = weight.shape[1]! * DTYPE_SIZE[weight.dtype] * 8 / spec.bits;
    if (!Number.isSafeInteger(logicalShape[1])) throw new Error(`${weight.name}: fractional logical width`);
    if (spec.mode === "trellis" && spec.trellis?.axis === 0) logicalShape.reverse();
  }
  const parameters = logicalShape.reduce((a, b) => a * b, 1);
  return {
    name: weight.name, role: role(weight.name), storedShape: weight.shape, logicalShape, parameters,
    payloadBytes: weight.end - weight.begin +
      (scales ? scales.end - scales.begin : 0) + (biases ? biases.end - biases.begin : 0),
    mode: spec?.mode ?? "dense", bits: spec?.bits ?? DTYPE_SIZE[weight.dtype] * 8,
    groupSize: spec?.groupSize ?? null, axis: spec?.trellis?.axis ?? null,
  };
}

export function inventoryModel(modelDir: string) {
  const path = realpathSync(modelDir);
  const configBytes = readFileSync(join(path, "config.json"));
  const config = JSON.parse(configBytes.toString());
  const text = config.text_config ?? config;
  const quant = parseQuantization(config.quantization ?? config.quantization_config ?? text.quantization);
  const indexPath = join(path, "model.safetensors.index.json");
  const indexBytes = existsSync(indexPath) ? readFileSync(indexPath) : null;
  const weightMap: Record<string, string> | null = indexBytes ? JSON.parse(indexBytes.toString()).weight_map : null;
  if (indexBytes && (!weightMap || typeof weightMap !== "object")) throw new Error(`${indexPath}: missing weight_map`);
  const fileNames = weightMap ? [...new Set(Object.values(weightMap))].sort() : ["model.safetensors"];
  const tensors = new Map<string, TensorInfo>();
  const tensorFiles = new Map<string, string>();
  const files = [];
  for (const name of fileNames) {
    const sf = SafetensorsFile.open(join(path, name));
    try {
      const header = [...sf.tensors.values()].sort((a, b) => a.name.localeCompare(b.name));
      files.push({ name, bytes: sf.mmap.size, layoutSha256: sha256(JSON.stringify(header)), tensors: header.length });
      for (const t of header) {
        if (tensors.has(t.name)) throw new Error(`duplicate tensor ${t.name}`);
        tensors.set(t.name, t);
        tensorFiles.set(t.name, name);
      }
    } finally { sf.mmap.unmap(); }
  }
  if (weightMap) {
    for (const [name, file] of Object.entries(weightMap))
      if (tensorFiles.get(name) !== file) throw new Error(`${name}: index/header mismatch`);
    if (tensors.size !== Object.keys(weightMap).length) throw new Error("shard contains tensors absent from weight_map");
  }
  const matrices = [...tensors.values()].map((t) => matrixInventory(t, tensors, quant))
    .filter((m): m is MatrixInventory => m !== null).sort((a, b) => a.name.localeCompare(b.name));
  const groups = new Map<string, { role: string; mode: string; bits: number; groupSize: number | null; axis: number | null; logicalShape: number[]; count: number; parameters: number; payloadBytes: number }>();
  for (const m of matrices) {
    const key = JSON.stringify([m.role, m.mode, m.bits, m.groupSize, m.axis, m.logicalShape]);
    const g = groups.get(key) ?? { role: m.role, mode: m.mode, bits: m.bits, groupSize: m.groupSize, axis: m.axis, logicalShape: m.logicalShape, count: 0, parameters: 0, payloadBytes: 0 };
    g.count++; g.parameters += m.parameters; g.payloadBytes += m.payloadBytes;
    groups.set(key, g);
  }
  const matrixParameters = matrices.reduce((n, m) => n + m.parameters, 0);
  const matrixPayloadBytes = matrices.reduce((n, m) => n + m.payloadBytes, 0);
  const roles: Record<string, { tensors: number; payloadBytes: number }> = {};
  for (const t of tensors.values()) {
    const r = roles[role(t.name)] ??= { tensors: 0, payloadBytes: 0 };
    r.tensors++; r.payloadBytes += t.end - t.begin;
  }
  return {
    schemaVersion: 1, path,
    identityNote: "Config/index hashes and tensor layouts only. Weight payloads are not hashed. Sidecars and mtp/ companions are excluded; inventory each companion separately.",
    configSha256: sha256(configBytes), indexSha256: indexBytes ? sha256(indexBytes) : null,
    architecture: Object.fromEntries([
      "model_type", "num_hidden_layers", "hidden_size", "intermediate_size", "vocab_size",
      "num_attention_heads", "num_key_value_heads", "head_dim", "full_attention_interval",
      "linear_num_key_heads", "linear_num_value_heads", "linear_key_head_dim", "linear_value_head_dim",
      "linear_conv_kernel_dim", "tie_word_embeddings",
    ].map((k) => [k, text[k] ?? null])),
    files, tensorCount: tensors.size, fileBytes: files.reduce((n, f) => n + f.bytes, 0),
    payloadBytes: [...tensors.values()].reduce((n, t) => n + t.end - t.begin, 0),
    matrixParameters, matrixPayloadBytes,
    matrixEffectiveBpw: matrixParameters ? matrixPayloadBytes * 8 / matrixParameters : null,
    bpwNote: "Rank-2 .weight matrices plus their .scales/.biases; excludes norms, convolutions and sidecars. This is not whole-model bpw or resident memory.",
    roles, projectionGroups: [...groups.values()], matrices,
  };
}

if (import.meta.main) {
  const paths = process.argv.slice(2);
  if (!paths.length || paths.some((p) => p.startsWith("--")))
    throw new Error("usage: bun scripts/bench/model-inventory.ts <model-dir> [<model-dir> ...]");
  console.log(JSON.stringify(paths.map(inventoryModel), null, 2));
}
