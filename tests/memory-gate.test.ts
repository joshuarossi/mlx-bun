import { describe, expect, it } from "bun:test";
import {
  checkFootnoteIntegrity,
  extractConvHashes,
  gateEdit,
} from "../src/memory/gate";

// ---- extractConvHashes ------------------------------------------------

describe("extractConvHashes", () => {
  it("returns the lowercased set, excluding spec placeholders", () => {
    const text =
      "claim one.[^1] claim two.[^2]\n\n" +
      "[^1]: `conv:a1b2c3d4` — Title\n" +
      "[^2]: `conv:DEADBEEF` — Other\n" +
      "[^3]: `conv:00000000` — placeholder that must be ignored\n";
    expect([...extractConvHashes(text)].sort()).toEqual(["a1b2c3d4", "deadbeef"]);
  });

  it("returns an empty set when there are no citations", () => {
    expect(extractConvHashes("# Title\n\nNo citations here.").size).toBe(0);
  });
});

// ---- checkFootnoteIntegrity (the bijection) ---------------------------

describe("checkFootnoteIntegrity", () => {
  it("passes a well-formed article", () => {
    const ok =
      "a.[^1] b.[^2]\n\n## References\n\n" +
      "[^1]: `conv:a1b2c3d4` — One\n" +
      "[^2]: `conv:deadbeef` — Two\n";
    expect(checkFootnoteIntegrity(ok)).toEqual({ ok: true, errors: [] });
  });

  it("flags a marker with no definition", () => {
    const bad = "a.[^1] b.[^2]\n\n[^1]: `conv:a1b2c3d4` — One\n";
    const r = checkFootnoteIntegrity(bad);
    expect(r.ok).toBe(false);
    expect(r.errors.join(" ")).toContain("marker [^2] has no definition");
  });

  it("flags a definition with no marker", () => {
    const bad =
      "a.[^1]\n\n[^1]: `conv:a1b2c3d4` — One\n[^2]: `conv:deadbeef` — Two\n";
    const r = checkFootnoteIntegrity(bad);
    expect(r.ok).toBe(false);
    expect(r.errors.join(" ")).toContain("definition [^2] has no marker");
  });

  it("counts a body marker glued to a colon as a marker, not a definition", () => {
    // Regression: `...types[^2]:` introducing a list is a body marker. Only a
    // line-start `[^N]:` is a definition.
    const ok =
      "a.[^1] He found two types[^2]:\n\n- one\n- two\n\n" +
      "## References\n\n" +
      "[^1]: `conv:a1b2c3d4` — One\n" +
      "[^2]: `conv:deadbeef` — Two\n";
    expect(checkFootnoteIntegrity(ok)).toEqual({ ok: true, errors: [] });
  });

  it("flags non-contiguous numbering", () => {
    const bad = "a.[^1] b.[^3]\n\n[^1]: `conv:a1b2c3d4`\n[^3]: `conv:deadbeef`\n";
    const r = checkFootnoteIntegrity(bad);
    expect(r.ok).toBe(false);
    expect(r.errors.join(" ")).toContain("not contiguous");
  });

  it("flags a definition missing a backticked conv:HASH", () => {
    const bad = "a.[^1]\n\n[^1]: conv:a1b2c3d4 — no backticks\n";
    const r = checkFootnoteIntegrity(bad);
    expect(r.ok).toBe(false);
    expect(r.errors.join(" ")).toContain("[^1] definition lacks a backticked");
  });

  it("flags a duplicated definition (every [^N] maps to ONE [^N]:)", () => {
    const bad =
      "a.[^1]\n\n[^1]: `conv:a1b2c3d4` — One\n[^1]: `conv:deadbeef` — Dup\n";
    const r = checkFootnoteIntegrity(bad);
    expect(r.ok).toBe(false);
    expect(r.errors.join(" ")).toContain("definition [^1] is duplicated");
  });
});

// ---- the gate ---------------------------------------------------------

const BEFORE =
  "# Topic\n\nLead.\n\n## Body\n\nClaim a.[^1] Claim b.[^2]\n\n" +
  "## References\n\n[^1]: `conv:a1b2c3d4` — One\n[^2]: `conv:deadbeef` — Two\n";

describe("gateEdit", () => {
  it("passes a faithful restructure", () => {
    const after =
      "# Topic\n\nA rebuilt two-paragraph lead previewing the body.\n\n" +
      "## Body\n\nClaim b and claim a, consolidated.[^1][^2]\n\n" +
      "## References\n\n[^1]: `conv:a1b2c3d4` — One\n[^2]: `conv:deadbeef` — Two\n";
    expect(gateEdit(BEFORE, after)).toEqual({ ok: true, reason: null });
  });

  it("rejects a dropped citation — a weak pass is a NO-OP", () => {
    const after =
      "# Topic\n\nLead.\n\n## Body\n\nClaim a only.[^1]\n\n" +
      "## References\n\n[^1]: `conv:a1b2c3d4` — One\n";
    const r = gateEdit(BEFORE, after);
    expect(r.ok).toBe(false);
    expect(r.reason).toContain("dropped citation");
    expect(r.reason).toContain("deadbeef");
  });

  it("rejects falling below the word floor", () => {
    const after =
      "# Topic\n\n## References\n\n" +
      "[^1]: `conv:a1b2c3d4`\n[^2]: `conv:deadbeef`\n"; // far too short
    const r = gateEdit(BEFORE, after);
    expect(r.ok).toBe(false);
    expect(r.reason).toContain("word count");
  });

  it("enforces footnote bijection on the edited text", () => {
    // Body still cites [^2] but its definition was dropped — a broken bijection.
    const after =
      "# Topic\n\nLead, lightly rephrased but kept whole.\n\n" +
      "## Body\n\nClaim a.[^1] Claim b.[^2]\n\n" +
      "## References\n\n[^1]: `conv:a1b2c3d4` — One\n";
    const r = gateEdit(BEFORE, after);
    expect(r.ok).toBe(false);
    expect(r.reason).toContain("marker [^2] has no definition");
  });

  it("rejects a dropped ## References section", () => {
    const after = "# Topic\n\nLead.\n\n## Body\n\nClaim a.[^1] Claim b.[^2]\n";
    const r = gateEdit(BEFORE, after);
    expect(r.ok).toBe(false);
    expect(r.reason).toContain("References");
  });

  it("rejects a dropped H1 title", () => {
    const after =
      "Lead with no title, otherwise faithful and long enough.\n\n" +
      "## Body\n\nClaim a.[^1] Claim b.[^2]\n\n" +
      "## References\n\n[^1]: `conv:a1b2c3d4` — One\n[^2]: `conv:deadbeef` — Two\n";
    const r = gateEdit(BEFORE, after);
    expect(r.ok).toBe(false);
    expect(r.reason).toContain("H1 title");
  });

  it("honors a custom floor", () => {
    // `after` is ~half the words of `before`; passes at floor 0.4, fails at 0.7.
    const before = "# T\n\n" + "word ".repeat(20).trim() + "\n\n## References\n";
    const after = "# T\n\n" + "word ".repeat(9).trim() + "\n\n## References\n";
    expect(gateEdit(before, after, { floor: 0.4 }).ok).toBe(true);
    expect(gateEdit(before, after, { floor: 0.7 }).ok).toBe(false);
  });
});

// ---- See-also singularity guard --------------------------------------

describe("gateEdit rejects more than one ## See also", () => {
  it("vetoes an edit whose result carries two ## See also headings", () => {
    const before = "# T\n\nLead.[^1]\n\n## See also\n\n- [[A]]\n\n## References\n\n[^1]: `conv:a1b2c3d4` — x\n";
    const after =
      "# T\n\nLead.[^1]\n\n## See also\n\n- [[A]]\n\n## See also\n\n- [[A]]\n\n## References\n\n[^1]: `conv:a1b2c3d4` — x\n";
    const v = gateEdit(before, after);
    expect(v.ok).toBe(false);
    expect(v.reason).toContain("multiple ## See also");
  });

  it("accepts an edit with exactly one ## See also", () => {
    const before = "# T\n\nLead.[^1]\n\n## See also\n\n- [[A]]\n\n## References\n\n[^1]: `conv:a1b2c3d4` — x\n";
    const after = "# T\n\nLead.[^1]\n\n## See also\n\n- [[A]]\n- [[B]]\n\n## References\n\n[^1]: `conv:a1b2c3d4` — x\n";
    expect(gateEdit(before, after).ok).toBe(true);
  });
});
