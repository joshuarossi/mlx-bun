import type { TaskCompletionClient as MemoryCompletionClient } from "@mlx-bun/app-core";
import type { WorkerMemoryCall } from "./worker-routes";
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
