// DOM-level unit tests for the pure/DOM-facing parts of the app's own browser modules (`src/web/browser/*`): the
// `api()` error envelope, the memory panel's provenance chips, the model picker's rows and the Model Hub's lists. The chat
// panel's browser code is tested in its package (`packages/module-chat/tests/panel.test.ts`).
//
// This is model-free and server-free: no WS, no fetch to a real server (fetch is stubbed per-test where api() is
// exercised). happy-dom provides document/window (see ./dom-setup.ts, imported first for its side effect of installing
// globals before any browser module runs).
import "./dom-setup";
import { MEMORY_TOOL_NAMES, REFERENCE_TOOL_NAMES } from "../../src/memory/tools";
import { describe, expect, it, beforeEach } from "bun:test";
import { api } from "../../src/web/browser/api";
import { MEMORY_CHIP_TOOL_NAMES, isMemoryToolName, memoryToolChip } from "../../src/web/browser/memory-panel";
import { fitVerdict, renderModelPopBodyHtml, type LibraryRow } from "../../src/web/browser/model-picker";
import { renderHubLocalHtml, renderHubSearchHtml, type HubLocalRow, type HubSearchRow } from "../../src/web/browser/hub";

/* ────────────────────────────────────────────────────────────────────
   (c) api() error-envelope unwrapping (`02d723a:docs/archive/planning/web-ui-pass-plan.md` #4): an
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
   Model picker: fit-verdict thresholds and esc()
   discipline on repo ids (HF strings, user/model-controlled) interpolated
   into the popover body and the Serve button.
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

  it("escapes a malicious repo id everywhere it's interpolated, including the Serve button's data attribute", () => {
    const html = renderModelPopBodyHtml([row({ repo_id: '"><script>alert(1)</script>/model' })]);
    expect(html).not.toContain("<script>alert(1)</script>");
    expect(html).toContain("&lt;script&gt;");
    expect(html).toContain('class="mp-serve" data-repo="&quot;&gt;&lt;script&gt;');
  });

  it("puts the currently-serving model first, marks loaded ones, and offers Serve only for the others", () => {
    const html = renderModelPopBodyHtml([
      row({ repo_id: "org/a", serving: false }),
      row({ repo_id: "org/b", serving: true, resident: true }),
      row({ repo_id: "org/c", serving: false, resident: true }),
    ]);
    expect(html.indexOf("org/b")).toBeLessThan(html.indexOf("org/a"));
    const servingRowEnd = html.indexOf("org/a"); // everything before the second row is the serving row
    expect(html.slice(0, servingRowEnd)).not.toContain("mp-serve");
    expect(html.slice(0, servingRowEnd)).toContain("currently serving");
    expect(html.match(/class="mp-serve"/g)).toHaveLength(2);
    // Only a model that is loaded but not served carries the loaded tag.
    expect(html.match(/○ loaded/g)).toHaveLength(1);
    expect(html.slice(html.indexOf("org/c"))).toContain("○ loaded");
  });

  it("never offers Serve for an unsupported model family", () => {
    const html = renderModelPopBodyHtml([row({ supported: false, assessment: null })]);
    expect(html).not.toContain("mp-serve");
    expect(html).toContain("unsupported model family");
  });
});

/* ────────────────────────────────────────────────────────────────────
   Model Hub panel (`02d723a:docs/design/web-chat-redesign.md` Appendix A,
   beat-matrix Axis 3): pure render
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

it("memory provenance chips cover every callable memory and reference tool", () => {
  expect([...MEMORY_CHIP_TOOL_NAMES].sort()).toEqual([...MEMORY_TOOL_NAMES, ...REFERENCE_TOOL_NAMES].sort());
  for (const name of [...MEMORY_TOOL_NAMES, ...REFERENCE_TOOL_NAMES]) expect(isMemoryToolName(name)).toBe(true);
  for (const name of ["read", "bash", "web_search", "memory_fake", "reference_fake", ""]) expect(isMemoryToolName(name)).toBe(false);
});
