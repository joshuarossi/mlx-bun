import type { GenerateOptions } from "../generate";

/** Snapshot numerical configuration when the request is bound. Caller-owned
 * arrays must not change the graph or persistence identity after grouping. */
export function captureSpeculativeOptions(options: GenerateOptions): GenerateOptions {
  return { ...options,
    ...(options.kvConfig ? { kvConfig: options.kvConfig.map(({ layerIdx, bits, groupSize }) =>
      ({ layerIdx, bits, groupSize })).sort((a, b) => a.layerIdx - b.layerIdx) } : {}),
    ...(options.turboQuant ? { turboQuant: { ...options.turboQuant } } : {}),
  };
}

/** Existing namespaces remain byte-identical when no per-layer scheme is
 * supplied. Execution and persistence consume the same captured settings. */
export function speculativePrefixNamespace(method: string | undefined, adapters: string | string[],
  options: GenerateOptions): string {
  return JSON.stringify({ method, adapters, kvBits: options.kvBits ?? null,
    kvGroupSize: options.kvGroupSize ?? 64, quantizedKvStart: options.quantizedKvStart ?? null,
    turboQuant: options.turboQuant ?? null,
    ...(options.kvConfig?.length ? { kvConfig: options.kvConfig } : {}),
  });
}
