import models.qwen.CopiedAttentionInitialReadAllocation
import models.qwen.CopiedAttentionPositiveReuseAllocation
namespace Inference.Models.Qwen.CopiedAttentionReadHighWater
open Contracts.Mlx Layers State Kernels.Attention
set_option maxRecDepth 10000

structure Bounds {n : Nat} {query : Fin 24 → Fin 256 → ArrayStorage.BF} {cache : Kv.Cache Kv.BF n}
    {gate : Fin 24 → Fin 256 → ArrayStorage.BF}
    (input : SdpaMemory.Input query cache) (gates : ∀ head, ArrayStorage.BFBuffer (gate head)) (frontier : Nat) : Prop where
  keys : input.cache.layout.keyBase+KvRegions.bytes n≤frontier
  values : input.cache.layout.valueBase+KvRegions.bytes n≤frontier
  queries : ∀ head, (input.query head).base+512≤frontier
  gates : ∀ head, (gates head).base+512≤frontier

private theorem initial_query_base {layer : Attention.Layer} {input : Fin 5120 → ArrayStorage.BF} {angle : RopeAngles.Inputs}
    {front : AttentionGateCopyFront.Execution layer input angle} {cache : Kv.Cache Kv.BF 0}
    (read : AttentionGateCopyInitialRead.Read front cache) (head : Fin 24) :
    (read.input.query head).base=(front.query head).base := rfl
private theorem initial_gate_base {layer : Attention.Layer} {input : Fin 5120 → ArrayStorage.BF} {angle : RopeAngles.Inputs}
    {front : AttentionGateCopyFront.Execution layer input angle} {cache : Kv.Cache Kv.BF 0}
    (read : AttentionGateCopyInitialRead.Read front cache) (head : Fin 24) :
    (read.gate head).base=(front.gate head).base := rfl

namespace Initial
variable {layer : Attention.Layer} {input : Fin 5120 → ArrayStorage.BF} {angle : RopeAngles.Inputs}
  {front : AttentionGateCopyFront.Execution layer input angle} (request : CopiedAttentionInitialReadAllocation.Request front)
  (cache : Kv.Cache Kv.BF 0)

theorem key_base : (CopiedAttentionInitialReadAllocation.read request cache).input.cache.layout.keyBase=request.cursor := rfl
theorem value_base : (CopiedAttentionInitialReadAllocation.read request cache).input.cache.layout.valueBase=request.cursor+KvRegions.bytes 1 := rfl

theorem bounds : Bounds (CopiedAttentionInitialReadAllocation.read request cache).input
    (CopiedAttentionInitialReadAllocation.read request cache).gate (request.cursor+CopiedAttentionInitialReadAllocation.bytes) where
  keys := by rw [key_base]; change request.cursor+KvRegions.bytes 1≤_; unfold CopiedAttentionInitialReadAllocation.bytes; omega
  values := by rw [value_base]; change request.cursor+KvRegions.bytes 1+KvRegions.bytes 1≤_; unfold CopiedAttentionInitialReadAllocation.bytes; omega
  queries := fun head => by rw [initial_query_base]; have := request.queries head; omega
  gates := fun head => by rw [initial_gate_base]; have := request.gates head; omega
end Initial

private theorem positive_query_base {layer : Attention.Layer} {n : Nat} {cache : Kv.Cache Kv.BF n}
    {input : Fin 5120 → ArrayStorage.BF} {angle : RopeAngles.Inputs}
    {s : AttentionGateCopyReadConstruction.Input layer cache input angle} {p : AttentionGateCopyFreshRead.Prepared s}
    (read : AttentionGateCopyFreshRead.Read p) (head : Fin 24) : (read.input.query head).base=(s.front.query head).base := rfl
private theorem positive_gate_base {layer : Attention.Layer} {n : Nat} {cache : Kv.Cache Kv.BF n}
    {input : Fin 5120 → ArrayStorage.BF} {angle : RopeAngles.Inputs}
    {s : AttentionGateCopyReadConstruction.Input layer cache input angle} {p : AttentionGateCopyFreshRead.Prepared s}
    (read : AttentionGateCopyFreshRead.Read p) (head : Fin 24) : (read.gate head).base=(s.front.gate head).base := rfl

namespace Positive
variable {layer : Attention.Layer} {n : Nat} {cache : Kv.Cache Kv.BF n}
  {input : Fin 5120 → ArrayStorage.BF} {angle : RopeAngles.Inputs}
  {s : AttentionGateCopyReadConstruction.Input layer cache input angle} (request : CopiedAttentionPositiveReuseAllocation.Request s)

theorem key_base : (CopiedAttentionPositiveReuseAllocation.read request).input.cache.layout.keyBase=request.cursor := rfl
theorem value_base : (CopiedAttentionPositiveReuseAllocation.read request).input.cache.layout.valueBase=request.cursor+KvRegions.bytes (n+1) := rfl

theorem bounds : Bounds (CopiedAttentionPositiveReuseAllocation.read request).input
    (CopiedAttentionPositiveReuseAllocation.read request).gate (request.cursor+CopiedAttentionPositiveReuseAllocation.bytes n) where
  keys := by rw [key_base]; unfold CopiedAttentionPositiveReuseAllocation.bytes; omega
  values := by rw [value_base]; unfold CopiedAttentionPositiveReuseAllocation.bytes; omega
  queries := fun head => by rw [positive_query_base]; have := request.queries head; omega
  gates := fun head => by rw [positive_gate_base]; have := request.gates head; omega
end Positive
end Inference.Models.Qwen.CopiedAttentionReadHighWater
