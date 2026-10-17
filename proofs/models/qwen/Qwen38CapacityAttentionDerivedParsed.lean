import models.qwen.Qwen38CapacityAttentionCache
import models.qwen.CapacityAttentionDerivedNative
namespace Inference.Models.Qwen.Qwen38CapacityAttentionDerivedParsed
open Contracts.Mlx Layers DecodeStage DecodeChain Kernels.Attention Qwen38TrellisM1Max
set_option maxRecDepth 10000
attribute [local irreducible] Graph.stages
variable {n : Nat} {graph : Graph} {cache : graph.Cache n} {input : Row BF} {angle : RopeAngles.Inputs}
  (execution : Qwen38CapacityAttentionExecution.Execution graph cache input angle)
  (inputs : CapacityAttentionDerivedNative.Inputs graph.stages cache input angle execution.source execution.storage execution.chain)
  (ranges : Ranges graph.stages cache input angle) (supported : n+1≤262144)

def native := CapacityAttentionDerivedNative.native graph.stages cache input angle execution.source execution.storage
  execution.chain inputs ranges supported

theorem parsed : CapacityAttentionChainParsed.Parsed graph.stages cache input angle execution.source execution.storage
    execution.chain (native execution inputs ranges supported) :=
  CapacityAttentionDerivedNative.parsed _ _ _ _ _ _ _ inputs ranges supported

theorem parsed_result (safe : Qwen38CapacityAttentionCache.Safe execution) :
    CapacityAttentionChainParsed.Parsed graph.stages cache input angle execution.source execution.storage execution.chain
      (native execution inputs ranges supported) ∧
    Qwen38CapacityAttentionCache.readResult execution safe=
      (graph.forward cache input angle,(DecodeChain.run graph.stages cache input angle).2) ∧
    0<n ∧ graph.stages.length=64 ∧ (graph.stages.filter isAttention).length=16 ∧
      (graph.stages.filter (fun stage => !isAttention stage)).length=48 :=
  ⟨parsed execution inputs ranges supported,Qwen38CapacityAttentionCache.read_result_eq execution safe,
    execution.positive,graph.layer_count,graph.attention_count,graph.delta_count⟩
end Inference.Models.Qwen.Qwen38CapacityAttentionDerivedParsed
