import models.qwen.Blocks
import contracts.mlx.NormalizationFloorBounds

namespace Inference.Models.Qwen.NormalizationRanges
open Contracts.Mlx Contracts.Mlx.Numerics
open FloatLib FloatLib.Floats FloatLib.Floats.Formats.BinaryInterchange
abbrev BF := BFloat16Arithmetic.Value

theorem width_constructor : Blocks.width = Float32.ofInt ((5120 : Nat) : Int) := by decide +kernel

theorem widened (x : Fin 5120 → BF) (exponent : Int)
    (hx : ∀ i, Model.isFinite (x i) = true ∧ |Model.toReal (x i)| ≤ (2 : ℝ)^exponent) (i : Fin 5120) :
    (Blocks.widenInput x i).isFinite = true ∧ |real (Blocks.widenInput x i)| ≤ (2 : ℝ)^exponent := by
  exact ⟨BFloat16.widen_finite _ (hx i).1, by
    change |real (BFloat16.widen (x i))| ≤ _
    rw [BFloat16.widen_real _ (hx i).1]
    exact (hx i).2⟩

theorem transfer (norm : Blocks.Norm) (x : Fin 5120 → BF) (cap : BF)
    (hf : norm.Finite x)
    (hb : ∀ i, |real (NormalizationExecution.output norm.platform.divide (Blocks.widenInput x) norm.weight
      (RmsNorm.expression norm.platform 5120) Blocks.width Blocks.eps norm.platform.rsqrt i)| ≤ Model.toReal cap) :
    norm.Finite x ∧ ∀ i, |Model.toReal (norm.forward x i)| ≤ Model.toReal cap := by
  refine ⟨hf, ?_⟩
  intro i
  rw [← BFloat16.widen_real _ (norm.forward_finite x hf i)]
  unfold Blocks.Norm.forward Layers.Normalization.value
  simp only [Layers.Normalization.prepare, Bool.false_eq_true, ite_false]
  unfold RmsNorm.value
  rw [RmsNorm.inverse_correct]
  exact hb i

theorem ranges (norm : Blocks.Norm) (p : NormalizationDyadicBounds.Profile) (heps : p.eps = Blocks.eps)
    (division : DivisionBounds.Contract norm.platform.divide)
    (root : NormalizationBounds.RsqrtRange norm.platform.rsqrt p.eps p.inverseCap)
    (hw : ∀ i, Model.isFinite (norm.weight i) = true ∧ |Model.toReal (norm.weight i)| ≤ Model.toReal p.weightCap)
    (x : Fin 5120 → BF)
    (hx : ∀ i, Model.isFinite (x i) = true ∧ |Model.toReal (x i)| ≤ (2 : ℝ)^p.inputExponent) :
    norm.Finite x ∧ ∀ i, |Model.toReal (norm.forward x i)| ≤ Model.toReal p.outputCap := by
  have h := p.ranges norm.platform division root (Blocks.widenInput x) norm.weight
    (widened x p.inputExponent hx) hw (by decide) (by decide)
  rw [heps, ← width_constructor] at h
  exact transfer norm x p.outputCap h.1 h.2

theorem floor_ranges (norm : Blocks.Norm) (p : NormalizationDyadicBounds.Profile) (heps : p.eps = Blocks.eps)
    (division : DivisionDirectedBounds.Contract norm.platform.divide)
    (hw : ∀ i, Model.isFinite (norm.weight i) = true ∧ |Model.toReal (norm.weight i)| ≤ Model.toReal p.weightCap)
    (x : Fin 5120 → BF)
    (hx : ∀ i, Model.isFinite (x i) = true ∧ |Model.toReal (x i)| ≤ (2 : ℝ)^p.inputExponent)
    (i : Fin 5120) (squareFloor meanFloor : Float32)
    (sf : squareFloor.isFinite = true) (sn : FlushToZero.threshold < real squareFloor)
    (mf : meanFloor.isFinite = true) (mn : FlushToZero.threshold < real meanFloor)
    (inputNormal : FlushToZero.threshold < |Model.toReal (x i)|)
    (square : real squareFloor ≤ Model.toReal (x i) * Model.toReal (x i))
    (capacity : real meanFloor ≤ real squareFloor / 5120)
    (root : NormalizationBounds.RsqrtRange norm.platform.rsqrt meanFloor p.inverseCap) :
    norm.Finite x ∧ ∀ j, |Model.toReal (norm.forward x j)| ≤ Model.toReal p.outputCap := by
  have hi : real (FlushToZero.flush (Blocks.widenInput x i)) = Model.toReal (x i) := by
    change real (FlushToZero.flush (BFloat16.widen (x i))) = _
    rw [FlushToZero.flush_eq_of_threshold_lt _ (by rw [BFloat16.widen_real _ (hx i).1]; exact inputNormal)]
    exact BFloat16.widen_real _ (hx i).1
  have h := NormalizationFloorBounds.ranges p norm.platform division (Blocks.widenInput x) norm.weight
    (widened x p.inputExponent hx) hw (by decide) (by decide) i squareFloor meanFloor sf sn mf mn
    (by simpa only [hi] using square) (by simpa only [Nat.cast_ofNat] using capacity) root
  rw [heps, ← width_constructor] at h
  exact transfer norm x p.outputCap h.1 h.2

theorem accuracy (norm : Blocks.Norm) (p : NormalizationDyadicBounds.Profile) (heps : p.eps = Blocks.eps)
    (division : DivisionBounds.Contract norm.platform.divide)
    (root : NormalizationBounds.RsqrtRange norm.platform.rsqrt p.eps p.inverseCap)
    (hw : ∀ i, Model.isFinite (norm.weight i) = true ∧ |Model.toReal (norm.weight i)| ≤ Model.toReal p.weightCap)
    (x : Fin 5120 → BF)
    (hx : ∀ i, Model.isFinite (x i) = true ∧ |Model.toReal (x i)| ≤ (2 : ℝ)^p.inputExponent)
    (target error : Fin 5120 → ℝ) (he : ∀ i, |Model.toReal (x i) - target i| ≤ error i) (i : Fin 5120) :
    Model.isFinite (norm.forward x i) = true ∧ |Model.toReal (norm.forward x i)| ≤ Model.toReal p.outputCap ∧
      |Model.toReal (norm.forward x i) - norm.target target i| ≤ norm.errorBudget x target error i := by
  have hr := ranges norm p heps division root hw x hx
  exact ⟨norm.forward_finite x hr.1 i, hr.2 i,
    norm.forward_error x target error he (fun j => (hx j).1) (fun j => (hw j).1) hr.1 i⟩

end Inference.Models.Qwen.NormalizationRanges
