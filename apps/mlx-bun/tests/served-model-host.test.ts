import { expect, test } from "bun:test";
import type { ModelHostError } from "@mlx-bun/app-core";
import { createServedModelHost } from "../src/cli/served-model-host";
import type { ServedHostLink } from "../src/cli/served-model-host";

const link = (extra: Partial<ServedHostLink> = {}): ServedHostLink => ({ model: { id: "org/model", bytes: 123 }, port: 4321,
  ...extra });
const code = async (work: Promise<unknown>) => { try { await work; } catch (error) { return (error as ModelHostError).code; } return undefined; };

test("with no serving host attached there is no default model and acquiring is refused", async () => {
  let attached: ServedHostLink | undefined;
  const host = createServedModelHost({ link: () => attached, fetch: async () => new Response() });
  expect(await host.defaultFor("generate")).toBeUndefined();
  expect(host.resident()).toEqual([]);
  expect(await code(host.acquire("org/model"))).toBe("closed");
  attached = link();
  expect(await host.defaultFor("generate")).toBe("org/model");
  expect(await host.defaultFor("transcribe")).toBeUndefined();
  expect(host.policy).toEqual({ budgetBytes: 123, pinned: ["org/model"], idleUnloadSec: 0 });
  attached = undefined;
  expect(await code(host.acquire("org/model"))).toBe("closed");
});

test("a lease admits only the served model and its declared operation, and counts until released", async () => {
  const host = createServedModelHost({ link: () => link(), fetch: async () => new Response() });
  expect(await code(host.acquire("other"))).toBe("does-not-fit");
  expect(await code(host.acquire("org/model", { need: ["embed"] }))).toBe("does-not-fit");
  const lease = await host.acquire("org/model", { need: ["generate"] });
  expect(lease.model).toMatchObject({ id: "org/model", role: "primary", state: "ready", operations: ["generate"], bytes: 123, pinned: true, leases: 1 });
  expect(Object.keys(lease.operations)).toEqual(["generate"]);
  expect(host.resident()[0]!.leases).toBe(1);
  lease.release(); lease.release();
  expect(host.resident()[0]!.leases).toBe(0);
  expect(await code(host.unload("org/model"))).toBe("in-use");
  expect(host.stats("org/model")).toMatchObject({ resident: true, unloads: 0, idleUnloadSec: null });
  expect(await host.plan("org/model")).toMatchObject({ fits: true, evict: [] });
});

test("generate sends the wire request to the host's own listener, keeping method, path, query, headers, body and signal", async () => {
  const sent: { request: Request; link: ServedHostLink }[] = [];
  const attached = link({ unix: "/tmp/host.sock" });
  const host = createServedModelHost({ link: () => attached, fetch: async (request, to) => { sent.push({ request, link: to }); return Response.json({ ok: true }); } });
  const lease = await host.acquire("org/model");
  const abort = new AbortController();
  const response = await lease.operations.generate!(new Request("http://model.local/v1/chat/completions?x=1", { method: "POST",
    headers: { "content-type": "application/json", authorization: "Bearer t" }, body: '{"a":1}', signal: abort.signal }));
  expect(await response.json()).toEqual({ ok: true });
  const { request, link: to } = sent[0]!;
  expect(request.url).toBe("http://127.0.0.1:4321/v1/chat/completions?x=1");
  expect(request.method).toBe("POST");
  expect(request.headers.get("authorization")).toBe("Bearer t");
  expect(await request.text()).toBe('{"a":1}');
  expect(to.unix).toBe("/tmp/host.sock");
  abort.abort(new Error("stop"));
  expect(request.signal.aborted).toBe(true);
});
