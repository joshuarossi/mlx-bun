import { expect, test } from "bun:test";
import { bindMlxGateway } from "../../src/backends/mlx/gateway-binding";
import { KVCache } from "../../src/model/gemma4-base";
import type { RuntimeModel } from "../../src/model/factory";
import type { DraftProvider } from "../../src/spec/source";
import { NgramProvider } from "../../src/spec/ngram-source";

const shape = { hasVision: false, hasAdapters: true, hasRepetitionPenalty: false, userSeed: true,
  kvQuant: false, turboQuant: false, hasLogitsExtras: false, hasGrammar: false, wantsLogprobs: true, hasDraft: true };

test("gateway reads provider adapter capability and preserves ordinary execution for unqualified combinations", () => {
  const model = { config: { modelType: "fixture", eosTokenIds: [] }, loraState: { active: [] },
    makeCache: () => [new KVCache()], logitsFromHidden() { throw new Error("not forwarding"); } } as unknown as RuntimeModel;
  const provider = new NgramProvider();
  const unqualified: DraftProvider = { id: "unqualified", weightsBytes: 0,
    grouped: { open: provider.grouped.open, openPrefill: provider.grouped.openPrefill },
    open: provider.open.bind(provider), dispose() {} };
  const qualified = bindMlxGateway(model, { provider, numDraftTokens: 3 });
  const other = bindMlxGateway(model, { provider: unqualified, numDraftTokens: 3 });
  const schedule = { continuous: true, quantizedBatch: true, checkpoints: false };
  expect(qualified.plan(shape, { adapters: ["upper"] }, schedule)).toMatchObject({ method: "speculative", mechanism: "continuous" });
  expect(other.plan(shape, { adapters: ["upper"] }, schedule).method).toBe("autoregressive");
  expect(qualified.plan(shape, { adapters: ["upper"] }, { ...schedule, continuous: false }).method).toBe("autoregressive");
  const context = qualified.bindAdapterContext!(["upper"], "adapter:upper");
  const close = context.enter();
  try { expect((model as unknown as { loraState: { active: string[] } }).loraState.active).toEqual(["upper"]); }
  finally { close(); }
  expect((model as unknown as { loraState: { active: string[] } }).loraState.active).toEqual([]);
});
