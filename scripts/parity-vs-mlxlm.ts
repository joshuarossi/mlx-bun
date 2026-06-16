// Bit-exact training-loss parity vs mlx-lm: read the fixed tokens + mlx-lm's
// base-model default_loss from /tmp/parity.json (written by
// /tmp/mlxlm-loss-parity.py) and compute OUR sftLoss on the same input.
//   MLX_BUN_PERF_KERNEL=0 MLX_BUN_FUSED_GELU=0 bun scripts/parity-vs-mlxlm.ts

import { readFileSync } from "node:fs";
import { readdirSync } from "node:fs";
import { loadModelConfig } from "../src/config";
import { Weights } from "../src/weights";
import { createModel } from "../src/model/factory";
import { sftLoss } from "../src/train/loss";
import type { SftBatch } from "../src/train/dataset";

const HOME = process.env.HOME!;
const base = `${HOME}/.cache/huggingface/hub/models--mlx-community--gemma-4-e4b-it-OptiQ-4bit/snapshots`;
const MODEL = process.env.MODEL ?? `${base}/${readdirSync(base)[0]}`;

const { ids, promptLen, len, loss: mlxLoss, ntoks } = JSON.parse(readFileSync("/tmp/parity.json", "utf8"));
console.log(`### parity-vs-mlxlm  L=${len} promptLen=${promptLen} ntoks=${ntoks}`);

const config = await loadModelConfig(MODEL);
const weights = await Weights.open(MODEL);
const model = createModel(weights, config);

const batch: SftBatch = { ids: [ids], promptLens: [promptLen] };
const l = sftLoss(model, batch); // base model, no LoRA — same as mlx-lm default_loss(base)
l.eval();
const ours = l.toFloat32()[0]!;
l.dispose();
weights.dispose();

const absDiff = Math.abs(ours - mlxLoss);
console.log(`### ours   base loss @${len} = ${ours.toFixed(8)}`);
console.log(`### mlx-lm base loss @${len} = ${mlxLoss.toFixed(8)}`);
console.log(`### abs diff = ${absDiff.toExponential(3)}  rel = ${(absDiff / Math.abs(mlxLoss) * 100).toFixed(6)}%`);
// bf16 ulp at ~15.6 is ~0.06; bit-exact is abs diff 0; sub-ulp is < ~0.06.
console.log(`### ${absDiff === 0 ? "BIT-EXACT" : absDiff < 0.06 ? "sub-ulp (bf16-exact forward)" : "DIVERGES"}`);
