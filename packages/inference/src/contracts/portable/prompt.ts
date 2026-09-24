/** Execute native prompt preparation under caller-owned resource coordination. */
export type PromptNativeWork = <T>(work: () => Promise<T>) => Promise<T>;
