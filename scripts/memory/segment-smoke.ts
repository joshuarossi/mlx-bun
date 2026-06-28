// P5-T2 · SEGMENT end-to-end smoke (real e4b chunk adapter).
//
// Proves the SEGMENT path works at the validated Gemma-4-e4b chunk adapter:
// pick N already-bootstrapped Lucien conversations, clear their chunked_at, run
// chunkConversations over JUST those, and report the valid-JSON rate + chunks
// produced. Then run a SECOND time with nothing cleared to prove the watermark
// makes a re-run a no-op.
//
// Single model load (the chunk adapter). Gate: ≥95% valid JSON with in-range
// anchors. This is the wiring proof, NOT the offline purity/cohesion eval
// (that's scripts/chunk-eval.ts with ADAPTER=…/e4b-chunk-300).
//
//   bun scripts/memory/segment-smoke.ts [N]

import { MemoryStore } from "../../src/memory/db";
import { chunkConversations } from "../../src/memory/chunk";
import { setupVault } from "../../src/memory/vault";

const N = Number(process.argv[2] ?? 10);

async function main() {
  // Ensure the vault Meta/ policy pages exist (loadMetaPolicy reads them).
  await setupVault();

  const store = new MemoryStore();

  // Deterministically pick N chunkable, already-chunked Lucien conversations:
  // has an assistant turn, a modest message count (fast, multi-chunk-capable),
  // ordered by conv id for reproducibility.
  const picks = store.db
    .query(
      `SELECT c.conv,
              (SELECT COUNT(*) FROM messages m WHERE m.conv = c.conv) AS nmsg
         FROM conversations c
        WHERE c.chunked_at IS NOT NULL
          AND (SELECT COUNT(*) FROM messages m WHERE m.conv = c.conv AND m.role = 'assistant') > 0
          AND (SELECT COUNT(*) FROM messages m WHERE m.conv = c.conv) BETWEEN 6 AND 16
        ORDER BY c.conv ASC
        LIMIT ?`,
    )
    .all(N) as { conv: string; nmsg: number }[];

  const convIds = picks.map((p) => p.conv);
  console.log(`picked ${convIds.length} conversations to (re)segment:`);
  for (const p of picks) console.log(`  ${p.conv}  (${p.nmsg} msgs)`);

  // Clear chunked_at so they become eligible.
  const clear = store.db.query("UPDATE conversations SET chunked_at = NULL WHERE conv = ?");
  const tx = store.db.transaction(() => {
    for (const id of convIds) clear.run(id);
  });
  tx();

  console.log("\n=== RUN 1 (segment) ===");
  const r1 = await chunkConversations(store, { convs: convIds }, (e) => console.log(`  ${e.message}`));

  const validJsonRate = r1.attempted > 0 ? r1.valid / r1.attempted : 0;
  console.log("\n=== RUN 1 result ===");
  console.log(JSON.stringify(r1, null, 2));
  console.log(`validJsonRate = ${r1.valid}/${r1.attempted} = ${(validJsonRate * 100).toFixed(1)}%`);

  // Verify chunks are stored as pointers and resolve back to text.
  let pointerOk = true;
  let totalRows = 0;
  for (const id of convIds) {
    const rows = store.db
      .query("SELECT id, start, end FROM chunks WHERE conv = ? ORDER BY start")
      .all(id) as { id: string; start: number; end: number }[];
    totalRows += rows.length;
    for (const row of rows) {
      const text = store.chunkText(row.id);
      const inRange = row.start <= row.end && text.length > 0;
      if (!inRange) {
        pointerOk = false;
        console.log(`  BAD pointer ${row.id}: start=${row.start} end=${row.end} textLen=${text.length}`);
      }
    }
  }
  console.log(`pointer rows: ${totalRows}, all resolve to text: ${pointerOk}`);

  console.log("\n=== RUN 2 (re-run, expect no-op) ===");
  const r2 = await chunkConversations(store, { convs: convIds }, (e) => console.log(`  ${e.message}`));
  const noop = r2.conversations === 0 && r2.attempted === 0 && r2.chunks === 0;
  console.log(`re-run no-op: ${noop} (conversations=${r2.conversations}, attempted=${r2.attempted})`);

  console.log("\n=== SMOKE SUMMARY ===");
  console.log(
    JSON.stringify(
      {
        convsSegmented: r1.valid,
        attempted: r1.attempted,
        validJsonRate: Number(validJsonRate.toFixed(4)),
        chunksProduced: r1.chunks,
        pointerOk,
        rerunNoop: noop,
        gateMet: validJsonRate >= 0.95 && pointerOk && noop,
      },
      null,
      2,
    ),
  );

  store.close();
}

await main();
