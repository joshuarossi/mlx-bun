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
import { loadTaskModel, greedyDecodeBitExact, type TaskModel } from "../eval/runner";
import type { ChatMessage, ChatTemplate } from "../chat-template";
import type { LoadedTokenizer } from "../tokenizer";
import { BatchScheduler, type RowSampler } from "../serve/batch-scheduler";
import * as ops from "../mlx/ops";
import type { MlxArray } from "../mlx/array";

const HF_HUB = `${process.env.HOME}/.cache/huggingface/hub`;
const E4B_REPO = "models--mlx-community--gemma-4-e4b-it-OptiQ-4bit";

/** Resolve the e4b snapshot dir by globbing snapshots/ for the one carrying
 *  config.json — so a freshly-downloaded model needs no hardcoded commit hash.
 *  Returns an _unresolved sentinel (precheck → STOP) until the download lands.
 *  Mirrors tests/paths.ts hfSnapshot / SNAPSHOT_E4B, inlined to keep src self-
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
class AsyncMutex {
  #tail: Promise<void> = Promise.resolve();
  acquire(): Promise<() => void> {
    let release!: () => void;
    const gate = new Promise<void>((r) => { release = r; });
    const wait = this.#tail;
    this.#tail = this.#tail.then(() => gate);
    return wait.then(() => release);
  }
}

interface MemoryRuntime {
  tm: TaskModel;
  template: ChatTemplate;
  scheduler: BatchScheduler;
  /** True once the `memory-chunk` adapter is mounted on the shared model. */
  hasChunkAdapter: boolean;
}

/** Max rows in a memory batch (continuous-batching width). 1 disables batching
 *  (callLocalBatch then loops on the bit-exact greedy fallback).
 *  Default 1 (serial): batching measured 1.7-1.9x SLOWER for the real
 *  extract/chunk workload (heterogeneous prefills pad) and can diverge on
 *  near-ties — see docs/design/memory-inference-path.md "Verification results".
 *  Opt back in with MLX_BUN_MEMORY_BATCH=8 if a length-bucketed scheduler
 *  lands. (Decision: Josh, 2026-07-01.) */
export function memoryBatchSize(): number {
  const n = Number(process.env.MLX_BUN_MEMORY_BATCH ?? "1");
  return Number.isFinite(n) && n >= 1 ? Math.floor(n) : 1;
}

function requireModel(): void {
  if (!existsSync(`${MODEL_ID}/config.json`)) {
    throw new Error(
      `memory: Gemma-4-e4b is not downloaded (looked under ${HF_HUB}/${E4B_REPO}/snapshots). ` +
        `Fetch it first:\n  HF_HUB_DISABLE_XET=1 hf download mlx-community/gemma-4-e4b-it-OptiQ-4bit`,
    );
  }
}

let runtimePromise: Promise<MemoryRuntime> | null = null;
const opLock = new AsyncMutex(); // serializes whole memory ops (loraState ownership)
const schedLock = new AsyncMutex(); // the scheduler's exclusive-GPU lock

/** Lazily load the ONE shared model + mount memory-chunk + build the scheduler.
 *  Never auto-downloads; throws (with the fetch hint) until the snapshot lands. */
async function getRuntime(): Promise<MemoryRuntime> {
  if (!runtimePromise) {
    runtimePromise = (async () => {
      requireModel();
      const tm = await loadTaskModel(MODEL_ID); // base e4b, no adapter
      if (!tm.template) throw new Error(`memory: ${MODEL_ID} has no chat template`);
      let hasChunkAdapter = false;
      const chunkDir = adapterDirFor("chunk");
      if (chunkDir) {
        // Mount ONCE; activation is per-call via loraState.active (see decodeGreedy
        // / batchDecode). Mounting alone runs base — it must be activated.
        const { AdapterManager } = await import("../lora");
        await new AdapterManager(tm.model).mount("memory-chunk", chunkDir);
        hasChunkAdapter = true;
      }
      const scheduler = new BatchScheduler(tm.model, {
        maxBatch: memoryBatchSize(),
        lock: { acquire: () => schedLock.acquire() },
      });
      return { tm, template: tm.template, scheduler, hasChunkAdapter };
    })();
  }
  return runtimePromise;
}

/** The adapters to activate for a stage. Only `chunk` is adapter-bound (and only
 *  when `memory-chunk` is mounted); every base stage runs with `active = []`. */
function activeFor(stage: string, rt: MemoryRuntime): string[] {
  return stage === "chunk" && rt.hasChunkAdapter ? ["memory-chunk"] : [];
}

/** One bit-exact greedy decode for a stage (raw-forward argmax, runner parity).
 *  Sets the stage's adapter for the call and resets `active` to [] after. */
function decodeGreedy(rt: MemoryRuntime, stage: string, input: LocalInput, maxTokens: number): string {
  const active = activeFor(stage, rt);
  rt.tm.model.loraState.active = active;
  const ids = memoryPromptIds(stage, input, rt.tm.tokenizer, rt.template);
  try {
    return greedyDecodeBitExact(
      { ...rt.tm, activeAdapters: active.length ? active : undefined },
      ids,
      maxTokens,
    );
  } finally {
    rt.tm.model.loraState.active = [];
  }
}

/** Batched decode for N independent inputs of ONE stage. Sets the stage adapter
 *  globally for the whole batch (the scheduler reads `loraState.active` per
 *  forward, so all rows get it uniformly — a batch is necessarily single-adapter),
 *  submits every row to the shared scheduler with a greedy per-row sampler, and
 *  resets `active` after all rows finish. Order-preserving: out[i] ↔ inputs[i].
 *
 *  Decode-path caveat: this samples via forwardHidden/logitsFromHidden (the
 *  scheduler), which can diverge from the runner's raw-forward greedy on near-ties
 *  past ~32 tokens. For the JSON/binary memory stages (validated by
 *  well-formedness) this is acceptable; the single-call fallback stays bit-exact. */
async function batchDecode(
  rt: MemoryRuntime,
  stage: string,
  inputs: LocalInput[],
  maxTokens: number,
): Promise<string[]> {
  const active = activeFor(stage, rt);
  rt.tm.model.loraState.active = active;
  const eos = rt.tm.config.eosTokenIds;
  const greedySample: RowSampler = (logits1V: MlxArray) => ops.argmaxAxis(logits1V, -1);
  try {
    return await Promise.all(
      inputs.map((inp) => {
        const ids = memoryPromptIds(stage, inp, rt.tm.tokenizer, rt.template);
        const toks: number[] = [];
        return rt.scheduler
          .submit({
            promptIds: ids,
            maxTokens,
            eosTokenIds: eos,
            sample: greedySample,
            onToken: (t) => { toks.push(t); },
          })
          .then(() => rt.tm.tokenizer.decode(toks, true));
      }),
    );
  } finally {
    rt.tm.model.loraState.active = [];
  }
}

// ---------------------------------------------------------------------------
// Public seams
// ---------------------------------------------------------------------------

/** Call the local model for a pipeline `stage` with a {system?, user} input.
 *  Renders through the shared chat-template path, runs the MODEL precheck, and
 *  decodes ONE completion on the bit-exact greedy path (the safe fallback used by
 *  every single-call site). NEVER auto-downloads. */
export async function callLocal(
  stage: string,
  input: LocalInput,
  opts?: { maxTokens?: number },
): Promise<string> {
  const rt = await getRuntime();
  const release = await opLock.acquire();
  try {
    return decodeGreedy(rt, stage, input, opts?.maxTokens ?? 256);
  } finally {
    release();
  }
}

/** N independent calls for ONE stage (homogeneous adapter by construction).
 *  Routed through the shared in-process BatchScheduler when batch>1 AND N>1, else
 *  looped on the bit-exact greedy fallback. Order-preserving: out[i] ↔ inputs[i]. */
export async function callLocalBatch(
  stage: string,
  inputs: LocalInput[],
  opts?: { maxTokens?: number },
): Promise<string[]> {
  if (inputs.length === 0) return [];
  const rt = await getRuntime();
  const maxTokens = opts?.maxTokens ?? 256;
  const release = await opLock.acquire();
  try {
    if (inputs.length === 1 || memoryBatchSize() <= 1) {
      const out: string[] = [];
      for (const inp of inputs) out.push(decodeGreedy(rt, stage, inp, maxTokens));
      return out;
    }
    return await batchDecode(rt, stage, inputs, maxTokens);
  } finally {
    release();
  }
}
