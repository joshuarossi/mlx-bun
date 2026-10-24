// The MOSS-Image oracle comparison's measurements, input verification and run
// status, apart from the opt-in test so model-free tests hold them:
// - comparisons count non-finite values as failures (a NaN never passes);
// - input verification hashes the pinned files' bytes, and for the snapshot
//   rejects any file in a directory the loaders read that is not pinned, so a
//   loader can only select verified bytes (an extra index or shard fails the run
//   before anything loads); captures are read by exact name;
// - the run status says when a test stopped before recording its checks, so a
//   results file never reads as a completed comparison it is not.
import { lstatSync, readdirSync, readlinkSync } from "node:fs";
import { basename, join } from "node:path";
import { fileSha256 } from "./real-weight-inputs";

export interface Stats { relative: number; maxAbs: number; minCosine: number; meanCosine: number; nonFinite: number; elements: number; bitMismatches: number }
export interface UlpStats { total: number; mismatches: number; maxUlps: number; nonFinite: number }
export interface Bounds { relative: number; minCosine: number; meanCosine?: number }

/** Relative Frobenius error, max |a - b|, and the cosine of each row over `width` values, over rows [from, to).
 * Bit mismatches compare every selected float32 word, including signed zero; bf16 values are widened exactly
 * by the caller. A non-finite value on either side is counted and makes every distance non-finite. */
export function compare(actual: Float32Array, expected: Float32Array, width: number, from = 0, to = expected.length / width): Stats {
  if (actual.length !== expected.length) throw new RangeError(`compared ${actual.length} values with ${expected.length}`);
  const actualBits = new Uint32Array(actual.buffer, actual.byteOffset, actual.length);
  const expectedBits = new Uint32Array(expected.buffer, expected.byteOffset, expected.length);
  let diff = 0, norm = 0, maxAbs = 0, minCosine = 1, cosines = 0, nonFinite = 0, elements = 0, bitMismatches = 0;
  for (let r = from; r < to; r++) {
    let dot = 0, na = 0, nb = 0;
    for (let i = r * width; i < (r + 1) * width; i++) {
      const a = actual[i]!, b = expected[i]!;
      elements++;
      if (actualBits[i] !== expectedBits[i]) bitMismatches++;
      if (!Number.isFinite(a) || !Number.isFinite(b)) nonFinite++;
      diff += (a - b) ** 2; norm += b * b; maxAbs = Math.max(maxAbs, Math.abs(a - b));
      dot += a * b; na += a * a; nb += b * b;
    }
    const cosine = dot / Math.sqrt(na * nb || 1);
    minCosine = Math.min(minCosine, cosine); cosines += cosine;
  }
  if (nonFinite) return { relative: Number.POSITIVE_INFINITY, maxAbs: Number.POSITIVE_INFINITY, minCosine: Number.NaN, meanCosine: Number.NaN, nonFinite, elements, bitMismatches };
  return { relative: Math.sqrt(diff / norm), maxAbs, minCosine, meanCosine: cosines / (to - from), nonFinite, elements, bitMismatches };
}

/** Compare `[1, C, H, W]` latents by spatial token, with each cosine over C
 * channels. The ordinary contiguous-row comparison measures channels over
 * space instead; historical results retain that separate measurement. */
export function compareSpatial(actual: Float32Array, expected: Float32Array, channels: number): Stats {
  if (!Number.isSafeInteger(channels) || channels <= 0 || expected.length % channels !== 0 || actual.length !== expected.length)
    throw new RangeError("spatial comparison needs equal channel-first tensors and a positive channel count");
  const positions = expected.length / channels;
  const transpose = (values: Float32Array) => {
    const rows = new Float32Array(values.length);
    for (let position = 0; position < positions; position++)
      for (let channel = 0; channel < channels; channel++) rows[position * channels + channel] = values[channel * positions + position]!;
    return rows;
  };
  return compare(transpose(actual), transpose(expected), channels);
}

/** Within `bounds`, with no non-finite value. */
export const meets = (stats: Stats, bounds: Bounds) => stats.nonFinite === 0 && stats.relative <= bounds.relative &&
  stats.minCosine >= bounds.minCosine && (bounds.meanCosine === undefined || stats.meanCosine >= bounds.meanCosine);

const word = new Uint32Array(1), single = new Float32Array(word.buffer);
/** The float32 spacing above |v|. */
export const ulpFloat32 = (v: number) => { single[0] = Math.abs(v); word[0] = word[0]! + 1; return single[0]! - Math.abs(v) || 2 ** -149; };
/** The bf16 spacing above |v| (a bf16 value). */
export const ulpBf16 = (v: number) => { single[0] = Math.abs(v); word[0] = (word[0]! & 0xffff0000) + 0x10000; return single[0]! - Math.abs(v) || 2 ** -133; };

/** How many elements differ, and the largest difference in units of `ulp` at the reference value. A non-finite value on
 * either side is a mismatch at an infinite distance. */
export function ulpDistance(actual: Float32Array, expected: Float32Array, ulp: (v: number) => number): UlpStats {
  if (actual.length !== expected.length) throw new RangeError(`compared ${actual.length} values with ${expected.length}`);
  let mismatches = 0, maxUlps = 0, nonFinite = 0;
  for (let i = 0; i < expected.length; i++) {
    const a = actual[i]!, e = expected[i]!;
    if (!Number.isFinite(a) || !Number.isFinite(e)) { mismatches++; nonFinite++; maxUlps = Number.POSITIVE_INFINITY; continue; }
    const d = Math.abs(a - e);
    if (d > 0) { mismatches++; maxUlps = Math.max(maxUlps, d / ulp(e)); }
  }
  return { total: expected.length, mismatches, maxUlps, nonFinite };
}

export interface Verification {
  /** SHA-256 of each pinned file's bytes. */
  sha256: Record<string, string>;
  /** Pinned files whose bytes differ, with both hashes. */
  mismatched: string[];
  /** Cache symlink target names: a filename claim, recorded and never trusted. */
  provenanceOnly: Record<string, string>;
}

/** Hash every pinned file under `root` (keys relative to it) and compare each with its pin. */
export async function verifyPinned(root: string, pins: Readonly<Record<string, string>>): Promise<Verification> {
  const result: Verification = { sha256: {}, mismatched: [], provenanceOnly: {} };
  for (const [file, expected] of Object.entries(pins)) {
    const path = join(root, file), actual = await fileSha256(path);
    result.sha256[file] = actual;
    if (actual !== expected) result.mismatched.push(`${file}: ${actual}, pinned ${expected}`);
    if (lstatSync(path).isSymbolicLink()) result.provenanceOnly[file] = basename(readlinkSync(path));
  }
  return result;
}

/** Every entry of the directories `pins` names (`dir/file` keys, under `root`) that is not pinned: in a directory a
 * loader reads, such an entry could be selected in place of the pinned bytes (an extra index or shard), so it fails
 * verification. */
export function unpinnedEntries(root: string, pins: Readonly<Record<string, string>>): string[] {
  const directories = new Set(Object.keys(pins).filter(file => file.includes("/")).map(file => file.slice(0, file.lastIndexOf("/"))));
  const unpinned: string[] = [];
  for (const directory of directories)
    for (const entry of readdirSync(join(root, directory)))
      if (!(`${directory}/${entry}` in pins)) unpinned.push(`${directory}/${entry}`);
  return unpinned.sort();
}

/** What a run established: `incomplete` when the inputs were not verified or a test stopped before recording its checks,
 * otherwise whether every asserted check held. */
export function runStatus(run: { inputsVerified: boolean; tests: readonly string[]; completed: ReadonlySet<string>; failures: readonly string[] }) {
  const incomplete = run.tests.filter(test => !run.completed.has(test));
  const status = !run.inputsVerified || incomplete.length ? "incomplete" : run.failures.length ? "checks failed" : "checks passed";
  return { status, inputsVerified: run.inputsVerified, incomplete } as const;
}
