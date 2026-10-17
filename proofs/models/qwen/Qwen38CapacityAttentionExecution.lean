import models.qwen.CapacityAttentionChainParsed
import models.qwen.Qwen38TrellisM1Max
import models.qwen.FinalProjectionConstruction
namespace Inference.Models.Qwen.Qwen38CapacityAttentionExecution
open Contracts.Mlx Layers DecodeStage DecodeChain Kernels.Attention Qwen38TrellisM1Max
set_option maxRecDepth 10000
variable {n : Nat}
attribute [local irreducible] Graph.stages

-- A separate execution type preserves the copied-attention events. There is
-- no conversion to the older Q/K/V-only attention prefix or chain type.
structure Execution (graph : Graph) {n : Nat} (cache : graph.Cache n) (input : Row BF) (angle : RopeAngles.Inputs) where
  positive : 0<n
  source : ArrayStorage.BFBuffer input
  storage : DecodeFrame.Storage graph.stages cache source.bytes
  chain : CapacityAttentionDecodeChain.Trace graph.stages cache input angle source storage
  safe : CapacityAttentionDecodeChain.CacheSafe graph.stages cache input angle source storage chain
  finalParameters : FinalProjectionConstruction.Storage graph.finalNorm graph.output (graph.hidden cache input angle)
  linked : finalParameters.source=CapacityAttentionDecodeChain.outputBuffer graph.stages cache input angle source storage chain
  allocation : FinalProjectionConstruction.Allocation finalParameters

variable {graph : Graph} {cache : graph.Cache n} {input : Row BF} {angle : RopeAngles.Inputs}
  (execution : Execution graph cache input angle)

def projection := FinalProjectionConstruction.output execution.finalParameters execution.allocation
def logitsBuffer := (projection execution).outputBuffer

theorem read_eq (column : Fin 248320) : (logitsBuffer execution).read column=graph.forward cache input angle column :=
  ((logitsBuffer execution).read_correct column).trans (congrFun (projection execution).output_eq column)

-- Positive cache preparation and each optional full preservation copy remain
-- in the typed source chain. Initial direct-zero executions use a separate type.
theorem parsed
    (native : CapacityAttentionChainParsed.Native graph.stages cache input angle execution.source execution.storage execution.chain) :
    CapacityAttentionChainParsed.Parsed graph.stages cache input angle execution.source execution.storage execution.chain native ∧
    graph.stages.length=64 ∧ (graph.stages.filter isAttention).length=16 ∧
    (graph.stages.filter (fun stage => !isAttention stage)).length=48 ∧
    (∀ column, (logitsBuffer execution).read column=graph.forward cache input angle column) :=
  ⟨CapacityAttentionChainParsed.checked graph.stages cache input angle execution.source execution.storage execution.chain native,
    graph.layer_count,graph.attention_count,graph.delta_count,read_eq execution⟩
end Inference.Models.Qwen.Qwen38CapacityAttentionExecution
