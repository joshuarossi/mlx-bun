import host.load.run.full.cached.Result
import host.load.run.full.cached.Certificate4
import host.load.run.full.cached.Facts4
namespace Host.Load.Run.Full.Cached
open Host.Load.Extract Host.Load.Program Host.Mlx Host.Mlx.GlueStep Host.Mlx.FfiEval Host.Ts
open Inference.Models.Qwen
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
variable {C : Inference.Contracts.Mlx.M1Max.Contract} (M : MlxContract C) (K : KernelContract C)
    (env : FfiEval.Env InKey) (table : List F64)
theorem terminal_forward4 (leaves : Leaves code env.weights) (typed : TypedCheckpoint env.weights)
    (parameters : TokenSequenceRanges.Parameters (firstPipeline M K env table leaves typed))
    (previous : ForwardResult M K env table leaves typed parameters 3 (by decide) after3.cache 22538) :
    ForwardResult M K env table leaves typed parameters 4 (by decide) after4.cache 24919 := by
  obtain ⟨hs,hr,hh,hc⟩ := previous
  exact terminal_cached_forward M K env table leaves typed parameters 3 (by decide)
    after3 after4.cache token4 22538 24919 hs Expected4.graph Expected4.tokenNode
    Expected4.cacheOutputs carriers4 before4_model
    (cache_classes3 (contents M K env (firstFfiGraph table)))
    (cache_shapes_checked3 table) (feedback4_node table) (by decide) original4
    (certificate4.matches table) (certificate4.inputs table) output4_caches output4_token hh hc hr
end Host.Load.Run.Full.Cached
