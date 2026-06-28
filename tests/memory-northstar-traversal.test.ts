// P3-T5 acceptance (M2 read-thesis): the north-star lens query is answered by
// FIND → READ → ANSWER through the actual pi read tools (createMemoryTools),
// against the hand-built fixture vault — category + name + [[link]] navigation
// only, NO infobox-field filter, NO vector search. Asserts the embedding
// tripwire stays at zero, every read is small (no read > 2 KB, total < ~8 KB),
// the second query resolves in < 1.5 KB without substring search, and there is
// NO infobox-field-query tool registered.

import { join } from "node:path";
import { beforeAll, describe, expect, it } from "bun:test";

import { getEmbedCounter, resetEmbedCounter } from "../src/embed";
import { createMemoryTools, MEMORY_TOOL_NAMES } from "../src/memory/tools";

const FIXTURE_VAULT = join(import.meta.dir, "fixtures", "wiki");

// vaultRoot() honors MLX_BUN_WIKI at call time, so the read tools point at the
// fixture vault without writing the real ~/.mlx-bun/wiki.
beforeAll(() => {
  process.env.MLX_BUN_WIKI = FIXTURE_VAULT;
});

const tools = createMemoryTools();

/** Invoke one read tool and return its text + UTF-8 byte size. */
async function call(name: string, params: Record<string, unknown>): Promise<{ text: string; bytes: number }> {
  const tool = tools.find((t) => t.name === name);
  if (!tool) throw new Error(`tool not registered: ${name}`);
  // execute(toolCallId, params, signal, onUpdate, ctx) — our read tools use only params.
  const res = await tool.execute("test", params as never, undefined, undefined, undefined as never);
  const text = res.content.map((c) => ("text" in c ? c.text : "")).join("");
  return { text, bytes: Buffer.byteLength(text, "utf8") };
}

describe("north-star traversal — FIND → READ → ANSWER over the fixture vault", () => {
  it("answers the lens query from the FOUND+READ article in < 8 KB, zero embeddings, no read > 2 KB", async () => {
    resetEmbedCounter();
    const reads: { step: string; bytes: number }[] = [];
    const track = (step: string, r: { text: string; bytes: number }) => {
      reads.push({ step, bytes: r.bytes });
      return r;
    };

    // ===== Q1: "best lens for really long reach that isn't crazy expensive?" =====
    // FIND — "articles about lenses" = Category:Lenses membership (not a search).
    const cat = track("category Lenses", await call("memory_category", { category: "Lenses" }));
    expect(cat.text).toContain("Sigma_150-600");
    expect(cat.bytes).toBeLessThan(2048);

    // FIND (corroborating) — hop the [[link]] graph from the camera's infobox
    // mount: [[L-Mount]] edge. memory_links groups outbound by origin.
    const resolveCam = await call("memory_resolve", { surface: "the Lumix S5IIX" });
    expect(resolveCam.text).toContain("Panasonic_Lumix_S5IIX");
    const links = track("links S5IIX", await call("memory_links", { stem: "Panasonic_Lumix_S5IIX" }));
    expect(links.text).toMatch(/infobox:.*L-Mount/);

    // READ small — TOC + lead by default (NOT a whole-article dump), then the
    // ONE verdict section that holds the user's recorded conclusion.
    const toc = track("read TOC Sigma", await call("memory_read", { stem: "Sigma_150-600" }));
    expect(toc.text).toContain("#verdict");
    // The default read must NOT include the section prose — proof it isn't a dump.
    expect(toc.text).not.toContain("crazy expensive");
    expect(toc.bytes).toBeLessThan(2048);

    const verdict = track("section verdict", await call("memory_section", { stem: "Sigma_150-600", anchor: "verdict" }));
    expect(verdict.text).toMatch(/crazy expensive/i);
    expect(verdict.text).toMatch(/reach/i);
    expect(verdict.bytes).toBeLessThan(2048);

    // ===== Q2: "PETG print settings" — resolve by name, read one section =====
    const q2Reads: { bytes: number }[] = [];
    const petg = await call("memory_resolve", { surface: "PETG" });
    q2Reads.push(petg);
    expect(petg.text).toContain("PETG");
    expect(petg.bytes).toBeLessThan(512); // ≤ 0.5 KB resolve

    const petgToc = await call("memory_read", { stem: "PETG" });
    q2Reads.push(petgToc);
    const settings = await call("memory_section", { stem: "PETG", anchor: "print-settings" });
    q2Reads.push(settings);
    expect(settings.text).toMatch(/nozzle|bed/i);

    const q2Bytes = q2Reads.reduce((a, r) => a + r.bytes, 0);
    expect(q2Bytes).toBeLessThan(1536); // < 1.5 KB, name-resolve path (no substring search)

    // ===== Acceptance gates =====
    const allReads = [...reads.map((r) => r.bytes), ...q2Reads.map((r) => r.bytes)];
    const total = allReads.reduce((a, b) => a + b, 0);
    const maxRead = Math.max(...allReads);

    expect(getEmbedCounter()).toBe(0); // zero embedding calls on the read path
    expect(maxRead).toBeLessThanOrEqual(2048); // no single read > 2 KB
    expect(total).toBeLessThan(8192); // total < ~8 KB (vs the 33–150 KB failure)
  });

  it("registers no infobox-field-query tool (the infobox is content, not a filter)", () => {
    // No facet/numeric/gte-lte/by-field query surface anywhere.
    for (const name of MEMORY_TOOL_NAMES) {
      expect(name).not.toMatch(/query|facet|gte|lte|by_?infobox|filter|sort/i);
    }
    expect(MEMORY_TOOL_NAMES as readonly string[]).not.toContain("memory_infobox_query");
    // memory_infobox exists only to READ the infobox facts.
    expect(MEMORY_TOOL_NAMES as readonly string[]).toContain("memory_infobox");
    expect(tools.map((t) => t.name).sort()).toEqual([...MEMORY_TOOL_NAMES].sort());
  });
});
