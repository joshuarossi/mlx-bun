// LoRA SFT fine-tune of a small model on lucien's chunking task, via mlx-bun's
// own trainer. Uses the default ops.sdpa training attention (mlx's fused
// kernel — correct gradients; set MLX_BUN_TRAIN_ATTN=flash to override, but
// flash crashes e4b at multi-K). Trains on the full chunk dataset; the adapter
// is loadable by mlx-bun's hot-swap serving and by scripts/chunk-eval.ts
// (ADAPTER=...).
//
//   SEQ=8192 ITERS=2  bun scripts/chunk-finetune.ts     # memory/stability probe
//   SEQ=8192 ITERS=300 bun scripts/chunk-finetune.ts    # real run
//
// MODEL defaults to MiniCPM5-1B-OptiQ-4bit.

import { mkdirSync, readdirSync } from "node:fs";
import { basename } from "node:path";
import { finetuneRunner } from "../src/train/job";
import { peakMemory, resetPeakMemory } from "../src/mlx/ffi";

const HOME = process.env.HOME!;
function resolveModel(): string {
  if (process.env.MODEL) return process.env.MODEL;
  const base = `${HOME}/.cache/huggingface/hub/models--mlx-community--MiniCPM5-1B-OptiQ-4bit/snapshots`;
  return `${base}/${readdirSync(base)[0]}`;
}
const MODEL = resolveModel();
const DATA = process.env.DATA ?? "/Users/joshrossi/Code/lucien/benchmark/finetune/chunk";
const SEQ = Number(process.env.SEQ ?? 8192);
const ITERS = Number(process.env.ITERS ?? 2);
const RANK = Number(process.env.RANK ?? 16);
const LR = Number(process.env.LR ?? 1e-5);
const SCALE = Number(process.env.SCALE ?? 20);
const ADAPTER = process.env.ADAPTER ?? `${HOME}/.cache/mlx-bun-finetunes/minicpm5-chunk-seq${SEQ}`;
const EVAL_EVERY = Number(process.env.EVAL_EVERY ?? (ITERS <= 5 ? 99999 : Math.max(25, Math.floor(ITERS / 6))));
// SEG>0 enables segmented backward (layers per segment). See
// docs/design/segmented-backward-training.md.
const SEG = Number(process.env.SEG ?? 0);

mkdirSync(ADAPTER, { recursive: true });
const gb = (b: number) => `${(b / 1e9).toFixed(2)} GB`;

// Derive a readable model name from the resolved path (HF cache: ".../models--org--repo/snapshots/<hash>").
const MODEL_NAME = MODEL.match(/models--[^/]+--([^/]+)/)?.[1] ?? basename(MODEL);
console.log(`### finetune  model=${MODEL_NAME}  seq=${SEQ} iters=${ITERS} rank=${RANK} lr=${LR}${SEG > 0 ? ` segmentSize=${SEG}` : ""}`);
console.log(`### data=${DATA}`);
console.log(`### adapter=${ADAPTER}`);

resetPeakMemory();
const t0 = performance.now();
try {
  const result = await finetuneRunner(
    (ev: Record<string, unknown>) => {
      if (ev.type === "stage") console.log(`  [stage] ${ev.stage} ${ev.message ?? ""}`);
      else if (ev.type === "metric") console.log(`  [${ev.kind}] step ${ev.step} loss=${ev.loss}`);
      else if (ev.type === "error") console.log(`  [error] ${ev.message}`);
    },
    {
      model_dir: MODEL,
      data_dir: DATA,
      adapter_path: ADAPTER,
      method: "sft",
      rank: RANK,
      scale: SCALE,
      iters: ITERS,
      learning_rate: LR,
      max_seq_length: SEQ,
      batch_size: 1,
      steps_per_report: 1,
      steps_per_eval: EVAL_EVERY,
      segment_size: SEG,
      save_checkpoints: process.env.CKPT !== "0", // keep-all-checkpoints + metrics.json (CKPT=0 to disable)
      grad_checkpoint: process.env.GRAD_CKPT === "1", // the apples-to-apples memory lever
    },
  );
  const secs = ((performance.now() - t0) / 1000).toFixed(1);
  console.log(`### DONE in ${secs}s — peak ${gb(peakMemory())}`);
  console.log(`### adapter -> ${(result as { outputPath?: string }).outputPath}`);
  console.log(`### files: ${readdirSync(ADAPTER).join(", ")}`);
} catch (e) {
  console.log(`### TRAIN FAILED @ seq=${SEQ}: ${(e as Error).message}`);
  console.log(`### peak before failure: ${gb(peakMemory())}`);
  process.exitCode = 1;
}
