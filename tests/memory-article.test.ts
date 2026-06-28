import { describe, expect, it } from "bun:test";
import {
  ENTITY_KINDS,
  articleStructure,
  countFenceLines,
  hasBalancedFences,
  infoboxAliases,
  parseFootnotes,
  parseInfobox,
  parseLead,
  parseSeriesBanner,
  repairFences,
  serializeInfobox,
} from "../src/memory/article";

// A canonically-formatted infobox (the P1-T2 grammar): fenced ```info block of
// `key: value` lines. Hand-written here — no golden-file dependency.
const INFOBOX = [
  "```info",
  "type: Mirrorless camera",
  "mount: [[L-Mount]]",
  "sensor: full-frame 24.2MP",
  "kind: thing",
  "owned: yes",
  "acquired: 2024-12 ($1,645 used)",
  "used_for: video-conference camera; anamorphic",
  "aliases: S5IIX, S5 IIX, Lumix S5IIX, LUMIX S5IIX",
  "```",
].join("\n");

const ARTICLE = [
  "# Panasonic Lumix S5IIX",
  "",
  "*Part of a series on [[Cameras]].*",
  "",
  INFOBOX,
  "",
  "The **S5IIX** is a full-frame mirrorless camera Josh owns.[^1] He uses it on",
  "the [[L-Mount]] system as a video-conference camera.[^2]",
  "",
  "## Use",
  "",
  "Pressed into anamorphic work.[^2]",
  "",
  "## See also",
  "",
  "- [[L-Mount]]",
  "",
  "## References",
  "",
  "[^1]: `conv:00000000` (2024-12-01, gear) — bought the camera used",
  "[^2]: `conv:11111111` (2024-12-02, mounts) — discussed mount and uses",
].join("\n");

describe("parseInfobox / serializeInfobox", () => {
  it("round-trips a hand-written infobox byte-identically", () => {
    const box = parseInfobox(INFOBOX);
    expect(box).not.toBeNull();
    expect(serializeInfobox(box!)).toBe(INFOBOX);
  });

  it("reads type and validates entityKind from the kind: field", () => {
    const box = parseInfobox(INFOBOX)!;
    expect(box.type).toBe("Mirrorless camera");
    expect(box.entityKind).toBe("thing");
    expect(ENTITY_KINDS).toContain(box.entityKind);
  });

  it("defaults entityKind to thing when kind: is absent or invalid", () => {
    expect(parseInfobox("```info\ntype: Lens\n```")!.entityKind).toBe("thing");
    expect(parseInfobox("```info\nkind: gizmo\n```")!.entityKind).toBe("thing");
    expect(parseInfobox("```info\nkind: person\n```")!.entityKind).toBe("person");
  });

  it("returns null when there is no infobox", () => {
    expect(parseInfobox("# Title\n\nProse only.")).toBeNull();
  });

  it("extracts the declared aliases: list exactly", () => {
    const box = parseInfobox(INFOBOX)!;
    expect(infoboxAliases(box)).toEqual(["S5IIX", "S5 IIX", "Lumix S5IIX", "LUMIX S5IIX"]);
  });

  it("classifies each value's isEntityLink correctly", () => {
    const box = parseInfobox(INFOBOX)!;
    const byKey = Object.fromEntries(box.fields.map((f) => [f.key, f.isEntityLink]));
    expect(byKey.mount).toBe(true); // [[L-Mount]] names another entity
    expect(byKey.type).toBe(false);
    expect(byKey.sensor).toBe(false);
    expect(byKey.owned).toBe(false);
    expect(byKey.aliases).toBe(false); // a comma list of plain surface forms
  });

  it("classifies field value-types", () => {
    const box = parseInfobox(INFOBOX)!;
    const byKey = Object.fromEntries(box.fields.map((f) => [f.key, f.kind]));
    expect(byKey.mount).toBe("entity-link");
    expect(byKey.used_for).toBe("list");
    expect(byKey.aliases).toBe("list");
    expect(byKey.type).toBe("scalar");
  });
});

describe("parseSeriesBanner / parseLead", () => {
  it("reads the series banner target", () => {
    expect(parseSeriesBanner(ARTICLE)).toBe("Cameras");
    expect(parseSeriesBanner("# Title\n\nNo banner.")).toBeNull();
  });

  it("extracts the lead, skipping the banner and infobox", () => {
    const lead = parseLead(ARTICLE);
    expect(lead).not.toBeNull();
    expect(lead!.startsWith("The **S5IIX** is a full-frame mirrorless camera")).toBe(true);
    expect(lead!).not.toContain("Part of a series");
    expect(lead!).not.toContain("```");
  });
});

describe("articleStructure", () => {
  it("returns the ordered skeleton with line ranges", () => {
    const kinds = articleStructure(ARTICLE).map((i) => i.kind);
    expect(kinds).toEqual(["h1", "series", "infobox", "lead", "section", "see-also", "references"]);
  });

  it("does not treat headings inside the infobox-adjacent fence as sections", () => {
    const md = "# T\n\n```info\ntype: x\n```\n\n## Real Section\n\nbody";
    const items = articleStructure(md);
    expect(items.filter((i) => i.kind === "section").length).toBe(1);
    const infobox = items.find((i) => i.kind === "infobox")!;
    expect(infobox.startLine).toBeLessThan(infobox.endLine);
  });
});

describe("parseFootnotes", () => {
  it("yields a bijection of markers and defs on a well-formed article", () => {
    const { markers, defs } = parseFootnotes(ARTICLE);
    const markerIds = new Set(markers.map((m) => m.id));
    const defIds = new Set(defs.map((d) => d.id));
    expect([...markerIds].sort()).toEqual(["1", "2"]);
    expect([...defIds].sort()).toEqual(["1", "2"]);
    // every marker has its def and vice versa
    for (const id of markerIds) expect(defIds.has(id)).toBe(true);
    for (const id of defIds) expect(markerIds.has(id)).toBe(true);
  });

  it("does not count a definition line's [^N]: as a marker", () => {
    const { markers } = parseFootnotes("body[^1]\n\n## References\n\n[^1]: `conv:00000000` (2024-01-01, x) — y");
    expect(markers.map((m) => m.id)).toEqual(["1"]);
  });

  it("flags an injected dangling [^9] marker with no definition", () => {
    const dangling = ARTICLE.replace("work.[^2]", "work.[^2] also see[^9]");
    const { markers, defs } = parseFootnotes(dangling);
    const markerIds = new Set(markers.map((m) => m.id));
    const defIds = new Set(defs.map((d) => d.id));
    expect(markerIds.has("9")).toBe(true);
    expect(defIds.has("9")).toBe(false);
    const orphans = [...markerIds].filter((id) => !defIds.has(id));
    expect(orphans).toEqual(["9"]);
  });
});

// ---- fence repair (the unbalanced-``` heal) --------------------------

describe("repairFences", () => {
  it("balanced fences are a byte-identical no-op", () => {
    const a = "# T\n\n```info\nkind: thing\n```\n\nLead.\n\n## References\n\n[^1]: `conv:a1b2c3d4` — x\n";
    expect(hasBalancedFences(a)).toBe(true);
    const r = repairFences(a);
    expect(r.changed).toBe(false);
    expect(r.content).toBe(a);
  });

  it("closes a dangling fence right before the first heading it would swallow", () => {
    // ```python opens and never closes → ## References is read as code.
    const a =
      "# T\n\nLead.\n\n## Code\n\n```python\nprint(1)\n\n## References\n\n[^1]: `conv:a1b2c3d4` — x\n";
    expect(hasBalancedFences(a)).toBe(false);
    const r = repairFences(a);
    expect(r.changed).toBe(true);
    expect(hasBalancedFences(r.content)).toBe(true);
    // The trailing ## References is a recognized heading again.
    const kinds = articleStructure(r.content).map((i) => i.kind);
    expect(kinds).toContain("references");
    // The python code body is preserved inside the now-closed block.
    expect(r.content).toContain("print(1)");
    // Idempotent.
    expect(repairFences(r.content).changed).toBe(false);
  });

  it("strips a spurious stray fence with no content under it", () => {
    const a = "# T\n\nLead.\n\n```\n\n## References\n\n[^1]: `conv:a1b2c3d4` — x\n";
    const r = repairFences(a);
    expect(r.changed).toBe(true);
    expect(hasBalancedFences(r.content)).toBe(true);
    expect(countFenceLines(r.content)).toBe(0);
    expect(articleStructure(r.content).map((i) => i.kind)).toContain("references");
  });

  it("closes a dangling fence at EOF when no heading follows", () => {
    const a = "# T\n\nLead.\n\n```js\nconst x = 1;\n";
    const r = repairFences(a);
    expect(r.changed).toBe(true);
    expect(hasBalancedFences(r.content)).toBe(true);
    expect(r.content).toContain("const x = 1;");
    expect(repairFences(r.content).changed).toBe(false);
  });
});
