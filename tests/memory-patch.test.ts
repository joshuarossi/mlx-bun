// P7-T2 — PATCH (UPDATE branch) deterministic invariants.
//
// Everything reachable WITHOUT the GPU, driven by a FAKE model: the only-section
// -changed byte-preservation invariant (every OTHER section identical, the target
// gains a correct [^N]/[^N]: pair), the assign-footnote helpers, the weak/uncited
// → NO-OP gate, and the synthesized_chunk_sections PK idempotency. The real
// base-model integration + self-healing demo is the one-load eval in
// scripts/memory/eval-patch.ts, not here.

import { describe, expect, it } from "bun:test";
import { mkdtemp, mkdir, readFile, writeFile } from "node:fs/promises";
import { tmpdir } from "node:os";
import { join } from "node:path";

import { checkFootnoteIntegrity } from "../src/memory/gate";
import { extractSection } from "../src/memory/vault";
import { MemoryStore, chunkId } from "../src/memory/db";
import { LEAD_ANCHOR } from "../src/memory/cluster";
import {
  appendReferenceDef,
  articleFootnoteState,
  patchSection,
  replaceSection,
  synthesizePatch,
  type PatchInput,
  type SynthesisChunk,
  type SynthesisCall,
} from "../src/memory/synthesize";

// ---- fixtures --------------------------------------------------------------

// A fully-normalized article: footnotes bijective + contiguous from 1, infobox
// sorted, References last — so NORMALIZE is a true no-op and the only-section
// -changed invariant is exact. "Mounting And Adapters" carries NO footnote, so a
// fold there mints a clean [^2].
const ARTICLE = `# Test Camera

\`\`\`info
type: camera-body
kind: thing
\`\`\`

**Test Camera** is the user's full-frame body, used with vintage glass.

## Lens Pairing

The user pairs the body with vintage glass for its rendering.[^1]

## Mounting And Adapters

Heavy adapters put torque on the mount; relieving it at the lens clamp helps.

## References

[^1]: \`conv:11112222\` (2024-01-01, Lens pairing chat)
`;

function newChunk(): SynthesisChunk {
  return {
    id: "33334444-0000-0000-0000-000000000000:0-2",
    conv: "33334444-0000-0000-0000-000000000000",
    label: "Centering adapter load on a tripod clamp",
    text: "Mounting a heavy adapter: attach the clamp foot to a tripod plate so the load sits under the lens, not the camera mount.",
    title: "Adapter Load Centering",
    dateMs: 1735689600000,
  };
}

/** A fake model that returns a clean integrated body carrying the assigned [^N]. */
function integrateCall(extra = ""): SectionCallLike {
  const call: SectionCallLike = async (prompt: string) => {
    const m = /placing the marker \[\^(\d+)\]/.exec(prompt);
    const marker = m ? `[^${m[1]}]` : "";
    return `Heavy adapters put torque on the mount; relieving it at the lens clamp helps. Centering the clamp foot on a tripod plate puts the load under the lens, sparing the mount.${marker}${extra}`;
  };
  return call;
}

type SectionCallLike = SynthesisCall;

// ---- pure helpers ----------------------------------------------------------

describe("patch — articleFootnoteState", () => {
  it("reads the max footnote number and maps defined conv:HASH → number", () => {
    const st = articleFootnoteState(ARTICLE);
    expect(st.maxN).toBe(1);
    expect(st.byHash.get("11112222")).toBe(1);
    expect(st.byHash.has("33334444")).toBe(false);
  });

  it("takes the max across non-contiguous, out-of-order definitions", () => {
    const a = "body [^1] [^7]\n\n## References\n\n[^7]: `conv:aaaabbbb` (x)\n[^1]: `conv:ccccdddd` (y)\n";
    const st = articleFootnoteState(a);
    expect(st.maxN).toBe(7);
    expect(st.byHash.get("aaaabbbb")).toBe(7);
  });
});

describe("patch — replaceSection byte-preservation", () => {
  it("swaps only the target block, leaving the rest byte-identical", () => {
    const out = replaceSection(ARTICLE, "mounting-and-adapters", "## Mounting And Adapters\n\nNew body.\n")!;
    expect(out).not.toBeNull();
    // Every byte before the target is identical.
    const head = ARTICLE.slice(0, ARTICLE.indexOf("## Mounting And Adapters"));
    expect(out.startsWith(head)).toBe(true);
    // The untouched section is identical.
    expect(extractSection(out, "lens-pairing")).toBe(extractSection(ARTICLE, "lens-pairing"));
    expect(out).toContain("New body.");
  });

  it("returns null for a missing anchor", () => {
    expect(replaceSection(ARTICLE, "does-not-exist", "x")).toBeNull();
  });
});

describe("patch — appendReferenceDef", () => {
  it("inserts a def after the last existing def in References", () => {
    const out = appendReferenceDef(ARTICLE, "[^2]: `conv:33334444` (2025-01-01, src)");
    const refs = extractSection(out, "references")!;
    expect(refs).toContain("[^1]: `conv:11112222`");
    expect(refs).toContain("[^2]: `conv:33334444`");
    // body sections untouched
    expect(extractSection(out, "lens-pairing")).toBe(extractSection(ARTICLE, "lens-pairing"));
  });

  it("creates a References section when the article has none", () => {
    const a = "# Stub\n\nBody only.\n";
    const out = appendReferenceDef(a, "[^1]: `conv:33334444` (2025-01-01, src)");
    expect(out).toContain("## References");
    expect(out).toContain("[^1]: `conv:33334444`");
  });
});

// ---- ACCEPTANCE 1 — only-that-section-changed ------------------------------

describe("patch — only the target section changes", () => {
  it("gains a correct [^N]/[^N]: pair, every other section byte-identical, gate passes", async () => {
    const out = await patchSection({ article: ARTICLE, anchor: "mounting-and-adapters", chunk: newChunk() }, { call: integrateCall() });

    expect(out.action).toBe("patched");
    expect(out.footnote).toBe(2);
    expect(out.addedDef).toBe(true);
    expect(out.reusedFootnote).toBe(false);
    const after = out.content!;

    // The target section gained the [^2] marker.
    const target = extractSection(after, "mounting-and-adapters")!;
    expect(target).toContain("[^2]");
    // …and References gained the matching [^2]: definition citing the new conv.
    expect(after).toContain("[^2]: `conv:33334444`");
    expect(checkFootnoteIntegrity(after).ok).toBe(true);

    // Every OTHER body section is byte-identical.
    expect(extractSection(after, "lens-pairing")).toBe(extractSection(ARTICLE, "lens-pairing"));
    // Everything before the patched section (H1 + infobox + lead) is byte-identical.
    const head = ARTICLE.slice(0, ARTICLE.indexOf("## Mounting And Adapters"));
    expect(after.startsWith(head)).toBe(true);
    // The pre-existing [^1] citation survived.
    expect(after).toContain("[^1]: `conv:11112222`");
  });

  it("reuses a marker (no new def) when the chunk's conversation is already cited", async () => {
    const sameConv: SynthesisChunk = { ...newChunk(), conv: "11112222-0000-0000-0000-000000000000", id: "11112222:9-9" };
    // The conv hashes to 11112222 — already defined as [^1]; the fold must reuse it.
    const reuseCall: SynthesisCall = async (prompt) => {
      const m = /placing the marker \[\^(\d+)\]/.exec(prompt);
      return `The user pairs the body with vintage glass for its rendering, now mounted via a load-centered clamp.${m ? `[^${m[1]}]` : ""}`;
    };
    const out = await patchSection({ article: ARTICLE, anchor: "lens-pairing", chunk: sameConv }, { call: reuseCall });
    expect(out.action).toBe("patched");
    expect(out.footnote).toBe(1);
    expect(out.reusedFootnote).toBe(true);
    expect(out.addedDef).toBe(false);
    // Still exactly one [^1]: definition (no duplicate minted).
    expect((out.content!.match(/^\[\^1\]:/gm) ?? []).length).toBe(1);
    expect(checkFootnoteIntegrity(out.content!).ok).toBe(true);
  });
});

// ---- ACCEPTANCE 1b — the LEAD is a patch target (verdict self-healing) ------

describe("patch — folds into the LEAD via LEAD_ANCHOR", () => {
  it("rewrites only the lead bytes, mints [^2], keeps every section byte-identical", async () => {
    const leadCall: SynthesisCall = async (prompt) => {
      const m = /\[\^(\d+)\] immediately after/.exec(prompt) ?? /\[\^(\d+)\] marker/.exec(prompt);
      const marker = m ? `[^${m[1]}]` : "";
      return `**Test Camera** is the user's full-frame body. The user now shoots video on it as well.${marker}`;
    };
    const out = await patchSection({ article: ARTICLE, anchor: LEAD_ANCHOR, chunk: newChunk() }, { call: leadCall });

    expect(out.action).toBe("patched");
    expect(out.anchor).toBe(LEAD_ANCHOR);
    expect(out.footnote).toBe(2);
    const after = out.content!;

    // The lead changed and carries the new [^2]; References gained its def.
    expect(after).toContain("now shoots video");
    expect(after).toContain("[^2]");
    expect(after).toContain("[^2]: `conv:33334444`");
    expect(checkFootnoteIntegrity(after).ok).toBe(true);

    // Every body section is byte-identical — only the lead moved.
    expect(extractSection(after, "lens-pairing")).toBe(extractSection(ARTICLE, "lens-pairing"));
    expect(extractSection(after, "mounting-and-adapters")).toBe(extractSection(ARTICLE, "mounting-and-adapters"));
    expect(after).toContain("[^1]: `conv:11112222`"); // pre-existing citation survived
  });

  it("NO-OPs an uncited lead rewrite (vault untouched)", async () => {
    const uncited: SynthesisCall = async () => "**Test Camera** is the user's full-frame body, now also a video rig.";
    const out = await patchSection({ article: ARTICLE, anchor: LEAD_ANCHOR, chunk: newChunk() }, { call: uncited });
    expect(out.action).toBe("skipped");
    expect(out.content).toBeNull();
  });
});

// ---- ACCEPTANCE 2 — weak/uncited → NO-OP -----------------------------------

describe("patch — weak / leaky / uncited output is a NO-OP", () => {
  it("NO-OPs a refusal (leaky after one retry), leaving content null", async () => {
    const refuse: SynthesisCall = async () => "I'm sorry, but I cannot help write this section.";
    const out = await patchSection({ article: ARTICLE, anchor: "mounting-and-adapters", chunk: newChunk() }, { call: refuse });
    expect(out.action).toBe("skipped");
    expect(out.content).toBeNull();
    expect(out.reason).toContain("NO-OP");
  });

  it("NO-OPs when the model integrates clean prose but never places the [^N] marker", async () => {
    const uncited: SynthesisCall = async () =>
      "Heavy adapters put torque on the mount; relieving it at the lens clamp helps. Centering the load under the lens via a tripod clamp spares the mount.";
    const out = await patchSection({ article: ARTICLE, anchor: "mounting-and-adapters", chunk: newChunk() }, { call: uncited });
    expect(out.action).toBe("skipped");
    expect(out.content).toBeNull();
  });

  it("retries ONCE, then NO-OPs (the model is called exactly twice)", async () => {
    let calls = 0;
    const flaky: SynthesisCall = async () => {
      calls++;
      return "As an AI, I will now draft the section based on the source material.";
    };
    const out = await patchSection({ article: ARTICLE, anchor: "mounting-and-adapters", chunk: newChunk() }, { call: flaky });
    expect(calls).toBe(2);
    expect(out.action).toBe("skipped");
  });
});

// ---- ACCEPTANCE 3 — idempotency via synthesized_chunk_sections PK ----------

describe("patch — synthesizePatch effectful write + PK idempotency", () => {
  async function seedVault(): Promise<{ root: string; store: MemoryStore; conv: string; id: string }> {
    const root = await mkdtemp(join(tmpdir(), "dreaming-patch-"));
    await mkdir(join(root, "articles"), { recursive: true });
    await writeFile(join(root, "articles", "Test_Camera.md"), ARTICLE);

    const store = new MemoryStore(":memory:");
    const conv = "33334444-0000-0000-0000-000000000000";
    store.db.run("INSERT INTO conversations (conv, source, title, updated_at, chunked_at) VALUES (?,?,?,?,?)", [
      conv,
      "pi-terminal",
      "Adapter Load Centering",
      1735689600000,
      null,
    ]);
    const msgs = [
      "How do I mount a heavy adapter without stressing the mount?",
      "Attach the clamp foot to a tripod plate so the load sits under the lens.",
      "So the camera mount only carries the body weight then.",
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
    const id = chunkId(conv, 0, 2);
    store.db.run("INSERT INTO chunks (id, conv, start, end, label) VALUES (?,?,?,?,?)", [id, conv, 0, 2, "adapter load centering"]);
    return { root, store, conv, id };
  }

  it("writes the patched article + ledger row, then a second fold is a NO-OP", async () => {
    const { root, store, id } = await seedVault();
    let calls = 0;
    const countingCall: SynthesisCall = async (prompt) => {
      calls++;
      const m = /placing the marker \[\^(\d+)\]/.exec(prompt);
      return `Heavy adapters put torque on the mount; relieving it at the lens clamp helps. Centering the clamp foot on a tripod plate puts the load under the lens.${m ? `[^${m[1]}]` : ""}`;
    };

    const first = await synthesizePatch(store, {
      stem: "Test_Camera",
      anchor: "mounting-and-adapters",
      chunkId: id,
      root,
      call: countingCall,
      commit: false,
    });
    expect(first.patched).toBe(true);
    expect(first.footnote).toBe(2);
    expect(calls).toBeGreaterThanOrEqual(1);

    const afterFirst = await readFile(join(root, "articles", "Test_Camera.md"), "utf8");
    expect(afterFirst).toContain("[^2]: `conv:33334444`");
    const ledger = store.db
      .query("SELECT chunk_id, article_stem, section_anchor FROM synthesized_chunk_sections")
      .all() as { chunk_id: string; article_stem: string; section_anchor: string }[];
    expect(ledger.length).toBe(1);
    expect(ledger[0]).toEqual({ chunk_id: id, article_stem: "Test_Camera", section_anchor: "mounting-and-adapters" });

    // Second fold: the PK short-circuits BEFORE the model — no new call, no write.
    const callsBefore = calls;
    const second = await synthesizePatch(store, {
      stem: "Test_Camera",
      anchor: "mounting-and-adapters",
      chunkId: id,
      root,
      call: countingCall,
      commit: false,
    });
    expect(second.patched).toBe(false);
    expect(second.alreadyIntegrated).toBe(true);
    expect(calls).toBe(callsBefore); // model NOT called the second time
    const afterSecond = await readFile(join(root, "articles", "Test_Camera.md"), "utf8");
    expect(afterSecond).toBe(afterFirst); // byte-identical, nothing re-written
    store.close();
  });

  it("a gated NO-OP writes nothing and records no ledger row", async () => {
    const { root, store, id } = await seedVault();
    const refuse: SynthesisCall = async () => "I cannot complete this request.";
    const res = await synthesizePatch(store, {
      stem: "Test_Camera",
      anchor: "mounting-and-adapters",
      chunkId: id,
      root,
      call: refuse,
      commit: false,
    });
    expect(res.patched).toBe(false);
    expect(res.skippedByGate).toBe(true);
    const unchanged = await readFile(join(root, "articles", "Test_Camera.md"), "utf8");
    expect(unchanged).toBe(ARTICLE);
    const ledger = store.db.query("SELECT COUNT(*) AS n FROM synthesized_chunk_sections").get() as { n: number };
    expect(ledger.n).toBe(0);
    store.close();
  });
});
