import models.qwen.CheckpointSequenceBinding
import models.qwen.CheckpointTrellisData

namespace Inference.Models.Qwen.CheckpointMlpBinding
open Contracts.Mlx Qwen38TrellisM1Max
open CheckpointNormalizationBinding (deltaLayer attentionLayer)
open FloatLib FloatLib.Floats FloatLib.Floats.Formats.BinaryInterchange

-- Equality to the checkpoint literals replaces all 192 MLP scale bounds.
-- Native loader attachment still has to establish these equalities.
structure Bindings (g : Graph) : Prop extends toSequence : CheckpointSequenceBinding.Bindings g where
  deltaGate : ∀ i, (g.delta i).suffix.mlp.gate.scale = CheckpointTrellisData.gate (deltaLayer i)
  deltaUp : ∀ i, (g.delta i).suffix.mlp.up.scale = CheckpointTrellisData.up (deltaLayer i)
  deltaDown : ∀ i, (g.delta i).suffix.mlp.down.scale = CheckpointTrellisData.down (deltaLayer i)
  attentionGate : ∀ i, (g.attention i).suffix.mlp.gate.scale = CheckpointTrellisData.gate (attentionLayer i)
  attentionUp : ∀ i, (g.attention i).suffix.mlp.up.scale = CheckpointTrellisData.up (attentionLayer i)
  attentionDown : ∀ i, (g.attention i).suffix.mlp.down.scale = CheckpointTrellisData.down (attentionLayer i)

structure RemainingParameters (g : Graph) : Prop where
  deltaProjections : ∀ i, DeltaInputRanges.Parameters (g.delta i).mixer
  deltaOutput : ∀ i, DeltaOutputRanges.Parameters (g.delta i).mixer.out
  deltaConvolution : ∀ i c k, Model.isFinite ((g.delta i).mixer.convolutionWeight c k) = true ∧
    |Model.toReal ((g.delta i).mixer.convolutionWeight c k)| ≤ 1
  attentionProjections : ∀ i, AttentionInputRanges.Parameters (g.attention i).mixer.projections
  attentionOutput : ∀ i, DeltaOutputRanges.Parameters (g.attention i).mixer.output
  output : NormalizedAffineProjection.Parameters g.output

theorem mlp_parameters (mlp : WrittenLayers.GateDown) (layer : Fin 64)
    (gate : mlp.gate.scale = CheckpointTrellisData.gate layer)
    (up : mlp.up.scale = CheckpointTrellisData.up layer)
    (down : mlp.down.scale = CheckpointTrellisData.down layer) : TrellisMlpRanges.Parameters mlp := by
  constructor
  · rw [gate]
    exact CheckpointTrellisData.gate_bound layer
  · rw [up]
    exact CheckpointTrellisData.up_bound layer
  · rw [down]
    exact CheckpointTrellisData.down_bound layer

theorem delta_parameters (g : Graph) (binding : Bindings g) (layer : Fin 48) :
    TrellisMlpRanges.Parameters (g.delta layer).suffix.mlp :=
  mlp_parameters _ (deltaLayer layer) (binding.deltaGate layer) (binding.deltaUp layer) (binding.deltaDown layer)

theorem attention_parameters (g : Graph) (binding : Bindings g) (layer : Fin 16) :
    TrellisMlpRanges.Parameters (g.attention layer).suffix.mlp :=
  mlp_parameters _ (attentionLayer layer) (binding.attentionGate layer) (binding.attentionUp layer) (binding.attentionDown layer)

theorem remaining_parameters (g : Graph) (binding : Bindings g) (remaining : RemainingParameters g) :
    CheckpointSequenceBinding.RemainingParameters g := {
  deltaProjections := remaining.deltaProjections
  deltaOutput := remaining.deltaOutput
  deltaConvolution := remaining.deltaConvolution
  deltaMlp := delta_parameters g binding
  attentionProjections := remaining.attentionProjections
  attentionOutput := remaining.attentionOutput
  attentionMlp := attention_parameters g binding
  output := remaining.output }

theorem parameters (g : Graph) (binding : Bindings g) (remaining : RemainingParameters g) :
    Qwen38TrellisM1MaxSequenceRanges.Parameters g :=
  CheckpointSequenceBinding.parameters g binding.toSequence (remaining_parameters g binding remaining)

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

end Inference.Models.Qwen.CheckpointMlpBinding
