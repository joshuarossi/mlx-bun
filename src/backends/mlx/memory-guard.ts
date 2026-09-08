import { DEFAULT_CHUNK, TRANSIENT_PER_TOKEN } from "../../fit";
import { kvBytesAt, type KvSchemeOptions } from "../../kv-scheme";
import { activeMemory, clearCache, maxRecommendedWorkingSetSize } from "../../mlx/ffi";
import type { RuntimeModel } from "../../model/factory";
import { Qwen35Model } from "../../model/qwen3_5";
import type { PromptCache } from "../../prompt-cache";
import { runtimeValue } from "../../runtime-config";

/** Admission's ceiling and the cache that can release memory under the GPU lease. */
export interface MlxMemoryBudget {
  readonly usableBytes: number;
  readonly kvOptions: KvSchemeOptions;
  readonly promptCache: Pick<PromptCache, "relievePressure" | "totalBytes">;
}

/** Both execution paths enter after acquiring the request's reusable prefix.
 * The caller owns the GPU lease and must close the scope on every exit. */
export function enterMlxMemoryGuard(model: RuntimeModel, budget: MlxMemoryBudget,
  promptTokens: number, prefillChunkSize?: number): { check(): void; close(): void } {
  const reserve = (prefillChunkSize ?? DEFAULT_CHUNK) * TRANSIENT_PER_TOKEN +
    kvBytesAt(model.config, promptTokens, budget.kvOptions);
  const ceiling = Math.min(budget.usableBytes, maxRecommendedWorkingSetSize());
  const check = () => {
    if (activeMemory() + reserve <= ceiling) return;
    clearCache();
    if (runtimeValue("MLX_BUN_PREFILL_MEM_LOG") === "1")
      console.error(`[cache-memory] active=${activeMemory()} prompt=${budget.promptCache.totalBytes} reserve=${reserve} ceiling=${ceiling}`);
    const count = budget.promptCache.relievePressure(() => {
      clearCache();
      return activeMemory() + reserve > ceiling;
    });
    if (count) console.log(`[prompt-cache] demoted ${count} entries for GPU headroom`);
    if (activeMemory() + reserve > ceiling)
      throw new Error("insufficient GPU headroom after prompt-cache demotion; saved generation checkpoints are retained");
  };
  const qwen = model instanceof Qwen35Model ? model : undefined;
  const previous = qwen?.prefillMemoryGuard;
  if (qwen) qwen.prefillMemoryGuard = check;
  return { check, close() { if (qwen) qwen.prefillMemoryGuard = previous ?? null; } };
}
