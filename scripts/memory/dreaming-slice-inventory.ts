// One-off: reindex the slice vault and report the article inventory for the
// Dreaming E2E slice — stem, kind, infobox presence, citation count — so we can
// judge gear vs pattern-shaped coverage (the reviewer's #1 concern).

import { readFileSync, readdirSync } from "node:fs";
import { join } from "node:path";
import { parseInfobox } from "../../src/memory/article";
import { MemoryStore } from "../../src/memory/db";
import { reindex } from "../../src/memory/reindex";
import { articlesDir } from "../../src/memory/vault";

const vault = process.env.MLX_BUN_WIKI ?? "/Users/joshrossi/.mlx-bun/wiki-slice";

const store = new MemoryStore();
const idx = reindex(store, vault);
console.log("reindex:", JSON.stringify(idx));

const dir = articlesDir(vault);
let stems: string[] = [];
try {
  stems = readdirSync(dir).filter((n) => n.endsWith(".md") && !n.startsWith(".")).map((n) => n.slice(0, -3)).sort();
} catch {
  stems = [];
}

interface Row {
  stem: string;
  kind: string;
  type: string;
  hasInfobox: boolean;
  citations: number;
  bodyWords: number;
  stub: boolean;
}

const rows: Row[] = [];
for (const stem of stems) {
  const md = readFileSync(join(dir, `${stem}.md`), "utf8");
  const box = parseInfobox(md);
  // citations = distinct [^N]: definition lines (the References block).
  const defs = new Set<string>();
  for (const m of md.matchAll(/^\[\^([0-9A-Za-z]+)\]:/gm)) defs.add(m[1]!);
  const typeField = box?.fields.find((f) => f.key === "type")?.value ?? "";
  const bodyWords = md.replace(/```[\s\S]*?```/g, "").split(/\s+/).filter(Boolean).length;
  rows.push({
    stem,
    kind: box?.entityKind ?? "thing",
    type: typeField,
    hasInfobox: box != null,
    citations: defs.size,
    bodyWords,
    stub: /\{\{stub\}\}/.test(md),
  });
}

console.log(`\n=== ${rows.length} articles ===`);
for (const r of rows) {
  console.log(
    `${r.hasInfobox ? "I" : "-"}${r.stub ? "s" : " "} cites=${String(r.citations).padStart(2)} kind=${r.kind.padEnd(9)} type=${(r.type || "—").slice(0, 22).padEnd(22)} ${r.stem}`,
  );
}

await Bun.write(
  process.env.INV_OUT ?? "/tmp/dreaming-slice-inventory.json",
  JSON.stringify({ vault, reindex: idx, articles: rows }, null, 2),
);
store.close();
