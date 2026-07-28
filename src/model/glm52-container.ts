// Header-only reader and validator for Colibri's converted GLM-5.2 artifact.
//
// Colibri emits ordinary safetensors shards named out-*, out-mtp-* and
// optionally out-idx-*. There is no model.safetensors.index.json. Tensor byte
// geometry is authoritative: converted 2-D tensors are flattened U8 payloads
// with companion F32 `<name>.qs` scales. Reading only the headers avoids
// mapping hundreds of GiB merely to validate the artifact.

import { closeSync, fstatSync, openSync, readSync, readdirSync } from "node:fs";
import { basename, join } from "node:path";
import type { Glm52Config } from "./glm52-config";

export type ColibriShardFamily = "main" | "mtp" | "indexer";
export type ColibriDtype =
  | "BOOL" | "U8" | "I8" | "U16" | "I16" | "U32" | "I32" | "U64" | "I64"
  | "F16" | "BF16" | "F32" | "F64";

const DTYPE_BYTES: Record<ColibriDtype, number> = {
  BOOL: 1, U8: 1, I8: 1, U16: 2, I16: 2, U32: 4, I32: 4,
  U64: 8, I64: 8, F16: 2, BF16: 2, F32: 4, F64: 8,
};

const GROUP_SIZES = [16, 32, 48, 64, 96, 128, 192, 256] as const;
// Match safetensors' own defensive ceiling: headers are metadata, never model
// payload. This prevents a corrupt multi-GiB shard from becoming a matching
// multi-GiB Bun allocation before JSON validation.
const MAX_SAFETENSORS_HEADER_BYTES = 100_000_000n;

interface HeaderTensor {
  dtype: ColibriDtype;
  shape: number[];
  data_offsets: [number, number];
}

export interface ColibriTensorInfo {
  readonly name: string;
  readonly dtype: ColibriDtype;
  readonly shape: number[];
  readonly file: string;
  readonly family: ColibriShardFamily;
  readonly begin: number;
  readonly end: number;
  readonly absoluteBegin: number;
  readonly absoluteEnd: number;
  readonly byteLength: number;
}

export interface ColibriQuantTensorInfo {
  readonly name: string;
  readonly outputRows: number;
  readonly inputColumns: number;
  readonly bits: 4 | 8;
  readonly groupSize: number | null;
  readonly weight: ColibriTensorInfo;
  readonly scales: ColibriTensorInfo;
  readonly coalescedNextWeight: string | null;
}

export interface Glm52ContainerCapabilities {
  readonly hasMtp: boolean;
  readonly hasDsa: boolean;
  readonly missingMtpTensors: string[];
  readonly missingDsaTensors: string[];
}

function product(shape: number[], label: string): number {
  let value = 1;
  for (const dim of shape) {
    if (!Number.isSafeInteger(dim) || dim < 0)
      throw new Error(`${label}: invalid shape ${JSON.stringify(shape)}`);
    value *= dim;
    if (!Number.isSafeInteger(value))
      throw new Error(`${label}: shape product exceeds safe integer range`);
  }
  return value;
}

function readFully(fd: number, buffer: Uint8Array, position: number, label: string): void {
  let offset = 0;
  while (offset < buffer.byteLength) {
    const got = readSync(fd, buffer, offset, buffer.byteLength - offset, position + offset);
    if (got === 0)
      throw new Error(`${label}: short read at ${position + offset}`);
    offset += got;
  }
}

function familyFor(filename: string): ColibriShardFamily | null {
  if (/^out-mtp-\d+\.safetensors$/.test(filename)) return "mtp";
  if (/^out-idx-\d+\.safetensors$/.test(filename)) return "indexer";
  if (/^out-\d+\.safetensors$/.test(filename)) return "main";
  return null;
}

function parseHeader(path: string, family: ColibriShardFamily): ColibriTensorInfo[] {
  const fd = openSync(path, "r");
  try {
    const stat = fstatSync(fd);
    if (stat.size < 8) throw new Error(`${path}: too small for safetensors`);
    const prefix = Buffer.allocUnsafe(8);
    readFully(fd, prefix, 0, path);
    const headerBig = prefix.readBigUInt64LE(0);
    if (headerBig > MAX_SAFETENSORS_HEADER_BYTES) {
      throw new Error(
        `${path}: safetensors header ${headerBig} exceeds ` +
        `${MAX_SAFETENSORS_HEADER_BYTES} byte limit`,
      );
    }
    if (headerBig > BigInt(Number.MAX_SAFE_INTEGER))
      throw new Error(`${path}: safetensors header is too large`);
    const headerLength = Number(headerBig);
    const dataStart = 8 + headerLength;
    if (headerLength < 2 || dataStart > stat.size)
      throw new Error(`${path}: invalid safetensors header length ${headerLength}`);
    const bytes = Buffer.allocUnsafe(headerLength);
    readFully(fd, bytes, 8, path);
    let parsed: Record<string, HeaderTensor | Record<string, string>>;
    try {
      parsed = JSON.parse(bytes.toString("utf8"));
    } catch (error) {
      throw new Error(`${path}: invalid safetensors JSON: ${String(error)}`);
    }

    const out: ColibriTensorInfo[] = [];
    for (const [name, raw] of Object.entries(parsed)) {
      if (name === "__metadata__") continue;
      const entry = raw as HeaderTensor;
      if (!entry || !(entry.dtype in DTYPE_BYTES) || !Array.isArray(entry.shape) ||
          !Array.isArray(entry.data_offsets) || entry.data_offsets.length !== 2)
        throw new Error(`${path}: malformed tensor entry ${name}`);
      const [begin, end] = entry.data_offsets;
      if (!Number.isSafeInteger(begin) || !Number.isSafeInteger(end) || begin < 0 || end < begin)
        throw new Error(`${path}: tensor ${name} has invalid offsets ${String(entry.data_offsets)}`);
      const elements = product(entry.shape, `${path}:${name}`);
      const expected = elements * DTYPE_BYTES[entry.dtype];
      if (end - begin !== expected)
        throw new Error(
          `${path}: tensor ${name} byte range ${end - begin} != ` +
          `${JSON.stringify(entry.shape)} × ${entry.dtype}`,
        );
      if (dataStart + end > stat.size)
        throw new Error(`${path}: tensor ${name} extends past end of shard`);
      out.push({
        name,
        dtype: entry.dtype,
        shape: [...entry.shape],
        file: path,
        family,
        begin,
        end,
        absoluteBegin: dataStart + begin,
        absoluteEnd: dataStart + end,
        byteLength: end - begin,
      });
    }
    return out;
  } finally {
    closeSync(fd);
  }
}

export class ColibriGlm52Container {
  readonly tensors = new Map<string, ColibriTensorInfo>();
  readonly files: ReadonlyArray<{ path: string; family: ColibriShardFamily }>;

  private constructor(files: Array<{ path: string; family: ColibriShardFamily }>) {
    this.files = files;
    for (const { path, family } of files) {
      for (const tensor of parseHeader(path, family)) {
        const prior = this.tensors.get(tensor.name);
        if (prior)
          throw new Error(
            `duplicate Colibri tensor ${tensor.name} in ${basename(prior.file)} ` +
            `and ${basename(tensor.file)}`,
          );
        this.tensors.set(tensor.name, tensor);
      }
    }
    if (this.tensors.size === 0)
      throw new Error("Colibri container has no tensors");
  }

  static open(modelDir: string): ColibriGlm52Container {
    const files = readdirSync(modelDir)
      .map((name) => ({ name, family: familyFor(name) }))
      .filter((entry): entry is { name: string; family: ColibriShardFamily } =>
        entry.family !== null)
      .sort((a, b) => a.name.localeCompare(b.name))
      .map(({ name, family }) => ({ path: join(modelDir, name), family }));
    if (!files.some((entry) => entry.family === "main"))
      throw new Error(`${modelDir}: no out-NNNNN.safetensors Colibri shards`);
    return new ColibriGlm52Container(files);
  }

  has(name: string): boolean {
    return this.tensors.has(name);
  }

  info(name: string): ColibriTensorInfo {
    const info = this.tensors.get(name);
    if (!info) throw new Error(`Colibri container: missing tensor ${name}`);
    return info;
  }

  /** Validate a converted 2-D tensor and infer int4 group geometry from scales. */
  quantized(name: string, outputRows: number, inputColumns: number): ColibriQuantTensorInfo {
    if (!Number.isSafeInteger(outputRows) || outputRows <= 0 ||
        !Number.isSafeInteger(inputColumns) || inputColumns <= 0)
      throw new Error(`${name}: invalid logical shape [${outputRows},${inputColumns}]`);
    const weight = this.info(name);
    const scales = this.info(`${name}.qs`);
    if (weight.dtype !== "U8")
      throw new Error(`${name}: converted weight must be U8 (got ${weight.dtype})`);
    if (scales.dtype !== "F32")
      throw new Error(`${name}.qs: scales must be F32 (got ${scales.dtype})`);

    const int8Bytes = outputRows * inputColumns;
    const int4Bytes = outputRows * Math.ceil(inputColumns / 2);
    let bits: 4 | 8;
    if (weight.byteLength === int8Bytes) bits = 8;
    else if (weight.byteLength === int4Bytes) bits = 4;
    else {
      throw new Error(
        `${name}: ${weight.byteLength} bytes do not encode logical ` +
        `[${outputRows},${inputColumns}] as int8 (${int8Bytes}) or int4 (${int4Bytes})`,
      );
    }

    const scaleCount = scales.byteLength / 4;
    let groupSize: number | null = null;
    if (scaleCount !== outputRows) {
      if (bits !== 4)
        throw new Error(`${name}.qs: grouped scales are only valid for int4`);
      groupSize = GROUP_SIZES.find(
        (candidate) => scaleCount === outputRows * Math.ceil(inputColumns / candidate),
      ) ?? null;
      if (groupSize === null)
        throw new Error(
          `${name}.qs: ${scaleCount} scales do not match per-row or a supported ` +
          `group size for [${outputRows},${inputColumns}]`,
        );
    }

    let coalescedNextWeight: string | null = null;
    for (const other of this.tensors.values()) {
      if (other.dtype === "U8" && other.file === weight.file &&
          other.absoluteBegin === weight.absoluteEnd) {
        coalescedNextWeight = other.name;
        break;
      }
    }
    return {
      name,
      outputRows,
      inputColumns,
      bits,
      groupSize,
      weight,
      scales,
      coalescedNextWeight,
    };
  }

  capabilities(config: Glm52Config): Glm52ContainerCapabilities {
    const mtpLayer = config.numHiddenLayers;
    const mtpPrefix = `model.layers.${mtpLayer}`;
    // G4 validates the full MTP family before enabling drafting. G2 records the
    // architectural sentinels so a partial sidecar cannot masquerade as MTP.
    const mtpRequired = config.numNextnPredictLayers > 0 ? [
      `${mtpPrefix}.eh_proj.weight`,
      `${mtpPrefix}.enorm.weight`,
      `${mtpPrefix}.hnorm.weight`,
      `${mtpPrefix}.shared_head.norm.weight`,
      `${mtpPrefix}.input_layernorm.weight`,
      `${mtpPrefix}.post_attention_layernorm.weight`,
      `${mtpPrefix}.self_attn.q_a_proj.weight`,
      `${mtpPrefix}.self_attn.kv_a_proj_with_mqa.weight`,
      `${mtpPrefix}.mlp.gate.weight`,
      `${mtpPrefix}.mlp.gate.e_score_correction_bias`,
    ] : [];
    const missingMtpTensors = mtpRequired.filter((name) => !this.has(name));

    const dsaRequired: string[] = [];
    if (config.indexTopk > 0) {
      for (let layer = 0; layer < config.numHiddenLayers; layer++) {
        if (config.indexerTypes[layer] !== "full") continue;
        const prefix = `model.layers.${layer}.self_attn.indexer`;
        dsaRequired.push(
          `${prefix}.wq_b.weight`,
          `${prefix}.wk.weight`,
          `${prefix}.weights_proj.weight`,
          `${prefix}.k_norm.weight`,
          `${prefix}.k_norm.bias`,
        );
      }
    }
    const missingDsaTensors = dsaRequired.filter((name) => !this.has(name));
    return {
      hasMtp: mtpRequired.length > 0 && missingMtpTensors.length === 0,
      hasDsa: dsaRequired.length > 0 && missingDsaTensors.length === 0,
      missingMtpTensors,
      missingDsaTensors,
    };
  }
}
