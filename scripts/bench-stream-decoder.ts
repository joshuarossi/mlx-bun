#!/usr/bin/env bun

// Tokenizer-only scaling benchmark for PERF-01. No model weights or server.
// Keeps an in-file full-history oracle so an optimized StreamDecoder can be
// measured against the old algorithm with exact per-push chunk parity.

import { mkdirSync } from "node:fs";
import { dirname } from "node:path";
import { StreamDecoder } from "../src/server";
import { loadTokenizer, type LoadedTokenizer } from "../src/tokenizer";

class FullHistoryDecoder {
  #ids: number[] = [];
  #emitted = "";
  #warnedRevision = false;
  readonly #trimLeadingSpace: boolean;
  readonly #bareSpaceId: number | undefined;

  constructor(
    readonly tokenizer: LoadedTokenizer,
    readonly skipSpecialTokens = true,
  ) {
    this.#trimLeadingSpace = tokenizer.trimsLeadingSpace === true;
    this.#bareSpaceId = tokenizer.bareSpaceTokenId;
  }

  #decode(ids: number[]): string {
    const full = this.tokenizer.decode(ids, this.skipSpecialTokens);
    return this.#trimLeadingSpace && full.startsWith(" ") ? full.slice(1) : full;
  }

  push(token: number): string {
    this.#ids.push(token);
    if (token === this.#bareSpaceId) return "";
    const full = this.#decode(this.#ids);
    const stable = full.endsWith("�") ? full.slice(0, -1) : full;
    if (!stable.startsWith(this.#emitted)) {
      if (!this.#warnedRevision) this.#warnedRevision = true;
      if (stable.length <= this.#emitted.length) return "";
      const out = stable.slice(this.#emitted.length);
      this.#emitted = stable;
      return out;
    }
    const delta = stable.slice(this.#emitted.length);
    this.#emitted = stable;
    return delta;
  }

  flush(): string {
    let ids = this.#ids;
    if (this.#bareSpaceId !== undefined) {
      let n = ids.length;
      while (n > 0 && ids[n - 1] === this.#bareSpaceId) n--;
      if (n < ids.length) ids = ids.slice(0, n);
    }
    const full = this.#decode(ids);
    const delta = full.slice(this.#emitted.length);
    this.#emitted = full;
    return delta;
  }
}

interface RunResult {
  chunks: string[];
  text: string;
}

function run(
  make: () => { push(token: number): string; flush(): string },
  ids: number[],
): RunResult {
  const decoder = make();
  const chunks: string[] = [];
  let text = "";
  for (const id of ids) {
    const chunk = decoder.push(id);
    chunks.push(chunk);
    text += chunk;
  }
  const tail = decoder.flush();
  chunks.push(tail);
  text += tail;
  return { chunks, text };
}

function median(xs: number[]): number {
  const sorted = [...xs].sort((a, b) => a - b);
  const mid = Math.floor(sorted.length / 2);
  return sorted.length % 2 ? sorted[mid]! : (sorted[mid - 1]! + sorted[mid]!) / 2;
}

function percentile(xs: number[], p: number): number {
  const sorted = [...xs].sort((a, b) => a - b);
  return sorted[Math.min(sorted.length - 1, Math.floor((sorted.length - 1) * p))]!;
}

function arg(name: string): string | undefined {
  const i = process.argv.indexOf(name);
  return i >= 0 ? process.argv[i + 1] : undefined;
}

const modelDir = arg("--model");
if (!modelDir) throw new Error("usage: bench-stream-decoder.ts --model <snapshot> [--out <json>]");
const outPath =
  arg("--out") ?? `reports/stream-decoder-${new Date().toISOString().replaceAll(":", "-")}.json`;
const warmups = Number(arg("--warmups") ?? 2);
const repetitions = Number(arg("--repetitions") ?? 7);
const lengths = (arg("--lengths") ?? "64,128,256,512,1024,2048")
  .split(",")
  .map(Number);

const tokenizer = await loadTokenizer(modelDir);
const seedText =
  " The first eight prime numbers are 2, 3, 5, 7, 11, 13, 17, and 19. " +
  "Streaming detokenization must preserve every byte, including punctuation and spaces. ";
let seedIds = tokenizer.encode(seedText.repeat(64), false);
if (seedIds.length === 0) throw new Error("benchmark seed encoded to no tokens");
const maxLength = Math.max(...lengths);
if (seedIds.length < maxLength) {
  const base = seedIds;
  seedIds = Array.from({ length: maxLength }, (_, i) => base[i % base.length]!);
}

const cases: Record<string, unknown>[] = [];
for (const length of lengths) {
  const ids = seedIds.slice(0, length);
  const oracle = run(() => new FullHistoryDecoder(tokenizer), ids);
  const candidate = run(() => new StreamDecoder(tokenizer), ids);
  if (
    oracle.text !== candidate.text ||
    oracle.chunks.length !== candidate.chunks.length ||
    oracle.chunks.some((chunk, i) => chunk !== candidate.chunks[i])
  ) {
    throw new Error(`chunk parity failed at length ${length}`);
  }

  for (let i = 0; i < warmups; i++) {
    run(() => new FullHistoryDecoder(tokenizer), ids);
    run(() => new StreamDecoder(tokenizer), ids);
  }

  const fullHistoryMs: number[] = [];
  const candidateMs: number[] = [];
  for (let i = 0; i < repetitions; i++) {
    // Alternate order to avoid giving either implementation a systematic
    // cache/thermal advantage.
    const order = i % 2 === 0 ? ["oracle", "candidate"] : ["candidate", "oracle"];
    for (const which of order) {
      const start = performance.now();
      run(
        which === "oracle"
          ? () => new FullHistoryDecoder(tokenizer)
          : () => new StreamDecoder(tokenizer),
        ids,
      );
      const elapsed = performance.now() - start;
      (which === "oracle" ? fullHistoryMs : candidateMs).push(elapsed);
    }
  }

  const summary = (samples: number[]) => ({
    samples_ms: samples,
    median_ms: median(samples),
    p25_ms: percentile(samples, 0.25),
    p75_ms: percentile(samples, 0.75),
    ms_per_token: median(samples) / length,
  });
  cases.push({
    length,
    emitted_bytes: new TextEncoder().encode(oracle.text).byteLength,
    chunks: oracle.chunks.length,
    exact_chunk_parity: true,
    full_history: summary(fullHistoryMs),
    candidate: summary(candidateMs),
  });
}

const artifact = {
  benchmark: "PERF-01 StreamDecoder tokenizer-only scaling",
  recorded_at: new Date().toISOString(),
  bun: Bun.version,
  model_dir: modelDir,
  warmups,
  repetitions,
  lengths,
  cases,
};
mkdirSync(dirname(outPath), { recursive: true });
await Bun.write(outPath, JSON.stringify(artifact, null, 2) + "\n");
console.log(outPath);
for (const row of cases as Array<{
  length: number;
  full_history: { median_ms: number; p25_ms: number; p75_ms: number };
  candidate: { median_ms: number; p25_ms: number; p75_ms: number };
}>) {
  console.log(
    `${String(row.length).padStart(5)} tok · full ${row.full_history.median_ms.toFixed(2)} ms ` +
      `[${row.full_history.p25_ms.toFixed(2)}, ${row.full_history.p75_ms.toFixed(2)}] · ` +
      `candidate ${row.candidate.median_ms.toFixed(2)} ms ` +
      `[${row.candidate.p25_ms.toFixed(2)}, ${row.candidate.p75_ms.toFixed(2)}]`,
  );
}
