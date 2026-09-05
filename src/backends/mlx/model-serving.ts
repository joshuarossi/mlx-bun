import type { ServerContext, ServingContext } from "../../serve/model-host";
import type { ModelServingBinding } from "../../serve/model-binding";
import { Glm52Model } from "../../model/glm52";
import { embedMany, isEmbeddingModel } from "../../embed";
import { bindMlxGateway } from "./gateway-binding";
import { bindLegacySerialModel, createMlxSerialExecutor } from "./serial-executor";
import { buildModelPrompt } from "./model-prompt";

export function modelPromptBuilder(context: ServingContext): ModelServingBinding["buildPrompt"] {
  return context.serving?.buildPrompt ?? ((body, tools, ownership, prep) =>
    buildModelPrompt(context as ServerContext, prep, body, tools, ownership));
}

/** Existing model classes enter the interface once here. New implementations
 * provide ctx.serving directly and need no forward/makeCache methods. */
export function modelServingBinding(context: ServingContext): ModelServingBinding {
  if (context.serving) return context.serving;
  const ctx = context as ServerContext;
  const model = ctx.model;
  if (typeof model.makeCache !== "function" || typeof model.forward !== "function")
    throw new Error("model implementation must supply its serving binding");
  const serial = bindLegacySerialModel(model, ctx.draft ?? undefined);
  const glm = model instanceof Glm52Model;
  const embedding = isEmbeddingModel(model);
  return {
    gateway: bindMlxGateway(model),
    createSerial: (services) => createMlxSerialExecutor(serial, services),
    buildPrompt: (body, tools, ownership, prep) => buildModelPrompt(ctx, prep, body, tools, ownership),
    restore: (store, entry) => store.restore(entry, model),
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
