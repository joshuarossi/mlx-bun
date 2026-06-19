// ORPO training-step micro-benchmark: ms/step + peak GB across memory configs,
// on a synthetic long-response preference example. Lets us see whether a change
// improves or regresses time/memory before committing to it.
//
//   MODEL=/path/to/snapshot SEQ=1024 ITERS=4 bun scripts/bench-orpo.ts
//   (MODEL unset → MiniCPM5-1B-OptiQ-4bit; runs only if that snapshot is cached)
//
// Sweeps: baseline (full head) · chunked head (orpoChunkSize) · segmented
// backward (segmentSize). Each config resets the peak-memory counter and times
// ITERS steps. Numbers are only meaningful on an unloaded machine.

import { mkdtempSync, mkdirSync, writeFileSync, rmSync, existsSync } from "node:fs";
import { tmpdir } from "node:os";
import { join } from "node:path";
import { peakMemory, resetPeakMemory } from "../src/mlx/ffi";
import type { JobEvent } from "../src/jobs/types";

const MODEL = process.env.MODEL ??
  `${process.env.HOME}/.cache/huggingface/hub/models--mlx-community--MiniCPM5-1B-OptiQ-4bit/snapshots/664aabaed233c653f82716d8dc822234d0091f78`;
const SEQ = Number(process.env.SEQ ?? 1024);
const ITERS = Number(process.env.ITERS ?? 4);
const CHUNK = Number(process.env.CHUNK ?? 256);
const SEG = Number(process.env.SEG ?? 4);

if (!existsSync(`${MODEL}/config.json`)) {
  console.error(`model not found: ${MODEL} (set MODEL=...)`);
  process.exit(1);
}

const { loadModelConfig } = await import("../src/config");
const { Weights } = await import("../src/weights");
const { createModel } = await import("../src/model/factory");
const { loadTokenizer } = await import("../src/tokenizer");
const { ChatTemplate } = await import("../src/chat-template");
const { trainLora, DEFAULT_TRAIN_CONFIG } = await import("../src/train/trainer");

// Synthetic long-response preference data (short prompt, long chosen/rejected so
// the response span M ≈ SEQ — this is what stresses the [M, vocab] head term).
const tmp = mkdtempSync(join(tmpdir(), "bench-orpo-"));
const dataDir = join(tmp, "data");
mkdirSync(dataDir, { recursive: true });
const long = "The quick brown fox jumps over the lazy dog. ".repeat(600);
const rows = Array.from({ length: 4 }, () =>
  JSON.stringify({ prompt: "Continue:", chosen: " " + long, rejected: " " + long.toUpperCase() }));
writeFileSync(join(dataDir, "train.jsonl"), rows.join("\n") + "\n");

const config = await loadModelConfig(MODEL);
const weights = await Weights.open(MODEL);
const model = createModel(weights, config);
const tok = await loadTokenizer(MODEL);
const tmpl = await ChatTemplate.load(MODEL);

// ONLY_NEW=1 → sweep just the new-system configs (flash / segmented+flash /
// prefix+flash) — the ones that matter for the e4b 8192 overnight; skips the slow
// full-head baseline that OOMs at long seq. The segmented+flash row IS the overnight
// config shape: tune SEG until "segmented + flash" peak fits your RAM at SEQ=8192.
const onlyNew = process.env.ONLY_NEW === "1";
const legacy = [
  { label: "baseline (full head)", orpoChunkSize: 0, orpoFusedCe: false, orpoFlashCe: false, orpoPrefixShared: false, segmentSize: 0 },
  { label: `chunked head (${CHUNK})`, orpoChunkSize: CHUNK, orpoFusedCe: false, orpoFlashCe: false, orpoPrefixShared: false, segmentSize: 0 },
  { label: `fused linear-CE (${CHUNK})`, orpoChunkSize: CHUNK, orpoFusedCe: true, orpoFlashCe: false, orpoPrefixShared: false, segmentSize: 0 },
  { label: `segmented (${SEG})`, orpoChunkSize: 0, orpoFusedCe: false, orpoFlashCe: false, orpoPrefixShared: false, segmentSize: SEG },
];
const newSystem = [
  { label: `flash head`, orpoChunkSize: CHUNK, orpoFusedCe: true, orpoFlashCe: true, orpoPrefixShared: false, segmentSize: 0 },
  { label: `segmented + flash (${SEG})`, orpoChunkSize: CHUNK, orpoFusedCe: true, orpoFlashCe: true, orpoPrefixShared: false, segmentSize: SEG },
  { label: `prefix + flash`, orpoChunkSize: CHUNK, orpoFusedCe: true, orpoFlashCe: true, orpoPrefixShared: true, segmentSize: 0 },
];
// CONFIG=<substr> runs only configs whose label contains <substr> (e.g.
// CONFIG="segmented + flash" to probe just the overnight config — lowest memory).
const all = onlyNew ? newSystem : [...legacy, ...newSystem];
const configs = process.env.CONFIG ? all.filter((c) => c.label.includes(process.env.CONFIG!)) : all;
if (configs.length === 0) { console.error(`no config matches CONFIG="${process.env.CONFIG}"`); process.exit(1); }

console.log(`\nORPO bench — model=${MODEL.split("/").pop()} SEQ=${SEQ} ITERS=${ITERS}\n`);
console.log(`${"config".padEnd(24)} ${"ms/step".padStart(10)} ${"peak GB".padStart(10)}`);
for (const cfg of configs) {
  resetPeakMemory();
  const losses: number[] = [];
  const t0 = Date.now();
  await trainLora(model, tok, tmpl, dataDir, {
    ...DEFAULT_TRAIN_CONFIG,
    method: "orpo", rank: 8, scale: 2.0, rankScaling: "constant", numLayers: -1,
    iters: ITERS, learningRate: 1e-5, orpoLambda: 0.1, orpoLrSchedule: "constant",
    orpoChunkSize: cfg.orpoChunkSize, orpoFusedCe: cfg.orpoFusedCe,
    orpoFlashCe: cfg.orpoFlashCe, orpoPrefixShared: cfg.orpoPrefixShared, segmentSize: cfg.segmentSize,
    maxSeqLen: SEQ, seed: 0, stepsPerReport: 1, stepsPerEval: 100000,
    adapterPath: join(tmp, `adapter-${cfg.label.replace(/\W/g, "")}`), baseModel: MODEL,
  }, (e: JobEvent) => { if (e.type === "metric" && e.kind === "train") losses.push(e.loss as number); });
  const ms = (Date.now() - t0) / ITERS;
  const peak = peakMemory() / 1e9;
  const finite = losses.length > 0 && losses.every((l) => Number.isFinite(l));
  const lossStr = losses.length ? `${losses[0]!.toFixed(3)}→${losses[losses.length - 1]!.toFixed(3)}${finite ? "" : " NaN!"}` : "n/a";
  console.log(`${cfg.label.padEnd(24)} ${ms.toFixed(0).padStart(10)} ${peak.toFixed(2).padStart(10)}  loss ${lossStr}`);
}

weights.dispose();
rmSync(tmp, { recursive: true, force: true });
