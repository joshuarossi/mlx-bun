// The Dreaming — SECTION-ROUTE `newSection` is HONORED, never dropped.
//
// When a substantive routed chunk fits NO existing section of an article it
// already belongs to, SECTION-ROUTE proposes a NAMED new section. The synthesize
// PATCH loop must MINT that section and fold the chunk into it (cited, gated,
// recorded) rather than silently dropping the chunk — the self-healing-loss bug.
// Everything reachable WITHOUT the GPU via injected model seams.

import { describe, expect, it, afterEach } from "bun:test";
import { mkdtemp, mkdir, readFile, writeFile } from "node:fs/promises";
import { tmpdir } from "node:os";
import { join } from "node:path";

import { MemoryStore, chunkId } from "../src/memory/db";
import { runSynthesizeStage } from "../src/memory/stages";
import type { SectionCall } from "../src/memory/cluster";
import type { SynthesisCall } from "../src/memory/synthesize";
import { checkFootnoteIntegrity } from "../src/memory/gate";
import { extractSection } from "../src/memory/vault";

// A normalized existing article: a lead + ONE section ("Power") that the incoming
// chunk does not belong to, so SECTION-ROUTE must name a NEW section.
const GADGET = `# Gadget

\`\`\`info
type: gadget
kind: thing
\`\`\`

**Gadget** is a device the user owns and tinkers with.[^1]

## Power

It runs off a removable battery pack.[^1]

## References

[^1]: \`conv:11112222\` (2024-01-01, Gadget basics)
`;

const NEW_CONV = "99990000-0000-0000-0000-000000000000"; // → conv:99990000

const savedWiki = process.env.MLX_BUN_WIKI;
afterEach(() => {
  if (savedWiki === undefined) delete process.env.MLX_BUN_WIKI;
  else process.env.MLX_BUN_WIKI = savedWiki;
});

async function seed(): Promise<{ root: string; store: MemoryStore; cid: string }> {
  const root = await mkdtemp(join(tmpdir(), "dreaming-newsection-"));
  await mkdir(join(root, "articles"), { recursive: true });
  await writeFile(join(root, "articles", "Gadget.md"), GADGET);
  process.env.MLX_BUN_WIKI = root;

  const store = new MemoryStore(":memory:");
  store.db.run("INSERT INTO entities (name, article_stem, kind, notable) VALUES (?,?,?,?)", ["Gadget", "Gadget", "thing", 1]);
  store.db.run("INSERT INTO conversations (conv, source, title, updated_at, chunked_at) VALUES (?,?,?,?,?)", [
    NEW_CONV, "pi-terminal", "Cooling notes", 1735689600000, 1735689600000,
  ]);
  const msgs = [
    "One more thing about the Gadget — it gets HOT under load.",
    "I added a small fan and a heatsink to keep its temperature down.",
  ];
  msgs.forEach((text, i) =>
    store.db.run("INSERT INTO messages (conv, position, role, uuid, text) VALUES (?,?,?,?,?)", [
      NEW_CONV, i, i % 2 === 0 ? "user" : "assistant", `g${i}`, text,
    ]),
  );
  const cid = chunkId(NEW_CONV, 0, 1);
  store.db.run("INSERT INTO chunks (id, conv, start, end, label) VALUES (?,?,?,?,?)", [cid, NEW_CONV, 0, 1, "gadget cooling"]);
  store.db.run("INSERT OR IGNORE INTO chunk_entities (chunk_id, entity_name, surface_form) VALUES (?,?,?)", [cid, "Gadget", "Gadget"]);
  return { root, store, cid };
}

// SECTION-ROUTE: decline every existing section AND the lead; name a NEW section.
const sectionCall: SectionCall = async (prompt) => {
  if (prompt.includes("name that NEW section")) return "Cooling System";
  return "no";
};

// SYNTHESIS: fold the chunk into the (freshly-minted, empty) section, citing the
// assigned marker.
const synthesisCall: SynthesisCall = async (prompt) => {
  if (prompt.includes("integrating ONE new note")) {
    const m = /placing the marker \[\^(\d+)\]/.exec(prompt) ?? /\[\^(\d+)\] immediately after/.exec(prompt);
    const marker = m ? `[^${m[1]}]` : "";
    return `The user added a fan and heatsink to keep the Gadget cool under load.${marker}`;
  }
  return "NONE";
};

describe("synthesize — honors a SECTION-ROUTE newSection (no silent drop)", () => {
  it("mints the named section, folds + cites the chunk, records the ledger", async () => {
    const { root, store, cid } = await seed();

    const r = await runSynthesizeStage(store, {
      root,
      convIds: [NEW_CONV],
      sectionCall,
      call: synthesisCall,
      commit: false,
    });

    // The chunk was folded into the NEW section, not dropped.
    expect(r.created.length).toBe(0);
    expect(r.patched).toContainEqual(
      expect.objectContaining({ stem: "Gadget", anchor: "cooling-system", chunkId: cid, footnote: 2 }),
    );

    const after = await readFile(join(root, "articles", "Gadget.md"), "utf8");

    // A real "## Cooling System" section now exists, carries the chunk + its [^2],
    // and the article is still footnote-bijective.
    const cooling = extractSection(after, "cooling-system");
    expect(cooling).not.toBeNull();
    expect(cooling!).toContain("fan and heatsink");
    expect(cooling!).toContain("[^2]");
    expect(after).toContain("[^2]: `conv:99990000`");
    expect(checkFootnoteIntegrity(after).ok).toBe(true);

    // Pre-existing structure survived untouched.
    expect(extractSection(after, "power")).toBe(extractSection(GADGET, "power"));

    // The (chunk, section) edge is in the integration ledger (idempotency key).
    const ledger = store.db
      .query("SELECT 1 FROM synthesized_chunk_sections WHERE chunk_id = ? AND article_stem = 'Gadget' AND section_anchor = 'cooling-system'")
      .get(cid);
    expect(ledger).not.toBeNull();

    store.close();
  });

  it("is idempotent — a second pass mints nothing (synthesized_chunk_sections PK)", async () => {
    const { root, store } = await seed();
    const first = await runSynthesizeStage(store, { root, convIds: [NEW_CONV], sectionCall, call: synthesisCall, commit: false });
    expect(first.patched.length).toBe(1);
    const afterFirst = await readFile(join(root, "articles", "Gadget.md"), "utf8");

    const second = await runSynthesizeStage(store, { root, convIds: [NEW_CONV], sectionCall, call: synthesisCall, commit: false });
    expect(second.patched.length).toBe(0);
    const afterSecond = await readFile(join(root, "articles", "Gadget.md"), "utf8");
    expect(afterSecond).toBe(afterFirst); // byte-identical, nothing re-minted

    store.close();
  });
});
