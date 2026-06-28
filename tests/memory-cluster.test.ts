// P7-T1 — SECTION-ROUTE deterministic scaffolding (no GPU).
//
// Covers everything reachable WITHOUT the model: TOC iteration into routable
// sections (with gists, tail sections excluded), the new-section parse, the
// all-yes / all-no→new-section binary routing driven by a FAKE model, structural
// pruning to ROUTE-matched articles, and the chunk_sections ledger write. The
// real base-model M×N grid is the one-load smoke in scripts/memory/eval-section-route.ts.

import { describe, expect, it } from "bun:test";

import { MemoryStore, chunkId } from "../src/memory/db";
import {
  articleSections,
  articleTitle,
  buildSectionBinaryPrompt,
  firstSentences,
  parseNewSection,
  persistSectionRoutes,
  routeChunkSections,
  routeSections,
  type SectionCall,
  type SectionRouteArticle,
  type SectionRouteChunk,
} from "../src/memory/cluster";

// ---- fixtures --------------------------------------------------------------

const CAMERA = `# Panasonic Lumix S5IIX

\`\`\`info
type: camera-body
kind: thing
\`\`\`

**Panasonic Lumix S5IIX** is the user's full-frame body.

## Lens Pairing Considerations

The user pairs the S5IIX with vintage glass like the Helios 44-2.[^1] Focus peaking helps nail manual focus.

## Camera Body Compatibility

The body offers IBIS for handheld manual shooting.[^1] It accepts SDXC cards up to 1TB.

## Lens Mounting And Adapters

Heavy adapters put torque on the [[L-Mount]]; pivoting the mount point to the lens clamp relieves it.

## References

[^1]: \`conv:67030293\` (2024-10-06, Helios 44-2 on Full Frame)
`;

const LENS = `# lens

## Helios Naming Breakdown

The "44-2" in Helios 44-2 denotes the optical block revision.

## See also

- [[photography]]

## References

[^1]: \`conv:67030293\` (2024-10-06, Helios)
`;

function camArticle(): SectionRouteArticle {
  return { stem: "Panasonic_Lumix_S5IIX", content: CAMERA };
}

// A fake model: matches a section iff the prompt's section heading shares a
// keyword with the chunk gist; names a new section from a sentinel gist.
function keywordCall(opts?: { newName?: string }): SectionCall {
  return async (prompt: string) => {
    if (prompt.includes("name that NEW section")) {
      return opts?.newName ?? "NONE";
    }
    const heading = /Section heading: "([^"]+)"/.exec(prompt)?.[1]?.toLowerCase() ?? "";
    const gist = /New note: (.+)/.exec(prompt)?.[1]?.toLowerCase() ?? "";
    const hit = heading
      .split(/\s+/)
      .some((w) => w.length > 3 && gist.includes(w));
    return hit ? "yes" : "no";
  };
}

// ---- section enumeration ---------------------------------------------------

describe("section-route — TOC iteration", () => {
  it("enumerates topical sections, excluding H1 + References/See also", () => {
    const secs = articleSections(CAMERA);
    expect(secs.map((s) => s.heading)).toEqual([
      "Lens Pairing Considerations",
      "Camera Body Compatibility",
      "Lens Mounting And Adapters",
    ]);
  });

  it("drops the See also + References tail and never the title", () => {
    const secs = articleSections(LENS);
    expect(secs.map((s) => s.heading)).toEqual(["Helios Naming Breakdown"]);
  });

  it("gives each section a footnote/wikilink-free gist", () => {
    const secs = articleSections(CAMERA);
    const pairing = secs.find((s) => s.anchor === "lens-pairing-considerations")!;
    expect(pairing.gist).not.toContain("[^1]");
    expect(pairing.gist.toLowerCase()).toContain("helios");
    const mounting = secs.find((s) => s.anchor === "lens-mounting-and-adapters")!;
    expect(mounting.gist).toContain("L-Mount"); // wikilink unwrapped, brackets gone
    expect(mounting.gist).not.toContain("[[");
  });

  it("uses the H1 as the article title", () => {
    expect(articleTitle(CAMERA, "Panasonic_Lumix_S5IIX")).toBe("Panasonic Lumix S5IIX");
    expect(articleTitle("## Body only", "My_Stem")).toBe("My Stem");
  });
});

describe("section-route — firstSentences", () => {
  it("keeps the first two sentences", () => {
    expect(firstSentences("One. Two. Three.", 2)).toBe("One. Two.");
  });
  it("returns the whole thing when under the sentence count", () => {
    expect(firstSentences("Only one sentence here", 2)).toBe("Only one sentence here");
  });
});

// ---- new-section parse -----------------------------------------------------

describe("section-route — new-section parse", () => {
  it("accepts a 2–5 word name and slugs it", () => {
    expect(parseNewSection("Audio Recording Setup")).toEqual({
      title: "Audio Recording Setup",
      anchor: "audio-recording-setup",
    });
  });
  it("tolerates a stray heading/bullet prefix", () => {
    expect(parseNewSection("## Battery And Charging")?.anchor).toBe("battery-and-charging");
    expect(parseNewSection("- Cards And Storage")?.title).toBe("Cards And Storage");
  });
  it("rejects NONE, empty, and out-of-range names", () => {
    expect(parseNewSection("NONE")).toBeNull();
    expect(parseNewSection("")).toBeNull();
    expect(parseNewSection("Mount")).toBeNull(); // 1 word
    expect(parseNewSection("a b c d e f g")).toBeNull(); // 7 words
  });
});

describe("section-route — prompt builder is schematic", () => {
  it("embeds the section + chunk context without leaking an answer example", () => {
    const secs = articleSections(CAMERA);
    const p = buildSectionBinaryPrompt("Panasonic Lumix S5IIX", secs[0]!, "Does it ship with a battery?");
    expect(p).toContain("Lens Pairing Considerations");
    expect(p).toContain("Does it ship with a battery?"); // the new-note gist
    expect(p.toLowerCase()).toContain("yes or no");
    // The framing must invite a same-subject CORRECTION (a contradicting value
    // is still a match), not a value-equality check that drops it.
    expect(p.toLowerCase()).toContain("contradicting");
  });
});

// ---- binary routing (fake model) -------------------------------------------

describe("section-route — binary routing", () => {
  it("matches the on-topic section, leaves the rest", async () => {
    const chunk: SectionRouteChunk = {
      id: "c:0-1",
      label: "Adapter torque on the mount",
      gist: "Heavy adapters stress the mounting connection; relieve it at the clamp.",
    };
    const res = await routeSections(chunk, camArticle(), { call: keywordCall() });
    expect(res.matchedAnchors).toEqual(["lens-mounting-and-adapters"]);
    expect(res.newSection).toBeNull();
  });

  it("all-no + substantive → a NAMED new section, not a drop", async () => {
    const chunk: SectionRouteChunk = {
      id: "c:2-3",
      label: "XLR audio input options",
      gist: "Recording pro audio over the hot shoe with an XLR adapter.",
    };
    const res = await routeSections(chunk, camArticle(), {
      call: keywordCall({ newName: "Audio Recording Options" }),
    });
    expect(res.matchedAnchors).toEqual([]);
    expect(res.newSection).toEqual({ title: "Audio Recording Options", anchor: "audio-recording-options" });
  });

  it("all-no + NOT substantive → no new section (the chunk is held, not forced)", async () => {
    const chunk: SectionRouteChunk = { id: "c:4-5", label: "passing mention", gist: "zzz unrelated trivia" };
    const res = await routeSections(chunk, camArticle(), {
      call: keywordCall({ newName: "Should Not Be Used" }),
      substantive: false,
    });
    expect(res.matchedAnchors).toEqual([]);
    expect(res.newSection).toBeNull();
  });

  it("never accepts a 'new' name that duplicates an existing heading", async () => {
    const chunk: SectionRouteChunk = { id: "c:6-7", label: "x", gist: "zzz nothing matches" };
    const res = await routeSections(chunk, camArticle(), {
      call: keywordCall({ newName: "Camera Body Compatibility" }), // echoes an existing section
    });
    expect(res.newSection).toBeNull();
  });
});

// ---- hierarchical pruning --------------------------------------------------

describe("section-route — pruning to ROUTE-matched articles", () => {
  it("only iterates the articles handed in (the matched set), never the vault", async () => {
    const seenArticles = new Set<string>();
    const trackingCall: SectionCall = async (prompt) => {
      const t = /Article: "([^"]+)"/.exec(prompt)?.[1] ?? "";
      seenArticles.add(t);
      return "no";
    };
    const chunk: SectionRouteChunk = { id: "c:0-1", label: "x", gist: "zzz" };
    // ROUTE matched ONLY the camera; the lens article exists but is NOT passed.
    const results = await routeChunkSections(chunk, [camArticle()], {
      call: trackingCall,
      substantive: false,
    });
    expect(results.map((r) => r.stem)).toEqual(["Panasonic_Lumix_S5IIX"]);
    expect([...seenArticles]).toEqual(["Panasonic Lumix S5IIX"]); // lens never probed
  });
});

// ---- ledger write ----------------------------------------------------------

describe("section-route — chunk_sections ledger", () => {
  it("writes matched + new-section rows and is idempotent", () => {
    const store = new MemoryStore(":memory:");
    try {
      const conv = "67030293";
      const id = chunkId(conv, 0, 1);
      // chunk_sections.chunk_id FKs chunks(id) — seed the conversation + chunk.
      store.db.run("INSERT INTO conversations (conv, source, updated_at) VALUES (?, ?, ?)", [conv, "pi-web", 1]);
      store.db.run("INSERT INTO chunks (id, conv, start, end, label) VALUES (?, ?, ?, ?, ?)", [id, conv, 0, 1, null]);
      const results = [
        {
          stem: "Panasonic_Lumix_S5IIX",
          matchedAnchors: ["camera-body-compatibility", "lens-mounting-and-adapters"],
          newSection: { title: "Audio Recording Options", anchor: "audio-recording-options" },
        },
      ];
      const first = persistSectionRoutes(store, id, results);
      expect(first).toBe(3);
      // Re-running writes nothing new (PK blocks the double-fold).
      expect(persistSectionRoutes(store, id, results)).toBe(0);

      const rows = store.db
        .query("SELECT section_anchor FROM chunk_sections WHERE chunk_id = ? ORDER BY section_anchor")
        .all(id) as { section_anchor: string }[];
      expect(rows.map((r) => r.section_anchor)).toEqual([
        "audio-recording-options",
        "camera-body-compatibility",
        "lens-mounting-and-adapters",
      ]);
    } finally {
      store.close();
    }
  });
});
