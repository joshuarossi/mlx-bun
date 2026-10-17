import models.qwen.Qwen38TrellisParsedLayers
import models.qwen.Qwen38TrellisM1MaxConstruction
namespace Inference.Models.Qwen.Qwen38TrellisParsedExecution
open Contracts.Mlx Layers DecodeStage DecodeChain Kernels.Attention Qwen38TrellisM1Max
set_option maxRecDepth 10000
attribute [local irreducible] Graph.stages

variable {graph : Graph} {cache : graph.Cache n} {input : Row BF} {angle : RopeAngles.Inputs}
  {source : ArrayStorage.BFBuffer input} {storage : DecodeFrame.Storage graph.stages cache source.bytes}
  (parameters : DecodeParameterMemory.Storage graph.stages source.bytes)
  (plan : DecodeParameterConstruction.ChainPlan graph.stages .root cache input angle source storage parameters)
  (safe : DecodeParameterConstruction.CacheRegions graph.stages .root cache input angle source storage parameters plan)
  (finalParameters : FinalProjectionConstruction.Storage graph.finalNorm graph.output (graph.hidden cache input angle))
  (linked : finalParameters.source=DecodeParameterConstruction.outputBuffer graph.stages .root cache input angle source storage parameters plan)
  (allocation : FinalProjectionConstruction.Allocation finalParameters)

def execution : Qwen38TrellisM1MaxMemory.Execution graph cache input angle :=
  Qwen38TrellisM1MaxConstruction.fromChain
    (DecodeParameterConstruction.chain graph.stages .root cache input angle source storage parameters plan)
    (DecodeParameterConstruction.cacheSafe graph.stages .root cache input angle source storage parameters plan safe)
    finalParameters linked allocation

theorem same_chain : (execution parameters plan safe finalParameters linked allocation).chain=
    DecodeParameterConstruction.chain graph.stages .root cache input angle source storage parameters plan := rfl

-- The parsed 64-layer witness and logits refer to one constructed execution.
-- Final normalization/projection retain their explicit execution contracts.
theorem parsed_logits
    (native : TrellisParsedParameterChain.Native graph.stages .root cache input angle source storage parameters plan) :
    TrellisParsedParameterChain.Parsed graph.stages .root cache input angle source storage parameters plan native ∧
    (execution parameters plan safe finalParameters linked allocation).logits=graph.forward cache input angle :=
  ⟨TrellisParsedParameterChain.parsed graph.stages .root cache input angle source storage parameters plan native,
    (execution parameters plan safe finalParameters linked allocation).logits_eq⟩
end Inference.Models.Qwen.Qwen38TrellisParsedExecution
