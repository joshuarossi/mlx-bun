// P6-T3 acceptance smoke — CREATE one real owned-thing article on the base model.
//
// Finds a SMALL set of real ingested chunks about ONE owned thing (the Panasonic
// Lumix S5IIX camera), copies just those rows out of the production memory store
// into an in-memory store (so NOTHING is written to ~/.cache/mlx-bun/memory.sqlite
// — the synthesized_chunk_sections ledger lands in the throwaway store), and runs
// the CREATE flow into a DEDICATED smoke vault at ~/.mlx-bun/wiki-smoke. The real
// ~/.mlx-bun/wiki is never touched.
//
// ONE base-model load (synthesis stage, no adapter). Run:
//   bun scripts/experiments/dreaming-create-smoke.ts
//
// Acceptance (P6-T3): a stub-or-better article with a parseable infobox and ≥1
// cited section, passing gate + NORMALIZE, committed to the smoke vault.

import { Database } from "bun:sqlite";
import { homedir } from "node:os";
import { join } from "node:path";

const SMOKE_VAULT = join(homedir(), ".mlx-bun", "wiki-smoke");
process.env.MLX_BUN_WIKI = SMOKE_VAULT; // BEFORE importing vault-aware modules

const { MemoryStore, DEFAULT_MEMORY_DB } = await import("../../src/memory/db");
const { setupVault } = await import("../../src/memory/vault");
const { synthesizeCreate } = await import("../../src/memory/synthesize");
const { parseInfobox } = await import("../../src/memory/article");
const { loadDreamingGold, goldSeeds } = await import("../../src/memory/resolve");

// The owned thing + a small set of real chunks that route to it (S5IIX
// ownership: in-the-box, accessories, the buy decision, vintage pairing).
const ENTITY = "Panasonic Lumix S5IIX";
const CHUNK_IDS = [
  "67406000-7308-8013-a892-272d0a37eb0a:0-1", // battery included in box
  "67406000-7308-8013-a892-272d0a37eb0a:2-9", // memory cards / codecs
  "67406000-7308-8013-a892-272d0a37eb0a:18-19", // hot shoe mount + accessories
  "67406000-7308-8013-a892-272d0a37eb0a:24-25", // USB-C ports
  "f7663669-a689-4344-8f06-fe26f6630a17:91-95", // final S5II vs S5IIx buy decision
  "67030293-c6a0-8013-ad9a-51d5b42a7beb:4-10", // pairing Helios with the S5IIX
];

function copyChunks(src: Database, dst: InstanceType<typeof MemoryStore>): void {
  const ins = dst.db;
  const seenConv = new Set<string>();
  for (const id of CHUNK_IDS) {
    const ch = src.query("SELECT id, conv, start, end, label FROM chunks WHERE id = ?").get(id) as
      | { id: string; conv: string; start: number; end: number; label: string | null }
      | null;
    if (!ch) {
      console.warn(`  ! chunk not found in production store: ${id}`);
      continue;
    }
    if (!seenConv.has(ch.conv)) {
      seenConv.add(ch.conv);
      const conv = src.query("SELECT conv, source, title, updated_at, chunked_at FROM conversations WHERE conv = ?").get(ch.conv) as any;
      ins.run("INSERT OR IGNORE INTO conversations (conv, source, title, updated_at, chunked_at) VALUES (?,?,?,?,?)", [
        conv.conv, conv.source, conv.title, conv.updated_at, conv.chunked_at,
      ]);
      const msgs = src.query("SELECT conv, position, role, uuid, text FROM messages WHERE conv = ? AND position BETWEEN ? AND ? ORDER BY position").all(ch.conv, ch.start, ch.end) as any[];
      for (const m of msgs) {
        ins.run("INSERT OR IGNORE INTO messages (conv, position, role, uuid, text) VALUES (?,?,?,?,?)", [
          m.conv, m.position, m.role, m.uuid, m.text,
        ]);
      }
    }
    ins.run("INSERT OR IGNORE INTO chunks (id, conv, start, end, label) VALUES (?,?,?,?,?)", [
      ch.id, ch.conv, ch.start, ch.end, ch.label,
    ]);
  }
}

async function main() {
  console.log(`smoke vault: ${SMOKE_VAULT}`);
  await setupVault(SMOKE_VAULT); // seed Meta pages + git so policy inlines + commit works

  const prod = new Database(DEFAULT_MEMORY_DB, { readonly: true });
  const store = new MemoryStore(":memory:");
  copyChunks(prod, store);
  prod.close();
  const have = store.db.query("SELECT COUNT(*) c FROM chunks").get() as { c: number };
  console.log(`copied ${have.c}/${CHUNK_IDS.length} chunks into the throwaway store`);

  // Aliases from the curated gold so the infobox `aliases:` line seeds.
  const seed = goldSeeds(loadDreamingGold()).find((s) => s.canonical === ENTITY);

  console.log(`drafting ${ENTITY} on the base model (one load)…`);
  const t0 = Date.now();
  const res = await synthesizeCreate(store, {
    entity: ENTITY,
    kind: "thing",
    chunkIds: CHUNK_IDS,
    root: SMOKE_VAULT,
    aliases: seed?.aliases ?? [],
  });
  console.log(`done in ${((Date.now() - t0) / 1000).toFixed(1)}s`);

  const stem = ENTITY.replace(/\s+/g, "_");
  const path = join(SMOKE_VAULT, "articles", `${stem}.md`);
  let content = "";
  try {
    content = await Bun.file(path).text();
  } catch {
    /* not written */
  }

  const box = content ? parseInfobox(content) : null;
  const hasMount = /mount:\s*\[\[/.test(content);

  console.log("\n================ ARTICLE ================\n");
  console.log(content || "(no article written)");
  console.log("\n========================================\n");

  const metrics = {
    articleCreated: res.created,
    hasInfobox: box != null,
    citedSections: res.citedSections,
    gatePassed: !res.skippedByGate,
    hasMount,
    reason: res.reason,
  };
  console.log("metrics:", JSON.stringify(metrics, null, 2));

  const pass = res.created && box != null && res.citedSections >= 1 && !res.skippedByGate;
  store.close();
  if (!pass) {
    console.error("\nACCEPTANCE FAILED");
    process.exit(1);
  }
  console.log("\nACCEPTANCE MET");
}

await main();
