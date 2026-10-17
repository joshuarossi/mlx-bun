import models.qwen.CheckpointMlpBinding
import models.qwen.CheckpointConvolutionData

namespace Inference.Models.Qwen.CheckpointConvolutionBinding
open Contracts.Mlx Qwen38TrellisM1Max

structure Bindings (g : Graph) : Prop extends toMlp : CheckpointMlpBinding.Bindings g where
  convolution : ∀ i, (g.delta i).mixer.convolutionWeight = CheckpointConvolutionData.weight i

-- Only the affine projections and embedding still need numerical payload
-- certificates. All normalization, Delta gates, convolution and MLP scales
-- follow from literal certificates once their exact attachment is supplied.
structure RemainingParameters (g : Graph) : Prop where
  deltaProjections : ∀ i, DeltaInputRanges.Parameters (g.delta i).mixer
  deltaOutput : ∀ i, DeltaOutputRanges.Parameters (g.delta i).mixer.out
  attentionProjections : ∀ i, AttentionInputRanges.Parameters (g.attention i).mixer.projections
  attentionOutput : ∀ i, DeltaOutputRanges.Parameters (g.attention i).mixer.output
  output : NormalizedAffineProjection.Parameters g.output

theorem remaining_parameters (g : Graph) (binding : Bindings g) (remaining : RemainingParameters g) :
    CheckpointMlpBinding.RemainingParameters g := {
  deltaProjections := remaining.deltaProjections
  deltaOutput := remaining.deltaOutput
  deltaConvolution := by
    intro layer channel tap
    rw [binding.convolution layer]
    exact CheckpointConvolutionData.weight_bound layer channel tap
  attentionProjections := remaining.attentionProjections
  attentionOutput := remaining.attentionOutput
  output := remaining.output }

theorem parameters (g : Graph) (binding : Bindings g) (remaining : RemainingParameters g) :
    Qwen38TrellisM1MaxSequenceRanges.Parameters g :=
  CheckpointMlpBinding.parameters g binding.toMlp (remaining_parameters g binding remaining)

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

end Inference.Models.Qwen.CheckpointConvolutionBinding
