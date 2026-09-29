// Runtimes that plan memory before opening any weights (streamed expert
// loaders). Callers pass generic options and receive a generic plan, the
// runtime's draft-head fact and its telemetry; which model owns the loader is
// decided here from the resolved profile, never by the application.

import type { MemoryPlan } from "../contracts/portable/memory-plan";
import type { DisposableResource } from "../contracts/portable/resources";
import { declaredGraph } from "./capabilities";
import { openGlm52RuntimeModel, type RuntimeModel } from "./factory";
import { plansMemory } from "./memory-plan";
import type { ResolvedModelProfile } from "./profile";

/** Options every planned runtime understands; a runtime ignores what it has no
 * use for. Unset values take the runtime's own preset. */
export interface RuntimeOpenOptions {
  /** Whole-process ceiling in bytes. */
  memoryBudgetBytes?: number;
  /** Context tokens the plan reserves. */
  contextTokens?: number;
  /** Generated-token allowance within `contextTokens`. */
  maxGenerationTokens?: number;
  /** Maximum ordinary continuous-batch rows. */
  batchSize?: number;
  /** The checkpoint-native draft head, on by default where the checkpoint has one. */
  nativeDraft?: boolean;
  /** Test/diagnostic override; normal callers use physical RAM. */
  machineBytes?: number;
  /** Native loader library override. */
  libraryPath?: string;
}

export interface OpenedRuntime {
  readonly model: RuntimeModel & DisposableResource;
  readonly memoryPlan: MemoryPlan;
  /** Draft tokens per round of the checkpoint-native draft head the runtime
   * planned for, or null when none is enabled. */
  readonly nativeDraftTokens: number | null;
  /** Runtime telemetry for status views: the plan's line items and live streaming state. */
  diagnostics(): Record<string, unknown>;
}

/** Open the profile's planned runtime. The plan runs before any resident tensor
 * or streaming tier is opened, so an impossible configuration fails without
 * committing memory. */
export async function openPlannedRuntime(
  modelDir: string, resolved: ResolvedModelProfile, options: RuntimeOpenOptions = {},
): Promise<OpenedRuntime> {
  if (!plansMemory(resolved))
    throw new Error(`profile ${resolved.profile.id} does not load through a planned runtime`);
  const { model, plan } = await openGlm52RuntimeModel(modelDir, {
    memoryBudgetBytes: options.memoryBudgetBytes, contextTokens: options.contextTokens,
    maxGenerationTokens: options.maxGenerationTokens, batchSize: options.batchSize,
    enableMtp: options.nativeDraft, machineBytes: options.machineBytes, libraryPath: options.libraryPath,
  });
  const sparse = declaredGraph(model).graphCapabilities.sparseAttention;
  return {
    model,
    memoryPlan: plan,
    nativeDraftTokens: plan.enableMtp ? plan.mtpDraftTokens : null,
    diagnostics: () => ({
      preset: plan.preset, planned_process_bytes: plan.plannedProcessBytes,
      process_limit_bytes: plan.processLimitBytes, context_tokens: plan.contextTokens,
      max_generation_tokens: plan.maxGenerationTokens, batch_size: plan.batchSize,
      dsa: sparse, mtp: plan.enableMtp,
      mtp_draft_tokens: plan.mtpDraftTokens, resident_weight_bytes: plan.lineItems.residentWeightsBytes,
      main_expert_slab_bytes: plan.lineItems.mainExpertSlabBytes,
      mtp_expert_slab_bytes: plan.lineItems.mtpExpertSlabBytes,
      expert_runtime: declaredGraph(model).expertResidency?.() ?? null,
    }),
  };
}
