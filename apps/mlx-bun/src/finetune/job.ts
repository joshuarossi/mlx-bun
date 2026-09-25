import type { TrainConfig, trainLora } from "@mlx-bun/training";
import type { Weights, loadModelConfig } from "@mlx-bun/inference/artifacts";
import type { createModel } from "@mlx-bun/inference/models";
import type { loadTokenizer, ChatTemplate } from "@mlx-bun/inference/input";
import { cleanupFailure, disposeResources } from "@mlx-bun/inference/runtime/resources";
import type { JobRunner } from "../jobs/protocol";
import { parseFinetuneConfig } from "./config";

/** Child-local native resources. The parent job host owns the execution lease. */
export interface FinetuneRuntime {
  defaults: TrainConfig;
  loadConfig: typeof loadModelConfig;
  openWeights: typeof Weights.open;
  createModel: typeof createModel;
  loadTokenizer: typeof loadTokenizer;
  loadTemplate: typeof ChatTemplate.load;
  train: typeof trainLora;
  recommendedLimit(): number;
  setWiredLimit(limit: number): number;
  synchronize(): void;
}

async function loadRuntime(): Promise<FinetuneRuntime> {
  const [training, artifacts, models, input, ffi, array] = await Promise.all([
    import("@mlx-bun/training"), import("@mlx-bun/inference/artifacts"),
    import("@mlx-bun/inference/models"), import("@mlx-bun/inference/input"),
    import("@mlx-bun/mlx/ffi"), import("@mlx-bun/mlx/array"),
  ]);
  return {
    defaults: training.DEFAULT_TRAIN_CONFIG, loadConfig: artifacts.loadModelConfig,
    openWeights: dir => artifacts.Weights.open(dir), createModel: models.createModel,
    loadTokenizer: input.loadTokenizer, loadTemplate: dir => input.ChatTemplate.load(dir),
    train: training.trainLora, recommendedLimit: ffi.maxRecommendedWorkingSetSize,
    setWiredLimit: ffi.setWiredLimit, synchronize: () => ffi.synchronize(array.gpuStream),
  };
}

export function createFinetuneRunner(runtime: () => Promise<FinetuneRuntime> = loadRuntime): JobRunner {
  return async (emit, config, signal) => {
    // Reject incomplete jobs without loading MLX or creating any resources.
    for (const name of ["model_dir", "data_dir", "adapter_path"])
      if (typeof config[name] !== "string" || !config[name]) throw new Error(`finetune job: missing ${name}`);
    signal?.throwIfAborted();
    // The trainer cancels cooperatively at its step boundaries: started
    // checkpoint writes complete, earlier checkpoints stay, no final adapter is
    // written; the cleanup below then releases the model, weights and wired limit.
    const r = await runtime();
    const { modelDir, dataDir, cfg } = parseFinetuneConfig(config, r.defaults);
    emit({ type: "stage", stage: "load", progress: 0.01, message: `loading model ${modelDir}` });
    const modelConfig = await r.loadConfig(modelDir);
    if (cfg.method === "orpo" && !modelConfig.quantization && (cfg.orpoFlashCe || cfg.orpoFusedCe)) {
      emit({ type: "stage", stage: "load",
        message: "unquantized base — flash/fused-CE head needs a quantized head; using full-logits head" });
      cfg.orpoFlashCe = false;
      cfg.orpoFusedCe = false;
    }
    const owned: { dispose(): void }[] = [];
    const cleanup = () => disposeResources(owned.splice(0).reverse());
    let result: Awaited<ReturnType<typeof trainLora>>;
    try {
      signal?.throwIfAborted();
      const weights = await r.openWeights(modelDir);
      owned.push(weights);
      const model = r.createModel(weights, modelConfig);
      if ("dispose" in model && typeof model.dispose === "function") owned.push(model as { dispose(): void });
      const tokenizer = await r.loadTokenizer(modelDir);
      const template = await r.loadTemplate(modelDir);
      const oldLimit = r.setWiredLimit(r.recommendedLimit());
      // Reverse cleanup order: synchronize, restore wired memory, model, weights.
      owned.push({ dispose: () => { r.setWiredLimit(oldLimit); } }, { dispose: () => r.synchronize() });
      // Training observations already have the app event shape: pass every
      // field through unchanged. The job owner alone emits terminal lifecycle
      // events; a trainer stage named "done" remains an ordinary stage.
      result = await r.train(model, tokenizer, template, dataDir, cfg, emit, { signal });
    } catch (error) { return cleanupFailure(error, cleanup); }
    cleanup();
    return { outputPath: result.adapterPath };
  };
}
