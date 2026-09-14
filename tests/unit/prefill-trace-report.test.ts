import { expect, test } from "bun:test";
import { summarizePrefillTraces } from "../../scripts/bench/prefill-trace";
import type { P2RTraceRecord } from "../../src/serve/prompt-response-trace";

test("trace report aligns requests and deduplicates shared work only within its process", () => {
  const record = (requestId: string, origin: number): P2RTraceRecord => ({
    version: 1, requestId, traceId: requestId, route: "test", clock: "monotonic-ms",
    outcome: "success", totalMs: 100, startedAtMs: origin, events: [
      { phase: "prefill.forward", startMs: 20 - origin, durationMs: 30, attributes: { workId: 1, batchSize: 2 } },
      { phase: "token_zero.total", startMs: 50, durationMs: 10 },
      { phase: "response.first_write", startMs: 80, durationMs: 0 },
    ],
  });
  const [result] = summarizePrefillTraces([{ cell: { model: "local", arm: "mlx-bun" },
    promptResponseTraces: [{ pid: 1, record: record("a", 0) }, { pid: 1, record: record("b", 10) },
      { pid: 2, record: record("c", 0) }] }]);
  expect(result!.work).toHaveLength(2);
  expect(result!.work[0]).toMatchObject({ startMs: 20, endMs: 50, requests: ["a", "b"] });
  expect(result!.requests[0]!.readyToWriteMs).toBe(20);
  expect(result!.requests[1]!.durationByPhase["prefill.forward"]).toBe(30);
});
