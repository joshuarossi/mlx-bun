// The served model's adapter operation for a host that holds residency (serve-host.ts, serve-isolated.ts): every call leases
// the current model, so it cannot be evicted while the call runs, and runs on the operation the model's own unit exposes.
import type { AdapterOperation, ModelId } from "@mlx-bun/app-core";
import type { ResidencyHost, ResidentUnit } from "./model-residency";

export function leasedAdapters<U extends ResidentUnit>(host: Pick<ResidencyHost<U>, "acquire">, current: () => ModelId): AdapterOperation {
  async function on<T>(signal: AbortSignal | undefined, use: (operation: AdapterOperation) => Promise<T>): Promise<T> {
    const lease = await host.acquire(current(), signal ? { signal } : {});
    try {
      const operation = lease.operations.adapters;
      if (!operation) throw new Error(`${lease.model.id} does not mount adapters`);
      return await use(operation);
    } finally { lease.release(); }
  }
  return {
    list: signal => on(signal, operation => operation.list(signal)),
    mount: (id, directory, signal) => on(signal, operation => operation.mount(id, directory, signal)),
    unmount: (id, signal) => on(signal, operation => operation.unmount(id, signal)),
    merge: (request, signal) => on(signal, operation => operation.merge(request, signal)),
  };
}
