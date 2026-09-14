/** Summarize P2R records captured by bench-serve without loading a model.
 * bun scripts/bench/prefill-trace.ts report.md.json --out breakdown.json */
import { readFileSync, writeFileSync } from "node:fs";
import type { CellResult } from "../bench-serve";
import type { P2RTraceEvent } from "../../src/serve/prompt-response-trace";

export function summarizePrefillTraces(cells: Pick<CellResult, "cell" | "promptResponseTraces">[]) {
  return cells.map(cell => {
    const work = new Map<string, { pid: number; phase: string; workId: number; batchSize: number;
      startMs: number; endMs: number; requests: string[] }>();
    const requests = (cell.promptResponseTraces ?? []).map(({ pid, record }) => {
      const durationByPhase: Record<string, number> = {};
      const phase = (name: string) => record.events.find(event => event.phase === name);
      const end = (event?: P2RTraceEvent) => event ? event.startMs + event.durationMs : null;
      for (const event of record.events) {
        durationByPhase[event.phase] = (durationByPhase[event.phase] ?? 0) + event.durationMs;
        const workId = event.attributes?.workId;
        if (typeof workId !== "number" || record.startedAtMs === undefined) continue;
        // Row-local checkpoint/completion spans are distinct within shared work.
        const key = `${pid}:${workId}:${event.phase}:${event.attributes?.row ?? "group"}`;
        const startMs = record.startedAtMs + event.startMs, endMs = startMs + event.durationMs;
        const existing = work.get(key);
        if (existing) {
          existing.startMs = Math.min(existing.startMs, startMs);
          existing.endMs = Math.max(existing.endMs, endMs);
          existing.requests.push(record.requestId);
        } else work.set(key, { pid, phase: event.phase, workId,
          batchSize: Number(event.attributes?.batchSize ?? 1), startMs, endMs, requests: [record.requestId] });
      }
      const ready = end(phase("token_zero.total")), write = phase("response.first_write")?.startMs ?? null;
      return { pid, requestId: record.requestId, traceId: record.traceId, outcome: record.outcome,
        startedAtMs: record.startedAtMs ?? null, totalMs: record.totalMs,
        promptTokens: phase("prefill.total")?.attributes?.promptTokens ?? null,
        cachedTokens: phase("prefill.total")?.attributes?.cachedTokens ?? null,
        firstWriteMs: write, tokenZeroReadyMs: ready,
        readyToWriteMs: ready !== null && write !== null ? write - ready : null, durationByPhase };
    });
    return { cell: cell.cell, requests, work: [...work.values()].sort((a, b) => a.pid - b.pid || a.startMs - b.startMs) };
  });
}

if (import.meta.main) {
  const input = process.argv[2];
  if (!input) throw new Error("usage: prefill-trace.ts report.md.json [--out breakdown.json]");
  const report = JSON.parse(readFileSync(input, "utf8"));
  const result = { input,
    timing: "Observed wall spans without added synchronization. Forward may include backend evaluation; evaluate is the remaining wait. Nested phases are not additive. Shared work is deduplicated within each process; clocks across PIDs are unrelated.",
    cells: summarizePrefillTraces(report.results) };
  const outputIndex = process.argv.indexOf("--out"), json = JSON.stringify(result, null, 2);
  if (outputIndex >= 0) writeFileSync(process.argv[outputIndex + 1]!, json + "\n");
  else console.log(json);
}
