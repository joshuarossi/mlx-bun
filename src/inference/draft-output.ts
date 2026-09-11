import type { Cancellation, CancelReason, GenerationOutput, TokenLogprobs } from "../contracts/generation";
import type { DraftAcceptance } from "./draft-acceptance";

export interface DraftOutputRow {
  readonly acceptance: DraftAcceptance;
  readonly logprobs?: readonly (TokenLogprobs | undefined)[];
  readonly output: Pick<GenerationOutput, "commit">;
  readonly cancellation?: Cancellation;
}

/** Counts apply to this round. Accepted counts describe processed proposed
 * inputs, excluding an unprocessed correction/bonus and any unpublished EOS.
 * Failed/cancelled requests must be discarded, never checkpointed. */
export type DraftOutputResult = { readonly generated: number; readonly accepted: number } & (
  | { readonly kind: "continue"; readonly pending: number }
  | { readonly kind: "stop" | "length" }
  | { readonly kind: "cancelled"; readonly reason: CancelReason }
  | { readonly kind: "failed"; readonly error: unknown }
);

/** Deliver verified content through the output interface before resolving
 * retained state. A stopped or failed consumer affects only its own request.
 * Token-sized publications preserve callbacks that stop inside a draft burst. */
export async function deliverDraftOutputs(rows: readonly DraftOutputRow[]): Promise<DraftOutputResult[]> {
  const results: DraftOutputResult[] = [];
  for (const row of rows) results.push(await deliver(row));
  return results;
}

async function deliver(row: DraftOutputRow): Promise<DraftOutputResult> {
  const { acceptance } = row;
  let generated = 0;
  const retained = () => ({ generated, accepted: Math.min(generated, acceptance.accepted) });
  try {
    for (const token of acceptance.emitted) {
      const reason = row.cancellation?.reason;
      if (reason) return { kind: "cancelled", reason, generated, accepted: 0 };
      const metadata = row.logprobs?.[generated];
      const more = await row.output.commit([token], metadata ? [metadata] : undefined);
      generated++;
      if (more === false) return { kind: "stop", ...retained() };
    }
    const reason = row.cancellation?.reason;
    if (reason) return { kind: "cancelled", reason, generated, accepted: 0 };
    if (acceptance.sawEos || acceptance.grammarDone) return { kind: "stop", ...retained() };
    if (generated >= acceptance.remaining) return { kind: "length", ...retained() };
    return { kind: "continue", pending: acceptance.correction!, ...retained() };
  } catch (error) { return { kind: "failed", error, generated, accepted: 0 }; }
}
