// Compatibility facade for the canonical IFEval scorer.
//
// The complete verifier registry and strict/loose aggregation contract live in
// `tasks/ifeval.ts`, which is also used by `scripts/eval.ts`. Keep this module
// as the stable import surface used by `scripts/run-ifeval.ts` and older
// callers; it must not grow a second verifier implementation.

import {
  scoreIfevalInstance,
  scoreIfevalPairs,
  type IfevalInstance,
  type IfevalResult,
} from "./tasks/ifeval";

export {
  SUPPORTED_INSTRUCTIONS,
  looseClean,
  scoreIfevalInstance,
  scoreIfevalPairs,
  stripThinking,
  verifyResponse,
  type IfevalCoverage,
  type IfevalInstance,
  type IfevalInstanceScore,
  type IfevalPair,
  type IfevalResult,
  type IfevalVerification,
} from "./tasks/ifeval";

/** Historical spelling retained for callers of this module. */
export type IFEvalInstance = IfevalInstance;

export interface InstanceResult {
  /** Unknown instructions are true here per the canonical prompt contract. */
  perInstruction: boolean[];
  followedAll: boolean;
  /** Consult this field rather than interpreting unknown IDs as verified. */
  unhandled: string[];
}

/**
 * Historical strict-only helper, now delegated to the canonical scorer.
 * New code should prefer `scoreIfevalInstance` for both strict and loose modes.
 */
export function scoreInstance(
  instance: IFEvalInstance,
  response: string,
): InstanceResult {
  const { strict } = scoreIfevalInstance(instance, response);
  return {
    perInstruction: strict.instructionPasses.map((result) => result ?? true),
    followedAll: strict.pass,
    unhandled: strict.unhandled,
  };
}

export interface IFEvalReport extends IfevalResult {
  /** Historical alias for nTotal. */
  n: number;
  /** Historical alias for strictAcc (prompt-level strict). */
  promptAccuracy: number;
  /** Historical alias for strictInstructionAcc. */
  instructionAccuracy: number;
}

/**
 * Historical aggregation helper with unambiguous canonical fields plus aliases.
 * Unknown instructions do not fail prompt accuracy, are excluded from
 * instruction accuracy, and remain visible in `coverage`.
 */
export function aggregate(
  pairs: Array<{ instance: IFEvalInstance; response: string }>,
): IFEvalReport {
  const result = scoreIfevalPairs(pairs);
  return {
    ...result,
    n: result.nTotal,
    promptAccuracy: result.strictAcc,
    instructionAccuracy: result.strictInstructionAcc,
  };
}
