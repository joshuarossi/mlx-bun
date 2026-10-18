import host.load.boundary.growth.Certificate
import host.load.boundary.growth.CacheFacts
import host.load.boundary.growth.LoadGraph
import host.load.BoundaryForward
namespace Host.Load.Run.Full.Growth64
open Host.Load.Extract Host.Load.Program Host.Mlx Host.Mlx.GlueStep Host.Mlx.FfiEval Host.Ts
open Inference.Models.Qwen
set_option Elab.async false
set_option maxRecDepth 1000000
variable {C : Inference.Contracts.Mlx.M1Max.Contract} (M : MlxContract C) (K : KernelContract C)
    (env : Env InKey) (table : List F64)

/-- The actual source graph implements this capacity branch for all64 layers.
The incoming semantic cache and token remain explicit source-loop entry
obligations; output capacity and compatibility are derived. -/
theorem cached_forward (leaves : Leaves code env.weights) (typed : TypedCheckpoint env.weights)
    (parameters : TokenSequenceRanges.Parameters (firstPipeline M K env table leaves typed))
    (ids : Value) (hs : List Handles)
    (chain : ChainHolds (firstPipeline M K env table leaves typed).graph.stages hs
      ((firstContext M K env table leaves typed parameters).run promptToken 256 (by decide)).cache)
    (caches : CacheValues M K env (graph table) before.cache hs)
    (buffer : TokenBuffer ids
      ((firstContext M K env table leaves typed parameters).run promptToken 256 (by decide)).token.val)
    (tokenValue : evalR M K env (graph table) inputToken.node = some ids) :
    let next := (firstContext M K env table leaves typed parameters).run promptToken 257 (by decide)
    ∃ out, (∃ r, evalR M K env (graph table) 24983 = some r ∧ itemUint32 r = some next.token.val) ∧
      ChainHolds (firstPipeline M K env table leaves typed).graph.stages out next.cache ∧
      CacheValues M K env (graph table) after.cache out ∧
      List.Forall₂ CacheCompatible (stageWeights (weights (firstValues M K env table))) out ∧
      chainLayout (stageWeights (weights (firstValues M K env table))) out =
        chainLayout (stageWeights (weights (firstValues M K env table))) (populatedLayoutHandles 512) := by
  exact boundary_cached_forward M K env table leaves typed parameters 256 (by decide)
    s1521.ffi.mlx before after.cache inputToken ids hs Expected.graph Expected.tokenNode
    Expected.cacheOutputs carriers 24983 512 model_preserved.1
    (parameter_value M K env table leaves)
    (classes_before (contents M K env (firstFfiGraph table)))
    (classes_after (contents M K env (firstFfiGraph table)))
    (before_capacities_derived table) (capacities_derived table) original
    (certificate.matches table) (certificate.inputs table) cache_carriers output_token
    chain caches buffer tokenValue
end Host.Load.Run.Full.Growth64
