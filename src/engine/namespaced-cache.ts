import type { PrefixCache } from "../contracts/prefix-cache";

/** Compose numerical identity with a cache without exposing its storage tiers. */
export function namespacedCache<State, Attachment>(cache: PrefixCache<State, Attachment>,
  namespace: (base: string) => string): PrefixCache<State, Attachment> {
  return {
    reclaim: () => cache.reclaim?.(),
    ...(cache.prefetch ? { prefetch: (tokens: number[], ns = "") => cache.prefetch!(tokens, namespace(ns)) } : {}),
    take: (tokens, ns = "") => cache.take(tokens, namespace(ns)),
    put: (tokens, state, ns = "", retain, attachments) => cache.put(tokens, state, namespace(ns), retain, attachments),
  };
}
