// The companion hosts behind one `ModelHost`: every call reaches the host of the
// operation the model declares, with no model named anywhere.
import { expect, test } from "bun:test";
import type { CatalogEntry, ModelCatalog, ModelOperation, ResidentModel } from "@mlx-bun/app-core";
import { createCompanionModelHost, type CompanionHost } from "../src";

/** A host that records each call it answers and holds what it was asked to acquire. */
function fakeHost(operation: ModelOperation, calls: string[], defaultId?: string, refuses: (id: string) => boolean = () => false): CompanionHost {
  const held = new Set<string>(), pinned = new Set<string>();
  const model = (id: string): ResidentModel => ({ id, role: "companion", state: "ready", operations: [operation], bytes: 1, pinned: pinned.has(id), leases: 0, lastUsedAt: 0 });
  return {
    get policy() { return { budgetBytes: Number.POSITIVE_INFINITY, pinned: [...pinned], idleUnloadSec: operation === "image" ? 30 : 0 }; },
    async acquire(id, options) { calls.push(`${operation} acquire ${id} ${options?.need?.join("+") ?? "-"}`); if (refuses(id)) throw new Error(`${id} does not declare the ${operation} operation`); held.add(id); return { model: model(id), loadMs: 0, operations: {}, release() {} }; },
    async defaultFor(asked) { return asked === operation ? defaultId : undefined; },
    async plan(id) { calls.push(`${operation} plan ${id}`); return { fits: true, requiredBytes: 1, freeBytes: Infinity, evict: [] }; },
    async serve() { throw new Error("unused"); },
    async unload(id) { calls.push(`${operation} unload ${id}`); held.delete(id); },
    pin(id) { calls.push(`${operation} pin ${id}`); pinned.add(id); },
    unpin(id) { calls.push(`${operation} unpin ${id}`); pinned.delete(id); },
    resident: () => [...held].map(model),
    stats: id => ({ resident: held.has(id), loads: held.has(id) ? 1 : 0, unloads: 0, lastLoadMs: 0, idleUnloadSec: operation === "image" ? 30 : 0 }),
    async close() { calls.push(`${operation} close`); },
  };
}

const entries: CatalogEntry[] = [
  { id: "org/audio", kind: "model", directory: "/a", bytes: 1, operations: ["transcribe"] },
  { id: "org/picture", kind: "model", directory: "/p", bytes: 1, operations: ["image"] },
  { id: "org/chat", kind: "model", directory: "/c", bytes: 1, operations: ["generate"] },
];
const catalog = (finds: string[]): Pick<ModelCatalog, "find"> => ({ async find(query) {
  finds.push(query);
  return entries.find(item => item.id === query) ?? (() => { throw new Error(`no model matching "${query}"`); })();
} });

function setup(known: Record<string, ModelOperation> = {}) {
  const calls: string[] = [], finds: string[] = [];
  // The image host refuses a model whose catalog entry does not declare `image`, as the real one does.
  const declares = (id: string, operation: ModelOperation) => entries.find(entry => entry.id === id)?.operations.includes(operation) ?? true;
  const host = createCompanionModelHost({ hosts: { transcribe: fakeHost("transcribe", calls, "org/audio"), image: fakeHost("image", calls, "org/picture", id => !declares(id, "image")) },
    catalog: catalog(finds), known });
  return { host, calls, finds };
}

test("a lease reaches the host of the operation the caller needs, without asking the catalog", async () => {
  const { host, calls, finds } = setup();
  await host.acquire("org/picture", { need: ["image"] });
  await host.acquire("org/audio", { need: ["transcribe"] });
  expect(calls).toEqual(["image acquire org/picture image", "transcribe acquire org/audio transcribe"]);
  expect(finds).toEqual([]);
});

test("a lease that needs no companion operation reaches the host of the operation the catalog entry declares, looked up once", async () => {
  const { host, calls, finds } = setup();
  await host.acquire("org/picture");
  await host.plan("org/picture");
  await host.acquire("org/audio", { need: ["generate"] });
  expect(calls).toEqual(["image acquire org/picture -", "image plan org/picture", "transcribe acquire org/audio generate"]);
  expect(finds).toEqual(["org/picture", "org/audio"]);
  await expect(host.acquire("org/chat")).rejects.toMatchObject({ code: "does-not-fit", message: "org/chat declares no companion operation (generate)" });
  await expect(host.acquire("missing")).rejects.toThrow('no model matching "missing"');
});

test("each operation's default is its host's, and a default it answered routes later calls, synchronous ones included", async () => {
  const { host, calls, finds } = setup();
  expect(await host.defaultFor("image")).toBe("org/picture");
  expect(await host.defaultFor("transcribe")).toBe("org/audio");
  expect(await host.defaultFor("generate")).toBeUndefined();
  host.pin("org/picture");
  expect(host.policy.pinned).toEqual(["org/picture"]);
  host.unpin("org/picture");
  await host.plan("org/audio");
  expect(calls).toEqual(["image pin org/picture", "image unpin org/picture", "transcribe plan org/audio"]);
  expect(finds).toEqual([]);
});

test("an id no host has resolved is pinned wherever it may load; a configured checkpoint is known from the start", async () => {
  const unknown = setup();
  unknown.host.pin("org/new");
  expect(unknown.calls).toEqual(["transcribe pin org/new", "image pin org/new"]);
  expect(unknown.host.policy.pinned).toEqual(["org/new"]);
  const configured = setup({ "/dir/picture": "image" });
  configured.host.pin("/dir/picture");
  await configured.host.acquire("/dir/picture");
  expect(configured.calls).toEqual(["image pin /dir/picture", "image acquire /dir/picture -"]);
  expect(configured.finds).toEqual([]);
});

test("residency is every host's; stats and unload reach the host holding the model; close releases every host", async () => {
  const { host, calls } = setup();
  await host.acquire("org/audio", { need: ["transcribe"] });
  await host.acquire("org/picture", { need: ["image"] });
  expect(host.resident().map(model => `${model.id}:${model.operations.join()}`)).toEqual(["org/audio:transcribe", "org/picture:image"]);
  expect(host.stats("org/picture")).toMatchObject({ resident: true, idleUnloadSec: 30 });
  expect(host.stats("org/nothing")).toMatchObject({ resident: false, loads: 0 });
  expect(host.policy).toMatchObject({ budgetBytes: Number.POSITIVE_INFINITY, idleUnloadSec: 0 });
  await host.unload("org/picture");
  await host.unload("org/nothing");
  await expect(host.serve("org/picture")).rejects.toMatchObject({ code: "not-switchable" });
  await host.close();
  expect(calls.slice(2)).toEqual(["image unload org/picture", "transcribe close", "image close"]);
});

test("a lease another host refuses changes nothing: the model's later calls still reach the host that holds it", async () => {
  const { host, calls } = setup();
  (await host.acquire("org/audio", { need: ["transcribe"] })).release();
  // Asking for an operation the model does not declare reaches that operation's host, which refuses it.
  await expect(host.acquire("org/audio", { need: ["image"] })).rejects.toThrow("org/audio does not declare the image operation");
  expect(host.stats("org/audio").resident).toBe(true);
  await host.unload("org/audio");
  expect(calls).toEqual(["transcribe acquire org/audio transcribe", "image acquire org/audio image", "transcribe unload org/audio"]);
  expect(host.resident().map(model => model.id)).toEqual([]);
});
