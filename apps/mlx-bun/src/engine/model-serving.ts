import type { MlxHeadForward, MlxHeadRange, MlxSequenceRange, MlxSequenceForward } from "@mlx-bun/inference/contracts/mlx";
import type { Composition } from "@mlx-bun/inference/contracts/portable";
import type { ModelContext, LoadedModelContext } from "./model-host";
import type { ModelBinding } from "./model-binding";

/** The loaded composition as `/stats` reports it: the record's fields, with
 * snake_case keys like the rest of that view. */
function compositionWire(composition: Composition): unknown {
  const wire = (value: unknown): unknown => Array.isArray(value) ? value.map(wire)
    : value !== null && typeof value === "object"
      ? Object.fromEntries(Object.entries(value).map(([key, field]) => [key.replace(/[A-Z]/g, c => `_${c.toLowerCase()}`), wire(field)]))
      : value;
  return wire(composition);
}
/** Existing model classes enter the interface once here. New implementations
 * supply a binding explicitly and need no forward/makeCache methods. */
export async function modelServingBinding(context: LoadedModelContext, supplied?: ModelBinding): Promise<ModelBinding> {
  if (supplied) return supplied;
  const [{ declaredGraph, embeddingDeclarationFor }, { embedMany, embeddingTerminatorId, isEmbeddingModel }, { bindMlxGateway }, { MLX_VERSION, deviceArchitecture }, ops, { sequenceHiddenOperation, sequenceLogitsOperation, scoreDecisionAnswers }] = await Promise.all([
    import("@mlx-bun/inference/models"), import("@mlx-bun/inference/embeddings"),
    import("@mlx-bun/inference/execution"), import("@mlx-bun/mlx/ffi"), import("@mlx-bun/mlx/ops"), import("@mlx-bun/inference/scoring"),
  ]);
  const ctx = context as ModelContext;
  const model = ctx.model;
  const scoring = model as { readonly sequence?: readonly MlxSequenceRange[]; readonly sequenceHidden?: MlxSequenceForward;
    readonly sequenceLogits?: readonly MlxHeadRange[]; readonly logitsFromHidden?: MlxHeadForward };
  if (typeof model.makeCache !== "function")
    throw new Error("model implementation must supply its serving binding");
  const graph = declaredGraph(model);
  const hasSequence = !!scoring.sequence?.some(range => typeof range.operation === "function") || typeof scoring.sequenceHidden === "function";
  const hasHead = !!scoring.sequenceLogits?.some(range => typeof range.operation === "function") || typeof scoring.logitsFromHidden === "function";
  const adapters = typeof model.loraTargets === "function" && model.loraTargets().size > 0;
  const gateway = bindMlxGateway(model, ctx.draft ?? undefined);
  const capabilities = gateway.capabilities;
  const embedding = isEmbeddingModel(model);
  const declaration = embedding ? embeddingDeclarationFor(ctx.profile) : null;
  if (embedding && !declaration) throw new Error(`profile ${ctx.profile.profile.id} declares no embedding recipe for its embedding graph`);
  const terminator = declaration ? embeddingTerminatorId(ctx.tokenizer, declaration.terminator) : 0;
  return {
    stateCompatibility: `mlx-${MLX_VERSION}-${deviceArchitecture()}`,
    gateway,
    async signal(ids, count, minimum) {
      if (!hasSequence || !hasHead) throw new TypeError("model declares no full-sequence scoring operation for signal");
      const caches = model.makeCache();
      try {
        // The whole prompt as one window (the scoring forward), the head over every position.
        const input = ops.fromInt32(ids, [1, ids.length]);
        let hidden;
        try { hidden = sequenceHiddenOperation(scoring, input, caches, ids.length); } finally { input.dispose(); }
        let logits;
        try { logits = sequenceLogitsOperation(model, hidden); } finally { hidden.dispose(); }
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
    discovery: { adapters, training: adapters && ((hasSequence && hasHead) || typeof graph.trainable?.denoising?.canvasLogits === "function"),
      dsa: capabilities.sparseAttention, embeddings: embedding, decisions: hasSequence && hasHead && !embedding },
    ...(embedding ? { embed: (inputs: string[], instruction?: string) => embedMany(model, ctx.tokenizer, terminator, inputs, instruction) } : {}),
    ...(hasSequence && hasHead && !embedding ? { decide: async ({ prompt, candidates, vision, signal, execute }: Parameters<NonNullable<ModelBinding["decide"]>>[0]) => {
      if (vision && !graph.bindMediaInput) throw new TypeError("graph declares no media input for decisions");
      return (await scoreDecisionAnswers({ makeCache: () => model.makeCache(),
        forward: (ids, cache, rows) => sequenceHiddenOperation(scoring, ids, cache, rows),
        logits: hidden => sequenceLogitsOperation(model, hidden) }, prompt, candidates,
        { signal, execute, ...(vision ? { input: graph.bindMediaInput!(vision) } : {}) })).probabilities;
    } } : {}),
    diagnostics() {
      const runtime = ctx.runtimeDiagnostics?.();
      return { ...(ctx.composition ? { composition: compositionWire(ctx.composition) } : {}), ...(runtime ? { runtime } : {}) };
    },
  };
}
