// Evidence capture for the Lab report: runs the three native engines on the
// on-disk MiniCPM5-1B and records concrete results (no server). Output is
// printed and written to benchmarks/lab-verification.json for the report.
//
//   bun scripts/verify-lab.ts

import { mkdtempSync, rmSync, existsSync, statSync, readdirSync } from "node:fs";
import { tmpdir } from "node:os";
import { join } from "node:path";
import { SNAPSHOT_MINICPM5 } from "../tests/paths";

const out: Record<string, unknown> = { model: "mlx-community/MiniCPM5-1B-OptiQ-4bit" };
const tmp = mkdtempSync(join(tmpdir(), "lab-verify-"));

function dirSizeGB(dir: string): number {
  let bytes = 0;
  for (const f of readdirSync(dir)) {
    try { bytes += statSync(join(dir, f)).size; } catch {}
  }
  return bytes / 1e9;
}

// ---- 1. Dataset builder (non-LLM, no model) -------------------------------
{
  const { generate } = await import("../src/dataset");
  const dir = join(tmp, "dataset");
  const r = await generate(
    "sft_qa_pairs",
    { pairs_text: "Q: What is mlx-bun?\nA: A native MLX runtime for Bun.\n\nQ: Does it need Python?\nA: No.\n\nQ: What chip?\nA: Apple silicon." },
    dir, () => {},
  );
  const sample = (await Bun.file(join(dir, "train.jsonl")).text()).trim().split("\n")[0];
  out.dataset = { n_train: r.n_train, n_valid: r.n_valid, output_dir: dir, sample_row: JSON.parse(sample!) };
  console.log(`[dataset] sft_qa_pairs → train=${r.n_train} valid=${r.n_valid}`);
}

// ---- 2. Native quantization -----------------------------------------------
{
  const { quantizeModelDir } = await import("../src/quantize");
  const dir = join(tmp, "quant");
  const stages: string[] = [];
  const t0 = performance.now();
  const r = await quantizeModelDir(SNAPSHOT_MINICPM5, dir, { bits: 4, groupSize: 64 }, (e) => {
    if (!stages.includes(e.stage)) stages.push(e.stage);
  });
  const secs = (performance.now() - t0) / 1000;
  out.quantize = {
    bits: 4, group_size: 64,
    n_quantized: r.nQuantized, achieved_bpw: Number(r.achievedBpw.toFixed(3)),
    out_size_gb: Number(dirSizeGB(dir).toFixed(3)), seconds: Number(secs.toFixed(1)),
    stages, output_dir: dir,
  };
  console.log(`[quantize] ${r.nQuantized} modules → ${r.achievedBpw.toFixed(2)} bpw, ${dirSizeGB(dir).toFixed(2)} GB in ${secs.toFixed(1)}s`);
}

// ---- 3. Native LoRA training ----------------------------------------------
{
  const { loadModelConfig } = await import("../src/config");
  const { Weights } = await import("../src/weights");
  const { createModel } = await import("../src/model/factory");
  const { loadTokenizer } = await import("../src/tokenizer");
  const { ChatTemplate } = await import("../src/chat-template");
  const { AdapterManager } = await import("../src/lora");
  const { trainLora, DEFAULT_TRAIN_CONFIG } = await import("../src/train/trainer");

  const config = await loadModelConfig(SNAPSHOT_MINICPM5);
  const weights = await Weights.open(SNAPSHOT_MINICPM5);
  const model = createModel(weights, config);
  const tok = await loadTokenizer(SNAPSHOT_MINICPM5);
  const tmpl = await ChatTemplate.load(SNAPSHOT_MINICPM5);

  const adapterDir = join(tmp, "adapter");
  const losses: { step: number; loss: number }[] = [];
  const t0 = performance.now();
  const result = await trainLora(model, tok, tmpl, "fixtures/train/tiny", {
    ...DEFAULT_TRAIN_CONFIG, method: "sft", rank: 8, scale: 2.0, rankScaling: "constant",
    numLayers: -1, iters: 20, learningRate: 1e-3, maxSeqLen: 256,
    stepsPerReport: 1, stepsPerEval: 1000, adapterPath: adapterDir, baseModel: SNAPSHOT_MINICPM5,
  }, (e) => { if (e.type === "metric" && e.kind === "train") losses.push({ step: e.step as number, loss: Number((e.loss as number).toFixed(4)) }); });
  const secs = (performance.now() - t0) / 1000;

  // before / after the adapter on a held-out prompt
  const prompt = tmpl.render([{ role: "user", content: "Tell me about your day." }], { addGenerationPrompt: true });
  const ids = tok.encode(prompt);
  const eos = tok.eosTokenId != null ? [tok.eosTokenId] : [];
  model.loraState.active = [];
  const before = tok.decode(model.generate(ids, 24, eos), true);
  const manager = new AdapterManager(model);
  await manager.mount("trained", adapterDir);
  model.loraState.active = ["trained"];
  const after = tok.decode(model.generate(ids, 24, eos), true);
  model.loraState.active = [];

  out.train = {
    method: "sft", iters: 20, rank: 8, seconds: Number(secs.toFixed(1)),
    loss_first: losses[0]?.loss, loss_last: losses.at(-1)?.loss,
    loss_curve: losses, applied_ranks_count: Object.keys(result.appliedRanks ?? {}).length,
    adapter_mount_layers: manager.get("trained")?.mountedLayers,
    adapter_path: adapterDir, sample_before: before, sample_after: after,
  };
  console.log(`[train] loss ${losses[0]?.loss} → ${losses.at(-1)?.loss} over 20 iters in ${secs.toFixed(1)}s`);
  console.log(`[train] before: ${JSON.stringify(before)}`);
  console.log(`[train] after : ${JSON.stringify(after)}`);
  manager.unmount("trained");
  weights.dispose();
}

await Bun.write("benchmarks/lab-verification.json", JSON.stringify(out, null, 2));
rmSync(tmp, { recursive: true, force: true });
console.log("\nwrote benchmarks/lab-verification.json");
