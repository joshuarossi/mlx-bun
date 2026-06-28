// The Dreaming — STAGES PROCESS CHRONOLOGICALLY (oldest conversation first).
//
// The load-bearing property of the staged pipeline: every stage walks
// conversations.updated_at ASC, NOT chunk-id (== conv UUID, lexicographic =
// random w.r.t. time). This deterministic test (fake model seams that RECORD the
// order chunks/entities are handed to them) pins that:
//   • three conversations with OUT-OF-ORDER updated_at (A=100, C=200, B=300),
//     each inserted in a DIFFERENT order and with UUIDs that sort DIFFERENTLY
//     again, so insertion / UUID / chronological order all disagree;
//   • runExtractStage hands chunks to the model A → C → B (updated_at ASC);
//   • runSynthesizeStage drafts entities A → C → B (oldest source first);
//   • resumability: a second pass with some chunk_entities already present
//     processes ONLY the remainder.
// All reachable WITHOUT the GPU via the injected `call` seams.

import { afterEach, describe, expect, it } from "bun:test";
import { mkdtemp, mkdir, writeFile } from "node:fs/promises";
import { tmpdir } from "node:os";
import { join } from "node:path";

import { MemoryStore, chunkId } from "../src/memory/db";
import type { ExtractCall } from "../src/memory/entity";
import type { SynthesisCall } from "../src/memory/synthesize";
import { runExtractStage, runRouteStage, runSynthesizeStage } from "../src/memory/stages";

// updated_at: A=100 (oldest), C=200 (mid), B=300 (newest).
// UUIDs chosen so lexicographic order (B < A < C) ≠ chronological order (A,C,B).
const CONV_A = "aaaaaaaa-0000-0000-0000-000000000000"; // updated_at 100
const CONV_B = "00000000-0000-0000-0000-000000000000"; // updated_at 300 (UUID sorts FIRST)
const CONV_C = "cccccccc-0000-0000-0000-000000000000"; // updated_at 200

const savedWiki = process.env.MLX_BUN_WIKI;
afterEach(() => {
  if (savedWiki === undefined) delete process.env.MLX_BUN_WIKI;
  else process.env.MLX_BUN_WIKI = savedWiki;
});

async function seedVault(): Promise<string> {
  const root = await mkdtemp(join(tmpdir(), "dreaming-chrono-"));
  await mkdir(join(root, "articles"), { recursive: true });
  await mkdir(join(root, "Meta"), { recursive: true });
  await writeFile(join(root, "Meta", "Entities.md"), "# Entities\n\nName the entity each chunk is about.\n");
  process.env.MLX_BUN_WIKI = root;
  return root;
}

/** Each conversation has 3 chunks all about ONE entity (≥3 ⇒ create-eligible).
 *  The chunk text carries a per-entity token so the recording ExtractCall can map
 *  prompt → entity. INSERTION order is B, A, C (≠ chrono, ≠ UUID). */
function seedStore(): MemoryStore {
  const store = new MemoryStore(":memory:");
  const addConv = (conv: string, at: number, token: string) => {
    store.db.run("INSERT INTO conversations (conv, source, title, updated_at, chunked_at) VALUES (?,?,?,?,?)", [
      conv, "pi-terminal", token, at, at,
    ]);
    // six messages → three [start,end] chunks, all mentioning the entity token.
    for (let i = 0; i < 6; i++) {
      store.db.run("INSERT INTO messages (conv, position, role, uuid, text) VALUES (?,?,?,?,?)", [
        conv, i, i % 2 === 0 ? "user" : "assistant", `${conv}-${i}`, `talking about ${token} here`,
      ]);
    }
    for (const [s, e] of [[0, 1], [2, 3], [4, 5]] as const) {
      store.db.run("INSERT INTO chunks (id, conv, start, end, label) VALUES (?,?,?,?,?)", [
        chunkId(conv, s, e), conv, s, e, token,
      ]);
    }
  };
  addConv(CONV_B, 300, "Bravo");
  addConv(CONV_A, 100, "Zephyr");
  addConv(CONV_C, 200, "Charlie");
  return store;
}

const ENTITIES = ["Zephyr", "Bravo", "Charlie"] as const;
function entityIn(prompt: string): string | null {
  for (const e of ENTITIES) if (prompt.includes(e)) return e;
  return null;
}

describe("stages — chronological processing (oldest conversation first)", () => {
  it("runExtractStage hands chunks to the model updated_at ASC (A → C → B), not by UUID", async () => {
    await seedVault();
    const store = seedStore();
    const order: string[] = [];
    const extractCall: ExtractCall = async (prompt) => {
      const e = entityIn(prompt) ?? "Unknown";
      order.push(e);
      return e;
    };

    const r = await runExtractStage(store, { call: extractCall });
    expect(r.extracted).toBe(9); // 3 convs × 3 chunks
    expect(r.remaining).toBe(0);
    // Chronological: all of Zephyr (100) before all of Charlie (200) before Bravo (300).
    expect(order).toEqual([
      "Zephyr", "Zephyr", "Zephyr",
      "Charlie", "Charlie", "Charlie",
      "Bravo", "Bravo", "Bravo",
    ]);
    // NOT UUID order (which would have put Bravo, UUID 0000…, first).
    expect(order[0]).not.toBe("Bravo");
    store.close();
  });

  it("runSynthesizeStage drafts entities oldest-source-first (Zephyr → Charlie → Bravo)", async () => {
    const root = await seedVault();
    const store = seedStore();
    await runExtractStage(store, { call: async (p) => entityIn(p) ?? "Unknown" });
    await runRouteStage(store);

    const createOrder: string[] = [];
    const synthesisCall: SynthesisCall = async (prompt) => {
      if (prompt.includes("Propose a clean table of contents")) {
        const e = entityIn(prompt); // OUTLINE is the first call per entity → records create order
        if (e) createOrder.push(e);
        return "Usage Notes";
      }
      if (prompt.includes("Write the LEAD")) return `**${entityIn(prompt)}** is something the user owns and uses.`;
      if (prompt.includes("Produce the INFOBOX facts")) return "```\ntype: gadget\nowned: yes\n```";
      if (prompt.includes("Draft ONLY the body of the")) {
        const list = prompt.split("Cite sources")[1] ?? "";
        const mk = /\[\^(\d+)\]/.exec(list);
        return `The user relies on this thing.${mk ? `[^${mk[1]}]` : ""}`;
      }
      return "NONE";
    };

    const r = await runSynthesizeStage(store, { root, call: synthesisCall, commit: false });
    expect(r.created.map((c) => c.stem).sort()).toEqual(["Bravo", "Charlie", "Zephyr"]);
    // The ORDER entities were drafted is chronological by earliest source conv.
    expect(createOrder).toEqual(["Zephyr", "Charlie", "Bravo"]);
    store.close();
  });

  it("is resumable — a second extract pass processes ONLY the remainder", async () => {
    await seedVault();
    const store = seedStore();
    // First pass: extract ONLY A and B (leaving C pending).
    const first: string[] = [];
    await runExtractStage(store, {
      convIds: [CONV_A, CONV_B],
      call: async (p) => {
        const e = entityIn(p) ?? "Unknown";
        first.push(e);
        return e;
      },
    });
    expect(first.sort()).toEqual(["Bravo", "Bravo", "Bravo", "Zephyr", "Zephyr", "Zephyr"]);

    // Second pass over EVERYTHING: only C's chunks remain (A/B already have rows).
    const second: string[] = [];
    const r = await runExtractStage(store, {
      call: async (p) => {
        const e = entityIn(p) ?? "Unknown";
        second.push(e);
        return e;
      },
    });
    expect(r.extracted).toBe(3);
    expect(second).toEqual(["Charlie", "Charlie", "Charlie"]);
    store.close();
  });

  it("is resumable — a second synthesize pass creates ONLY entities without an article", async () => {
    const root = await seedVault();
    const store = seedStore();
    await runExtractStage(store, { call: async (p) => entityIn(p) ?? "Unknown" });
    await runRouteStage(store);

    const mk: SynthesisCall = async (prompt) => {
      if (prompt.includes("Write the LEAD")) return `**${entityIn(prompt)}** is owned and used.`;
      if (prompt.includes("Propose a clean table of contents")) return "Usage Notes";
      if (prompt.includes("Produce the INFOBOX facts")) return "```\ntype: gadget\n```";
      if (prompt.includes("Draft ONLY the body of the")) {
        const list = prompt.split("Cite sources")[1] ?? "";
        const mk2 = /\[\^(\d+)\]/.exec(list);
        return `The user relies on this thing.${mk2 ? `[^${mk2[1]}]` : ""}`;
      }
      return "NONE";
    };

    // First pass: cap at 1 → only the oldest (Zephyr) is created.
    const r1 = await runSynthesizeStage(store, { root, limit: 1, call: mk, commit: false });
    expect(r1.created.map((c) => c.stem)).toEqual(["Zephyr"]);

    // Second pass: Zephyr now has an article file → skipped; Charlie+Bravo remain.
    const r2 = await runSynthesizeStage(store, { root, call: mk, commit: false });
    expect(r2.created.map((c) => c.stem)).toEqual(["Charlie", "Bravo"]);
    store.close();
  });
});
