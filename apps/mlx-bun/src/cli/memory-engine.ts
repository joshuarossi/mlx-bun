// The `memory` verb's in-process task model: main's `memory synthesize` (and the
// nightly job) loaded its own Gemma-4 e4b on first use instead of needing a
// serving mlx-bun. Nothing loads until a stage actually asks for a completion,
// and every call runs through the app engine's continuous gateway — there is
// no serial lane and no second server. Policy stays here and in memory/model:
// the task model, the chunk adapter only for the chunk stage, greedy argmax
// with the model's EOS and no stop strings, full-precision KV, and the raw
// decoded text main returned.

import { resolveKvScheme, type KvScheme } from "@mlx-bun/inference/state/kv-scheme";
import type { LoadContextOptions, LoadedModelContext } from "../engine/model-host";
import type { CompletionEngine } from "../engine/completion";
import type { GenerationGateway } from "../engine/generation-gateway";
import {
  MEMORY_TASK_MODEL, adapterDirFor, locateTaskModel, memoryBatchSize, memoryPromptIds,
  type MemoryCompletionClient, type MemoryCompletionRequest,
} from "../modules";
import { planRequest, RequestOwnership } from "../server/request-plan";

/** The chunk stage's trained adapter, mounted once under this id when present. */
export const CHUNK_ADAPTER = "memory-chunk";

export interface MemoryEngine {
  context: LoadedModelContext;
  completion: CompletionEngine;
  gateway: Pick<GenerationGateway, "runExclusive">;
  close(): Promise<void>;
}

export interface MemoryEngineDependencies {
  /** The task model's snapshot directory; never downloads. */
  locate(repoId: string): Promise<string>;
  /** `composition`: the batch cap and chunk adapter the loaded composition records. */
  load(path: string, repoId: string, composition?: Pick<LoadContextOptions, "adapters" | "maxRows">): Promise<LoadedModelContext>;
  /** Takes ownership of the context even if construction rejects. */
  engine(context: LoadedModelContext, scheme: KvScheme, capacity: number): Promise<MemoryEngine>;
  adapterDir(stage: string): string | undefined;
}

/** The shipped wiring: the cached task model, the app engine, main's adapter directory. */
export const defaultMemoryEngineDependencies: MemoryEngineDependencies = {
  locate: repoId => locateTaskModel(repoId),
  async load(path, repoId, composition) {
    const { loadContext } = await import("../engine/model-host");
    return loadContext(path, repoId, composition);
  },
  async engine(context, scheme, capacity) {
    const { createAppEngine } = await import("../engine");
    return createAppEngine(context, { capacity, gateway: { kvScheme: scheme } });
  },
  adapterDir: adapterDirFor,
};

interface MemoryRuntime { engine: MemoryEngine; scheme: KvScheme; chunkAdapter: boolean }

/** The task model's client, and a view of it whose every completion ends when a signal aborts. */
export interface InProcessMemoryClient {
  client: MemoryCompletionClient;
  /** `snapshot`: the task model directory the caller selected. A view's call
   * that starts the load loads exactly it instead of locating one; once
   * loaded, the task model stays what it is. */
  clientFor(signal: AbortSignal, snapshot?: string): MemoryCompletionClient;
  close(): Promise<void>;
}

/** A lazily loaded memory client. The first completion loads the task model
 *  once (every caller shares that one initialization); a failed load stays
 *  failed for this client, as in main. `close()` is safe before, during and
 *  after initialization, including after it failed. */
export function createInProcessMemoryClient(deps: MemoryEngineDependencies = defaultMemoryEngineDependencies): InProcessMemoryClient {
  let closed = false, init: Promise<MemoryRuntime> | undefined, closing: Promise<void> | undefined;
  const closedError = () => new Error("memory: the task model client is closed");
  const start = async (snapshot?: string): Promise<MemoryRuntime> => {
    const path = snapshot ?? await deps.locate(MEMORY_TASK_MODEL);
    if (closed) throw closedError();
    const dir = deps.adapterDir("chunk");
    const context = await deps.load(path, MEMORY_TASK_MODEL, { adapters: dir !== undefined, maxRows: memoryBatchSize() });
    if (closed) { context.dispose(); throw closedError(); }
    // Main decoded with a full-precision cache, whatever the artifact's kv_config says.
    const scheme = resolveKvScheme({ override: "off", config: context.kvConfig });
    const engine = await deps.engine(context, scheme, memoryBatchSize());
    try {
      if (closed) throw closedError();
      if (dir) await engine.gateway.runExclusive(async () => { await engine.context.adapters.mount(CHUNK_ADAPTER, dir); });
      if (closed) throw closedError();
      return { engine, scheme, chunkAdapter: dir !== undefined };
    } catch (error) { await engine.close(); throw error; }
  };
  const runtime = (snapshot?: string) => closed ? Promise.reject(closedError()) : (init ??= start(snapshot));

  const run = async (rt: MemoryRuntime, request: MemoryCompletionRequest, signal?: AbortSignal): Promise<string> => {
    const { context, completion } = rt.engine;
    if (!context.template) throw new Error(`memory: ${MEMORY_TASK_MODEL} has no chat template`);
    const tokenizer = context.tokenizer;
    const promptIds = memoryPromptIds(request.stage, request.input,
      { encode: text => tokenizer.encode(text), bosTokenId: tokenizer.bosTokenId ?? -1 }, context.template);
    const plan = planRequest({ promptIds,
      options: { maxTokens: request.maxTokens, temperature: 0, ...rt.scheme.generationOptions, stopSequences: [] },
      requestedMaxTokens: request.maxTokens, contextLimit: context.memoryPlan?.contextTokens ?? null,
      stream: false, wantLogprobs: false, topLogprobs: 0,
      adapterIds: request.stage === "chunk" && rt.chunkAdapter ? [CHUNK_ADAPTER] : [],
      hasVision: false, userSeed: false, hasGrammar: false, hasDraft: false, ownership: new RequestOwnership() });
    if (!plan.ok) { plan.dispose(); throw new Error(plan.error.message); }
    const tokens: number[] = [];
    try {
      const placement = completion.place(plan.shape, plan.options);
      plan.transferOwnership();
      await completion.run(plan.promptIds, plan.options, token => { tokens.push(token); }, undefined, plan.shape, placement, signal);
      signal?.throwIfAborted();
      return tokenizer.decode(tokens, true);
    } finally { plan.dispose(); }
  };

  const clientFor = (outer?: AbortSignal, snapshot?: string): MemoryCompletionClient => ({
    async complete(request) {
      // Cancelled work never starts the shared load; a load another caller started continues.
      outer?.throwIfAborted();
      const rt = await runtime(snapshot);
      outer?.throwIfAborted();
      return run(rt, request, outer);
    },
    async completeBatch(requests) {
      if (!requests.length) return [];
      outer?.throwIfAborted();
      const rt = await runtime(snapshot);
      outer?.throwIfAborted();
      const first = requests[0]!;
      // Main's rule: a mixed-stage or mixed-budget batch runs its rows one after another.
      if (memoryBatchSize() <= 1 || requests.length === 1 ||
        !requests.every(request => request.stage === first.stage && request.maxTokens === first.maxTokens)) {
        const results: string[] = [];
        for (const request of requests) results.push(await run(rt, request, outer));
        return results;
      }
      // Bounded producers, as main's scheduler and the loopback client: at most
      // the batch width of rows in flight, results in input order. One row's
      // failure cancels its siblings and stops new rows; every started row
      // settles before the batch rejects.
      const abort = new AbortController(), signal = outer ? AbortSignal.any([outer, abort.signal]) : abort.signal;
      const results = new Array<string>(requests.length);
      let next = 0, failure: { error: unknown } | undefined;
      const producer = async () => {
        while (!failure && next < requests.length) {
          const index = next++;
          try { results[index] = await run(rt, requests[index]!, signal); }
          catch (error) { failure ??= { error }; abort.abort(error); }
        }
      };
      await Promise.all(Array.from({ length: Math.min(memoryBatchSize(), requests.length) }, producer));
      if (failure) throw failure.error;
      return results;
    },
  });
  return {
    client: clientFor(),
    clientFor,
    close() {
      closed = true;
      return closing ??= (async () => {
        const rt = await init?.catch(() => undefined);
        await rt?.engine.close();
      })();
    },
  };
}
