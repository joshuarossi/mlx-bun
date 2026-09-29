// Helpers shared by the opt-in Whisper, VAD and embedding parity tests: pinned
// reads of externally produced references and small comparison utilities.
// No native imports.
import { strict as assert } from "node:assert";
import { readFileSync } from "node:fs";
import { basename, join } from "node:path";
import { isSha256, sha256 } from "./real-weight-inputs";

/** Read a JSON file whose bytes must match the supplied SHA-256 pin. */
export function readPinnedJson<T>(path: string, pin: string, what: string): T {
  assert(isSha256(pin), `${what}: the pin must be a lowercase SHA-256`);
  const bytes = readFileSync(path);
  assert.equal(sha256(bytes), pin, `${what} differs from its pin`);
  return JSON.parse(bytes.toString("utf8")) as T;
}

/** Read a blob whose bytes must match the SHA-256 the reference manifest records for it. */
export function readBlob(directory: string, name: string, pin: string | undefined): Uint8Array {
  assert(pin && isSha256(pin), `${name}: the manifest records no SHA-256`);
  const bytes = new Uint8Array(readFileSync(join(directory, name)));
  assert.equal(sha256(bytes), pin, `${name} differs from the manifest`);
  return bytes;
}

export type Recipe = ({ file: string } | { silence: number })[];

/** A clip's waveform from its recipe; files resolve by base name inside `audioDir`. */
export function buildClip(audioDir: string, recipe: Recipe, decode: (bytes: Uint8Array) => { samples: Float32Array }): Float32Array {
  const parts = recipe.map(step => "silence" in step
    ? new Float32Array(Math.floor(step.silence * 16_000))
    : decode(new Uint8Array(readFileSync(join(audioDir, basename(step.file))))).samples);
  const out = new Float32Array(parts.reduce((n, part) => n + part.length, 0));
  let offset = 0;
  for (const part of parts) { out.set(part, offset); offset += part.length; }
  return out;
}

/** Elements that differ, and the largest absolute difference. */
export function countMismatch(a: ArrayLike<number>, b: ArrayLike<number>): { count: number; maxAbs: number } {
  assert.equal(a.length, b.length, "length differs");
  let count = 0, maxAbs = 0;
  for (let i = 0; i < a.length; i++)
    if (a[i] !== b[i]) { count++; maxAbs = Math.max(maxAbs, Math.abs(a[i]! - b[i]!)); }
  return { count, maxAbs };
}

/** Levenshtein distance over token ids. */
export function tokenDiff(a: number[], b: number[]): number {
  const dp = Array.from({ length: a.length + 1 }, (_, i) => [i, ...new Array<number>(b.length).fill(0)]);
  for (let j = 0; j <= b.length; j++) dp[0]![j] = j;
  for (let i = 1; i <= a.length; i++)
    for (let j = 1; j <= b.length; j++)
      dp[i]![j] = Math.min(dp[i - 1]![j]! + 1, dp[i]![j - 1]! + 1, dp[i - 1]![j - 1]! + (a[i - 1] === b[j - 1] ? 0 : 1));
  return dp[a.length]![b.length]!;
}

/** Float32 values of raw little-endian bytes (copied, so alignment never matters). */
export function float32Of(bytes: Uint8Array): Float32Array {
  return new Float32Array(new Uint8Array(bytes).buffer);
}
