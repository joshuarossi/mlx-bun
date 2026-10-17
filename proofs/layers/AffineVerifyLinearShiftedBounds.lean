import layers.AffineVerifyLinearBounds
import kernels.quantization.AffineShiftedTileBounds

namespace Inference.Layers.AffineVerifyLinearShiftedBounds
open Contracts.Mlx Contracts.Mlx.Numerics Kernels.Quantization AffineVerifyLinear AffineVerifyLinearBounds
open FloatLib FloatLib.Floats FloatLib.Floats.Formats.BinaryInterchange

theorem range3 (p : Projection3 steps rows) (profile : Profile steps 36 3) (parameters : Parameters3 p profile)
    (division : DivisionDirectedBounds.Contract p.platform.tile.divide) (x : Fin (steps * 512) → BF)
    (hx : ∀ i, Model.isFinite (x i) = true ∧ |Model.toReal (x i)| ≤ (2 : ℝ)^profile.inputExponent) :
    p.Finite x ∧ ∀ row, |Model.toReal (p.forward x row)| ≤ Model.toReal profile.outputCap := by
  have ht (row : Fin rows) (step : Fin steps) (lane : Fin 32) :=
    AffineShiftedTileBounds.range3 p.platform.tile division (AffineRow.slice x step lane) ((p.weights row).bytes step lane)
      ((p.weights row).scale (AffineRow.groupIndex step lane)) ((p.weights row).bias (AffineRow.groupIndex step lane))
      profile.inputExponent profile.scaleExponent profile.biasExponent profile.tileExponent
      profile.inputLower profile.inputUpper profile.tileLower profile.tileUpper profile.scaled profile.biased
      (fun i => hx (AffineLayout.inputIndex step lane i)) (parameters.scale row _) (parameters.bias row _)
  have hr (row : Fin rows) := AffineRowBounds.output_range p.platform (AffineRow.tiles3 p.platform x (p.weights row))
    36 profile.tileExponent profile.tileLower profile.tileUpper profile.size (fun step lane => (ht row step lane).2)
    profile.outputCap profile.outputFinite profile.capacity
  exact ⟨⟨fun row step lane => (ht row step lane).1, fun row => (hr row).1, fun row => (hr row).2.1⟩,
    fun row => (hr row).2.2⟩

theorem range4 (p : Projection4 steps rows) (profile : Profile steps 32 4) (parameters : Parameters4 p profile)
    (division : DivisionDirectedBounds.Contract p.platform.tile.divide) (x : Fin (steps * 512) → BF)
    (hx : ∀ i, Model.isFinite (x i) = true ∧ |Model.toReal (x i)| ≤ (2 : ℝ)^profile.inputExponent) :
    p.Finite x ∧ ∀ row, |Model.toReal (p.forward x row)| ≤ Model.toReal profile.outputCap := by
  have ht (row : Fin rows) (step : Fin steps) (lane : Fin 32) :=
    AffineShiftedTileBounds.range4 p.platform.tile division (AffineRow.slice x step lane) ((p.weights row).words step lane)
      ((p.weights row).scale (AffineRow.groupIndex step lane)) ((p.weights row).bias (AffineRow.groupIndex step lane))
      profile.inputExponent profile.scaleExponent profile.biasExponent profile.tileExponent
      profile.inputLower profile.inputUpper profile.tileLower profile.tileUpper profile.scaled profile.biased
      (fun i => hx (AffineLayout.inputIndex step lane i)) (parameters.scale row _) (parameters.bias row _)
  have hr (row : Fin rows) := AffineRowBounds.output_range p.platform (AffineRow.tiles4 p.platform x (p.weights row))
    32 profile.tileExponent profile.tileLower profile.tileUpper profile.size (fun step lane => (ht row step lane).2)
    profile.outputCap profile.outputFinite profile.capacity
  exact ⟨⟨fun row step lane => (ht row step lane).1, fun row => (hr row).1, fun row => (hr row).2.1⟩,
    fun row => (hr row).2.2⟩

theorem accuracy3 (p : Projection3 steps rows) (profile : Profile steps 36 3) (parameters : Parameters3 p profile)
    (division : DivisionDirectedBounds.Contract p.platform.tile.divide) (x : Fin (steps * 512) → BF)
    (hx : ∀ i, Model.isFinite (x i) = true ∧ |Model.toReal (x i)| ≤ (2 : ℝ)^profile.inputExponent)
    (target error : Fin (steps * 512) → ℝ) (he : ∀ i, |Model.toReal (x i) - target i| ≤ error i) (row : Fin rows) :
    Model.isFinite (p.forward x row) = true ∧ |Model.toReal (p.forward x row)| ≤ Model.toReal profile.outputCap ∧
      |Model.toReal (p.forward x row) - p.target target row| ≤ p.budget x target error row := by
  have h := range3 p profile parameters division x hx
  exact ⟨p.forward_finite x h.1 row, h.2 row, p.forward_error x target error he h.1 row⟩

theorem accuracy4 (p : Projection4 steps rows) (profile : Profile steps 32 4) (parameters : Parameters4 p profile)
    (division : DivisionDirectedBounds.Contract p.platform.tile.divide) (x : Fin (steps * 512) → BF)
    (hx : ∀ i, Model.isFinite (x i) = true ∧ |Model.toReal (x i)| ≤ (2 : ℝ)^profile.inputExponent)
    (target error : Fin (steps * 512) → ℝ) (he : ∀ i, |Model.toReal (x i) - target i| ≤ error i) (row : Fin rows) :
    Model.isFinite (p.forward x row) = true ∧ |Model.toReal (p.forward x row)| ≤ Model.toReal profile.outputCap ∧
      |Model.toReal (p.forward x row) - p.target target row| ≤ p.budget x target error row := by
  have h := range4 p profile parameters division x hx
  exact ⟨p.forward_finite x h.1 row, h.2 row, p.forward_error x target error he h.1 row⟩

end Inference.Layers.AffineVerifyLinearShiftedBounds
