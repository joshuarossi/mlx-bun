import models.qwen.CheckpointAffineDictionaryData

namespace Inference.Models.Qwen.CheckpointAffineDictionary
open Contracts.Mlx Layers.AffineVerifyLinear
open FloatLib FloatLib.Floats FloatLib.Floats.Formats.BinaryInterchange
open CheckpointAffineDictionaryData
abbrev BF := BFloat16Arithmetic.Value

structure Encoding (steps rows : Nat) where
  scales : Encoded rows (steps*8)
  biases : Encoded rows (steps*8)

def scale (p : Projection steps rows) (row : Fin rows) (group : Fin (steps*8)) : BF :=
  match p with | .bits3 p => (p.weights row).scale group | .bits4 p => (p.weights row).scale group
def bias (p : Projection steps rows) (row : Fin rows) (group : Fin (steps*8)) : BF :=
  match p with | .bits3 p => (p.weights row).bias group | .bits4 p => (p.weights row).bias group

-- These are exact equalities to decoded dictionaries, not assumed numerical
-- inequalities. The selected native payloads must establish this binding.
structure Attached (p : Projection steps rows) (encoded : Encoding steps rows) : Prop where
  scales : ∀ row group, scale p row group = projectionScales encoded.scales row group
  biases : ∀ row group, bias p row group = projectionBiases encoded.biases row group

theorem scales_bound (p : Projection steps rows) (encoded : Encoding steps rows) (binding : Attached p encoded)
    (row : Fin rows) (group : Fin (steps*8)) :
    Model.isFinite (scale p row group) = true ∧ |Model.toReal (scale p row group)| ≤ (2 : ℝ)^(-4 : Int) := by
  rw [binding.scales row group]
  exact projectionScales_bound encoded.scales row group

theorem biases_bound (p : Projection steps rows) (encoded : Encoding steps rows) (binding : Attached p encoded)
    (row : Fin rows) (group : Fin (steps*8)) :
    Model.isFinite (bias p row group) = true ∧ |Model.toReal (bias p row group)| ≤ (2 : ℝ)^(-1 : Int) := by
  rw [binding.biases row group]
  exact projectionBiases_bound encoded.biases row group

theorem normalized (p : Projection 10 rows) (encoded : Encoding 10 rows) (binding : Attached p encoded) :
    NormalizedAffineProjection.Parameters p := by
  cases p with
  | bits3 p => exact ⟨scales_bound (.bits3 p) encoded binding, biases_bound (.bits3 p) encoded binding⟩
  | bits4 p => exact ⟨scales_bound (.bits4 p) encoded binding, biases_bound (.bits4 p) encoded binding⟩

theorem output (p : Projection 12 5120) (encoded : Encoding 12 5120) (binding : Attached p encoded) :
    DeltaOutputRanges.Parameters p := by
  cases p with
  | bits3 p => exact ⟨scales_bound (.bits3 p) encoded binding, biases_bound (.bits3 p) encoded binding⟩
  | bits4 p => exact ⟨scales_bound (.bits4 p) encoded binding, biases_bound (.bits4 p) encoded binding⟩

def specialize3 (p : Projection3 steps rows) (encoded : Encoding steps rows) : Projection3 steps rows :=
  { p with weights := fun row => { p.weights row with
      scale := projectionScales encoded.scales row
      bias := projectionBiases encoded.biases row } }
def specialize4 (p : Projection4 steps rows) (encoded : Encoding steps rows) : Projection4 steps rows :=
  { p with weights := fun row => { p.weights row with
      scale := projectionScales encoded.scales row
      bias := projectionBiases encoded.biases row } }
theorem specialize3_attached (p : Projection3 steps rows) (encoded : Encoding steps rows) :
    Attached (.bits3 (specialize3 p encoded)) encoded := ⟨fun _ _ => rfl, fun _ _ => rfl⟩
theorem specialize4_attached (p : Projection4 steps rows) (encoded : Encoding steps rows) :
    Attached (.bits4 (specialize4 p encoded)) encoded := ⟨fun _ _ => rfl, fun _ _ => rfl⟩

structure EmbeddingAttached (p : Layers.QuantizedEmbedding.Layer) (encoded : Encoding 10 248320) : Prop where
  scales : p.scales = embeddingScales encoded.scales
  biases : p.biases = embeddingBiases encoded.biases

theorem embedding (p : Layers.QuantizedEmbedding.Layer) (encoded : Encoding 10 248320)
    (binding : EmbeddingAttached p encoded) : EmbeddingRanges.Parameters p := by
  constructor
  · intro row group
    rw [binding.scales]
    exact (embeddingScales_bound encoded.scales row group).1
  · intro row group
    rw [binding.biases]
    exact (embeddingBiases_bound encoded.biases row group).1
  · intro row group
    rw [binding.scales]
    exact (embeddingScales_bound encoded.scales row group).2
  · intro row group
    rw [binding.biases]
    exact (embeddingBiases_bound encoded.biases row group).2

end Inference.Models.Qwen.CheckpointAffineDictionary
