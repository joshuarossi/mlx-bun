import { describe, expect, test } from "bun:test";
import {
  createPromptResponseTrace,
  PromptResponseTrace,
  type P2RTraceRecord,
} from "../src/serve/prompt-response-trace";
import { configureRuntime } from "../src/runtime-config";

describe("PromptResponseTrace", () => {
  test("is absent when diagnostics are disabled", () => {
    const restore = configureRuntime({ MLX_BUN_P2R_TRACE: undefined });
    try {
      expect(createPromptResponseTrace({
        traceId: "trace-off",
        requestId: "request-off",
        route: "/v1/chat/completions",
      })).toBeUndefined();
    } finally {
      restore();
    }
  });

  test("records ordered spans and closes exactly once", () => {
    const ticks = [100, 102, 108, 110, 115, 120];
    const records: P2RTraceRecord[] = [];
    const trace = new PromptResponseTrace({
      traceId: "trace-1",
      requestId: "request-1",
      route: "/v1/completions",
      clock: () => ticks.shift()!,
      emit: (record) => records.push(record),
    });

    const closePrefill = trace.begin("prefill.total", { tokens: 1024 });
    closePrefill();
    closePrefill();
    trace.mark("response.first_write");
    const record = trace.finish("success", { generatedTokens: 1 });

    expect(record).toEqual({
      version: 1,
      traceId: "trace-1",
      requestId: "request-1",
      route: "/v1/completions",
      clock: "monotonic-ms",
      outcome: "success",
      totalMs: 15,
      events: [
        {
          phase: "prefill.total",
          startMs: 2,
          durationMs: 6,
          attributes: { tokens: 1024 },
        },
        { phase: "response.first_write", startMs: 10, durationMs: 0 },
      ],
      attributes: { generatedTokens: 1 },
    });
    expect(trace.finish("error")).toBeNull();
    expect(records).toEqual([record!]);
  });

  test("drops late span closures after an abort", () => {
    let tick = 0;
    const records: P2RTraceRecord[] = [];
    const trace = new PromptResponseTrace({
      traceId: "trace-abort",
      requestId: "request-abort",
      route: "/v1/chat/completions",
      clock: () => tick++,
      emit: (record) => records.push(record),
    });
    const close = trace.begin("engine.admission_wait");
    trace.finish("abort");
    close();
    expect(records[0]!.outcome).toBe("abort");
    expect(records[0]!.events).toEqual([]);
  });
});
