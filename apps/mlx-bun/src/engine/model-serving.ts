import type { ModelContext, LoadedModelContext } from "./model-host";
import type { ModelBinding } from "./model-binding";
/** Existing model classes enter the interface once here. New implementations
 * supply a binding explicitly and need no forward/makeCache methods. */
export async function modelServingBinding(context: LoadedModelContext, supplied?: ModelBinding): Promise<ModelBinding> {
  if (supplied) return supplied;
  const [{ Glm52Model }, { embedMany, isEmbeddingModel }, { bindMlxGateway }, { MLX_VERSION, deviceArchitecture }] = await Promise.all([
    import("@mlx-bun/inference/models/glm52"), import("@mlx-bun/inference/embeddings"),
    import("@mlx-bun/inference/execution"), import("@mlx-bun/mlx/ffi"),
  ]);
  const ctx = context as ModelContext;
  const model = ctx.model;
  if (typeof model.makeCache !== "function" || typeof model.forward !== "function")
    throw new Error("model implementation must supply its serving binding");
  const glm = model instanceof Glm52Model;
  const embedding = isEmbeddingModel(model);
  return {
    stateCompatibility: `mlx-${MLX_VERSION}-${deviceArchitecture()}`,
    gateway: bindMlxGateway(model, ctx.draft ?? undefined),
    restore: (store, entry) => store.restore(entry, model),
    restoreAsync: (store, entry) => store.restoreAsync(entry, model),
    async signal(ids, count, minimum) {
      const caches = model.makeCache();
      try {
        const logits = model.forward(ids, caches);
        let f: Float32Array;
        let vocab: number;
        try {
          const [, length, width] = logits.shape as [number, number, number];
          vocab = width;
          const last = logits.slice([0, length - 1, 0], [1, length, width]);
          try { f = last.toFloat32(); } finally { last.dispose(); }
        } finally { logits.dispose(); }
        let mx = -Infinity;
        for (const value of f) if (value > mx) mx = value;
        let sum = 0;
        for (const value of f) sum += Math.exp(value - mx);
        const lse = mx + Math.log(sum);
        const bins = new Array<number>(count).fill(0);
        for (const value of f) {
          const t = Math.max(0, Math.min(1, (value - lse - minimum) / -minimum));
          const bin = Math.min(count - 1, Math.floor(t * count));
          bins[bin] = (bins[bin] ?? 0) + 1;
        }
        return { bins, vocab };
      } finally { for (const cache of caches) cache.dispose(); }
    },
    discovery: { adapters: !glm, training: !glm, dsa: glm && model.capabilities.dsa, embeddings: embedding },
    ...(embedding ? { embed: (inputs: string[], instruction?: string) => embedMany(model, ctx.tokenizer, inputs, instruction) } : {}),
    diagnostics() {
      const plan = ctx.glmMemoryPlan;
      if (!plan) return {};
      const runtime = glm ? model.expertRuntime : undefined;
      return { glm52: {
        preset: plan.preset, planned_process_bytes: plan.plannedProcessBytes,
        process_limit_bytes: plan.processLimitBytes, context_tokens: plan.contextTokens,
        max_generation_tokens: plan.maxGenerationTokens, batch_size: plan.batchSize,
        dsa: glm && model.capabilities.dsa, mtp: ctx.draft?.provider.id === "glm52-native-mtp",
        mtp_draft_tokens: plan.mtpDraftTokens, resident_weight_bytes: plan.lineItems.residentWeightsBytes,
        main_expert_slab_bytes: plan.lineItems.mainExpertSlabBytes,
        mtp_expert_slab_bytes: plan.lineItems.mtpExpertSlabBytes,
        expert_runtime: runtime ? {
          main_residency: runtime.manager.snapshot(), mtp_residency: runtime.mtp?.manager.snapshot() ?? null,
          last_turn: runtime.lastTelemetry, last_repin: runtime.lastRepin,
        } : null,
      } };
    },
  };
}
