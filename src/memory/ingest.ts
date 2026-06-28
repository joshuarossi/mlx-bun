// mlx-bun memory — synthesis stage 1: INGEST. (P5-T1)
//
// Two sources feed the synthesis ledger, both watermark-gated per `source`:
//
//   • pi sessions — SessionManager.listAll() walks every on-disk pi session
//     (the same JSONL store pi-web / pi-terminal write). Each becomes a
//     conversation; its resolved messages become `messages` rows. This is the
//     steady-state, "synthesize my own sessions" path.
//
//   • the Lucien bootstrap — a one-time import of the read-only Lucien corpus
//     (`~/Code/lucien/.lucien/lucien.db`) so the vault starts from a real body
//     of prior conversations. Lucien's column names differ (B9 mapping below);
//     critically we also REUSE Lucien's existing `chunks` by re-pointing each
//     UUID span to mlx-bun `(start,end)` positions, so SEGMENT (P5-T2) only has
//     to run on conversations Lucien never chunked.
//
// Everything is idempotent. Each source carries a watermark (max conversation
// `updated_at`, as epoch-ms); a re-run only looks at conversations newer than
// the cursor, and even a conversation that IS re-touched is rewritten in place
// (delete-then-insert its messages/chunks), so re-ingesting changes nothing.
//
// Lucien → mlx-bun column map (B9):
//   conversations.uuid→conv, name→title, source→source, updated_at→updated_at
//   messages.conversation_uuid→conv, position→position, sender→role,
//            uuid→uuid, text→text
//   chunks.start_message_uuid/end_message_uuid → messages.position (per conv)
//            → chunks.start/.end; id = `${conv}:${start}-${end}` (Lucien's
//            INTEGER chunk id is discarded). chunked_at from
//            chunked_conversations.chunked_at where present.

import { Database } from "bun:sqlite";
import { SessionManager } from "@earendil-works/pi-coding-agent";
import { MemoryStore, chunkId } from "./db";
import type { SynthesisEvent } from "./pipeline";

/** Default read-only Lucien source DB for the bootstrap import. */
export const DEFAULT_LUCIEN_DB = `${process.env.HOME}/Code/lucien/.lucien/lucien.db`;

export interface IngestResult {
  /** Conversations examined this run (across every source). */
  scanned: number;
  /** Conversations written/refreshed this run (past the watermark). */
  ingested: number;
  /** Message rows written this run. */
  messages: number;
  /** Chunk-pointer rows written this run (Lucien bootstrap only). */
  chunks: number;
}

function emptyResult(): IngestResult {
  return { scanned: 0, ingested: 0, messages: 0, chunks: 0 };
}

/** Parse an ISO-8601 / Date string to epoch-ms; 0 when unparseable. */
function toEpoch(value: string | number | null | undefined): number {
  if (value == null) return 0;
  if (typeof value === "number") return Number.isFinite(value) ? value : 0;
  const t = Date.parse(value);
  return Number.isFinite(t) ? t : 0;
}

/** Read a source's watermark cursor as epoch-ms (0 when none). */
function readWatermark(store: MemoryStore, source: string): number {
  const row = store.db
    .query("SELECT cursor FROM watermarks WHERE source = ?")
    .get(source) as { cursor: string | null } | null;
  // cursor is stored as an epoch-ms numeric string (see writeWatermark).
  const n = row ? Number(row.cursor) : 0;
  return Number.isFinite(n) ? n : 0;
}

/** Advance a source's watermark to `cursorEpoch` (epoch-ms, stored as text). */
function writeWatermark(store: MemoryStore, source: string, cursorEpoch: number): void {
  store.db.run(
    `INSERT INTO watermarks (source, cursor, updated_at) VALUES (?, ?, ?)
       ON CONFLICT(source) DO UPDATE SET cursor = excluded.cursor, updated_at = excluded.updated_at`,
    [source, String(cursorEpoch), Date.now()],
  );
}

/** Upsert one conversation header. */
function upsertConversation(
  store: MemoryStore,
  conv: string,
  source: string,
  title: string,
  updatedAt: number,
  chunkedAt: number | null,
): void {
  store.db.run(
    `INSERT INTO conversations (conv, source, title, updated_at, chunked_at) VALUES (?, ?, ?, ?, ?)
       ON CONFLICT(conv) DO UPDATE SET
         source = excluded.source, title = excluded.title,
         updated_at = excluded.updated_at, chunked_at = excluded.chunked_at`,
    [conv, source, title, updatedAt, chunkedAt],
  );
}

/**
 * Replace a conversation's messages with `rows` (delete-then-insert, so a
 * re-ingested conversation ends up with exactly its current message set).
 * Returns the number of message rows written.
 */
function replaceMessages(
  store: MemoryStore,
  conv: string,
  rows: { position: number; role: string; uuid: string; text: string }[],
): number {
  store.db.run("DELETE FROM messages WHERE conv = ?", [conv]);
  const ins = store.db.query(
    "INSERT INTO messages (conv, position, role, uuid, text) VALUES (?, ?, ?, ?, ?)",
  );
  for (const r of rows) ins.run(conv, r.position, r.role, r.uuid, r.text);
  return rows.length;
}

// ───────────────────────────── pi sessions ──────────────────────────────────

/** First 8 lowercase hex digits of a session UUID — the conv:HASH citation id. */
function convIdFromSessionId(id: string): string {
  const hex = id.replace(/[^0-9a-fA-F]/g, "").toLowerCase();
  return hex.slice(0, 8) || id.slice(0, 8);
}

/** Flatten a pi message's content to plain text (text parts only). */
function piMessageText(content: unknown): string {
  if (typeof content === "string") return content;
  if (!Array.isArray(content)) return "";
  const parts: string[] = [];
  for (const part of content as { type?: string; text?: string }[]) {
    if (part && part.type === "text" && typeof part.text === "string") parts.push(part.text);
  }
  return parts.join("\n");
}

/**
 * Ingest pi sessions (every on-disk session SessionManager.listAll() finds)
 * into the store under source "pi", watermark-gated by session modified time.
 */
export async function ingestSessions(
  store: MemoryStore,
  onEvent?: (e: SynthesisEvent) => void,
): Promise<IngestResult> {
  const result = emptyResult();
  const source = "pi";
  let infos: Awaited<ReturnType<typeof SessionManager.listAll>>;
  try {
    infos = await SessionManager.listAll();
  } catch (err) {
    onEvent?.({ type: "log", stage: "ingest", message: `pi sessions: none readable (${String(err)})` });
    return result;
  }

  const cursor = readWatermark(store, source);
  let maxEpoch = cursor;

  for (const info of infos) {
    result.scanned++;
    const updatedAt = info.modified instanceof Date ? info.modified.getTime() : toEpoch(info.modified as never);
    if (updatedAt <= cursor) continue;

    let messages: { role: string; content: unknown }[] = [];
    try {
      const mgr = SessionManager.open(info.path);
      messages = mgr.buildSessionContext().messages as { role: string; content: unknown }[];
    } catch (err) {
      onEvent?.({ type: "log", stage: "ingest", message: `skip session ${info.id}: ${String(err)}` });
      continue;
    }

    const conv = convIdFromSessionId(info.id);
    const rows: { position: number; role: string; uuid: string; text: string }[] = [];
    let pos = 0;
    for (const m of messages) {
      if (m.role !== "user" && m.role !== "assistant") continue; // drop tool-result/system noise
      const text = piMessageText(m.content);
      if (text.trim() === "") continue;
      rows.push({ position: pos, role: m.role, uuid: `${conv}-${pos}`, text });
      pos++;
    }
    if (rows.length === 0) continue;

    const title = info.name?.trim() || info.firstMessage?.trim() || conv;
    const tx = store.db.transaction(() => {
      upsertConversation(store, conv, source, title, updatedAt, null);
      result.messages += replaceMessages(store, conv, rows);
    });
    tx();
    result.ingested++;
    if (updatedAt > maxEpoch) maxEpoch = updatedAt;
  }

  if (maxEpoch > cursor) writeWatermark(store, source, maxEpoch);
  onEvent?.({
    type: "log",
    stage: "ingest",
    message: `pi sessions: scanned ${result.scanned}, ingested ${result.ingested} (${result.messages} messages)`,
  });
  return result;
}

// ──────────────────────────── Lucien bootstrap ──────────────────────────────

interface LucienConv {
  uuid: string;
  name: string | null;
  source: string;
  updated_at: string | null;
  created_at: string | null;
}
interface LucienMsg {
  uuid: string;
  position: number;
  sender: string;
  text: string | null;
}
interface LucienChunk {
  start_message_uuid: string;
  end_message_uuid: string;
  label: string | null;
}

/**
 * One-time bootstrap import of the read-only Lucien corpus. Watermark-gated per
 * Lucien `source` (chatgpt / claude-ai / …) so a re-run is a no-op. Reuses
 * Lucien's existing chunks as mlx-bun chunk pointers (UUID span → positions).
 */
export async function ingestLucien(
  store: MemoryStore,
  dbPath: string = DEFAULT_LUCIEN_DB,
  onEvent?: (e: SynthesisEvent) => void,
): Promise<IngestResult> {
  const result = emptyResult();
  const src = new Database(dbPath, { readonly: true });
  try {
    // Map each conversation to its (optional) chunked_at epoch up front.
    const chunkedAt = new Map<string, number>();
    for (const row of src
      .query("SELECT conversation_uuid AS conv, chunked_at FROM chunked_conversations")
      .all() as { conv: string; chunked_at: string | null }[]) {
      chunkedAt.set(row.conv, toEpoch(row.chunked_at));
    }

    const sources = (
      src.query("SELECT DISTINCT source FROM conversations WHERE source IS NOT NULL").all() as {
        source: string;
      }[]
    ).map((r) => r.source);

    const convsBySource = src.query(
      "SELECT uuid, name, source, updated_at, created_at FROM conversations WHERE source = ?",
    );
    const msgsByConv = src.query(
      "SELECT uuid, position, sender, text FROM messages WHERE conversation_uuid = ? ORDER BY position, uuid",
    );
    const chunksByConv = src.query(
      "SELECT start_message_uuid, end_message_uuid, label FROM chunks WHERE conversation_uuid = ?",
    );

    for (const source of sources) {
      const cursor = readWatermark(store, source);
      let maxEpoch = cursor;
      const convs = convsBySource.all(source) as LucienConv[];

      const pending: { conv: LucienConv; epoch: number }[] = [];
      for (const conv of convs) {
        result.scanned++;
        const epoch = toEpoch(conv.updated_at) || toEpoch(conv.created_at);
        if (epoch <= cursor) continue;
        pending.push({ conv, epoch });
        if (epoch > maxEpoch) maxEpoch = epoch;
      }

      const tx = store.db.transaction(() => {
        for (const { conv, epoch } of pending) {
          const id = conv.uuid; // B9: conversations.uuid → conv (full uuid)
          const msgs = msgsByConv.all(id) as LucienMsg[];

          // Renumber positions densely (0..n-1) in source order. Lucien keys
          // messages by uuid, so a branched conversation can repeat a position;
          // mlx-bun's (conv,position) PK requires uniqueness. Order is preserved,
          // so chunk spans (resolved via this same map) stay contiguous.
          const posByUuid = new Map<string, number>();
          const rows = msgs.map((m, i) => {
            posByUuid.set(m.uuid, i);
            return { position: i, role: m.sender, uuid: m.uuid, text: m.text ?? "" };
          });

          upsertConversation(
            store,
            id,
            conv.source,
            conv.name ?? "",
            epoch,
            chunkedAt.get(id) ?? null,
          );
          result.messages += replaceMessages(store, id, rows);

          // Re-point Lucien's chunks to mlx-bun positions, discarding its int id.
          store.db.run("DELETE FROM chunks WHERE conv = ?", [id]);
          const insChunk = store.db.query(
            "INSERT OR IGNORE INTO chunks (id, conv, start, end, label) VALUES (?, ?, ?, ?, ?)",
          );
          for (const c of chunksByConv.all(id) as LucienChunk[]) {
            const start = posByUuid.get(c.start_message_uuid);
            const end = posByUuid.get(c.end_message_uuid);
            if (start === undefined || end === undefined) continue; // unresolvable span
            const lo = Math.min(start, end);
            const hi = Math.max(start, end);
            const info = insChunk.run(chunkId(id, lo, hi), id, lo, hi, c.label);
            result.chunks += info.changes; // count only rows actually inserted
          }
          result.ingested++;
        }
        if (maxEpoch > cursor) writeWatermark(store, source, maxEpoch);
      });
      tx();

      onEvent?.({
        type: "log",
        stage: "ingest",
        message: `lucien[${source}]: ${pending.length} new conversations`,
      });
    }
  } finally {
    src.close();
  }

  onEvent?.({
    type: "log",
    stage: "ingest",
    message: `lucien bootstrap: scanned ${result.scanned}, ingested ${result.ingested} (${result.messages} messages, ${result.chunks} chunks)`,
  });
  return result;
}
