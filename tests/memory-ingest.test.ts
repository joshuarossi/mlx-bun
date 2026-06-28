// P5-T1 — Lucien bootstrap ingest (column map + chunk re-pointing + watermark).

import { afterEach, describe, expect, it } from "bun:test";
import { Database } from "bun:sqlite";
import { rmSync } from "node:fs";
import { MemoryStore, chunkId } from "../src/memory/db";
import { ingestLucien } from "../src/memory/ingest";

const TMP = "/private/tmp/claude-501/-Users-joshrossi-Code-mlx-bun";

/** Build a tiny Lucien-shaped source DB on disk and return its path. */
function makeLucienFixture(): string {
  const path = `${TMP}/lucien-fixture-${Date.now()}-${Math.random().toString(36).slice(2)}.db`;
  const db = new Database(path);
  db.exec(`
    CREATE TABLE conversations (uuid TEXT PRIMARY KEY, name TEXT, summary TEXT,
      created_at TEXT, updated_at TEXT, message_count INTEGER, source TEXT);
    CREATE TABLE messages (uuid TEXT PRIMARY KEY, conversation_uuid TEXT NOT NULL,
      position INTEGER NOT NULL, sender TEXT NOT NULL, text TEXT, timestamp TEXT,
      parent_message_uuid TEXT);
    CREATE TABLE chunks (id INTEGER PRIMARY KEY AUTOINCREMENT, conversation_uuid TEXT NOT NULL,
      start_message_uuid TEXT NOT NULL, end_message_uuid TEXT NOT NULL, label TEXT NOT NULL);
    CREATE TABLE chunked_conversations (conversation_uuid TEXT PRIMARY KEY,
      chunked_at TEXT NOT NULL, status TEXT);
  `);

  // conv A: chatgpt, 4 messages, 1 resolvable chunk (m0..m2) + 1 unresolvable (bogus end).
  db.run("INSERT INTO conversations VALUES (?,?,?,?,?,?,?)", [
    "aaaa1111-0000-0000-0000-000000000000", "Lens chat", "", "2025-01-01T00:00:00.000Z",
    "2025-01-02T00:00:00.000Z", 4, "chatgpt",
  ]);
  const aMsgs = [
    ["a-m0", 0, "user", "tell me about the L-Mount"],
    ["a-m1", 1, "assistant", "the L-Mount is an alliance"],
    ["a-m2", 2, "user", "and the S5IIX?"],
    ["a-m3", 3, "assistant", "a hybrid camera"],
  ] as const;
  for (const [u, p, s, t] of aMsgs)
    db.run("INSERT INTO messages VALUES (?,?,?,?,?,?,?)", [u, "aaaa1111-0000-0000-0000-000000000000", p, s, t, "", null]);
  db.run("INSERT INTO chunks (conversation_uuid,start_message_uuid,end_message_uuid,label) VALUES (?,?,?,?)",
    ["aaaa1111-0000-0000-0000-000000000000", "a-m0", "a-m2", "L-Mount intro"]);
  db.run("INSERT INTO chunks (conversation_uuid,start_message_uuid,end_message_uuid,label) VALUES (?,?,?,?)",
    ["aaaa1111-0000-0000-0000-000000000000", "a-m3", "a-DOESNOTEXIST", "broken span"]);
  db.run("INSERT INTO chunked_conversations VALUES (?,?,?)",
    ["aaaa1111-0000-0000-0000-000000000000", "2025-02-01T00:00:00.000Z", "done"]);

  // conv B: claude-ai, 2 messages, no chunks, not in chunked_conversations.
  db.run("INSERT INTO conversations VALUES (?,?,?,?,?,?,?)", [
    "bbbb2222-0000-0000-0000-000000000000", "Quick q", "", "2025-03-01T00:00:00.000Z",
    "2025-03-01T00:00:00.000Z", 2, "claude-ai",
  ]);
  db.run("INSERT INTO messages VALUES (?,?,?,?,?,?,?)", ["b-m0", "bbbb2222-0000-0000-0000-000000000000", 0, "human", "hi", "", null]);
  db.run("INSERT INTO messages VALUES (?,?,?,?,?,?,?)", ["b-m1", "bbbb2222-0000-0000-0000-000000000000", 1, "assistant", "hello", "", null]);

  db.close();
  return path;
}

function count(store: MemoryStore, sql: string, ...args: unknown[]): number {
  return (store.db.query(sql).get(...(args as never[])) as { n: number }).n;
}

describe("ingestLucien (P5-T1 bootstrap)", () => {
  const created: string[] = [];
  afterEach(() => {
    for (const p of created.splice(0)) {
      try { rmSync(p); rmSync(`${p}-wal`); rmSync(`${p}-shm`); } catch {}
    }
  });

  it("imports conversations/messages 1:1 with the source and re-points chunks to positions", async () => {
    const fixture = makeLucienFixture();
    created.push(fixture);
    const src = new Database(fixture, { readonly: true });
    const srcConvs = (src.query("SELECT COUNT(*) n FROM conversations").get() as { n: number }).n;
    const srcMsgs = (src.query("SELECT COUNT(*) n FROM messages").get() as { n: number }).n;
    src.close();

    const store = new MemoryStore(":memory:");
    const res = await ingestLucien(store, fixture);

    // Relative gate: ingested store counts equal the source's counts.
    expect(count(store, "SELECT COUNT(*) n FROM conversations")).toBe(srcConvs);
    expect(count(store, "SELECT COUNT(*) n FROM messages")).toBe(srcMsgs);
    expect(res.ingested).toBe(srcConvs);
    expect(res.messages).toBe(srcMsgs);

    // B9 column map: uuid→conv, name→title, source→source.
    const convA = store.db
      .query("SELECT conv, source, title, chunked_at FROM conversations WHERE conv = ?")
      .get("aaaa1111-0000-0000-0000-000000000000") as { conv: string; source: string; title: string; chunked_at: number | null };
    expect(convA.source).toBe("chatgpt");
    expect(convA.title).toBe("Lens chat");
    expect(convA.chunked_at).toBe(Date.parse("2025-02-01T00:00:00.000Z"));

    // sender→role preserved verbatim ("human" stays "human").
    const roleB0 = (store.db.query("SELECT role FROM messages WHERE uuid = ?").get("b-m0") as { role: string }).role;
    expect(roleB0).toBe("human");

    // Only the resolvable chunk survives; its id is the position-derived id and
    // Lucien's integer id is discarded; the broken span is dropped.
    expect(res.chunks).toBe(1);
    expect(count(store, "SELECT COUNT(*) n FROM chunks")).toBe(1);
    const wantId = chunkId("aaaa1111-0000-0000-0000-000000000000", 0, 2);
    const chunk = store.db.query("SELECT id, start, end, label FROM chunks").get() as {
      id: string; start: number; end: number; label: string;
    };
    expect(chunk.id).toBe(wantId);
    expect(chunk.start).toBe(0);
    expect(chunk.end).toBe(2);
    expect(chunk.label).toBe("L-Mount intro");
    // pointer reassembly works on the imported messages.
    expect(store.chunkText(wantId)).toBe(
      "tell me about the L-Mount\nthe L-Mount is an alliance\nand the S5IIX?",
    );

    store.close();
  });

  it("is a watermark no-op on re-run", async () => {
    const fixture = makeLucienFixture();
    created.push(fixture);
    const store = new MemoryStore(":memory:");

    const first = await ingestLucien(store, fixture);
    expect(first.ingested).toBeGreaterThan(0);
    const convsAfter = count(store, "SELECT COUNT(*) n FROM conversations");
    const msgsAfter = count(store, "SELECT COUNT(*) n FROM messages");

    const second = await ingestLucien(store, fixture);
    // Nothing new past the watermark.
    expect(second.ingested).toBe(0);
    expect(second.messages).toBe(0);
    expect(second.chunks).toBe(0);
    // Store counts unchanged → genuinely idempotent.
    expect(count(store, "SELECT COUNT(*) n FROM conversations")).toBe(convsAfter);
    expect(count(store, "SELECT COUNT(*) n FROM messages")).toBe(msgsAfter);

    store.close();
  });

  it("ingests a newly-appended conversation on a later run (per-source watermark advances)", async () => {
    const fixture = makeLucienFixture();
    created.push(fixture);
    const store = new MemoryStore(":memory:");
    await ingestLucien(store, fixture);

    // Append a brand-new, newer chatgpt conversation to the source.
    const w = new Database(fixture);
    w.run("INSERT INTO conversations VALUES (?,?,?,?,?,?,?)", [
      "cccc3333-0000-0000-0000-000000000000", "Later chat", "", "2025-06-01T00:00:00.000Z",
      "2025-06-01T00:00:00.000Z", 1, "chatgpt",
    ]);
    w.run("INSERT INTO messages VALUES (?,?,?,?,?,?,?)", ["c-m0", "cccc3333-0000-0000-0000-000000000000", 0, "user", "fresh", "", null]);
    w.close();

    const res = await ingestLucien(store, fixture);
    expect(res.ingested).toBe(1);
    expect(res.messages).toBe(1);
    expect(count(store, "SELECT COUNT(*) n FROM conversations WHERE conv = 'cccc3333-0000-0000-0000-000000000000'")).toBe(1);

    store.close();
  });
});
