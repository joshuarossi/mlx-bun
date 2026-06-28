// P8-T1 / P8-T2 bounded GPU acceptance — one model load, commit into the smoke
// vault. Runs the LLM wikify sweep (per-section tighten + infobox refresh) on a
// real synthesized article, demonstrates that a deliberately-weak edit is
// rejected (original kept), and confirms the declared aliases feed back into
// `entity_aliases` on reindex.
//
// Usage: bun scripts/memory/wikify-smoke.ts [stem]
//   defaults to Panasonic_Lumix_S5IIX in ~/.mlx-bun/wiki-smoke.

import { mkdtemp, readFile } from "node:fs/promises";
import { tmpdir } from "node:os";
import { join } from "node:path";

import { parseInfobox, infoboxAliases } from "../../src/memory/article";
import { MemoryStore } from "../../src/memory/db";
import { callLocal } from "../../src/memory/model";
import { reindex } from "../../src/memory/reindex";
import { countFencedInfoBlocks } from "../../src/memory/synthesize";
import { articlesDir } from "../../src/memory/vault";
import { improveSections, wikifyArticle } from "../../src/memory/wikify";

const ROOT = `${process.env.HOME}/.mlx-bun/wiki-smoke`;
const STEM = process.argv[2] ?? "Panasonic_Lumix_S5IIX";

/** The real editor stage (single cached load for the whole script). */
const realCall = (p: string, o?: { maxTokens?: number }) => callLocal("editor", { user: p }, o);

/** A deliberately-weak editor: every tighten request returns a meta/reasoning
 *  leak, which `isLeakyDraft` rejects — so every section keeps its original
 *  bytes. Demonstrates "weak edit → NO-OP" on the real article (no extra GPU). */
const weakLeakCall = async (p: string, _o?: { maxTokens?: number }): Promise<string> =>
  p.includes("tightening ONE section")
    ? "I will now summarize the source material and draft the body prose for this section."
    : "NONE";

async function main(): Promise<void> {
  const path = join(articlesDir(ROOT), `${STEM}.md`);
  const before = await readFile(path, "utf8");
  console.log(`# wikify-smoke ${STEM} (${before.length} bytes, ${countFencedInfoBlocks(before)} infobox)`);

  // 1) Real wikify pass (per-section tighten + infobox refresh), commit into vault.
  const r = await wikifyArticle({ stem: STEM, root: ROOT, call: realCall, commit: true });
  console.log(
    `wikify: status=${r.status} sectionsImproved=${r.sectionsImproved} ` +
      `weakEditRejected=${r.weakEditRejected} infoboxRefreshed=${r.infoboxRefreshed}` +
      (r.reason ? ` reason="${r.reason}"` : ""),
  );

  const after = await readFile(path, "utf8");
  const box = parseInfobox(after);
  const mount = box?.fields.find((f) => f.key === "mount");
  console.log(`infobox: blocks=${countFencedInfoBlocks(after)} mount=${mount ? mount.value : "(none)"}`);
  console.log(`aliases declared: ${box ? infoboxAliases(box).join(" | ") : "(none)"}`);

  // 2) Deliberately weak edit (meta/reasoning leak) — every section rejected,
  //    original bytes kept.
  const weak = await improveSections(after, { call: weakLeakCall });
  const keptOriginal = weak.content === after;
  console.log(
    `deliberate-weak: improved=${weak.improved.length} rejected=${weak.rejected.length} ` +
      `originalKept=${keptOriginal}`,
  );

  // 3) Aliases feed back into entity_aliases on reindex.
  const dbPath = join(await mkdtemp(join(tmpdir(), "wikify-reindex-")), "memory.sqlite");
  const store = new MemoryStore(dbPath);
  reindex(store, ROOT);
  const rows = store.db
    .query("SELECT alias FROM entity_aliases WHERE entity_name = ?")
    .all(STEM) as { alias: string }[];
  store.db.close();
  const declared = box ? infoboxAliases(box).map((a) => a.toLowerCase().replace(/\s+/g, " ").trim()) : [];
  const fedBack = rows.map((x) => x.alias).filter((a) => declared.includes(a));
  console.log(`aliasesFedBack: ${fedBack.length} of ${declared.length} declared (${fedBack.join(" | ")})`);

  console.log(
    `\nMETRICS ${JSON.stringify({
      sectionsImproved: r.sectionsImproved,
      weakEditRejected: weak.rejected.length,
      infoboxRefreshed: r.infoboxRefreshed,
      mountLink: mount?.value ?? null,
      aliasesFedBack: fedBack.length,
    })}`,
  );
}

await main();
