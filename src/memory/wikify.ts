// mlx-bun memory — synthesis stage 5: WIKIFY (deterministic).  ⚠️ M1 STUB.
//
// Non-model editorial cleanup after synthesis: canonicalize [[wikilinks]]
// (spaces↔underscores, case, resolve to existing stems), repair footnotes, and
// run the deterministic editorial gate. Non-fatal — a failure here logs and
// continues; it never corrupts an article. Mirrors lucien's wikify.ts +
// normalize-wikilinks.ts + normalize-footnotes.ts.
//
// See docs/design/memory-system.md → "The nightly pipeline" (wikify/normalize).

import type { SynthesisEvent } from "./pipeline";

export interface WikifyResult {
  articlesNormalized: number;
  linksFixed: number;
}

/** Deterministic editorial gate + link/footnote normalize. STUB. */
export async function wikify(_onEvent?: (e: SynthesisEvent) => void): Promise<WikifyResult> {
  // TODO(M1): resolveWikilinkToStem across touched articles (vault.ts already
  // has the resolver), footnote renumber/repair, {{stub}} marking.
  throw new Error("memory.wikify is not implemented yet (M1)");
}
