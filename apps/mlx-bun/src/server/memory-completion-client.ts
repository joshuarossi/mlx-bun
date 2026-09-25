// Loopback memory completion client: the one implementation of the memory
// domain's `MemoryCompletionClient`. Every stage call becomes a request to a
// serving mlx-bun's own /v1/chat/completions, so synthesis rides the
// continuous-batching scheduler like any other client — nothing here loads a
// model or owns tensors. Composition roots (`serve`, the `memory` verb) build
// one client and install it with `configureMemoryCompletionClient`.
//
// Main's in-process client decoded greedily on the base model, activating the
// trained `memory-chunk` adapter for the `chunk` stage only. The same policy
// over the wire: temperature 0, the stage's {system?, user} messages rendered
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

  async function request(path: string, init: RequestInit): Promise<Response> {
    http.signal?.throwIfAborted();
    let response: Response;
    try {
      response = await doFetch(`${base()}${path}`, { ...init, signal: http.signal,
        headers: { "Content-Type": "application/json", Authorization: `Bearer ${LOOPBACK_TOKEN}` } });
    } catch (error) {
      if (http.signal?.aborted) throw error;
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
  function adapterFor(stage: string): Promise<string> {
    if (stage !== "chunk") return Promise.resolve("none");
    chunkAdapterMounted ??= (async () => {
      const directory = adapterDirFor("chunk");
      if (!directory) return undefined;
      const listed = (await (await request("/v1/adapters", { method: "GET" })).json()) as { adapters?: { id: string }[] };
      if (!listed.adapters?.some((adapter) => adapter.id === CHUNK_ADAPTER))
        await request("/v1/adapters", { method: "POST", body: JSON.stringify({ id: CHUNK_ADAPTER, path: directory }) });
      return CHUNK_ADAPTER;
    })().catch((error) => { chunkAdapterMounted = undefined; throw error; });
    return chunkAdapterMounted.then((id) => id ?? "none");
  }

  async function complete({ stage, input, maxTokens }: MemoryCompletionRequest): Promise<string> {
    const adapter = await adapterFor(stage);
    const body = { model, messages: memoryMessages(stage, input), max_tokens: maxTokens, temperature: 0, stream: false, adapter };
    const data = (await (await request("/v1/chat/completions", { method: "POST", body: JSON.stringify(body) })).json()) as
      { choices?: { message?: { content?: string | null } }[] };
    return data.choices?.[0]?.message?.content ?? "";
  }

  /** Order-preserving; at most `memoryBatchSize()` requests in flight (default 1:
   *  one after another, main's serial default). */
  async function completeBatch(requests: readonly MemoryCompletionRequest[]): Promise<string[]> {
    const results = new Array<string>(requests.length);
    const width = Math.min(memoryBatchSize(), requests.length || 1);
    let next = 0;
    const worker = async () => {
      while (next < requests.length) {
        const index = next++;
        results[index] = await complete(requests[index]!);
      }
    };
    await Promise.all(Array.from({ length: width }, worker));
    return results;
  }

  return { complete, completeBatch };
}
