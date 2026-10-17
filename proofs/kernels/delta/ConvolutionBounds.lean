import kernels.delta.Convolution
import contracts.mlx.ArithmeticBounds
import contracts.mlx.BFloat16ConversionBounds

namespace Inference.Kernels.Delta.ConvolutionBounds
open Contracts.Mlx Contracts.Mlx.Numerics Convolution
open FloatLib FloatLib.Floats FloatLib.Floats.Formats.BinaryInterchange
open scoped BigOperators

structure Profile where
  inputCap : Float32
  weightCap : Float32
  productCap : Float32
  accumulatorCap : Fin 5 → Float32
  storeCap : BF
  productFinite : productCap.isFinite = true
  accumulatorFinite : ∀ i, (accumulatorCap i).isFinite = true
  storeFinite : Model.isFinite storeCap = true
  zeroCapacity : 0 ≤ real (accumulatorCap 0)
  productCapacity : real inputCap * real weightCap ≤ real productCap
  stepCapacity : ∀ i : Fin 4, real (accumulatorCap ⟨i.val, by omega⟩) + real productCap ≤
    real (accumulatorCap ⟨i.val + 1, by omega⟩)
  storeCapacity : real (accumulatorCap 4) ≤ Model.toReal storeCap

def Profile.inputCaps (p : Profile) : Nat → Float32 := bind (fun _ => p.inputCap) (fun _ => p.weightCap)

theorem Profile.certificate (p : Profile) (contracted : Bool) :
    ArithmeticBounds.Certificate p.inputCaps (expression contracted) (p.accumulatorCap 4) := by
  have step (tap : Fin 4) (acc : Arithmetic.Expr)
      (ha : ArithmeticBounds.Certificate p.inputCaps acc (p.accumulatorCap ⟨tap.val, by omega⟩)) :
      ArithmeticBounds.Certificate p.inputCaps
        (Gated.madd contracted (.input tap.val) (.input (4 + tap.val)) acc)
        (p.accumulatorCap ⟨tap.val + 1, by omega⟩) := by
    have hi : ArithmeticBounds.Certificate p.inputCaps (.input tap.val) p.inputCap := by
      simpa only [inputCaps, bind_input] using ArithmeticBounds.Certificate.input (inputCap := p.inputCaps) tap.val
    have hw : ArithmeticBounds.Certificate p.inputCaps (.input (4 + tap.val)) p.weightCap := by
      simpa only [inputCaps, bind_weight] using ArithmeticBounds.Certificate.input (inputCap := p.inputCaps) (4 + tap.val)
    cases contracted
    · exact .add ha (.mul hi hw p.productCap p.productFinite p.productCapacity)
        _ (p.accumulatorFinite _) (p.stepCapacity tap)
    · apply ArithmeticBounds.Certificate.fma hi hw ha _ (p.accumulatorFinite _)
      have hp := p.productCapacity
      have hs := p.stepCapacity tap
      linarith
  have h0 : ArithmeticBounds.Certificate p.inputCaps .zero (p.accumulatorCap 0) := .zero _ p.zeroCapacity
  exact step 3 _ (step 2 _ (step 1 _ (step 0 _ h0)))

theorem Profile.bind_range (p : Profile) (input weight : Fin 4 → BF)
    (hi : ∀ i, Model.isFinite (input i) = true ∧ |Model.toReal (input i)| ≤ real p.inputCap)
    (hw : ∀ i, Model.isFinite (weight i) = true ∧ |Model.toReal (weight i)| ≤ real p.weightCap)
    (i : Nat) :
    (bind (fun i => BFloat16.widen (input i)) (fun i => BFloat16.widen (weight i)) i).isFinite = true ∧
      |real (bind (fun i => BFloat16.widen (input i)) (fun i => BFloat16.widen (weight i)) i)| ≤ real (p.inputCaps i) := by
  unfold Convolution.bind inputCaps Convolution.bind
  split
  · exact ⟨BFloat16.widen_finite _ (hi _).1, by rw [BFloat16.widen_real _ (hi _).1]; exact (hi _).2⟩
  · split
    · exact ⟨BFloat16.widen_finite _ (hw _).1, by rw [BFloat16.widen_real _ (hw _).1]; exact (hw _).2⟩
    · have hz : real (0 : Float32) = 0 := by rw [real_unpack]; exact Model.unpackedToReal_zero .positive
      exact ⟨by decide +kernel, by simp only [hz, abs_zero, le_refl]⟩

theorem Profile.ranges (p : Profile) (contracted : Bool) (input weight : Fin 4 → BF)
    (hi : ∀ i, Model.isFinite (input i) = true ∧ |Model.toReal (input i)| ≤ real p.inputCap)
    (hw : ∀ i, Model.isFinite (weight i) = true ∧ |Model.toReal (weight i)| ≤ real p.weightCap) :
    Arithmetic.Finite (bind (fun i => BFloat16.widen (input i)) (fun i => BFloat16.widen (weight i))) (expression contracted) ∧
      Model.isFinite (value contracted input weight) = true ∧
      |Model.toReal (value contracted input weight)| ≤ Model.toReal p.storeCap := by
  have h := ArithmeticBounds.sound _ _ (p.bind_range input weight hi hw) (p.certificate contracted)
  have hf := Arithmetic.finite_evaluate _ _ h.1
  rw [execution] at hf
  have hb := h.2
  rw [execution] at hb
  have hc := BFloat16ConversionBounds.narrow_range _ p.storeCap hf p.storeFinite (hb.trans p.storeCapacity)
  exact ⟨h.1, hc⟩

theorem Profile.accuracy (p : Profile) (contracted : Bool) (input weight : Fin 4 → BF)
    (targetInput targetWeight inputError weightError : Fin 4 → ℝ)
    (hif : ∀ i, Model.isFinite (input i) = true ∧ |Model.toReal (input i)| ≤ real p.inputCap)
    (hwf : ∀ i, Model.isFinite (weight i) = true ∧ |Model.toReal (weight i)| ≤ real p.weightCap)
    (hi : ∀ i, |Model.toReal (input i) - targetInput i| ≤ inputError i)
    (hw : ∀ i, |Model.toReal (weight i) - targetWeight i| ≤ weightError i) :
    Model.isFinite (value contracted input weight) = true ∧
      |Model.toReal (value contracted input weight)| ≤ Model.toReal p.storeCap ∧
      |Model.toReal (value contracted input weight) - ∑ i, targetInput i * targetWeight i| ≤
        budget contracted input weight targetInput targetWeight inputError weightError := by
  have h := p.ranges contracted input weight hif hwf
  exact ⟨h.2.1, h.2.2, value_error contracted input weight targetInput targetWeight inputError weightError
    (fun i => (hif i).1) (fun i => (hwf i).1) hi hw h.1 h.2.1⟩

end Inference.Kernels.Delta.ConvolutionBounds
