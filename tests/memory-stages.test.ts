// The Dreaming — STAGE WORKERS are independent, chronological, resumable.
//
// Proves the pipeline decomposition (src/memory/stages.ts): each of the four
// stage workers is callable on its own over the store, pulls its eligible work
// by DB state, walks oldest-conversation-first (NOT by chunk-id == conv-UUID,
// which sorts randomly w.r.t. time), and is resumable (a re-run does no work).
// Everything reachable WITHOUT the GPU via the injected model seams.

import { describe, expect, it, afterEach } from "bun:test";
import { mkdtemp, mkdir, writeFile } from "node:fs/promises";
import { tmpdir } from "node:os";
import { join } from "node:path";

import { MemoryStore, chunkId } from "../src/memory/db";
import type { ExtractCall } from "../src/memory/entity";
import type { SynthesisCall } from "../src/memory/synthesize";
import {
  runExtractStage,
  runRouteStage,
  runSynthesizeStage,
  chronoChunkIds,
  entityChunkIdsChrono,
} from "../src/memory/stages";

// A NEWER conversation whose UUID sorts FIRST lexicographically, and an OLDER one
// whose UUID sorts LAST — so chunk-id order is the REVERSE of chronological order.
const CONV_NEW = "00000000-0000-0000-0000-000000000000"; // updated_at LATER, id sorts first
const CONV_OLD = "ffffffff-0000-0000-0000-000000000000"; // updated_at EARLIER, id sorts last

const savedWiki = process.env.MLX_BUN_WIKI;
afterEach(() => {
  if (savedWiki === undefined) delete process.env.MLX_BUN_WIKI;
  else process.env.MLX_BUN_WIKI = savedWiki;
});

async function seedVault(): Promise<string> {
  const root = await mkdtemp(join(tmpdir(), "dreaming-stages-"));
  await mkdir(join(root, "articles"), { recursive: true });
  await mkdir(join(root, "Meta"), { recursive: true });
  await writeFile(join(root, "Meta", "Entities.md"), "# Entities\n\nName the entity each chunk is about.\n");
  process.env.MLX_BUN_WIKI = root;
  return root;
}

/** OLD conv: three chunks all about "Old Thing" (recurs ⇒ create-eligible).
 *  NEW conv: one chunk about "New Thing" (captured). Both pre-chunked +
 *  watermarked so SEGMENT is out of scope here. */
function seedStore(): MemoryStore {
  const store = new MemoryStore(":memory:");
  const addConv = (conv: string, at: number, lines: string[]) => {
    store.db.run("INSERT INTO conversations (conv, source, title, updated_at, chunked_at) VALUES (?,?,?,?,?)", [
      conv, "pi-terminal", "t", at, at,
    ]);
    lines.forEach((text, i) =>
      store.db.run("INSERT INTO messages (conv, position, role, uuid, text) VALUES (?,?,?,?,?)", [
        conv, i, i % 2 === 0 ? "user" : "assistant", `${conv}-${i}`, text,
      ]),
    );
  };
  addConv(CONV_OLD, 1000, [
    "old-a user", "old-a asst", "old-b user", "old-b asst", "old-c user", "old-c asst",
  ]);
  addConv(CONV_NEW, 5000, ["new user", "new asst"]);
  for (const [s, e] of [[0, 1], [2, 3], [4, 5]] as const) {
    store.db.run("INSERT INTO chunks (id, conv, start, end, label) VALUES (?,?,?,?,?)", [
      chunkId(CONV_OLD, s, e), CONV_OLD, s, e, "old thing",
    ]);
  }
  store.db.run("INSERT INTO chunks (id, conv, start, end, label) VALUES (?,?,?,?,?)", [
    chunkId(CONV_NEW, 0, 1), CONV_NEW, 0, 1, "new thing",
  ]);
  return store;
}

describe("stages — chronological selectors", () => {
  it("chronoChunkIds orders oldest-conversation-first, not by chunk-id (== conv UUID)", () => {
    const store = seedStore();
    const { convs, chunkIds } = chronoChunkIds(store);
    expect(convs).toBe(2);
    // OLD (updated_at 1000) precedes NEW (updated_at 5000) despite its UUID sorting LAST.
    expect(chunkIds[0]!.startsWith(CONV_OLD)).toBe(true);
    expect(chunkIds[chunkIds.length - 1]!.startsWith(CONV_NEW)).toBe(true);
    store.close();
  });
});

describe("stages — runExtractStage (independent, chronological, resumable)", () => {
  it("extracts each pending chunk oldest-first and skips already-extracted on re-run", async () => {
    await seedVault();
    const store = seedStore();
    const order: string[] = [];
    const extractCall: ExtractCall = async (prompt) => {
      const which = /old/i.test(prompt) ? "Old Thing" : "New Thing";
      order.push(which);
      return which;
    };

    const first = await runExtractStage(store, { call: extractCall });
    expect(first.extracted).toBe(4); // 3 old + 1 new
    expect(first.remaining).toBe(0);
    // Chronological: all OLD chunks processed before the NEW one.
    expect(order).toEqual(["Old Thing", "Old Thing", "Old Thing", "New Thing"]);

    // Resumable: nothing left to do on a second pass (no model calls).
    order.length = 0;
    const second = await runExtractStage(store, { call: extractCall });
    expect(second.extracted).toBe(0);
    expect(order).toEqual([]);
    store.close();
  });

  it("honors a bounded limit and reports the remaining work", async () => {
    await seedVault();
    const store = seedStore();
    const r = await runExtractStage(store, { limit: 2, call: async () => "Old Thing" });
    expect(r.extracted).toBe(2);
    expect(r.remaining).toBe(2);
    store.close();
  });
});

describe("stages — runRouteStage persists the create/capture decision", () => {
  it("marks the recurring entity notable=1 and captures the thin one (notable=0)", async () => {
    await seedVault();
    const store = seedStore();
    await runExtractStage(store, {
      call: async (prompt) => (/old/i.test(prompt) ? "Old Thing" : "New Thing"),
    });

    const route = await runRouteStage(store);
    expect(route.createEligible).toBe(1);
    expect(route.captured).toContain("New Thing");

    const notable = (name: string) =>
      (store.db.query("SELECT notable FROM entities WHERE name = ?").get(name) as { notable: number }).notable;
    expect(notable("Old Thing")).toBe(1);
    expect(notable("New Thing")).toBe(0);

    // Captured subject's chunk landed in the reserved _captured bucket (still
    // searchable — not dropped).
    const capturedChunks = store.db
      .query("SELECT COUNT(*) AS n FROM chunk_buckets WHERE bucket = '_captured'")
      .get() as { n: number };
    expect(capturedChunks.n).toBe(1);

    // entityChunkIdsChrono feeds Old Thing's chunks oldest-first.
    const cids = entityChunkIdsChrono(store, "Old Thing");
    expect(cids.length).toBe(3);
    expect(cids.every((id) => id.startsWith(CONV_OLD))).toBe(true);
    store.close();
  });
});

describe("stages — runSynthesizeStage drafts only the create-eligible entity", () => {
  it("creates the notable=1 entity, leaves the captured one alone", async () => {
    const root = await seedVault();
    const store = seedStore();
    await runExtractStage(store, {
      call: async (prompt) => (/old/i.test(prompt) ? "Old Thing" : "New Thing"),
    });
    await runRouteStage(store);

    const synthesisCall: SynthesisCall = async (prompt) => {
      if (prompt.includes("Propose a clean table of contents")) return "Usage Notes";
      if (prompt.includes("Write the LEAD")) return "**Old Thing** is something the user owns and uses.";
      if (prompt.includes("Produce the INFOBOX facts")) return "```\ntype: gadget\nowned: yes\n```";
      if (prompt.includes("Draft ONLY the body of the")) {
        const list = prompt.split("Cite sources")[1] ?? "";
        const mk = /\[\^(\d+)\]/.exec(list);
        return `The user relies on this thing.${mk ? `[^${mk[1]}]` : ""}`;
      }
      return "NONE";
    };

    const r = await runSynthesizeStage(store, { root, call: synthesisCall, commit: false });
    expect(r.created.map((c) => c.stem)).toEqual(["Old_Thing"]);
    expect(r.patched.length).toBe(0);
    store.close();
  });
});
