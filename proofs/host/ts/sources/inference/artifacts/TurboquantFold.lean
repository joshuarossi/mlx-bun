import host.ts.Source
namespace Host.Ts.Sources.Inference.Artifacts.TurboquantFold
set_option maxRecDepth 100000

/-- Verbatim `packages/inference/src/artifacts/turboquant-fold.ts`; `host/ts/SourceBinding.ts` checks the bytes. -/
def source : String := r#"// The TurboQuant fold record: `turboquant_fold.json`, the auxiliary file the
// Trellis quantizer (packages/quantize/src/trellis-quantizer.ts) writes beside a
// rotated checkpoint. It records the R1 rotation the weights were folded with
// and the final-norm gain the fold moved into `lm_head`. Records written before
// the quantizer recorded the gain carry no `final_gain`.

import { existsSync, readFileSync } from "node:fs";
import { join } from "node:path";

export const TURBOQUANT_FOLD_FILE = "turboquant_fold.json";

/** What a rotated checkpoint records about its fold. */
export interface TurboQuantFold {
  /** Seed of R1's sign vector. */
  readonly seed: number;
  /** The residual stream carries the R1 rotation. */
  readonly r1: boolean;
  readonly hiddenSize: number;
  /** `final_gain`: the effective final-norm gain γ (stored + 1 of the source's
   *  final norm) the fold moved into `lm_head`, one per hidden channel. Absent
   *  when the record does not carry it. */
  readonly finalGain?: Float32Array;
}

/** The fold record in `modelDir`, or null when the artifact carries none.
 *  Throws when the record lacks a field or its gain does not span `hiddenSize`. */
export function readTurboQuantFold(modelDir: string): TurboQuantFold | null {
  const path = join(modelDir, TURBOQUANT_FOLD_FILE);
  if (!existsSync(path)) return null;
  const raw = JSON.parse(readFileSync(path, "utf8")) as Record<string, unknown>;
  const { seed, r1, hiddenSize } = raw;
  if (!Number.isInteger(seed)) throw new Error(`${path}: seed must be an integer (got ${String(seed)})`);
  if (typeof r1 !== "boolean") throw new Error(`${path}: r1 must be a boolean (got ${String(r1)})`);
  if (!Number.isInteger(hiddenSize) || (hiddenSize as number) <= 0)
    throw new Error(`${path}: hiddenSize must be a positive integer (got ${String(hiddenSize)})`);
  const fold = { seed: seed as number, r1, hiddenSize: hiddenSize as number };
  if (raw.final_gain === undefined) return Object.freeze(fold);
  const gain = raw.final_gain;
  if (!Array.isArray(gain) || gain.length !== hiddenSize || !gain.every(value => typeof value === "number" && Number.isFinite(value)))
    throw new Error(`${path}: final_gain must be ${String(hiddenSize)} finite numbers`);
  return Object.freeze({ ...fold, finalGain: Float32Array.from(gain as number[]) });
}
"#

source_parse source

/-- Lean's lexer and parser accept the whole file (kernel-checked chunks). -/
theorem parses : (parse chars).isSome = true := parse_isSome lex_eq parsesTokens

theorem sourceParses : (parse source.toList).isSome = true := chars.eq ▸ parses

end Host.Ts.Sources.Inference.Artifacts.TurboquantFold
