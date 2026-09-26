// Read-path embedding tripwire.
//
// Main counted embedder calls in `src/embed.ts`; every read-path test asserted
// the counter stayed 0. Here the memory domain cannot import the embeddings
// layer at all (the app DAG forbids it), so the equivalent proof is structural:
// no module under the inference package's `embeddings/` directory is loaded in
// this process. `resetEmbedCounter` keeps main's call sites intact; the count
// can only rise if something on the exercised path pulled the embedder in.

export function resetEmbedCounter(): void {}

export function getEmbedCounter(): number {
  return Object.keys(require.cache).filter((path) => /\/embeddings\//.test(path)).length;
}
