import { expect, test } from "bun:test";
import { retainResponseLease } from "../../src/serve/response-lease";

test("response activity survives headers and releases exactly once at EOF or cancellation", async () => {
  for (const cancel of [false, true]) {
    let released = 0;
    let source!: ReadableStreamDefaultController<Uint8Array>;
    const response = retainResponseLease(new Response(new ReadableStream({ start(c) { source = c; } })),
      { dispose() { released++; } });
    expect(released).toBe(0);
    const reader = response.body!.getReader();
    source.enqueue(new Uint8Array([1]));
    expect((await reader.read()).value).toEqual(new Uint8Array([1]));
    expect(released).toBe(0);
    if (cancel) await reader.cancel();
    else { source.close(); expect((await reader.read()).done).toBe(true); }
    expect(released).toBe(1);
    await reader.cancel(); expect(released).toBe(1);
  }
});

test("a failed worker stream releases its activity and retains the stream error", async () => {
  let released = 0;
  const response = retainResponseLease(new Response(new ReadableStream({ start(c) { c.error(new Error("worker died")); } })),
    { dispose() { released++; } });
  await expect(response.text()).rejects.toThrow("worker died");
  expect(released).toBe(1);
});
