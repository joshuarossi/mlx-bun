// DOM-level unit tests for the Phase 3 command-palette + session
// search/export additions (plan §9 Phase 3, beat-matrix Axis 10/11):
//   - src/web/src/palette.ts: fuzzyMatch, staticActions (pure)
//   - src/web/src/sessions.ts: slugTitle, sessionEntriesToMarkdown,
//     highlightSnippetHtml (pure), openSessionRowByPath (DOM-click bridge)
//
// Kept in its own file (not appended to the already-large, multi-agent-
// touched tests/web-app.test.ts this wave) to avoid a merge collision;
// same happy-dom harness (web-dom-setup's side effect of installing
// document/window globals before any src/web/src module loads).
import "../support/web-dom-setup";
import { describe, expect, it, beforeEach } from "bun:test";
import { fuzzyMatch, staticActions } from "../../src/web/src/palette";
import {
  highlightSnippetHtml, openSessionRowByPath, sessionEntriesToMarkdown, slugTitle,
} from "../../src/web/src/sessions";

describe("fuzzyMatch", () => {
  it("matches an empty query against anything", () => {
    expect(fuzzyMatch("", "New chat")).toBe(true);
  });

  it("matches when every query char appears in order (subsequence)", () => {
    expect(fuzzyMatch("nch", "New chat")).toBe(true);
    expect(fuzzyMatch("newchat", "New chat")).toBe(true);
  });

  it("is case-insensitive", () => {
    expect(fuzzyMatch("NCH", "new chat")).toBe(true);
  });

  it("rejects out-of-order or missing characters", () => {
    expect(fuzzyMatch("chn", "New chat")).toBe(false); // n after ch, wrong order
    expect(fuzzyMatch("xyz", "New chat")).toBe(false);
  });
});

describe("staticActions", () => {
  it("includes every action the task brief names, each with a working id", () => {
    const ids = staticActions().map((a) => a.id);
    expect(ids).toContain("new-chat");
    expect(ids).toContain("toggle-thinking");
    expect(ids).toContain("toggle-theme");
    expect(ids).toContain("toggle-developer");
    expect(ids).toContain("open-memory");
    expect(ids).toContain("browse-models");
    expect(ids).toContain("open-shortcuts");
    expect(ids).toContain("export-chat");
  });

  it("every action has a non-empty label and a run function", () => {
    for (const a of staticActions()) {
      expect(a.label.length).toBeGreaterThan(0);
      expect(typeof a.run).toBe("function");
    }
  });
});

describe("slugTitle", () => {
  it("lowercases and hyphenates", () => {
    expect(slugTitle("Chicken Recipes!")).toBe("chicken-recipes");
  });

  it("falls back to 'chat' for an empty/whitespace title", () => {
    expect(slugTitle("")).toBe("chat");
    expect(slugTitle("   ")).toBe("chat");
  });

  it("collapses runs of punctuation and trims leading/trailing hyphens", () => {
    expect(slugTitle("  --Hello, World!!--  ")).toBe("hello-world");
  });

  it("caps length at 60 chars", () => {
    const long = "a".repeat(200);
    expect(slugTitle(long).length).toBeLessThanOrEqual(60);
  });
});

describe("sessionEntriesToMarkdown", () => {
  it("renders user/assistant turns as headed sections", () => {
    const entries = [
      { type: "session", id: "s1" },
      { type: "message", message: { role: "user", content: "hello" } },
      { type: "message", message: { role: "assistant", content: "hi there" } },
    ];
    const md = sessionEntriesToMarkdown(entries, "My chat");
    expect(md).toContain("# My chat");
    expect(md).toContain("### User");
    expect(md).toContain("hello");
    expect(md).toContain("### Assistant");
    expect(md).toContain("hi there");
  });

  it("flattens content-block-array messages to their text", () => {
    const entries = [
      { type: "message", message: { role: "user", content: [{ type: "text", text: "part one" }, { type: "text", text: "part two" }] } },
    ];
    const md = sessionEntriesToMarkdown(entries, "t");
    expect(md).toContain("part one");
    expect(md).toContain("part two");
  });

  it("skips non-message entries and non-user/assistant roles", () => {
    const entries = [
      { type: "session_info", name: "x" },
      { type: "message", message: { role: "system", content: "should not appear" } },
    ];
    const md = sessionEntriesToMarkdown(entries, "t");
    expect(md).not.toContain("should not appear");
  });

  it("falls back to 'Chat' as the heading when title is empty", () => {
    expect(sessionEntriesToMarkdown([], "")).toContain("# Chat");
  });
});

describe("highlightSnippetHtml", () => {
  it("escapes plain text with no ranges", () => {
    expect(highlightSnippetHtml("a < b & c", [])).toBe("a &lt; b &amp; c");
  });

  it("wraps the matched range in <mark> and escapes the rest", () => {
    const html = highlightSnippetHtml("hello <world>", [[6, 13]]);
    expect(html).toBe("hello <mark>&lt;world&gt;</mark>");
  });

  it("handles multiple non-overlapping ranges in order", () => {
    const html = highlightSnippetHtml("aa bb cc", [[0, 2], [6, 8]]);
    expect(html).toBe("<mark>aa</mark> bb <mark>cc</mark>");
  });

  it("ignores an out-of-bounds or inverted range rather than throwing", () => {
    expect(() => highlightSnippetHtml("short", [[10, 20]])).not.toThrow();
    expect(() => highlightSnippetHtml("short", [[3, 1]])).not.toThrow();
  });
});

describe("openSessionRowByPath (DOM-click bridge)", () => {
  beforeEach(() => {
    document.body.innerHTML =
      '<div id="chat-sessions">' +
        '<div class="sess" data-path="/a/1.jsonl" data-title="alpha"><div class="stitle">Alpha</div></div>' +
        '<div class="sess sess-hidden" data-path="/a/2.jsonl" data-title="beta"><div class="stitle">Beta</div></div>' +
      "</div>";
  });

  it("clicks the matching row and un-hides it", () => {
    const opened: { path: string | null } = { path: null };
    const row = document.querySelector('.sess[data-path="/a/2.jsonl"]') as HTMLElement;
    row.addEventListener("click", () => { opened.path = row.dataset.path || null; });
    const ok = openSessionRowByPath("/a/2.jsonl");
    expect(ok).toBe(true);
    expect(opened.path).toBe("/a/2.jsonl");
    expect(row.classList.contains("sess-hidden")).toBe(false);
  });

  it("returns false for a path with no matching row (no throw)", () => {
    expect(openSessionRowByPath("/a/does-not-exist.jsonl")).toBe(false);
  });

  it("returns false when #chat-sessions isn't in the DOM at all", () => {
    document.body.innerHTML = "";
    expect(openSessionRowByPath("/a/1.jsonl")).toBe(false);
  });
});
