// One-off: drive OUR chunker + the full Dreaming pipeline over a selected slice
// of the PROD memory DB into a fresh slice vault. This is the real E2E test of
// the segment-stage wiring (our e4b-chunk-300 / `memory-chunk` adapter does the
// segmentation — Lucien chunks are replaced).
//
// Usage:
//   MLX_BUN_WIKI=<vault> bun scripts/experiments/dreaming-slice-run.ts \
//       --convs <slice.json> [--ids id1,id2] [--limit N] [--cap M]
//
// Resets chunked_at=NULL for the in-scope convs so OUR chunker re-segments them,
// then runPipeline(segment → extract → route → create). DB writes + vault files
// persist per-step; safe to interrupt + resume (segment no-ops on re-run).

import { MemoryStore } from "../../src/memory/db";
import { runPipeline, type SynthesisEvent } from "../../src/memory/pipeline";
import { setupVault } from "../../src/memory/vault";

function arg(name: string): string | undefined {
  const i = process.argv.indexOf(`--${name}`);
  return i >= 0 ? process.argv[i + 1] : undefined;
}

const vault = process.env.MLX_BUN_WIKI;
if (!vault) throw new Error("set MLX_BUN_WIKI to the slice vault path");

const convsFile = arg("convs");
const idsArg = arg("ids");
const limit = arg("limit") ? parseInt(arg("limit")!, 10) : undefined;
const cap = arg("cap") ? parseInt(arg("cap")!, 10) : 500;

let convIds: string[];
if (idsArg) {
  convIds = idsArg.split(",").map((s) => s.trim()).filter(Boolean);
} else if (convsFile) {
  const j = JSON.parse(await Bun.file(convsFile).text()) as { convIds: string[] };
  convIds = j.convIds;
} else {
  throw new Error("pass --ids or --convs");
}
if (limit !== undefined) convIds = convIds.slice(0, limit);

const t0 = Date.now();
const el = () => ((Date.now() - t0) / 1000).toFixed(1).padStart(7);
const log = (m: string) => console.log(`[${el()}s] ${m}`);

log(`slice run: ${convIds.length} convs → vault ${vault} (cap ${cap})`);

// Fresh slice vault (Meta pages, git). MLX_BUN_WIKI is already this path so the
// segment + extract stages inline the slice vault's Meta policy pages.
await setupVault(vault);
log(`vault ready`);

const store = new MemoryStore();

// Reset the watermark so OUR chunker re-segments these convs (replacing any
// pre-existing — e.g. Lucien — chunk rows).
const placeholders = convIds.map(() => "?").join(",");
// Resegment only when asked (--reset). On a plain re-run we RESUME: segment skips
// already-chunked convs and extract skips already-extracted chunks, so the run
// continues instead of repeating the ~15s/conv segmentation.
if (process.argv.includes("--reset")) {
  const before = store.db
    .query(`SELECT COUNT(*) n FROM conversations WHERE conv IN (${placeholders})`)
    .get(...convIds) as { n: number };
  store.db
    .query(`UPDATE conversations SET chunked_at = NULL WHERE conv IN (${placeholders})`)
    .run(...convIds);
  log(`reset chunked_at=NULL for ${before.n}/${convIds.length} convs present in DB`);
} else {
  log(`resume mode: keeping existing segmentation/extraction (pass --reset to resegment)`);
}

const counts = { segMsgs: 0 };
const onEvent = (e: SynthesisEvent) => {
  if (e.type === "stage" || e.type === "done") log(`${e.stage ?? e.type}: ${e.message}`);
  else if (/extracted \d+\/|created |patched |segment:|repair:|skipped /.test(e.message)) log(`  ${e.message}`);
};

let result;
try {
  result = await runPipeline(store, { convIds, root: vault, articleCap: cap, onEvent });
} catch (err) {
  log(`PIPELINE ERROR: ${String(err)}`);
  throw err;
} finally {
  // Snapshot durable DB progress regardless of completion.
  const chunks = store.db.query(`SELECT COUNT(*) n FROM chunks WHERE conv IN (${placeholders})`).get(...convIds) as { n: number };
  const segConvs = store.db.query(`SELECT COUNT(*) n FROM conversations WHERE chunked_at IS NOT NULL AND conv IN (${placeholders})`).get(...convIds) as { n: number };
  const ces = store.db.query(`SELECT COUNT(DISTINCT chunk_id) n FROM chunk_entities WHERE chunk_id IN (SELECT id FROM chunks WHERE conv IN (${placeholders}))`).get(...convIds) as { n: number };
  log(`DB SNAPSHOT: chunks=${chunks.n} segmentedConvs=${segConvs.n} chunksWithEntities=${ces.n}`);
}

log(`RESULT: convs=${result.convs} chunks=${result.chunks} entities=${result.entities} created=${result.created.length} patched=${result.patched.length} gated=${result.skippedByGate.length} captured=${result.captured.length}`);
log(`created stems: ${result.created.map((c) => c.stem).join(", ")}`);

await Bun.write(
  arg("out") ?? "/tmp/dreaming-slice-result.json",
  JSON.stringify({ elapsedS: (Date.now() - t0) / 1000, convCount: convIds.length, result }, null, 2),
);
store.close();
log(`done`);
