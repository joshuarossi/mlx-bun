// L1 bit-exact check (mlx-bun side): step-0 masked-CE loss on a fixed batch.
// B=0 / no adapter → loss is the base model's masked CE, init-independent.
// Run with kernels OFF for the L1 (mlx-lm-compat) forward:
//   MLX_BUN_PERF_KERNEL=0 MLX_BUN_FUSED_GELU=0 bun scripts/verify-loss-parity.ts
// then: .venv/bin/python scripts/verify-loss-parity.py  (reads the same ids)

import { writeFileSync } from "node:fs";
import { loadModelConfig } from "../src/config";
import { Weights } from "../src/weights";
import { createModel } from "../src/model/factory";
import { sftLoss } from "../src/train/loss";

const E4B = `${process.env.HOME}/.cache/huggingface/hub/models--mlx-community--gemma-4-e4b-it-OptiQ-4bit/snapshots/fcdb12d740cd813634064567fc7cb51159b34253`;

// Deterministic fixed batch: 64 tokens, prompt boundary at 40 (24 supervised).
const L = 64;
const promptLen = 40;
const ids = Array.from({ length: L }, (_, i) => ((i * 1009 + 17) % 30000) + 1);
writeFileSync("/tmp/ft-verify-ids.json", JSON.stringify({ ids, promptLen }));

const config = await loadModelConfig(E4B);
const weights = await Weights.open(E4B);
const model = createModel(weights, config);

const batch = { ids: [ids], promptLens: [promptLen], lengths: [L] };
const loss = sftLoss(model, batch);
console.log(`mlx-bun sftLoss (responseOnly, B=1): ${loss.toFloat32()[0]!.toPrecision(10)}`);
loss.dispose();
weights.dispose();
