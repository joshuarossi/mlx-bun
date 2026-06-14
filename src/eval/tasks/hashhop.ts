// HashHop — long-context multi-hop key/value retrieval. Port of
// optiq/eval/hashhop.py. The generator (Magic AI's HashHop, codelion's
// `hashhop` package) isn't on PyPI, so we reconstruct MultiHopEval.make_one
// from the documented format: a chain h0=h1, h1=h2, …, h(N-1)='hN' (quoted
// terminal) buried in many distractor assignments, serialized as a shuffled
// dictionary. The model walks N lookups from h0 and reports hN.
//
// This is the long-context guard (≈12k-char dict → ~8–9k tokens): online-
// softmax / mixed-4/8-bit-KV error compounds across hops, so it's where the
// fused-attention kernel (opportunity A) has the most to prove.

import { generateText, type TaskModel } from "../runner";

const INSTR =
  "You will be given a list of hash assignments and a starting hash. " +
  "Walk the chain by repeated key->value lookup until you hit a terminal " +
  "value (written with single quotes, e.g. `KEY = 'VALUE'`). Output ONLY " +
  "the final 16-character hash inside the quotes, with no extra words or " +
  "punctuation.";

const ALPHABET = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz";
const HASH_LEN = 16;

function mulberry32(seed: number): () => number {
  let s = seed >>> 0;
  return () => {
    s = (s + 0x6d2b79f5) | 0;
    let t = Math.imul(s ^ (s >>> 15), 1 | s);
    t = (t + Math.imul(t ^ (t >>> 7), 61 | t)) ^ t;
    return ((t ^ (t >>> 14)) >>> 0) / 4294967296;
  };
}

function randHash(rand: () => number): string {
  let h = "";
  for (let i = 0; i < HASH_LEN; i++) h += ALPHABET[Math.floor(rand() * ALPHABET.length)];
  return h;
}

interface Sample { prompt: string; start: string; expected: string }

/** One multi-hop instance: a length-`hops` chain padded with distractors to
 *  ~`nChars`, lines shuffled. start = h0, expected = h(hops). */
function makeOne(rand: () => number, hops: number, nChars: number): Sample {
  const chain: string[] = [];
  for (let i = 0; i <= hops; i++) chain.push(randHash(rand));
  const lines: string[] = [];
  for (let i = 0; i < hops; i++)
    lines.push(i === hops - 1 ? `${chain[i]} = '${chain[i + 1]}'` : `${chain[i]} = ${chain[i + 1]}`);

  let chars = lines.reduce((a, l) => a + l.length + 1, 0);
  while (chars < nChars) {
    const a = randHash(rand);
    const b = randHash(rand);
    const line = rand() < 0.5 ? `${a} = '${b}'` : `${a} = ${b}`;
    lines.push(line);
    chars += line.length + 1;
  }
  for (let i = lines.length - 1; i > 0; i--) {
    const j = Math.floor(rand() * (i + 1));
    [lines[i], lines[j]] = [lines[j]!, lines[i]!];
  }
  return { prompt: lines.join("\n"), start: chain[0]!, expected: chain[hops]! };
}

function buildPrompt(s: Sample): string {
  return `${INSTR}\n\nDictionary:\n${s.prompt}\n\nStarting hash: ${s.start}\nFinal hash:`;
}

/** First 16-char alphabetic run in the output (port of _extract_pred). */
function extractPred(out: string): string {
  const m = out.match(/[A-Za-z]{16}/);
  return m ? m[0] : out.trim();
}

export interface HashhopResult {
  nTotal: number;
  nCorrect: number;
  accuracy: number; // overall, 0..1
  byHops: Record<number, number>;
}

export async function evaluateHashhop(
  tm: TaskModel,
  opts: { nPerHop?: number; hopsList?: number[]; chars?: number; maxTokens?: number; seed?: number } = {},
): Promise<HashhopResult> {
  const nPerHop = opts.nPerHop ?? 25;
  const hopsList = opts.hopsList ?? [1, 2, 3, 4];
  const chars = opts.chars ?? 12000;
  const maxTokens = opts.maxTokens ?? 32;
  const rand = mulberry32(opts.seed ?? 42);

  const byHops: Record<number, number> = {};
  let total = 0;
  let correct = 0;
  for (const hops of hopsList) {
    let hc = 0;
    for (let k = 0; k < nPerHop; k++) {
      const s = makeOne(rand, hops, chars);
      const out = await generateText(tm, buildPrompt(s), { maxTokens, useChat: true });
      if (extractPred(out) === s.expected) { hc++; correct++; }
      total++;
      process.stderr.write(`\r  hashhop hops=${hops} ${k + 1}/${nPerHop}  acc=${(hc / (k + 1) * 100).toFixed(0)}%`);
    }
    byHops[hops] = nPerHop ? hc / nPerHop : 0;
    process.stderr.write("\n");
  }
  return { nTotal: total, nCorrect: correct, accuracy: total ? correct / total : 0, byHops };
}
