// src/serve/session-search.ts — fast tier, no model context, tmp session-dir
// fixtures (never ~/.mlx-bun/sessions — the hard rule for this task).

import { afterEach, describe, expect, test } from "bun:test";
import { mkdtempSync, rmSync, writeFileSync } from "node:fs";
import { tmpdir } from "node:os";
import { join } from "node:path";
import {
  buildSnippet, handleSessionsExport, handleSessionsSearch, isUnderSessionDir,
  searchSessionContent, searchSessions,
} from "../src/serve/session-search";

function jsonl(entries: unknown[]): string {
  return entries.map((e) => JSON.stringify(e)).join("\n") + "\n";
}

function sessionHeader(id: string, cwd = "/tmp"): object {
  return { type: "session", version: 3, id, timestamp: new Date().toISOString(), cwd };
}

function msg(role: "user" | "assistant", text: string): object {
  return {
    type: "message", id: crypto.randomUUID(), parentId: null, timestamp: new Date().toISOString(),
    message: { role, content: text, timestamp: Date.now() },
  };
}

describe("buildSnippet", () => {
  test("centers a ±60-char window around the match", () => {
    const text = "a".repeat(100) + "NEEDLE" + "b".repeat(100);
    const { snippet, range } = buildSnippet(text, 100, "NEEDLE".length);
    expect(snippet).toContain("NEEDLE");
    expect(snippet.slice(range[0], range[1])).toBe("NEEDLE");
    expect(snippet.startsWith("…")).toBe(true);
    expect(snippet.endsWith("…")).toBe(true);
  });

  test("no ellipsis at the true start/end of the text", () => {
    const text = "NEEDLE at the very start of a short string";
    const { snippet, range } = buildSnippet(text, 0, "NEEDLE".length);
    expect(snippet.startsWith("…")).toBe(false);
    expect(snippet.slice(range[0], range[1])).toBe("NEEDLE");
  });
});

describe("searchSessionContent", () => {
  test("finds a substring match in a user message and reports role + snippet", () => {
    const content = jsonl([
      sessionHeader("s1"),
      msg("user", "What's the best way to roast a chicken with rosemary?"),
      msg("assistant", "Try a high-heat roast with rosemary and lemon."),
    ]);
    const result = searchSessionContent(content, "rosemary");
    expect(result).not.toBeNull();
    expect(result!.matches.length).toBe(2);
    expect(result!.matches[0]!.role).toBe("user");
    expect(result!.matches[0]!.snippet.toLowerCase()).toContain("rosemary");
  });

  test("case-insensitive", () => {
    const content = jsonl([sessionHeader("s1"), msg("user", "ROSEMARY is great")]);
    const result = searchSessionContent(content, "rosemary");
    expect(result).not.toBeNull();
  });

  test("returns null when there's no match", () => {
    const content = jsonl([sessionHeader("s1"), msg("user", "hello world")]);
    expect(searchSessionContent(content, "xyzzy")).toBeNull();
  });

  test("match offsets stay correct when a length-expanding lowercase fold (Turkish dotted İ) precedes the match (review finding)", () => {
    // "İ".toLowerCase() is a 2-code-unit "i̇" (dotted i + combining dot
    // above) — one code unit LONGER than the original "İ". A whole-string
    // text.toLowerCase() before scanning would desync every match offset
    // after this character from the ORIGINAL text's coordinates, which is
    // what buildSnippet slices.
    const text = "See İstanbul now: match here";
    expect(text.length).not.toBe(text.toLowerCase().length); // sanity: the fold really does expand
    const result = searchSessionContent(jsonl([sessionHeader("s1"), msg("user", text)]), "match");
    expect(result).not.toBeNull();
    const m = result!.matches[0]!;
    const [start, end] = m.ranges[0]!;
    expect(m.snippet.slice(start, end)).toBe("match");
  });

  test("a match spanning the expanding character itself still yields the correct original substring", () => {
    // "İ".toLowerCase() is "i" + a combining dot above (U+0307), so the
    // query that actually substring-matches the folded text is "i̇st",
    // not the plain ASCII "ist" — this exercises findOccurrences' lastFold
    // path (the match's LAST folded code unit, not just its first, needs
    // translating back through `index`).
    const text = "the İstanbul trip";
    const result = searchSessionContent(jsonl([sessionHeader("s1"), msg("user", text)]), "i̇st");
    expect(result).not.toBeNull();
    const m = result!.matches[0]!;
    const [start, end] = m.ranges[0]!;
    expect(m.snippet.slice(start, end)).toBe("İst");
  });

  test("uses session_info name as title when present", () => {
    const content = jsonl([
      sessionHeader("s1"),
      { type: "session_info", id: "x", parentId: null, timestamp: new Date().toISOString(), name: "Chicken recipes" },
      msg("user", "rosemary chicken please"),
    ]);
    const result = searchSessionContent(content, "rosemary");
    expect(result!.sessionTitle).toBe("Chicken recipes");
  });

  test("falls back to first user message as title", () => {
    const content = jsonl([sessionHeader("s1"), msg("user", "rosemary chicken please")]);
    const result = searchSessionContent(content, "rosemary");
    expect(result!.sessionTitle).toBe("rosemary chicken please");
  });

  test("tolerates a corrupt/truncated line without throwing", () => {
    const content = jsonl([sessionHeader("s1"), msg("user", "rosemary chicken")]) + '{"type":"message","message":{"role":"user"' /* truncated */;
    expect(() => searchSessionContent(content, "rosemary")).not.toThrow();
    const result = searchSessionContent(content, "rosemary");
    expect(result).not.toBeNull();
  });

  test("skips non-user/assistant roles and non-message entries", () => {
    const content = jsonl([
      sessionHeader("s1"),
      { type: "thinking_level_change", id: "x", parentId: null, timestamp: new Date().toISOString(), thinkingLevel: "high" },
      msg("user", "rosemary chicken"),
    ]);
    const result = searchSessionContent(content, "rosemary");
    expect(result!.matches.length).toBe(1);
  });

  test("caps matches per session at 10", () => {
    const many = Array.from({ length: 20 }, () => msg("user", "needle needle"));
    const content = jsonl([sessionHeader("s1"), ...many]);
    const result = searchSessionContent(content, "needle");
    expect(result!.matches.length).toBeLessThanOrEqual(10);
  });
});

describe("searchSessions (filesystem scan)", () => {
  let dir = "";
  afterEach(() => {
    if (dir) rmSync(dir, { recursive: true, force: true });
    dir = "";
  });

  test("scans every .jsonl file in the session dir", async () => {
    dir = mkdtempSync(join(tmpdir(), "mlx-bun-session-search-"));
    writeFileSync(join(dir, "20260101_a.jsonl"), jsonl([sessionHeader("a"), msg("user", "tell me about rosemary")]));
    writeFileSync(join(dir, "20260102_b.jsonl"), jsonl([sessionHeader("b"), msg("user", "unrelated topic entirely")]));
    writeFileSync(join(dir, "not-a-session.txt"), "rosemary rosemary rosemary");

    const results = await searchSessions(dir, "rosemary");
    expect(results.length).toBe(1);
    expect(results[0]!.sessionPath).toBe(join(dir, "20260101_a.jsonl"));
  });

  test("empty query returns no results", async () => {
    dir = mkdtempSync(join(tmpdir(), "mlx-bun-session-search-"));
    writeFileSync(join(dir, "a.jsonl"), jsonl([sessionHeader("a"), msg("user", "hello")]));
    expect(await searchSessions(dir, "  ")).toEqual([]);
  });

  test("missing session dir returns no results, never throws", async () => {
    const results = await searchSessions(join(tmpdir(), "mlx-bun-does-not-exist-" + Date.now()), "rosemary");
    expect(results).toEqual([]);
  });

  test("tolerates a file that is deleted between listing and read", async () => {
    dir = mkdtempSync(join(tmpdir(), "mlx-bun-session-search-"));
    writeFileSync(join(dir, "a.jsonl"), jsonl([sessionHeader("a"), msg("user", "rosemary present")]));
    const results = await searchSessions(dir, "rosemary");
    expect(results.length).toBe(1);
  });
});

describe("isUnderSessionDir", () => {
  test("accepts the root itself and nested paths", () => {
    expect(isUnderSessionDir("/a/b", "/a/b")).toBe(true);
    expect(isUnderSessionDir("/a/b/c.jsonl", "/a/b")).toBe(true);
  });

  test("rejects paths outside the root, including lexical prefix tricks", () => {
    expect(isUnderSessionDir("/a/bc.jsonl", "/a/b")).toBe(false);
    expect(isUnderSessionDir("/etc/passwd", "/a/b")).toBe(false);
    expect(isUnderSessionDir("/a/b/../../etc/passwd", "/a/b")).toBe(false);
  });
});

describe("GET /api/sessions/search", () => {
  let dir = "";
  afterEach(() => {
    if (dir) rmSync(dir, { recursive: true, force: true });
    dir = "";
  });

  test("400s without q", async () => {
    const res = await handleSessionsSearch(new URL("http://x/api/sessions/search"));
    expect(res.status).toBe(400);
    const body = (await res.json()) as { ok: boolean };
    expect(body.ok).toBe(false);
  });

  test("returns results shaped for the sidebar/palette", async () => {
    dir = mkdtempSync(join(tmpdir(), "mlx-bun-session-search-"));
    writeFileSync(join(dir, "a.jsonl"), jsonl([sessionHeader("a"), msg("user", "let's talk about rosemary bread")]));
    const res = await handleSessionsSearch(new URL("http://x/api/sessions/search?q=rosemary"), dir);
    expect(res.status).toBe(200);
    const body = (await res.json()) as { ok: boolean; results: Array<{ sessionPath: string; sessionTitle: string; matches: unknown[] }> };
    expect(body.ok).toBe(true);
    expect(body.results.length).toBe(1);
    expect(body.results[0]!.matches.length).toBeGreaterThan(0);
  });
});

describe("GET /api/sessions/export", () => {
  let dir = "";
  afterEach(() => {
    if (dir) rmSync(dir, { recursive: true, force: true });
    dir = "";
  });

  test("400s without path", async () => {
    const res = await handleSessionsExport(new URL("http://x/api/sessions/export"));
    expect(res.status).toBe(400);
  });

  test("403s a path outside the session dir", async () => {
    dir = mkdtempSync(join(tmpdir(), "mlx-bun-session-search-"));
    const res = await handleSessionsExport(new URL("http://x/api/sessions/export?path=/etc/passwd"), dir);
    expect(res.status).toBe(403);
  });

  test("404s a path inside the dir that doesn't exist", async () => {
    dir = mkdtempSync(join(tmpdir(), "mlx-bun-session-search-"));
    const res = await handleSessionsExport(new URL("http://x/api/sessions/export?path=" + encodeURIComponent(join(dir, "ghost.jsonl"))), dir);
    expect(res.status).toBe(404);
  });

  test("returns parsed JSONL entries for a real session file", async () => {
    dir = mkdtempSync(join(tmpdir(), "mlx-bun-session-search-"));
    const file = join(dir, "a.jsonl");
    writeFileSync(file, jsonl([sessionHeader("a"), msg("user", "hi"), msg("assistant", "hello there")]));
    const res = await handleSessionsExport(new URL("http://x/api/sessions/export?path=" + encodeURIComponent(file)), dir);
    expect(res.status).toBe(200);
    const body = (await res.json()) as { ok: boolean; entries: unknown[] };
    expect(body.ok).toBe(true);
    expect(body.entries.length).toBe(3);
  });

  test("skips malformed lines instead of failing the whole export", async () => {
    dir = mkdtempSync(join(tmpdir(), "mlx-bun-session-search-"));
    const file = join(dir, "a.jsonl");
    writeFileSync(file, jsonl([sessionHeader("a"), msg("user", "hi")]) + "not json at all\n");
    const res = await handleSessionsExport(new URL("http://x/api/sessions/export?path=" + encodeURIComponent(file)), dir);
    expect(res.status).toBe(200);
    const body = (await res.json()) as { ok: boolean; entries: unknown[] };
    expect(body.entries.length).toBe(2);
  });
});
