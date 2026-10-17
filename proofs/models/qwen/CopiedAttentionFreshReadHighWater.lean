import models.qwen.CopiedAttentionReadHighWater
import models.qwen.CopiedAttentionGrowthPreparation
namespace Inference.Models.Qwen.CopiedAttentionFreshReadHighWater
open Contracts.Mlx Layers State Kernels.Attention
set_option maxRecDepth 10000
variable {layer : Attention.Layer} {n : Nat} {cache : Kv.Cache Kv.BF n}
  {input : Fin 5120 → ArrayStorage.BF} {angle : RopeAngles.Inputs}
  {s : AttentionGateCopyReadConstruction.Input layer cache input angle} {p : AttentionGateCopyFreshRead.Prepared s}
  (request : CopiedAttentionFreshAppendAllocation.Request p)

private theorem query_base (head : Fin 24) :
    ((CopiedAttentionFreshAppendAllocation.read request).input.query head).base=(s.front.query head).base := rfl
private theorem gate_base (head : Fin 24) :
    ((CopiedAttentionFreshAppendAllocation.read request).gate head).base=(s.front.gate head).base := rfl

theorem key_base : (CopiedAttentionFreshAppendAllocation.read request).input.cache.layout.keyBase=request.cursor := rfl
theorem value_base : (CopiedAttentionFreshAppendAllocation.read request).input.cache.layout.valueBase=request.cursor+KvRegions.bytes (n+1) := rfl

theorem bounds : CopiedAttentionReadHighWater.Bounds (CopiedAttentionFreshAppendAllocation.read request).input
    (CopiedAttentionFreshAppendAllocation.read request).gate (request.cursor+CopiedAttentionFreshAppendAllocation.bytes n) where
  keys := by rw [key_base]; unfold CopiedAttentionFreshAppendAllocation.bytes; omega
  values := by rw [value_base]; unfold CopiedAttentionFreshAppendAllocation.bytes; omega
  queries := fun head => by rw [query_base]; have := request.queries head; omega
  gates := fun head => by rw [gate_base]; have := request.gates head; omega

variable (growth : CopiedAttentionGrowthPreparation.Request s)
theorem growth_bounds : CopiedAttentionReadHighWater.Bounds (CopiedAttentionGrowthPreparation.read growth).input
    (CopiedAttentionGrowthPreparation.read growth).gate
    (growth.cursor+KvGrowthAllocation.bytes n+CopiedAttentionFreshAppendAllocation.bytes n) :=
  bounds (CopiedAttentionGrowthPreparation.appendRequest growth)
end Inference.Models.Qwen.CopiedAttentionFreshReadHighWater
