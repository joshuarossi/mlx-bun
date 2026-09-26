// Loopback memory completion client: the one implementation of the memory
// domain's `MemoryCompletionClient`. Every stage call becomes a request to a
// serving mlx-bun's own /v1/chat/completions, so synthesis rides the
// continuous-batching scheduler like any other client — nothing here loads a
// model or owns tensors. Composition roots (`serve`, the `memory` verb) build
// explicit clients; the server creates one signal-bound client per synthesis run.
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
