import host.ts.Source
namespace Host.Ts.Sources.Inference.Contracts.Portable.Prefill
set_option maxRecDepth 100000

/-- Verbatim `packages/inference/src/contracts/portable/prefill.ts`; `host/ts/SourceBinding.ts` checks the bytes. -/
def source : String := r#"/** Request-level chunk policy. Execution consumes the selected size; model
 * backends can account for their temporary workspace without changing admission. */
export interface PrefillPolicy {
  chunkSize(promptTokens: number): number;
}

export interface PrefillPosition {
  readonly length: number;
  readonly position: number;
  readonly chunkSize: number;
  readonly tailSplit: boolean;
  readonly snapshotAt?: number | null;
}

/** The phase a prompt step runs in, named by the planner that cut it: a whole
 * planned `chunk` (exactly the step's chunk size), a `tail` (any other number
 * of positions above one: what is left after the whole chunks, or a piece a
 * snapshot boundary cuts short), or `decode`, a single position, which appends
 * through the one-position read. */
export type PrefillPhase = "chunk" | "tail" | "decode";

export interface PrefillStep {
  readonly start: number;
  readonly end: number;
  readonly kind: "drain" | "final";
  readonly snapshot: boolean;
  /** Batch admission may finish a short last drain and token zero in one tick.
   * Otherwise execution yields between every drain and the next forward. */
  readonly batchYield: boolean;
  readonly phase: PrefillPhase;
}

/** The phase of a step the planner made `whole` (a full chunk) or not, from
 * `start` to `end`. */
export function prefillPhase(start: number, end: number, whole: boolean): PrefillPhase {
  return end - start === 1 ? "decode" : whole ? "chunk" : "tail";
}

/** The prefill program a row follows, alone or in a batch. No tensors, runtime policy reads,
 * or sampling. Advance position only after executing the returned step. */
export function nextPrefillStep(input: PrefillPosition): PrefillStep {
  const { length, position, chunkSize, tailSplit, snapshotAt } = input;
  if (!Number.isSafeInteger(length) || !Number.isSafeInteger(position) ||
      !Number.isSafeInteger(chunkSize) || chunkSize < 1 || position < 0 || position >= length)
    throw new Error("invalid prefill position or chunk size");
  if (snapshotAt != null && (!Number.isSafeInteger(snapshotAt) || snapshotAt < 0 || snapshotAt > length))
    throw new Error("invalid prefill snapshot boundary");
  if (snapshotAt != null && snapshotAt > position && snapshotAt < length) {
    const whole = position + chunkSize <= snapshotAt;
    const end = whole ? position + chunkSize : snapshotAt;
    return { start: position, end, kind: "drain", snapshot: end === snapshotAt, batchYield: true,
      phase: prefillPhase(position, end, whole) };
  }
  const remaining = length - position;
  if (remaining > (tailSplit ? 1 : chunkSize)) {
    const whole = !tailSplit || chunkSize <= remaining - 1;
    const end = position + (whole ? chunkSize : remaining - 1);
    return { start: position, end, kind: "drain", snapshot: false,
      batchYield: !tailSplit || remaining - 1 > chunkSize, phase: prefillPhase(position, end, whole) };
  }
  return { start: position, end: length, kind: "final", snapshot: false, batchYield: false,
    phase: prefillPhase(position, length, remaining === chunkSize) };
}
"#

source_parse source

/-- Lean's lexer and parser accept the whole file (kernel-checked chunks). -/
theorem parses : (parse chars).isSome = true := parse_isSome lex_eq parsesTokens

theorem sourceParses : (parse source.toList).isSome = true := chars.eq ▸ parses

end Host.Ts.Sources.Inference.Contracts.Portable.Prefill
