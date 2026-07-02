// Task-eval runner: load a model and greedily complete prompts through the
// REAL serving path. Unlike the M0 KL (compat forward() + plain caches),
// this drives generate() with the model's kv_config, so generation runs the
// mixed-4/8-bit quantized-KV path the generated class actually serves.

import { homedir } from "node:os";
import { readFileSync } from "node:fs";
import { generate, type GenerateOptions } from "../generate";
import * as ops from "../mlx/ops";
import { ChatTemplate } from "../chat-template";
import { loadModelConfig, type ModelConfig } from "../config";
import { Weights } from "../weights";
import { createModel, type RuntimeModel } from "../model/factory";
import { DiffusionGemmaModel } from "../model/diffusion-gemma";
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

/** Sampler keys an eval arm may force across every task (greedy/HLG/curve). */
type SamplerArm = Partial<Pick<GenerateOptions, "temperature" | "topP" | "topK" | "seed" | "hlg" | "curve">>;

export interface TaskModel {
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

export async function loadTaskModel(query: string, adapterDir?: string): Promise<TaskModel> {
  const dir = resolveModelDir(query);
  const config = await loadModelConfig(dir);
  const weights = await Weights.open(dir);
  const model = createModel(weights, config);
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
  /** Explicit KV-quant scheme (cli `generate --l2/--l3/--kv-quant`, resolved with
   *  serve's semantics). Overrides the MLX_BUN_EVAL_KV_QUANT env default; an empty
   *  object forces bf16. When it names quantized KV, generation runs the product
   *  generate() path (same tokens as `serve` with the same scheme). */
  kvScheme?: Pick<GenerateOptions, "kvBits" | "kvConfig" | "quantizedKvStart">;
}

/** Bit-exact greedy decode: raw `model.forward` + argmax loop, which matches mlx-lm
 *  token-for-token (gen8k: 8000/8000). The product `generate()` decode wrapper
 *  (forwardHidden/logitsFromHidden + pipelined sampler) diverges from the raw forward
 *  on near-ties past ~32 tokens, so the EVAL decodes bit-exactly itself rather than
 *  alter the serving path. Greedy + full-precision KV only. */
export function greedyDecodeBitExact(tm: TaskModel, ids: number[], maxTokens: number): string {
  if (tm.activeAdapters) tm.model.loraState.active = tm.activeAdapters; // apply the mounted adapter
  const cache = tm.model.makeCache();
  try {
    if (ids.length > 1) tm.model.forward(ids.slice(0, -1), cache).dispose(); // prefill
    let last = ids[ids.length - 1]!;
    const eos = new Set(tm.config.eosTokenIds);
    const out: number[] = [];
    for (let i = 0; i < maxTokens; i++) {
      const lg = tm.model.forward([last], cache);
      const am = ops.argmaxAxis(lg, -1); // GPU argmax (mlx-lm greedy: lowest-index tie-break)
      lg.dispose();
      const best = ops.itemUint32(am);
      am.dispose();
      if (eos.has(best)) break; // mlx-lm halts on EOS and excludes it from the output
      out.push(best);
      last = best;
    }
    return tm.tokenizer.decode(out, true);
  } finally {
    for (const c of cache) c.dispose();
  }
}

/** Complete `body` via the model's real quantized-KV path. Greedy by default;
 *  pass `opts.sampler` to drive temperature/HLG/etc. */
export async function generateText(tm: TaskModel, body: string, opts: GenOpts = {}): Promise<string> {
  const maxTokens = opts.maxTokens ?? 256;
  const enableThinking = opts.enableThinking ?? process.env.MLX_BUN_EVAL_THINK === "1";
  const templated = opts.useChat !== false && tm.template !== null;
  const text = templated
    ? tm.template!.render([{ role: "user", content: body }], { addGenerationPrompt: true, enableThinking })
    : body;
  // The chat template ALREADY emits the BOS; encoding it with add_special_tokens on
  // would prepend a SECOND BOS (<s><s>…), corrupting generation. Raw bodies (no
  // template) get the BOS added as normal.
  const ids = tm.tokenizer.encode(text, /* addSpecialTokens */ !templated);

  // optiq's PUBLISHED eval generates with a FULL-PRECISION KV cache — its eval calls
  // plain mlx_lm.generate (kv-quant lives in the serving runtime, not the eval). So
  // for like-for-like parity we default the eval to UNQUANTIZED KV; MMLU's argmax
  // path was already unquantized, which is why it matched while generation didn't.
  // MLX_BUN_EVAL_KV_QUANT=1 generates through the model's quantized KV (serving
  // config); an explicit opts.kvScheme (cli generate's resolved tier route) wins.
  const envKv: GenOpts["kvScheme"] | undefined =
    (process.env.MLX_BUN_EVAL_KV_QUANT === "1" && tm.config.kvQuant?.length)
      ? { kvConfig: tm.config.kvQuant, quantizedKvStart: 0 } : undefined;
  const kvScheme = opts.kvScheme ?? envKv;
  const kvActive = !!(kvScheme && (kvScheme.kvBits || kvScheme.kvConfig?.length));

  // Parity default — greedy + full-precision KV + no sampler arm: decode bit-exactly
  // via the raw forward (matches mlx-lm token-for-token). Sampler arms / kv-quant fall
  // through to the product generate(). DiffusionGemma is non-autoregressive (no AR
  // forward) — always go through generate(), which routes it to the denoising engine.
  const isDiffusion = tm.model instanceof DiffusionGemmaModel;
  if (!isDiffusion && !kvActive && !opts.sampler && !tm.samplerOverride) {
    return greedyDecodeBitExact(tm, ids, maxTokens);
  }
  const gen = generate(tm.model, ids, {
    maxTokens,
    temperature: 0, // greedy default — deterministic head-to-head arms
    adapters: tm.activeAdapters ?? [], // per-request activation of the mounted eval-adapter
    ...(kvActive ? kvScheme : {}),
    ...(opts.sampler ?? {}), // overrides temperature when provided
    ...(tm.samplerOverride ?? {}), // arm override wins over the task's own sampler
  });

  const out: number[] = [];
  for await (const { token } of gen) out.push(token);
  return tm.tokenizer.decode(out, true);
}
