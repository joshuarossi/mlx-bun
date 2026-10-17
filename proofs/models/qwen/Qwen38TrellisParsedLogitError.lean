import models.qwen.Qwen38TrellisParsedExecution
namespace Inference.Models.Qwen.Qwen38TrellisParsedLogitError
open Contracts.Mlx Layers DecodeStage DecodeChain Kernels.Attention Qwen38TrellisM1Max
open FloatLib FloatLib.Floats FloatLib.Floats.Formats.BinaryInterchange
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

-- The observable is a load from the constructed final output heap.
theorem read_eq (column : Fin 248320) :
    (Qwen38TrellisParsedExecution.execution parameters plan safe finalParameters linked allocation).logitsBuffer.read column=
      graph.forward cache input angle column :=
  ((Qwen38TrellisParsedExecution.execution parameters plan safe finalParameters linked allocation).logitsBuffer.read_correct column).trans
    (congrFun (Qwen38TrellisParsedExecution.execution parameters plan safe finalParameters linked allocation).logits_eq column)

theorem parsed_error
    (native : TrellisParsedParameterChain.Native graph.stages .root cache input angle source storage parameters plan)
    (targetCache cacheError : graph.ReferenceCache n) (target error : Row ℝ) (aim angleError : RopeAngles.Target)
    (hi : ∀ i, |Model.toReal (input i)-target i|≤error i)
    (hif : ∀ i, Model.isFinite (input i)=true)
    (hc : DecodeChain.CacheErrors graph.stages cache targetCache cacheError)
    (hcf : DecodeChain.CachesFinite graph.stages cache) (ranges : graph.Ranges cache input angle)
    (ha : RopeAngles.InputError angle aim angleError) (hb : 0≤aim.base)
    (capacity : DecodeChain.Capacities graph.stages cache targetCache cacheError input target error angle aim angleError ranges.chain)
    (column : Fin 248320) :
    TrellisParsedParameterChain.Parsed graph.stages .root cache input angle source storage parameters plan native ∧
    |Model.toReal ((Qwen38TrellisParsedExecution.execution parameters plan safe finalParameters linked allocation).logitsBuffer.read column)-
      graph.target targetCache target aim column|≤graph.budget cache targetCache cacheError input target error angle aim angleError ranges column := by
  refine ⟨TrellisParsedParameterChain.parsed graph.stages .root cache input angle source storage parameters plan native,?_⟩
  rw [read_eq]
  exact graph.forward_error cache targetCache cacheError input target error angle aim angleError hi hif hc hcf ranges ha hb capacity column
end Inference.Models.Qwen.Qwen38TrellisParsedLogitError
