// Calibration data loading for sensitivity analysis.
//
// Port of optiq/calibration/datasets.py `load_llm_calibration` /
// `_load_optiq_calibration`: load a multi-domain JSONL mix, tokenize, build one
// long token stream, and chunk it into fixed-length sequences. The
// `calibrationFn` contract is the TS analogue of OptIQ's
// `list[(args_tuple, kwargs_dict)]`: here, just a list of `number[]` token-id
// prompts (each a (1, seq_len) row the model forwards).
//
// Two deviations from the Python, both forced by our pure-JS tokenizer surface
// (src/tokenizer.ts exposes plain `encode` only, no `apply_chat_template`):
//   - `messages` samples use the role-prefixed dumb-concatenation fallback —
//     exactly OptIQ's `no chat template` branch.
//   - `add_special_tokens=False` is the OptIQ encode flag; our `encode` already
//     omits special tokens for raw substrings.
//
// Source mix: the bundled `optiq.jsonl` if locatable on disk (the oracle venv's
// optiq/calibration/data/optiq.jsonl), else a small built-in fallback corpus so
// the path works with no external data.

import { existsSync } from "node:fs";
import type { LoadedTokenizer } from "../tokenizer";

/** One JSONL calibration sample (subset of the OptIQ schema we can consume). */
interface CalibrationSample {
  domain?: string;
  text?: string;
  messages?: Array<{ role: string; content: string }>;
  tools?: unknown;
}

/** Candidate on-disk locations for the bundled optiq.jsonl mix. */
function bundledMixCandidates(): string[] {
  const home = process.env.HOME ?? "";
  const rel = "lib/python3.14/site-packages/optiq/calibration/data/optiq.jsonl";
  return [
    process.env.MLX_BUN_CALIBRATION_JSONL,
    `${home}/Code/mlx-lm-example/.venv/${rel}`,
    `${home}/Code/mlx-lm/.venv/${rel}`,
  ].filter((p): p is string => !!p);
}

/** A tiny built-in fallback corpus (used only when no JSONL mix is found).
 *  Multi-domain prose so groups have meaningful activation diversity. */
const FALLBACK_CORPUS: string[] = [
  "The history of computing stretches back to mechanical calculators and the abacus. Charles Babbage designed the Analytical Engine, a general-purpose mechanical computer, in the nineteenth century. Ada Lovelace wrote what is often considered the first algorithm intended for such a machine. The theoretical foundations were later laid by Alan Turing, whose model of computation defined the limits of what machines can compute.",
  "In physics, the conservation of energy states that the total energy of an isolated system remains constant over time. Energy can neither be created nor destroyed; rather, it transforms from one form to another. Kinetic energy becomes potential energy as a ball rises, and back again as it falls. Thermodynamics extends these ideas to heat, work, and entropy in large systems.",
  "Functions in programming are reusable blocks of code that perform a specific task. They take inputs, called arguments, and may return a value. Pure functions have no side effects and always return the same output for the same input, which makes them easier to test and reason about. Recursion is a technique where a function calls itself to solve smaller subproblems.",
  "The water cycle describes the continuous movement of water on, above, and below the surface of the Earth. Water evaporates from oceans and lakes, condenses into clouds, and precipitates as rain or snow. Rivers carry water back to the sea, and groundwater slowly percolates through soil and rock. Plants release water vapor through transpiration, contributing to atmospheric moisture.",
  "Economic markets coordinate the production and exchange of goods through prices. When demand for a product rises and supply stays fixed, prices tend to increase, signaling producers to make more. Competition drives firms to lower costs and innovate. Externalities, such as pollution, are costs not reflected in market prices and often require regulation to address.",
  "A neural network is composed of layers of interconnected nodes, each applying a weighted sum followed by a nonlinear activation. During training, the network adjusts its weights to minimize a loss function via gradient descent. Backpropagation efficiently computes gradients by applying the chain rule layer by layer. Deeper networks can represent more complex functions but are harder to train.",
];

/**
 * Build a calibration callable from a tokenizer.
 *
 * @returns a zero-arg function producing `number[][]` — N token-id rows, each
 *          of length `seqLen`, ready to forward through a model.
 */
export function loadLlmCalibration(
  tokenizer: LoadedTokenizer,
  opts: {
    nSamples?: number;
    seqLen?: number;
    seed?: number;
    mix?: string;
  } = {},
): () => number[][] {
  const nSamples = opts.nSamples ?? 32;
  const seqLen = opts.seqLen ?? 1024;
  const seed = opts.seed ?? 42;
  const mix = opts.mix ?? "optiq";

  const samples = loadSamples(mix);

  // Concatenate every sample's tokens into one long stream.
  const allTokens: number[] = [];
  for (const s of samples) {
    let text: string | undefined;
    if (s.messages) {
      // No chat template available in our JS tokenizer — role-prefixed
      // concatenation (OptIQ's no-chat-template fallback branch).
      text = s.messages.map((m) => `[${m.role}]: ${m.content}`).join("\n\n");
    } else if (s.text !== undefined) {
      text = s.text;
    } else {
      continue;
    }
    const toks = tokenizer.encode(text);
    for (const t of toks) allTokens.push(t);
  }

  if (allTokens.length < seqLen) {
    throw new Error(
      `Calibration mix produced only ${allTokens.length} tokens (< seqLen=${seqLen}). ` +
        `Try a smaller seqLen or a larger mix.`,
    );
  }

  // Chunk start offsets, shuffled deterministically (seeded), like OptIQ.
  const starts: number[] = [];
  for (let s = 0; s < allTokens.length - seqLen; s += seqLen) starts.push(s);
  shuffleInPlace(starts, seed);

  const chunks: number[][] = [];
  for (const start of starts.slice(0, nSamples)) {
    chunks.push(allTokens.slice(start, start + seqLen));
  }

  if (chunks.length === 0) {
    throw new Error("Could not create any calibration sequences.");
  }

  return () => chunks;
}

/** Load raw samples from the mix spec ("optiq" → bundled, else a JSONL path,
 *  else the built-in fallback corpus). */
function loadSamples(mix: string): CalibrationSample[] {
  let jsonlPath: string | null = null;
  if (mix === "optiq") {
    jsonlPath = bundledMixCandidates().find((p) => existsSync(p)) ?? null;
  } else if (existsSync(mix)) {
    jsonlPath = mix;
  } else {
    throw new Error(
      `calibration mix not found at ${mix}. Use mix='optiq' (default) or a ` +
        `path to a JSONL file.`,
    );
  }

  if (jsonlPath) return parseJsonl(jsonlPath);

  // Built-in fallback: synthesize one prose sample per corpus entry.
  return FALLBACK_CORPUS.map((text) => ({ domain: "prose", text }));
}

/** Parse a JSONL file into CalibrationSample[] (one object per non-blank line). */
function parseJsonl(path: string): CalibrationSample[] {
  // Synchronous read so the caller can stay synchronous; the file is small.
  const text = readFileSyncUtf8(path);
  const out: CalibrationSample[] = [];
  for (const line of text.split("\n")) {
    const trimmed = line.trim();
    if (trimmed) out.push(JSON.parse(trimmed) as CalibrationSample);
  }
  return out;
}

function readFileSyncUtf8(path: string): string {
  // Bun's readFileSync via node:fs is available in this runtime.
  // (Kept local so the rest of the module is import-light.)
  const { readFileSync } = require("node:fs") as typeof import("node:fs");
  return readFileSync(path, "utf8");
}

/** Deterministic Fisher–Yates shuffle (mulberry32 PRNG seeded by `seed`).
 *  NOTE: this does NOT reproduce numpy's RandomState shuffle order — it only
 *  needs to be deterministic for our own reproducibility; the exact sample
 *  ordering does not affect the allocator's 1:1 parity (that test feeds
 *  synthetic SensitivityResults directly). */
function shuffleInPlace<T>(arr: T[], seed: number): void {
  const rand = mulberry32(seed >>> 0);
  for (let i = arr.length - 1; i > 0; i--) {
    const j = Math.floor(rand() * (i + 1));
    const tmp = arr[i]!;
    arr[i] = arr[j]!;
    arr[j] = tmp;
  }
}

function mulberry32(a: number): () => number {
  return () => {
    a |= 0;
    a = (a + 0x6d2b79f5) | 0;
    let t = Math.imul(a ^ (a >>> 15), 1 | a);
    t = (t + Math.imul(t ^ (t >>> 7), 61 | t)) ^ t;
    return ((t ^ (t >>> 14)) >>> 0) / 4294967296;
  };
}
