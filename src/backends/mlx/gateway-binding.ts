import type { ModelConfig } from "../../config";
import type { KvScheme } from "../../kv-scheme";
import type { RuntimeModel } from "../../model/factory";
import { DiffusionGemmaModel } from "../../model/diffusion-gemma";
import { UniversalDenseModel } from "../../model/universal/dense";
import { KVCache, RotatingKVCache, isBatchableCache, isPlainKvCache, isRotatingPlainCache } from "../../model/gemma4-base";
import { SSMCache } from "../../model/qwen3-delta";
import { runtimeConfig, type RuntimeConfig } from "../../runtime-config";
import { disposeResources } from "../../engine/resources";
import { legacyCompiledDecodeAvailable } from "./autoregressive";
import { MlxBatchExecutionGroup, type MlxBatchExecutionGroupOptions } from "./batch-group";
import type { GenerateOptions } from "../../generate";
import type { ExecutionRequirements, ResolvedExecution } from "../../contracts/execution";
import { resolveExecution } from "../../engine/execution-plan";

export interface MlxBatchGroup extends Pick<MlxBatchExecutionGroup,
  "activeRows" | "pendingRows" | "projectedKvBytes" | "kvBudgetBytes" | "submit" | "kick" | "close"> {}

/** A model implementation owns capability checks and the execution group.
 * Scheduling never inspects concrete model/cache classes. */
export interface MlxGatewayBinding {
  readonly config: ModelConfig;
  readonly runtime: RuntimeConfig;
  plan(request: ExecutionRequirements, options: GenerateOptions,
    scheduling: { continuous: boolean; quantizedBatch: boolean; checkpoints: boolean }): ResolvedExecution;
  cachesBatchable(): boolean;
  kvBatchable(scheme: KvScheme): boolean;
  createBatchGroup(options: MlxBatchExecutionGroupOptions): MlxBatchGroup;
}

export function bindMlxGateway(model: RuntimeModel): MlxGatewayBinding {
  const runtime = runtimeConfig();
  return {
    config: model.config, runtime,
    plan(request, options, scheduling) {
      return resolveExecution(request, {
        ...scheduling,
        method: model instanceof DiffusionGemmaModel ? "denoising" : "autoregressive",
        compiledDecode: legacyCompiledDecodeAvailable(model),
        grammarBatch: runtime.value("MLX_BUN_GRAMMAR_BATCH") !== "0",
      }, {
        pagedKv: !!options.pagedKv, fill: !!options.fill,
        compiledDecode: runtime.flag("MLX_BUN_COMPILED_DECODE", true),
        grammarJump: runtime.flag("MLX_BUN_GRAMMAR_JUMP", false),
      });
    },
    cachesBatchable() {
      if (model instanceof UniversalDenseModel)
        return !model.args.maskArray && !model.args.layerTypes?.includes("sliding_attention");
      const caches = model.makeCache();
      try {
        const ssm = runtime.value("MLX_BUN_BATCH_SSM") !== "0";
        return caches.every((cache) => cache instanceof KVCache || cache instanceof RotatingKVCache ||
          isBatchableCache(cache) || (ssm && cache instanceof SSMCache));
      } finally { disposeResources(caches); }
    },
    kvBatchable(scheme) {
      if (scheme.kind !== "affine-config") return false;
      const caches = model.makeCache();
      try {
        return scheme.batchable(model.config,
          (layer) => isPlainKvCache(caches[layer]) || isRotatingPlainCache(caches[layer]));
      } finally { disposeResources(caches); }
    },
    createBatchGroup: (options) => new MlxBatchExecutionGroup(model, options),
  };
}
