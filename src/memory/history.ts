// mlx-bun memory — the contradiction classifier + the "## History" section.
//
// When a later-dated note contradicts a claim already in an article, the resolve
// must decide WHICH KIND of contradiction it is before it edits:
//
//   (a) EVOLUTION — the USER changed their own position / opinion / preference /
//       relationship over time (both statements were true when made; the view
//       simply moved). The LEAD/BODY resolve to the CURRENT state, and the
//       trajectory is PRESERVED in a dedicated "## History" section (we KEEP the
//       history) — both the earlier and the later source cited.
//
//   (b) ERROR — the earlier value was simply a WRONG world-fact / spec, or a flat
//       "no, that is wrong, it is actually <value>" correction. The wrong value is
//       SILENTLY overwritten with the correct one: NO History entry, the wrong
//       value pruned entirely as if it had never been there.
//
// The classifier is a bounded yes/no the small local model can answer reliably:
// "is this the user changing their own view over time, or correcting a wrong
// fact?". Everything in this module is schematic (the prompt carries ONLY
// instructions + the two real values under comparison, never a copyable example).

import { LEAD_ANCHOR } from "./cluster";

export const HISTORY_TITLE = "History";
export const HISTORY_ANCHOR = "history";
const HISTORY_HEADING_RE = /^##\s+History\s*$/i;

/** The two outcomes of a contradiction classification. */
export type ContradictionKind = "evolution" | "error";

/**
 * The bounded EVOLUTION-vs-ERROR classifier prompt. It carries ONLY the two real
 * values under comparison (the article data being reconciled) plus the decision
 * rule — no copyable illustrative example. Answered with a single word.
 */
export function buildContradictionClassifierPrompt(earlier: string, later: string): string {
  return (
    `Two statements by the SAME user conflict. Decide which KIND of conflict this is.\n\n` +
    `EARLIER value: ${earlier}\n` +
    `LATER value: ${later}\n\n` +
    `Answer EVOLUTION if the user CHANGED THEIR OWN position, opinion, preference, stance, or relationship over time — ` +
    `both were genuine at the time they were said, and the view simply moved.\n` +
    `Answer ERROR if the earlier value was simply a WRONG fact now being corrected — ` +
    `a mistaken world-fact or spec, or a flat "no, that is wrong, it is actually <value>" fix where the earlier value was never a real position.\n\n` +
    `Answer with EXACTLY one word: EVOLUTION or ERROR.`
  );
}

/**
 * Parse a classifier reply to a {@link ContradictionKind}. Defaults to
 * `"evolution"` — the NON-DESTRUCTIVE branch (keep the history) — unless the reply
 * unambiguously says ERROR, so an ambiguous answer never silently destroys a
 * genuine trajectory. Pure.
 */
export function classifyContradiction(raw: string): ContradictionKind {
  const t = (raw ?? "").toLowerCase();
  if (/\berror\b/.test(t) && !/\bevolution\b/.test(t)) return "error";
  return "evolution";
}

/** True when the article already has a `## History` section. Pure. */
export function hasHistorySection(article: string): boolean {
  return article.split("\n").some((l) => HISTORY_HEADING_RE.test(l.trim()));
}

/** A `[^k]` suffix for a marker number, or `""` when none is known. */
function markerSuffix(n: number | null | undefined): string {
  return n != null ? `[^${n}]` : "";
}

/**
 * Build ONE History trajectory line preserving BOTH sources' citation markers:
 * the earlier position (past) carries `[^earlierMarker]`, the later/current one
 * carries `[^laterMarker]`, so no provenance is lost. Both values are real article
 * data, not copyable example values. Pure.
 */
export function buildHistoryEntry(opts: {
  earlier: string;
  earlierMarker?: number | null;
  later: string;
  laterMarker?: number | null;
  laterDate?: string | null;
}): string {
  const when =
    opts.laterDate && opts.laterDate !== "undated" ? `as of ${opts.laterDate}` : "now";
  return (
    `- Previously ${opts.earlier.trim()}${markerSuffix(opts.earlierMarker)}; ` +
    `${when} ${opts.later.trim()}${markerSuffix(opts.laterMarker)}.`
  );
}

/**
 * Insert `entry` into the article's `## History` section, creating the section
 * (just before `## See also` / `## References`, never after the references) when
 * it is absent. Idempotent for an identical entry already present — never
 * duplicates a line. Pure.
 */
export function upsertHistoryEntry(article: string, entry: string): string {
  const trimmedEntry = entry.trim();
  const lines = article.replace(/\s+$/, "").split("\n");

  const headingIdx = lines.findIndex((l) => HISTORY_HEADING_RE.test(l.trim()));
  if (headingIdx >= 0) {
    // Find the end of the existing History block (next heading, or EOF).
    let end = lines.length;
    for (let i = headingIdx + 1; i < lines.length; i++) {
      if (/^#{1,6}\s+/.test(lines[i]!.trim())) {
        end = i;
        break;
      }
    }
    const block = lines.slice(headingIdx + 1, end);
    if (block.some((l) => l.trim() === trimmedEntry)) {
      return article; // already recorded — idempotent
    }
    // Append after the last non-blank line of the block.
    let last = end - 1;
    while (last > headingIdx && lines[last]!.trim() === "") last--;
    const next = [...lines.slice(0, last + 1), trimmedEntry, "", ...lines.slice(end)];
    return next.join("\n") + "\n";
  }

  // No History section yet — insert one before See also / References.
  const tailIdx = lines.findIndex((l) => /^##\s+(see also|references)\s*$/i.test(l.trim()));
  const section = [`## ${HISTORY_TITLE}`, "", trimmedEntry, ""];
  if (tailIdx < 0) return [...lines, "", ...section].join("\n") + "\n";
  return [...lines.slice(0, tailIdx), ...section, ...lines.slice(tailIdx)].join("\n") + "\n";
}

/**
 * The `[^N]` marker number that CITES `value`, so a resolve can preserve the right
 * source when it moves a value into History. By the citation-after-claim
 * convention the marker follows the claim, so we take the FIRST marker at/after the
 * value's first occurrence; failing that, the nearest marker before it. Returns
 * null when `value` carries no nearby marker. Pure.
 */
export function markerNear(text: string, value: string): number | null {
  const v = value.trim().toLowerCase();
  if (!v) return null;
  const idx = text.toLowerCase().indexOf(v);
  if (idx < 0) return null;
  // First marker AT/AFTER the value (the citation follows the claim).
  const after = text.slice(idx).match(/\[\^(\d+)\]/);
  if (after) return parseInt(after[1]!, 10);
  // Fallback: the LAST marker before the value.
  const before = [...text.slice(0, idx).matchAll(/\[\^(\d+)\]/g)];
  const last = before[before.length - 1];
  return last ? parseInt(last[1]!, 10) : null;
}

/** Re-export so callers can name the lead target without reaching into cluster. */
export { LEAD_ANCHOR };
