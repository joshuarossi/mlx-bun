// mlx-bun memory — local-model call seam for The Dreaming.
//
// ONE base model drives the whole synthesis pipeline: Gemma-4-e4b (the OptiQ
// 4-bit checkpoint). Each stage (chunk / entity / route / section / synthesis /
// editor) renders a {system?, user} message array through the SAME chat-template
// path the server uses (server.ts:977-980), so a stage that was SFT'd with a
// system turn (the `memory-chunk` chunk adapter) decodes ON-distribution — the
// trained `<|turn>system…<turn|>` block is present, not dropped.
//
// Two seams, ONE shared model:
//   - callLocal(stage, input)        — one call, bit-exact greedy (the eval
//                                       runner's raw-forward decode), the safe
//                                       fallback used by every single-call site.
//   - callLocalBatch(stage, inputs)  — N independent calls for ONE stage, routed
//                                       through the in-process continuous-batching
//                                       BatchScheduler when batch>1, else looped on
//                                       the bit-exact greedy path. Order-preserving.
//
// A lazy module-level runtime holds ONE RuntimeModel (via loadTaskModel), the
// `memory-chunk` adapter mounted once, and ONE BatchScheduler — consolidating the
// old per-(stage,adapter) TaskModel instances into a single shared model (reuse
// AND batching in one move). Stages NEVER re-implement prompt→ids; they pass
// {system?, user} and this seam renders+encodes+BOS-dedupes identically to the
// server and to the trainer's prompt-region render (dataset.ts:98-101).

import { existsSync, readdirSync } from "node:fs";
import type { ChatMessage, ChatTemplate } from "../chat-template";
import type { LoadedTokenizer } from "../tokenizer";
import { runtimeValue } from "../runtime-config";

const HF_HUB = `${process.env.HOME}/.cache/huggingface/hub`;
const E4B_REPO = "models--mlx-community--gemma-4-e4b-it-OptiQ-4bit";

/** Resolve the e4b snapshot dir by globbing snapshots/ for the one carrying
 *  config.json — so a freshly-downloaded model needs no hardcoded commit hash.
 *  Returns an _unresolved sentinel (precheck → STOP) until the download lands.
 *  Mirrors tests/support/paths.ts hfSnapshot / SNAPSHOT_E4B, inlined to keep src self-
 *  contained (no src→tests dependency). */
function resolveE4bSnapshot(): string {
  const base = `${HF_HUB}/${E4B_REPO}/snapshots`;
  try {
    for (const snap of readdirSync(base))
      if (existsSync(`${base}/${snap}/config.json`)) return `${base}/${snap}`;
  } catch {
    /* not downloaded yet */
  }
  return `${base}/_unresolved`;
}

export const MODEL_ID = resolveE4bSnapshot();

/** Per-stage adapter dir, or undefined when none is symlinked (run base). Only
 *  the `chunk` stage has a trained adapter on disk today (`memory-chunk`). */
export function adapterDirFor(stage: string): string | undefined {
  const dir = `${process.env.HOME}/.cache/mlx-bun/adapters/memory-${stage}`;
  return existsSync(dir) ? dir : undefined;
}

// ---------------------------------------------------------------------------
// Templating — system vs user per stage
// ---------------------------------------------------------------------------

/** Token budget for EVERY memory model call. A finished answer stops at EOS on
 *  its own; a maxTokens cap can only ever truncate an UNFINISHED answer — there is
 *  no case where capping output improves it (a one-word verdict already stops; a
 *  long section that gets cut is corrupted). This is a single high backstop against
 *  a pathological non-terminating decode, set far above any real output. Never set
 *  a per-call cap below this. */
export const MAX_OUTPUT_TOKENS = 64_000;

/** A stage's model input: a SYSTEM turn (instruction/policy) plus the USER turn
 *  (the content to operate on). `system` is OPTIONAL — when omitted, the stage's
 *  default system (below) is applied; pass it explicitly to override (the chunk
 *  stage passes its EXACT trained system, CHUNK_SYSTEM, so the only trained
 *  adapter decodes byte-for-byte on-distribution). */
export interface LocalInput {
  system?: string;
  user: string;
}

/** Default per-stage SYSTEM turn, applied when `LocalInput.system` is omitted.
 *
 *  The `chunk` stage is intentionally ABSENT here: it supplies its exact trained
 *  system (CHUNK_SYSTEM in chunk.ts) explicitly, the load-bearing correctness fix.
 *  The base-stage systems are a QUALITY split for the instruct model (which honors
 *  a system turn) — there is no trained adapter to match byte-for-byte, so these
 *  are concise directives that reinforce each prompt's existing instructions. */
const DEFAULT_STAGE_SYSTEM: Record<string, string> = {
  entity:
    "You are an entity extractor. Read ONE conversation chunk and list the " +
    "canonical wiki-title names it is about, one per line — nothing else.",
  route: "You answer only 'yes' or 'no'.",
  section:
    "You route a conversation chunk to an article section. Follow the " +
    "instructions in the message and answer concisely with no preamble.",
  synthesis:
    "You are a careful encyclopedia editor. Follow the editorial instructions " +
    "in the message exactly and output only the requested article text.",
  editor:
    "You are a careful encyclopedia section editor. Follow the editorial " +
    "instructions in the message exactly and output only the requested text.",
};

/** Build the {system?, user} message array for a stage — system resolved from the
 *  explicit override, else the stage default (absent ⇒ user-only, today's shape). */
export function memoryMessages(stage: string, input: LocalInput): ChatMessage[] {
  const system = input.system ?? DEFAULT_STAGE_SYSTEM[stage];
  const msgs: ChatMessage[] = [];
  if (system) msgs.push({ role: "system", content: system });
  msgs.push({ role: "user", content: input.user });
  return msgs;
}

/** Render a stage input to prompt ids through the model's chat template, exactly
 *  like the server (server.ts:977-980) and the trainer's prompt-region render
 *  (dataset.ts:98-101): render([system?,user], addGenerationPrompt:true) →
 *  encode (the template already emits the BOS) → strip a duplicate leading BOS.
 *  Pure w.r.t. the GPU (tokenizer + template only), so the parity test can call
 *  it without loading the model. */
export function memoryPromptIds(
  stage: string,
  input: LocalInput,
  tokenizer: LoadedTokenizer,
  template: ChatTemplate,
): number[] {
  const text = template.render(memoryMessages(stage, input), { addGenerationPrompt: true });
  const ids = tokenizer.encode(text); // template emits <bos>; default add_special
  const bos = tokenizer.bosTokenId;
  return ids.length >= 2 && ids[0] === bos && ids[1] === bos ? ids.slice(1) : ids;
}

// ---------------------------------------------------------------------------
// Shared runtime — one model, one adapter mount, one scheduler
// ---------------------------------------------------------------------------

/** Async mutex: acquire() resolves to a release fn; releases run FIFO. Serializes
 *  memory generation ops so the global `loraState.active` is owned exclusively for
 *  one op's lifetime (set for the chunk batch, reset after). */
export interface MemoryCompletionRequest {
  readonly stage: string;
  readonly input: LocalInput;
  readonly maxTokens: number;
}
export type MemoryCompletionClient = import("../contracts/completion").BatchCompletionClient<MemoryCompletionRequest, string>;

/** Max rows in a memory batch (continuous-batching width). 1 disables batching
 *  (callLocalBatch then loops on the bit-exact greedy fallback).
 *  Default 1 (serial): batching measured 1.7-1.9x SLOWER for the real
 *  extract/chunk workload (heterogeneous prefills pad) and can diverge on
 *  near-ties — see docs/design/dreaming-nightly-pipeline.md "Verification results".
 *  Opt back in with MLX_BUN_MEMORY_BATCH=8 if a length-bucketed scheduler
 *  lands. (Decision: Josh, 2026-07-01.) */
export function memoryBatchSize(): number {
  const n = Number(runtimeValue("MLX_BUN_MEMORY_BATCH") ?? "1");
  return Number.isFinite(n) && n >= 1 ? Math.floor(n) : 1;
}


/** One configured client per pipeline. Importing this module does not load MLX. */
export function createMemoryCalls(client: MemoryCompletionClient) {
  return {
    callLocal(stage: string, input: LocalInput, opts?: { maxTokens?: number }): Promise<string> {
      return client.complete({ stage, input, maxTokens: opts?.maxTokens ?? 256 });
    },
    callLocalBatch(stage: string, inputs: LocalInput[], opts?: { maxTokens?: number }): Promise<string[]> {
      if (!inputs.length) return Promise.resolve([]);
      return client.completeBatch(inputs.map((input) => ({ stage, input, maxTokens: opts?.maxTokens ?? 256 })));
    },
  };
}

const defaultCalls = createMemoryCalls({
  async complete(request) {
    const { memoryCompletionClient } = await import("../backends/mlx/memory-client");
    return memoryCompletionClient.complete(request);
  },
  async completeBatch(requests) {
    const { memoryCompletionClient } = await import("../backends/mlx/memory-client");
    return memoryCompletionClient.completeBatch(requests);
  },
});
export const callLocal = defaultCalls.callLocal;
export const callLocalBatch = defaultCalls.callLocalBatch;
