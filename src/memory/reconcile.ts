// mlx-bun memory — RECONCILE pass (P7-T3): make an article internally consistent
// with its latest-dated position AFTER a self-healing fold.
//
// A targeted PATCH resolves ONE claim toward the user's newest statement — it
// flips the LEAD (the verdict) to the current value. But the rest of the article
// can be left contradicting that verdict: an INFOBOX relationship field still
// records the superseded value (`<preference_key>: <old value>` while the lead now
// says `<new value>`), and a sibling BODY section still asserts the old take. This pass
// runs AFTER the patch loop, scans those surfaces, and updates whatever the fold
// made stale so the whole article ends consistent with the latest position.
//
// It is the same discipline as PATCH: every edit goes through NORMALIZE + the
// conservative gate, and it is PROVENANCE-PRESERVING — a section rewrite keeps
// every pre-existing `[^k]` marker (phrased as a change over time), so the gate's
// citation-survival check passes instead of NO-OP'ing the fold. It is bounded
// (only relationship infobox fields + body sections are touched; world-fact / spec
// fields are left alone) and idempotent: a fully-consistent article is a NO-OP.

import { readFile, writeFile } from "node:fs/promises";
import { join } from "node:path";

import { articleStructure, fenceLabel, isFenceLine, parseInfobox, parseLead } from "./article";
import { articleTitle } from "./cluster";
import type { MemoryStore } from "./db";
import { gateEdit } from "./gate";
import {
  buildContradictionClassifierPrompt,
  buildHistoryEntry,
  classifyContradiction,
  type ContradictionKind,
  markerNear,
  upsertHistoryEntry,
} from "./history";
import { callLocal } from "./model";
import { normalizeArticle } from "./normalize";
import {
  articleFootnoteState,
  entityStem,
  MAX_OUTPUT_TOKENS,
  PHYSICAL_SPEC_KEYS,
  referenceDatesByMarker,
  sanitizeLead,
  sanitizeSection,
  type SynthesisCall,
} from "./synthesize";
import { articlesDir, commitVault, extractSection, listArticles, slugifyHeading, vaultRoot } from "./vault";

// ---- relationship-field classification -------------------------------------

/** Infobox keys we NEVER touch — schema keys plus the physical spec keys (a
 *  spec is a world-fact, not a stance that a verdict can supersede). */
const RECONCILE_SKIP_KEYS = new Set(["type", "kind", "aliases", "categories"]);

/** A relationship/opinion key whose value records the user's stance — the only
 *  infobox fields a verdict change can make stale (favorite / opinion / status /
 *  preference / current pick …). World-fact + spec keys are excluded above. */
const RELATIONSHIP_KEY_RE =
  /(favou?rite|prefer|preference|pick|choice|chosen|opinion|verdict|status|stance|current|rating|sentiment|\btake\b|likes?|dislikes?|using|used_for|owns?|owned|acquired)/i;

/** True when an infobox field is a relationship/stance fact (refreshable), not a
 *  world-fact or physical spec (left untouched). */
export function isRelationshipKey(key: string): boolean {
  const k = key.trim().toLowerCase();
  if (RECONCILE_SKIP_KEYS.has(k)) return false;
  if (PHYSICAL_SPEC_KEYS.has(k)) return false;
  return RELATIONSHIP_KEY_RE.test(k);
}

// ---- prompt builders (schematic — no parrot-able concrete values) ----------

/** The model sentinel for "this fact already agrees with the summary". */
export const RECONCILE_KEEP = "KEEP";

/** Check ONE infobox relationship fact against the current verdict (the lead). The
 *  model answers KEEP when it agrees, or the corrected VALUE (no key, no prose)
 *  when it is stale. Schematic on purpose. */
export function buildInfoboxReconcilePrompt(verdict: string, key: string, value: string): string {
  return (
    `You are checking ONE infobox fact against the article's current summary for internal consistency.\n\n` +
    `CURRENT SUMMARY (the user's latest position):\n${verdict}\n\n` +
    `INFOBOX FACT:\n${key}: ${value}\n\n` +
    `If the fact AGREES with the current summary, answer exactly ${RECONCILE_KEEP}. ` +
    `If it CONTRADICTS the summary (it records a preference, opinion, or status the summary has since changed), ` +
    `answer with the corrected VALUE only — the single value that matches the summary, no key, no prose, no quotes.`
  );
}

/** Detection (used only for a ground-truth field with no KNOWN superseded value):
 *  does this passage state, as the user's CURRENT choice, a value that DIFFERS
 *  from the established current value? Answer KEEP, or that different value only. */
export function buildProseConflictPrompt(label: string, groundTruth: string, body: string): string {
  return (
    `ESTABLISHED CURRENT VALUE: ${groundTruth}\n\n` +
    `${label}:\n${body || "(empty)"}\n\n` +
    `Does this passage state, as the user's CURRENT / present choice, a value DIFFERENT from ${groundTruth}? ` +
    `If it states only ${groundTruth} as current (any other value appears solely as past history), answer exactly ${RECONCILE_KEEP}. ` +
    `Otherwise answer with that different current value ONLY — no key, no prose, no quotes.`
  );
}

/**
 * The CONSTRAINED consistency rewrite — the safety net that guarantees the prose
 * agrees with the infobox GROUND TRUTH. Both values are real article data (the
 * resolved current value + the value it replaced), not copyable example values:
 * we tell the model exactly which value is current and which is former, so the
 * small model only has to demote the named superseded value to past tense — far
 * more reliable than the open-ended "resolve toward latest" fold. Every existing
 * `[^k]` marker is preserved (provenance), framed as a change over time.
 */
export function buildProseConsistencyPrompt(
  label: string,
  groundTruth: string,
  superseded: string,
  body: string,
): string {
  return (
    `You are correcting ONE passage of a personal-wiki article so it agrees with the article's ESTABLISHED CURRENT fact.\n\n` +
    `ESTABLISHED CURRENT VALUE: ${groundTruth}\n` +
    `FORMER (SUPERSEDED) VALUE: ${superseded}\n\n` +
    `${label}:\n${body || "(empty)"}\n\n` +
    `Rewrite the passage so it reads as a change OVER TIME: state ${superseded} ONLY in the past tense ` +
    `("previously ${superseded}", "originally ${superseded}", "${superseded} was"), and state ${groundTruth} as the user's CURRENT, present choice. ` +
    `${superseded} must NEVER appear as a current/present favourite, pick, or "the one I reach for". ` +
    `Keep EVERY existing [^k] citation marker: attach the ${superseded} marker to the past clause and the ${groundTruth} marker to the present clause, so no [^N] is lost. ` +
    `Prefer ONE flowing statement — "previously ${superseded}[^k]; now ${groundTruth} is my current pick[^n]". ` +
    `Output ONLY the rewritten passage prose — no heading, no list, no References section.`
  );
}

/**
 * The CURRENT-STATE-ONLY rewrite. Used for the LEAD (which must read as a clean
 * current-state summary — never scattered "previously …" caveats) and for a
 * factual-ERROR fix in any passage (the wrong value is removed as if it had never
 * been there). The passage is rewritten to state ONLY `groundTruth` as current and
 * to DROP `superseded` entirely. For an evolution the dropped value's trajectory
 * is recorded in the article's `## History` section instead; for an error it is
 * simply gone. Both values are real article data, not copyable example values.
 */
export function buildCurrentStateOnlyPrompt(
  label: string,
  groundTruth: string,
  superseded: string,
  body: string,
  isError: boolean,
): string {
  const why = isError
    ? `The value ${superseded} was a MISTAKE — a wrong fact. Remove it entirely; it must NOT appear anywhere in the passage (no "previously", no history). ` +
      `You may drop ${superseded}'s citation marker.`
    : `Do NOT mention ${superseded} in this passage — its trajectory is recorded separately in the History section. ` +
      `Keep ${groundTruth}'s [^k] citation marker.`;
  return (
    `You are rewriting ONE passage of a personal-wiki article to state ONLY the user's CURRENT value.\n\n` +
    `CURRENT VALUE: ${groundTruth}\n` +
    `VALUE TO REMOVE: ${superseded}\n\n` +
    `${label}:\n${body || "(empty)"}\n\n` +
    `Rewrite the passage so it states ${groundTruth} as the user's current, present value, in the present tense. ` +
    `${why} ` +
    `Output ONLY the rewritten passage prose — no heading, no list, no References section.`
  );
}

/** Sharper retry instruction when the first rewrite still asserts the superseded
 *  value as current. */
export function proseRetryHint(groundTruth: string, superseded: string): string {
  return (
    `STILL WRONG: the passage must NOT claim ${superseded} is current, now, or a favourite. ` +
    `The ONLY current value is ${groundTruth}. Write ${superseded} strictly as a FORMER value ("previously ${superseded}[^k]"), ` +
    `and ${groundTruth} as the present one ("now ${groundTruth}[^n]"). Demote ${superseded} to the past tense.`
  );
}

// ---- pure helpers ----------------------------------------------------------

/** Distinct `[^N]` markers in a block (definition lines excluded). */
function markersIn(body: string): number[] {
  const out: number[] = [];
  const seen = new Set<number>();
  for (const line of body.split("\n")) {
    if (/^\[\^\d+\]:/.test(line.trim())) continue;
    for (const m of line.matchAll(/\[\^(\d+)\]/g)) {
      const n = parseInt(m[1]!, 10);
      if (!seen.has(n)) {
        seen.add(n);
        out.push(n);
      }
    }
  }
  return out;
}

/** Escape a literal string for embedding in a RegExp. */
function escapeRe(s: string): string {
  return s.replace(/[.*+?^${}()|[\]\\]/g, "\\$&");
}

/** Past-tense framing cues — when one governs the clause that mentions a value,
 *  the value reads as HISTORY, not a present assertion. Deliberately EXCLUDES
 *  "currently"/"now"/"today" (those are PRESENT, the very thing we flag). */
const PAST_FRAME_RE =
  /\b(previous|origin|earlier|used to|no longer|formerly|initial|at first|back then|before|had been|until|supersed|was|were|moved on|switched)\b/i;

/**
 * True when `value` is asserted as the user's CURRENT / present choice somewhere
 * in `text` and that clause is NOT framed as past. A "clause" is a span between
 * sentence / `;` breaks, so "previously <old>[^1]; now <new>[^2]" reads the <old>
 * clause as history (past-framed) and is NOT flagged. This is the deterministic
 * detector AND the post-rewrite acceptance check the retry hinges on. Pure.
 */
export function assertsValueAsCurrent(text: string, value: string): boolean {
  const t = text.toLowerCase();
  const v = value.trim().toLowerCase();
  if (!v || !t.includes(v)) return false;
  const ev = escapeRe(v);
  const present = new RegExp(
    `(${ev}[^.;!?]{0,60}\\b(is|are|remain|stay|favou?rite|prefer|reach for|number-one|pick|go-to|current|now)\\b)|` +
      `(\\b(favou?rite|prefer|current(ly)?|now|pick|reach for|go-to|reach|consider)\\b[^.;!?]{0,60}${ev})`,
  );
  for (const clause of t.split(/[.;!?]+/)) {
    if (!clause.includes(v)) continue;
    if (!present.test(clause)) continue;
    if (PAST_FRAME_RE.test(clause)) continue; // framed as history → fine
    return true; // present-tense, not past-framed → stale
  }
  return false;
}

/** Collapse adjacent duplicate footnote markers (`[^2][^2]` or `[^2] [^2]` →
 *  `[^2]`) — the lead artifact a fold can leave. Pure. */
export function dedupeAdjacentMarkers(text: string): string {
  return text.replace(/(\[\^\d+\])(\s*\1)+/g, "$1");
}

/** Strip a model value reply to a clean single-line value (drop quotes, a stray
 *  echoed `key:` prefix, surrounding markup). */
function cleanValue(raw: string, key: string): string {
  let v = raw.split("\n").map((l) => l.trim()).find((l) => l.length > 0) ?? "";
  v = v.replace(new RegExp(`^${key}\\s*:`, "i"), "").trim();
  v = v.replace(/^[-*+]\s+/, "").replace(/^["'`]+|["'`.]+$/g, "").trim();
  return v;
}

/** Replace the value of one `key:` line inside the article's fenced ```info block.
 *  Returns the article unchanged when the key is absent. Pure. */
export function setInfoboxFieldValue(content: string, key: string, newValue: string): string {
  const lines = content.split(/\r?\n/);
  let inInfo = false;
  for (let i = 0; i < lines.length; i++) {
    const line = lines[i]!;
    if (isFenceLine(line)) {
      if (!inInfo && fenceLabel(line) === "info") inInfo = true;
      else if (inInfo) break; // closing fence — leave the info block
      continue;
    }
    if (inInfo) {
      const idx = line.indexOf(":");
      if (idx > 0 && line.slice(0, idx).trim() === key) {
        lines[i] = `${key}: ${newValue}`;
        return lines.join("\n");
      }
    }
  }
  return content;
}

// ---- the reconcile core (pure w.r.t. disk) ---------------------------------

export interface ReconcileDeps {
  /** Model call; defaults to `callLocal("synthesis", …)`. */
  call?: SynthesisCall;
  /** Other article stems (wikilink resolution in NORMALIZE). */
  stems?: Set<string>;
  /** Article stem (H1/NORMALIZE); defaults to the entity stem of the H1 title. */
  stem?: string;
}

export interface ReconcileResult {
  content: string;
  changed: boolean;
  /** Infobox keys whose value was refreshed to the current verdict. */
  refreshedFields: string[];
  /** Passage labels rewritten toward the ground-truth value (`lead` + section anchors). */
  rewrittenSections: string[];
  /** True when NORMALIZE+gate vetoed the reconciled article (kept the original). */
  gateVetoed: boolean;
  reason: string | null;
  normalizeNotes: string[];
  /** Passage labels where, even after the retry, the small model could NOT demote
   *  the superseded value to past tense (left as the gate-vetoed original). Logged
   *  honestly — these are a base-model limit, not a silent success. */
  unresolved: string[];
  /** True when at least one passage rewrite needed the sharper retry. */
  retried: boolean;
  /** Trajectory lines written to the `## History` section for EVOLUTION
   *  corrections (the user's position changing over time). Empty when every
   *  contradiction was a factual error (silently overwritten, no History). */
  historyEntries: string[];
}

/** One prose-passage to reconcile: the LEAD or a body section. */
interface Passage {
  /** Stable label for `rewrittenSections` / logs (`lead` or the section anchor). */
  label: string;
  /** Current passage body (no heading). */
  body: string;
  /** Sanitizer for a model rewrite (section vs lead). */
  sanitize: (raw: string) => string;
  /** Splice a rewritten body back into the article. */
  write: (article: string, newBody: string) => string;
}

/** Collect the reconcilable prose passages (lead + every body section, skipping
 *  References / See also / Notes) with the helpers to read+write each. */
function collectPassages(article: string): Passage[] {
  const out: Passage[] = [];
  const items = articleStructure(article);

  const lead = items.find((it) => it.kind === "lead");
  if (lead) {
    const lines = article.split("\n");
    const start = lead.startLine - 1;
    const end = lead.endLine - 1;
    const body = lines.slice(start, end + 1).join("\n").trim();
    if (body) {
      out.push({
        label: "lead",
        body,
        sanitize: sanitizeLead,
        write: (a, nb) => {
          const ls = a.split("\n");
          return [...ls.slice(0, start), nb, ...ls.slice(end + 1)].join("\n");
        },
      });
    }
  }

  for (const item of items) {
    if (item.kind !== "section" || !item.title) continue;
    const anchor = slugifyHeading(item.title);
    const block = extractSection(article, anchor);
    if (block == null) continue;
    const headingLine = block.split("\n")[0] ?? `## ${item.title}`;
    const body = block.split("\n").slice(1).join("\n").trim();
    if (!body) continue;
    const title = item.title;
    out.push({
      label: anchor,
      body,
      sanitize: (raw) => sanitizeSection(raw, title),
      write: (a, nb) => {
        const cur = extractSection(a, anchor);
        if (cur == null) return a;
        const idx = a.indexOf(cur);
        if (idx < 0) return a;
        return a.slice(0, idx) + `${headingLine}\n\n${nb}\n` + a.slice(idx + cur.length);
      },
    });
  }
  return out;
}

/** Outcome of one constrained passage rewrite. */
interface PassageFix {
  body: string;
  changed: boolean;
  retried: boolean;
  /** True when the small model still left the superseded value as current AFTER
   *  the retry (or dropped a marker) — kept the original; report honestly. */
  unresolved: boolean;
}

/**
 * Make ONE passage agree that `groundTruth` is current and `superseded` is former.
 * No-op when the passage does not assert `superseded` as current (idempotent).
 * Otherwise: constrained rewrite → deterministic check → ONE sharper retry; if it
 * still asserts the stale value as current OR would drop a `[^k]` marker, keep the
 * original and flag `unresolved`. Markers are deduped; provenance is preserved.
 */
async function reconcileOnePassage(
  call: SynthesisCall,
  passage: Passage,
  groundTruth: string,
  superseded: string,
): Promise<PassageFix> {
  const keep: PassageFix = { body: passage.body, changed: false, retried: false, unresolved: false };
  if (!superseded || !groundTruth || superseded.toLowerCase() === groundTruth.toLowerCase()) return keep;
  if (!assertsValueAsCurrent(passage.body, superseded)) return keep; // already clean / absent

  const before = new Set(markersIn(passage.body));
  const attempt = async (prompt: string): Promise<string> => {
    const raw = await call(prompt, { maxTokens: MAX_OUTPUT_TOKENS });
    return dedupeAdjacentMarkers(passage.sanitize(raw)).trim();
  };
  const accept = (x: string): boolean => {
    if (!x) return false;
    if (assertsValueAsCurrent(x, superseded)) return false; // still asserts stale value as current
    const after = new Set(markersIn(x));
    return ![...before].some((m) => !after.has(m)); // every marker preserved (provenance)
  };

  const base = buildProseConsistencyPrompt(passage.label, groundTruth, superseded, passage.body);
  let body = await attempt(base);
  if (accept(body)) return { body, changed: true, retried: false, unresolved: false };

  body = await attempt(`${base}\n\n${proseRetryHint(groundTruth, superseded)}`);
  if (accept(body)) return { body, changed: true, retried: true, unresolved: false };

  return { ...keep, retried: true, unresolved: true }; // base-model limit — keep original
}

/**
 * Make ONE passage state ONLY `groundTruth` as current and DROP `superseded`
 * entirely (the LEAD path, and the factual-ERROR path). No-op when the passage
 * does not mention `superseded`. Otherwise: constrained rewrite → deterministic
 * check (superseded gone, groundTruth present) → ONE sharper retry; if it still
 * mentions `superseded`, keep the original and flag `unresolved`. For an evolution
 * the dropped value's `[^k]` is preserved in the History section (added by the
 * caller); for an error it is allowed to fall away.
 */
async function reconcileOnePassageCurrentState(
  call: SynthesisCall,
  passage: Passage,
  groundTruth: string,
  superseded: string,
  isError: boolean,
): Promise<PassageFix> {
  const keep: PassageFix = { body: passage.body, changed: false, retried: false, unresolved: false };
  if (!superseded || !groundTruth || superseded.toLowerCase() === groundTruth.toLowerCase()) return keep;
  if (!passage.body.toLowerCase().includes(superseded.toLowerCase())) return keep; // already clean

  const attempt = async (prompt: string): Promise<string> => {
    const raw = await call(prompt, { maxTokens: MAX_OUTPUT_TOKENS });
    return dedupeAdjacentMarkers(passage.sanitize(raw)).trim();
  };
  const accept = (x: string): boolean => {
    if (!x) return false;
    if (x.toLowerCase().includes(superseded.toLowerCase())) return false; // value not removed
    return x.toLowerCase().includes(groundTruth.toLowerCase()); // current value present
  };

  const base = buildCurrentStateOnlyPrompt(passage.label, groundTruth, superseded, passage.body, isError);
  let body = await attempt(base);
  if (accept(body)) return { body, changed: true, retried: false, unresolved: false };

  body = await attempt(`${base}\n\n${proseRetryHint(groundTruth, superseded)}`);
  if (accept(body)) return { body, changed: true, retried: true, unresolved: false };

  return { ...keep, retried: true, unresolved: true };
}

/**
 * Reconcile ONE article to its INFOBOX GROUND TRUTH. The infobox relationship
 * value is the authority (it is resolved first, against the lead verdict): once
 * resolved, the LEAD and EVERY body section must AGREE with it. We refresh stale
 * infobox fields, then for each passage that still asserts a SUPERSEDED value as
 * current we run a CONSTRAINED rewrite ("make <ground-truth> current and <old>
 * past") with a deterministic check + one retry — far more reliable for the small
 * model than the open-ended fold. Every rewrite is provenance-preserving (keeps
 * its `[^k]` markers, dedupes duplicates). Runs NORMALIZE + the gate; a veto keeps
 * the original. A consistent article is a byte-identical NO-OP. Pure w.r.t. disk.
 */
export async function reconcileContent(article: string, deps: ReconcileDeps = {}): Promise<ReconcileResult> {
  const call: SynthesisCall = deps.call ?? ((p, o) => callLocal("synthesis", { user: p }, o));
  const title = articleTitle(article, deps.stem ?? "");
  const stem = deps.stem ?? entityStem(title);
  const stems = new Set(deps.stems ?? []);
  stems.add(stem);

  const noop: ReconcileResult = {
    content: article,
    changed: false,
    refreshedFields: [],
    rewrittenSections: [],
    gateVetoed: false,
    reason: null,
    normalizeNotes: [],
    unresolved: [],
    retried: false,
    historyEntries: [],
  };

  // The verdict — the latest-dated position — lives in the LEAD. With no lead
  // there is nothing to resolve the infobox against.
  const verdict = parseLead(article);
  if (!verdict || !verdict.trim()) return { ...noop, reason: "no lead verdict to reconcile against" };

  let next = article;
  const refreshedFields: string[] = [];
  const rewrittenSections: string[] = [];
  const unresolved: string[] = [];
  let retried = false;

  // Provenance lookups read from the ORIGINAL article (markers/hashes/dates are
  // stable there before any rewrite moves them around). Markers are found in the
  // PROSE only — the infobox value precedes the body, so scanning it would mis-
  // attribute a value to the lead's citation.
  const prose = article.replace(/```info[\s\S]*?```/i, "");
  const refDates = referenceDatesByMarker(article);
  const fnState = articleFootnoteState(article);
  const hashByMarker = new Map<number, string>();
  for (const [h, n] of fnState.byHash) hashByMarker.set(n, h);

  // (1) INFOBOX relationship fields — resolve any that contradict the verdict.
  // Each resolved field carries a GROUND-TRUTH value; a refreshed one also yields a
  // KNOWN superseded (old) value, the precise correction to propagate into the prose.
  // CLASSIFY each contradiction: a relationship/opinion/stance the user CHANGED over
  // time is an EVOLUTION (keep the trajectory in `## History`); a wrong world-fact /
  // spec is an ERROR (silently overwrite, prune the wrong value entirely).
  interface Correction {
    groundTruth: string;
    superseded: string;
    kind: ContradictionKind;
    earlierMarker: number | null;
    laterMarker: number | null;
    laterDate: string | null;
  }
  const corrections: Correction[] = [];
  const groundTruthOnly: string[] = []; // resolved values with no known old value (KEEP)
  const box = parseInfobox(article);
  if (box) {
    for (const f of box.fields) {
      if (!isRelationshipKey(f.key)) continue; // world-fact / spec → untouched
      const old = f.value.trim();
      const reply = await call(buildInfoboxReconcilePrompt(verdict, f.key, f.value), { maxTokens: 48 });
      const cleaned = cleanValue(reply, f.key);
      if (cleaned && !/^keep$/i.test(cleaned) && cleaned !== old) {
        next = setInfoboxFieldValue(next, f.key, cleaned);
        refreshedFields.push(f.key);
        const kind = classifyContradiction(
          await call(buildContradictionClassifierPrompt(old, cleaned), { maxTokens: 8 }),
        );
        const earlierMarker = markerNear(prose, old);
        const laterMarker = markerNear(prose, cleaned);
        corrections.push({
          groundTruth: cleaned,
          superseded: old,
          kind,
          earlierMarker,
          laterMarker,
          laterDate: laterMarker != null ? refDates.get(laterMarker) ?? null : null,
        });
      } else {
        groundTruthOnly.push(old); // already current — superseded value unknown
      }
    }
  }

  // (2) PROSE — the LEAD and every body section must agree with the ground truth.
  // The LEAD is held to a CLEAN CURRENT-STATE summary (no "previously …" caveats);
  // an ERROR correction strips the wrong value from EVERY passage; an EVOLUTION
  // keeps the body's in-context trajectory and consolidates it into `## History`.
  for (const passage of collectPassages(next)) {
    let body = passage.body;
    let touched = false;
    const isLead = passage.label === "lead";

    // (2a) KNOWN corrections (infobox refresh old→new): deterministic + reliable.
    for (const corr of corrections) {
      const live: Passage = { ...passage, body };
      const currentStateOnly = isLead || corr.kind === "error";
      const fix = currentStateOnly
        ? await reconcileOnePassageCurrentState(call, live, corr.groundTruth, corr.superseded, corr.kind === "error")
        : await reconcileOnePassage(call, live, corr.groundTruth, corr.superseded);
      retried ||= fix.retried;
      if (fix.unresolved) unresolved.push(passage.label);
      if (fix.changed) {
        body = fix.body;
        touched = true;
      }
    }

    // (2b) Ground-truth fields the infobox already had right (no known old value):
    // ask the model whether the prose names a DIFFERENT value as current, then run
    // the same constrained rewrite. Guarded by the deterministic check so a model
    // hallucination cannot trigger a needless rewrite.
    for (const gt of groundTruthOnly) {
      const detect = cleanValue(
        await call(buildProseConflictPrompt(passage.label, gt, body), { maxTokens: 24 }),
        "",
      );
      if (!detect || /^keep$/i.test(detect) || detect.toLowerCase() === gt.toLowerCase()) continue;
      const live: Passage = { ...passage, body };
      const fix = await reconcileOnePassage(call, live, gt, detect);
      retried ||= fix.retried;
      if (fix.unresolved) unresolved.push(passage.label);
      if (fix.changed) {
        body = fix.body;
        touched = true;
      }
    }

    if (touched && body !== passage.body) {
      next = passage.write(next, body);
      rewrittenSections.push(passage.label);
    }
  }

  // (3) HISTORY — for EVOLUTION corrections, PRESERVE the trajectory in a
  // `## History` section (we keep the history). For ERROR corrections, the wrong
  // value's citation may have been pruned everywhere — allow the gate to drop it.
  const historyEntries: string[] = [];
  const allowDroppedHashes = new Set<string>();
  for (const corr of corrections) {
    if (corr.kind === "evolution") {
      const entry = buildHistoryEntry({
        earlier: corr.superseded,
        earlierMarker: corr.earlierMarker,
        later: corr.groundTruth,
        laterMarker: corr.laterMarker,
        laterDate: corr.laterDate,
      });
      const withHistory = upsertHistoryEntry(next, entry);
      if (withHistory !== next) {
        next = withHistory;
        historyEntries.push(entry);
      }
    } else if (corr.earlierMarker != null) {
      // A factual error: the wrong value (and only it) is allowed to lose its cite.
      const h = hashByMarker.get(corr.earlierMarker);
      if (h) allowDroppedHashes.add(h);
    }
  }

  if (!refreshedFields.length && !rewrittenSections.length && !historyEntries.length) {
    return { ...noop, unresolved, retried }; // already consistent (or unrepairable)
  }

  // NORMALIZE then the conservative gate over (original, reconciled).
  const norm = normalizeArticle(next, { stem, stems });
  if (norm.content === article) return { ...noop, normalizeNotes: norm.notes, unresolved, retried };
  const verdictGate = gateEdit(article, norm.content, { allowDroppedHashes });
  if (!verdictGate.ok) {
    return { ...noop, gateVetoed: true, reason: verdictGate.reason, normalizeNotes: norm.notes, unresolved, retried };
  }

  return {
    content: norm.content,
    changed: true,
    refreshedFields,
    rewrittenSections,
    gateVetoed: false,
    reason: null,
    normalizeNotes: norm.notes,
    unresolved,
    retried,
    historyEntries,
  };
}

// ---- effectful entry: reconcile a vault article + ledger -------------------

export interface ReconcileArticleOpts {
  /** Vault root (honors MLX_BUN_WIKI); defaults to `vaultRoot()`. */
  root?: string;
  /** Model-call override (tests inject a fake). */
  call?: SynthesisCall;
  /** Skip the git commit (tests). */
  commit?: boolean;
  now?: number;
}

export interface ReconcileArticleResult {
  stem: string;
  reconciled: boolean;
  refreshedFields: string[];
  rewrittenSections: string[];
  gateVetoed: boolean;
  reason: string | null;
  /** Passages the model could not demote even after the retry (honest reporting). */
  unresolved: string[];
  /** True when at least one rewrite needed the sharper retry. */
  retried: boolean;
}

/**
 * Reconcile a vault article on disk and persist it: read the file, run
 * {@link reconcileContent}, write back + record a `reconciled_articles` ledger row
 * when it changed, and commit (unless suppressed). A consistent article writes
 * nothing. Used by SYNTHESIZE after the PATCH loop for every article it touched.
 */
export async function reconcileArticle(
  store: MemoryStore,
  stem: string,
  opts: ReconcileArticleOpts = {},
): Promise<ReconcileArticleResult> {
  const root = opts.root ?? vaultRoot();
  const base: ReconcileArticleResult = {
    stem,
    reconciled: false,
    refreshedFields: [],
    rewrittenSections: [],
    gateVetoed: false,
    reason: null,
    unresolved: [],
    retried: false,
  };

  const path = join(articlesDir(root), `${stem}.md`);
  let article: string;
  try {
    article = await readFile(path, "utf8");
  } catch {
    return { ...base, reason: `article not found: ${stem}` };
  }

  const stems = new Set(await listArticles(root));
  const res = await reconcileContent(article, { call: opts.call, stems, stem });
  if (!res.changed) {
    return { ...base, gateVetoed: res.gateVetoed, reason: res.reason, unresolved: res.unresolved, retried: res.retried };
  }

  await writeFile(path, res.content);

  const now = opts.now ?? Date.now();
  store.db
    .query(
      "INSERT OR REPLACE INTO reconciled_articles (article_stem, reconciled_at, refreshed, rewritten) VALUES (?,?,?,?)",
    )
    .run(stem, now, res.refreshedFields.join(","), res.rewrittenSections.join(","));

  if (opts.commit !== false) {
    await commitVault(
      root,
      `memory: reconcile ${stem} (${res.refreshedFields.length} field(s), ${res.rewrittenSections.length} section(s))`,
    );
  }

  return {
    ...base,
    reconciled: true,
    refreshedFields: res.refreshedFields,
    rewrittenSections: res.rewrittenSections,
    unresolved: res.unresolved,
    retried: res.retried,
  };
}
