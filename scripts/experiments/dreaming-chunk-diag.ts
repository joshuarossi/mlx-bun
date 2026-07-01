// One-off diagnostic (moved from repo-root _diag.ts): inspect the next unchunked
// conversations in the wiki-full import DB and re-run segment on 5 of them.
process.env.MLX_BUN_WIKI = `${process.env.HOME}/.mlx-bun/wiki-full`;
import { MemoryStore } from "../../src/memory/db";
import { runSegmentStage } from "../../src/memory/stages";
const store = new MemoryStore();
// size of the next few unchunked convs
const next = store.db.query(
  "SELECT conv, length(updated_at) FROM conversations WHERE chunked_at IS NULL ORDER BY updated_at ASC LIMIT 5"
).all() as {conv:string}[];
for (const c of next) {
  const msgs = (store.db.query("SELECT COUNT(*) c FROM messages WHERE conv=?").get(c.conv) as {c:number}).c;
  console.log(`conv ${c.conv.slice(0,8)} · ${msgs} msgs`);
}
console.log("\n--- segmenting 5 (corrected path) ---");
const r = await runSegmentStage(store, { limit: 5, onEvent: (e:any)=>{ if(/error|skip|invalid|empty|chunk/i.test(e.message||"")) console.log("  "+e.message); } });
console.log(`\nRESULT: conversations=${r.conversations} attempted=${r.attempted} valid=${r.valid} skipped=${r.skipped} errored=${r.errored} chunks=${r.chunks}`);
store.close();
