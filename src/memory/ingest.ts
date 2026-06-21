// mlx-bun memory — synthesis stage 1: INGEST.  ⚠️ M1 STUB.
//
// pi sessions (~/.mlx-bun/sessions + ~/.mlx-bun/pi, pi's own JSONL) →
// memory.sqlite, normalized to {conv, source, title, transcript}, watermark-
// gated so each run only processes what's new. No web scraping, no Playwright:
// mlx-bun synthesizes ITS OWN sessions only. Mirrors lucien's ingest-recent.ts.
//
// See docs/design/memory-system.md → "Ingestion — mlx-bun sessions only".

import type { SynthesisEvent } from "./pipeline";

export interface IngestResult {
  scanned: number;
  ingested: number;
}

/** Read new pi sessions into memory.sqlite. STUB: returns zero, does nothing. */
export async function ingestSessions(_onEvent?: (e: SynthesisEvent) => void): Promise<IngestResult> {
  // TODO(M1): SessionManager.listAll() → normalize → upsert into conversations,
  // advancing the per-source watermark. pi's session format is the contract.
  throw new Error("memory.ingest is not implemented yet (M1)");
}
