// mlx-bun memory — the conservative write gate.
//
// The Dreaming write pipeline patches articles section-by-section. Before any
// synthesized edit is committed to the vault, it passes through this gate: a
// deterministic, GPU-free check that the edit PRESERVED the existing article
// rather than degrading it. A weak pass is a NO-OP — the caller discards the
// model's output and leaves the vault byte-for-byte unchanged.
//
// This is a faithful port of Lucien's editorial gate (scripts/wikify.ts:
// verifyEditorialResult / checkFootnoteIntegrity / extractConvHashes). It
// catches citation loss, structural loss, footnote-bijection breaks, and gross
// prose deletion. It does NOT catch nuance loss — that is the cloud judge's job.
// The gate is mechanism, not policy: it can only reject, never rewrite.

// ---- citation hashes --------------------------------------------------

// Illustrative placeholder hashes the synthesis prompt warns against; never
// real citations, so excluded from the preservation set.
const SPEC_HASHES = new Set(["00000000", "00000001"]);

/** All real `conv:HASH` citation hashes in `text`, lowercased, minus the
 *  documented spec placeholders. A `conv:` hash is exactly 8 lowercase
 *  hex-ish chars `[0-9a-z]` (matched case-insensitively, then lowered). */
export function extractConvHashes(text: string): Set<string> {
  const out = new Set<string>();
  for (const m of text.matchAll(/conv:([0-9a-z]{8})/gi)) {
    const h = m[1]!.toLowerCase();
    if (!SPEC_HASHES.has(h)) out.add(h);
  }
  return out;
}

// ---- footnote integrity ----------------------------------------------

export interface CheckResult {
  ok: boolean;
  /** Human-readable violations; empty when `ok`. */
  errors: string[];
}

/**
 * Verify footnote markers and definitions form a clean bijection:
 * - every `[^N]` body marker has a matching `[^N]:` definition and vice versa;
 * - marker/definition numbers are contiguous from 1;
 * - every definition line carries exactly one backticked `conv:HASH`.
 *
 * Only a line-START `[^N]:` is a definition. A body marker glued to a
 * list-introducing colon (`...two types[^2]:`) is still a marker, so we strip
 * definition lines before scanning for markers rather than excluding any
 * `[^N]` followed by `:`.
 */
export function checkFootnoteIntegrity(text: string): CheckResult {
  const errors: string[] = [];

  // Definition lines: `[^N]: ...` at line start.
  const defNums = new Set<number>();
  const defLineByNum = new Map<number, string>();
  const defSeen = new Set<number>();
  for (const m of text.matchAll(/^\[\^(\d+)\]:(.*)$/gm)) {
    const n = parseInt(m[1]!, 10);
    if (defSeen.has(n)) errors.push(`definition [^${n}] is duplicated`);
    defSeen.add(n);
    defNums.add(n);
    defLineByNum.set(n, m[2]!);
  }

  // Body markers: every `[^N]` outside a definition line.
  const bodyText = text
    .split("\n")
    .filter((l) => !/^\[\^\d+\]:/.test(l))
    .join("\n");
  const markerNums = new Set<number>();
  for (const m of bodyText.matchAll(/\[\^(\d+)\]/g)) {
    markerNums.add(parseInt(m[1]!, 10));
  }

  for (const n of markerNums) {
    if (!defNums.has(n)) errors.push(`marker [^${n}] has no definition`);
  }
  for (const n of defNums) {
    if (!markerNums.has(n)) errors.push(`definition [^${n}] has no marker`);
  }

  const all = [...new Set([...markerNums, ...defNums])].sort((a, b) => a - b);
  for (let i = 0; i < all.length; i++) {
    if (all[i] !== i + 1) {
      errors.push(`footnote numbers not contiguous from 1 (saw ${all.join(",")})`);
      break;
    }
  }

  for (const [n, line] of defLineByNum) {
    const backticked = line.match(/`conv:[0-9a-z]{8}`/gi) ?? [];
    if (backticked.length !== 1) {
      errors.push(`[^${n}] definition lacks a backticked \`conv:HASH\` (found ${backticked.length})`);
    }
  }

  return { ok: errors.length === 0, errors };
}

// ---- the gate ---------------------------------------------------------

export interface GateOptions {
  /** Edited word count must be >= floor * before's word count. Default 0.7. */
  floor?: number;
  /** Citation hashes the caller has DELIBERATELY pruned (a factual-error fix that
   *  removes a wrong value as if it had never been there). Their loss is permitted
   *  rather than vetoed as accidental citation loss. Empty by default. */
  allowDroppedHashes?: Set<string>;
}

export interface GateVerdict {
  /** True when the edit is safe to commit. */
  ok: boolean;
  /** Null when `ok`; otherwise the joined failing reasons, so the caller can
   *  log WHY the edit was discarded. */
  reason: string | null;
}

function wordCount(s: string): number {
  const t = s.trim();
  return t ? t.split(/\s+/).length : 0;
}

/** True when `text` contains an H1 title line (`# Title`). */
function hasH1(text: string): boolean {
  return text.split("\n").some((l) => /^#\s+\S/.test(l.trim()));
}

/** True when `text` contains a `## References` section heading. */
function hasReferences(text: string): boolean {
  return /^##\s+References\s*$/m.test(text);
}

/**
 * The conservative write gate. Given the (before, after) text of a section or
 * article, decide whether the edit preserved it. On `ok: false` the caller
 * MUST discard `after` and keep `before` — the vault stays unchanged.
 *
 * Enforces (deterministically, no GPU):
 * 1. Citation preservation — every pre-existing `conv:HASH` survives.
 * 2. Footnote bijection — every `[^N]` marker ⇔ one `[^N]:` definition.
 * 3. Prose preservation — the edited word count stays at/above the floor.
 * 4. Structural survival — an H1 and `## References` present before survive.
 *
 * Catches citation/structure/bulk-prose loss; does NOT catch nuance loss.
 */
export function gateEdit(before: string, after: string, opts: GateOptions = {}): GateVerdict {
  const floor = opts.floor ?? 0.7;
  const reasons: string[] = [];

  // 1. Citation preservation: every pre-existing hash must still be cited —
  //    UNLESS the caller deliberately pruned it (a factual-error fix).
  const beforeHashes = extractConvHashes(before);
  const afterHashes = extractConvHashes(after);
  const allowed = opts.allowDroppedHashes ?? new Set<string>();
  for (const h of beforeHashes) {
    if (!afterHashes.has(h) && !allowed.has(h)) reasons.push(`dropped citation conv:${h}`);
  }

  // 2. Footnote bijection on the edited text.
  const fn = checkFootnoteIntegrity(after);
  if (!fn.ok) reasons.push(...fn.errors);

  // 3. Prose preservation: word floor on the touched text.
  const bw = wordCount(before);
  const aw = wordCount(after);
  if (bw > 0 && aw < floor * bw) {
    reasons.push(`word count ${aw} below floor ${Math.ceil(floor * bw)} (before ${bw})`);
  }

  // 4. Structural survival: an H1 / ## References present before must survive.
  if (hasH1(before) && !hasH1(after)) reasons.push("edit dropped the H1 title");
  if (hasReferences(before) && !hasReferences(after)) {
    reasons.push("edit dropped the ## References section");
  }

  // 5. See-also singularity: a fence-confused rebuild that buried one ## See also
  //    and appended another would grow the section unboundedly. Reject (NO-OP) any
  //    result carrying more than ONE ## See also heading, so the section can never
  //    grow regardless of how pathological the input was.
  const seeAlsoCount = (after.match(/^##\s+See also\s*$/gim) ?? []).length;
  if (seeAlsoCount > 1) reasons.push(`multiple ## See also sections (${seeAlsoCount})`);

  return reasons.length ? { ok: false, reason: reasons.join("; ") } : { ok: true, reason: null };
}
