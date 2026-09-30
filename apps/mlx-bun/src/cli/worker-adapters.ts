// A worker's `adapters` operation as the isolated parent reaches it: each call is one POST on the worker's private socket
// (`/admin/adapters`), which runs on the worker's own model under its engine lock (server/worker-routes.ts). Nothing here
// touches native code.
import type { AdapterMergeStats, AdapterOperation, MountedAdapter } from "@mlx-bun/app-core";
import { ModelHostFailure } from "@mlx-bun/app-services/portable";
import type { WorkerAdapterCall } from "../server/worker-routes";

export function workerAdapters(worker: { fetch(url: string, init?: RequestInit): Promise<Response> }): AdapterOperation {
  async function call<T>(body: WorkerAdapterCall, signal: AbortSignal | undefined): Promise<T> {
    let response: Response;
    try {
      response = await worker.fetch("http://engine/admin/adapters", { method: "POST", headers: { "content-type": "application/json" },
        body: JSON.stringify(body), ...(signal ? { signal } : {}) });
    } catch (error) {
      // A worker that is down, restarting or gone under the call is the model host being unavailable, not a refusal of the adapter.
      signal?.throwIfAborted();
      throw new ModelHostFailure("closed", error instanceof Error ? error.message : String(error), { cause: error });
    }
    const text = await response.text();
    let parsed: { error?: { message?: string } } & Record<string, unknown> = {};
    try { parsed = JSON.parse(text) as typeof parsed; } catch { /* answered with something else */ }
    if (!response.ok) throw new Error(parsed.error?.message ?? `the model worker answered ${response.status}`);
    return parsed as T;
  }
  return {
    async list(signal) { return (await call<{ adapters: MountedAdapter[] }>({ op: "list" }, signal)).adapters; },
    async mount(id, path, signal) { return (await call<{ adapter: MountedAdapter }>({ op: "mount", id, path }, signal)).adapter; },
    async unmount(id, signal) { return (await call<{ removed: number }>({ op: "unmount", id }, signal)).removed; },
    async merge(request, signal) {
      return (await call<{ stats: AdapterMergeStats }>({ op: "merge", adapters: [request.adapters[0], request.adapters[1]], output: request.output,
        ...(request.scales ? { scales: [...request.scales] } : {}) }, signal)).stats;
    },
  };
}
