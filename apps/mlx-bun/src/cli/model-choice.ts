// The public `mlx-bun/selection` entry: main's pure model-selection helpers
// (src/fit.ts). A leaf module with no imports, so it loads without native MLX;
// model-selection.ts applies these choices to the registry and fit.
// Application choices, not hub policy: discovery and fit remain reusable libraries.

/** The model automatic selection prefers (e4b). */
export const DEFAULT_REPO_ID = "mlx-community/gemma-4-e4b-it-OptiQ-4bit";
/** Downloaded first when no supported model is cached. */
export const STARTER_REPO_ID = "mlx-community/MiniCPM5-1B-OptiQ-4bit";
/** Fraction of RAM an automatically selected model may use while leaving room for other apps. */
export const COEXIST_FRACTION = 0.6;

/** Prefer e4b when it fits; otherwise retain room for other apps where possible.
 * Explicit model selection does not use these advisory fit predicates. */
export function chooseAutoModel<T extends { repoId: string; sizeBytes: number }>(
  candidates: readonly T[], preferredRepo: string,
  fitsFull: (candidate: T) => boolean, fitsCoexist: (candidate: T) => boolean,
): T | undefined {
  const preferred = candidates.find(candidate => candidate.repoId === preferredRepo);
  if (preferred && fitsFull(preferred)) return preferred;
  const largest = [...candidates].sort((a, b) => b.sizeBytes - a.sizeBytes);
  return largest.find(fitsCoexist) ?? largest.find(fitsFull);
}

/** Largest Gemma a RAM tier can comfortably hold: the 26B at 48 GiB or more,
 * the 12B at 24 GiB or more, otherwise DEFAULT_REPO_ID. An explicit opt-in:
 * automatic selection never calls it. Pass the RAM, e.g. `os.totalmem()`. */
export function largestRecommendedRepoId(ramBytes: number): string {
  const gb = ramBytes / 2 ** 30;
  if (gb >= 48) return "mlx-community/gemma-4-26B-A4B-it-OptiQ-4bit";
  if (gb >= 24) return "mlx-community/gemma-4-12B-it-OptiQ-4bit";
  return DEFAULT_REPO_ID;
}
