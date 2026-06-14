// Capability score — port of optiq/eval/score.py.
//
// A single scalar: the simple UNWEIGHTED mean of whichever of the six
// benchmarks (MMLU, GSM8K, IFEval, BFCL, HumanEval, HashHop) were run.
// Disk size is reported alongside but NEVER enters the score — no hidden
// quality/disk tradeoff baked into the number (optiq's explicit design
// choice). Missing components are skipped, not zero-filled.

export interface CapabilityScore {
  /** 0–100, simple mean of the provided benchmark percents. */
  score: number;
  /** Per-benchmark contribution to the mean (only the ones that ran). */
  components: Record<string, number>;
  /** Reported separately; does NOT affect `score`. */
  diskGb: number;
}

export type TaskName = "MMLU" | "GSM8K" | "IFEval" | "BFCL" | "HumanEval" | "HashHop";

/** Unweighted mean of the provided task percents (each 0–100). */
export function computeCapabilityScore(
  percents: Partial<Record<TaskName, number>>,
  diskGb: number,
): CapabilityScore {
  const components: Record<string, number> = {};
  for (const [name, val] of Object.entries(percents))
    if (val !== undefined && val !== null && Number.isFinite(val))
      components[name] = val;

  const keys = Object.keys(components);
  const score = keys.length === 0
    ? 0
    : keys.reduce((a, k) => a + components[k]!, 0) / keys.length;

  return { score, components, diskGb };
}

/** Sum of `*.safetensors` shard sizes for a local model dir, in GB. */
export function diskGbForDir(modelDir: string): number {
  try {
    const { readdirSync, statSync } = require("node:fs") as typeof import("node:fs");
    let total = 0;
    for (const f of readdirSync(modelDir))
      if (f.endsWith(".safetensors")) total += statSync(`${modelDir}/${f}`).size;
    return total / 1024 ** 3;
  } catch {
    return 0;
  }
}
