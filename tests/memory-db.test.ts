// P0-T3 — pointer+entity MemoryStore schema.

import { describe, expect, it } from "bun:test";
import { Database } from "bun:sqlite";
import { MemoryStore, chunkId } from "../src/memory/db";

function byteLen(s: string): number {
  return Buffer.byteLength(s, "utf8");
}

describe("MemoryStore schema", () => {
  it("nukes a legacy DB (chunks.text / synthesized_bucket_chunks) and recreates cleanly", () => {
    const path = `/private/tmp/claude-501/-Users-joshrossi-Code-mlx-bun/legacy-${Date.now()}.sqlite`;
    const seed = new Database(path);
    seed.exec(`CREATE TABLE conversations (conv TEXT PRIMARY KEY, transcript TEXT)`);
    seed.exec(`CREATE TABLE chunks (id TEXT PRIMARY KEY, conv TEXT, ordinal INTEGER, text TEXT, bucket TEXT)`);
    seed.exec(`INSERT INTO chunks VALUES ('old', 'c0', 0, 'legacy body', 'b')`);
    seed.exec(`CREATE TABLE synthesized_bucket_chunks (bucket TEXT, chunk_id TEXT, PRIMARY KEY (bucket, chunk_id))`);
    seed.close();

    const store = new MemoryStore(path);
    const cols = store.db.query("PRAGMA table_info(chunks)").all() as { name: string }[];
    expect(cols.some((c) => c.name === "text")).toBe(false);
    expect(cols.some((c) => c.name === "bucket")).toBe(false);
    expect(cols.some((c) => c.name === "start")).toBe(true);
    expect(cols.some((c) => c.name === "end")).toBe(true);
    expect(store.db.query("SELECT name FROM sqlite_master WHERE name='synthesized_bucket_chunks'").get()).toBeNull();
    expect(store.db.query("SELECT name FROM sqlite_master WHERE name='entities'").get()).not.toBeNull();
    expect(store.chunkText("old")).toBe(""); // legacy row gone
    store.close();
  });

  it("stores chunks as pointers — no text duplication, chunkText reassembles the slice", () => {
    const store = new MemoryStore(":memory:");
    const conv = "deadbeef";
    store.db.run("INSERT INTO conversations (conv, source, updated_at) VALUES (?, ?, ?)", [conv, "pi-web", 1]);

    const messages = [
      { role: "user", text: "hello there general" },
      { role: "assistant", text: "greetings, traveler" },
      { role: "user", text: "tell me about entities" },
      { role: "assistant", text: "an entity is a thing" },
      { role: "user", text: "and chunks?" },
      { role: "assistant", text: "chunks are ranges" },
    ];
    const ins = store.db.query("INSERT INTO messages (conv, position, role, uuid, text) VALUES (?, ?, ?, ?, ?)");
    messages.forEach((m, i) => ins.run(conv, i, m.role, `u${i}`, m.text));

    const insChunk = store.db.query("INSERT INTO chunks (id, conv, start, end, label) VALUES (?, ?, ?, ?, ?)");
    insChunk.run(chunkId(conv, 0, 2), conv, 0, 2, "intro");
    insChunk.run(chunkId(conv, 3, 5), conv, 3, 5, "explain");

    const totalMsgBytes = messages.reduce((n, m) => n + byteLen(m.text), 0);
    const storedMsgBytes = (
      store.db.query("SELECT text FROM messages").all() as { text: string }[]
    ).reduce((n, r) => n + byteLen(r.text), 0);
    // chunks carry no text column → the only text bytes are the messages, once.
    expect(storedMsgBytes).toBe(totalMsgBytes);
    const chunkCols = store.db.query("PRAGMA table_info(chunks)").all() as { name: string }[];
    expect(chunkCols.some((c) => c.name === "text")).toBe(false);

    expect(store.chunkText(chunkId(conv, 0, 2))).toBe(
      "hello there general\ngreetings, traveler\ntell me about entities",
    );
    expect(store.chunkText(chunkId(conv, 3, 5))).toBe(
      "an entity is a thing\nand chunks?\nchunks are ranges",
    );
    store.close();
  });

  it("cascades deletes from conversations to messages and chunks", () => {
    const store = new MemoryStore(":memory:");
    const conv = "cafef00d";
    store.db.run("INSERT INTO conversations (conv, source, updated_at) VALUES (?, ?, ?)", [conv, "pi-web", 1]);
    store.db.run("INSERT INTO messages (conv, position, role, uuid, text) VALUES (?, ?, ?, ?, ?)", [conv, 0, "user", "u0", "hi"]);
    store.db.run("INSERT INTO chunks (id, conv, start, end, label) VALUES (?, ?, ?, ?, ?)", [chunkId(conv, 0, 0), conv, 0, 0, null]);

    store.db.run("DELETE FROM conversations WHERE conv = ?", [conv]);
    expect((store.db.query("SELECT COUNT(*) n FROM conversations").get() as { n: number }).n).toBe(0);
    expect((store.db.query("SELECT COUNT(*) n FROM messages").get() as { n: number }).n).toBe(0);
    expect((store.db.query("SELECT COUNT(*) n FROM chunks").get() as { n: number }).n).toBe(0);
    store.close();
  });

  it("has foreign_keys enforcement on", () => {
    const store = new MemoryStore(":memory:");
    const fk = store.db.query("PRAGMA foreign_keys").get() as { foreign_keys: number };
    expect(fk.foreign_keys).toBe(1);
    store.close();
  });
});
