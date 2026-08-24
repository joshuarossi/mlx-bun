// Machine-specific golden resolution.
//
// Logit goldens are bit-exact only on the GPU that produced them: brew
// libmlx and pip mlx-metal compile metallibs that diverge across chips at
// the fast-SDPA dispatch boundary (see PLAN.md "goldens are machine-
// specific"). So a single committed set can't be bit-exact everywhere.
//
// Layout:
//   goldens/<name>                 — reference set (the REFERENCE_MACHINE box)
//   goldens/<machine-key>/<name>   — per-machine override, wins when present
//
// Machine-independent goldens (tokenizer, chat templates, prompt ids,
// shape manifests) live only in the flat set and resolve there by fallback.
// Reads go through goldenAt()/goldenPath(); regen scripts write to
// goldenOutDir(). Override the auto-detected key with MLX_BUN_GOLDEN_MACHINE.

import { existsSync } from "node:fs";
import { cpus } from "node:os";

/** Stable per-GPU key, e.g. "apple-m1-max", from the CPU brand string.
 *  Override with MLX_BUN_GOLDEN_MACHINE (CI, cross-machine reproduction). */
export function goldenMachine(): string {
  const explicit = process.env.MLX_BUN_GOLDEN_MACHINE?.trim();
  if (explicit) return explicit;
  const brand = cpus()[0]?.model ?? "unknown";
  return brand
    .toLowerCase()
    .replace(/[^a-z0-9]+/g, "-")
    .replace(/^-+|-+$/g, "");
}

/** The box that produced the committed flat goldens. On it, regen writes the
 *  flat set rather than an override dir. Override with MLX_BUN_GOLDEN_REFERENCE
 *  on whichever machine owns the canonical goldens. */
export const REFERENCE_MACHINE =
  process.env.MLX_BUN_GOLDEN_REFERENCE?.trim() || "apple-m4-pro";

/** Resolve a golden file name to its path: the current machine's override if
 *  one exists, else the flat reference set. */
export function goldenPath(name: string): string {
  const override = `goldens/${goldenMachine()}/${name}`;
  return existsSync(override) ? override : `goldens/${name}`;
}

/** Bun.file for a golden, machine-override-aware. Drop-in for
 *  Bun.file("goldens/<name>"). Named goldenAt (not golden) to avoid colliding
 *  with the `const golden = ...` parsed-object convention in the tests. */
export function goldenAt(name: string) {
  return Bun.file(goldenPath(name));
}

/** Directory regen scripts should write to for THIS machine: the flat set on
 *  the reference box, an override dir everywhere else. */
export function goldenOutDir(): string {
  return goldenMachine() === REFERENCE_MACHINE ? "goldens" : `goldens/${goldenMachine()}`;
}
