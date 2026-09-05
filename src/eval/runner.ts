import type { GenerateOptions } from "../generate";
// Task-eval runner: load a model and greedily complete prompts through the
// REAL serving path. Unlike the M0 KL (compat forward() + plain caches),
// this drives generate() with the model's kv_config, so generation runs the
// mixed-4/8-bit quantized-KV path the generated class actually serves.

import { homedir } from "node:os";
import { readFileSync } from "node:fs";
import { ChatTemplate } from "../chat-template";
import { loadModelConfig, type ModelConfig } from "../config";
import { runtimeValue } from "../runtime-config";
import {
  openModel,
  type Glm52RuntimeOpenOptions,
  type RuntimeModel,
} from "../model/factory";
import { isGlm52Config } from "../model/support";
import { loadTokenizer, type LoadedTokenizer } from "../tokenizer";
import { resolveModelDir } from "./kl";

export const EVAL_DATA_DIR = runtimeValue("MLX_BUN_EVAL_DATA") ?? `${homedir()}/.cache/mlx-bun/eval-data`;

/** Read a jsonl dataset exported by scripts/oracle/export-datasets.py. */
export function loadJsonl<T = Record<string, unknown>>(name: string): T[] {
  const path = `${EVAL_DATA_DIR}/${name}.jsonl`;
  const out: T[] = [];
  for (const line of readFileSync(path, "utf8").split("\n")) {
    const t = line.trim();
    if (t) out.push(JSON.parse(t) as T);
  }
  return out;
}

/** Deterministic seeded subsample of [0, total): mulberry32 shuffle, sorted. */
export function sampleIndices(total: number, n: number, seed = 42): number[] {
  let s = seed >>> 0;
  const rand = (): number => {
    s = (s + 0x6d2b79f5) | 0;
    let t = Math.imul(s ^ (s >>> 15), 1 | s);
    t = (t + Math.imul(t ^ (t >>> 7), 61 | t)) ^ t;
    return ((t ^ (t >>> 14)) >>> 0) / 4294967296;
  };
  const idx = Array.from({ length: total }, (_, i) => i);
  for (let i = total - 1; i > 0; i--) {
    const j = Math.floor(rand() * (i + 1));
    [idx[i], idx[j]] = [idx[j]!, idx[i]!];
  }
  return idx.slice(0, Math.min(n, total)).sort((a, b) => a - b);
}

/** Sampler keys an eval arm may force across every task (greedy/HLG/curve). */
type SamplerArm = Partial<Pick<GenerateOptions, "temperature" | "topP" | "topK" | "seed" | "hlg" | "curve">>;

export interface TaskModel {
  completionClient?: import("../contracts/completion").CompletionClient<{ body: string; options?: GenOpts }, string>;
  model: RuntimeModel;
  tokenizer: LoadedTokenizer;
  template: ChatTemplate | null;
  config: ModelConfig;
  dir: string;
  /** When set, FORCES this sampler on every generateText call, overriding the
   *  task's own (greedy) default — used to run the whole suite under one sampler
   *  arm (e.g. the v2 curve vs the default chat recipe) for the degradation gate. */
  samplerOverride?: SamplerArm;
  /** Mounted-adapter ids to ACTIVATE on every forward/generate. Mounting an adapter
   *  only stores it on the linears; `loraState.active` is what actually applies it,
   *  and generation resets it to [] after each call. So generateText re-passes this,
   *  and direct-forward tasks (MMLU) re-assert it — else the eval silently runs base. */
  activeAdapters?: string[];
}

export async function loadTaskModel(
  query: string,
  adapterDir?: string,
  runtimeOptions: Glm52RuntimeOpenOptions = {},
): Promise<TaskModel> {
  const dir = resolveModelDir(query);
  const config = await loadModelConfig(dir);
  if (adapterDir && isGlm52Config(config))
    throw new Error("GLM-5.2 does not support LoRA adapters");
  const model = await openModel(dir, runtimeOptions);
  const activeAdapters: string[] = [];
  if (adapterDir) {
    // Mount a trained LoRA adapter so the eval measures base+adapter (e.g. the
    // ORPO-fine-tuned "after" model). NOTE: mount() only STORES the adapter on each
    // linear — it does NOT activate it. Activation is `loraState.active`; without
    // setting it the forward runs BASE (bit-identical to no-adapter). So activate it
    // here for direct-forward tasks; generateText re-passes `activeAdapters` too.
    const { AdapterManager } = await import("../lora");
    await new AdapterManager(model).mount("eval-adapter", adapterDir);
    activeAdapters.push("eval-adapter");
    model.loraState.active = [...activeAdapters];
  }
  const tokenizer = await loadTokenizer(dir);
  let template: ChatTemplate | null = null;
  try { template = await ChatTemplate.load(dir); } catch { template = null; }
  return { model, tokenizer, template, config, dir, activeAdapters: activeAdapters.length ? activeAdapters : undefined };
}

export interface GenOpts {
  maxTokens?: number;
  /** Wrap `body` as a single user turn in the chat template (default true). */
  useChat?: boolean;
  /** Sampling overrides (default greedy). Lets the HLG/diversity evals vary the
   *  sampler — temperature, top-p/k, seed, hlg — while sharing this prompt path. */
  sampler?: Partial<Pick<GenerateOptions, "temperature" | "topP" | "topK" | "seed" | "hlg" | "curve">>;
  /** Chat-template `enable_thinking`. Defaults to OFF for eval parity with optiq
   *  (its capability numbers are non-thinking; e.g. MiniCPM5 IFEval 64.7 is
   *  non-thinking). Set MLX_BUN_EVAL_THINK=1 or pass true to evaluate thinking mode. */
  enableThinking?: boolean;
  /** Explicit KV-quant scheme (cli `generate --l2/--kv-quant`, resolved with
   *  serve's semantics). Overrides the MLX_BUN_EVAL_KV_QUANT env default; an empty
   *  object forces bf16. When it names quantized KV, generation runs the product
   *  generate() path (same tokens as `serve` with the same scheme). */
  kvScheme?: Pick<GenerateOptions, "kvBits" | "kvConfig" | "quantizedKvStart" | "turboQuant">;
}

export { greedyDecodeBitExact } from "../backends/mlx/evaluation";
import { createEvalCompletionClient } from "../backends/mlx/evaluation";

/** Application entry point; selection and model math belong to its client. */
export function generateText(tm: TaskModel, body: string, opts: GenOpts = {}): Promise<string> {
  return (tm.completionClient ?? createEvalCompletionClient(tm)).complete({ body, options: opts });
}
