import { expect, test } from "bun:test";
import { createCacheRoutes } from "../../src/server/cache-routes";

const zero = { pendingSnapshots: 0, pendingSpills: 0, pendingSpillBytes: 0, droppedSpills: 0, failedSpills: 0 };
const durable = { ...zero, durable: true, flushedSnapshots: 1, missingSnapshots: 0, elapsedMs: 3 };
const post = (path: string, body?: BodyInit) => new Request(`http://local${path}`, { method: "POST", body });

function fixture(flush: () => Promise<typeof durable> = async () => durable, disk = true) {
  const closed: string[] = [];
  const routes = createCacheRoutes({ promptCache: { closeSession: id => { closed.push(id); } }, flush,
    checkpoints: disk ? { entries: 2, longestDurablePrefixTokens: 16_384 } : null });
  return { routes, closed };
}

test("session close keeps main's semantics: any string id closes, anything else reports closed:false", async () => {
  const { routes, closed } = fixture();
  const close = async (body?: BodyInit) => {
    const response = (await routes.handle(post("/admin/cache/session/close", body)))!;
    return { status: response.status, body: await response.json() };
  };
  expect(await close(JSON.stringify({ session_id: "agent-42" }))).toEqual({ status: 200, body: { closed: true } });
  expect(await close(JSON.stringify({ session_id: "never-seen" }))).toEqual({ status: 200, body: { closed: true } });
  expect(await close(JSON.stringify({}))).toEqual({ status: 200, body: { closed: false } });
  expect(await close(JSON.stringify({ session_id: 7 }))).toEqual({ status: 200, body: { closed: false } });
  expect(await close(JSON.stringify(["agent-42"]))).toEqual({ status: 200, body: { closed: false } });
  expect(await close()).toEqual({ status: 200, body: { closed: false } });
  expect(await close("{not json")).toEqual({ status: 400, body: { error: { message: "invalid JSON body" } } });
  expect(closed).toEqual(["agent-42", "never-seen"]);
});

test("flush answers 200 with main's counters when durable, 503 with them otherwise, and 500 on a persistence failure", async () => {
  const withDisk = (await fixture().routes.handle(post("/admin/cache/flush")))!;
  expect(withDisk.status).toBe(200);
  expect(await withDisk.json()).toEqual({ ...durable, entries: 2, longest_durable_prefix_tokens: 16_384 });
  const ramOnly = (await fixture(undefined, false).routes.handle(post("/admin/cache/flush")))!;
  expect(ramOnly.status).toBe(200);
  expect(await ramOnly.json()).toMatchObject({ durable: true, entries: 0, longest_durable_prefix_tokens: 0 });
  const pending = (await fixture(async () => ({ ...durable, durable: false, pendingSpills: 1, missingSnapshots: 1, flushedSnapshots: 0 }))
    .routes.handle(post("/admin/cache/flush")))!;
  expect(pending.status).toBe(503);
  expect(await pending.json()).toMatchObject({ durable: false, pendingSpills: 1, missingSnapshots: 1, entries: 2 });
  const failed = (await fixture(async () => { throw new Error("spill queue failed"); }).routes.handle(post("/admin/cache/flush")))!;
  expect(failed.status).toBe(500);
  expect(await failed.json()).toEqual({ error: { message: "spill queue failed" } });
});

test("a session close never waits for a flush in progress, and other methods or paths are not handled", async () => {
  const gate = Promise.withResolvers<typeof durable>();
  const { routes, closed } = fixture(() => gate.promise);
  const flushing = routes.handle(post("/admin/cache/flush"));
  const close = (await routes.handle(post("/admin/cache/session/close", JSON.stringify({ session_id: "live" }))))!;
  expect(await close.json()).toEqual({ closed: true });
  expect(closed).toEqual(["live"]);
  gate.resolve(durable);
  expect((await flushing)!.status).toBe(200);
  for (const request of [new Request("http://local/admin/cache/flush"), new Request("http://local/admin/cache/session/close"),
    post("/admin/cache/other"), post("/admin/cache/session/close/extra")])
    expect(await routes.handle(request)).toBeNull();
});
