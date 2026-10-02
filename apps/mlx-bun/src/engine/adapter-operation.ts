// The `adapters` operation of a loaded model: mounting, unmounting and merging LoRA adapters on its own weights, each
// under the engine's execution lock. This is where the numerical work happens (native MLX), so it runs in the process
// that holds the model; a host that isolates its models reaches it through the worker's private route.
import type { AdapterMergeStats, AdapterOperation, MountedAdapter } from "@mlx-bun/app-core";
import type { AdapterInfo } from "@mlx-bun/inference/adapters";
import type { GenerationGateway } from "./generation-gateway";
import type { LoadedModelContext } from "./model-host";

const mountedAdapter = (info: AdapterInfo): MountedAdapter => ({ id: info.id, path: info.path, rank: info.rank, scale: info.scale,
  sizeBytes: info.sizeBytes, mountedLayers: info.mountedLayers, ramBytes: info.ramBytes });

export function createAdapterOperation(context: Pick<LoadedModelContext, "adapters">, gateway: Pick<GenerationGateway, "runExclusive">,
  /** Test seam: the merge, default the training library's. */
  merge?: (sources: string[], output: string, scales?: number[]) => Promise<object>): AdapterOperation {
  return {
    async list() { return context.adapters.list().map(mountedAdapter); },
    mount: (id, directory, signal) => gateway.runExclusive(async () => mountedAdapter(await context.adapters.mount(id, directory)), undefined, signal),
    unmount: (id, signal) => gateway.runExclusive(async () => context.adapters.unmount(id), undefined, signal),
    // The library releases every tensor it materialized before it resolves, so the lock is held until cleanup finished.
    merge: (request, signal) => gateway.runExclusive(async () => {
      const run = merge ?? (await import("@mlx-bun/training/merge")).mergeAdapters;
      signal?.throwIfAborted();
      return await run([...request.adapters], request.output, request.scales ? [...request.scales] : undefined) as AdapterMergeStats;
    }, undefined, signal),
  };
}
