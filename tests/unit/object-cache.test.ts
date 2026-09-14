import { expect, test } from "bun:test";
import { PromptCache } from "../../src/prompt-cache";
import type { CheckpointAttachment } from "../../src/backends/mlx/checkpoint-state";
import type { MlxArray } from "../../src/mlx/array";

function tensor(bytes: number, disposed: string[], label: string): MlxArray {
  return { nbytes: bytes, shape: [bytes / 2],
    slice: () => tensor(bytes, disposed, `${label}:view`),
    dispose: () => disposed.push(label),
  } as unknown as MlxArray;
}
const payload = (value: MlxArray): CheckpointAttachment[] =>
  [{ schema: "test-feature-v1", metadata: {}, tensors: [value] }];
const create = (bytes: number, cold?: ConstructorParameters<typeof PromptCache>[2]) =>
  new PromptCache(bytes, null, cold, () => [], () => {});

test("exact objects share the prefix byte budget and lend independent views", async () => {
  const freed: string[] = [], cache = create(24);
  cache.objects!.put("image-a", payload(tensor(16, freed, "a")));
  const held = await cache.objects!.take("image-a");
  expect(held).not.toBeNull();
  expect(await cache.objects!.take("image-b")).toBeNull();
  expect(cache.take([1, 2, 3])).toBeNull();
  cache.put([1, 2], [], "", undefined, payload(tensor(16, freed, "prefix")));
  expect(cache.totalBytes).toBe(16);
  expect(freed).toEqual(["a"]);
  expect(held!.value[0]!.tensors[0]!.nbytes).toBe(16);
  held!.dispose(); held!.dispose();
  expect(freed).toEqual(["a", "a:view"]);
  cache.clear();
  expect(freed).toEqual(["a", "a:view", "prefix"]);
});

test("clearing the cache during an object restore prevents stale publication", async () => {
  const freed: string[] = [];
  let finish!: (value: any) => void;
  const cache = create(128, { find: () => null, restore: () => null, store() {},
    findExact: () => ({ prefixLen: 0, handle: "object" }),
    restoreObjectAsync: () => new Promise(resolve => { finish = resolve; }),
  });
  const request = cache.objects!.take("image-a");
  cache.clear();
  finish({ tokens: [], caches: [], attachments: payload(tensor(16, freed, "restore")),
    retain: () => freed.push("backing") });
  expect(await request).toBeNull();
  expect(cache.size).toBe(0);
  expect(freed).toEqual(["restore", "backing"]);
});

test("an in-flight object restore cannot replace a newer resident publication", async () => {
  const freed: string[] = [];
  let finish!: (value: any) => void;
  const cache = create(128, { find: () => null, restore: () => null, store() {},
    findExact: () => ({ prefixLen: 0, handle: "object" }),
    restoreObjectAsync: () => new Promise(resolve => { finish = resolve; }),
  });
  const request = cache.objects!.take("image-a");
  cache.objects!.put("image-a", payload(tensor(16, freed, "resident")));
  finish({ tokens: [], caches: [], attachments: payload(tensor(16, freed, "restore")),
    retain: () => freed.push("backing") });
  const hit = await request;
  expect(freed).toEqual(["restore", "backing"]);
  hit!.dispose(); cache.clear();
  expect(freed).toEqual(["restore", "backing", "resident:view", "resident"]);
});


test("disabled caching supplies no object port to the producer", () => {
  expect(create(0).objects).toBeUndefined();
});
