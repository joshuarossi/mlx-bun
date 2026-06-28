// P6-T3 — CREATE flow deterministic scaffolding + gate/NORMALIZE wiring.
//
// Covers everything reachable WITHOUT the GPU: the conv:HASH + footnote
// scaffolding, OUTLINE parsing, sub-clustering, infobox seeding, article
// assembly, and the full createArticle → NORMALIZE → gate path driven by a FAKE
// model (so it's pure and fast). The real base-model draft is a one-load smoke
// in scripts/experiments/dreaming-create-smoke.ts, not here.

import { describe, expect, it } from "bun:test";
import { mkdtemp, readFile } from "node:fs/promises";
import { tmpdir } from "node:os";
import { join } from "node:path";

import { checkFootnoteIntegrity } from "../src/memory/gate";
import { articleStructure, validateArticleStructure, parseInfobox } from "../src/memory/article";
import { MemoryStore, chunkId } from "../src/memory/db";
import {
  assembleArticle,
  buildFootnoteMap,
  buildInfoboxFields,
  convHash,
  countCitedSections,
  countFencedInfoBlocks,
  createArticle,
  deriveSeeAlso,
  footnoteDate,
  isLeakyDraft,
  parseOutline,
  sanitizeSection,
  sectionAnchor,
  subClusterChunks,
  synthesizeCreate,
  type SynthesisChunk,
} from "../src/memory/synthesize";

// ---- a fake camera-article model -------------------------------------------

/** Routes each bounded call to a canned response by inspecting the prompt — the
 *  section draft echoes the FIRST footnote marker the prompt offered it. */
async function fakeCamera(prompt: string): Promise<string> {
  if (prompt.includes("Propose a clean table of contents")) {
    return "## Purchase Decision\n- In the Box";
  }
  if (prompt.includes("Write the LEAD")) {
    return "**Panasonic Lumix S5IIX** is the user's full-frame L-Mount camera, chosen as their primary body for video work.";
  }
  if (prompt.includes("Produce the INFOBOX facts")) {
    return "```\ntype: camera-body\nmount: [[L-Mount]]\nsensor: full-frame 24.2MP\nkind: person\nowned: yes\n```";
  }
  if (prompt.includes("Draft ONLY the body of the")) {
    const list = prompt.split("Cite sources")[1] ?? "";
    const m = /\[\^(\d+)\]/.exec(list);
    const marker = m ? `[^${m[1]}]` : "";
    const t = /Draft ONLY the body of the "([^"]+)"/.exec(prompt);
    const title = t ? t[1] : "section";
    return `The user weighed the ${title} for the S5IIX in detail and reached a clear conclusion.${marker}`;
  }
  return "NONE";
}

function camChunks(): SynthesisChunk[] {
  return [
    {
      id: "67406000-7308-8013-a892-272d0a37eb0a:0-1",
      conv: "67406000-7308-8013-a892-272d0a37eb0a",
      label: "S5IIX purchase decision and deal timing",
      text: "Should I buy the S5IIX? Yes, the deal timing is good and it fits your needs.",
      title: "Lumix S5IIX Decision",
      dateMs: 1732275549599,
    },
    {
      id: "67406000-7308-8013-a892-272d0a37eb0a:2-9",
      conv: "67406000-7308-8013-a892-272d0a37eb0a",
      label: "S5IIX in the box battery and accessories",
      text: "Does the S5IIX come with a battery? Yes, the box includes the body, a battery, and a charger.",
      title: "Lumix S5IIX Decision",
      dateMs: 1732275549599,
    },
    {
      id: "abcd1234-0000-0000-0000-000000000000:0-3",
      conv: "abcd1234-0000-0000-0000-000000000000",
      label: "In the box accessories list",
      text: "The accessory kit and what ships in the box with the camera.",
      title: "Accessory Kit",
      dateMs: 1730000000000,
    },
  ];
}

// ---- scaffolding -----------------------------------------------------------

describe("synthesize — conv:HASH + footnote scaffolding", () => {
  it("convHash strips hyphens and takes the first 8 hex", () => {
    expect(convHash("67406000-7308-8013-a892-272d0a37eb0a")).toBe("67406000");
    expect(convHash("abcd1234")).toBe("abcd1234");
  });

  it("footnoteDate formats epoch-millis as YYYY-MM-DD", () => {
    expect(footnoteDate(1732275549599)).toBe("2024-11-22");
    expect(footnoteDate(null)).toBe("undated");
  });

  it("buildFootnoteMap numbers distinct conversations and emits a backticked def", () => {
    const { entries } = buildFootnoteMap(camChunks());
    expect(entries.length).toBe(2); // two distinct conversations
    expect(entries[0]!.n).toBe(1);
    expect(entries[0]!.def).toBe("[^1]: `conv:67406000` (2024-11-22, Lumix S5IIX Decision)");
    // exactly one backticked conv:HASH per def — the gate's invariant
    for (const e of entries) {
      expect((e.def.match(/`conv:[0-9a-z]{8}`/g) ?? []).length).toBe(1);
    }
  });
});

describe("synthesize — OUTLINE parsing", () => {
  it("strips heading/bullet/numbering markup and dedupes", () => {
    expect(parseOutline("## Purchase Decision\n- In the Box\n1. In the Box")).toEqual([
      "Purchase Decision",
      "In the Box",
    ]);
  });
  it("falls back to a single Overview on empty output", () => {
    expect(parseOutline("NONE")).toEqual(["Overview"]);
  });
  it("caps the section count", () => {
    expect(parseOutline("A\nB\nC\nD\nE\nF\nG\nH", 3)).toEqual(["A", "B", "C"]);
  });
});

describe("synthesize — sub-clustering", () => {
  it("assigns each chunk to the best-overlapping section, dropping empties", () => {
    const map = subClusterChunks(camChunks(), ["Purchase Decision", "In the Box"]);
    expect(map.get(sectionAnchor("Purchase Decision"))?.length).toBe(1);
    expect(map.get(sectionAnchor("In the Box"))?.length).toBe(2);
  });
});

describe("synthesize — infobox seeding", () => {
  it("keeps world/relationship facts, forces kind, drops model kind/aliases, appends aliases", () => {
    const fields = buildInfoboxFields(
      "type: camera-body\nmount: [[L-Mount]]\nkind: person\nowned: yes\nNot a field line\nBADKEY!: x",
      "thing",
      ["S5IIX", "S5 IIX", "S5IIX"],
    );
    expect(fields[0]).toBe("type: camera-body"); // type leads
    expect(fields).toContain("kind: thing"); // our declared kind, not the model's "person"
    expect(fields).not.toContain("kind: person");
    expect(fields).toContain("mount: [[L-Mount]]");
    expect(fields).toContain("owned: yes");
    expect(fields[fields.length - 1]).toBe("aliases: S5IIX, S5 IIX"); // deduped, trails
  });

  it("always yields at least a parseable kind-only infobox", () => {
    const fields = buildInfoboxFields("(no usable lines)", "standard");
    expect(fields).toEqual(["kind: standard"]);
  });
});

describe("synthesize — assembly + derivations", () => {
  it("assembles the fixed skeleton with References last and counts cited sections", () => {
    const md = assembleArticle({
      stem: "Panasonic_Lumix_S5IIX",
      infoboxFields: ["type: camera-body", "kind: thing", "mount: [[L-Mount]]"],
      lead: "**Panasonic Lumix S5IIX** is a camera.",
      sections: [
        { title: "Purchase Decision", anchor: "purchase-decision", body: "Chose it.[^1]" },
        { title: "In the Box", anchor: "in-the-box", body: "Battery included." },
      ],
      seeAlso: ["L-Mount"],
      referenceDefs: ["[^1]: `conv:67406000` (2024-11-22, src)"],
    });
    const v = validateArticleStructure(md);
    expect(v.ok).toBe(true);
    expect(checkFootnoteIntegrity(md).ok).toBe(true);
    expect(countCitedSections(md)).toBe(1);
    expect(md.indexOf("## See also")).toBeLessThan(md.indexOf("## References"));
  });

  it("deriveSeeAlso resolves only known stems, excluding self/Category", () => {
    const stems = new Set(["L-Mount", "Panasonic_Lumix_S5IIX"]);
    const got = deriveSeeAlso(
      "mount: [[L-Mount]] and [[Category:Cameras]] and [[Unknown_Thing]] and [[Panasonic Lumix S5IIX]]",
      stems,
      "Panasonic_Lumix_S5IIX",
    );
    expect(got).toEqual(["L-Mount"]);
  });

  it("sanitizeSection drops a repeated heading and stray definition lines", () => {
    const out = sanitizeSection("## Purchase Decision\nChose it.[^1]\n[^1]: `conv:67406000` (x)", "Purchase Decision");
    expect(out).toBe("Chose it.[^1]");
  });
});

// ---- createArticle: gate + NORMALIZE wiring --------------------------------

describe("synthesize — createArticle (fake model)", () => {
  it("CREATE yields a gated, normalized, cited, infobox-bearing article", async () => {
    const outcome = await createArticle("Panasonic Lumix S5IIX", "thing", camChunks(), {
      call: fakeCamera,
      stems: new Set(["L-Mount"]),
      aliases: ["S5IIX", "S5 IIX"],
    });
    expect(outcome.action).toBe("created");
    expect(outcome.content).not.toBeNull();
    const md = outcome.content!;

    // structurally valid + footnote-bijective (NORMALIZE + gate both ran)
    expect(validateArticleStructure(md).ok).toBe(true);
    expect(checkFootnoteIntegrity(md).ok).toBe(true);

    // parseable infobox, kind forced to thing, mount preserved
    const box = parseInfobox(md);
    expect(box).not.toBeNull();
    expect(box!.entityKind).toBe("thing");
    expect(md).toContain("mount: [[L-Mount]]");

    // ≥1 cited section, and the ledger edges were collected
    expect(outcome.citedSections).toBeGreaterThanOrEqual(1);
    expect(outcome.chunkSections.length).toBeGreaterThan(0);
    expect(md).toContain("# Panasonic Lumix S5IIX");
  });

  it("a weak pass that drops a pre-existing citation is gated to NO-OP", async () => {
    const before =
      "# Panasonic Lumix S5IIX\n\nOld prose.[^1]\n\n## References\n\n[^1]: `conv:deadbeef` (2024-01-01, old)\n";
    const outcome = await createArticle("Panasonic Lumix S5IIX", "thing", camChunks(), {
      call: fakeCamera,
      stems: new Set(["L-Mount"]),
      before,
    });
    expect(outcome.action).toBe("skipped");
    expect(outcome.content).toBeNull();
    expect(outcome.reason).toContain("deadbeef");
  });
});

// ---- defect hardening: leak / single-infobox / bijection / grounding -------

describe("synthesize — leak rejection (isLeakyDraft)", () => {
  // The real anamorphic_adapter leak string the per-section gate must reject.
  const REAL_LEAK =
    "The user is asking to draft the body prose for the Anamorphic Rig Setup " +
    "section. The source material discusses: 1. the rig, 2. the anamorphic lens.";

  it("rejects the real anamorphic_adapter meta/planning leak", () => {
    expect(isLeakyDraft(REAL_LEAK)).toBe(true);
  });

  it("rejects refusals and first-person-about-the-task voice", () => {
    expect(isLeakyDraft("As an AI, I cannot help draft this section.")).toBe(true);
    expect(isLeakyDraft("I'm sorry, but I don't have enough information to write this.")).toBe(true);
    expect(isLeakyDraft("I will draft the section based on the source material.")).toBe(true);
    expect(isLeakyDraft("1. Discuss the rig. 2. Describe the lens.")).toBe(true);
  });

  it("accepts clean personal-wiki prose (which IS about the user)", () => {
    expect(
      isLeakyDraft("The Panasonic Lumix S5IIX is the user's full-frame L-Mount body, used for video.[^1]"),
    ).toBe(false);
    expect(
      isLeakyDraft("The user weighed the purchase decision in detail and reached a clear conclusion.[^1]"),
    ).toBe(false);
    expect(isLeakyDraft("")).toBe(false);
  });

  it("drops a section whose draft leaks meta/planning after one retry", async () => {
    let sectionCalls = 0;
    const fakeLeak = async (prompt: string): Promise<string> => {
      if (prompt.includes("Propose a clean table of contents")) return "Purchase Decision";
      if (prompt.includes("Write the LEAD")) return "**Panasonic Lumix S5IIX** is the user's camera.";
      if (prompt.includes("Produce the INFOBOX facts")) return "kind: thing\nowned: yes";
      if (prompt.includes("Draft ONLY the body of the")) {
        sectionCalls++;
        return "The user is asking me to draft the Purchase Decision section. The source material discusses the camera.";
      }
      return "NONE";
    };
    const outcome = await createArticle("Panasonic Lumix S5IIX", "thing", camChunks(), {
      call: fakeLeak,
      stems: new Set(["L-Mount"]),
    });
    expect(sectionCalls).toBe(2); // drafted once, then retried once before the drop
    expect(outcome.action).toBe("created"); // lead-only stub still commits
    const md = outcome.content!;
    expect(md).not.toContain("The user is asking");
    expect(md).not.toContain("## Purchase Decision"); // the leaky section was dropped
    expect(outcome.chunkSections.length).toBe(0); // no edges for a dropped section
  });
});

describe("synthesize — single infobox (strip stray fenced info blocks)", () => {
  it("sanitizeSection strips a stray fenced info block from a drafted body", () => {
    const out = sanitizeSection(
      "Prose before.[^1]\n```info\ntype: Mirrorless camera\nmount: [[L-Mount]]\n```\nProse after.",
      "Setup",
    );
    expect(out).not.toContain("```info");
    expect(out).not.toContain("type: Mirrorless camera");
    expect(out).toContain("Prose before.[^1]");
    expect(out).toContain("Prose after.");
  });

  it("createArticle yields exactly one infobox when a section parrots one", async () => {
    const rigChunks: SynthesisChunk[] = [
      {
        id: "11112222-0000-0000-0000-000000000000:0-1",
        conv: "11112222-0000-0000-0000-000000000000",
        label: "anamorphic rig setup",
        text: "The anamorphic rig setup and how the user configured it for video.",
        title: "Rig Setup",
        dateMs: 1700000000000,
      },
    ];
    const fakeStray = async (prompt: string): Promise<string> => {
      if (prompt.includes("Propose a clean table of contents")) return "Rig Setup";
      if (prompt.includes("Write the LEAD")) return "**Anamorphic Rig** is the user's video rig.";
      if (prompt.includes("Produce the INFOBOX facts")) return "kind: thing\nowned: yes";
      if (prompt.includes("Draft ONLY the body of the")) {
        const m = /\[\^(\d+)\]/.exec(prompt.split("Cite sources")[1] ?? "");
        const marker = m ? `[^${m[1]}]` : "";
        return (
          `The rig is configured for anamorphic capture.${marker}\n\n` +
          "```info\ntype: Mirrorless camera\nmount: [[L-Mount]]\nsensor: full-frame 24.2MP\n```\n\n" +
          "It performs reliably for the user's work."
        );
      }
      return "NONE";
    };
    const outcome = await createArticle("Anamorphic Rig", "thing", rigChunks, { call: fakeStray });
    expect(outcome.action).toBe("created");
    const md = outcome.content!;
    expect(countFencedInfoBlocks(md)).toBe(1); // only the code-constructed block
    expect(md).not.toContain("type: Mirrorless camera"); // the parroted block was stripped
    expect(md).toContain("kind: thing");
  });
});

describe("synthesize — footnote bijection enforcement", () => {
  it("NO-OPs when a cited conversation yields an unrepairable malformed citation", async () => {
    // A conv UUID with only 7 hex chars produces `conv:abc1234` — too short for
    // the fixed 8-hex `conv:HASH`, a def NORMALIZE cannot repair. The committed
    // article would be citation-broken, so the create must veto it.
    const shortConv: SynthesisChunk[] = [
      { id: "x1", conv: "abc1234", label: "thin note", text: "A short note about the topic.", title: "Note", dateMs: 1700000000000 },
    ];
    const fakeCite = async (prompt: string): Promise<string> => {
      if (prompt.includes("Propose a clean table of contents")) return "NONE";
      if (prompt.includes("Write the LEAD")) return "**Topic** is a thing the user noted.[^1]";
      if (prompt.includes("Produce the INFOBOX facts")) return "kind: thing";
      if (prompt.includes("Draft ONLY the body of the")) return "A factual note about the topic.[^1]";
      return "NONE";
    };
    const outcome = await createArticle("Topic", "thing", shortConv, { call: fakeCite });
    expect(outcome.action).toBe("skipped");
    expect(outcome.content).toBeNull();
    expect(outcome.reason).toContain("footnote");
  });
});

describe("synthesize — grounded infobox (no parroted spec-leak)", () => {
  it("drops camera hardware fields on a domain entity, keeps generic facts", () => {
    const fields = buildInfoboxFields(
      "type: Photography\nmount: [[L-Mount]]\nsensor: full-frame 24.2MP\nsubfield: optics\nowned: no",
      "domain",
    );
    expect(fields).toContain("type: Photography");
    expect(fields).toContain("kind: domain");
    expect(fields).toContain("subfield: optics");
    expect(fields.some((f) => f.startsWith("mount:"))).toBe(false); // hardware spec is ungrounded
    expect(fields.some((f) => f.startsWith("sensor:"))).toBe(false);
  });

  it("keeps the same hardware fields on a thing entity", () => {
    const fields = buildInfoboxFields("type: camera-body\nmount: [[L-Mount]]", "thing");
    expect(fields).toContain("mount: [[L-Mount]]");
  });
});

// ---- synthesizeCreate: effectful write + ledger ----------------------------

describe("synthesize — synthesizeCreate (store + vault)", () => {
  it("writes the article into a smoke vault and records synthesized_chunk_sections", async () => {
    const store = new MemoryStore(":memory:");
    const conv = "67406000-7308-8013-a892-272d0a37eb0a";
    store.db.run("INSERT INTO conversations (conv, source, title, updated_at, chunked_at) VALUES (?,?,?,?,?)", [
      conv,
      "pi-terminal",
      "Lumix S5IIX Decision",
      1732275549599,
      null,
    ]);
    const msgs = [
      "Should I buy the S5IIX?",
      "Yes, the deal timing is good.",
      "Does it come with a battery?",
      "Yes, the box includes a battery.",
    ];
    msgs.forEach((text, i) =>
      store.db.run("INSERT INTO messages (conv, position, role, uuid, text) VALUES (?,?,?,?,?)", [
        conv,
        i,
        i % 2 === 0 ? "user" : "assistant",
        `m${i}`,
        text,
      ]),
    );
    const c1 = chunkId(conv, 0, 1);
    const c2 = chunkId(conv, 2, 3);
    store.db.run("INSERT INTO chunks (id, conv, start, end, label) VALUES (?,?,?,?,?)", [c1, conv, 0, 1, "purchase decision"]);
    store.db.run("INSERT INTO chunks (id, conv, start, end, label) VALUES (?,?,?,?,?)", [c2, conv, 2, 3, "in the box battery"]);

    const root = await mkdtemp(join(tmpdir(), "dreaming-smoke-"));
    const res = await synthesizeCreate(store, {
      entity: "Panasonic Lumix S5IIX",
      kind: "thing",
      chunkIds: [c1, c2],
      root,
      aliases: ["S5IIX"],
      call: fakeCamera,
      commit: false,
    });

    expect(res.created).toBe(true);
    expect(res.hasInfobox).toBe(true);
    expect(res.citedSections).toBeGreaterThanOrEqual(1);

    const md = await readFile(join(root, "articles", "Panasonic_Lumix_S5IIX.md"), "utf8");
    expect(md).toContain("# Panasonic Lumix S5IIX");
    expect(parseInfobox(md)).not.toBeNull();

    const rows = store.db
      .query("SELECT chunk_id, article_stem, section_anchor FROM synthesized_chunk_sections ORDER BY chunk_id")
      .all() as { chunk_id: string; article_stem: string; section_anchor: string }[];
    expect(rows.length).toBeGreaterThan(0);
    expect(rows.every((r) => r.article_stem === "Panasonic_Lumix_S5IIX")).toBe(true);
    store.close();
  });
});

// ---- fence-balance guard (unbalanced ``` in a drafted section) --------------

/** Count ``` fence lines in a document. */
function fenceLines(md: string): number {
  return md.split("\n").filter((l) => /^```/.test(l)).length;
}

describe("synthesis never assembles an unbalanced fence", () => {
  it("sanitizeSection balances a section that opened a ``` but never closed it", () => {
    const raw = "Here is a snippet:\n\n```js\nconst x = 1;";
    const body = sanitizeSection(raw, "Examples");
    expect(fenceLines(body) % 2).toBe(0);
    expect(body).toContain("const x = 1;");
  });

  it("assembleArticle closes a dangling section fence so trailing headings survive", () => {
    const md = assembleArticle({
      stem: "Demo_Thing",
      infoboxFields: ["kind: thing"],
      lead: "**Demo Thing** is a thing.[^1]",
      // This section body opens a ```python fence and never closes it.
      sections: [
        { title: "Examples", anchor: "examples", body: "Snippet:\n\n```python\nprint(1)" },
      ],
      seeAlso: ["Other_Thing"],
      referenceDefs: ["[^1]: `conv:a1b2c3d4` (2024-01-01, src) — note"],
    });
    // EVEN fence count — the dangling ```python was closed.
    expect(fenceLines(md) % 2).toBe(0);
    // ## See also and ## References are recognized headings, not swallowed as code.
    const kinds = articleStructure(md).map((i) => i.kind);
    expect(kinds).toContain("see-also");
    expect(kinds).toContain("references");
    expect(validateArticleStructure(md).ok).toBe(true);
  });

  it("createArticle yields a balanced, footnote-bijective article even when a section draft is unbalanced", async () => {
    const fakeUnclosed = async (prompt: string): Promise<string> => {
      if (prompt.includes("Propose a clean table of contents")) return "Examples";
      if (prompt.includes("Write the LEAD")) return "**Widget** is a small tool the user built.";
      if (prompt.includes("Produce the INFOBOX facts")) return "type: tool\nkind: thing";
      if (prompt.includes("Draft ONLY the body of the")) {
        const m = /\[\^(\d+)\]/.exec(prompt.split("Cite sources")[1] ?? "");
        const marker = m ? `[^${m[1]}]` : "";
        // An unclosed ```python fence in the section body.
        return `The user wrote a small script.${marker}\n\n\`\`\`python\nprint("hi")`;
      }
      return "NONE";
    };
    const chunks: SynthesisChunk[] = [
      { id: "c1", conv: "11111111-1111-1111-1111-111111111111", label: "script", text: "a python script the user wrote", title: "Script", dateMs: Date.UTC(2024, 0, 1) },
    ];
    const out = await createArticle("Widget", "thing", chunks, { call: fakeUnclosed });
    expect(out.content).not.toBeNull();
    expect(fenceLines(out.content!) % 2).toBe(0);
    expect(checkFootnoteIntegrity(out.content!).ok).toBe(true);
    expect(validateArticleStructure(out.content!).ok).toBe(true);
  });
});
