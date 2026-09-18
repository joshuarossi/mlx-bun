// Frequency-ranked draft vocabulary (FR-Spec, Zhao et al. 2025).
//
// A native MTP head spends most of each draft step in the target's vocabulary
// projection (Qwen3.8: 248,320 rows). Drafts only need to be LIKELY tokens, so
// the draft projects onto the N most frequent rows of the same quantized head.
// The target still verifies and samples over the full vocabulary: outputs are
// unchanged, a token outside the list simply cannot be drafted (one miss).
//
// Coupling is preserved. For a [1, V] input MLX's categorical draws by INVERSE
// CDF in token-id order with ONE uniform from the step key (random.cpp
// categorical_inverse_cdf), and the default draft uses the same key as the target
// position it predicts, so both read the same point of their own CDFs. The list
// is kept in ascending id order, so a categorical draw over the listed rows IS a
// full-vocabulary draw with zero mass outside the list: same uniform, same order,
// same coupling. No noise reconstruction is involved.
//
// Opt-in: MLX_BUN_SPEC_DRAFT_VOCAB=<json {"ids":[...]}>. Build lists with
// reports/qwen38-trellis-publication/build-draft-vocab.ts (corpus provenance
// and coverage are recorded beside the list).
import { existsSync, readFileSync } from "node:fs";
import { join } from "node:path";
import { MlxArray } from "../mlx/array";
import * as ops from "../mlx/ops";
import { runtimeValue } from "../runtime-config";
import { applyMinP, applyTopK, applyTopP, stepKey, toLogprobs, type SamplerOptions } from "../sampler";

export interface QuantizedHeadState {
  readonly w: MlxArray;
  readonly scales: MlxArray;
  readonly biases: MlxArray | null;
  readonly spec: ops.QuantSpec;
}

const lists = new Map<string, readonly number[]>();

export const DRAFT_VOCAB_FILE = "draft_vocab.json";

/** The draft vocabulary for this target, validated against its vocabulary size,
 *  or null. Precedence: `MLX_BUN_SPEC_DRAFT_VOCAB=<path>` selects a list,
 *  `=0`/`=off` disables, and otherwise the list shipped beside the draft
 *  companion (`<companionDir>/draft_vocab.json`) is used when present. */
export function configuredDraftVocabulary(vocabSize: number, companionDir?: string): readonly number[] | null {
  const setting = runtimeValue("MLX_BUN_SPEC_DRAFT_VOCAB");
  if (setting === "0" || setting === "off") return null;
  let path = setting;
  if (!path && companionDir) {
    const shipped = join(companionDir, DRAFT_VOCAB_FILE);
    if (existsSync(shipped)) path = shipped;
  }
  if (!path) return null;
  let ids = lists.get(path);
  if (!ids) {
    const parsed = JSON.parse(readFileSync(path, "utf8")) as { ids?: unknown };
    if (!Array.isArray(parsed.ids) || parsed.ids.length === 0)
      throw new Error(`draft vocabulary ${path}: expected {"ids":[...]}`);
    const sorted = [...new Set(parsed.ids as number[])].sort((a, b) => a - b);
    if (!sorted.every(id => Number.isInteger(id) && id >= 0))
      throw new Error(`draft vocabulary ${path}: ids must be nonnegative integers`);
    lists.set(path, ids = sorted);
  }
  if (ids.at(-1)! >= vocabSize)
    throw new Error(`draft vocabulary ${path}: id ${ids.at(-1)} outside the target vocabulary ${vocabSize}`);
  return ids;
}

/** Rows of a quantized head (affine packs along the input axis, so a row
 *  gather is exact). Owns its gathered arrays; borrows nothing afterwards. */
export class DraftVocabularyHead {
  readonly ids: MlxArray; // [N] int32, ascending token ids
  readonly size: number;
  readonly #w: MlxArray;
  readonly #scales: MlxArray;
  readonly #biases: MlxArray | null;
  readonly #spec: ops.QuantSpec;

  constructor(head: QuantizedHeadState, ids: readonly number[]) {
    this.size = ids.length;
    this.ids = ops.fromInt32([...ids], [ids.length]);
    const rows = (a: MlxArray) => { using taken = ops.takeAxis(a, this.ids, 0); return ops.contiguous(taken); };
    this.#w = rows(head.w);
    this.#scales = rows(head.scales);
    this.#biases = head.biases ? rows(head.biases) : null;
    this.#spec = head.spec;
    ops.evalAll([this.ids, this.#w, this.#scales, ...(this.#biases ? [this.#biases] : [])]);
  }

  /** hidden [..., H] → logits [..., N] over the listed ids. */
  project(hidden: MlxArray): MlxArray {
    return ops.quantizedMatmul(hidden, this.#w, this.#scales, this.#biases, this.#spec, true);
  }

  dispose(): void {
    this.ids.dispose(); this.#w.dispose(); this.#scales.dispose(); this.#biases?.dispose();
  }
}

export type SubsetDraftSampler = (logits: MlxArray, head: DraftVocabularyHead, step: number) => MlxArray;

/** One request's coupled draw over a draft vocabulary: subset logits [1, N] →
 *  owned token id [1] (a FULL-vocabulary id). Null when the options need a
 *  sampler this path does not reproduce (curve, HLG, XTC). */
export function makeSubsetDraftSampler(options: SamplerOptions): SubsetDraftSampler | null {
  const { temperature = 0, topP = 0, topK = 0, minP = 0, minTokensToKeep = 1, xtcProbability = 0, seed = 0 } = options;
  if (options.curve || options.hlg?.enabled === true || xtcProbability > 0) return null;
  const pick = (index: MlxArray, head: DraftVocabularyHead): MlxArray => {
    using flat = ops.reshape(index, [1]);
    return ops.takeAxis(head.ids, flat, 0);
  };
  if (temperature === 0) return (logits, head) => { using index = ops.argmaxAxis(logits, -1); return pick(index, head); };
  return (logits, head, step) => {
    const owned: MlxArray[] = [];
    try {
      let current = toLogprobs(logits); owned.push(current);
      if (topP > 0 && topP < 1) { current = applyTopP(current, topP); owned.push(current); }
      if (minP !== 0) { current = applyMinP(current, minP, minTokensToKeep); owned.push(current); }
      if (topK > 0 && topK < head.size) { current = applyTopK(current, topK); owned.push(current); }
      using scaled = ops.mulScalar(current, 1 / temperature);
      using key = stepKey(seed, step);
      using index = ops.randomCategorical(scaled, key);
      return pick(index, head);
    } finally { for (const array of owned) array.dispose(); }
  };
}
