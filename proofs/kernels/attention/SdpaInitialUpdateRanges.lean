import kernels.attention.SdpaExponentRanges
import contracts.mlx.ArithmeticBounds
import contracts.mlx.DyadicBounds
import contracts.mlx.FlushedIdentities

namespace Inference.Kernels.Attention.SdpaInitialUpdateRanges
open Contracts.Mlx Contracts.Mlx.Numerics SdpaUpdate ArithmeticBounds

def inputCap (i : Nat) : Float32 :=
  if i = 0 ∨ i = 1 then 0 else if i = 2 ∨ i = 3 then 1 else DyadicBounds.ceiling 1 23
def numeratorCap : Float32 := DyadicBounds.ceiling 1 23

theorem cap_range : numeratorCap.isFinite = true ∧ real numeratorCap = (2 : ℝ)^(23 : Nat) := by
  simpa [numeratorCap] using
    DyadicBounds.ceiling_range 1 23 (by decide) (by decide) (by decide)

theorem denominator_certificate (p : Platform) : Certificate inputCap (denominatorExpr p) 1 := by
  have h0 : Certificate inputCap (.input 0) 0 := .input 0
  have h2 : Certificate inputCap (.input 2) 1 := .input 2
  have h3 : Certificate inputCap (.input 3) 1 := .input 3
  have hz := FlushedIdentities.zero_real
  cases h : p.sumContracted <;> simp only [denominatorExpr, h, Bool.false_eq_true, ite_false, ite_true]
  · exact .add (.mul h0 h2 0 (by decide) (by rw [hz, real_one]; norm_num)) h3 1 (by decide)
      (by rw [hz, real_one]; norm_num)
  · exact .fma h0 h2 h3 1 (by decide) (by rw [hz, real_one]; norm_num)

theorem numerator_certificate (p : Platform) : Certificate inputCap (numeratorExpr p) numeratorCap := by
  have h1 : Certificate inputCap (.input 1) 0 := .input 1
  have h2 : Certificate inputCap (.input 2) 1 := .input 2
  have h3 : Certificate inputCap (.input 3) 1 := .input 3
  have h4 : Certificate inputCap (.input 4) numeratorCap := .input 4
  have prod0 : Certificate inputCap (.mul (.input 1) (.input 2)) 0 :=
    .mul h1 h2 0 (by decide) (by rw [FlushedIdentities.zero_real, real_one]; norm_num)
  have prod1 : Certificate inputCap (.mul (.input 3) (.input 4)) numeratorCap :=
    .mul h3 h4 _ cap_range.1 (by rw [real_one, one_mul])
  cases h : p.numeratorContracted <;> simp only [numeratorExpr, h]
  · exact .add prod0 prod1 _ cap_range.1 (by rw [FlushedIdentities.zero_real, zero_add])
  · exact .fma h1 h2 prod1 _ cap_range.1 (by rw [FlushedIdentities.zero_real, zero_mul, zero_add])
  · exact .fma h3 h4 prod0 _ cap_range.1 (by rw [real_one, FlushedIdentities.zero_real, one_mul, add_zero])

theorem ranges (p : Platform) (primitive : SdpaExponentRanges.Primitive p) (score value : Float32)
    (hs : score.isFinite = true) (scoreBound : |real score| ≤ (2 : ℝ)^(24 : Nat))
    (hv : value.isFinite = true) (valueBound : |real value| ≤ (2 : ℝ)^(23 : Nat)) :
    Finite p (SdpaLoop.initial SdpaVector.initialShift) score value score ∧
      real (step p (SdpaLoop.initial SdpaVector.initialShift) score value score).denominator = 1 ∧
      |real (step p (SdpaLoop.initial SdpaVector.initialShift) score value score).numerator| ≤ (2 : ℝ)^(23 : Nat) := by
  have old := SdpaExponentRanges.initial p primitive score hs scoreBound
  have current := SdpaExponentRanges.diagonal p primitive score hs
  let s := SdpaLoop.initial SdpaVector.initialShift
  have hi : ∀ i, (SdpaUpdate.bind p s score value score i).isFinite = true ∧
      |real (SdpaUpdate.bind p s score value score i)| ≤ real (inputCap i) := by
    intro i
    by_cases h0 : i = 0
    · subst i
      change (0 : Float32).isFinite = true ∧ |real (0 : Float32)| ≤ real (0 : Float32)
      exact ⟨by decide, by rw [FlushedIdentities.zero_real, abs_zero]⟩
    by_cases h1 : i = 1
    · subst i
      change (0 : Float32).isFinite = true ∧ |real (0 : Float32)| ≤ real (0 : Float32)
      exact ⟨by decide, by rw [FlushedIdentities.zero_real, abs_zero]⟩
    by_cases h2 : i = 2
    · subst i
      change (exponential p SdpaVector.initialShift score).isFinite = true ∧
        |real (exponential p SdpaVector.initialShift score)| ≤ real (1 : Float32)
      rw [real_one, abs_of_nonneg old.2.1]
      exact ⟨old.1.exponential, old.2.2⟩
    by_cases h3 : i = 3
    · subst i
      change (exponential p score score).isFinite = true ∧ |real (exponential p score score)| ≤ real (1 : Float32)
      rw [current.2, real_one, abs_one]
      exact ⟨current.1.exponential, le_refl _⟩
    · simp only [SdpaUpdate.bind, inputCap, h0, h1, h2, h3, or_self, ite_false]
      change value.isFinite = true ∧ |real value| ≤ real numeratorCap
      rw [cap_range.2]
      exact ⟨hv, valueBound⟩
  have hd := ArithmeticBounds.sound _ inputCap hi (denominator_certificate p)
  have hn := ArithmeticBounds.sound _ inputCap hi (numerator_certificate p)
  have finite : Finite p s score value score := ⟨old.1, current.1, hd.1, hn.1⟩
  refine ⟨finite, ?_, ?_⟩
  · have fd := finite.denominator
    cases hc : p.sumContracted
    · simp only [denominatorExpr, hc, Bool.false_eq_true, ite_false, Arithmetic.Finite] at fd
      have prod : real (FlushToZero.mul s.denominator (exponential p s.shift score)) = 0 :=
        FlushedIdentities.mul_zero_left _ _ FlushedIdentities.zero_real fd.1.2.2
      have h := FlushedIdentities.add_zero_one
        (FlushToZero.mul s.denominator (exponential p s.shift score)) (exponential p score score)
        (FlushToZero.finite_flushExact _ _ fd.1.2.2)
        current.1.exponential prod current.2 fd.2.2
      simpa only [step, hc, Bool.false_eq_true, ite_false] using h
    · simp only [denominatorExpr, hc, ite_true, Arithmetic.Finite] at fd
      have h := FlushedIdentities.fma_zero_one s.denominator (exponential p s.shift score)
        (exponential p score score) (by decide) old.1.exponential current.1.exponential
        FlushedIdentities.zero_real current.2 fd.2.2.2
      simpa only [step, hc, ite_true] using h
  · rw [numerator_execution] at hn
    exact hn.2.trans_eq cap_range.2

end Inference.Kernels.Attention.SdpaInitialUpdateRanges
