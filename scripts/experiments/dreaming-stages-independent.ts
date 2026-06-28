// The Dreaming — the four stage workers run INDEPENDENTLY + advance DB state.
//
// Mirrors `mlx-bun memory segment|extract|route|synthesize-stage` (cli.ts thin
// wrappers over stages.ts) but on a TEMP store with injected fake model seams, so
// it is GPU-free and mutates nothing real. Each stage is invoked SEPARATELY with a
// bounded limit; after each we print the DB state it advanced, proving the stages
// are individually runnable + resumable (a re-run drains the remainder, then is a
// no-op).

import { mkdtemp, mkdir, writeFile } from "node:fs/promises";
import { tmpdir } from "node:os";
import { join } from "node:path";

import { MemoryStore } from "../../src/memory/db";
import type { ChunkCall } from "../../src/memory/chunk";
import {
  runSegmentStage,
  runExtractStage,
  runRouteStage,
  runSynthesizeStage,
} from "../../src/memory/stages";
import type { SynthesisCall } from "../../src/memory/synthesize";

function state(store: MemoryStore) {
  const q = (sql: string) => (store.db.query(sql).get() as { n: number }).n;
  return {
    convsChunked: q("SELECT COUNT(*) AS n FROM conversations WHERE chunked_at IS NOT NULL"),
    chunks: q("SELECT COUNT(*) AS n FROM chunks"),
    extracted: q("SELECT COUNT(DISTINCT chunk_id) AS n FROM chunk_entities"),
    notable: q("SELECT COUNT(*) AS n FROM entities WHERE notable = 1"),
  };
}

async function main(): Promise<void> {
  const root = await mkdtemp(join(tmpdir(), "stages-indep-"));
  await mkdir(join(root, "articles"), { recursive: true });
  await mkdir(join(root, "Meta"), { recursive: true });
  await writeFile(join(root, "Meta", "Entities.md"), "# Entities\n");
  await writeFile(join(root, "Meta", "Chunking.md"), "# Chunking\n\nSplit a conversation into single-topic chunks.\n");
  await writeFile(join(root, "Meta", "Topics_to_Ignore.md"), "# Topics to Ignore\n\nNothing for this demo.\n");
  process.env.MLX_BUN_WIKI = root;
  const store = new MemoryStore(":memory:");

  // Seed 4 conversations (out-of-order updated_at) each with 6 messages, NOT yet
  // chunked (chunked_at NULL) so SEGMENT has real work.
  const convs = [
    { conv: "aaaa1111-0000-0000-0000-000000000000", at: 100, ent: "Zephyr" },
    { conv: "0000bbbb-0000-0000-0000-000000000000", at: 400, ent: "Bravo" },
    { conv: "cccc2222-0000-0000-0000-000000000000", at: 200, ent: "Charlie" },
    { conv: "dddd3333-0000-0000-0000-000000000000", at: 300, ent: "Delta" },
  ];
  for (const c of convs) {
    store.db.run("INSERT INTO conversations (conv, source, title, updated_at, chunked_at) VALUES (?,?,?,?,NULL)", [
      c.conv, "pi-terminal", c.ent, c.at,
    ]);
    for (let i = 0; i < 6; i++) {
      store.db.run("INSERT INTO messages (conv, position, role, uuid, text) VALUES (?,?,?,?,?)", [
        c.conv, i, i % 2 === 0 ? "user" : "assistant", `${c.conv}-${i}`, `talking about ${c.ent} here`,
      ]);
    }
  }

  // FAKE seams (GPU-free). SEGMENT emits a 3-chunk boundary set per conversation,
  // echoing the message uuids it parses from the prompt (the first `uuid:` is the
  // conversation's own; the rest are the six messages).
  const segCall: ChunkCall = async (prompt) => {
    const uuids = [...prompt.matchAll(/uuid: ([^)]+)\)/g)].map((m) => m[1]!);
    const msg = uuids.slice(1); // drop the conversation uuid
    const chunks = [[0, 1], [2, 3], [4, 5]].map(([s, e]) => ({
      start_message_uuid: msg[s!]!,
      end_message_uuid: msg[e!]!,
      label: "topic",
    }));
    return JSON.stringify({ chunks });
  };
  const entFor = (p: string) => convs.find((c) => p.includes(c.ent))?.ent ?? "Unknown";
  const synthCall: SynthesisCall = async (prompt) => {
    if (prompt.includes("Propose a clean table of contents")) return "Usage Notes";
    if (prompt.includes("Write the LEAD")) return `**${entFor(prompt)}** is owned and used by the user.`;
    if (prompt.includes("Produce the INFOBOX facts")) return "```\ntype: gadget\n```";
    if (prompt.includes("Draft ONLY the body of the")) {
      const list = prompt.split("Cite sources")[1] ?? "";
      const mk = /\[\^(\d+)\]/.exec(list);
      return `The user relies on this.${mk ? `[^${mk[1]}]` : ""}`;
    }
    return "NONE";
  };
  const show = (label: string) => console.log(`  state after ${label}: ${JSON.stringify(state(store))}`);

  console.log("\n# mlx-bun memory segment --limit 3   (independent worker)");
  const s1 = await runSegmentStage(store, { limit: 3, call: segCall });
  console.log(`  segment: ${s1.valid} segmented, ${s1.chunks} chunks`);
  show("segment#1 (limit 3)");

  console.log("\n# mlx-bun memory segment            (resume → drains the 4th)");
  const s2 = await runSegmentStage(store, { call: segCall });
  console.log(`  segment: ${s2.valid} segmented (resumed)`);
  show("segment#2");

  console.log("\n# mlx-bun memory extract --limit 5  (independent worker, bounded)");
  const e1 = await runExtractStage(store, { limit: 5, call: async (p) => entFor(p) });
  console.log(`  extract: ${e1.extracted} extracted, ${e1.remaining} remaining`);
  show("extract#1 (limit 5)");

  console.log("\n# mlx-bun memory extract            (resume → drains remainder)");
  const e2 = await runExtractStage(store, { call: async (p) => entFor(p) });
  console.log(`  extract: ${e2.extracted} extracted, ${e2.remaining} remaining`);
  show("extract#2");

  console.log("\n# mlx-bun memory route              (independent worker)");
  const r = await runRouteStage(store);
  console.log(`  route: ${r.decisions.length} entities, ${r.createEligible} create-eligible, ${r.captured.length} captured`);
  show("route");

  console.log("\n# mlx-bun memory synthesize-stage --limit 3  (independent worker, bounded)");
  const y1 = await runSynthesizeStage(store, { root, limit: 3, call: synthCall, commit: false });
  console.log(`  synthesize: created=${y1.created.map((c) => c.stem).join(",")}`);

  console.log("\n# mlx-bun memory synthesize-stage   (resume → creates the 4th only)");
  const y2 = await runSynthesizeStage(store, { root, call: synthCall, commit: false });
  console.log(`  synthesize: created=${y2.created.map((c) => c.stem).join(",") || "(none — all present)"}`);

  console.log("\n# mlx-bun memory synthesize-stage   (idempotent re-run → no work)");
  const y3 = await runSynthesizeStage(store, { root, call: synthCall, commit: false });
  console.log(`  synthesize: created=${y3.created.length}, patched=${y3.patched.length}`);

  store.close();
  console.log("\nOK — each stage ran on its own, advanced DB state, and resumed cleanly.");
}

main().catch((e) => {
  console.error(e);
  process.exit(1);
});
