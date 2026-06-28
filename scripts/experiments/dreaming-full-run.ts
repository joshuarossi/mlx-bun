// Full-corpus Dreaming run — resumable, chronological, detached-friendly.
//
// Processes EVERY conversation (oldest→newest by updated_at) through the staged
// pipeline with OUR chunker: clean slate once, then runPipeline over chronological
// conv-batches. Resumable via a cursor file + the pipeline's internal stage
// resumability (segment skips chunked, extract skips extracted, synth skips the
// ledger). Writes into a DEDICATED vault (wiki-full), never the real ~/.mlx-bun/wiki.
//
//   nohup bun scripts/experiments/dreaming-full-run.ts > ~/.mlx-bun/full-run.log 2>&1 & disown
//
// Re-launching after an interruption continues from the cursor.

import { existsSync } from "node:fs";
import { MemoryStore } from "../../src/memory/db";
import { runPipeline } from "../../src/memory/pipeline";
import { setupVault } from "../../src/memory/vault";

const HOME = process.env.HOME!;
const VAULT = `${HOME}/.mlx-bun/wiki-full`;
process.env.MLX_BUN_WIKI = VAULT;
const CURSOR = `${HOME}/.mlx-bun/full-run-cursor.txt`;
const INIT = `${HOME}/.mlx-bun/full-run-initialized`;
const BATCH = 20;

const stamp = () => new Date().toISOString().slice(11, 19);
const log = (m: string) => console.log(`[${stamp()}] ${m}`);

const store = new MemoryStore();

// One-time CLEAN SLATE: drop the mixed (Lucien + partial-ours) chunk state so OUR
// chunker re-segments the whole corpus fresh. conversations/messages are kept.
if (!existsSync(INIT)) {
  store.db.query("DELETE FROM chunk_entities").run();
  store.db.query("DELETE FROM chunks").run();
  store.db.query("DELETE FROM chunk_sections").run();
  store.db.query("DELETE FROM synthesized_chunk_sections").run();
  store.db.query("DELETE FROM entities WHERE article_stem IS NULL").run();
  store.db.query("DELETE FROM chunk_buckets").run();
  store.db.query("UPDATE conversations SET chunked_at = NULL").run();
  await setupVault(VAULT);
  await Bun.write(INIT, "1");
  log("CLEAN SLATE: cleared chunks/extractions/ledgers, reset chunked_at, fresh wiki-full vault");
}

const convs = (store.db.query("SELECT conv FROM conversations ORDER BY updated_at ASC").all() as { conv: string }[]).map((r) => r.conv);
let cursor = existsSync(CURSOR) ? parseInt((await Bun.file(CURSOR).text()).trim(), 10) || 0 : 0;
log(`FULL RUN: ${convs.length} conversations, batch=${BATCH}, resuming at index ${cursor}`);

const tStart = Date.now();
for (let i = cursor; i < convs.length; i += BATCH) {
  const batch = convs.slice(i, i + BATCH);
  const t0 = Date.now();
  try {
    const res = await runPipeline(store, { convIds: batch, root: VAULT, articleCap: 1000 });
    const arts = (store.db.query("SELECT COUNT(*) c FROM entities WHERE article_stem IS NOT NULL").get() as { c: number }).c;
    const secs = ((Date.now() - t0) / 1000).toFixed(0);
    const pct = (((i + batch.length) / convs.length) * 100).toFixed(1);
    log(`batch ${i}-${i + batch.length} (${pct}%) ${secs}s · created=${res.created.length} captured=${res.captured.length} · TOTAL articles=${arts}`);
  } catch (e) {
    log(`batch ${i} ERROR: ${String(e)}`);
  }
  await Bun.write(CURSOR, String(i + BATCH));
}

const mins = ((Date.now() - tStart) / 60000).toFixed(1);
const finalArts = (store.db.query("SELECT COUNT(*) c FROM entities WHERE article_stem IS NOT NULL").get() as { c: number }).c;
log(`FULL RUN COMPLETE in ${mins}min · ${finalArts} articles in ${VAULT}`);
store.close();
