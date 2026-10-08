// Small helpers shared by the opt-in real-weight consumers: all-or-nothing
// opt-in parsing, content hashes, artifact pin checks, the custom
// sliding-window descriptor, and releases that run even when one fails.
// No native imports.
import { strict as assert } from "node:assert";
import { createHash } from "node:crypto";
import { closeSync, createReadStream, existsSync, openSync, readFileSync, readSync } from "node:fs";
import { join } from "node:path";

export const sha256 = (bytes: string | Uint8Array) => createHash("sha256").update(bytes).digest("hex");
export async function fileSha256(path: string): Promise<string> {
  const hash = createHash("sha256");
  for await (const chunk of createReadStream(path)) hash.update(chunk);
  return hash.digest("hex");
}
export const isSha256 = (value: unknown): value is string => typeof value === "string" && /^[0-9a-f]{64}$/.test(value);

/** Every named setting, or none. None skips (null); a partial or blank opt-in fails. */
export function optInAll<N extends string>(env: Record<string, string | undefined>, names: readonly N[], label: string): Record<N, string> | null {
  const values = names.map(name => env[name]);
  if (values.every(value => value === undefined)) return null;
  const missing = names.filter((_, i) => !values[i]?.trim());
  if (missing.length) throw new Error(`${label} needs all of ${names.join(", ")}; missing or blank: ${missing.join(", ")}`);
  return Object.fromEntries(names.map((name, i) => [name, values[i]!])) as Record<N, string>;
}

/** The pinned files of a model artifact, by content, wherever it now lives:
 * each named file, then the index's shard set against the pinned shards and
 * each shard. The recorded snapshot path is never compared. */
export async function verifyArtifact(model: string, pins: { files: Record<string, string>; weights: Record<string, string> },
  required: readonly string[] = ["config.json", "model.safetensors.index.json"]): Promise<void> {
  for (const name of required) assert(pins.files?.[name], `artifact pins do not include ${name}`);
  for (const [name, pin] of Object.entries(pins.files)) {
    assert(isSha256(pin), `${name}: invalid SHA-256`);
    assert.equal(await fileSha256(join(model, name)), pin, `model file ${name} differs from its pin`);
  }
  // A single-file artifact has no index: its one model.safetensors is the shard set.
  const indexPath = join(model, "model.safetensors.index.json");
  const shards = existsSync(indexPath)
    ? [...new Set(Object.values((JSON.parse(readFileSync(indexPath, "utf8")) as { weight_map?: Record<string, string> }).weight_map ?? {}))]
    : ["model.safetensors"];
  assert.deepEqual(shards.sort(), Object.keys(pins.weights ?? {}).sort(), "index shards differ from the pinned shards");
  for (const [name, pin] of Object.entries(pins.weights)) {
    assert(isSha256(pin), `${name}: invalid SHA-256`);
    assert.equal(await fileSha256(join(model, name)), pin, `weights ${name} differ from their pin`);
  }
}

const FLOATING: Record<string, string> = { F16: "float16", BF16: "bfloat16", F32: "float32", F64: "float64" };
/** The one floating dtype a selected model artifact stores, from the
 * safetensors headers of the shards its index names (or its single
 * model.safetensors). For the consumers' artifacts, whose Universal and Gemma4
 * graphs load stored tensors without casting, this is the expected KV dtype;
 * it is not a claim about every graph. A config's dtype describes the source
 * model and is not consulted. Artifacts with no floating tensors, or with more
 * than one floating dtype, are unsupported rather than inferred. */
export function storedFloatDtype(model: string): string {
  const index = join(model, "model.safetensors.index.json");
  const shards = existsSync(index)
    ? [...new Set(Object.values((JSON.parse(readFileSync(index, "utf8")) as { weight_map?: Record<string, string> }).weight_map ?? {}))]
    : ["model.safetensors"];
  const found = new Set<string>();
  for (const shard of shards) {
    const fd = openSync(join(model, shard), "r");
    try {
      const prefix = Buffer.alloc(8);
      assert.equal(readSync(fd, prefix, 0, 8, 0), 8, `${shard}: no safetensors header`);
      const length = Number(prefix.readBigUInt64LE(0));
      assert(Number.isSafeInteger(length) && length > 1 && length < (1 << 28), `${shard}: header length ${length}`);
      const header = Buffer.alloc(length);
      assert.equal(readSync(fd, header, 0, length, 8), length, `${shard}: truncated header`);
      for (const [name, entry] of Object.entries(JSON.parse(header.toString("utf8")) as Record<string, { dtype?: string }>))
        if (name !== "__metadata__" && entry.dtype! in FLOATING) found.add(FLOATING[entry.dtype!]!);
    } finally { closeSync(fd); }
  }
  if (found.size !== 1) throw new Error(`${model}: stored floating dtypes [${[...found].join(", ")}]; exactly one is supported`);
  return [...found][0]!;
}

/** A custom sliding-window graph's descriptor over a Llama-family artifact's
 * unchanged weights (not a published model): alternating sliding and full
 * layers, one value source. */
export interface WindowDescriptor { layerTypes: string[]; slidingWindow: number }
export function descriptorFor(layers: number, window: number): WindowDescriptor {
  return { layerTypes: Array.from({ length: layers }, (_, i) => i % 2 === 0 ? "sliding_attention" : "full_attention"), slidingWindow: window };
}
/** One descriptor for both the parsed config and the raw arguments the graph is built from. */
export function applyDescriptor(config: { raw: Record<string, unknown>; text: { layerTypes: string[]; slidingWindow: number } },
  descriptor: WindowDescriptor): void {
  const raw = (config.raw.text_config ?? config.raw) as Record<string, unknown>;
  raw.layer_types = [...descriptor.layerTypes]; raw.sliding_window = descriptor.slidingWindow;
  config.text.layerTypes = [...descriptor.layerTypes]; config.text.slidingWindow = descriptor.slidingWindow;
}

/** Run every release even when one throws, then rethrow the first failure. */
export function releaseAll(releases: Array<() => void>): void {
  const failures: unknown[] = [];
  for (const release of releases) { try { release(); } catch (error) { failures.push(error); } }
  if (failures.length) throw failures[0];
}

/** Values of raw bytes stored as bfloat16 or float32 (little-endian). */
export function floatValues(bytes: Uint8Array, dtype: "bfloat16" | "float32"): Float32Array {
  const copy = new Uint8Array(bytes); // aligned, owns its bytes
  if (dtype === "float32") return new Float32Array(copy.buffer);
  const half = new Uint16Array(copy.buffer), bits = new Uint32Array(half.length);
  for (let i = 0; i < half.length; i++) bits[i] = half[i]! << 16;
  return new Float32Array(bits.buffer);
}
