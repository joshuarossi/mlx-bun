// Read-only substring search over Pi's JSONL transcripts; no SDK runtime or index.
import { readdir } from "node:fs/promises";
import { join } from "node:path";
import { readSessionFile } from "./session-files";

export interface SearchMatch {
  /** Plain text around the match; the consumer owns HTML escaping/highlighting. */
  snippet: string;
  /** Matched [start,end) UTF-16 offsets within the snippet. */
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

/** Map folded code units back to original offsets. Lowercasing can expand
 * characters (İ → i + combining dot), so slicing by folded offsets is wrong. */
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

/** Translate both ends of each folded substring match to original offsets. */
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
  const sessionPath = "";
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

/** Flat directory scan in listing order, capped across sessions. Missing,
 * unreadable, or concurrently removed files do not fail the remaining search. */
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
    const fileContent = await readSessionFile(sessionDir, path);
    if (!fileContent.ok) continue; // deleted, unreadable, or outside via a symlink
    const result = searchSessionContent(fileContent.content, trimmed);
    if (!result) continue;
    result.sessionPath = path;
    const remaining = MAX_TOTAL_MATCHES - total;
    if (result.matches.length > remaining) result.matches = result.matches.slice(0, remaining);
    total += result.matches.length;
    results.push(result);
  }
  return results;
}
