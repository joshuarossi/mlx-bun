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

import { readFileSync } from "node:fs";
import { join } from "node:path";

import { vaultRoot } from "./vault";

export const CHUNK_PROMPT = `TODO(M1): segment a conversation transcript into topic-coherent chunks.`;

export const CLUSTER_PROMPT = `TODO(M1): assign a chunk to an existing bucket from Meta/Buckets.md, or propose a new bucket.`;

export const SYNTHESIZE_PROMPT = `TODO(M1): integrate new chunks into the bucket's article. Preserve prose and every conv: citation; integrate, don't overwrite; respect the ≥70% word-count floor and the editorial gate.`;

/** Placeholder registry so the pipeline can reference prompts by stage name. */
export const STAGE_PROMPTS: Record<string, string> = {
  chunk: CHUNK_PROMPT,
  cluster: CLUSTER_PROMPT,
  synthesize: SYNTHESIZE_PROMPT,
};

// ---- meta-policy inlining (ported from lucien scripts/meta-inline.ts) ------
//
// Editorial policy lives in the vault's Meta/ pages, not in code. Rather than
// telling the model to Read those pages at synthesis time (which turns every
// pipeline call into an agent loop whose context accumulates — a 34k-char
// conversation was observed ballooning to a 105k-token prefill on the local
// server), we inline the requested pages directly into the prompt. Calls stay
// single-turn: one bounded prefill, one bounded generation. The policy is
// edit-in-the-vault: change a Meta page on disk and the next run reflects it
// with zero code change.

/**
 * Read the named Meta policy pages from the vault's Meta/ dir and concatenate
 * them for inlining into a stage prompt. Each `name` addresses
 * `<vault>/Meta/<name>.md` (a trailing `.md` is accepted and normalized).
 *
 * The vault root honors the MLX_BUN_WIKI override (see {@link vaultRoot}).
 *
 * @throws {Error} If a requested Meta page does not exist on disk, naming it.
 */
export function loadMetaPolicy(names: string[]): string {
  const metaDir = join(vaultRoot(), "Meta");
  const sections: string[] = [];
  for (const name of names) {
    const stem = name.trim().endsWith(".md") ? name.trim().slice(0, -3) : name.trim();
    const path = join(metaDir, `${stem}.md`);
    let text: string;
    try {
      text = readFileSync(path, "utf8");
    } catch {
      throw new Error(`Meta policy page not found: ${path}`);
    }
    sections.push(`--- Meta/${stem}.md ---\n\n${text.trim()}`);
  }
  return sections.join("\n\n");
}
