// Small helpers shared by the opt-in real-weight consumers: all-or-nothing
// opt-in parsing, content hashes, artifact pin checks, and releases that run
// even when one fails. No native imports.
import { strict as assert } from "node:assert";
import { createHash } from "node:crypto";
import { createReadStream, readFileSync } from "node:fs";
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
  const index = JSON.parse(readFileSync(join(model, "model.safetensors.index.json"), "utf8")) as { weight_map?: Record<string, string> };
  assert.deepEqual([...new Set(Object.values(index.weight_map ?? {}))].sort(), Object.keys(pins.weights ?? {}).sort(),
    "index shards differ from the pinned shards");
  for (const [name, pin] of Object.entries(pins.weights)) {
    assert(isSha256(pin), `${name}: invalid SHA-256`);
    assert.equal(await fileSha256(join(model, name)), pin, `weights ${name} differ from their pin`);
  }
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
