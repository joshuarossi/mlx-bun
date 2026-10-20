// DOM-level unit tests for the app's side of the installed panels: the memory panel's provenance chips as the chat
// host draws them. The JSON client's envelope handling is the web kit's (`packages/web-kit/tests/api.test.ts`); the
// chat panel's browser code is tested in its package (`packages/module-chat/tests/panel.test.ts`).
//
// This is model-free and server-free. happy-dom provides document/window (see ./dom-setup.ts, imported first for its
// side effect of installing globals before any browser module runs).
import "./dom-setup";
import { MEMORY_TOOL_NAMES, REFERENCE_TOOL_NAMES } from "@mlx-bun/module-memory/tools";
import { describe, expect, it } from "bun:test";
import { MEMORY_CHIP_TOOL_NAMES, isMemoryToolName, memoryToolChip } from "../../../../packages/module-memory/src/panel/memory";

/* esc() discipline on the provenance chip's label and result: memory tool args and results are model and vault data,
   so a crafted article name or tool result must never break out of the chip's markup. */
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
