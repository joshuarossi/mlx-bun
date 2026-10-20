// The event-stream client over the fake EventSource: normal completion, the terminal event, named events, a
// dropped connection, cancellation through close() and an AbortSignal, and that nothing is delivered after either.
import { beforeEach, describe, expect, it } from "bun:test";
import { byType, openEventStream } from "../src";
import { FakeEventSource } from "../src/testing";

const options = { EventSource: FakeEventSource as unknown as typeof EventSource };
type JobEvent = { type: "log"; line: string } | { type: "stage"; progress: number } | { type: "done" } | { type: "failed"; error: string };

beforeEach(() => FakeEventSource.reset());

describe("openEventStream", () => {
  it("delivers parsed unnamed events in order and closes itself on the terminal event", () => {
    const seen: unknown[] = [];
    let ended = 0;
    const stream = openEventStream<JobEvent>("/api/jobs/j1/stream", { message: (event) => seen.push(event), end: () => ended++ }, options);
    const source = FakeEventSource.last("/api/jobs/j1/stream")!;
    source.open();
    source.emit({ type: "log", line: "a" });
    source.emit({ type: "stage", progress: 0.5 });
    source.emit({ type: "done" });
    expect(stream.closed).toBe(false);
    source.emit({}, "end");
    expect(stream.closed).toBe(true);
    expect(source.closed).toBe(true);
    expect(ended).toBe(1);
    source.emit({ type: "log", line: "late" }); // the fake drops events after close, as a browser does
    expect(seen).toEqual([{ type: "log", line: "a" }, { type: "stage", progress: 0.5 }, { type: "done" }]);
    expect(FakeEventSource.open).toEqual([]);
  });

  it("dispatches named events, keeps the stream open without a terminal event and reports a dropped connection", () => {
    const snapshots: unknown[] = [];
    let errors = 0;
    const stream = openEventStream("/api/metrics/stream", { events: { snapshot: (data) => snapshots.push(data) }, error: () => errors++ }, { ...options, endEvent: null });
    const source = FakeEventSource.last()!;
    source.emit({ at: 1 }, "snapshot");
    source.fail();
    source.emit({ at: 2 }, "snapshot"); // the browser reconnected
    expect(snapshots).toEqual([{ at: 1 }, { at: 2 }]);
    expect(errors).toBe(1);
    expect(stream.closed).toBe(false);
    stream.close();
    expect(source.closed).toBe(true);
    source.fail();
    expect(errors).toBe(1); // nothing after close
  });

  it("close() is idempotent and an AbortSignal closes the stream, before or after it opens", () => {
    const controller = new AbortController();
    const seen: unknown[] = [];
    const stream = openEventStream("/s", { message: (event) => seen.push(event) }, { ...options, signal: controller.signal });
    const source = FakeEventSource.last()!;
    controller.abort();
    expect(stream.closed).toBe(true);
    stream.close();
    source.emit({ type: "log" });
    expect(seen).toEqual([]);
    const aborted = new AbortController(); aborted.abort();
    const second = openEventStream("/t", {}, { ...options, signal: aborted.signal });
    expect(second.closed).toBe(true);
    expect(FakeEventSource.open).toEqual([]);
  });

  it("an unparseable frame arrives as an unparseable event instead of throwing", () => {
    const seen: unknown[] = [];
    openEventStream("/u", { message: (event) => seen.push(event) }, options);
    FakeEventSource.last()!.emit("not json {");
    expect(seen).toEqual([{ type: "unparseable", text: "not json {" }]);
  });

  it("byType routes typed events to their handlers and ignores the rest", () => {
    const log: string[] = [];
    const dispatch = byType<JobEvent>({ log: (event) => log.push(event.line), failed: (event) => log.push("failed:" + event.error) });
    dispatch({ type: "log", line: "x" }); dispatch({ type: "stage", progress: 1 }); dispatch({ type: "failed", error: "boom" });
    expect(log).toEqual(["x", "failed:boom"]);
  });
});
