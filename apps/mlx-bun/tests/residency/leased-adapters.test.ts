import { expect, test } from "bun:test";
import type { AdapterOperation, ModelLease } from "@mlx-bun/app-core";
import { leasedAdapters } from "../../src/residency/leased-adapters";

const stub = (extra: Partial<AdapterOperation> = {}): AdapterOperation => ({ list: async () => [], mount: async id => ({ id, path: "/p", rank: 1, scale: 1, sizeBytes: 1, mountedLayers: 1, ramBytes: 1 }),
  unmount: async () => 1, merge: async () => ({}), ...extra });

function host(operation: AdapterOperation | undefined, events: string[]) {
  let current = "a";
  return { set current(id: string) { current = id; }, acquire: async (id: string, options?: { signal?: AbortSignal }) => {
    events.push(`acquire ${id}${options?.signal ? " with signal" : ""}`);
    return { model: { id }, unit: {}, loadMs: 0, operations: operation ? { adapters: operation } : {}, release() { events.push(`release ${id}`); } } as unknown as ModelLease & { unit: never };
  }, currentId: () => current };
}

test("each call leases the model that is current when it is made, runs the model's own operation, and releases even when it fails", async () => {
  const events: string[] = [];
  const fake = host(stub({ mount: async id => { events.push(`mount ${id}`); throw new Error("no room"); }, unmount: async () => { events.push("unmount"); return 2; } }), events);
  const adapters = leasedAdapters(fake, fake.currentId);
  expect(await adapters.list()).toEqual([]);
  await expect(adapters.mount("x", "/x")).rejects.toThrow("no room");
  fake.current = "b";
  const controller = new AbortController();
  expect(await adapters.unmount("x", controller.signal)).toBe(2);
  expect(events).toEqual(["acquire a", "release a", "acquire a", "mount x", "release a", "acquire b with signal", "unmount", "release b"]);
});

test("a model that declares no adapter operation is refused by name, and the lease is still released", async () => {
  const events: string[] = [];
  const fake = host(undefined, events);
  await expect(leasedAdapters(fake, fake.currentId).merge({ adapters: ["/a", "/b"], output: "/out" })).rejects.toThrow("a does not mount adapters");
  expect(events).toEqual(["acquire a", "release a"]);
});
