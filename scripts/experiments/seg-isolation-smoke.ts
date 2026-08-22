// seg-isolation-smoke.ts — the measurement that REFUTED kernel-review backlog
// #2 (planSegments full-attention isolation), 2026-07-02. e4b SFT @8K on the
// two LONGEST real chunk rows (~8.1K tokens), MLX_BUN_SEG_MEM_LOG=1 phase probes.
//
// Measured (M1 Max 32 GB): an isolating planner (each full layer a singleton
// segment) gave ZERO peak win vs uniform seg2 (18.09 vs 18.02 GB) because the
// design §5 premise is false — mlx's sdpa BACKWARD materializes O(L²) scores
// for EVERY layer (~3.5 GB/layer @8K; sliding pair +7.1 GB ≈ sliding+full
// +7.15). Per-segment clearCache also changed nothing (the watermark is live
// memory). The whole knob is segment_size: seg2 = 17.5 GB, seg1 = 14.59 GB
// (+3% step time), step-1 loss identical. The head vjp adds ~3 GB (the [M,V]
// responseOnlyCe — kernel-review backlog #8, the next real lever).
//
//   SEG=2 ITERS=1 bun scripts/experiments/seg-isolation-smoke.ts   # 17.5 GB class
//   SEG=1 ITERS=1 bun scripts/experiments/seg-isolation-smoke.ts   # 14.59 GB
//   SEQ=8192 MLX_BUN_SEG_MEM_LOG=1 for the phase decomposition

import { mkdirSync, readFileSync, writeFileSync, readdirSync } from "node:fs";
import { tmpdir } from "node:os";
import { peakMemory, resetPeakMemory } from "../../src/mlx/ffi";
import { configureRuntime } from "../../src/runtime-config";

// e4b LoRA training standing env (see memory/e4b notes): the perf kernel and
// fused GeGLU are inference-side and must be off for training.
configureRuntime({ MLX_BUN_MEM_LOG: "1" });
// trainer.ts snapshots this diagnostic at module evaluation, so load it only
// after the explicit runtime snapshot above has been installed.
const { finetuneRunner } = await import("../../src/train/job");

const HOME = process.env.HOME!;
const e4bBase = `${HOME}/.cache/huggingface/hub/models--mlx-community--gemma-4-e4b-it-OptiQ-4bit/snapshots`;
const E4B = process.env.MODEL ?? `${e4bBase}/${readdirSync(e4bBase).filter((d) => !d.startsWith("."))[0]}`;
const CHUNK_TRAIN = "/Users/joshrossi/Code/lucien/benchmark/finetune/chunk/train.jsonl";
const SEQ = Number(process.env.SEQ ?? 8192);
const SEG = Number(process.env.SEG ?? 2);
const ITERS = Number(process.env.ITERS ?? 2);
const gb = (b: number): string => (b / 1e9).toFixed(2) + " GB";

// the two longest rows (~8.1K approx tokens each) so the run actually
// exercises the 8K regime, not just the maxSeqLen setting
const lines = readFileSync(CHUNK_TRAIN, "utf8").split("\n").filter(Boolean);
const byLen = lines
  .map((l, i) => ({ i, len: l.length }))
  .sort((a, b) => b.len - a.len)
  .slice(0, 2)
  .map(({ i }) => lines[i]!);

const WORK = `${tmpdir()}/seg-isolation-smoke`;
const dataDir = `${WORK}/data`;
const adapterPath = `${WORK}/adapter-seg${SEG}`;
mkdirSync(dataDir, { recursive: true });
mkdirSync(adapterPath, { recursive: true });
writeFileSync(`${dataDir}/train.jsonl`, byLen.join("\n") + "\n");
writeFileSync(`${dataDir}/valid.jsonl`, byLen[0]! + "\n");

console.log(
  `### seg-isolation-smoke  SEQ=${SEQ} SEG=${SEG} ITERS=${ITERS} rows=${byLen.length} model=${E4B.split("/").at(-1)}`,
);
resetPeakMemory();
const t0 = performance.now();
const stepT: number[] = [];
let lastStep = t0;
await finetuneRunner(
  (ev: Record<string, unknown>) => {
    if (ev.type === "stage") console.log(`  [stage] ${ev.stage} ${ev.message ?? ""}`);
    else if (ev.type === "metric") {
      const now = performance.now();
      stepT.push(now - lastStep);
      lastStep = now;
      console.log(`  [${ev.kind}] step ${ev.step} loss=${ev.loss} peak-so-far=${gb(peakMemory())}`);
    } else if (ev.type === "error") console.log(`  [error] ${ev.message}`);
  },
  {
    model_dir: E4B,
    data_dir: dataDir,
    adapter_path: adapterPath,
    method: "sft",
    rank: 16,
    iters: ITERS,
    max_seq_length: SEQ,
    batch_size: 1,
    segment_size: SEG,
    steps_per_report: 1,
    steps_per_eval: 9999,
  },
);
console.log(
  `### DONE in ${((performance.now() - t0) / 1000).toFixed(1)}s  PEAK=${gb(peakMemory())}  ` +
  `step-times=[${stepT.map((t) => (t / 1000).toFixed(1)).join(", ")}]s`,
);
