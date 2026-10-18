import host.load.run.full.cached.Result
import host.load.run.full.cached.Certificate5
import host.load.run.full.cached.Facts5
namespace Host.Load.Run.Full.Cached
open Host.Load.Extract Host.Load.Program Host.Mlx Host.Mlx.GlueStep Host.Mlx.FfiEval Host.Ts
open Inference.Models.Qwen
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
variable {C : Inference.Contracts.Mlx.M1Max.Contract} (M : MlxContract C) (K : KernelContract C)
    (env : FfiEval.Env InKey) (table : List F64)
theorem terminal_forward5 (leaves : Leaves code env.weights) (typed : TypedCheckpoint env.weights)
    (parameters : TokenSequenceRanges.Parameters (firstPipeline M K env table leaves typed))
    (previous : ForwardResult M K env table leaves typed parameters 4 (by decide) after4.cache 24919) :
    ForwardResult M K env table leaves typed parameters 5 (by decide) after5.cache 27300 := by
  obtain ⟨hs,hr,hh,hc⟩ := previous
  exact terminal_cached_forward M K env table leaves typed parameters 4 (by decide)
    after4 after5.cache token5 24919 27300 hs Expected5.graph Expected5.tokenNode
    Expected5.cacheOutputs carriers5 before5_model
    (cache_classes4 (contents M K env (firstFfiGraph table)))
    (cache_shapes_checked4 table) (feedback5_node table) (by decide) original5
    (certificate5.matches table) (certificate5.inputs table) output5_caches output5_token hh hc hr
end Host.Load.Run.Full.Cached
