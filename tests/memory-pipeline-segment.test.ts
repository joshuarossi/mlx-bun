// The Dreaming — SEGMENT is wired into runPipeline (not a no-op).
//
// runPipeline must run OUR chunker (chunkConversations → the e4b-chunk-300 /
// `memory-chunk` adapter) over any conversation whose chunked_at is NULL or
// stale BEFORE it collects the run's chunk ids, then proceed on the freshly
// written chunks. We prove that here WITHOUT a real model load by injecting a
// fake `segmentCall` at the new pipeline seam: a conversation seeded with NO
// chunks and a NULL chunked_at is segmented by the fake, the chunk-pointer rows
// land in the store, the watermark is set, and the downstream DAG runs on them.

import { describe, expect, it, afterEach } from "bun:test";
import { mkdtemp, mkdir, writeFile } from "node:fs/promises";
import { tmpdir } from "node:os";
import { join } from "node:path";

import { MemoryStore } from "../src/memory/db";
import type { ChunkCall } from "../src/memory/chunk";
import type { ExtractCall } from "../src/memory/entity";
import { runPipeline } from "../src/memory/pipeline";

const CONV = "77778888-0000-0000-0000-000000000000"; // → conv:77778888

const savedWiki = process.env.MLX_BUN_WIKI;
afterEach(() => {
  if (savedWiki === undefined) delete process.env.MLX_BUN_WIKI;
  else process.env.MLX_BUN_WIKI = savedWiki;
});

/** A throwaway vault with the Meta policy pages SEGMENT inlines (Chunking +
 *  Topics_to_Ignore). chunkConversations reads the GLOBAL vaultRoot for these,
 *  so we point MLX_BUN_WIKI at this same root. */
async function seedVault(): Promise<string> {
  const root = await mkdtemp(join(tmpdir(), "dreaming-pipeline-segment-"));
  await mkdir(join(root, "articles"), { recursive: true });
  await mkdir(join(root, "Meta"), { recursive: true });
  await writeFile(join(root, "Meta", "Chunking.md"), "# Chunking\n\nDefault granularity.\n");
  await writeFile(join(root, "Meta", "Topics_to_Ignore.md"), "# Topics to Ignore\n\n(none)\n");
  await writeFile(join(root, "Meta", "Entities.md"), "# Entities\n\nName the entity each chunk is about.\n");
  process.env.MLX_BUN_WIKI = root;
  return root;
}

/** A conversation with NO chunks yet (chunked_at NULL) + one user/assistant
 *  exchange — eligible for SEGMENT. */
function seedStore(): MemoryStore {
  const store = new MemoryStore(":memory:");
  store.db.run(
    "INSERT INTO conversations (conv, source, title, updated_at, chunked_at) VALUES (?,?,?,?,?)",
    [CONV, "pi-terminal", "Tripod head deliberation", 1735000000000, null],
  );
  const msgs = [
    "Which tripod head should I get for the S5IIX?",
    "A geared head trades speed for precision; a ball head is faster to frame.",
  ];
  msgs.forEach((text, i) =>
    store.db.run("INSERT INTO messages (conv, position, role, uuid, text) VALUES (?,?,?,?,?)", [
      CONV,
      i,
      i % 2 === 0 ? "user" : "assistant",
      `m${i}`,
      text,
    ]),
  );
  return store;
}

describe("pipeline — SEGMENT runs our chunker (not a no-op)", () => {
  it("segments a NULL-chunked_at conversation via the injected segmentCall and proceeds on the fresh chunks", async () => {
    const root = await seedVault();
    const store = seedStore();

    // No chunks exist for the conversation before the run.
    expect(
      (store.db.query("SELECT COUNT(*) AS n FROM chunks WHERE conv = ?").get(CONV) as { n: number }).n,
    ).toBe(0);

    // Fake SEGMENT model: emit one chunk spanning both messages (anchored on the
    // seeded uuids). Records that the seam was actually invoked.
    let segmentCalls = 0;
    const segmentCall: ChunkCall = async () => {
      segmentCalls++;
      return JSON.stringify({
        chunks: [{ start_message_uuid: "m0", end_message_uuid: "m1", label: "tripod head deliberation" }],
      });
    };
    // Fake ENTITY-EXTRACT so the downstream DAG runs with no GPU.
    const extractCall: ExtractCall = async () => "Tripod head";

    const result = await runPipeline(store, {
      root,
      convIds: [CONV],
      segmentCall,
      extractCall,
      commit: false,
    });

    // The segmenter was actually called …
    expect(segmentCalls).toBe(1);
    // … its chunk-pointer row landed in the store …
    const chunkRows = store.db.query("SELECT id, start, end, label FROM chunks WHERE conv = ?").all(CONV) as {
      id: string;
      start: number;
      end: number;
      label: string;
    }[];
    expect(chunkRows.length).toBe(1);
    expect(chunkRows[0]!.label).toBe("tripod head deliberation");
    // … the watermark was set (a re-run would now be a no-op) …
    const chunkedAt = (
      store.db.query("SELECT chunked_at FROM conversations WHERE conv = ?").get(CONV) as {
        chunked_at: number | null;
      }
    ).chunked_at;
    expect(chunkedAt).not.toBeNull();
    // … and the pipeline proceeded on the freshly written chunk.
    expect(result.convs).toBe(1);
    expect(result.chunks).toBe(1);

    store.close();
  });

  it("skips an already-segmented conversation (watermark holds, segmentCall not called)", async () => {
    const root = await seedVault();
    const store = seedStore();
    // Mark it segmented at == updated_at so SEGMENT skips it.
    store.db.run("UPDATE conversations SET chunked_at = updated_at WHERE conv = ?", [CONV]);

    let segmentCalls = 0;
    const segmentCall: ChunkCall = async () => {
      segmentCalls++;
      return "{}";
    };

    await runPipeline(store, { root, convIds: [CONV], segmentCall, extractCall: async () => "X", commit: false });

    expect(segmentCalls).toBe(0);
    store.close();
  });
});
