// Task-eval runner: load a model and greedily complete prompts through the
// REAL serving path. Unlike the M0 KL (compat forward() + plain caches),
// this drives generate() with the model's kv_config, so generation runs the
// mixed-4/8-bit quantized-KV path the generated class actually serves.

import { homedir } from "node:os";
import { readFileSync } from "node:fs";
import { generate } from "../generate";
import { ChatTemplate } from "../chat-template";
import { loadModelConfig, type ModelConfig } from "../config";
import { Weights } from "../weights";
import { createModel, type RuntimeModel } from "../model/factory";
import { loadTokenizer, type LoadedTokenizer } from "../tokenizer";
import { resolveModelDir } from "./kl";

export const EVAL_DATA_DIR = process.env.MLX_BUN_EVAL_DATA ?? `${homedir()}/.cache/mlx-bun/eval-data`;

/** Read a jsonl dataset exported by scripts/eval/export-datasets.py. */
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

export interface TaskModel {
  model: RuntimeModel;
  tokenizer: LoadedTokenizer;
  template: ChatTemplate | null;
  config: ModelConfig;
  dir: string;
}

export async function loadTaskModel(query: string): Promise<TaskModel> {
  const dir = resolveModelDir(query);
  const config = await loadModelConfig(dir);
  const weights = await Weights.open(dir);
  const model = createModel(weights, config);
  const tokenizer = await loadTokenizer(dir);
  let template: ChatTemplate | null = null;
  try { template = await ChatTemplate.load(dir); } catch { template = null; }
  return { model, tokenizer, template, config, dir };
}

export interface GenOpts {
  maxTokens?: number;
  /** Wrap `body` as a single user turn in the chat template (default true). */
  useChat?: boolean;
}

/** Greedy completion of `body` via the model's real quantized-KV path. */
export async function generateText(tm: TaskModel, body: string, opts: GenOpts = {}): Promise<string> {
  const maxTokens = opts.maxTokens ?? 256;
  const text = opts.useChat !== false && tm.template
    ? tm.template.render([{ role: "user", content: body }], { addGenerationPrompt: true })
    : body;
  const ids = tm.tokenizer.encode(text);

  const kv = tm.config.kvQuant?.length ? tm.config.kvQuant : undefined;
  const gen = generate(tm.model, ids, {
    maxTokens,
    temperature: 0, // greedy — deterministic, same questions both head-to-head arms
    ...(kv ? { kvConfig: kv, quantizedKvStart: 0 } : {}),
  });

  const out: number[] = [];
  for await (const { token } of gen) out.push(token);
  return tm.tokenizer.decode(out, true);
}
