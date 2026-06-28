// The Dreaming — DATE-AWARE synthesis + PROVENANCE-PRESERVING resolve.
//
// Two self-healing-correctness invariants, both reachable WITHOUT the GPU:
//   (A) every synthesis prompt that resolves a conflict carries each claim's DATE
//       (the same date in its [^N] footnote), so a contradiction resolves toward
//       the LATER-DATED statement explicitly, not merely by processing order.
//   (B) a PATCH that corrects an earlier claim KEEPS the superseded citation
//       alongside the new one — so provenance survives, the latest wins, AND the
//       gate's citation-survival check passes instead of NO-OP'ing the fold.

import { describe, expect, it } from "bun:test";

import { checkFootnoteIntegrity, extractConvHashes } from "../src/memory/gate";
import { extractSection } from "../src/memory/vault";
import { LEAD_ANCHOR } from "../src/memory/cluster";
import {
  buildLeadPatchPrompt,
  buildPatchPrompt,
  createArticle,
  footnoteDate,
  patchSection,
  type SynthesisCall,
  type SynthesisChunk,
} from "../src/memory/synthesize";

const D2023 = 1672531200000; // 2023-01-01
const D2025 = 1735689600000; // 2025-01-01

// ---- A. date label in the CREATE prompts -----------------------------------

describe("date-aware — CREATE labels each source chunk with its date", () => {
  it("threads [YYYY-MM-DD] + the later-dated-wins rule into the lead/section prompts", async () => {
    const chunks: SynthesisChunk[] = [
      {
        id: "aaaa1111-0000-0000-0000-000000000000:0-1",
        conv: "aaaa1111-0000-0000-0000-000000000000",
        label: "early take",
        text: "Back then my favorite focal length was 35mm.",
        title: "Early take",
        dateMs: D2023,
      },
      {
        id: "bbbb2222-0000-0000-0000-000000000000:0-1",
        conv: "bbbb2222-0000-0000-0000-000000000000",
        label: "current take",
        text: "These days 50mm is my favorite focal length, the one I reach for.",
        title: "Current take",
        dateMs: D2025,
      },
    ];

    const prompts: string[] = [];
    const call: SynthesisCall = async (prompt) => {
      prompts.push(prompt);
      if (prompt.includes("Propose a clean table of contents")) return "Favorite Focal Length";
      if (prompt.includes("Write the LEAD"))
        return "**Focal Length Preference** is the user's preference, currently 50mm.[^2]";
      if (prompt.includes("Produce the INFOBOX facts")) return "type: preference\nfavorite_focal_length: 50mm";
      if (prompt.includes("Draft ONLY the body")) {
        const list = prompt.split("Cite sources")[1] ?? "";
        const m = /\[\^(\d+)\]/.exec(list);
        return `The user originally favored 35mm, but now favors 50mm.${m ? `[^${m[1]}]` : ""}`;
      }
      return "";
    };

    await createArticle("Focal Length Preference", "thing", chunks, { call });

    // The LEAD prompt carries BOTH dates as labels + the later-dated-wins rule.
    const leadPrompt = prompts.find((p) => p.includes("Write the LEAD"))!;
    expect(leadPrompt).toContain(`[${footnoteDate(D2023)}]`);
    expect(leadPrompt).toContain(`[${footnoteDate(D2025)}]`);
    expect(leadPrompt).toContain("LATER-DATED");

    // The SECTION draft prompt is date-tagged per source too.
    const sectionPrompt = prompts.find((p) => p.includes("Draft ONLY the body"))!;
    expect(sectionPrompt).toContain(`[${footnoteDate(D2025)}]`);
  });
});

// ---- A. date label in the PATCH prompt -------------------------------------

describe("date-aware — PATCH prompt carries the integrating chunk's date", () => {
  it("includes the chunk date + the prior claim's date + the keep-both correction rule", () => {
    const chunk: SynthesisChunk = {
      id: "bbbb2222-0000-0000-0000-000000000000:0-1",
      conv: "bbbb2222-0000-0000-0000-000000000000",
      label: "current take",
      text: "50mm is my favorite now.",
      title: "Current take",
      dateMs: D2025,
    };
    const prompt = buildPatchPrompt(
      "Focal Length Preference",
      "Favorite Focal Length",
      "The user's favorite is 35mm.[^1]",
      chunk,
      2,
      "(none yet)",
      "",
      [footnoteDate(D2023)],
    );
    expect(prompt).toContain(`(${footnoteDate(D2025)})`); // the new note's date
    expect(prompt).toContain(footnoteDate(D2023)); // the contradicted claim's date
    expect(prompt).toContain("LATER-DATED");
    // The provenance-preserving instruction: keep [^k] alongside the new [^2].
    expect(prompt).toContain("existing [^k] citation marker");
    // The sharpened demotion instruction: superseded clause goes to past tense.
    expect(prompt).toContain("DEMOTE the superseded claim to the PAST TENSE");
    expect(prompt).toContain("[^2]");
  });
});

// ---- B. provenance-preserving resolve passes the gate ----------------------

const ARTICLE = `# Focal Length Preference

\`\`\`info
type: preference
kind: thing
\`\`\`

**Focal Length Preference** is the user's lens preference.

## Favorite Focal Length

The user's favorite focal length is 35mm, the one they reach for.[^1]

## References

[^1]: \`conv:aaaa1111\` (2023-01-01, Early take)
`;

function correctionChunk(): SynthesisChunk {
  return {
    id: "bbbb2222-0000-0000-0000-000000000000:0-1",
    conv: "bbbb2222-0000-0000-0000-000000000000",
    label: "current take",
    text: "50mm is my favorite focal length now.",
    title: "Current take",
    dateMs: D2025,
  };
}

describe("provenance-preserving resolve — keep both citations, gate passes", () => {
  it("a resolve fold that keeps [^1] AND adds [^2] patches (not NO-OP), both convs survive", async () => {
    const keepBoth: SynthesisCall = async (prompt) => {
      const m = /placing the marker \[\^(\d+)\]/.exec(prompt);
      const nn = m ? m[1] : "2";
      return `The user originally favored 35mm[^1]; as of 2025 their pick is 50mm[^${nn}].`;
    };
    const out = await patchSection(
      { article: ARTICLE, anchor: "favorite-focal-length", chunk: correctionChunk() },
      { call: keepBoth },
    );

    expect(out.action).toBe("patched");
    expect(out.footnote).toBe(2);
    const after = out.content!;
    const target = extractSection(after, "favorite-focal-length")!;
    expect(target).toContain("[^1]"); // superseded citation survived
    expect(target).toContain("[^2]"); // the correction's citation added
    expect(target).toContain("50mm");
    // Both conversations are still cited; the gate did NOT drop the old one.
    const hashes = extractConvHashes(after);
    expect(hashes.has("aaaa1111")).toBe(true);
    expect(hashes.has("bbbb2222")).toBe(true);
    expect(checkFootnoteIntegrity(after).ok).toBe(true);
  });

  it("classified LEAD correction — EVOLUTION keeps current-state + provenance; ERROR drops the wrong cite", () => {
    const chunk = correctionChunk();
    const evo = buildLeadPatchPrompt("X", "current[^1]", chunk, 2, "(none)", "", [], "evolution");
    expect(evo).toContain("the user's view evolved");
    expect(evo).toContain("PRESENT TENSE");
    expect(evo).toContain('do NOT scatter "previously'); // clean current-state lead
    const err = buildLeadPatchPrompt("X", "current[^1]", chunk, 2, "(none)", "", [], "error");
    expect(err).toContain("factual error");
    expect(err).toContain("MAY drop the wrong value's [^k]");
  });
});

// A LEAD that already cites a prior claim: the new note contradicts it, so patchLead
// CLASSIFIES the contradiction before resolving the lead.
const LEAD_CITED = `# Coffee Order

\`\`\`info
type: preference
kind: thing
\`\`\`

**Coffee Order** is the user's usual cafe order, currently a flat white.[^1]

## References

[^1]: \`conv:aaaa1111\` (2024-01-01, Early order)
`;

function orderChunk(): SynthesisChunk {
  return {
    id: "bbbb2222-0000-0000-0000-000000000000:0-1",
    conv: "bbbb2222-0000-0000-0000-000000000000",
    label: "new order",
    text: "My usual order is a cortado now.",
    title: "New order",
    dateMs: D2025,
  };
}

describe("classified LEAD resolve — evolution preserves provenance, error overwrites silently", () => {
  it("EVOLUTION: resolves the lead to current-state and KEEPS both citations (history kept by reconcile)", async () => {
    const evoCall: SynthesisCall = async (prompt) => {
      if (prompt.includes("EARLIER value")) return "EVOLUTION"; // the classifier
      const m = /\[\^(\d+)\] immediately after/.exec(prompt);
      const marker = m ? `[^${m[1]}]` : "";
      return `**Coffee Order** is the user's usual cafe order, currently a cortado.[^1]${marker}`;
    };
    const out = await patchSection({ article: LEAD_CITED, anchor: LEAD_ANCHOR, chunk: orderChunk() }, { call: evoCall });

    expect(out.action).toBe("patched");
    const after = out.content!;
    // Both the earlier and the later source survive (provenance kept for History).
    const hashes = extractConvHashes(after);
    expect(hashes.has("aaaa1111")).toBe(true);
    expect(hashes.has("bbbb2222")).toBe(true);
    expect(checkFootnoteIntegrity(after).ok).toBe(true);
  });

  it("ERROR: silently overwrites — the wrong value's citation is pruned, gate does NOT veto", async () => {
    const errCall: SynthesisCall = async (prompt) => {
      if (prompt.includes("EARLIER value")) return "ERROR"; // the classifier
      const m = /\[\^(\d+)\] immediately after/.exec(prompt);
      const marker = m ? `[^${m[1]}]` : "";
      return `**Coffee Order** is the user's usual cafe order, a cortado.${marker}`;
    };
    const out = await patchSection({ article: LEAD_CITED, anchor: LEAD_ANCHOR, chunk: orderChunk() }, { call: errCall });

    expect(out.action).toBe("patched"); // NOT NO-OP'd despite the dropped citation
    const after = out.content!;
    const hashes = extractConvHashes(after);
    expect(hashes.has("aaaa1111")).toBe(false); // the wrong value's cite pruned
    expect(hashes.has("bbbb2222")).toBe(true); // the correct value cited
    expect(checkFootnoteIntegrity(after).ok).toBe(true);
  });

  it("contrast — a fold that DROPS the old [^1] is NO-OP'd by the gate (citation loss)", async () => {
    const dropOld: SynthesisCall = async (prompt) => {
      const m = /placing the marker \[\^(\d+)\]/.exec(prompt);
      return `The user's favorite focal length is now 50mm[^${m ? m[1] : "2"}].`;
    };
    const out = await patchSection(
      { article: ARTICLE, anchor: "favorite-focal-length", chunk: correctionChunk() },
      { call: dropOld },
    );
    expect(out.action).toBe("skipped");
    expect(out.content).toBeNull();
    expect(out.reason).toContain("dropped citation conv:aaaa1111");
  });
});
