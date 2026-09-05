import { existsSync } from "node:fs";
import { loadTaskModel, greedyDecodeBitExact, type TaskModel } from "../../eval/runner";
import type { ChatTemplate } from "../../chat-template";
import { MlxBatchExecutionGroup as BatchScheduler, type RowSampler } from "./batch-group";
import * as ops from "../../mlx/ops";
import type { MlxArray } from "../../mlx/array";
import { adapterDirFor, memoryBatchSize, memoryPromptIds, MODEL_ID,
  type LocalInput, type MemoryCompletionClient } from "../../memory/model";

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


function requireModel(): void {
  if (!existsSync(`${MODEL_ID}/config.json`))
    throw new Error(`memory: Gemma-4-e4b is not downloaded (looked under ${MODEL_ID}). Fetch it first: HF_HUB_DISABLE_XET=1 hf download mlx-community/gemma-4-e4b-it-OptiQ-4bit`);
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
        const { AdapterManager } = await import("../../lora");
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

export const memoryCompletionClient: MemoryCompletionClient = {
  complete: ({ stage, input, maxTokens }) => callLocal(stage, input, { maxTokens }),
  completeBatch(requests) {
    if (!requests.length) return Promise.resolve([]);
    const first = requests[0]!;
    if (requests.some((request) => request.stage !== first.stage || request.maxTokens !== first.maxTokens))
      return (async () => {
        const results: string[] = [];
        for (const request of requests) results.push(await this.complete(request));
        return results;
      })();
    return callLocalBatch(first.stage, requests.map((request) => request.input), { maxTokens: first.maxTokens });
  },
};
