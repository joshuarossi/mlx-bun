// P9 — the self-healing loop wired into runPipeline: SECTION-ROUTE → PATCH.
//
// runPipeline's cold-start branch CREATEs new entity articles; this proves the
// steady-state counterpart — a routed chunk whose entity ALREADY has an article
// is folded into the relevant section via synthesizePatch, NOT minted as a
// duplicate. Everything reachable WITHOUT the GPU, driving the full DAG (real DB
// + real vault file I/O + real routeSections/patch/gate/normalize logic) with a
// FAKE model injected at every stage seam (extract / section-route / synthesis).
//
// The end-to-end acceptance is the self-heal demo: inject a CORRECTION chunk
// about an existing article, run the pipeline, assert the article was PATCHED in
// just the relevant section (cites the new chunk, every other section
// byte-identical) and no duplicate article was created. The real base-model
// version is the one-load smoke in scripts/experiments, not here.

import { describe, expect, it } from "bun:test";
import { mkdtemp, mkdir, readdir, readFile, writeFile } from "node:fs/promises";
import { tmpdir } from "node:os";
import { join } from "node:path";

import { MemoryStore, chunkId } from "../src/memory/db";
import type { ExtractCall } from "../src/memory/entity";
import { runPipeline } from "../src/memory/pipeline";
import type { SectionCall } from "../src/memory/cluster";
import type { SynthesisCall } from "../src/memory/synthesize";
import { checkFootnoteIntegrity } from "../src/memory/gate";
import { extractSection } from "../src/memory/vault";

// ---- fixtures --------------------------------------------------------------

// A fully-normalized existing article (footnotes bijective from 1, infobox
// sorted, References last) so NORMALIZE is a true no-op and the
// only-section-changed invariant is exact. "Lens Pairing" carries [^1]; the
// correction folds into it and mints a clean [^2]. "Autofocus Performance"
// carries no footnote and must stay byte-identical through the run.
const TEST_CAMERA = `# Test Camera

\`\`\`info
type: camera-body
kind: thing
\`\`\`

**Test Camera** is the user's full-frame body, used with vintage glass.

## Lens Pairing

The user pairs the body with vintage glass for its rendering.[^1]

## Autofocus Performance

Autofocus tracking is reliable for stills in good light.

## References

[^1]: \`conv:11112222\` (2024-01-01, Lens pairing chat)
`;

const CORRECTION_CONV = "33334444-0000-0000-0000-000000000000"; // → conv:33334444
const HELIOS_CONV = "55556666-0000-0000-0000-000000000000"; // → conv:55556666

/** Seed a throwaway vault (Test_Camera.md only) + an in-memory store carrying:
 *  - one CORRECTION conversation/chunk about Test Camera (folds into an existing
 *    article), and
 *  - one 3-chunk conversation about a brand-new entity "Helios 44-2" (≥3 routed
 *    chunks ⇒ the deterministic CREATE gate fires) so the same run exercises the
 *    create-vs-patch split. */
async function seed(): Promise<{ root: string; store: MemoryStore; correctionId: string }> {
  const root = await mkdtemp(join(tmpdir(), "dreaming-pipeline-patch-"));
  await mkdir(join(root, "articles"), { recursive: true });
  await writeFile(join(root, "articles", "Test_Camera.md"), TEST_CAMERA);

  const store = new MemoryStore(":memory:");

  // CORRECTION conversation about the existing Test Camera article. chunked_at is
  // set == updated_at so SEGMENT skips it (the watermark holds) — these convs are
  // pre-seeded WITH chunks, so the test exercises the create/patch DAG, not our
  // chunker (which would need a real model load).
  store.db.run("INSERT INTO conversations (conv, source, title, updated_at, chunked_at) VALUES (?,?,?,?,?)", [
    CORRECTION_CONV,
    "pi-terminal",
    "Lens preference update",
    1735689600000,
    1735689600000,
  ]);
  const correctionMsgs = [
    "I want to revisit how I pair lenses on the Test Camera.",
    "Actually I now prefer the 50mm vintage lens for portraits, not the 35mm I mentioned before.",
  ];
  correctionMsgs.forEach((text, i) =>
    store.db.run("INSERT INTO messages (conv, position, role, uuid, text) VALUES (?,?,?,?,?)", [
      CORRECTION_CONV,
      i,
      i % 2 === 0 ? "user" : "assistant",
      `c${i}`,
      text,
    ]),
  );
  const correctionId = chunkId(CORRECTION_CONV, 0, 1);
  store.db.run("INSERT INTO chunks (id, conv, start, end, label) VALUES (?,?,?,?,?)", [
    correctionId,
    CORRECTION_CONV,
    0,
    1,
    "lens pairing preference change",
  ]);

  // A brand-new entity with 3 chunks (≥3 ⇒ create) in one conversation. chunked_at
  // == updated_at so SEGMENT skips it too (pre-seeded chunks drive the run).
  store.db.run("INSERT INTO conversations (conv, source, title, updated_at, chunked_at) VALUES (?,?,?,?,?)", [
    HELIOS_CONV,
    "pi-terminal",
    "Helios 44-2 notes",
    1735000000000,
    1735000000000,
  ]);
  const heliosMsgs = [
    "The Helios 44-2 is a vintage lens I picked up cheap.",
    "It has that swirly bokeh I love for portraits.",
    "I cleaned the Helios 44-2 helicoid and it focuses smoothly now.",
    "The Helios 44-2 renders beautifully wide open.",
    "I keep reaching for the Helios 44-2 over my modern glass.",
    "The Helios 44-2 is my favourite character lens.",
  ];
  heliosMsgs.forEach((text, i) =>
    store.db.run("INSERT INTO messages (conv, position, role, uuid, text) VALUES (?,?,?,?,?)", [
      HELIOS_CONV,
      i,
      i % 2 === 0 ? "user" : "assistant",
      `h${i}`,
      text,
    ]),
  );
  // Three chunks → three routed chunks for "Helios 44-2".
  for (const [s, e] of [[0, 1], [2, 3], [4, 5]] as const) {
    store.db.run("INSERT INTO chunks (id, conv, start, end, label) VALUES (?,?,?,?,?)", [
      chunkId(HELIOS_CONV, s, e),
      HELIOS_CONV,
      s,
      e,
      "helios 44-2 character",
    ]);
  }

  return { root, store, correctionId };
}

// ---- fake model at every stage seam ----------------------------------------

/** ENTITY-EXTRACT: name "Helios 44-2" for the Helios chunks, "Test Camera"
 *  otherwise. The prompt embeds the chunk text, so branch on it. */
const extractCall: ExtractCall = async (prompt) =>
  /helios/i.test(prompt) ? "Helios 44-2" : "Test Camera";

/** SECTION-ROUTE binary: fold the correction ONLY into "Lens Pairing"; decline
 *  every other section, and never name a new one. */
const sectionCall: SectionCall = async (prompt) => {
  if (prompt.includes("name that NEW section")) return "NONE";
  return /Section heading:\s*"Lens Pairing"/.test(prompt) ? "yes" : "no";
};

/** SYNTHESIS stage (CREATE drafting AND PATCH integration share this seam). */
const synthesisCall: SynthesisCall = async (prompt) => {
  // PATCH: integrate the new note into the Lens Pairing section, preserving the
  // pre-existing [^1] marker and placing the assigned new marker.
  if (prompt.includes("integrating ONE new note")) {
    const m = /placing the marker \[\^(\d+)\]/.exec(prompt);
    const marker = m ? `[^${m[1]}]` : "";
    return (
      "The user pairs the body with vintage glass for its rendering.[^1] " +
      `They now prefer the 50mm vintage lens for portraits over the 35mm.${marker}`
    );
  }
  // CREATE drafting (Helios article).
  if (prompt.includes("Propose a clean table of contents")) return "Optical Character";
  if (prompt.includes("Write the LEAD")) {
    return "**Helios 44-2** is a vintage swirly-bokeh lens the user owns and favours for portraits.";
  }
  if (prompt.includes("Produce the INFOBOX facts")) return "```\ntype: lens\nowned: yes\n```";
  if (prompt.includes("Draft ONLY the body of the")) {
    const list = prompt.split("Cite sources")[1] ?? "";
    const mk = /\[\^(\d+)\]/.exec(list);
    const marker = mk ? `[^${mk[1]}]` : "";
    return `The user owns this lens and reaches for its rendering character over modern glass.${marker}`;
  }
  return "NONE";
};

// ---- ACCEPTANCE — self-heal through runPipeline ----------------------------

describe("pipeline — SECTION-ROUTE → PATCH self-healing loop", () => {
  it("folds a correction into the existing article's relevant section, mints no duplicate", async () => {
    const { root, store, correctionId } = await seed();

    const result = await runPipeline(store, {
      root,
      extractCall,
      sectionCall,
      call: synthesisCall,
      commit: false,
    });

    // --- the existing article was PATCHED (not re-created) ---
    expect(result.patched.length).toBe(1);
    expect(result.patched[0]).toMatchObject({
      stem: "Test_Camera",
      anchor: "lens-pairing",
      chunkId: correctionId,
      footnote: 2,
    });
    expect(result.created.map((c) => c.stem)).not.toContain("Test_Camera");

    const after = await readFile(join(root, "articles", "Test_Camera.md"), "utf8");

    // The Lens Pairing section gained the new note + its [^2] citation…
    const lens = extractSection(after, "lens-pairing")!;
    expect(lens).toContain("50mm vintage lens");
    expect(lens).toContain("[^2]");
    expect(lens).toContain("[^1]"); // the pre-existing citation survived
    expect(after).toContain("[^2]: `conv:33334444`");
    expect(checkFootnoteIntegrity(after).ok).toBe(true);

    // …and EVERY other section is byte-identical to the original.
    expect(extractSection(after, "autofocus-performance")).toBe(
      extractSection(TEST_CAMERA, "autofocus-performance"),
    );
    const head = TEST_CAMERA.slice(0, TEST_CAMERA.indexOf("## Lens Pairing"));
    expect(after.startsWith(head)).toBe(true);

    // No DUPLICATE article: still exactly the one Test_Camera.md (+ any genuine
    // new creates), never a second Test_Camera variant.
    const files = await readdir(join(root, "articles"));
    expect(files.filter((f) => f.startsWith("Test_Camera")).length).toBe(1);

    store.close();
  });

  it("selects CREATE for a new entity and PATCH for an existing one in the same run", async () => {
    const { root, store } = await seed();

    const result = await runPipeline(store, {
      root,
      extractCall,
      sectionCall,
      call: synthesisCall,
      commit: false,
    });

    // The new entity earned a fresh article…
    expect(result.created.map((c) => c.stem)).toContain("Helios_44-2");
    const helios = await readFile(join(root, "articles", "Helios_44-2.md"), "utf8");
    expect(helios).toContain("# Helios 44-2");
    expect(checkFootnoteIntegrity(helios).ok).toBe(true);

    // …while the pre-existing entity was patched, not re-created.
    expect(result.patched.some((p) => p.stem === "Test_Camera")).toBe(true);
    expect(result.created.map((c) => c.stem)).not.toContain("Test_Camera");

    store.close();
  });

  it("is idempotent: a second run re-folds nothing (synthesized_chunk_sections PK)", async () => {
    const { root, store } = await seed();

    const first = await runPipeline(store, { root, extractCall, sectionCall, call: synthesisCall, commit: false });
    expect(first.patched.length).toBe(1);
    const afterFirst = await readFile(join(root, "articles", "Test_Camera.md"), "utf8");

    const second = await runPipeline(store, { root, extractCall, sectionCall, call: synthesisCall, commit: false });
    expect(second.patched.length).toBe(0); // PK short-circuits the fold

    const afterSecond = await readFile(join(root, "articles", "Test_Camera.md"), "utf8");
    expect(afterSecond).toBe(afterFirst); // byte-identical, nothing re-written

    const ledger = store.db
      .query("SELECT COUNT(*) AS n FROM synthesized_chunk_sections WHERE article_stem = 'Test_Camera'")
      .get() as { n: number };
    expect(ledger.n).toBe(1);

    store.close();
  });
});
