import { describe, expect, spyOn, test } from "bun:test";
import { createHash } from "node:crypto";

const enabled = Bun.env.MLX_BUN_TEST_MTP_PREFIX === "1";
describe.skipIf(!enabled)("paired Qwen MTP prefill cache", async () => {
  if (!enabled) return;
  const { Weights } = await import("../../src/weights");
  const { loadModelConfig } = await import("../../src/config");
  const { loadTokenizer } = await import("../../src/tokenizer");
  const { Qwen35Model } = await import("../../src/model/qwen3_5");
  const { QwenMtpProvider } = await import("../../src/spec/qwen-mtp-source");
  const { SpeculativePrefixStore } = await import("../../src/spec/prefix-state");
  const { specServeRun } = await import("../../src/spec/serve-loop");
  const { withResource } = await import("../../src/engine/resources");
  const { leaseCacheStates } = await import("../../src/backends/mlx/state-views");
  const { clearCache, activeMemory } = await import("../../src/mlx/ffi");
  const target = Bun.env.MLX_BUN_TEST_MTP_TARGET!;
  const draft = Bun.env.MLX_BUN_TEST_MTP_DRAFT!;

  function digest(entry: any) {
    const h = createHash("sha256");
    withResource(leaseCacheStates([...entry.target, entry.draft]), (state) => {
      for (const a of [...state, entry.hidden]) {
        h.update(JSON.stringify({ shape: a.shape, dtype: a.dtype }));
        h.update(new Uint8Array(a.toFloat32Host().buffer));
      }
    });
    return h.digest("hex");
  }

  test("repeated prompts restore unchanged target, draft and hidden state with exact continuations", async () => {
    const config = await loadModelConfig(target), weights = await Weights.open(target);
    const model = new Qwen35Model(weights, config), provider = await QwenMtpProvider.load(draft);
    const tokenizer = await loadTokenizer(target);
    const corpus = tokenizer.encode("Alpha beta gamma delta. The workshop inventory contains brass washers and maple dowels. ".repeat(250));
    const put = SpeculativePrefixStore.prototype.put, take = SpeculativePrefixStore.prototype.take;
    let captured: string | undefined;
    const restored: Array<{ same: boolean; tokens: number }> = [], rows: any[] = [];
    const putSpy = spyOn(SpeculativePrefixStore.prototype, "put").mockImplementation(function (this: InstanceType<typeof SpeculativePrefixStore>, entry, budget) {
      captured = digest(entry);
      return put.call(this, entry, budget);
    });
    const takeSpy = spyOn(SpeculativePrefixStore.prototype, "take").mockImplementation(function (this: InstanceType<typeof SpeculativePrefixStore>, ...args) {
      const state = take.apply(this, args);
      if (state) restored.push({ same: digest(state) === captured, tokens: state.tokens.length });
      return state;
    });
    try {
      for (const length of [128, 513, 2051]) {
        const prompt = corpus.slice(0, length), boundary = length - 3;
        const runs: any[] = [];
        // A zero budget clears any earlier prompt and preserves the historical path.
        await specServeRun(model, provider, 2, prompt, { maxTokens: 1, temperature: 0,
          speculativeCacheBytes: 0 }, () => {});
        for (let repeat = 0; repeat < 3; repeat++) {
          const tokens: number[] = [], start = performance.now();
          const stats = await specServeRun(model, provider, 2, prompt, {
            maxTokens: 24, temperature: 0, seed: 42, snapshotAt: boundary,
            speculativeCacheBytes: 4 * 1024 ** 3,
          }, token => { tokens.push(token); });
          clearCache();
          runs.push({ repeat, tokens, cached: stats.cachedTokens,
            speculation: stats.spec, wallMs: performance.now() - start, activeBytes: activeMemory() });
          expect(stats.cachedTokens).toBe(repeat ? boundary : 0);
          if (repeat) {
            expect(tokens).toEqual(runs[0].tokens);
            expect(stats.spec?.acceptanceLengths).toEqual(runs[0].speculation.acceptanceLengths);
          }
        }
        rows.push({ length, boundary, runs });
      }
      expect(restored.length).toBe(6);
      expect(restored.every(r => r.same)).toBe(true);
    } finally {
      putSpy.mockRestore(); takeSpy.mockRestore();
      provider.dispose(); weights.dispose(); clearCache();
      if (Bun.env.MLX_BUN_TEST_MTP_REPORT) await Bun.write(Bun.env.MLX_BUN_TEST_MTP_REPORT,
        JSON.stringify({ target, draft, rows, restored, activeAfterDisposal: activeMemory() }, null, 2));
    }
  }, 600000);
});
