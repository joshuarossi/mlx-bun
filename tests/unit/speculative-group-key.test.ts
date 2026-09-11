import { speculativePrefixNamespace } from "../../src/spec/cache-identity";
import type { GenerateOptions } from "../../src/generate";
import { expect, test } from "bun:test";
import { bindSpeculativeGroupRequests } from "../../src/backends/mlx/speculative-group";
import type { RuntimeModel } from "../../src/model/factory";
import type { DraftProvider } from "../../src/spec/source";

// Building a compatibility key must not open numerical state or a draft.
const model = { config: { modelType: "qwen3_5", eosTokenIds: [] },
  makeCache() { throw new Error("key opened target state"); },
  logitsFromHidden() { throw new Error("key projected logits"); },
} as unknown as RuntimeModel;
const provider = { id: "qwen-mtp", open() { throw new Error("key opened draft"); } } as unknown as DraftProvider;

test("shared method membership separates TurboQuant encodings from affine and full precision", () => {
  const bind = bindSpeculativeGroupRequests(model, provider, 4);
  const keys = [bind({}), bind({ kvBits: 8, quantizedKvStart: 0 }),
    bind({ turboQuant: { kBits: 8, vBits: 3 }, quantizedKvStart: 0 }),
    bind({ turboQuant: { kBits: 4, vBits: 3 }, quantizedKvStart: 0 }),
    bind({ turboQuant: { kBits: 8, vBits: 5 }, quantizedKvStart: 0 })].map(request => request.key);
  expect(new Set(keys).size).toBe(keys.length);
  expect(bind({ turboQuant: { kBits: 8, vBits: 3 }, quantizedKvStart: 0, seed: 42 }).key).toBe(keys[2]!);
});


test("per-layer schemes separate groups and persisted state without invalidating existing keys", () => {
  const bind = bindSpeculativeGroupRequests(model, provider, 4);
  expect(bind({}).key).toBe('["speculative","qwen-mtp",4,null,64,null,null]');
  expect(speculativePrefixNamespace("draft-v1", "", {})).toBe(
    '{"method":"draft-v1","adapters":"","kvBits":null,"kvGroupSize":64,"quantizedKvStart":null,"turboQuant":null}');
  const input: GenerateOptions = { kvConfig: [{layerIdx:5,bits:4,groupSize:64},{layerIdx:1,bits:8,groupSize:64}] };
  const request = bind(input), captured = request.data as GenerateOptions;
  const namespace = speculativePrefixNamespace("draft-v1", "", captured);
  input.kvConfig![0]!.bits = 8;
  expect(captured.kvConfig!.find(item => item.layerIdx === 5)!.bits).toBe(4);
  expect(bind(input).key).not.toBe(request.key);
  expect(speculativePrefixNamespace("draft-v1", "", bind(input).data as GenerateOptions)).not.toBe(namespace);
  const reordered = bind({kvConfig:[{groupSize:64,bits:8,layerIdx:1},{bits:4,layerIdx:5,groupSize:64}]});
  expect(reordered.key).toBe(request.key);
  expect(speculativePrefixNamespace("draft-v1", "", reordered.data as GenerateOptions)).toBe(namespace);
  expect(bind({kvConfig:[]}).key).toBe(bind({}).key);
});
