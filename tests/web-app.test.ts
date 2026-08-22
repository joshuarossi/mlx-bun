// DOM-level unit tests for the pure/DOM-facing parts of the src/web/src/*
// module split (plan §7/§9 Phase 2). Covers exactly the four things the
// task calls out:
//   (a) streaming parity — block-memoized incremental render vs one-shot
//       mdToHtml, fed char-by-char, over a small fixture corpus
//   (b) renderQueue length/array semantics (web-ui-pass-plan.md #2)
//   (c) api() error-envelope unwrapping ([object Object] bug, #4)
//   (d) esc() discipline on the adapter-option template path (#15)
//
// This is model-free and server-free: no WS, no fetch to a real server
// (fetch is stubbed per-test where api() is exercised). happy-dom provides
// document/window (see web-dom-setup.ts, imported first for its side effect
// of installing globals before any src/web/src module runs).
import "./web-dom-setup";
import { describe, expect, it, beforeEach } from "bun:test";
import {
  captureCanvasViewStates, highlightIn, isCanvasFence, linkifyCitations, makeFrameScheduler, mdCodeBlock, mdToHtml,
  renderBlocksIncremental, restoreCanvasViewStates, splitBlocks, wireCanvasToggle, type BlockState,
} from "../src/web/src/markdown";
import { api } from "../src/web/src/api";
import { renderQueue } from "../src/web/src/composer";
import { renderAdapterOptionsHtml, type AdapterInfo } from "../src/web/src/composer";
import {
  applyMention, buildMentionItems, detectMentionQuery, filterFileMentions,
  renderMentionListHtml, type Attachment, type MentionItem, type MentionQuery,
} from "../src/web/src/composer";
import { buildMessageText, ComposerState } from "../src/web/src/composer";
import { createChatController, renderSourcesHtml } from "../src/web/src/chat";
import { MEMORY_CHIP_TOOL_NAMES, isMemoryToolName, memoryToolChip } from "../src/web/src/memory-panel";
import { MEMORY_TOOL_NAMES, REFERENCE_TOOL_NAMES } from "../src/memory/tools";
import {
  AdaptersPanelState, renderAdapterRow, renderAdaptersBodyHtml,
  type AvailableAdapterRow, type MountedAdapterRow,
} from "../src/web/src/adapters-panel";
import { fitVerdict, renderModelPopBodyHtml, type LibraryRow } from "../src/web/src/model-picker";
import {
  INLINE_THRESHOLD_CHARS, bm25TopK, buildContextBlock, buildIndex, chunkFiles, chunkText,
  retrieve, shouldRetrieve, tokenize, toCitations, type Chunk, type Citation,
} from "../src/web/src/rag";
import { renderHubLocalHtml, renderHubSearchHtml, type HubLocalRow, type HubSearchRow } from "../src/web/src/hub";
import {
  ambientLine, buildAppContext, captureUiSnapshot, resolveSpotlightTarget, type UiSnapshot,
} from "../src/web/src/assistant";
import { isRouteId, isViewId, resolveRouteId, ROUTE_IDS } from "../src/web/src/ui-catalog";

/* ────────────────────────────────────────────────────────────────────
   (a) Streaming parity: block-memoized incremental render must converge
   to byte-identical output vs. a one-shot mdToHtml() render, for each
   fixture fed in char-by-char (the worst case for block splitting: every
   possible mid-block boundary gets exercised as the "live tail").
   ──────────────────────────────────────────────────────────────────── */
describe("streaming parity: renderBlocksIncremental vs one-shot mdToHtml", () => {
  const fixtures: Record<string, string> = {
    plain: "Just a plain sentence with no markdown at all.",
    headings: "# Title\n\nSome intro text.\n\n## Subheading\n\nMore body text here.",
    lists: "Intro line.\n\n- one\n- two\n- three\n\n1. first\n2. second\n\n- [ ] todo\n- [x] done",
    tables: "| a | b |\n| - | - |\n| 1 | 2 |\n| 3 | 4 |\n\nAfter-table paragraph.",
    "closed fence": "Before.\n\n```js\nconst x = 1;\nconsole.log(x);\n```\n\nAfter.",
    "still-open fence": "Before.\n\n```python\ndef f():\n    return 1\n",
    mixed:
      "# Report\n\nSome **bold** and _italic_ text with a [link](https://example.com).\n\n" +
      "- item one\n- item two\n\n```ts\nconst y: number = 2;\n```\n\n" +
      "| col1 | col2 |\n| - | - |\n| x | y |\n\n> a blockquote\n> continues here\n\nFinal paragraph.",
  };

  for (const [name, fullText] of Object.entries(fixtures)) {
    it(`converges for fixture: ${name}`, () => {
      const container = document.createElement("div");
      const state: BlockState = { blocks: [] };
      // Feed char by char — the worst case for the live-tail/done-block
      // boundary logic in splitBlocks/renderBlocksIncremental.
      for (let i = 1; i <= fullText.length; i++) {
        renderBlocksIncremental(container, fullText.slice(0, i), state);
      }
      // Final full non-memoized pass — same as finishStreaming() in
      // chat.ts (the acceptance test the design doc calls the "ground
      // truth"). The INVARIANT under test is actually stronger than "the
      // final state matches": the incremental container's rendered HTML,
      // right before any final pass, must already equal a one-shot
      // render — otherwise a final full pass would be silently papering
      // over a real streaming bug.
      //
      // Each top-level child of `container` is exactly one block's own
      // wrapper <div class="md-block[ done]">; concatenating each
      // wrapper's innerHTML (not outerHTML) reconstructs what a one-shot
      // mdToHtml(fullText) would have produced, since mdToHtml has no
      // concept of block wrappers at all. This avoids fragile string
      // surgery on the full innerHTML (which would also mangle unrelated
      // </div> tags from tables/code blocks/blockquotes nested INSIDE a
      // block, not just the block wrapper itself).
      const reconstructed = [...container.children].map((c) => c.innerHTML).join("");
      // Round-trip the one-shot render through the DOM too (a fresh
      // element's innerHTML set-then-read), so both sides are compared
      // after the same HTML-serialization normalization (e.g. boolean
      // attributes like `disabled`/`checked` round-trip as `disabled=""`
      // in some engines) — the real invariant is "same DOM," not
      // "identical source string," and finishStreaming() in chat.ts does
      // exactly this same innerHTML-assignment for its ground-truth pass.
      const oneShotContainer = document.createElement("div");
      oneShotContainer.innerHTML = mdToHtml(fullText);
      expect(reconstructed).toBe(oneShotContainer.innerHTML);
    });
  }

  it("highlightIn is idempotent and safe with no hljs global present", () => {
    const container = document.createElement("div");
    container.innerHTML = mdToHtml("```js\nconst x = 1;\n```");
    // No `hljs` global in this test environment — highlightIn must no-op
    // safely (guarded by `typeof hljs === "undefined"`), not throw.
    expect(() => highlightIn(container)).not.toThrow();
    expect(() => highlightIn(container)).not.toThrow();
  });

  it("makeFrameScheduler coalesces multiple calls within one frame into one render", async () => {
    let renders = 0;
    const schedule = makeFrameScheduler(() => { renders++; });
    schedule(); schedule(); schedule();
    await new Promise((r) => requestAnimationFrame(() => r(undefined)));
    expect(renders).toBe(1);
  });

  it("splitBlocks marks an open fence as not-done and a closed fence as done", () => {
    const openFence = splitBlocks("```js\nconst x = 1;\n");
    expect(openFence[openFence.length - 1]!.done).toBe(false);
    const closedFence = splitBlocks("```js\nconst x = 1;\n```\n");
    expect(closedFence[closedFence.length - 1]!.done).toBe(true);
  });
});

describe("chat turn rendering lifecycle", () => {
  it("finishes a turn before its queued frame render without touching cleared state", async () => {
    const html = await Bun.file("src/web/app.html").text();
    document.body.innerHTML = html.match(/<body[^>]*>([\s\S]*?)<\/body>/)?.[1] || "";
    localStorage.clear();

    class FakeWebSocket {
      static last: FakeWebSocket | null = null;
      readyState = 0;
      onopen: ((event: Event) => void) | null = null;
      onclose: ((event: Event) => void) | null = null;
      onerror: ((event: Event) => void) | null = null;
      onmessage: ((event: MessageEvent) => void) | null = null;

      constructor(readonly url: string) { FakeWebSocket.last = this; }
      send(_data: string): void {}
      emit(value: unknown): void {
        this.onmessage?.(new MessageEvent("message", { data: JSON.stringify(value) }));
      }
      open(): void {
        this.readyState = 1;
        this.onopen?.(new Event("open"));
      }
    }

    const originalFetch = globalThis.fetch;
    const originalWebSocket = globalThis.WebSocket;
    const originalRequestAnimationFrame = globalThis.requestAnimationFrame;
    const pendingFrames: FrameRequestCallback[] = [];
    globalThis.fetch = (async () => Response.json({ ok: true })) as unknown as typeof fetch;
    globalThis.WebSocket = FakeWebSocket as unknown as typeof WebSocket;
    globalThis.requestAnimationFrame = ((callback: FrameRequestCallback) => {
      pendingFrames.push(callback);
      return pendingFrames.length;
    }) as typeof requestAnimationFrame;
    try {
      const controller = createChatController();
      controller.init();
      controller.enter();
      const socket = FakeWebSocket.last;
      expect(socket).not.toBeNull();
      socket!.open();
      socket!.emit({ type: "turn_start" });
      socket!.emit({ type: "text_delta", delta: "A normal streamed answer." });
      socket!.emit({ type: "turn_end", lane: "batched" });

      expect(() => {
        for (const callback of pendingFrames) callback(performance.now());
      }).not.toThrow();
      expect(document.querySelector(".msg.assistant .atext")?.textContent).toBe("A normal streamed answer.");
      expect((document.getElementById("chat-send") as HTMLButtonElement).disabled).toBe(false);
    } finally {
      globalThis.fetch = originalFetch;
      globalThis.WebSocket = originalWebSocket;
      globalThis.requestAnimationFrame = originalRequestAnimationFrame;
    }
  });
});

/* ────────────────────────────────────────────────────────────────────
   Canvas v1 (plan §9 Phase 3, beat matrix Axis 2): fence-language
   detection is a pure predicate (isCanvasFence) so it's tested directly
   without a DOM, plus a check that mdCodeBlock only emits the
   Preview|Source toggle markup for qualifying languages.
   ──────────────────────────────────────────────────────────────────── */
describe("Canvas v1: fence detection", () => {
  it("recognizes html and svg fences (case-insensitive, incl. htm alias)", () => {
    expect(isCanvasFence("html")).toBe(true);
    expect(isCanvasFence("HTML")).toBe(true);
    expect(isCanvasFence("htm")).toBe(true);
    expect(isCanvasFence("svg")).toBe(true);
    expect(isCanvasFence("SVG")).toBe(true);
  });

  it("rejects js/ts/plain/empty fences", () => {
    expect(isCanvasFence("js")).toBe(false);
    expect(isCanvasFence("javascript")).toBe(false);
    expect(isCanvasFence("ts")).toBe(false);
    expect(isCanvasFence("python")).toBe(false);
    expect(isCanvasFence("")).toBe(false);
  });

  it("mdCodeBlock emits a Preview|Source toggle for an html fence", () => {
    const html = mdCodeBlock("html", "<h1>hi</h1>");
    expect(html).toContain("cbtoggle");
    expect(html).toContain("cbview-preview");
    expect(html).toContain("cbview-source");
    expect(html).toContain("cbcanvas");
    // Raw source is stashed verbatim (entity-escaped, non-executing, and
    // NOT inside a <script> tag — script/style content isn't entity-decoded
    // by .textContent, which would corrupt the round-trip; see markdown.ts)
    // for wireCanvasToggle's lazy iframe creation.
    expect(html).toContain('<div class="cbsrc" hidden>');
  });

  it("mdCodeBlock emits a Preview|Source toggle for an svg fence", () => {
    const svg = mdCodeBlock("svg", "<svg></svg>");
    expect(svg).toContain("cbtoggle");
  });

  it("mdCodeBlock does NOT emit a toggle for a js fence", () => {
    const js = mdCodeBlock("js", "const x = 1;");
    expect(js).not.toContain("cbtoggle");
    expect(js).not.toContain("cbcanvas");
    expect(js).not.toContain("cbsrc");
  });

  it("mdCodeBlock does NOT emit a toggle for an untagged fence", () => {
    const plain = mdCodeBlock("", "some text");
    expect(plain).not.toContain("cbtoggle");
  });

  it("mdToHtml end-to-end: an html fence in a full document gets the toggle, a js fence does not", () => {
    const doc = "```html\n<p>hi</p>\n```\n\n```js\nconst x = 1;\n```\n";
    const out = mdToHtml(doc);
    const htmlBlockToggles = (out.match(/cbtoggle/g) || []).length;
    expect(htmlBlockToggles).toBe(1); // exactly the html block, not the js block
  });

  it("escapes the stashed raw source so it can never break out of the .cbsrc div", () => {
    const html = mdCodeBlock("html", "</div><img src=x onerror=alert(1)>");
    // esc() must have neutralized the closing tag inside the stash — an
    // unescaped </div> here would close .cbsrc early and inject a live
    // <img onerror> into the surrounding chat/memory-panel DOM (this stash
    // is a plain element specifically so .textContent entity-decodes it
    // back to the model's exact literal string, but that only matters if
    // it's escaped correctly when serialized in the first place).
    expect(html).not.toContain("</div><img");
  });
});

/* ────────────────────────────────────────────────────────────────────
   Canvas v1 view-state survives finishStreaming's full re-render (review
   finding, chat.ts finishStreaming): the turn-end pass replaces
   textNode.innerHTML wholesale with a fresh mdToHtml(text), and mdCodeBlock
   always emits qualifying fences back in their default Source view — a
   user's mid-stream Preview click must not silently revert. chat.ts wires
   this via captureCanvasViewStates (before the re-render) +
   restoreCanvasViewStates (after).
   ──────────────────────────────────────────────────────────────────── */
describe("Canvas v1: view state survives a full re-render", () => {
  it("captureCanvasViewStates finds no Preview blocks by default (Source is the initial state)", () => {
    const container = document.createElement("div");
    container.innerHTML = mdToHtml("```html\n<p>a</p>\n```\n\n```html\n<p>b</p>\n```\n");
    expect(captureCanvasViewStates(container)).toEqual([]);
  });

  it("restoreCanvasViewStates re-applies Preview after innerHTML is replaced (finishStreaming's exact sequence)", () => {
    const container = document.createElement("div");
    const text = "```html\n<p>a</p>\n```\n\n```html\n<p>b</p>\n```\n";
    container.innerHTML = mdToHtml(text);
    wireCanvasToggle(container);
    // User toggles the SECOND block to Preview mid-stream.
    const blocks = container.querySelectorAll(".codeblock.has-canvas");
    (blocks[1]!.querySelector(".cbview-preview") as HTMLElement).click();
    expect(blocks[1]!.querySelector(".cbview-preview")!.classList.contains("active")).toBe(true);

    // finishStreaming's sequence: capture, replace innerHTML, restore.
    const previewIdx = captureCanvasViewStates(container);
    expect(previewIdx).toEqual([1]);
    container.innerHTML = mdToHtml(text); // full non-memoized re-render, same as chat.ts
    // Freshly rendered blocks default back to Source (the bug, absent the fix).
    const freshBlocks = container.querySelectorAll(".codeblock.has-canvas");
    expect(freshBlocks[1]!.querySelector(".cbview-preview")!.classList.contains("active")).toBe(false);

    restoreCanvasViewStates(container, previewIdx);
    const restored = container.querySelectorAll(".codeblock.has-canvas");
    expect(restored[1]!.querySelector(".cbview-preview")!.classList.contains("active")).toBe(true);
    expect(restored[1]!.querySelector(".cbview-source")!.classList.contains("active")).toBe(false);
    // The first block (never toggled) stays on Source, untouched.
    expect(restored[0]!.querySelector(".cbview-source")!.classList.contains("active")).toBe(true);
  });

  it("restoreCanvasViewStates is a no-op when nothing was in Preview", () => {
    const container = document.createElement("div");
    container.innerHTML = mdToHtml("```html\n<p>a</p>\n```\n");
    restoreCanvasViewStates(container, []);
    const block = container.querySelector(".codeblock.has-canvas")!;
    expect(block.querySelector(".cbview-source")!.classList.contains("active")).toBe(true);
  });
});

/* ────────────────────────────────────────────────────────────────────
   (b) renderQueue length/array semantics (web-ui-pass-plan.md #2): an
   empty steering/followUp array must render nothing (not the truthy-array
   bug where `q.steering` alone gated visibility).
   ──────────────────────────────────────────────────────────────────── */
describe("renderQueue array-length semantics", () => {
  beforeEach(() => {
    document.body.innerHTML = '<div id="chat-queue"></div>';
  });

  it("hides the bar when steering/followUp are both empty arrays (not undefined)", () => {
    renderQueue({ steering: [], followUp: [] });
    const bar = document.getElementById("chat-queue")!;
    expect(bar.style.display).toBe("none");
    expect(bar.innerHTML).toBe("");
  });

  it("hides the bar when steering/followUp are omitted entirely", () => {
    renderQueue({});
    const bar = document.getElementById("chat-queue")!;
    expect(bar.style.display).toBe("none");
  });

  it("shows the latest steering note only (not the whole history)", () => {
    renderQueue({ steering: ["first", "second", "latest"], followUp: [] });
    const bar = document.getElementById("chat-queue")!;
    expect(bar.style.display).toBe("flex");
    expect(bar.innerHTML).toContain("latest");
    expect(bar.innerHTML).not.toContain("first");
  });

  it("shows one pill per queued follow-up", () => {
    renderQueue({ steering: [], followUp: ["a", "b", "c"] });
    const bar = document.getElementById("chat-queue")!;
    const matches = bar.innerHTML.match(/qtag/g) || [];
    expect(matches.length).toBe(3);
  });
});

/* ────────────────────────────────────────────────────────────────────
   (c) api() error-envelope unwrapping (web-ui-pass-plan.md #4): an
   OpenAI-style {error:{message}} object must unwrap to a plain string,
   never surface as "[object Object]".
   ──────────────────────────────────────────────────────────────────── */
describe("api() error-envelope unwrapping", () => {
  // Each test stubs globalThis.fetch and restores it in a finally block
  // (rather than a shared afterEach) so a thrown assertion still leaves
  // fetch un-clobbered for the next test.
  const originalFetch = globalThis.fetch;

  it("unwraps a nested {error:{message}} object to a plain string", async () => {
    globalThis.fetch = (async () =>
      new Response(JSON.stringify({ error: { message: "model not found", code: 404 } }), {
        status: 404,
      })) as unknown as typeof fetch;
    try {
      const d = await api("/v1/whatever");
      expect(typeof d.error).toBe("string");
      expect(d.error).toBe("model not found");
      expect(String(d.error)).not.toContain("[object Object]");
    } finally {
      globalThis.fetch = originalFetch;
    }
  });

  it("falls back to a stringified error object when no .message field exists", async () => {
    globalThis.fetch = (async () =>
      new Response(JSON.stringify({ error: { code: 500 } }), { status: 500 })) as unknown as typeof fetch;
    try {
      const d = await api("/v1/whatever");
      expect(typeof d.error).toBe("string");
      expect(d.error).not.toBe("[object Object]");
    } finally {
      globalThis.fetch = originalFetch;
    }
  });

  it("passes a plain string error through unchanged", async () => {
    globalThis.fetch = (async () =>
      new Response(JSON.stringify({ ok: false, error: "plain string error" }), { status: 400 })) as unknown as typeof fetch;
    try {
      const d = await api("/v1/whatever");
      expect(d.error).toBe("plain string error");
    } finally {
      globalThis.fetch = originalFetch;
    }
  });

  it("synthesizes an HTTP-status error when the body is empty/unparseable and the response was not ok", async () => {
    globalThis.fetch = (async () => new Response("", { status: 503 })) as unknown as typeof fetch;
    try {
      const d = await api("/v1/whatever");
      expect(d.ok).toBe(false);
      expect(String(d.error)).toContain("503");
    } finally {
      globalThis.fetch = originalFetch;
    }
  });
});

/* ────────────────────────────────────────────────────────────────────
   (d) esc() discipline on the adapter-option template path
   (web-ui-pass-plan.md #15): a live unescaped-HTML injection point in the
   original app.html — an adapter id/path containing HTML-significant
   characters must never break out of its attribute/element.
   ──────────────────────────────────────────────────────────────────── */
describe("esc() discipline: adapter <option> template", () => {
  it("escapes a malicious adapter id so it cannot inject markup", () => {
    const list: AdapterInfo[] = [
      { id: '"><script>alert(1)</script>', path: "/tmp/x", compatible: true },
    ];
    const html = renderAdapterOptionsHtml(list);
    expect(html).not.toContain("<script>alert(1)</script>");
    expect(html).toContain("&lt;script&gt;");
  });

  it("escapes the base_model field used in the incompatible-option title", () => {
    const list: AdapterInfo[] = [
      { id: "safe-id", path: "/tmp/y", compatible: false, base_model: '"><b>owned</b>' },
    ];
    const html = renderAdapterOptionsHtml(list);
    expect(html).not.toContain("<b>owned</b>");
  });

  it("renders a normal compatible adapter option with its path as a data attribute", () => {
    const list: AdapterInfo[] = [
      { id: "my-lora", path: "/adapters/my-lora", rank: 8, mounted: true, compatible: true },
    ];
    const html = renderAdapterOptionsHtml(list);
    expect(html).toContain('data-path="/adapters/my-lora"');
    expect(html).toContain("· r8");
    expect(html).toContain("· mounted");
  });

  it("marks an incompatible adapter disabled with an explanatory title", () => {
    const list: AdapterInfo[] = [
      { id: "wrong-base", path: "/adapters/wrong-base", compatible: false, base_model: "gemma3-12b" },
    ];
    const html = renderAdapterOptionsHtml(list);
    expect(html).toContain("disabled");
    expect(html).toContain("trained for gemma3-12b");
  });
});

/* ────────────────────────────────────────────────────────────────────
   (e) Memory provenance chips (plan §5.4.2): the frontend's literal
   MEMORY_CHIP_TOOL_NAMES list (memory-panel.ts can't import
   src/memory/tools.ts's value export — see that file's header comment on
   staying server-code-free) must never drift from the real
   MEMORY_TOOL_NAMES/REFERENCE_TOOL_NAMES the server actually registers.
   ──────────────────────────────────────────────────────────────────── */
describe("memory provenance chip: tool-name list stays in sync with src/memory/tools.ts", () => {
  it("MEMORY_CHIP_TOOL_NAMES is exactly MEMORY_TOOL_NAMES + REFERENCE_TOOL_NAMES", () => {
    const expected = [...MEMORY_TOOL_NAMES, ...REFERENCE_TOOL_NAMES].slice().sort();
    const actual = [...MEMORY_CHIP_TOOL_NAMES].slice().sort();
    expect(actual).toEqual(expected);
  });

  it("isMemoryToolName agrees with the real tool name lists, both directions", () => {
    for (const name of [...MEMORY_TOOL_NAMES, ...REFERENCE_TOOL_NAMES]) {
      expect(isMemoryToolName(name)).toBe(true);
    }
    expect(isMemoryToolName("bash")).toBe(false);
    expect(isMemoryToolName("edit")).toBe(false);
  });
});

/* ────────────────────────────────────────────────────────────────────
   (f) esc() discipline on the provenance chip's label/result (memory tool
   args and results are model/vault data — a maliciously-crafted article
   name or tool result must never break out of the chip's markup).
   ──────────────────────────────────────────────────────────────────── */
describe("esc() discipline: memory provenance chip", () => {
  it("escapes an article name pulled from tool args into the chip label", () => {
    const parent = document.createElement("div");
    memoryToolChip(parent, "memory_read", { article: '"><script>alert(1)</script>' });
    expect(parent.innerHTML).not.toContain("<script>alert(1)</script>");
    expect(parent.innerHTML).toContain("&lt;script&gt;");
  });

  it("escapes a malicious tool result via setResult (textContent, never innerHTML)", () => {
    const parent = document.createElement("div");
    const handle = memoryToolChip(parent, "memory_search", { query: "test" });
    handle.setResult('<img src=x onerror="alert(1)">');
    // setResult uses .textContent (never .innerHTML), so no live <img> tag
    // is ever parsed into the DOM — the serialized innerHTML shows the
    // literal markup HTML-entity-escaped, not as a real element.
    const resultEl = parent.querySelector(".mcresult")!;
    expect(resultEl.querySelector("img")).toBeNull();
    expect(parent.innerHTML).toContain("&lt;img src=x onerror=");
  });

  it("renders no article name gracefully when args carry none", () => {
    const parent = document.createElement("div");
    expect(() => memoryToolChip(parent, "memory_status", {})).not.toThrow();
    expect(parent.querySelector(".mcopen")).toBeNull(); // no "Open in Memory" without a resolvable article
  });
});

/* ────────────────────────────────────────────────────────────────────
   Adapter routing table (plan §5.6/§9 Phase 2): esc() discipline on every
   interpolated field (id/path/base_model are on-disk directory names and
   config strings — user-controlled, same hazard class as #15's adapter
   <option> bug) plus the three-state row logic (mounted/selected/stacking).
   ──────────────────────────────────────────────────────────────────── */
describe("adapter routing table: renderAdapterRow", () => {
  const base = (over: Partial<AvailableAdapterRow> = {}): AvailableAdapterRow => ({
    id: "sft", path: "/adapters/sft", rank: 8, scale: 20, base_model: "org/model", mounted: false, compatible: true,
    ...over,
  });

  it("escapes a malicious id/path/base_model into every interpolation site", () => {
    const a = base({
      id: '"><img src=x onerror=alert(1)>',
      path: '"><script>alert(2)</script>',
      base_model: '"><script>alert(3)</script>',
      compatible: false,
    });
    const html = renderAdapterRow(a, { mountedInfo: undefined, isSelected: false, stackPicked: false, stackModeOn: false });
    expect(html).not.toContain("<img src=x onerror=");
    expect(html).not.toContain("<script>alert(2)</script>");
    expect(html).not.toContain("<script>alert(3)</script>");
    expect(html).toContain("&lt;img src=x onerror=");
  });

  it("shows Mount for an unmounted compatible adapter, no stacking checkbox outside stack mode", () => {
    const html = renderAdapterRow(base(), { mountedInfo: undefined, isSelected: false, stackPicked: false, stackModeOn: false });
    expect(html).toContain('class="ad-mount"');
    expect(html).not.toContain("ad-stack-pick");
    expect(html).not.toContain("mounted</span>");
  });

  it("shows Select for a mounted, unselected adapter", () => {
    const mounted: MountedAdapterRow = { id: "sft", path: "/adapters/sft", rank: 8, scale: 20, size_bytes: 1024, mounted_layers: 28, ram_bytes: 2048 };
    const html = renderAdapterRow(base(), { mountedInfo: mounted, isSelected: false, stackPicked: false, stackModeOn: false });
    expect(html).toContain('class="ad-select primary"');
    expect(html).toContain("mounted</span>");
    expect(html).not.toContain("selected</span>");
  });

  it("shows Unselect and the selected badge for a mounted, selected adapter", () => {
    const mounted: MountedAdapterRow = { id: "sft", path: "/adapters/sft", rank: 8, scale: 20, size_bytes: 1024, mounted_layers: 28, ram_bytes: 2048 };
    const html = renderAdapterRow(base(), { mountedInfo: mounted, isSelected: true, stackPicked: false, stackModeOn: false });
    expect(html).toContain('class="ad-unselect"');
    expect(html).toContain("selected</span>");
  });

  it("shows the RAM cost only once mounted (never guessed from disk size)", () => {
    const mounted: MountedAdapterRow = { id: "sft", path: "/adapters/sft", rank: 8, scale: 20, size_bytes: 1024, mounted_layers: 28, ram_bytes: 2048 };
    const unmountedHtml = renderAdapterRow(base(), { mountedInfo: undefined, isSelected: false, stackPicked: false, stackModeOn: false });
    const mountedHtml = renderAdapterRow(base(), { mountedInfo: mounted, isSelected: false, stackPicked: false, stackModeOn: false });
    expect(unmountedHtml).not.toContain("RAM <b>");
    expect(mountedHtml).toContain("RAM <b>2.0 KB</b>");
  });

  it("grays an incompatible adapter and explains why, with no actions", () => {
    const html = renderAdapterRow(base({ compatible: false, base_model: "other-org/other-model" }), {
      mountedInfo: undefined, isSelected: false, stackPicked: false, stackModeOn: false,
    });
    expect(html).toContain("ad-row incompatible");
    expect(html).toContain("trained for other-org/other-model");
    expect(html).not.toContain("ad-mount");
    expect(html).not.toContain("ad-select");
  });

  it("offers the stack checkbox only in stack mode, disabled until mounted", () => {
    const html = renderAdapterRow(base(), { mountedInfo: undefined, isSelected: false, stackPicked: false, stackModeOn: true });
    expect(html).toContain("ad-stack-pick");
    expect(html).toContain("disabled");
  });
});

describe("adapter routing table: renderAdaptersBodyHtml", () => {
  it("renders an empty-state with no fetch/DOM dependency when nothing is on disk", () => {
    const state = new AdaptersPanelState();
    expect(renderAdaptersBodyHtml(state)).toContain("No adapters found on disk yet");
  });

  it("renders the stack bar once two ids are picked, with the composed a+b expression escaped", () => {
    const state = new AdaptersPanelState();
    state.available = [
      { id: "sft", path: "/a/sft", rank: 8, scale: 20, base_model: "org/model", mounted: true, compatible: true },
      { id: "dpo", path: "/a/dpo", rank: 8, scale: 20, base_model: "org/model", mounted: true, compatible: true },
    ];
    state.mounted = new Map([
      ["sft", { id: "sft", path: "/a/sft", rank: 8, scale: 20, size_bytes: 100, mounted_layers: 28, ram_bytes: 200 }],
      ["dpo", { id: "dpo", path: "/a/dpo", rank: 8, scale: 20, size_bytes: 100, mounted_layers: 28, ram_bytes: 200 }],
    ]);
    state.stackPicks = new Set(["sft", "dpo"]);
    const html = renderAdaptersBodyHtml(state);
    expect(html).toContain("ad-stack-bar");
    expect(html).toContain("sft + dpo");
    expect(html).toContain("ad-stack-apply");
  });
});

/* ────────────────────────────────────────────────────────────────────
   Model picker (plan §5.6/§9 Phase 2): fit-verdict thresholds and esc()
   discipline on repo ids (HF strings, user/model-controlled) interpolated
   into the popover body and the copy-able restart command.
   ──────────────────────────────────────────────────────────────────── */
describe("model picker: fitVerdict", () => {
  it("is null with no assessment, red when it doesn't fit", () => {
    expect(fitVerdict(null)).toBeNull();
    expect(fitVerdict({ fits: false, max_safe_context: 8192, predicted_decode_tps: 0 })).toBe("red");
  });
  it("is green at/above 10 tok/s, yellow below it, only when it fits", () => {
    expect(fitVerdict({ fits: true, max_safe_context: 8192, predicted_decode_tps: 10 })).toBe("green");
    expect(fitVerdict({ fits: true, max_safe_context: 8192, predicted_decode_tps: 9.9 })).toBe("yellow");
  });
});

describe("model picker: renderModelPopBodyHtml", () => {
  const row = (over: Partial<LibraryRow> = {}): LibraryRow => ({
    repo_id: "mlx-community/gemma-4-e4b-it", model_type: "gemma4", size_bytes: 4 * 2 ** 30,
    quant_bits: 4, vision: false, supported: true, support_tier: "targeted", serving: false,
    assessment: { fits: true, max_safe_context: 8192, predicted_decode_tps: 42 },
    ...over,
  });

  it("shows an empty-state pointing at `mlx-bun get`", () => {
    expect(renderModelPopBodyHtml([])).toContain("mlx-bun get");
  });

  it("escapes a malicious repo id everywhere it's interpolated, including the copy command", () => {
    const html = renderModelPopBodyHtml([row({ repo_id: '"><script>alert(1)</script>/model' })]);
    expect(html).not.toContain("<script>alert(1)</script>");
    expect(html).toContain("&lt;script&gt;");
  });

  it("puts the currently-serving model first and omits its restart command", () => {
    const html = renderModelPopBodyHtml([
      row({ repo_id: "org/a", serving: false }),
      row({ repo_id: "org/b", serving: true }),
    ]);
    expect(html.indexOf("org/b")).toBeLessThan(html.indexOf("org/a"));
    const servingRowEnd = html.indexOf("org/a"); // everything before the second row is the serving row
    expect(html.slice(0, servingRowEnd)).not.toContain("mp-cmd");
  });

  it("never offers a restart command for an unsupported model family", () => {
    const html = renderModelPopBodyHtml([row({ supported: false, assessment: null })]);
    expect(html).not.toContain("mp-cmd");
    expect(html).toContain("unsupported model family");
  });
});

/* ────────────────────────────────────────────────────────────────────
   Unified "#" retrieval mention (plan §5.2/§9 Phase 2): detectMentionQuery
   (caret-aware span detection), filterFileMentions/buildMentionItems (pure
   list assembly), applyMention (pure text-splice insertion), and esc()
   discipline on renderMentionListHtml — the same pure/DOM split as the
   adapter-option and model-pop templates above.
   ──────────────────────────────────────────────────────────────────── */
describe("mention picker: detectMentionQuery", () => {
  it("detects an open '#query' span right at the caret", () => {
    expect(detectMentionQuery("hello #rep", 10)).toEqual({ hashIndex: 6, query: "rep" });
  });

  it("detects a bare '#' with an empty query", () => {
    expect(detectMentionQuery("#", 1)).toEqual({ hashIndex: 0, query: "" });
  });

  it("returns null once the mention span is closed by whitespace", () => {
    expect(detectMentionQuery("hello #report done", 19)).toBeNull();
  });

  it("returns null for 'C#' style tokens (hash preceded by a word char)", () => {
    expect(detectMentionQuery("I use C#", 8)).toBeNull();
    expect(detectMentionQuery("issue#12", 8)).toBeNull();
  });

  it("returns null when there's no '#' before the caret at all", () => {
    expect(detectMentionQuery("just plain text", 10)).toBeNull();
  });

  it("finds the nearest '#' when the caret sits mid-message after an earlier one", () => {
    // Two hashes in the message; caret is inside the second span only.
    const text = "look at #filea.txt and #par";
    expect(detectMentionQuery(text, text.length)).toEqual({ hashIndex: 23, query: "par" });
  });
});

describe("mention picker: filterFileMentions", () => {
  const atts: Attachment[] = [
    { id: 1, kind: "text", name: "report.md" },
    { id: 2, kind: "image", name: "photo.png" },
    { id: 3, kind: "text", name: "REPORT-final.txt" },
  ];

  it("returns everything (capped) for an empty query", () => {
    const out = filterFileMentions(atts, "");
    expect(out.map((m) => (m as { name: string }).name)).toEqual(["report.md", "photo.png", "REPORT-final.txt"]);
  });

  it("matches case-insensitively on a substring", () => {
    const out = filterFileMentions(atts, "report");
    expect(out.map((m) => (m as { name: string }).name)).toEqual(["report.md", "REPORT-final.txt"]);
  });

  it("returns file-kind MentionItems with the attachment id preserved", () => {
    const out = filterFileMentions(atts, "photo");
    expect(out).toEqual([{ kind: "file", id: 2, name: "photo.png" }]);
  });

  it("returns an empty list when nothing matches", () => {
    expect(filterFileMentions(atts, "zzz-nomatch")).toEqual([]);
  });
});

describe("mention picker: buildMentionItems", () => {
  it("puts file matches first, then articles, both capped independently", () => {
    const files: MentionItem[] = [{ kind: "file", id: 1, name: "a.txt" }];
    const items = buildMentionItems(files, ["Some_Article", "Other_Article"]);
    expect(items).toEqual([
      { kind: "file", id: 1, name: "a.txt" },
      { kind: "article", name: "Some_Article" },
      { kind: "article", name: "Other_Article" },
    ]);
  });

  it("works with zero files (no vault attachments) — articles only", () => {
    const items = buildMentionItems([], ["Solo_Article"]);
    expect(items).toEqual([{ kind: "article", name: "Solo_Article" }]);
  });

  it("works with zero articles (no vault) — files only", () => {
    const files: MentionItem[] = [{ kind: "file", id: 1, name: "a.txt" }];
    expect(buildMentionItems(files, [])).toEqual(files);
  });
});

describe("mention picker: applyMention", () => {
  it("inserts a bracketed wikilink for an article, with a trailing space, at the hash span", () => {
    const text = "tell me about #proj please";
    const q: MentionQuery = { hashIndex: 14, query: "proj" };
    const caret = 19; // right after "proj"
    const result = applyMention(text, q, { kind: "article", name: "Project_Atlas" }, caret);
    expect(result.text).toBe("tell me about [[Project_Atlas]]  please");
    // Caret lands right after the inserted "[[Project_Atlas]] " (including its trailing space).
    expect(result.text.slice(0, result.caret)).toBe("tell me about [[Project_Atlas]] ");
  });

  it("deletes the '#query' span with no insertion for a file mention", () => {
    const text = "see #rep for details";
    const q: MentionQuery = { hashIndex: 4, query: "rep" };
    const caret = 8; // right after "rep"
    const result = applyMention(text, q, { kind: "file", id: 1, name: "report.md" }, caret);
    expect(result.text).toBe("see  for details");
    expect(result.caret).toBe(4);
  });

  it("preserves text after the caret untouched (mid-message insertion)", () => {
    const text = "#hi there, ignore this tail";
    const q: MentionQuery = { hashIndex: 0, query: "hi" };
    const caret = 3;
    const result = applyMention(text, q, { kind: "article", name: "Hi" }, caret);
    expect(result.text.endsWith(" there, ignore this tail")).toBe(true);
  });
});

describe("esc() discipline: mention picker list", () => {
  it("escapes a malicious file name", () => {
    const items: MentionItem[] = [{ kind: "file", id: 1, name: '"><script>alert(1)</script>.txt' }];
    const html = renderMentionListHtml(items, 0, true);
    expect(html).not.toContain("<script>alert(1)</script>");
    expect(html).toContain("&lt;script&gt;");
  });

  it("escapes a malicious article name and underscores render as spaces", () => {
    const items: MentionItem[] = [{ kind: "article", name: '"><img src=x onerror=alert(1)>_Test' }];
    const html = renderMentionListHtml(items, 0, true);
    expect(html).not.toContain("<img src=x onerror=alert(1)>");
    expect(html).toContain("&lt;img");
    expect(html).toContain(" Test"); // underscore -> space, same display convention as memory-panel.ts
  });

  it("marks the selected index active and separates files from memory into labeled sections", () => {
    const items: MentionItem[] = [
      { kind: "file", id: 1, name: "a.txt" },
      { kind: "article", name: "B" },
    ];
    const html = renderMentionListHtml(items, 1, true);
    expect(html).toContain("Attached files");
    expect(html).toContain("Memory");
    // The second row (index 1, the article) should carry "active"; the first should not.
    const rows = html.split("mention-row").filter((_, i) => i > 0);
    expect(rows[0]!.startsWith('"')).toBe(true); // 'class="mention-row"...' — no " active" suffix
    expect(rows[1]!.startsWith(' active"')).toBe(true);
  });

  it("shows a memory-aware empty state when there's a vault vs. files-only when there isn't", () => {
    expect(renderMentionListHtml([], 0, true)).toContain("memory articles");
    expect(renderMentionListHtml([], 0, false)).not.toContain("memory articles");
    expect(renderMentionListHtml([], 0, false)).toContain("attached files");
  });
});

/* ────────────────────────────────────────────────────────────────────
   Model Hub panel (plan §9 Phase 3, beat-matrix Axis 3): pure render
   functions for the Downloaded and Search Hugging Face sections — same
   esc()-discipline + empty-state coverage as the model-pop tests above.
   ──────────────────────────────────────────────────────────────────── */
describe("Model Hub: renderHubLocalHtml", () => {
  const row = (over: Partial<HubLocalRow> = {}): HubLocalRow => ({
    repo_id: "mlx-community/gemma-4-e4b-it", model_type: "gemma4", size_bytes: 4 * 2 ** 30,
    quant_bits: 4, quant_group_size: 64, vision: false, supported: true, support_tier: "targeted",
    assessment: { fits: true, max_safe_context: 8192, predicted_decode_tps: 42 },
    ...over,
  });

  it("shows an empty state pointing at search when nothing is downloaded", () => {
    expect(renderHubLocalHtml([])).toContain("search Hugging Face");
  });

  it("escapes a malicious repo id everywhere it's interpolated, including the serve button", () => {
    const html = renderHubLocalHtml([row({ repo_id: '"><script>alert(1)</script>/model' })]);
    expect(html).not.toContain("<script>alert(1)</script>");
    expect(html).toContain("&lt;script&gt;");
  });

  it("offers a serve action for a supported model but not an unsupported one", () => {
    const html = renderHubLocalHtml([row({ repo_id: "org/supported" })]);
    expect(html).toContain("hub-serve-btn");
    const htmlUnsupported = renderHubLocalHtml([row({ repo_id: "org/unsupported", supported: false, assessment: null })]);
    expect(htmlUnsupported).not.toContain("hub-serve-btn");
    expect(htmlUnsupported).toContain("unsupported model family");
  });

  it("reflects the fit verdict as a dot class (green/yellow/red)", () => {
    const green = renderHubLocalHtml([row({ assessment: { fits: true, max_safe_context: 8192, predicted_decode_tps: 42 } })]);
    expect(green).toContain("hub-fit-dot green");
    const red = renderHubLocalHtml([row({ assessment: { fits: false, max_safe_context: 8192, predicted_decode_tps: 0 } })]);
    expect(red).toContain("hub-fit-dot red");
  });
});

describe("Model Hub: renderHubSearchHtml", () => {
  const row = (over: Partial<HubSearchRow> = {}): HubSearchRow => ({
    id: "mlx-community/gemma-3-1b-it-4bit", downloads: 5000, likes: 42, size_estimate: null,
    ...over,
  });

  it("shows an offline note distinct from a plain no-results state", () => {
    const offline = renderHubSearchHtml([], true, new Set());
    const empty = renderHubSearchHtml([], false, new Set());
    expect(offline).not.toBe(empty);
    expect(offline.toLowerCase()).toContain("hugging face");
  });

  it("escapes a malicious repo id in a search result row", () => {
    const html = renderHubSearchHtml([row({ id: '"><script>alert(1)</script>/model' })], false, new Set());
    expect(html).not.toContain("<script>alert(1)</script>");
    expect(html).toContain("&lt;script&gt;");
  });

  it("shows a Download button normally, and a downloading tag for an in-flight repo", () => {
    const html = renderHubSearchHtml([row({ id: "org/model" })], false, new Set(["org/model"]));
    expect(html).toContain("downloading");
    expect(html).not.toContain("hub-download-btn");
    const htmlIdle = renderHubSearchHtml([row({ id: "org/model" })], false, new Set());
    expect(htmlIdle).toContain("hub-download-btn");
  });
});

/* ────────────────────────────────────────────────────────────────────
   Chat-with-files RAG v1 (plan §9 Phase 3, beat matrix Axis 5 — optiq
   Lab's dependency-free BM25 bar). Covers: chunker boundaries, BM25
   ranking sanity (term overlap outranks none, term-frequency saturation),
   the inline-vs-RAG threshold decision, and the citation-map rendering
   guard ([n] markers only linkify when a source map exists for that
   message — never in an ordinary reply).
   ──────────────────────────────────────────────────────────────────── */
describe("rag.ts: chunkText boundaries", () => {
  it("returns no chunks for empty text", () => {
    expect(chunkText(1, "a.txt", "")).toEqual([]);
  });

  it("keeps a short single-paragraph file as one chunk covering the whole text", () => {
    const text = "Just one short paragraph, well under the target size.";
    const chunks = chunkText(1, "a.txt", text);
    expect(chunks.length).toBe(1);
    expect(chunks[0]!.text).toBe(text);
    expect(chunks[0]!.start).toBe(0);
    expect(chunks[0]!.end).toBe(text.length);
    expect(chunks[0]!.fileId).toBe(1);
    expect(chunks[0]!.fileName).toBe("a.txt");
  });

  it("every chunk's [start,end) slice of the original text equals its .text field", () => {
    const paras = Array.from({ length: 12 }, (_, i) => `Paragraph number ${i} `.repeat(20));
    const text = paras.join("\n\n");
    const chunks = chunkText(7, "doc.md", text);
    expect(chunks.length).toBeGreaterThan(1); // this fixture is well over CHUNK_TARGET
    for (const c of chunks) expect(text.slice(c.start, c.end)).toBe(c.text);
  });

  it("prefers paragraph boundaries: a chunk never ends mid-paragraph when a blank-line boundary is available nearby", () => {
    const paras = Array.from({ length: 10 }, (_, i) => `P${i}: ${"word ".repeat(40)}`.trim());
    const text = paras.join("\n\n");
    const chunks = chunkText(1, "b.md", text);
    // Every chunk boundary in the ORIGINAL text should land exactly on a
    // paragraph start (i.e. chunks partition the paragraph list, not the
    // raw character stream) — check each chunk's text is a clean join of
    // one or more whole paragraphs, never a truncated one.
    for (const c of chunks) {
      const trimmed = c.text;
      // A chunk's text must consist of whole paragraphs from the `paras`
      // list joined by blank lines — reconstructing by splitting on the
      // same separator and checking every piece is a full original
      // paragraph (exact membership) confirms no mid-paragraph cut.
      const pieces = trimmed.split(/\n\s*\n/);
      for (const piece of pieces) expect(paras).toContain(piece);
    }
  });

  it("gives an oversized single paragraph its own chunk rather than splitting it mid-word", () => {
    const huge = "x".repeat(3000); // no blank lines at all -> one paragraph, over CHUNK_TARGET
    const chunks = chunkText(1, "huge.txt", huge);
    expect(chunks.length).toBe(1);
    expect(chunks[0]!.text).toBe(huge);
  });

  it("chunkFiles never mixes chunks across files", () => {
    const chunks = chunkFiles([
      { id: 1, name: "a.txt", text: "alpha content here" },
      { id: 2, name: "b.txt", text: "beta content here" },
    ]);
    expect(chunks.every((c) => c.fileId === 1 || c.fileId === 2)).toBe(true);
    expect(chunks.find((c) => c.fileId === 1)!.fileName).toBe("a.txt");
    expect(chunks.find((c) => c.fileId === 2)!.fileName).toBe("b.txt");
  });
});

describe("rag.ts: tokenize", () => {
  it("lowercases and splits on non-alnum runs", () => {
    expect(tokenize("Hello, World! It's 2026.")).toEqual(["hello", "world", "it", "s", "2026"]);
  });
  it("returns an empty array for text with no alnum tokens", () => {
    expect(tokenize("--- *** ...")).toEqual([]);
  });
});

describe("rag.ts: BM25 ranking sanity", () => {
  const mkChunk = (fileId: number, fileName: string, text: string): Chunk => ({ fileId, fileName, start: 0, end: text.length, text });

  it("a chunk mentioning the query term outranks one that doesn't", () => {
    const chunks = [
      mkChunk(1, "on-topic.txt", "The quarterly revenue report shows strong growth in the enterprise segment."),
      mkChunk(2, "off-topic.txt", "The cat sat on the mat and watched the birds outside the window."),
    ];
    const index = buildIndex(chunks);
    const top = bm25TopK(index, "revenue growth", 5);
    expect(top.length).toBe(1); // the off-topic chunk has zero term overlap -> excluded entirely
    expect(top[0]!.chunk.fileName).toBe("on-topic.txt");
    expect(top[0]!.score).toBeGreaterThan(0);
  });

  it("ranks a chunk with higher query-term density above one with lower density (term-frequency saturation still favors more occurrences)", () => {
    const chunks = [
      mkChunk(1, "dense.txt", "Photosynthesis photosynthesis photosynthesis. Plants use photosynthesis to convert light into energy via photosynthesis."),
      mkChunk(2, "sparse.txt", "This document discusses several biology topics including one brief mention of photosynthesis among many other subjects unrelated to it at all."),
    ];
    const index = buildIndex(chunks);
    const top = bm25TopK(index, "photosynthesis", 5);
    expect(top.length).toBe(2);
    expect(top[0]!.chunk.fileName).toBe("dense.txt");
  });

  it("term-frequency saturation: BM25 score grows sublinearly, not linearly, with repeated term count", () => {
    // Two synthetic chunks of EQUAL length (so length-normalization is a
    // non-factor), one repeating the query term 2x, the other 20x. Under
    // saturating TF (BM25's k1 term), the 10x-more-repetitions chunk should
    // score well under 10x higher, not proportionally more.
    const pad = (s: string, n: number) => (s + " filler ").repeat(n);
    const low = mkChunk(1, "low.txt", pad("widget widget filler filler filler filler filler filler filler filler", 6));
    const high = mkChunk(2, "high.txt", pad("widget ".repeat(20) + "filler filler filler filler filler filler filler filler filler filler", 6));
    const index = buildIndex([low, high]);
    const top = bm25TopK(index, "widget", 5);
    const scoreLow = top.find((t) => t.chunk.fileName === "low.txt")!.score;
    const scoreHigh = top.find((t) => t.chunk.fileName === "high.txt")!.score;
    expect(scoreHigh).toBeGreaterThan(scoreLow); // more occurrences still scores higher...
    expect(scoreHigh / scoreLow).toBeLessThan(10); // ...but nowhere near the raw 10x term-count ratio
  });

  it("returns no chunks for a query with no tokens or an empty index", () => {
    const index = buildIndex([mkChunk(1, "a.txt", "some content")]);
    expect(bm25TopK(index, "   ", 5)).toEqual([]);
    expect(bm25TopK(buildIndex([]), "query", 5)).toEqual([]);
  });

  it("caps results at k", () => {
    const chunks = Array.from({ length: 10 }, (_, i) => mkChunk(i, `f${i}.txt`, `apple banana chunk number ${i} with apple mentioned`));
    const index = buildIndex(chunks);
    expect(bm25TopK(index, "apple", 3).length).toBe(3);
  });
});

describe("rag.ts: inline-vs-RAG threshold decision", () => {
  it("shouldRetrieve is false at/under the threshold, true just above it", () => {
    expect(shouldRetrieve(0)).toBe(false);
    expect(shouldRetrieve(INLINE_THRESHOLD_CHARS)).toBe(false);
    expect(shouldRetrieve(INLINE_THRESHOLD_CHARS + 1)).toBe(true);
  });

  function mkComposerState(files: { name: string; text: string }[]): ComposerState {
    const state = new ComposerState();
    state.attachments = files.map((f, i) => ({ id: i + 1, kind: "text" as const, name: f.name, text: f.text }));
    return state;
  }

  it("small attachments: buildMessageText inlines verbatim with zero citations (identical to pre-RAG behavior)", () => {
    const state = mkComposerState([{ name: "notes.txt", text: "A short note about the project." }]);
    const result = buildMessageText(state, "What does this say?");
    expect(result.citations).toEqual([]);
    expect(result.text).toContain("Attached file: notes.txt");
    expect(result.text).toContain("A short note about the project.");
    expect(result.text.endsWith("What does this say?")).toBe(true);
  });

  it("large attachments: buildMessageText switches to retrieval mode and injects numbered citations instead of the raw file", () => {
    const bigText = Array.from({ length: 40 }, (_, i) =>
      `Section ${i}: revenue figures for the enterprise segment show growth. `.repeat(6)).join("\n\n");
    expect(bigText.length).toBeGreaterThan(INLINE_THRESHOLD_CHARS);
    const state = mkComposerState([{ name: "report.txt", text: bigText }]);
    const result = buildMessageText(state, "Tell me about revenue growth");
    expect(result.citations.length).toBeGreaterThan(0);
    expect(result.text).not.toContain("Attached file: report.txt"); // raw-inline framing is gone in RAG mode
    expect(result.text).toContain("[1]");
    expect(result.text).toContain("cite it inline with the matching [n] marker");
    expect(result.text.endsWith("Tell me about revenue growth")).toBe(true); // user's message still lands at the end
  });

  it("multiple attached files stay under threshold individually but combine over it -> retrieval mode fires on the COMBINED total", () => {
    const chunk = "Paragraph about local inference performance and hardware. ".repeat(30); // ~1770 chars
    const files = Array.from({ length: 6 }, (_, i) => ({ name: `f${i}.txt`, text: chunk })); // ~10.6k combined
    const totalChars = files.reduce((n, f) => n + f.text.length, 0);
    expect(totalChars).toBeGreaterThan(INLINE_THRESHOLD_CHARS);
    const state = mkComposerState(files);
    const result = buildMessageText(state, "hardware performance");
    expect(result.citations.length).toBeGreaterThan(0);
  });

  it("large attachments with zero term overlap with the message fall back to the plain user text (no useless empty citation block)", () => {
    const bigText = "zzz ".repeat(3000); // over threshold, but shares no tokens with the query below
    const state = mkComposerState([{ name: "big.txt", text: bigText }]);
    const result = buildMessageText(state, "completely unrelated query about xyz123");
    expect(result.citations).toEqual([]);
    expect(result.text).toBe("completely unrelated query about xyz123");
  });

  it("retrieve() end-to-end: citations are numbered 1..K and carry filename + range", () => {
    const bigText = Array.from({ length: 30 }, (_, i) => `Topic ${i}: apples and oranges discussion. `.repeat(10)).join("\n\n");
    const citations = retrieve([{ id: 1, name: "fruit.txt", text: bigText }], "apples", 3);
    expect(citations.length).toBeLessThanOrEqual(3);
    citations.forEach((c, i) => {
      expect(c.n).toBe(i + 1);
      expect(c.fileName).toBe("fruit.txt");
      expect(c.end).toBeGreaterThan(c.start);
    });
  });

  it("buildContextBlock renders an empty string for no citations, and a framed block otherwise", () => {
    expect(buildContextBlock([])).toBe("");
    const citations: Citation[] = [{ n: 1, fileName: "a.txt", start: 0, end: 10, text: "hello there" }];
    const block = buildContextBlock(citations);
    expect(block).toContain("[1] a.txt");
    expect(block).toContain("hello there");
    expect(block).toContain("cite it inline with the matching [n] marker");
  });
});

describe("rag.ts: toCitations numbering", () => {
  it("numbers scored chunks 1..N in the given (already-sorted) order", () => {
    const chunk = (fileName: string): Chunk => ({ fileId: 1, fileName, start: 0, end: 5, text: "hello" });
    const citations = toCitations([
      { chunk: chunk("first.txt"), score: 5 },
      { chunk: chunk("second.txt"), score: 3 },
    ]);
    expect(citations.map((c) => c.n)).toEqual([1, 2]);
    expect(citations.map((c) => c.fileName)).toEqual(["first.txt", "second.txt"]);
  });
});

describe("Chat-with-files RAG v1: Sources panel rendering (chat.ts)", () => {
  it("renders nothing for an empty citation list", () => {
    expect(renderSourcesHtml([])).toBe("");
  });

  it("renders a collapsed 'Sources · K' summary and one row per citation with filename + snippet", () => {
    const citations: Citation[] = [
      { n: 1, fileName: "report.txt", start: 0, end: 20, text: "Revenue grew 12% YoY." },
      { n: 2, fileName: "notes.md", start: 100, end: 140, text: "Follow-up items for next quarter." },
    ];
    const html = renderSourcesHtml(citations);
    expect(html).toContain("Sources · 2");
    expect(html).toContain("[1]");
    expect(html).toContain("[2]");
    expect(html).toContain("report.txt");
    expect(html).toContain("notes.md");
    expect(html).toContain("Revenue grew 12% YoY.");
    expect(html).toContain('data-cite-row="1"');
    expect(html).toContain('data-cite-row="2"');
  });

  it("esc() discipline: a malicious filename or snippet can never break out of the panel markup", () => {
    const citations: Citation[] = [
      { n: 1, fileName: '"><script>alert(1)</script>.txt', start: 0, end: 10, text: '</div><img src=x onerror=alert(1)>' },
    ];
    const html = renderSourcesHtml(citations);
    expect(html).not.toContain("<script>alert(1)</script>");
    expect(html).not.toContain("<img src=x onerror=alert(1)>");
    expect(html).toContain("&lt;script&gt;");
  });

  it("truncates long snippets rather than dumping the whole ~1200-char chunk into the panel", () => {
    const longText = "word ".repeat(400); // well over the 240-char snippet cap
    const citations: Citation[] = [{ n: 1, fileName: "a.txt", start: 0, end: longText.length, text: longText }];
    const html = renderSourcesHtml(citations);
    expect(html).toContain("…");
    expect(html.length).toBeLessThan(longText.length + 500); // sanity: panel isn't just echoing the full chunk
  });
});

describe("Chat-with-files RAG v1: [n] citation-marker linkification guard", () => {
  it("linkifies [n] markers that ARE in the valid set", () => {
    const html = "The answer is here [1] and also here [2].";
    const out = linkifyCitations(html, new Set([1, 2]));
    expect(out).toContain('data-cite="1"');
    expect(out).toContain('data-cite="2"');
    expect(out).toContain("cite-mark");
  });

  it("NEVER linkifies [n] when there is no citation map for this message (ordinary reply guard)", () => {
    const html = "See note [1] below for details, and reference [42] elsewhere.";
    const out = linkifyCitations(html, new Set()); // empty map = ordinary message, not a RAG'd turn
    expect(out).toBe(html); // completely untouched
    expect(out).not.toContain("cite-mark");
  });

  it("leaves an out-of-range [n] alone even when SOME citations exist for this message", () => {
    const html = "Cited: [1]. Not cited (out of range): [7].";
    const out = linkifyCitations(html, new Set([1]));
    expect(out).toContain('data-cite="1"');
    expect(out).toContain("[7]"); // untouched literal text, no data-cite attribute for it
    expect(out).not.toContain('data-cite="7"');
  });

  it("does not touch ordinary bracketed text that happens to look like a footnote in a message with no citations", () => {
    const html = "Reference implementation notes [1], [2], [3] for the algorithm.";
    const out = linkifyCitations(html, new Set());
    expect(out).toBe(html);
  });

  it("never rewrites [n] found inside tag markup (e.g. a URL path containing a literal [1]), only in text nodes", () => {
    const html = mdToHtml("See [1] and check out [our site](https://example.com/path[1]/thing) for [2].");
    expect(html).toContain('href="https://example.com/path[1]/thing"'); // sanity: mdToHtml left the URL as-is
    const out = linkifyCitations(html, new Set([1, 2]));
    // The href attribute's literal "[1]" must survive untouched — a naive
    // string-wide regex replace would splice a <button> into the middle of
    // the attribute value here, corrupting the tag.
    expect(out).toContain('href="https://example.com/path[1]/thing"');
    // The genuine text-node [1] and [2] markers still get linkified.
    expect(out).toContain('data-cite="1"');
    expect(out).toContain('data-cite="2"');
    expect((out.match(/data-cite="1"/g) || []).length).toBe(1); // only the text-node [1], not the URL's
  });
});

/* ════════════════════════════════════════════════════════════════════
   App-aware assistant (plan §6.6, §9 Phase 3, beat matrix Axis 12) —
   captureUiSnapshot on a fixture DOM: caps at MAX_ELEMENTS, excludes agent
   chrome, and resolves labels via aria-label/data-ui-label/text content.
   ════════════════════════════════════════════════════════════════════ */
describe("assistant.ts: captureUiSnapshot", () => {
  beforeEach(() => {
    document.body.innerHTML = "";
  });

  it("captures a visible button, labeling it by text content", () => {
    document.body.innerHTML = '<button id="chat-send">Send</button>';
    const snap = captureUiSnapshot("chat");
    expect(snap.route).toBe("chat");
    expect(snap.elements).toHaveLength(1);
    expect(snap.elements[0]).toMatchObject({ tag: "button", label: "Send", kind: "interactive" });
    expect(snap.elements[0]!.selector).toContain("data-ui-ref");
  });

  it("prefers data-ui-label, then aria-label, then text content, in that order", () => {
    document.body.innerHTML = `
      <button id="a" data-ui-label="Explicit label" aria-label="Aria label">Text</button>
      <button id="b" aria-label="Aria label">Text</button>
      <button id="c">Text only</button>
    `;
    const snap = captureUiSnapshot("chat");
    const byId = (id: string) => snap.elements.find((e) => e.selector.includes(`ui-chat`) && document.querySelector(e.selector) === document.getElementById(id));
    expect(byId("a")?.label).toBe("Explicit label");
    expect(byId("b")?.label).toBe("Aria label");
    expect(byId("c")?.label).toBe("Text only");
  });

  it("excludes elements hidden via inline display:none, including inside a closed overlay", () => {
    document.body.innerHTML = `
      <button id="visible">Visible</button>
      <button id="hidden-btn" style="display:none">Hidden</button>
      <div id="closed-overlay" style="display:none">
        <button id="inside-closed">Inside a closed overlay</button>
      </div>
    `;
    const snap = captureUiSnapshot("chat");
    const labels = snap.elements.map((e) => e.label);
    expect(labels).toContain("Visible");
    expect(labels).not.toContain("Hidden");
    expect(labels).not.toContain("Inside a closed overlay");
  });

  it("excludes agent chrome (data-ui-chrome=assistant) and the toast container", () => {
    document.body.innerHTML = `
      <button id="real">Real control</button>
      <div data-ui-chrome="assistant"><button id="chrome-btn">Spotlight popover button</button></div>
      <div id="toasts"><button id="toast-btn">Dismiss toast</button></div>
    `;
    const snap = captureUiSnapshot("chat");
    const labels = snap.elements.map((e) => e.label);
    expect(labels).toContain("Real control");
    expect(labels).not.toContain("Spotlight popover button");
    expect(labels).not.toContain("Dismiss toast");
  });

  // Review finding: captureUiSnapshot is re-served to the model verbatim as
  // trusted "current UI state" via get_current_app_context. Rendered
  // conversation content (chat-thread messages, memory vault articles) can
  // contain a real `<a href>` — a citation link, a markdown link from
  // RAG'd/tool/web content — whose visible text INTERACTIVE_SELECTOR would
  // otherwise harvest as if it were legitimate app chrome, giving a second,
  // less-obvious prompt-injection channel. data-ui-chrome="content" (any
  // value, not just "assistant") closes this — see isAgentChrome's doc
  // comment and its marker sites in app.html (#chat-thread) and
  // memory-panel.ts (.mem-article-render).
  it("excludes rendered conversation content marked data-ui-chrome=content (e.g. a link inside a chat message)", () => {
    document.body.innerHTML = `
      <button id="real">Real control</button>
      <div id="chat-thread" data-ui-chrome="content">
        <div class="msg assistant">
          <a href="https://example.com/x" id="cite-link">Click here for free access</a>
        </div>
      </div>
    `;
    const snap = captureUiSnapshot("chat");
    const labels = snap.elements.map((e) => e.label);
    expect(labels).toContain("Real control");
    expect(labels).not.toContain("Click here for free access");
    expect(document.querySelector("#cite-link")!.hasAttribute("data-ui-ref")).toBe(false);
  });

  it("skips elements with no resolvable label (an icon-only button with no aria-label/title)", () => {
    document.body.innerHTML = '<button id="icon-only"><svg></svg></button><button id="labeled">Has text</button>';
    const snap = captureUiSnapshot("chat");
    expect(snap.elements).toHaveLength(1);
    expect(snap.elements[0]!.label).toBe("Has text");
  });

  it("marks a data-spotlight element as kind:region and carries its spotlightId", () => {
    document.body.innerHTML = '<div data-spotlight="stat-card">Total: 42</div>';
    const snap = captureUiSnapshot("chat");
    expect(snap.elements).toHaveLength(1);
    expect(snap.elements[0]).toMatchObject({ kind: "region", spotlightId: "stat-card" });
  });

  it("caps at ~120 elements even when the fixture has many more", () => {
    const many = Array.from({ length: 200 }, (_, i) => `<button id="btn-${i}">Button ${i}</button>`).join("");
    document.body.innerHTML = many;
    const snap = captureUiSnapshot("chat");
    expect(snap.elements.length).toBeLessThanOrEqual(120);
  });

  it("assigns stable data-ui-ref attributes so a second capture reuses the same ref", () => {
    document.body.innerHTML = '<button id="stable">Stable</button>';
    const first = captureUiSnapshot("chat");
    const second = captureUiSnapshot("chat");
    expect(first.elements[0]!.ref).toBe(second.elements[0]!.ref);
  });
});

describe("assistant.ts: resolveSpotlightTarget", () => {
  beforeEach(() => {
    document.body.innerHTML = "";
  });

  function snapshotWith(elements: UiSnapshot["elements"]): UiSnapshot {
    return { route: "chat", capturedAt: new Date(0).toISOString(), elements };
  }

  it("resolves by ref from the last snapshot first", () => {
    document.body.innerHTML = '<button id="x" data-ui-ref="ui-chat-0">Send</button>';
    const snap = snapshotWith([{ ref: "ui-chat-0", tag: "button", label: "Send", kind: "interactive", selector: '[data-ui-ref="ui-chat-0"]' }]);
    const resolved = resolveSpotlightTarget({ ref: "ui-chat-0" }, snap);
    expect(resolved?.selector).toBe('[data-ui-ref="ui-chat-0"]');
    expect(resolved?.title).toBe("Send");
  });

  it("resolves by a live CSS selector when no snapshot ref matches", () => {
    document.body.innerHTML = '<button id="chat-send">Send</button>';
    const resolved = resolveSpotlightTarget({ selector: "#chat-send" }, null);
    expect(resolved?.selector).toBe("#chat-send");
  });

  it("resolves by fuzzy label match against the snapshot", () => {
    const snap = snapshotWith([{ ref: "ui-chat-3", tag: "button", label: "New chat", kind: "interactive", selector: '[data-ui-ref="ui-chat-3"]' }]);
    document.body.innerHTML = '<button data-ui-ref="ui-chat-3">New chat</button>';
    const resolved = resolveSpotlightTarget({ label: "new chat" }, snap);
    expect(resolved?.selector).toBe('[data-ui-ref="ui-chat-3"]');
  });

  it("resolves by a curated catalog target id when nothing else matches", () => {
    document.body.innerHTML = '<button id="chat-box">unused</button><textarea id="chat-box-real"></textarea>';
    // "composer" catalog target points at #chat-box specifically.
    document.body.innerHTML = '<textarea id="chat-box"></textarea>';
    const resolved = resolveSpotlightTarget({ target: "composer" }, null);
    expect(resolved?.selector).toBe("#chat-box");
    expect(resolved?.title).toBe("Message box");
  });

  it("returns null when nothing resolves (unknown ref/label/selector/target)", () => {
    document.body.innerHTML = "<div></div>";
    expect(resolveSpotlightTarget({ ref: "nonexistent" }, null)).toBeNull();
    expect(resolveSpotlightTarget({ label: "nothing like this exists anywhere" }, null)).toBeNull();
    expect(resolveSpotlightTarget({ selector: "#nonexistent" }, null)).toBeNull();
    expect(resolveSpotlightTarget({ target: "nonexistent-target" }, null)).toBeNull();
  });

  it("carries the optional message through to the resolved result", () => {
    document.body.innerHTML = '<button id="chat-send">Send</button>';
    const resolved = resolveSpotlightTarget({ selector: "#chat-send", message: "click here to send" }, null);
    expect(resolved?.message).toBe("click here to send");
  });

  // Model-invented inputs must MISS (→ the "couldn't find that on screen"
  // toast in chat.ts), never throw a SyntaxError through the ws message
  // handler (2026-07-07 review finding).
  it("treats an invalid model-invented selector as a miss, not a throw", () => {
    document.body.innerHTML = '<button id="chat-send">Send</button>';
    expect(resolveSpotlightTarget({ selector: ":::not-a-selector(" }, null)).toBeNull();
    expect(resolveSpotlightTarget({ selector: "[unclosed" }, null)).toBeNull();
  });

  it("survives quotes/brackets in model-provided ref/target values", () => {
    // attrEscape keeps a quote from breaking out of the attribute string —
    // the built selector stays syntactically valid and simply misses.
    // (Matching an escaped quote against a real quoted attr works in
    // browsers but not happy-dom's selector engine, so only the miss/no-
    // throw property is pinned here; real refs are our own generated
    // `ui-<route>-<n>` ids and never contain quotes.)
    document.body.innerHTML = '<button data-ui-ref="ui-chat-0">Send</button>';
    expect(resolveSpotlightTarget({ ref: '"]' }, null)).toBeNull();
    expect(resolveSpotlightTarget({ target: '"] *' }, null)).toBeNull();
    expect(resolveSpotlightTarget({ ref: 'odd"ref' }, null)).toBeNull();
  });
});

describe("assistant.ts: buildAppContext + ambientLine", () => {
  beforeEach(() => {
    document.body.innerHTML = "";
  });

  it("builds a context with no step/view for a plain route", () => {
    document.body.innerHTML = '<button id="chat-send">Send</button>';
    const ctx = buildAppContext("chat", null);
    expect(ctx.route).toBe("chat");
    expect(ctx.step).toBeUndefined();
    expect(ctx.view).toBeUndefined();
    expect(ctx.snapshot.elements.length).toBeGreaterThan(0);
  });

  it("carries a valid view override", () => {
    const ctx = buildAppContext("chat", "memory-panel");
    expect(ctx.view).toBe("memory-panel");
  });

  it("ignores an unrecognized view override", () => {
    const ctx = buildAppContext("chat", "not-a-real-view");
    expect(ctx.view).toBeUndefined();
  });

  it("derives the wizard step from the DOM's step-indicator markup", () => {
    document.body.innerHTML = `
      <div id="q-steps">
        <span class="s done"><span class="n">1</span>Source</span>
        <span class="s cur"><span class="n">2</span>Configure</span>
        <span class="s"><span class="n">3</span>Run</span>
        <span class="s"><span class="n">4</span>Done</span>
      </div>
    `;
    const ctx = buildAppContext("quantize", null);
    expect(ctx.step).toEqual({ index: 1, count: 4, label: "Configure" });
  });

  it("ambientLine renders the compact one-liner from a built context", () => {
    document.body.innerHTML = `<div id="q-steps"><span class="s"></span><span class="s cur"><span class="n">2</span>Configure</span><span class="s"></span><span class="s"></span></div>`;
    const ctx = buildAppContext("quantize", null);
    expect(ambientLine(ctx)).toBe("[user is on: Quantize · step 2/4]");
  });
});

describe("ui-catalog.ts: route/view validation", () => {
  it("isRouteId accepts every catalog route and rejects unknowns", () => {
    for (const r of ROUTE_IDS) expect(isRouteId(r)).toBe(true);
    expect(isRouteId("nonexistent")).toBe(false);
    expect(isRouteId("routes")).toBe(false); // DAG diagram tab deliberately excluded
  });

  it("isViewId accepts the known overlay views and rejects unknowns", () => {
    expect(isViewId("memory-panel")).toBe(true);
    expect(isViewId("hub-panel")).toBe(true);
    expect(isViewId("nonexistent")).toBe(false);
  });

  it("resolveRouteId resolves a bare id and a #/route hash, rejects unknowns", () => {
    expect(resolveRouteId("quantize")).toBe("quantize");
    expect(resolveRouteId("#/quantize")).toBe("quantize");
    expect(resolveRouteId("nonexistent")).toBeNull();
  });
});
