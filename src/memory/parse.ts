// mlx-bun memory — parse contracts for model outputs.
//
// The synthesis pipeline drives the model with small, structured prompts and
// needs deterministic parsing of free-text completions back into typed values.
// Two shapes cover the cases: a yes/no binary gate and a newline list.

/** Binary gate: true iff the output starts with `y`/`Y` (everything else → false). */
export function parseBinary(out: string): boolean {
  return /^\s*y/i.test(out);
}

/**
 * List output: split on newlines, trim each line, and drop empties as well as
 * any line that is exactly "NONE" (case-insensitive) — the model's sentinel for
 * "no items".
 */
export function parseLines(out: string): string[] {
  return out
    .split("\n")
    .map((line) => line.trim())
    .filter((line) => line.length > 0 && line.toLowerCase() !== "none");
}
