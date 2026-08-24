// Full-text search across web-chat session message BODIES (plan §9 Phase 3,
// beat-matrix Axis 10/11 "the full-text BEAT": Claude's own session search is
// title-only — a widely-cited annoyance — and local storage removes any
// server-cost excuse to skip real body search).
//
// Reads the SAME session directory pi-web.ts's PiWebSession uses
// (`~/.mlx-bun/sessions`, pi's own JSONL-per-session format —
// `join(homedir(), ".mlx-bun", "sessions")`, see pi-web.ts's `sessionDir`
// field and SessionManager.list's own file resolution in
// @earendil-works/pi-coding-agent). Deliberately NOT a SessionManager import:
// SessionManager.list() builds the full session tree (labels, branches,
// compaction) for the chat runtime; this scanner only needs a flat
// "role + text" reading of each line for substring matching, so a small,
// independent, read-only line parser is both simpler and can never
// accidentally mutate/lock a live session file.
//
// v1 is a linear, case-insensitive substring scan over every session file on
// every request — no index. That's the right trade at personal-chat-corpus
// scale (a few hundred to a few thousand sessions, read once per keystroke's
// debounced request); if the corpus ever grows enough to matter, the upgrade
// path is a background-built inverted index (token -> {sessionPath, lineNo})
// refreshed on file mtime change, not a rewrite of this module's contract.
//
// JSONL-tolerant: a corrupt or partially-written line (the active session's
// file can be mid-append) is skipped, never thrown — matching
// SessionManager's own `parseSessionEntryLine` tolerance.

import { readdir, readFile } from "node:fs/promises";
import { homedir } from "node:os";
import { join, resolve } from "node:path";

/** Same default session directory pi-web.ts's PiWebSession uses. Exported so
 *  server.ts/tests can override it (tests always pass an explicit dir —
 *  never touch the real `~/.mlx-bun/sessions`). */
export function defaultSessionDir(): string {
  return join(homedir(), ".mlx-bun", "sessions");
}

export interface SearchMatch {
  /** ±60-char plain-text window around the match, NOT html-escaped and NOT
   *  html-highlighted — matches are reported as plain-text [start,end)
   *  ranges into `snippet` so the caller (server-api consumer) chooses how
   *  to render highlighting (the frontend escapes then re-inserts a <mark>,
   *  matching the rest of this codebase's escape-then-restore convention —
   *  see markdown.ts's code-span handling for the same pattern applied to a
   *  different problem). */
  snippet: string;
  /** [start,end) offsets of the matched substring within `snippet`, one pair
   *  per occurrence actually contained in this snippet window (usually one —
   *  more only if two hits land within 60 chars of each other). */
  ranges: Array<[number, number]>;
  role: string;
}

export interface SessionSearchResult {
  sessionPath: string;
  sessionTitle: string;
  matches: SearchMatch[];
}

interface ParsedLine {
  type?: string;
  message?: { role?: string; content?: unknown; timestamp?: number };
  name?: string;
}

/** Best-effort JSON.parse of one JSONL line; never throws. Mirrors
 *  pi-coding-agent's own parseSessionEntryLine tolerance (skip malformed
 *  lines rather than fail the whole file). */
function parseLine(line: string): ParsedLine | null {
  const trimmed = line.trim();
  if (!trimmed) return null;
  try {
    return JSON.parse(trimmed) as ParsedLine;
  } catch {
    return null;
  }
}

/** Flatten a message's content (string | content-block array) to plain text,
 *  same shape pi-coding-agent's own extractTextContent handles. */
function contentText(content: unknown): string {
  if (typeof content === "string") return content;
  if (Array.isArray(content)) {
    return content
      .filter((p): p is { type: string; text: string } =>
        !!p && (p as { type?: string }).type === "text" && typeof (p as { text?: unknown }).text === "string")
      .map((p) => p.text)
      .join(" ");
  }
  return "";
}

const MAX_MATCHES_PER_SESSION = 10;
const MAX_TOTAL_MATCHES = 50;
const SNIPPET_RADIUS = 60;

/** Build one snippet window (±SNIPPET_RADIUS chars) around a single match
 *  index in `text`, plus the match's own [start,end) offsets translated into
 *  the snippet's local coordinate space. Pure — independently testable. */
export function buildSnippet(text: string, matchStart: number, matchLen: number): { snippet: string; range: [number, number] } {
  const start = Math.max(0, matchStart - SNIPPET_RADIUS);
  const end = Math.min(text.length, matchStart + matchLen + SNIPPET_RADIUS);
  const prefix = start > 0 ? "…" : "";
  const suffix = end < text.length ? "…" : "";
  const snippet = prefix + text.slice(start, end) + suffix;
  const localStart = matchStart - start + prefix.length;
  return { snippet, range: [localStart, localStart + matchLen] };
}

/** Build a case-folded copy of `text` PLUS a parallel index that maps every
 *  position in the folded string back to the position it came from in the
 *  original — needed because `String.prototype.toLowerCase()` is not
 *  length-preserving for every character (e.g. Turkish dotted capital I,
 *  U+0130, folds to a 2-code-unit "i̇": `"İ".length === 1` but
 *  `"İ".toLowerCase().length === 2`). Folding the WHOLE string at once (the
 *  original approach) desyncs any match offset that falls after such a
 *  character: `text.toLowerCase().indexOf(...)` returns an index into the
 *  now-longer folded string, but callers then slice the shorter original
 *  `text` at that same numeric offset. Folding one character at a time and
 *  recording, for each folded code unit, which original index it expanded
 *  from keeps the scan itself simple (still a plain indexOf loop) while
 *  making offset translation exact for every fold, not just the common
 *  1:1 case. */
function foldWithIndex(text: string): { folded: string; index: number[] } {
  let folded = "";
  const index: number[] = [];
  for (let i = 0; i < text.length; i++) {
    const piece = text[i]!.toLowerCase();
    for (let j = 0; j < piece.length; j++) index.push(i);
    folded += piece;
  }
  return { folded, index };
}

/** Find every occurrence of `qLower` (already lowercased) in `textLower`,
 *  returning [start, len] pairs translated back into the ORIGINAL
 *  (pre-fold) string's coordinate space via `index` (see foldWithIndex) —
 *  callers slice the original `text`, not `textLower`, so both the start
 *  offset AND the matched span's length must live in that space. `len` is
 *  computed from the first and last folded code unit's original index
 *  (not `qLower.length`) so a match whose folded span itself contains a
 *  length-expanding character (e.g. the query matches text spanning a
 *  Turkish dotted İ) still yields the exact original substring, not a
 *  same-length-as-query slice that's now off by the expansion. Pure
 *  substring scan — no regex (query is user-controlled; escaping for
 *  RegExp is an unforced footgun v1 doesn't need since substring search is
 *  the stated v1 bar). */
function findOccurrences(textLower: string, qLower: string, index: readonly number[]): Array<[number, number]> {
  if (!qLower) return [];
  const offsets: Array<[number, number]> = [];
  let i = 0;
  for (;;) {
    const idx = textLower.indexOf(qLower, i);
    if (idx === -1) break;
    const start = index[idx] ?? idx;
    const lastFoldedIdx = idx + qLower.length - 1;
    const end = index[lastFoldedIdx] ?? lastFoldedIdx;
    offsets.push([start, end - start + 1]);
    i = idx + qLower.length;
  }
  return offsets;
}

/** Scan one session file's raw JSONL content for `query` (case-insensitive
 *  substring), returning up to MAX_MATCHES_PER_SESSION per session. Pure
 *  given the file content string — split out from the disk read so it's
 *  unit-testable without touching the filesystem. */
export function searchSessionContent(content: string, query: string): SessionSearchResult | null {
  const qLower = query.toLowerCase();
  if (!qLower) return null;

  const lines = content.split("\n");
  let sessionPath = "";
  let title = "";
  let firstUserMessage = "";
  const matches: SearchMatch[] = [];

  for (const line of lines) {
    const entry = parseLine(line);
    if (!entry) continue;
    if (entry.type === "session_info" && typeof entry.name === "string" && entry.name.trim()) {
      title = entry.name.trim();
      continue;
    }
    if (entry.type !== "message" || !entry.message) continue;
    const role = entry.message.role;
    if (role !== "user" && role !== "assistant") continue;
    const text = contentText(entry.message.content);
    if (!text) continue;
    if (!firstUserMessage && role === "user") firstUserMessage = text;

    if (matches.length >= MAX_MATCHES_PER_SESSION) continue;
    // Fold with an index (not a plain text.toLowerCase()) so match offsets
    // stay valid against the ORIGINAL `text` that buildSnippet slices below
    // — a length-expanding fold (e.g. Turkish dotted İ -> 2-code-unit "i̇")
    // would otherwise desync a whole-string lowercase's offsets from the
    // original string's coordinates for any match after it (see
    // foldWithIndex's comment).
    const { folded: textLower, index } = foldWithIndex(text);
    const offsets = findOccurrences(textLower, qLower, index);
    for (const [off, len] of offsets) {
      if (matches.length >= MAX_MATCHES_PER_SESSION) break;
      const { snippet, range } = buildSnippet(text, off, len);
      matches.push({ snippet, ranges: [range], role });
    }
  }

  if (matches.length === 0) return null;
  return {
    sessionPath,
    sessionTitle: (title || firstUserMessage || "New chat").slice(0, 80),
    matches,
  };
}

/** Scan every `.jsonl` file under `sessionDir` for `query`. Read-only,
 *  JSONL-tolerant (a corrupt/mid-write file contributes whatever valid lines
 *  it has rather than aborting the whole scan), capped at
 *  MAX_TOTAL_MATCHES results across all sessions. Sessions are visited in
 *  directory-listing order (pi names files `<timestamp>_<id>.jsonl`, so this
 *  is naturally oldest-first — good enough for v1; result ordering isn't a
 *  relevance rank, just "found in these sessions"). */
export async function searchSessions(sessionDir: string, query: string): Promise<SessionSearchResult[]> {
  const trimmed = query.trim();
  if (!trimmed) return [];

  let files: string[];
  try {
    files = (await readdir(sessionDir)).filter((f) => f.endsWith(".jsonl"));
  } catch {
    return []; // no session dir yet — never throw, just no results
  }

  const results: SessionSearchResult[] = [];
  let total = 0;
  for (const file of files) {
    if (total >= MAX_TOTAL_MATCHES) break;
    const path = join(sessionDir, file);
    let content: string;
    try {
      content = await readFile(path, "utf8");
    } catch {
      continue; // deleted mid-scan, permissions, etc. — skip, don't throw
    }
    const result = searchSessionContent(content, trimmed);
    if (!result) continue;
    result.sessionPath = path;
    const remaining = MAX_TOTAL_MATCHES - total;
    if (result.matches.length > remaining) result.matches = result.matches.slice(0, remaining);
    total += result.matches.length;
    results.push(result);
  }
  return results;
}

/* ────────────────────────────────────────────────────────────────────
   REST handlers — pure (URL) => Response, no `ctx` dependency, same
   convention as src/memory/rest.ts / src/hub-rest.ts (dispatched from
   server.ts by path+method; unit-tested directly in
   tests/serve/session-search.test.ts without booting a model context).
   ──────────────────────────────────────────────────────────────────── */

function jsonOk<T extends object>(body: T, init?: ResponseInit): Response {
  return Response.json({ ok: true, ...body }, init);
}

function jsonErr(error: string, status = 400): Response {
  return Response.json({ ok: false, error }, { status });
}

/** True if `path` resolves under `sessionDir` — same guard shape as
 *  pi-web.ts's private `isUnderSessionDir` (root itself or a path prefixed
 *  by `root + "/"`), reimplemented here (not imported) since pi-web.ts's
 *  copy is a private method on PiWebSession, not a standalone export, and
 *  duplicating this one three-line check is cheaper than changing that
 *  class's visibility for two read-only REST routes. */
export function isUnderSessionDir(path: string, sessionDir: string): boolean {
  const root = resolve(sessionDir);
  const p = resolve(path);
  return p === root || p.startsWith(root + "/");
}

// ---- GET /api/sessions/search?q= ----------------------------------------

/** `sessionDirOverride` lets tests point at a tmp fixture dir instead of the
 *  real `~/.mlx-bun/sessions` (never touched by tests). */
export async function handleSessionsSearch(url: URL, sessionDirOverride?: string): Promise<Response> {
  const q = (url.searchParams.get("q") ?? "").trim();
  if (!q) return jsonErr("q is required");
  const dir = sessionDirOverride ?? defaultSessionDir();
  const results = await searchSessions(dir, q);
  return jsonOk({ results });
}

// ---- GET /api/sessions/export?path= --------------------------------------

/** Returns the raw session JSONL, parsed into an array of entries (one per
 *  line) — the frontend's non-open-session export path reads this to
 *  render Markdown/JSON client-side without a second, divergent parser.
 *  `path` is validated under sessionDir exactly like pi-web's
 *  isUnderSessionDir — a path outside the session directory 400s before
 *  touching the filesystem. */
export async function handleSessionsExport(url: URL, sessionDirOverride?: string): Promise<Response> {
  const path = (url.searchParams.get("path") ?? "").trim();
  if (!path) return jsonErr("path is required");
  const dir = sessionDirOverride ?? defaultSessionDir();
  if (!isUnderSessionDir(path, dir)) return jsonErr("path must be under the session directory", 403);
  let content: string;
  try {
    content = await readFile(path, "utf8");
  } catch {
    return jsonErr("session not found", 404);
  }
  const entries: unknown[] = [];
  for (const line of content.split("\n")) {
    const trimmed = line.trim();
    if (!trimmed) continue;
    try {
      entries.push(JSON.parse(trimmed));
    } catch {
      // skip malformed lines — same JSONL tolerance as the search scanner
    }
  }
  return jsonOk({ path, entries });
}
