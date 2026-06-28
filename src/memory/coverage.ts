// P9-T4 — migration parity / coverage.
//
// The migration thesis: synthesizing the old Lucien topic-bin vault (385 bins)
// into sharp entity articles DROPS article count, but must LOSE ZERO
// engaged-with things. This module is the proof harness: every notable entity
// in the hand-curated gold (`goldens/dreaming-entities-gold.json`
// notableEntities — owned/decided/recurring/opinion, NOT the bucket taxonomy
// we replace) must resolve to an article (or alias) in the new vault.
//
// Pure read-path: reindex (file I/O) + alias resolution. No model load, no
// embedder — the read-path tripwire (`src/embed.ts` counter) stays 0.

import { readFileSync } from "node:fs";
import { join } from "node:path";

import type { MemoryStore } from "./db";
import { resolveName } from "./reindex";
import { articlesDir } from "./vault";

/** A hand-curated notable entity (the personal-notability oracle). */
export interface NotableEntity {
  name: string;
  kind: string;
  domain: string;
  aliases: string[];
  whyNotable: string;
}

/** The shape of `goldens/dreaming-entities-gold.json` (the slice we read). */
export interface EntitiesGold {
  notableEntities: NotableEntity[];
}

/** Per-entity coverage verdict. */
export interface CoverageRow {
  /** Canonical gold name. */
  name: string;
  domain: string;
  /** True when the name or any alias resolves to an article stem. */
  covered: boolean;
  /** The resolved article stem, or null when missing. */
  stem: string | null;
  /** The surface form (name/alias) that resolved, or null. */
  matchedVia: string | null;
  /** Covered, but the target article body is below the stub threshold. */
  stub: boolean;
}

export interface CoverageReport {
  goldNotable: number;
  coveredCount: number;
  missingCount: number;
  stubCount: number;
  covered: CoverageRow[];
  missing: CoverageRow[];
  stubs: CoverageRow[];
  rows: CoverageRow[];
}

/** Below this many chars of prose (infobox + headings stripped) an article is
 *  flagged a stub: present but not yet a real article. Informational. */
export const STUB_PROSE_CHARS = 300;

/** Prose length of an article body, excluding the ```info fence and headings —
 *  the signal for "is this a real article or a placeholder?". */
function prosePulse(root: string, stem: string): number {
  let content: string;
  try {
    content = readFileSync(join(articlesDir(root), `${stem}.md`), "utf8");
  } catch {
    return 0;
  }
  const withoutInfo = content.replace(/```info[\s\S]*?```/g, "");
  const prose = withoutInfo
    .split(/\r?\n/)
    .filter((line) => !/^\s*#/.test(line)) // drop headings
    .join("\n")
    .trim();
  return prose.length;
}

/** Resolve one notable entity against the vault: try the canonical name first,
 *  then each alias. Returns the first hit (stem + the surface that matched). */
function resolveEntity(
  store: MemoryStore,
  entity: NotableEntity,
): { stem: string; via: string } | null {
  for (const surface of [entity.name, ...entity.aliases]) {
    const stem = resolveName(store, surface);
    if (stem) return { stem, via: surface };
  }
  return null;
}

/**
 * Coverage report for the notable-entity gold against a (reindexed) vault.
 * `store` MUST already be reindexed from `root` (the caller owns the load).
 */
export function coverageReport(
  store: MemoryStore,
  notable: NotableEntity[],
  root: string,
): CoverageReport {
  const rows: CoverageRow[] = notable.map((entity) => {
    const hit = resolveEntity(store, entity);
    if (!hit) {
      return { name: entity.name, domain: entity.domain, covered: false, stem: null, matchedVia: null, stub: false };
    }
    const stub = prosePulse(root, hit.stem) < STUB_PROSE_CHARS;
    return {
      name: entity.name,
      domain: entity.domain,
      covered: true,
      stem: hit.stem,
      matchedVia: hit.via,
      stub,
    };
  });

  const covered = rows.filter((r) => r.covered);
  const missing = rows.filter((r) => !r.covered);
  const stubs = covered.filter((r) => r.stub);

  return {
    goldNotable: notable.length,
    coveredCount: covered.length,
    missingCount: missing.length,
    stubCount: stubs.length,
    covered,
    missing,
    stubs,
    rows,
  };
}
