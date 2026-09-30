// HTTP memory completion clients: the memory domain's `MemoryCompletionClient`
// over a transport, never loading a model or owning tensors (the in-process
// task model is `cli/memory-engine.ts`). Composition roots build explicit
// clients; the server creates one signal-bound client per synthesis run.
//
// - The loopback client: every stage call becomes a request to a serving
//   mlx-bun's own /v1/chat/completions, so synthesis rides the
//   continuous-batching scheduler like any other client (`memory
//   --host`/`--port`).
// - The worker client (the isolated parent): every stage call or batch is
//   one request to the default model worker's private `/admin/memory/complete`,
//   where that worker's memory task model runs it.
//
// Main's in-process client decoded greedily on the base model, activating the
// trained `memory-chunk` adapter for the `chunk` stage only. The same policy
// over the wire: raw greedy sampling (all processors neutral), template defaults
// instead of server thinking overrides, and the stage's {system?, user} messages rendered
// by the server's chat template, `adapter: "memory-chunk"` for chunk calls when
// that adapter directory exists (mounted on first use through /v1/adapters),
// and `adapter: "none"` otherwise so a `serve --adapter` default never leaks
// into synthesis.

import { adapterDirFor, memoryBatchSize, memoryMessages, type MemoryCompletionClient, type MemoryCompletionRequest } from "../memory/model";
import type { WorkerMemoryCall } from "./worker-routes";

export interface MemoryClientHttp { fetch?: typeof fetch; signal?: AbortSignal }

const LOOPBACK_TOKEN = "sk-mlx-bun-local";
const CHUNK_ADAPTER = "memory-chunk";

/** Build a client for the server at `apiUrl` (a thunk: the port is known only
 *  once the listener is bound). `model` is the served model's stable id. */
export function createLoopbackMemoryClient(apiUrl: () => string, http: MemoryClientHttp = {}, model = "local"): MemoryCompletionClient {
  const base = () => apiUrl().replace(/\/+$/, "");
  const doFetch = http.fetch ?? fetch;
  let chunkAdapterMounted: Promise<string | undefined> | undefined;

  async function request(path: string, init: RequestInit, signal = http.signal): Promise<Response> {
    signal?.throwIfAborted();
    let response: Response;
    try {
      response = await doFetch(`${base()}${path}`, { ...init, signal,
        headers: { "Content-Type": "application/json", Authorization: `Bearer ${LOOPBACK_TOKEN}` } });
    } catch (error) {
      if (signal?.aborted) throw signal.reason;
      throw new Error(`memory: no mlx-bun server answered at ${base()} (${error instanceof Error ? error.message : String(error)}) — start \`mlx-bun serve\` first`);
    }
    if (!response.ok) {
      const detail = await response.text().catch(() => "");
      throw new Error(`memory: ${init.method ?? "GET"} ${path} ${response.status}: ${detail.slice(0, 400)}`);
    }
    return response;
  }

  /** The adapter spec for a stage: `memory-chunk` for chunk calls when its
   *  directory exists (mounting it once), else "none" (run base). */
  function adapterFor(stage: string, signal?: AbortSignal): Promise<string> {
    if (stage !== "chunk") return Promise.resolve("none");
    chunkAdapterMounted ??= (async () => {
      const directory = adapterDirFor("chunk");
      if (!directory) return undefined;
      const listed = (await (await request("/v1/adapters", { method: "GET" }, signal)).json()) as { adapters?: { id: string }[] };
      if (!listed.adapters?.some((adapter) => adapter.id === CHUNK_ADAPTER))
        await request("/v1/adapters", { method: "POST", body: JSON.stringify({ id: CHUNK_ADAPTER, path: directory }) }, signal);
      return CHUNK_ADAPTER;
    })().catch((error) => { chunkAdapterMounted = undefined; throw error; });
    return chunkAdapterMounted.then((id) => id ?? "none");
  }

  async function complete({ stage, input, maxTokens }: MemoryCompletionRequest, signal = http.signal): Promise<string> {
    signal?.throwIfAborted();
    const adapter = await adapterFor(stage, signal);
    signal?.throwIfAborted();
    const body = { model, messages: memoryMessages(stage, input), max_tokens: maxTokens, temperature: 0, top_p: 0, top_k: 0, min_p: 0,
      repetition_penalty: 1, presence_penalty: 0, frequency_penalty: 0, logit_bias: {},
      xtc_probability: 0, xtc_threshold: 0, hlg: { enabled: false },
      chat_template_kwargs: { enable_thinking: null }, stream: false, adapter };
    const data = (await (await request("/v1/chat/completions", { method: "POST", body: JSON.stringify(body) }, signal)).json()) as
      { choices?: { message?: { content?: string | null } }[] };
    signal?.throwIfAborted();
    return data.choices?.[0]?.message?.content ?? "";
  }

  /** Order-preserving; at most `memoryBatchSize()` requests in flight (default 1:
   *  one after another, main's serial default). */
  async function completeBatch(requests: readonly MemoryCompletionRequest[]): Promise<string[]> {
    const results = new Array<string>(requests.length);
    const width = Math.min(memoryBatchSize(), requests.length || 1);
    const abort = new AbortController();
    const signal = http.signal ? AbortSignal.any([http.signal, abort.signal]) : abort.signal;
    let next = 0;
    let failure: unknown;
    let failed = false;
    const worker = async () => {
      try {
        while (!signal.aborted && next < requests.length) {
          const index = next++;
          results[index] = await complete(requests[index]!, signal);
        }
        signal.throwIfAborted();
      } catch (error) {
        if (!failed) { failed = true; failure = error; abort.abort(error); }
      }
    };
    await Promise.allSettled(Array.from({ length: width }, worker));
    if (failed) throw failure;
    return results;
  }

  return { complete, completeBatch };
}

/** Where one memory call goes: the worker (its supervisor's socket fetch)
 * and the task model snapshot selected for it, which that worker loads if
 * this call is the one that loads its task model. */
export interface MemoryTarget { worker: { fetch(url: string, init?: RequestInit): Promise<Response> }; snapshot: string }

/** The isolated parent's client for one synthesis run: each `complete` or
 * `completeBatch` is one POST of the rows and the selected snapshot to the
 * private `/admin/memory/complete` of the worker `select` returns (the
 * model worker), answered with the ordered raw outputs. A failed
 * selection fails the call as it is. The worker's task model runs the call
 * under the worker's own execution lease; none is taken here (one
 * would wait on that worker). The run's signal aborts the request, and the
 * worker then aborts and joins every row. A call is never retried: a worker
 * that stops mid-call fails it rather than replay a POST. */
export function createWorkerMemoryClient(select: (signal: AbortSignal) => Promise<MemoryTarget>, signal: AbortSignal): MemoryCompletionClient {
  const send = async (call: Omit<WorkerMemoryCall, "snapshot">): Promise<string[]> => {
    signal.throwIfAborted();
    const { worker, snapshot } = await select(signal);
    const body: WorkerMemoryCall = { call: call.call, snapshot, requests: call.requests };
    let response: Response;
    try {
      response = await worker.fetch("http://engine/admin/memory/complete", { method: "POST",
        headers: { "content-type": "application/json" }, body: JSON.stringify(body), signal });
    } catch (error) {
      if (signal.aborted) throw signal.reason;
      throw new Error(`memory: the model worker did not complete the task model ${body.call} (${error instanceof Error ? error.message : String(error)}); it is not retried`);
    }
    if (!response.ok) {
      const detail = await response.text().catch(() => "");
      let message = detail;
      try {
        const parsed = JSON.parse(detail) as { error?: { message?: unknown } } | null;
        if (typeof parsed?.error?.message === "string") message = parsed.error.message;
      } catch { /* not JSON: the text itself */ }
      throw new Error(`memory: the model worker's task model ${body.call} failed (${response.status}): ${message.slice(0, 400)}`);
    }
    const { outputs } = await response.json() as { outputs?: unknown };
    signal.throwIfAborted();
    if (!Array.isArray(outputs) || outputs.length !== body.requests.length || !outputs.every(output => typeof output === "string"))
      throw new Error(`memory: the model worker's task model ${body.call} answered no ordered outputs`);
    return outputs as string[];
  };
  return {
    complete: async request => (await send({ call: "complete", requests: [request] }))[0]!,
    // An empty batch is answered here, as the task model answers it: without a call.
    completeBatch: async requests => requests.length ? send({ call: "completeBatch", requests: [...requests] }) : [],
  };
}
