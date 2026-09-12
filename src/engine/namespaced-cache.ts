import type { PrefixCache } from "../contracts/prefix-cache";

/** Compose numerical identity with a cache without exposing its storage tiers. */
export function namespacedCache<State, Attachment>(cache: PrefixCache<State, Attachment>,
  namespace: (base: string) => string): PrefixCache<State, Attachment> {
  return {
    closeSession: id => cache.closeSession?.(id),
    reclaim: () => cache.reclaim?.(),
    ...(cache.prefetch ? { prefetch: (tokens: number[], ns = "", sessionId?: string) => cache.prefetch!(tokens, namespace(ns), sessionId) } : {}),
    take: (tokens, ns = "", sessionId) => cache.take(tokens, namespace(ns), sessionId),
    put: (tokens, state, ns = "", retain, attachments, sessionId) => cache.put(tokens, state, namespace(ns), retain, attachments, sessionId),
  };
}
