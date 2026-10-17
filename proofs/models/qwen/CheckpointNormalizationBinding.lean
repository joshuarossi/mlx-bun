import models.qwen.CheckpointNormalizationData
import models.qwen.TokenInitialRanges

namespace Inference.Models.Qwen.CheckpointNormalizationBinding
open Contracts.Mlx
open FloatLib FloatLib.Floats FloatLib.Floats.Formats.BinaryInterchange
open Qwen38TrellisM1Max

def deltaLayer (i : Fin 48) : Fin 64 := ⟨4*(i.val/3)+i.val%3, by omega⟩
def attentionLayer (i : Fin 16) : Fin 64 := ⟨4*i.val+3, by omega⟩
def inputIndex (i : Fin 64) : Fin 129 := ⟨2*i.val, by omega⟩
def postIndex (i : Fin 64) : Fin 129 := ⟨2*i.val+1, by omega⟩

-- Exact attachment replaces numerical assumptions about normalization
-- weights. The certified literals imply their bounds. Establishing these
-- equalities for native loader objects is still an external binding task.
structure Bindings (g : Graph) : Prop where
  deltaInput : ∀ i, (g.delta i).inputNorm.weight = CheckpointNormalizationData.mainNorm (inputIndex (deltaLayer i))
  deltaPost : ∀ i, (g.delta i).suffix.norm.weight = CheckpointNormalizationData.mainNorm (postIndex (deltaLayer i))
  attentionInput : ∀ i, (g.attention i).inputNorm.weight = CheckpointNormalizationData.mainNorm (inputIndex (attentionLayer i))
  attentionPost : ∀ i, (g.attention i).suffix.norm.weight = CheckpointNormalizationData.mainNorm (postIndex (attentionLayer i))
  query : ∀ i, (g.attention i).mixer.preparation.qNorm.weight = CheckpointNormalizationData.query i
  key : ∀ i, (g.attention i).mixer.preparation.kNorm.weight = CheckpointNormalizationData.key i
  finalNorm : g.finalNorm.weight = CheckpointNormalizationData.mainNorm ⟨128, by decide⟩

structure RemainingParameters (g : Graph) : Prop where
  deltaProjections : ∀ i, DeltaInputRanges.Parameters (g.delta i).mixer
  deltaHeads : ∀ i, DeltaHeadRanges.Parameters (g.delta i).mixer
  deltaGates : ∀ i, DeltaGateRanges.Parameters (g.delta i).mixer
  deltaOutput : ∀ i, DeltaOutputRanges.Parameters (g.delta i).mixer.out
  deltaConvolution : ∀ i c k, Model.isFinite ((g.delta i).mixer.convolutionWeight c k) = true ∧
    |Model.toReal ((g.delta i).mixer.convolutionWeight c k)| ≤ 1
  deltaGated : ∀ i k, Model.isFinite ((g.delta i).mixer.normWeight k) = true ∧
    |Model.toReal ((g.delta i).mixer.normWeight k)| ≤ 2
  deltaMlp : ∀ i, TrellisMlpRanges.Parameters (g.delta i).suffix.mlp
  attentionProjections : ∀ i, AttentionInputRanges.Parameters (g.attention i).mixer.projections
  attentionOutput : ∀ i, DeltaOutputRanges.Parameters (g.attention i).mixer.output
  attentionMlp : ∀ i, TrellisMlpRanges.Parameters (g.attention i).suffix.mlp
  output : NormalizedAffineProjection.Parameters g.output

theorem parameters (g : Graph) (binding : Bindings g) (remaining : RemainingParameters g) :
    Qwen38TrellisM1MaxInitialRanges.Parameters g := by
  refine ⟨?_, ?_, ?_, remaining.output⟩
  · intro layer
    refine ⟨?_, ?_⟩
    · exact {
        projections := remaining.deltaProjections layer
        heads := remaining.deltaHeads layer
        gates := remaining.deltaGates layer
        output := remaining.deltaOutput layer
        normalization := by
          intro i
          rw [binding.deltaInput layer]
          exact CheckpointNormalizationData.mainNorm_bound _ i
        convolution := remaining.deltaConvolution layer
        gated := remaining.deltaGated layer }
    · refine ⟨?_, remaining.deltaMlp layer⟩
      intro i
      rw [binding.deltaPost layer]
      exact CheckpointNormalizationData.mainNorm_bound _ i
  · intro layer
    refine ⟨?_, ?_⟩
    · refine ⟨?_, remaining.attentionProjections layer, ?_, remaining.attentionOutput layer⟩
      · intro i
        rw [binding.attentionInput layer]
        exact CheckpointNormalizationData.mainNorm_bound _ i
      · constructor
        · intro i
          rw [binding.query layer]
          exact CheckpointNormalizationData.query_bound layer i
        · intro i
          rw [binding.key layer]
          exact CheckpointNormalizationData.key_bound layer i
    · refine ⟨?_, remaining.attentionMlp layer⟩
      intro i
      rw [binding.attentionPost layer]
      exact CheckpointNormalizationData.mainNorm_bound _ i
  · intro i
    rw [binding.finalNorm]
    exact CheckpointNormalizationData.mainNorm_bound _ i

theorem pipeline_parameters (p : TokenInference.Pipeline) (binding : Bindings p.graph)
    (remaining : RemainingParameters p.graph) (embedding : EmbeddingRanges.Parameters p.embedding) :
    TokenInitialRanges.Parameters p := ⟨embedding, parameters p.graph binding remaining⟩

noncomputable def token_ranges (p : TokenInference.Pipeline) (binding : Bindings p.graph)
    (remaining : RemainingParameters p.graph) (embedding : EmbeddingRanges.Parameters p.embedding)
    (primitive : Qwen38TrellisM1MaxInitialRanges.Primitives p.graph) (token : Fin 248320)
    (angle : Kernels.Attention.RopeAngles.Inputs) (ha : Kernels.Attention.RopeAnglesRanges.InputsBound angle)
    (position : Numerics.real angle.position = 0) : p.Ranges (InitialState.caches p.graph.stages) token angle :=
  TokenInitialRanges.checked p (pipeline_parameters p binding remaining embedding) primitive token angle ha position

end Inference.Models.Qwen.CheckpointNormalizationBinding
