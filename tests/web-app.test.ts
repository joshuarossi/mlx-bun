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
  highlightIn, makeFrameScheduler, mdToHtml, renderBlocksIncremental,
  splitBlocks, type BlockState,
} from "../src/web/src/markdown";
import { api } from "../src/web/src/api";
import { renderQueue } from "../src/web/src/composer";
import { renderAdapterOptionsHtml, type AdapterInfo } from "../src/web/src/composer";
import {
  applyMention, buildMentionItems, detectMentionQuery, filterFileMentions,
  renderMentionListHtml, type Attachment, type MentionItem, type MentionQuery,
} from "../src/web/src/composer";
import { MEMORY_CHIP_TOOL_NAMES, isMemoryToolName, memoryToolChip } from "../src/web/src/memory-panel";
import { MEMORY_TOOL_NAMES, REFERENCE_TOOL_NAMES } from "../src/memory/tools";
import {
  AdaptersPanelState, renderAdapterRow, renderAdaptersBodyHtml,
  type AvailableAdapterRow, type MountedAdapterRow,
} from "../src/web/src/adapters-panel";
import { fitVerdict, renderModelPopBodyHtml, type LibraryRow } from "../src/web/src/model-picker";

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
