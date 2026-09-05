import type { GenerateOptions } from "../../generate";

/** Copy policy data without cloning native caches, controllers or callbacks. */
export function snapshotGenerationPolicy<T extends GenerateOptions & { stopSequences?: readonly string[] }>(options: T): T {
  const snapshot = { ...options };
  const freeze = (value: unknown): void => {
    if (!value || typeof value !== "object") return;
    for (const item of Object.values(value)) freeze(item);
    Object.freeze(value);
  };
  for (const key of ["stopSequences", "eosTokenIds", "adapters", "xtcSpecialTokens", "logitBias",
    "kvConfig", "turboQuant", "pagedKv", "hlg", "curve", "decodePolicy"] as const) {
    if (snapshot[key] === undefined) continue;
    const value = structuredClone(snapshot[key]);
    freeze(value);
    Object.assign(snapshot, { [key]: value });
  }
  return Object.freeze(snapshot);
}

