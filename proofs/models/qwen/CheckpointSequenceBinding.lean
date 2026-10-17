import models.qwen.CheckpointNormalizationBinding
import models.qwen.CheckpointDeltaData
import models.qwen.HeadScaleConstruction
import models.qwen.TokenAutoregressive

namespace Inference.Models.Qwen.CheckpointSequenceBinding
open Contracts.Mlx
open FloatLib FloatLib.Floats FloatLib.Floats.Formats.BinaryInterchange
open Qwen38TrellisM1Max

-- Exact attachment obligations for the proved normalization literals and
-- the host-constructed head constants. These are not runtime bounds checks.
-- Native loader identity and Math.pow execution are still external bindings.
structure Bindings (g : Graph) : Prop extends CheckpointNormalizationBinding.Bindings g where
  headWidth : ∀ i, (g.delta i).mixer.headParams.width = Float32.ofInt 128
  headEps : ∀ i, (g.delta i).mixer.headParams.eps = Blocks.eps
  headQuery : ∀ i, (g.delta i).mixer.headParams.qScale = HeadScaleConstruction.query
  headKey : ∀ i, (g.delta i).mixer.headParams.kScale = HeadScaleConstruction.key
  aLog : ∀ i, (g.delta i).mixer.aLog = CheckpointDeltaData.aLog i
  dtBias : ∀ i, (g.delta i).mixer.dtBias = CheckpointDeltaData.dtBias i
  gatedNorm : ∀ i, (g.delta i).mixer.normWeight = CheckpointDeltaData.gatedNorm i

-- Other checkpoint tensors still require checked payload certificates.
-- No assumption about normalization, head scales, or decay-parameter
-- numerical bounds remains.
structure RemainingParameters (g : Graph) : Prop where
  deltaProjections : ∀ i, DeltaInputRanges.Parameters (g.delta i).mixer
  deltaOutput : ∀ i, DeltaOutputRanges.Parameters (g.delta i).mixer.out
  deltaConvolution : ∀ i c k, Model.isFinite ((g.delta i).mixer.convolutionWeight c k) = true ∧
    |Model.toReal ((g.delta i).mixer.convolutionWeight c k)| ≤ 1
  deltaMlp : ∀ i, TrellisMlpRanges.Parameters (g.delta i).suffix.mlp
  attentionProjections : ∀ i, AttentionInputRanges.Parameters (g.attention i).mixer.projections
  attentionOutput : ∀ i, DeltaOutputRanges.Parameters (g.attention i).mixer.output
  attentionMlp : ∀ i, TrellisMlpRanges.Parameters (g.attention i).suffix.mlp
  output : NormalizedAffineProjection.Parameters g.output

theorem heads (g : Graph) (binding : Bindings g) (layer : Fin 48) :
    DeltaHeadRanges.Parameters (g.delta layer).mixer := by
  refine ⟨binding.headWidth layer, binding.headEps layer, ?_, ?_⟩
  · intro i
    rw [binding.headQuery layer]
    have h := HeadScaleConstruction.query_bound i
    exact ⟨h.1, by rw [h.2]; norm_num⟩
  · intro i
    rw [binding.headKey layer]
    have h := HeadScaleConstruction.key_bound i
    exact ⟨h.1, by rw [h.2]; norm_num⟩

theorem initial_parameters (g : Graph) (binding : Bindings g) (remaining : RemainingParameters g) :
    Qwen38TrellisM1MaxInitialRanges.Parameters g :=
  CheckpointNormalizationBinding.parameters g binding.toBindings {
    deltaProjections := remaining.deltaProjections
    deltaHeads := heads g binding
    deltaGates := by
      intro layer
      constructor
      · intro i
        rw [binding.aLog layer]
        exact CheckpointDeltaData.aLog_bound layer i
      · intro i
        rw [binding.dtBias layer]
        exact CheckpointDeltaData.dtBias_bound layer i
    deltaOutput := remaining.deltaOutput
    deltaConvolution := remaining.deltaConvolution
    deltaGated := by
      intro layer i
      rw [binding.gatedNorm layer]
      exact CheckpointDeltaData.gatedNorm_bound layer i
    deltaMlp := remaining.deltaMlp
    attentionProjections := remaining.attentionProjections
    attentionOutput := remaining.attentionOutput
    attentionMlp := remaining.attentionMlp
    output := remaining.output }

theorem parameters (g : Graph) (binding : Bindings g) (remaining : RemainingParameters g) :
    Qwen38TrellisM1MaxSequenceRanges.Parameters g := by
  let h := initial_parameters g binding remaining
  refine ⟨?_, ?_, h.normalization, h.output⟩
  · intro layer
    refine ⟨⟨(h.delta layer).mixer, ?_⟩, (h.delta layer).suffix⟩
    intro i
    rw [binding.headKey layer]
    exact HeadScaleConstruction.key_energy_scale i
  · intro layer
    exact ⟨(h.attention layer).mixer, (h.attention layer).suffix⟩

theorem pipeline_parameters (p : TokenInference.Pipeline) (binding : Bindings p.graph)
    (remaining : RemainingParameters p.graph) (embedding : EmbeddingRanges.Parameters p.embedding) :
    TokenSequenceRanges.Parameters p := ⟨embedding, parameters p.graph binding remaining⟩

noncomputable def run (p : TokenInference.Pipeline) (binding : Bindings p.graph)
    (remaining : RemainingParameters p.graph) (embedding : EmbeddingRanges.Parameters p.embedding)
    (primitive : Qwen38TrellisM1MaxSequenceRanges.Primitives p.graph)
    (sampling : Kernels.Sampling.LogSumExpRanges.Platform)
    (samplingPrimitive : Kernels.Sampling.LogSumExpRanges.Primitives sampling)
    (token : Fin 248320) (angles : TokenAutoregressive.Angles) (steps : Nat) (supported : steps ≤ 262144) :
    TokenAutoregressive.State p steps :=
  TokenAutoregressive.run p (pipeline_parameters p binding remaining embedding) primitive sampling samplingPrimitive
    token angles steps supported

theorem run_invariant (p : TokenInference.Pipeline) (binding : Bindings p.graph)
    (remaining : RemainingParameters p.graph) (embedding : EmbeddingRanges.Parameters p.embedding)
    (primitive : Qwen38TrellisM1MaxSequenceRanges.Primitives p.graph)
    (sampling : Kernels.Sampling.LogSumExpRanges.Platform)
    (samplingPrimitive : Kernels.Sampling.LogSumExpRanges.Primitives sampling)
    (token : Fin 248320) (angles : TokenAutoregressive.Angles) (steps : Nat) (supported : steps ≤ 262144) :
    let state := run p binding remaining embedding primitive sampling samplingPrimitive token angles steps supported
    DecodeChainSequenceRanges.CachesBound p.graph.stages state.cache ∧
      DecodeChain.CacheErrors p.graph.stages state.cache state.targetCache state.errorCache ∧
      DecodeChain.CachesFinite p.graph.stages state.cache :=
  TokenAutoregressive.run_invariant p (pipeline_parameters p binding remaining embedding) primitive sampling samplingPrimitive
    token angles steps supported

end Inference.Models.Qwen.CheckpointSequenceBinding
