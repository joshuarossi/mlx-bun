// mlx-bun memory — per-stage synthesis prompts.  ⚠️ M1 STUBS.
//
// Each stage's prompt is the seam where a future specialized memory LoRA plugs
// in (today: base model + prompt; later: adapterScoped per stage). Editorial
// conventions are NOT duplicated here — they live in the vault's Meta/ pages
// (Editorial_Guidelines.md, Article_Conventions.md, Buckets.md,
// Topics_to_Ignore.md) and are read in at synthesis time so the system governs
// itself in its own substrate.
//
// See docs/design/memory-system.md → "Synthesis runs on the local model".

export const CHUNK_PROMPT = `TODO(M1): segment a conversation transcript into topic-coherent chunks.`;

export const CLUSTER_PROMPT = `TODO(M1): assign a chunk to an existing bucket from Meta/Buckets.md, or propose a new bucket.`;

export const SYNTHESIZE_PROMPT = `TODO(M1): integrate new chunks into the bucket's article. Preserve prose and every conv: citation; integrate, don't overwrite; respect the ≥70% word-count floor and the editorial gate.`;

/** Placeholder registry so the pipeline can reference prompts by stage name. */
export const STAGE_PROMPTS: Record<string, string> = {
  chunk: CHUNK_PROMPT,
  cluster: CLUSTER_PROMPT,
  synthesize: SYNTHESIZE_PROMPT,
};
