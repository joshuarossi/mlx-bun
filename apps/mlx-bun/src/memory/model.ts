// mlx-bun memory — the model-call seam every synthesis stage drives.
//
// Each stage (chunk / entity / route / section / synthesis / editor) renders a
// {system?, user} message array; a stage that was SFT'd with a system turn (the
// `memory-chunk` chunk adapter) passes its exact trained system so it decodes
// ON-distribution. Stages NEVER re-implement prompt→ids: they pass {system?, user}
// and the client renders it through the SAME chat-template path the server uses.
//
// Two seams, one client:
//   - callLocal(stage, input)        — one completion.
//   - callLocalBatch(stage, inputs)  — N independent completions for ONE stage,
//                                       order-preserving.
//
// Importing this module never loads MLX. The engine is reached only through a
// {@link MemoryCompletionClient} that the app's composition roots (`serve`, the
// `memory` verb) inject: a loopback HTTP client onto a serving mlx-bun, which
// runs the calls on its continuous-batching scheduler. Nothing here talks to a
// model directly; with no client configured the seams throw a clear error.

import { existsSync } from "node:fs";
import { runtimeValue } from "@mlx-bun/inference/runtime/config";

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

/** One rendered chat turn (the OpenAI wire shape the server accepts). */
export interface MemoryChatMessage {
  role: "system" | "user";
  content: string;
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
export function memoryMessages(stage: string, input: LocalInput): MemoryChatMessage[] {
  const system = input.system ?? DEFAULT_STAGE_SYSTEM[stage];
  const msgs: MemoryChatMessage[] = [];
  if (system) msgs.push({ role: "system", content: system });
  msgs.push({ role: "user", content: input.user });
  return msgs;
}

/** The slice of a chat template / tokenizer `memoryPromptIds` needs. */
export interface MemoryTemplate {
  render(messages: MemoryChatMessage[], options: { addGenerationPrompt: true }): string;
}
export interface MemoryTokenizer {
  encode(text: string): number[];
  readonly bosTokenId: number;
}

/** Render a stage input to prompt ids through the model's chat template, exactly
 *  like the server and the trainer's prompt-region render:
 *  render([system?,user], addGenerationPrompt:true) → encode (the template
 *  already emits the BOS) → strip a duplicate leading BOS. Pure w.r.t. the GPU
 *  (tokenizer + template only), so a parity check can call it without a model. */
export function memoryPromptIds(
  stage: string,
  input: LocalInput,
  tokenizer: MemoryTokenizer,
  template: MemoryTemplate,
): number[] {
  const text = template.render(memoryMessages(stage, input), { addGenerationPrompt: true });
  const ids = tokenizer.encode(text); // template emits <bos>; default add_special
  const bos = tokenizer.bosTokenId;
  return ids.length >= 2 && ids[0] === bos && ids[1] === bos ? ids.slice(1) : ids;
}

// ---------------------------------------------------------------------------
// The client seam — implemented by composition, never by this domain
// ---------------------------------------------------------------------------

export interface MemoryCompletionRequest {
  readonly stage: string;
  readonly input: LocalInput;
  readonly maxTokens: number;
}

/** Application-facing calls. The implementation owns tokenization, numerical
 *  method and transport; callers provide request data and consume results. */
export interface MemoryCompletionClient {
  complete(request: MemoryCompletionRequest): Promise<string>;
  /** Results preserve input order; the implementation chooses execution groups. */
  completeBatch(requests: readonly MemoryCompletionRequest[]): Promise<string[]>;
}

/** Max rows in flight for a memory batch. 1 disables batching (callLocalBatch
 *  then runs its rows one after another).
 *  Default 1 (serial): batching measured 1.7-1.9x SLOWER for the real
 *  extract/chunk workload (heterogeneous prefills pad) and can diverge on
 *  near-ties. Opt back in with MLX_BUN_MEMORY_BATCH=8. (Decision: Josh, 2026-07-01.) */
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

let configured: MemoryCompletionClient | undefined;

/** Install the client the stage defaults (`callLocal` / `callLocalBatch`) use for
 *  the rest of the process (or until the returned restore runs). Composition
 *  roots call this once with the loopback client; tests inject fakes. */
export function configureMemoryCompletionClient(client: MemoryCompletionClient | undefined): () => void {
  const previous = configured;
  configured = client;
  return () => { configured = previous; };
}

function requireClient(): MemoryCompletionClient {
  if (!configured)
    throw new Error("memory: no completion client configured — synthesis runs through a serving mlx-bun (start `mlx-bun serve`, then run the memory verb against it)");
  return configured;
}

const defaultCalls = createMemoryCalls({
  async complete(request) { return requireClient().complete(request); },
  async completeBatch(requests) { return requireClient().completeBatch(requests); },
});
export const callLocal = defaultCalls.callLocal;
export const callLocalBatch = defaultCalls.callLocalBatch;
