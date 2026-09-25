import { afterEach, describe, expect, test } from "bun:test";
import { mkdirSync, mkdtempSync, rmSync, symlinkSync, writeFileSync } from "node:fs";
import { tmpdir } from "node:os";
import { join } from "node:path";
import {
  buildSnippet, searchSessionContent, searchSessions,
} from "../src/chat/session-search";

import { isUnderSessionDir } from "../src/chat/session-files";
import { createSessionRoutes } from "../src/server/session-routes";

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

  test("later explicit titles survive match limits and are capped at eighty characters", () => {
    const result = searchSessionContent(jsonl([
      msg("user", "needle ".repeat(20)), { type: "session_info", name: "  " + "Title".repeat(20) + "  " },
    ]), "needle")!;
    expect(result.matches).toHaveLength(10); expect(result.sessionTitle).toBe("Title".repeat(16));
  });

  test("content block search ignores non-text and non-conversation roles", () => {
    const result = searchSessionContent(jsonl([
      { type: "message", message: { role: "assistant", content: [
        { type: "text", text: "first needle" }, { type: "thinking", text: "hidden needle" }, { type: "text", text: "last" },
      ] } },
      { type: "message", message: { role: "toolResult", content: "hidden needle" } },
    ]), "needle")!;
    expect(result.sessionTitle).toBe("New chat"); expect(result.matches).toHaveLength(1);
    expect(result.matches[0]!.snippet).toBe("first needle last");
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

  test("unreadable dangling session links do not prevent reading other files", async () => {
    dir = mkdtempSync(join(tmpdir(), "mlx-bun-session-search-"));
    writeFileSync(join(dir, "a.jsonl"), jsonl([sessionHeader("a"), msg("user", "rosemary present")]));
    symlinkSync(join(dir, "missing.jsonl"), join(dir, "dangling.jsonl"));
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

describe("session HTTP routes and filesystem confinement", () => {
  let root = "";
  afterEach(() => { if (root) rmSync(root, { recursive: true, force: true }); root = ""; });
  function setup() {
    root = mkdtempSync(join(tmpdir(), "mlx-session-routes-"));
    const dir = join(root, "sessions"), outside = join(root, "sessions-other");
    mkdirSync(dir); mkdirSync(outside);
    const routes = createSessionRoutes(dir);
    const get = async (path: string, query: Record<string, string> = {}) => {
      const response = await routes.handle(new Request(`http://local/api/sessions/${path}?${new URLSearchParams(query)}`));
      expect(response).not.toBeNull(); return response!;
    };
    return { dir, outside, routes, get };
  }

  test("requires query/path and leaves unrelated methods and routes to composition", async () => {
    const { routes, get } = setup();
    for (const [path, message] of [["search", "q is required"], ["export", "path is required"]] as const) {
      const response = await get(path); expect(response.status).toBe(400);
      expect(await response.json()).toEqual({ ok: false, error: message });
    }
    expect(await routes.handle(new Request("http://local/api/sessions/search?q=hello", { method: "POST" }))).toBeNull();
    expect(await routes.handle(new Request("http://local/other"))).toBeNull();
  });

  test("search returns sidebar matches and export retains all valid raw JSON entries", async () => {
    const { dir, get } = setup();
    const file = join(dir, "a.jsonl");
    const entries = [sessionHeader("a"), msg("user", "rosemary bread"), msg("assistant", "Try rosemary."), null, 3];
    writeFileSync(file, jsonl(entries) + "not json\n{\"partial\":");
    const searched = await get("search", { q: " ROSEMARY " });
    expect(searched.status).toBe(200);
    const body = await searched.json();
    expect(body.ok).toBe(true); expect(body.results).toHaveLength(1);
    expect(body.results[0]).toMatchObject({ sessionPath: file, sessionTitle: "rosemary bread" });
    expect(body.results[0].matches).toHaveLength(2);
    const exported = await get("export", { path: file });
    expect(exported.status).toBe(200); expect(await exported.json()).toEqual({ ok: true, path: file, entries });
    expect((await get("export", { path: join(dir, "missing.jsonl") })).status).toBe(404);
  });

  test("lexical escapes and symlink targets outside the directory are rejected and never searched", async () => {
    const { dir, outside, get } = setup();
    const external = join(outside, "secret.jsonl");
    writeFileSync(external, jsonl([msg("user", "outside secret")]));
    const leaf = join(dir, "escape.jsonl"), parent = join(dir, "linked-parent");
    symlinkSync(external, leaf); symlinkSync(outside, parent);
    for (const path of [external, `${dir}/../sessions-other/secret.jsonl`, leaf, join(parent, "secret.jsonl")]) {
      const response = await get("export", { path }); expect(response.status).toBe(403);
      expect(await response.json()).toEqual({ ok: false, error: "path must be under the session directory" });
    }
    expect(await (await get("search", { q: "secret" })).json()).toEqual({ ok: true, results: [] });
  });

  test("export trims Unicode whitespace and reports dangling aliases as not found", async () => {
    const { dir, routes, get } = setup();
    const file = join(dir, "whitespace.jsonl");
    writeFileSync(file, '\uFEFF{"first":1}\n\u00A0{"second":2}\n');
    expect((await (await get("export", { path: file })).json()).entries).toEqual([{ first: 1 }, { second: 2 }]);
    const dangling = join(dir, "dangling.jsonl");
    symlinkSync(join(dir, "missing-target.jsonl"), dangling);
    expect((await get("export", { path: dangling })).status).toBe(404);
    const encoded = new Request(`http://local/api/sessions/export?path=${encodeURIComponent(dir)}/%2e%2e/sessions-other/secret.jsonl`);
    expect((await routes.handle(encoded))!.status).toBe(403);
  });

  test("nested files and links inside the configured directory remain readable", async () => {
    const { dir, get } = setup();
    mkdirSync(join(dir, "nested"));
    const file = join(dir, "nested", "a.jsonl"), alias = join(dir, "alias.jsonl");
    const entries = [msg("user", "inside needle")];
    writeFileSync(file, jsonl(entries)); symlinkSync(file, alias);
    expect(await (await get("export", { path: file })).json()).toEqual({ ok: true, path: file, entries });
    expect(await (await get("export", { path: alias })).json()).toEqual({ ok: true, path: alias, entries });
    const results = await (await get("search", { q: "needle" })).json();
    expect(results.results).toHaveLength(1); expect(results.results[0].sessionPath).toBe(alias);
    // The configured root may itself be an explicit filesystem alias.
    const rootAlias = join(root, "configured-alias"); symlinkSync(dir, rootAlias);
    const path = join(rootAlias, "alias.jsonl");
    const response = await createSessionRoutes(rootAlias).handle(new Request(`http://local/api/sessions/export?${new URLSearchParams({ path })}`));
    expect(response!.status).toBe(200); expect((await response!.json()).entries).toEqual(entries);
  });

  test("scan retains the ten-per-session and fifty-total match limits", async () => {
    const { dir, get } = setup();
    for (let i = 0; i < 9; i++) writeFileSync(join(dir, `${i}.jsonl`), jsonl([msg("user", "needle ".repeat(15))]));
    const body = await (await get("search", { q: "needle" })).json();
    expect(body.results).toHaveLength(5);
    expect(body.results.map((result: { matches: unknown[] }) => result.matches.length)).toEqual([10, 10, 10, 10, 10]);
  });
});
