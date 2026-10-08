// DOM-level unit tests for the pure/DOM-facing parts of the app's own browser modules (`src/web/browser/*`): the
// `api()` error envelope, the memory panel's provenance chips, the model picker's rows and the Model Hub's lists. The chat
// panel's browser code is tested in its package (`packages/module-chat/tests/panel.test.ts`).
//
// This is model-free and server-free: no WS, no fetch to a real server (fetch is stubbed per-test where api() is
// exercised). happy-dom provides document/window (see ./dom-setup.ts, imported first for its side effect of installing
// globals before any browser module runs).
import "./dom-setup";
import { MEMORY_TOOL_NAMES, REFERENCE_TOOL_NAMES } from "@mlx-bun/module-memory/tools";
import { describe, expect, it, beforeEach } from "bun:test";
import { api } from "../../src/web/browser/api";
import { MEMORY_CHIP_TOOL_NAMES, isMemoryToolName, memoryToolChip } from "../../../../packages/module-memory/src/panel/memory";

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

it("memory provenance chips cover every callable memory and reference tool", () => {
  expect([...MEMORY_CHIP_TOOL_NAMES].sort()).toEqual([...MEMORY_TOOL_NAMES, ...REFERENCE_TOOL_NAMES].sort());
  for (const name of [...MEMORY_TOOL_NAMES, ...REFERENCE_TOOL_NAMES]) expect(isMemoryToolName(name)).toBe(true);
  for (const name of ["read", "bash", "web_search", "memory_fake", "reference_fake", ""]) expect(isMemoryToolName(name)).toBe(false);
});
