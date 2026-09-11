import { expect, test } from "bun:test";
import { MlxArray } from "../../src/mlx/array";
import { KVCache } from "../../src/model/gemma4-base";
import { QwenMtpSource } from "../../src/spec/qwen-mtp-source";
import { PromptCache } from "../../src/prompt-cache";
import { cloneKvCaches } from "../../src/kv-store";
import { disposeAttachments } from "../../src/backends/mlx/checkpoint-state";

test("restored MTP joins the next token to the saved preceding hidden at the correct position", async () => {
  const calls: Array<{ offset: number; tokens: number[]; hiddens: number[] }> = [];
  const array = (values: number[]) => MlxArray.fromFloat32(Float32Array.from(values), [1, values.length, 1]);
  const append = (cache: KVCache, values: number[]) => {
    using kv = MlxArray.fromFloat32(Float32Array.from(values), [1, 1, values.length, 1]);
    for (const view of cache.updateAndFetch(kv, kv)) view.dispose();
  };
  const target = {
    hiddenSize: 1, layerCount: 1,
    embed(ids: MlxArray) { return array(ids.toIntTokens()); },
    logitsFromHidden() { return MlxArray.fromFloat32(new Float32Array(8), [1, 1, 8]); },
  };
  const module = { forward(embeds: MlxArray, hidden: MlxArray, cache: KVCache) {
    const tokens = [...embeds.toFloat32Host()], hiddens = [...hidden.toFloat32Host()];
    calls.push({ offset: cache.offset, tokens, hiddens });
    append(cache, tokens);
    return array(tokens);
  } } as unknown as ConstructorParameters<typeof QwenMtpSource>[1];
  const store = new PromptCache(100000);
  const make = () => new QwenMtpSource(target, module,
    () => MlxArray.fromInt32(new Int32Array([1]), [1]));
  const original = make(), firstTarget = [new KVCache()], restored = make(), nextTarget = [new KVCache()];
  try {
    append(firstTarget[0]!, [1, 2, 3]);
    await original.prefill([1, 2, 3], array([10, 20, 30]));
    store.put([1, 2, 3], cloneKvCaches(firstTarget), "base", undefined, [original.checkpoint.capture(3)]);
    original.dispose();
    for (const cache of firstTarget) cache.dispose();
    const hit = store.take([1, 2, 3, 4, 5], "base")!;
    expect(hit.tokens.length).toBe(3);
    restored.checkpoint.restore(hit.tokens.length, hit.attachments![0]!);
    disposeAttachments(hit.attachments);
    nextTarget[0]!.dispose();
    nextTarget.splice(0, nextTarget.length, ...hit.caches as KVCache[]);
    expect(nextTarget[0]!.offset).toBe(3);
    append(nextTarget[0]!, [4, 5]);
    await restored.prefill([1, 2, 3, 4, 5], array([40, 50]));
    store.put([1, 2, 3, 4, 5], cloneKvCaches(nextTarget), "base", undefined, [restored.checkpoint.capture(5)]);
    await restored.draft([6], 1, 0);
    expect(calls).toEqual([
      { offset: 0, tokens: [2, 3], hiddens: [10, 20] },
      { offset: 2, tokens: [4], hiddens: [30] },
      { offset: 3, tokens: [5], hiddens: [40] },
      { offset: 4, tokens: [6], hiddens: [50] },
    ]);
  } finally {
    original.dispose(); restored.dispose(); store.clear();
    for (const cache of [...firstTarget, ...nextTarget]) cache.dispose();
  }
});
