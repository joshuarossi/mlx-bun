// Phase 0 smoke test for fine-tuning e4b on lucien's chunking task.
//
//   bun scripts/ft-chunk-smoke.ts infer            # does e4b emit chunk JSON?
//   bun scripts/ft-chunk-smoke.ts train 8192       # 2-iter LoRA, measure peak mem
//   bun scripts/ft-chunk-smoke.ts train 4096
//
// Goal: prove the inference + LoRA loops work end-to-end on the real chunk
// data BEFORE committing to a long run, and find the peak-memory cost of a
// long-context (8192-token) LoRA step on this 24 GB machine. Nothing here is
// a long-running server — finite scripts only.

import { mkdirSync, readFileSync, writeFileSync, readdirSync, existsSync } from "node:fs";
import { tmpdir } from "node:os";
import { generate } from "../src/generate";
import { loadModelConfig } from "../src/config";
import { Weights } from "../src/weights";
import { createModel } from "../src/model/factory";
import { loadTokenizer } from "../src/tokenizer";
import { ChatTemplate } from "../src/chat-template";
import { peakMemory, resetPeakMemory } from "../src/mlx/ffi";
import { finetuneRunner } from "../src/train/job";

const E4B = `${process.env.HOME}/.cache/huggingface/hub/models--mlx-community--gemma-4-e4b-it-OptiQ-4bit/snapshots/fcdb12d740cd813634064567fc7cb51159b34253`;
const LUCIEN_FT = "/Users/joshrossi/Code/lucien/benchmark/finetune/chunk";
const WORK = `${tmpdir()}/ft-chunk-smoke`;
const gb = (b: number): string => (b / 1e9).toFixed(2) + " GB";

type Msg = { role: string; content: string };
function firstRecords(path: string, n: number): { messages: Msg[] }[] {
  const out: { messages: Msg[] }[] = [];
  for (const line of readFileSync(path, "utf8").split("\n")) {
    const t = line.trim();
    if (!t) continue;
    out.push(JSON.parse(t));
    if (out.length >= n) break;
  }
  return out;
}

async function infer(): Promise<void> {
  console.log(`\n=== INFERENCE SMOKE — e4b on one chunk example ===`);
  const config = await loadModelConfig(E4B);
  const weights = await Weights.open(E4B);
  const model = createModel(weights, config);
  const tok = await loadTokenizer(E4B);
  const tmpl = await ChatTemplate.load(E4B);

  const rec = firstRecords(`${LUCIEN_FT}/valid.jsonl`, 1)[0]!;
  const gold = rec.messages.at(-1)!.content;
  const promptMsgs = rec.messages.filter((m) => m.role !== "assistant");
  const text = tmpl.render(promptMsgs, { addGenerationPrompt: true });
  const ids = tok.encode(text);
  console.log(`prompt: ${promptMsgs.length} msgs, ${ids.length} tokens`);

  const kv = config.kvQuant?.length ? config.kvQuant : undefined;
  resetPeakMemory();
  const t0 = performance.now();
  const gen = generate(model, ids, {
    maxTokens: 512,
    temperature: 0,
    ...(kv ? { kvConfig: kv, quantizedKvStart: 0 } : {}),
  });
  const outTokens: number[] = [];
  for await (const { token } of gen) outTokens.push(token);
  const out = tok.decode(outTokens, true);
  const secs = ((performance.now() - t0) / 1000).toFixed(1);

  let parsed: unknown = null;
  let parseErr = "";
  try { parsed = JSON.parse(out); } catch (e) { parseErr = (e as Error).message; }
  const chunks = (parsed as { chunks?: unknown[] } | null)?.chunks;

  console.log(`generated: ${outTokens.length} tokens in ${secs}s, peak ${gb(peakMemory())}`);
  console.log(`JSON parse: ${parsed ? "OK" : "FAILED — " + parseErr}`);
  console.log(`chunks[]: ${Array.isArray(chunks) ? chunks.length + " chunks" : "absent"}`);
  console.log(`--- model output (first 240 chars):\n${out.slice(0, 240)}`);
  console.log(`--- gold (first 240 chars):\n${gold.slice(0, 240)}`);
  weights.dispose();
}

async function train(seqLen: number): Promise<void> {
  console.log(`\n=== TRAIN SMOKE — 2-iter LoRA SFT @ maxSeqLen=${seqLen} ===`);
  const dataDir = `${WORK}/data`;
  const adapterPath = `${WORK}/adapter-${seqLen}`;
  mkdirSync(dataDir, { recursive: true });
  mkdirSync(adapterPath, { recursive: true });
  if (!existsSync(`${dataDir}/train.jsonl`)) {
    const train3 = firstRecords(`${LUCIEN_FT}/train.jsonl`, 3);
    const valid1 = firstRecords(`${LUCIEN_FT}/valid.jsonl`, 1);
    writeFileSync(`${dataDir}/train.jsonl`, train3.map((r) => JSON.stringify(r)).join("\n") + "\n");
    writeFileSync(`${dataDir}/valid.jsonl`, valid1.map((r) => JSON.stringify(r)).join("\n") + "\n");
    console.log(`wrote ${train3.length} train + ${valid1.length} valid to ${dataDir}`);
  }

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
        model_dir: E4B,
        data_dir: dataDir,
        adapter_path: adapterPath,
        method: "sft",
        rank: 16,
        iters: 2,
        max_seq_length: seqLen,
        batch_size: 1,
        steps_per_report: 1,
        steps_per_eval: 9999, // skip val during the memory probe (full-logits path)
        grad_checkpoint: process.env.GRAD_CKPT === "1",
      },
    );
    const secs = ((performance.now() - t0) / 1000).toFixed(1);
    console.log(`DONE in ${secs}s — peak ${gb(peakMemory())}`);
    console.log(`adapter -> ${(result as { outputPath?: string }).outputPath}`);
    console.log(`adapter files: ${readdirSync(adapterPath).join(", ")}`);
  } catch (e) {
    console.log(`TRAIN FAILED @ seqLen=${seqLen}: ${(e as Error).message}`);
    console.log(`peak before failure: ${gb(peakMemory())}`);
    process.exitCode = 1;
  }
}

// Forward-only probe: isolate whether the long-sequence crash is in the
// forward graph (logits [1,L,V] materialization) vs. the backward pass.
// No autograd, no LoRA — just forwardHidden → logits → eval.
async function fwd(seqLen: number): Promise<void> {
  console.log(`\n=== FORWARD-ONLY PROBE @ L=${seqLen} (no grad, no LoRA) ===`);
  const { trainForward } = await import("../src/train/forward");
  const { MlxArray } = await import("../src/mlx/array");
  const config = await loadModelConfig(E4B);
  const weights = await Weights.open(E4B);
  const model = createModel(weights, config);
  console.log(`vocab=${config.vocabSize} → logits buffer ≈ ${gb(seqLen * config.vocabSize * 4)}`);
  const data = new Int32Array(seqLen).map((_, i) => (i % 1000) + 1);
  const ids = MlxArray.fromInt32(data, [1, seqLen]);
  resetPeakMemory();
  try {
    const logits = trainForward(model, ids);
    logits.eval(); // forces materialization; surfaces MLX error catchably
    console.log(`forward OK — shape [${logits.shape.join(",")}], peak ${gb(peakMemory())}`);
    logits.dispose();
  } catch (e) {
    console.log(`forward FAILED: ${(e as Error).message}`);
  }
  weights.dispose();
}

const mode = process.argv[2];
if (mode === "infer") await infer();
else if (mode === "train") await train(Number(process.argv[3] ?? 8192));
else if (mode === "fwd") await fwd(Number(process.argv[3] ?? 2048));
else { console.error("usage: ft-chunk-smoke.ts infer | train <seqLen> | fwd <seqLen>"); process.exit(2); }
