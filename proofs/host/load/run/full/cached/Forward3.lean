import host.load.run.full.cached.Result
import host.load.run.full.cached.Certificate3
import host.load.run.full.cached.Facts3
namespace Host.Load.Run.Full.Cached
open Host.Load.Extract Host.Load.Program Host.Mlx Host.Mlx.GlueStep Host.Mlx.FfiEval Host.Ts
open Inference.Models.Qwen
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
variable {C : Inference.Contracts.Mlx.M1Max.Contract} (M : MlxContract C) (K : KernelContract C)
    (env : FfiEval.Env InKey) (table : List F64)
theorem terminal_forward3 (leaves : Leaves code env.weights) (typed : TypedCheckpoint env.weights)
    (parameters : TokenSequenceRanges.Parameters (firstPipeline M K env table leaves typed))
    (previous : ForwardResult M K env table leaves typed parameters 2 (by decide) after2.cache 20157) :
    ForwardResult M K env table leaves typed parameters 3 (by decide) after3.cache 22538 := by
  obtain ⟨hs,hr,hh,hc⟩ := previous
  exact terminal_cached_forward M K env table leaves typed parameters 2 (by decide)
    after2 after3.cache token3 20157 22538 hs Expected3.graph Expected3.tokenNode
    Expected3.cacheOutputs carriers3 before3_model
    (cache_classes2 (contents M K env (firstFfiGraph table)))
    (cache_shapes_checked2 table) (feedback3_node table) (by decide) original3
    (certificate3.matches table) (certificate3.inputs table) output3_caches output3_token hh hc hr
end Host.Load.Run.Full.Cached
