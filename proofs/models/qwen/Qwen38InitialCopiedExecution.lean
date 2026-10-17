import models.qwen.InitialCopiedChainParsed
import models.qwen.Qwen38TrellisM1Max
import models.qwen.FinalProjectionConstruction
namespace Inference.Models.Qwen.Qwen38InitialCopiedExecution
open Contracts.Mlx Layers DecodeStage DecodeChain Kernels.Attention Qwen38TrellisM1Max
set_option maxRecDepth 10000
attribute [local irreducible] Graph.stages

-- A separate execution type preserves the copied-attention events. There is
-- no conversion to the older Q/K/V-only attention prefix or chain type.
structure Execution (graph : Graph) (cache : graph.Cache 0) (input : Row BF) (angle : RopeAngles.Inputs) where
  source : ArrayStorage.BFBuffer input
  storage : DecodeFrame.Storage graph.stages cache source.bytes
  chain : InitialCopiedDecodeChain.Trace graph.stages cache input angle source storage
  safe : InitialCopiedDecodeChain.CacheSafe graph.stages cache input angle source storage chain
  finalParameters : FinalProjectionConstruction.Storage graph.finalNorm graph.output (graph.hidden cache input angle)
  linked : finalParameters.source=InitialCopiedDecodeChain.outputBuffer graph.stages cache input angle source storage chain
  allocation : FinalProjectionConstruction.Allocation finalParameters

variable {graph : Graph} {cache : graph.Cache 0} {input : Row BF} {angle : RopeAngles.Inputs}
  (execution : Execution graph cache input angle)

def projection := FinalProjectionConstruction.output execution.finalParameters execution.allocation
def logitsBuffer := (projection execution).outputBuffer

theorem read_eq (column : Fin 248320) : (logitsBuffer execution).read column=graph.forward cache input angle column :=
  ((logitsBuffer execution).read_correct column).trans (congrFun (projection execution).output_eq column)

-- The first-token route retains direct zero-slab initialization and both
-- native ownership branches; it contains no empty-cache concatenation.
theorem parsed
    (native : InitialCopiedChainParsed.Native graph.stages cache input angle execution.source execution.storage execution.chain) :
    InitialCopiedChainParsed.Parsed graph.stages cache input angle execution.source execution.storage execution.chain native ∧
    graph.stages.length=64 ∧ (graph.stages.filter isAttention).length=16 ∧
    (graph.stages.filter (fun stage => !isAttention stage)).length=48 ∧
    (∀ column, (logitsBuffer execution).read column=graph.forward cache input angle column) :=
  ⟨InitialCopiedChainParsed.checked graph.stages cache input angle execution.source execution.storage execution.chain native,
    graph.layer_count,graph.attention_count,graph.delta_count,read_eq execution⟩
end Inference.Models.Qwen.Qwen38InitialCopiedExecution
