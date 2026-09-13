import { expect, test } from "bun:test";
import type { MixedTokenModel } from "../../src/model/token-groups";

const target = Bun.env.MLX_BUN_TEST_MTP_TARGET;
const draft = Bun.env.MLX_BUN_TEST_MTP_DRAFT;
const enabled = Bun.env.MLX_BUN_TEST_MIXED_METHOD === "1" && target;

test.skipIf(!enabled)("mixed speculative work preserves method taps, retirement and generated cache reuse", async () => {
  const { Weights } = await import("../../src/weights");
  const { loadModelConfig } = await import("../../src/config");
  const { createModel } = await import("../../src/model/factory");
  const { MlxBatchExecutionGroup } = await import("../../src/backends/mlx/batch-group");
  const { bindSpeculativeGroupRequests } = await import("../../src/backends/mlx/speculative-group");
  const { QwenMtpProvider } = await import("../../src/spec/qwen-mtp-source");
  const { NgramProvider } = await import("../../src/spec/ngram-source");
  const { PromptCache } = await import("../../src/prompt-cache");
  const { createRuntimeConfig } = await import("../../src/runtime-config");
  const { clearCache } = await import("../../src/mlx/ffi");
  using resources = new DisposableStack();
  const weights = await Weights.open(target!); resources.defer(() => weights.dispose());
  const model = createModel(weights, await loadModelConfig(target!)) as ReturnType<typeof createModel> & MixedTokenModel;
  const provider = draft ? await QwenMtpProvider.load(draft) : new NgramProvider();
  const options = { temperature: 0, maxTokens: 48, prefillChunkSize: 32,
    ...(Bun.env.MLX_BUN_TEST_MTP_TURBO === "1" ? { turboQuant: { kBits: 8, vBits: 3 }, quantizedKvStart: 0 }
      : { kvBits: 4, quantizedKvStart: 0 }) };
  const bind = bindSpeculativeGroupRequests(model, provider, Number(Bun.env.MLX_BUN_TEST_MTP_DEPTH ?? 3));
  const original = model.forwardHiddenMixed.bind(model);
  let mixedCalls = 0, maxMixedRows = 0;
  model.forwardHiddenMixed = groups => {
    if (groups.length > 1) {
      mixedCalls++;
      maxMixedRows = Math.max(maxMixedRows, groups[0]!.ids.shape[0]!);
      expect(groups[0]!.preserveTokenGeometry).toBe(true);
      expect(groups.reduce((n, g) => n + g.ids.shape[0]! * g.ids.shape[1]!, 0)).toBeLessThanOrEqual(24);
      if (draft) expect(groups.every(g => typeof g.captureLayer === "function")).toBe(true);
    }
    return original(groups);
  };
  const prompt = [1, 2, 3, 4, 5, 6, 7];
  const run = async (mode: "length" | "stop" | "cancel") => {
    const cache = new PromptCache(1024 ** 3);
    const group = new MlxBatchExecutionGroup(model, { maxBatch: 4, promptCache: cache,
      runtime: createRuntimeConfig({ MLX_BUN_MIXED_PREFILL: "1", MLX_BUN_MIXED_TOKEN_BUDGET: "24" }) });
    const output: number[][] = [[], [], []];
    const controller = new AbortController();
    let joined: Promise<unknown> | undefined, third: Promise<unknown> | undefined;
    const before = mixedCalls;
    maxMixedRows = 0;
    try {
      const first = await group.submit({ method: bind(options), promptIds: prompt, maxTokens: 48, eosTokenIds: [],
        onToken(token) {
          output[0]!.push(token);
          if (output[0]!.length === 6) {
            joined = group.submit({ method: bind(options), promptIds: Array.from({ length: 97 }, (_, i) => 1 + i % 23),
              maxTokens: 12, eosTokenIds: [], signal: controller.signal, onToken(next) {
                output[1]!.push(next);
                if (output[1]!.length === 1) third = group.submit({ method: bind(options),
                  promptIds: Array.from({ length: 61 }, (_, i) => 1 + i % 17), maxTokens: 8, eosTokenIds: [],
                  onToken(value) { output[2]!.push(value); } });
                if (output[1]!.length === 3) {
                  if (mode === "stop") return false;
                  if (mode === "cancel") controller.abort(new Error("mixed row cancelled"));
                }
              } }).then(value => ({ value }), error => ({ error }));
          }
        } });
      const second = await joined as { value?: { generatedTokens: number }; error?: Error };
      await third;
      expect(first.generatedTokens).toBe(48);
      expect(mixedCalls).toBeGreaterThan(before);
      // A short consumer can retire within its first accepted draft burst,
      // before the third request is admitted. Length runs require B2 mixed work.
      if (mode === "length") expect(maxMixedRows).toBeGreaterThanOrEqual(2);
      expect(output[2]!.length).toBe(8);
      expect(output[1]!.length).toBe(mode === "length" ? 12 : 3);
      if (mode === "cancel") expect(second.error?.message).toBe("mixed row cancelled");
      else expect(second.value?.generatedTokens).toBe(output[1]!.length);
      expect(group.activeRows + group.pendingRows).toBe(0);
      const continued: number[] = [];
      const followup = await group.submit({ method: bind(options), promptIds: [...prompt, ...output[0]!, 21],
        maxTokens: 8, eosTokenIds: [], onToken(token) { continued.push(token); } });
      expect(followup.cachedTokens).toBeGreaterThan(prompt.length);
      expect(continued.length).toBe(8);
      return { output, continued };
    } finally { await group.close(); cache.clear(); clearCache(); }
  };
  try {
    expect(await run("length")).toEqual(await run("length"));
    await run("stop"); await run("cancel");
  } finally { model.forwardHiddenMixed = original; provider.dispose(); clearCache(); }
}, 300_000);
