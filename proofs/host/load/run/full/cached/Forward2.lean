import host.load.run.full.cached.Result
import host.load.run.full.cached.Certificate2
import host.load.run.full.cached.Facts2
namespace Host.Load.Run.Full.Cached
open Host.Load.Extract Host.Load.Program Host.Mlx Host.Mlx.GlueStep Host.Mlx.FfiEval Host.Ts
open Inference.Models.Qwen
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
variable {C : Inference.Contracts.Mlx.M1Max.Contract} (M : MlxContract C) (K : KernelContract C)
    (env : FfiEval.Env InKey) (table : List F64)
theorem terminal_forward2 (leaves : Leaves code env.weights) (typed : TypedCheckpoint env.weights)
    (parameters : TokenSequenceRanges.Parameters (firstPipeline M K env table leaves typed))
    (previous : ForwardResult M K env table leaves typed parameters 1 (by decide) firstChoice.cache 17776) :
    ForwardResult M K env table leaves typed parameters 2 (by decide) after2.cache 20157 := by
  obtain ⟨hs,hr,hh,hc⟩ := previous
  exact terminal_cached_forward M K env table leaves typed parameters 1 (by decide)
    firstChoice after2.cache token2 17776 20157 hs Expected2.graph Expected2.tokenNode
    Expected2.cacheOutputs carriers2 before2_model
    (cache_classes1 (contents M K env (firstFfiGraph table)))
    (cache_shapes_checked1 table) (feedback2_node table) (by decide) original2
    (certificate2.matches table) (certificate2.inputs table) output2_caches output2_token hh hc hr
end Host.Load.Run.Full.Cached
