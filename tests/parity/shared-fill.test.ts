// Compare the shared strict-fill method with the ordinary shared pipeline on
// the same machine, artifact, row geometry and seeded sampler policy.
import { afterAll, describe, expect, test } from "bun:test";
import type { GenerateOptions } from "../../src/generate";

const path = process.env.MLX_BUN_TEST_SHARED_FILL_MODEL;
describe.skipIf(!path)("shared strict-fill seeded replay", async () => {
  if (!path) return;
  const { loadModelConfig } = await import("../../src/config");
  const { Weights } = await import("../../src/weights");
  const { createModel } = await import("../../src/model/factory");
  const { MlxBatchExecutionGroup } = await import("../../src/backends/mlx/batch-group");
  const { bindFillGroupRequests } = await import("../../src/backends/mlx/fill-group");
  const { createRowSampling } = await import("../../src/backends/mlx/row-sampling");
  const { makeStepSampler } = await import("../../src/sampler");
  const { resolveKvScheme } = await import("../../src/kv-scheme");
  const { FillSession } = await import("../../src/fill/fill-session");
  const { createRuntimeConfig } = await import("../../src/runtime-config");
  const config = await loadModelConfig(path), weights = await Weights.open(path);
  const model = createModel(weights, config), method = bindFillGroupRequests(model);
  const appendShapes: number[][] = [];
  if ("createAppend" in model) {
    const createAppend = model.createAppend.bind(model);
    model.createAppend = policy => {
      const append = createAppend(policy);
      return append && { ...append, forwardHidden(ids, caches) {
        appendShapes.push([...ids.shape]); return append.forwardHidden(ids, caches);
      } };
    };
  }
  afterAll(() => weights.dispose());
  const runtime = createRuntimeConfig({ MLX_BUN_COMPILED_DECODE: "0" });

  for (const B of [1, 2, 4]) for (const format of ["bf16", "kv4", "k8v3", "kv4-delayed", "k8v3-delayed", "kv8", "k4v3"] as const) {
    test(`${format} B${B} sampled baseline, empty fill and asserted replay`, async () => {
      const quantizedKvStart = format.endsWith("delayed") ? 12 : 0;
      const scheme = resolveKvScheme(format.startsWith("kv") ? { override: format === "kv8" ? 8 : 4, quantizedKvStart }
        : format.startsWith("k") ? { turboQuant: { kBits: format === "k4v3" ? 4 : 8, vBits: 3 }, quantizedKvStart } : {});
      const outputs: number[][][] = [];
      appendShapes.length = 0;
      for (const arm of ["ordinary", "empty", "filled"] as const) {
        let held = true;
        const group = new MlxBatchExecutionGroup(model, { maxBatch: B, runtime, kvScheme: scheme,
          admissionHeld: () => held, kvBatchCapabilities: { delayedAffine: true } });
        const samplers: { dispose(): void }[] = [], fills: InstanceType<typeof FillSession>[] = [];
        const output = Array.from({ length: B }, () => [] as number[]);
        try {
          const requests = output.map((tokens, row) => {
            // Equal arrival and prefill length keep the numerical cohort
            // geometry matched to ordinary execution throughout this gate.
            const prompt = Array.from({ length: 7 }, (_, index) => 30 + row + index);
            const options: GenerateOptions = { ...scheme.generationOptions, temperature: 0.6, topP: 0.95,
              seed: 42 + row, presencePenalty: 0.2, repetitionPenalty: 1.05 };
            const common = { promptIds: prompt, maxTokens: 24, eosTokenIds: [] as number[],
              onToken: (token: number) => { tokens.push(token); } };
            if (arm === "ordinary") {
              const sampler = createRowSampling(makeStepSampler(options, { tokenRepresentation: "device",
                grammarWait: "external", historyUpdate: "after-sample", initialHistory: prompt }), common.onToken);
              samplers.push(sampler);
              return group.submit({ ...common, sample: sampler.sample, plainGreedy: sampler.plainGreedy });
            }
            const baseline = outputs[0]?.[row];
            // This gate supplies a known continuation at one exact position.
            // A recurring suffix is not a promise that its continuation
            // repeats under stochastic sampling. Template triggers have
            // independent parser/source tests.
            const fill = new FillSession({ rows: [], echo: null, eos: [] }, prompt, {
              sources: arm === "filled" ? [{ name: "saved-position", propose: view =>
                view.length === prompt.length + 3 ? { ids: baseline!.slice(3, 8),
                  policy: "assert", origin: "template" } : null }] : [],
            });
            fills.push(fill);
            return group.submit({ ...common, method: method({ ...options, fill }) });
          });
          held = false; group.kick(); await Promise.all(requests);
          outputs.push(output);
          if (arm !== "ordinary") expect(output, `${arm}, ${format}, B${B}`).toEqual(outputs[0]!);
          if (arm === "filled") expect(fills.map(fill => fill.stats.injected)).toEqual(Array(B).fill(5));
        } finally { await group.close(); samplers.forEach(sampler => sampler.dispose()); }
      }
      console.log(JSON.stringify({ kind: "shared-fill-native", model: path, B, format, appendShapes }));
      if (format === "k4v3") expect(appendShapes).toEqual([]);
    }, 120_000);
  }
});
