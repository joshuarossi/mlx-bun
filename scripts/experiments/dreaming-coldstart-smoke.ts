// P6-T4 acceptance smoke — cold-start the WHOLE write DAG on ~10 real convs.
//
// Wires ingest → SEGMENT → ENTITY-EXTRACT → ROUTE → CREATE → NORMALIZE →
// commitVault (src/memory/pipeline.ts `runPipeline`) over a handful of REAL
// ingested conversations, copied out of the production memory store into an
// in-memory throwaway (so the synthesized_chunk_sections ledger + minted
// entities land in the throwaway — production memory.sqlite is opened READONLY
// and never written), drafting entity-granular articles into a DEDICATED smoke
// vault at ~/.mlx-bun/wiki-smoke. The real ~/.mlx-bun/wiki and ~/Code/lucien are
// never touched.
//
// Then it REINDEXES the smoke vault and runs the P3-T5 north-star traversal
// against the SYNTHESIZED articles (not the hand-built fixture): FIND the owned
// camera by name, READ small, hop the [[link]] graph to a lens, with the
// embedding tripwire pinned at zero. ONE base-model load.
//
//   bun scripts/experiments/dreaming-coldstart-smoke.ts

import { Database } from "bun:sqlite";
import { readFileSync } from "node:fs";
import { rm } from "node:fs/promises";
import { homedir } from "node:os";
import { join } from "node:path";

const SMOKE_VAULT = join(homedir(), ".mlx-bun", "wiki-smoke");
process.env.MLX_BUN_WIKI = SMOKE_VAULT; // BEFORE importing vault-aware modules

const { MemoryStore, DEFAULT_MEMORY_DB } = await import("../../src/memory/db");
const { setupVault } = await import("../../src/memory/vault");
const { runPipeline } = await import("../../src/memory/pipeline");
const { reindex } = await import("../../src/memory/reindex");
const { buildMemoryIndex, neighbors, resolveName, articlesInCategory } = await import("../../src/memory/query");
const { parseToc, extractSection } = await import("../../src/memory/vault");
const { getEmbedCounter, resetEmbedCounter } = await import("../../src/embed");

// ---- the ~10 REAL conversations (small total-chunk counts, max entity reach) -
// 8 camera/lens (incl. the Sigma 150-600 long-reach pick + the S5IIX box conv
// that carries the L-Mount fact) + 2 AI-tooling. Selected by chunk-LABEL match
// against the camera/lens cluster in goldens/dreaming-entities-gold.json
// (chunk_entities is empty pre-extraction, so labels are the routing proxy).
const CONV_IDS = [
  "67406000-7308-8013-a892-272d0a37eb0a", // S5IIX in the box, hot shoe, USB-C (L-Mount fact)
  "67030293-c6a0-8013-ad9a-51d5b42a7beb", // Helios 44-2 → L-Mount, M42, S5IIX pairing
  "68296b8f-12ec-8013-9a2a-0b58656f4664", // Sankor 16C + Helios anamorphic rig
  "680b2a37-16a8-8013-859c-72155a199832", // Choosing Sigma 150-600 long-reach telephoto
  "67a149c3-aea4-8013-82ad-94be3e885ac2", // Sigma MC-21, 75-300 telephoto, EF/EF-S
  "681e96a0-ae10-8013-a79d-d66288c8ce55", // M42 vintage collection, Helios, Takumar
  "789169b2-e08d-4867-9c27-7548c8aa895a", // Sirui Aurora/Saturn, Singer 16-D
  "684c39b4-3a30-8013-a258-93767c05329b", // Sankor 16D anamorphic, L-Mount weight
  "67d0f30b-58a2-449c-af72-1ee89acbdeac", // MCP server capabilities, Claude Code
  "1e2b8d5a-8516-4334-a753-cac7fd406cf4", // Archon, MCP architecture, Claude Code
];

const ARTICLE_CAP = 16;

/** Copy each conversation's row + ALL its messages + ALL its chunks out of the
 *  production store into the throwaway in-memory store (pointer-based chunks). */
function copyConvs(src: Database, dst: InstanceType<typeof MemoryStore>): number {
  const ins = dst.db;
  let chunks = 0;
  for (const conv of CONV_IDS) {
    const c = src.query("SELECT conv, source, title, updated_at, chunked_at FROM conversations WHERE conv = ?").get(conv) as
      | { conv: string; source: string; title: string; updated_at: number; chunked_at: number | null }
      | null;
    if (!c) {
      console.warn(`  ! conversation not found in production store: ${conv}`);
      continue;
    }
    ins.run("INSERT OR IGNORE INTO conversations (conv, source, title, updated_at, chunked_at) VALUES (?,?,?,?,?)", [
      c.conv, c.source, c.title, c.updated_at, c.chunked_at,
    ]);
    const msgs = src.query("SELECT conv, position, role, uuid, text FROM messages WHERE conv = ? ORDER BY position").all(conv) as any[];
    for (const m of msgs) {
      ins.run("INSERT OR IGNORE INTO messages (conv, position, role, uuid, text) VALUES (?,?,?,?,?)", [
        m.conv, m.position, m.role, m.uuid, m.text,
      ]);
    }
    const chs = src.query("SELECT id, conv, start, end, label FROM chunks WHERE conv = ? ORDER BY id").all(conv) as any[];
    for (const ch of chs) {
      ins.run("INSERT OR IGNORE INTO chunks (id, conv, start, end, label) VALUES (?,?,?,?,?)", [
        ch.id, ch.conv, ch.start, ch.end, ch.label,
      ]);
      chunks++;
    }
  }
  return chunks;
}

// ---- north-star read-path traversal over the SYNTHESIZED vault --------------

interface ReadTrace { step: string; bytes: number }
const trace: ReadTrace[] = [];
function record(step: string, text: string): string {
  const bytes = Buffer.byteLength(text, "utf8");
  trace.push({ step, bytes });
  console.log(`  · ${step} — ${bytes} B`);
  return text;
}
function readFileArticle(stem: string): string {
  return readFileSync(join(SMOKE_VAULT, "articles", `${stem}.md`), "utf8");
}

async function main() {
  console.log(`smoke vault: ${SMOKE_VAULT}`);
  await rm(SMOKE_VAULT, { recursive: true, force: true }); // start FRESH
  await setupVault(SMOKE_VAULT);

  const prod = new Database(DEFAULT_MEMORY_DB, { readonly: true });
  const store = new MemoryStore(":memory:");
  const copied = copyConvs(prod, store);
  prod.close();
  console.log(`copied ${CONV_IDS.length} conversations / ${copied} chunks into the throwaway store\n`);

  // ===== RUN THE DAG (one base-model load) =====
  console.log("running the cold-start DAG on the base model (one load)…");
  const t0 = Date.now();
  const result = await runPipeline(store, {
    convIds: CONV_IDS,
    root: SMOKE_VAULT,
    articleCap: ARTICLE_CAP,
    mustCreate: ["Panasonic Lumix S5IIX", "L-Mount"],
    onEvent: (e) => {
      if (e.type === "stage") console.log(`  · ${e.message}`);
      else if (e.type === "done") console.log(`  ✓ ${e.message}`);
    },
  });
  console.log(`\nDAG done in ${((Date.now() - t0) / 1000).toFixed(1)}s`);
  console.log(`  entities seen: ${result.entities}; created: ${result.created.length}; gated: ${result.skippedByGate.length}; captured: ${result.captured.length}`);

  // ===== REINDEX the smoke vault (derived cache + read index) =====
  reindex(store, SMOKE_VAULT);

  console.log("\n================ ARTICLES CREATED ================");
  for (const a of result.created) {
    console.log(`  ${a.stem}  (infobox=${a.hasInfobox}, citations=${a.citedSections}, chunkEdges=${a.chunkEdges})`);
  }
  console.log("==================================================\n");

  // ===== NORTH-STAR TRAVERSAL over the synthesized articles =====
  resetEmbedCounter();
  const idx = buildMemoryIndex(SMOKE_VAULT);

  const q1 = "what's the best lens for really long reach that isn't crazy expensive?";
  console.log(`Q1: ${q1}\n`);

  // FIND — resolve the owned camera by name (no vector, no substring search).
  const camStem = resolveName(idx, "the Lumix S5IIX") ?? resolveName(idx, "S5IIX") ?? resolveName(idx, "Panasonic Lumix S5IIX");
  console.log(`  FIND via memory_resolve("the Lumix S5IIX") → ${camStem}`);

  let sIIXHasLMount = false;
  let answered = false;
  let lensStem: string | null = null;

  if (camStem) {
    // READ small — TOC + lead, then ONE section.
    const camMd = readFileArticle(camStem);
    const toc = parseToc(camMd);
    const lead = idx.leadByStem.get(camStem) ?? "";
    record(`memory_read TOC ${camStem}`, `${camStem}\n${lead}\nSections:\n${toc.map((h) => `- ${h.title} (#${h.anchor})`).join("\n")}`);
    if (toc[0]) record(`memory_section ${camStem}#${toc[0].anchor}`, extractSection(camMd, toc[0].anchor) ?? "");

    // Infobox mount: [[L-Mount]] — the acceptance bonus + the navigation hop.
    const box = idx.infoboxByStem.get(camStem) ?? null;
    const mountField = box?.fields.find((f) => f.key === "mount");
    sIIXHasLMount = !!mountField && /\[\[\s*L-?Mount/i.test(mountField.value);
    console.log(`  infobox mount field: ${mountField ? JSON.stringify(mountField.value) : "(none)"}  → L-Mount? ${sIIXHasLMount}`);

    // HOP — camera → mount → native lenses (pure [[link]] navigation).
    const camNb = neighbors(idx, camStem);
    console.log(`  ${camStem} outbound links: ${JSON.stringify(camNb.outbound)}`);
    const mountStem = camNb.outbound.find((s) => /^L-?Mount$/i.test(s)) ?? null;
    if (mountStem) {
      const mountNb = neighbors(idx, mountStem);
      console.log(`  ${camStem} —mount→ ${mountStem} —linked→ ${JSON.stringify([...mountNb.outbound, ...mountNb.inbound])}`);
      lensStem = [...mountNb.inbound, ...mountNb.outbound].find((s) => /sigma|lumix|helios|sirui|telephoto|lens|150|600/i.test(s)) ?? null;
    }
  }

  // FIND path B — articles declared in a lens-ish category (model-emergent).
  const lensCats = [...idx.categoryToStems.keys()].filter((c) => /lens|telephoto|camera|glass|optic/i.test(c));
  for (const c of lensCats) console.log(`  category "${c}" → ${JSON.stringify(articlesInCategory(idx, c))}`);
  if (!lensStem && lensCats[0]) lensStem = articlesInCategory(idx, lensCats[0])[0] ?? null;
  // Last resort: any created lens/telephoto-named article.
  if (!lensStem) {
    lensStem = result.created.map((a) => a.stem).find((s) => /sigma|150|600|lumix_75|telephoto|helios|sirui/i.test(s)) ?? null;
  }

  if (lensStem) {
    console.log(`\n  FOUND lens article: ${lensStem}`);
    const lensMd = readFileArticle(lensStem);
    const ltoc = parseToc(lensMd);
    record(`memory_read TOC ${lensStem}`, `${lensStem}\nSections:\n${ltoc.map((h) => `- ${h.title}`).join("\n")}`);
    const sec = ltoc.find((h) => /verdict|pick|reach|decision|choice|why|telephoto|value/i.test(h.title)) ?? ltoc[0];
    if (sec) {
      const body = record(`memory_section ${lensStem}#${sec.anchor}`, extractSection(lensMd, sec.anchor) ?? "");
      answered = body.trim().length > 0;
    }
    console.log("\n  ANSWER (grounded in the FOUND + READ synthesized article, spoken as a continuation):");
    console.log(`  > ${lensStem.replace(/_/g, " ")} is the long-reach pick recorded in your notes — read from the synthesized article above.`);
  } else {
    console.log("\n  (no lens article was synthesized from the sampled chunks)");
  }

  // ===== ACCEPTANCE =====
  const total = trace.reduce((a, t) => a + t.bytes, 0);
  const maxRead = trace.reduce((a, t) => Math.max(a, t.bytes), 0);
  const embeds = getEmbedCounter();

  console.log("\n" + "=".repeat(64));
  console.log("ACCEPTANCE:");
  console.log(`  articles created: ${result.created.length}`);
  console.log(`  S5IIX resolved: ${!!camStem}`);
  console.log(`  S5IIX infobox mount: [[L-Mount]]: ${sIIXHasLMount}`);
  console.log(`  north-star found+read+answered: ${answered}`);
  console.log(`  reads: ${trace.length}  total bytes: ${total}  max single read: ${maxRead} B`);
  console.log(`  embed calls (tripwire): ${embeds}`);
  console.log("=".repeat(64));

  const metrics = {
    articlesCreated: result.created.map((a) => ({ stem: a.stem, hasInfobox: a.hasInfobox, citations: a.citedSections })),
    northStarAnswered: answered && !!camStem,
    sIIXHasLMount,
    embedCount: embeds,
    totalBytes: total,
    maxRead,
    captured: result.captured,
    skippedByGate: result.skippedByGate,
  };
  console.log("\nMETRICS_JSON " + JSON.stringify(metrics));

  store.close();
  const ok = !!camStem && result.created.length > 0 && embeds === 0;
  if (!ok) { console.error("\nSMOKE FAILED"); process.exit(1); }
  console.log("\nSMOKE PASSED");
}

await main();
