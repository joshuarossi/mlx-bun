// Perplexity over a local text/JSONL dataset — mlx_lm.perplexity methodology.
//
// The reference (mlx_lm/perplexity.py, mlx-lm 0.31.3) does:
//   1. tokenize dataset samples, visit them in a seeded random permutation,
//   2. concatenate tokens into one stream and cut it into NON-OVERLAPPING
//      rows of `sequence_length` (no sliding-window stride, no BOS re-seeding
//      per row), keeping at most `num_samples` rows,
//   3. per batch: logits = model(batch[:, :-1]) in f32, per-token
//      cross-entropy vs batch[:, 1:] — EVERY position counts,
//   4. ppl = exp(mean loss); SE via the delta method:
//      se_ppl = ppl · std(losses, ddof=1) / √N.
//
// We reproduce 2-4 exactly. Step 1 differs only in the data source: the
// reference pulls a Hugging Face dataset (network); we take a LOCAL .txt or
// .jsonl file — never a download. The permutation RNG is a seeded
// deterministic shuffle (not NumPy's), so row selection is reproducible per
// seed but not bit-matched to the Python tool's sampling.
//
// The forward reuses the existing full-sequence machinery
// (src/train/forward.ts trainForward → model.forwardHidden + logitsFromHidden).

import { clearCache, Dtype } from "../mlx/ffi";
import * as ops from "../mlx/ops";
import { trainForward } from "../train/forward";
import type { RuntimeModel } from "../model/factory";

export interface PplDataOptions {
  sequenceLength: number;
  /** Max rows to keep (-1 / 0 = all available). */
  numSamples: number;
  /** Seed for the sample-order shuffle (reference default: 123). */
  seed: number;
}

export interface PplResult {
  ppl: number;
  /** Delta-method standard error of the perplexity. */
  standardError: number;
  meanLoss: number;
  tokens: number;
  rows: number;
}

/** Deterministic PRNG (mulberry32) for the seeded sample shuffle. */
function mulberry32(seed: number): () => number {
  let s = seed >>> 0;
  return () => {
    s = (s + 0x6d2b79f5) >>> 0;
    let t = s;
    t = Math.imul(t ^ (t >>> 15), t | 1);
    t ^= t + Math.imul(t ^ (t >>> 7), t | 61);
    return ((t ^ (t >>> 14)) >>> 0) / 4294967296;
  };
}

/** Split a raw dataset file into text samples: `.jsonl` → one sample per
 *  line from the `text` field; anything else → the whole file is one sample. */
export function parseSamples(raw: string, path: string): string[] {
  if (path.endsWith(".jsonl") || path.endsWith(".ndjson")) {
    const samples: string[] = [];
    for (const [i, line] of raw.split("\n").entries()) {
      if (!line.trim()) continue;
      let row: unknown;
      try {
        row = JSON.parse(line);
      } catch {
        throw new Error(`${path}:${i + 1}: not valid JSON`);
      }
      const text = (row as { text?: unknown }).text;
      if (typeof text !== "string")
        throw new Error(`${path}:${i + 1}: expected a {"text": "..."} row`);
      samples.push(text);
    }
    return samples;
  }
  return raw.length > 0 ? [raw] : [];
}

/** Tokenize samples (seeded shuffle), concatenate, and pack into
 *  non-overlapping rows of `sequenceLength` tokens (reference load_data). */
export function packRows(
  sampleTokens: number[][],
  opts: PplDataOptions,
): Int32Array[] {
  const { sequenceLength: L, numSamples, seed } = opts;
  const order = sampleTokens.map((_, i) => i);
  const rnd = mulberry32(seed);
  for (let i = order.length - 1; i > 0; i--) {
    const j = Math.floor(rnd() * (i + 1));
    [order[i], order[j]] = [order[j]!, order[i]!];
  }

  const wanted = numSamples > 0 ? L * numSamples : Infinity;
  const stream: number[] = [];
  for (const idx of order) {
    if (stream.length >= wanted) break;
    stream.push(...sampleTokens[idx]!);
  }

  const nRows = Math.min(
    Math.floor(stream.length / L),
    numSamples > 0 ? numSamples : Infinity,
  );
  const rows: Int32Array[] = [];
  for (let r = 0; r < nRows; r++)
    rows.push(Int32Array.from(stream.slice(r * L, (r + 1) * L)));
  return rows;
}

/** Evaluate perplexity over packed rows. Per batch (all rows are the same
 *  length, so the stock unpadded forward applies): f32 logits over
 *  batch[:, :-1], per-token CE vs batch[:, 1:], every position counted. */
export function evalPpl(
  model: RuntimeModel,
  rows: Int32Array[],
  batchSize: number,
  onBatch?: (done: number, total: number) => void,
): PplResult {
  const L = rows[0]!.length;
  const allLosses: number[] = [];
  const numBatches = Math.ceil(rows.length / batchSize);

  for (let s = 0, bi = 0; s < rows.length; s += batchSize, bi++) {
    const batch = rows.slice(s, s + batchSize);
    const B = batch.length;
    const inputs: number[] = [];
    const targets: number[] = [];
    for (const row of batch) {
      for (let i = 0; i < L - 1; i++) inputs.push(row[i]!);
      for (let i = 1; i < L; i++) targets.push(row[i]!);
    }
    const ids = ops.fromInt32(inputs, [B, L - 1]);
    const tgt = ops.fromInt32(targets, [B, L - 1, 1]);
    const logits = trainForward(model, ids);
    const f32 = logits.astype(Dtype.float32);
    logits.dispose();
    // CE[t] = logsumexp(logits[t]) − logits[t, target]  (f32, like nn.losses)
    const lse = ops.logsumexpAxis(f32, 2, false); // [B, L-1]
    const picked = ops.takeAlongAxis(f32, tgt, 2); // [B, L-1, 1]
    f32.dispose();
    const picked2d = ops.reshape(picked, [B, L - 1]);
    picked.dispose();
    const losses = ops.sub(lse, picked2d);
    lse.dispose();
    picked2d.dispose();
    const vals = losses.toFloat32();
    losses.dispose();
    ids.dispose();
    tgt.dispose();
    for (const v of vals) allLosses.push(v);
    clearCache();
    onBatch?.(bi + 1, numBatches);
  }

  const n = allLosses.length;
  const mean = allLosses.reduce((a, b) => a + b, 0) / n;
  const ppl = Math.exp(mean);
  // Sample std (ddof=1) → delta-method SE of the perplexity.
  const varSum = allLosses.reduce((a, b) => a + (b - mean) ** 2, 0);
  const std = n > 1 ? Math.sqrt(varSum / (n - 1)) : 0;
  const standardError = ppl * (std / Math.sqrt(n));

  return { ppl, standardError, meanLoss: mean, tokens: n, rows: rows.length };
}
