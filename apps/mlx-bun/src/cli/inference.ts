import { existsSync } from "node:fs";
import { basename, join, resolve } from "node:path";
import { Registry } from "@mlx-bun/hub/registry";
import { resolveKvScheme, type KvQuantOverride, type KvScheme } from "@mlx-bun/inference/state/kv-scheme";
import { runtimeValue } from "@mlx-bun/inference/runtime/config";
import type { GenerateOptions } from "@mlx-bun/inference/generation";
import type { LoadedModelContext } from "../engine/model-host";
import type { CompletionEngine } from "../engine/completion";
import type { ModelBinding } from "../engine/model-binding";
import type { GenerationGateway } from "../engine/generation-gateway";
import { planRequest, RequestOwnership } from "../server/request-plan";
import { textPrompt } from "../server/text-prompt";
import type { CommandArgs } from "./args";

type InferenceCommand = "generate" | "embed";
interface SelectedModel { path: string; repoId: string; }
type ModelRegistry = Pick<Registry, "resolve" | "list" | "scan" | "close">;

/** One-shot selection has no starter or background downloads. Generate keeps
 * main's direct registry resolution; embed alone scans an empty cache. */
export async function resolveInferenceModel(command: InferenceCommand, query: string,
  registry: () => ModelRegistry = () => new Registry()): Promise<SelectedModel> {
  if (query && existsSync(join(query, "config.json"))) {
    const path = resolve(query), hf = /models--([^/]+)--([^/]+)\/snapshots\//.exec(path);
    return { path, repoId: hf ? `${hf[1]}/${hf[2]}` : basename(path) };
  }
  const reg = registry();
  try {
    if (command === "generate") return reg.resolve(query);
    if (reg.list().length === 0) await reg.scan();
    if (query) return reg.resolve(query);
    const model = reg.list().find(model => model.modelType === "qwen3");
    if (!model) throw new Error("no embedding model downloaded — try: mlx-bun get mlx-community/Qwen3-Embedding-4B-4bit-DWQ");
    return model;
  } finally { reg.close(); }
}

export interface OneShotEngine {
  context: LoadedModelContext;
  completion: CompletionEngine;
  binding: Pick<ModelBinding, "embed">;
  gateway: Pick<GenerationGateway, "runExclusive">;
  close(): Promise<void>;
}
export interface InferenceDependencies {
  resolve: typeof resolveInferenceModel;
  load(model: SelectedModel, maxTokens?: number): Promise<LoadedModelContext>;
  /** Takes ownership of the context even if construction rejects. */
  engine(context: LoadedModelContext, scheme: KvScheme): Promise<OneShotEngine>;
  write(text: string): void;
  stdin(signal?: AbortSignal): Promise<string>;
  stdinIsTTY(): boolean;
}
const defaults: InferenceDependencies = {
  resolve: resolveInferenceModel,
  async load(model, maxTokens) {
    const { loadContext } = await import("../engine/model-host");
    return loadContext(model.path, model.repoId, { requireChatTemplate: false,
      glm: { enableMtp: false, maxGenerationTokens: maxTokens } });
  },
  async engine(context, scheme) {
    const { createAppEngine } = await import("../engine");
    return createAppEngine(context, { capacity: 1, gateway: { kvScheme: scheme } });
  },
  write: text => { process.stdout.write(text); },
  async stdin(signal) {
    const reader = Bun.stdin.stream().getReader(), decoder = new TextDecoder();
    let text = "";
    const abort = () => { void reader.cancel(signal?.reason).catch(() => {}); };
    signal?.addEventListener("abort", abort, { once: true });
    try {
      signal?.throwIfAborted();
      for (;;) {
        const next = await reader.read(); signal?.throwIfAborted();
        if (next.done) return text + decoder.decode();
        text += decoder.decode(next.value, { stream: true });
      }
    } finally { signal?.removeEventListener("abort", abort); reader.releaseLock(); }
  },
  stdinIsTTY: () => !!process.stdin.isTTY,
};

function option(args: CommandArgs, name: string): string | undefined {
  const value = args.values[name]; return typeof value === "string" ? value : undefined;
}
function numeric(args: CommandArgs, name: string, input: { integer?: boolean; minimum?: number; maximum?: number } = {}): number | undefined {
  const raw = option(args, name);
  if (raw === undefined) return undefined;
  const value = Number(raw);
  if (!raw.trim() || !Number.isFinite(value) || (input.integer && !Number.isSafeInteger(value)) ||
      value < (input.minimum ?? -Infinity) || value > (input.maximum ?? Infinity)) throw new Error(`invalid --${name}: ${raw}`);
  return value;
}

/** App CLI policy: raw generated text, greedy/full-precision defaults, no
 * model-author server sampling defaults or thinking/tool output filtering. */
export function generateOptions(args: CommandArgs): { prompt: string; raw: boolean; options: GenerateOptions; kvQuant: KvQuantOverride } {
  const prompt = option(args, "prompt") ?? args.positionals[1];
  if (!prompt) throw new Error('usage: mlx-bun generate [query] --prompt "…" [--raw] [--max-tokens N]');
  const kv = option(args, "kv-quant");
  if (kv !== undefined && !["off", "config", "4", "8"].includes(kv)) throw new Error("--kv-quant must be off, config, 4, or 8");
  return { prompt, raw: args.values.raw === true,
    kvQuant: kv === "4" || kv === "8" ? Number(kv) : kv as KvQuantOverride,
    options: {
      maxTokens: numeric(args, "max-tokens", { integer: true, minimum: 1 }) ?? 256,
      temperature: numeric(args, "temperature", { minimum: 0 }) ?? numeric(args, "temp", { minimum: 0 }) ?? 0,
      topP: numeric(args, "top-p", { minimum: 0, maximum: 1 }) ?? 0,
      topK: numeric(args, "top-k", { integer: true, minimum: 0 }) ?? 0,
      ...(option(args, "seed") !== undefined ? { seed: numeric(args, "seed", { integer: true })! } : {}),
    },
  };
}

export async function runInference(command: InferenceCommand, args: CommandArgs,
  supplied: Partial<InferenceDependencies> = {}, signal?: AbortSignal): Promise<void> {
  const deps = { ...defaults, ...supplied };
  const generation = command === "generate" ? generateOptions(args) : undefined;
  let texts: string[] = [];
  if (command === "embed") {
    const one = option(args, "text") ?? args.positionals[1];
    texts = one !== undefined ? [one] : !deps.stdinIsTTY()
      ? (await deps.stdin(signal)).split("\n").map(line => line.trim()).filter(Boolean) : [];
    if (!texts.length) throw new Error('usage: mlx-bun embed [query] --text "…" (or pipe text, one per line)');
  }
  signal?.throwIfAborted();
  const model = await deps.resolve(command, args.positionals[0] ?? option(args, "query") ?? "");
  signal?.throwIfAborted();
  const context = await deps.load(model, generation?.options.maxTokens);
  let close: (() => void | Promise<void>) | undefined = () => context.dispose();
  let failure: unknown, failed = false;
  try {
    signal?.throwIfAborted();
    const scheme = resolveKvScheme({ override: generation?.kvQuant ??
      (generation && runtimeValue("MLX_BUN_EVAL_KV_QUANT") === "1" ? "config" : "off"), config: context.kvConfig,
      ...(generation?.kvQuant === undefined && runtimeValue("MLX_BUN_EVAL_KV_QUANT") === "1" ? { quantizedKvStart: 0 } : {}),
    });
    close = undefined; // engine construction owns failure cleanup from here
    const engine = await deps.engine(context, scheme);
    close = () => engine.close();
    signal?.throwIfAborted();
    if (generation) {
      const ids = !generation.raw && context.template
        ? textPrompt(context.template, context.tokenizer, [{ role: "user", content: generation.prompt }],
          { addGenerationPrompt: true, enableThinking: runtimeValue("MLX_BUN_EVAL_THINK") === "1" }, false).ids
        : context.tokenizer.encode(generation.prompt, true);
      const plan = planRequest({ promptIds: ids, options: { ...generation.options, ...scheme.generationOptions, stopSequences: [] },
        requestedMaxTokens: generation.options.maxTokens!, contextLimit: context.glmMemoryPlan?.contextTokens ?? null,
        stream: false, wantLogprobs: false, topLogprobs: 0, adapterIds: [], hasVision: false,
        userSeed: generation.options.seed !== undefined, hasGrammar: false, hasDraft: false, ownership: new RequestOwnership() });
      if (!plan.ok) { plan.dispose(); throw new Error(plan.error.message); }
      const tokens: number[] = [];
      try {
        const placement = engine.completion.place(plan.shape, plan.options);
        plan.transferOwnership();
        await engine.completion.run(plan.promptIds, plan.options, token => { tokens.push(token); }, undefined,
          plan.shape, placement, signal);
        signal?.throwIfAborted();
        const text = context.tokenizer.decode(tokens, true);
        deps.write(text.endsWith("\n") ? text : text + "\n");
      } finally { plan.dispose(); }
    } else {
      const embed = engine.binding.embed?.bind(engine.binding);
      if (!embed) throw new Error(`"${model.repoId}" is not an embedding model (need plain Qwen3, e.g. Qwen3-Embedding).`);
      const results = await engine.gateway.runExclusive(async () => embed(texts, option(args, "instruct")), undefined, signal);
      signal?.throwIfAborted();
      if (args.values.json === true) {
        const total = results.reduce((sum, result) => sum + result.tokens, 0);
        deps.write(JSON.stringify({ object: "list", data: results.map((result, index) => ({ object: "embedding", index,
          embedding: Array.from(result.vector) })), model: model.repoId, usage: { prompt_tokens: total, total_tokens: total } }) + "\n");
      } else for (const result of results) deps.write(JSON.stringify(Array.from(result.vector)) + "\n");
    }
  } catch (error) { failed = true; failure = error; throw error; }
  finally {
    try { await close?.(); }
    catch (error) { if (failed) throw new AggregateError([failure, error], "inference and cleanup failed"); throw error; }
  }
}
