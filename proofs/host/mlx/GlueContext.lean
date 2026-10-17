import host.mlx.GlueStep
import models.qwen.ReachedTokenContext
namespace Host.Mlx.GlueContext
open Inference Inference.Contracts.Mlx Inference.Kernels Inference.Layers
open Inference.Models.Qwen WrittenLayers GlueLayers GlueStep
open FloatLib FloatLib.Floats FloatLib.Floats.Formats.BinaryInterchange
variable {C : M1Max.Contract} (M : MlxContract C) (K : KernelContract C)

-- One autoregressive step of ReachedTokenContext: from handles holding the
-- context's cache at `time`, the trace returns the context's next token and
-- handles holding its next cache.
theorem context_step (p : TokenInference.Pipeline) (w : PipelineWeights) (hl : PipelineLoaded M K p w)
    (context : ReachedTokenContext.Context p) (sampling : context.sampling = K.sampling)
    (token : Fin 248320) (time : Nat) (supported : time+1 ≤ 262144)
    (angle : context.angles.value time = RopeInputConstruction.inputs time)
    (hs : List Handles) (hh : ChainHolds p.graph.stages hs (context.run token time (by omega)).cache)
    (policy : M.logAddExp = Delta.MlxLogAddExpSource.legacyPolicy)
    (finite : DecayFinite p.graph.stages (context.run token time (by omega)).cache
      (p.embedding.forward (context.run token time (by omega)).token) (RopeInputConstruction.inputs time))
    (bound : ∀ i, Model.isFinite ((p.run (context.run token time (by omega)).cache (context.run token time (by omega)).token
        (RopeInputConstruction.inputs time)).1 i) = true ∧
      |Model.toReal ((p.run (context.run token time (by omega)).cache (context.run token time (by omega)).token
        (RopeInputConstruction.inputs time)).1 i)| ≤ (2:ℝ)^(23:Nat)) :
    ∃ hs', stepTrace M K w time (context.run token time (by omega)).token.val hs =
        some ((context.run token (time+1) supported).token.val, hs') ∧
      ChainHolds p.graph.stages hs' (context.run token (time+1) supported).cache := by
  have primitive : Sampling.LogSumExpRanges.Primitives K.sampling := sampling ▸ context.samplingPrimitive
  obtain ⟨hs', e, h'⟩ := step M K p w hl _ hs hh _ policy finite primitive bound
  obtain ⟨et, ec⟩ := context.run_step token time supported
  refine ⟨hs', ?_, ?_⟩
  · rw [et, sampling, angle]; exact e
  · rw [ec, angle]; exact h'

end Host.Mlx.GlueContext
