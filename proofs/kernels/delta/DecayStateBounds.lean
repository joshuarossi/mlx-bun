import contracts.mlx.ContractiveMultiplication
import kernels.delta.RecurrenceStability

namespace Inference.Kernels.Delta.DecayStateBounds
open Contracts.Mlx Contracts.Mlx.Numerics
open scoped BigOperators

theorem magnitude_abs (x : Fin n → ℝ) :
    RecurrenceStability.magnitude (fun i => |x i|) = RecurrenceStability.magnitude x := by
  simp only [RecurrenceStability.magnitude, RecurrenceStability.energy, sq_abs]

theorem constant_allowance :
    RecurrenceStability.magnitude (fun _ : Fin 128 => (2 : ℝ)^(-63 : Int)) ≤ (2 : ℝ)^(-59 : Int) := by
  have hs := RecurrenceStability.magnitude_square (fun _ : Fin 128 => (2 : ℝ)^(-63 : Int))
  norm_num [RecurrenceStability.energy] at hs ⊢
  nlinarith only [hs]

theorem relative_vector (x error : Fin 128 → ℝ)
    (bound : ∀ i, |error i| ≤ (2 : ℝ)^(-24 : Int)*|x i|+(2 : ℝ)^(-63 : Int)) :
    RecurrenceStability.magnitude error ≤ (2 : ℝ)^(-24 : Int)*RecurrenceStability.magnitude x+(2 : ℝ)^(-59 : Int) := by
  have h := RecurrenceStability.pointwise_bound error _ bound
  have ht := RecurrenceStability.triangle (fun i => (2 : ℝ)^(-24 : Int)*|x i|)
    (fun _ => (2 : ℝ)^(-63 : Int))
  rw [RecurrenceStability.magnitude_scale, magnitude_abs, abs_of_pos (by positivity : (0 : ℝ) < (2 : ℝ)^(-24 : Int))] at ht
  exact h.trans (ht.trans (add_le_add (le_refl _) constant_allowance))

theorem contraction (state : Fin 128 → Float32) (decay : Float32)
    (hs : ∀ i, (state i).isFinite = true) (hd : decay.isFinite = true) (bound : |real decay| ≤ 1) :
    (∀ i, (FlushToZero.mul (state i) decay).isFinite = true) ∧
      RecurrenceStability.magnitude (fun i => real (FlushToZero.mul (state i) decay)) ≤
        RecurrenceStability.magnitude (fun i => real (state i)) := by
  have h i := ContractiveMultiplication.range (state i) decay (hs i) hd bound
  refine ⟨fun i => FlushToZero.finite_flushExact _ _ (h i).1, ?_⟩
  have hn := RecurrenceStability.pointwise_bound _ _ (fun i => (h i).2)
  rwa [magnitude_abs] at hn

theorem error (state : Fin 128 → Float32) (decay : Float32)
    (hs : ∀ i, (state i).isFinite = true ∧ |real (state i)| ≤ (2 : ℝ)^(62 : Nat))
    (hd : decay.isFinite = true) (bound : |real decay| ≤ 1) :
    RecurrenceStability.magnitude (fun i => real (FlushToZero.mul (state i) decay)-real (state i)*real decay) ≤
      (2 : ℝ)^(-24 : Int)*RecurrenceStability.magnitude (fun i => real (state i))+(2 : ℝ)^(-59 : Int) :=
  relative_vector _ _ (fun i => ContractiveMultiplication.bounded_error (state i) decay (hs i).1 hd bound (hs i).2)

theorem budget (state : Fin 128 → Float32) (decay : Float32)
    (hs : ∀ i, (state i).isFinite = true ∧ |real (state i)| ≤ (2 : ℝ)^(62 : Nat))
    (hd : decay.isFinite = true) (bound : |real decay| ≤ 1) :
    RecurrenceStability.magnitude (fun i => FlushToZero.mulBudget (state i) decay) ≤
      (2 : ℝ)^(-24 : Int)*RecurrenceStability.magnitude (fun i => real (state i))+(2 : ℝ)^(-59 : Int) := by
  apply relative_vector
  intro i
  have h := ContractiveMultiplication.budget (state i) decay bound
  have finite := (ContractiveMultiplication.range (state i) decay (hs i).1 hd bound).1
  have positive := (abs_nonneg _).trans (FlushToZero.mul_error (state i) decay finite)
  change 0 ≤ FlushToZero.mulBudget (state i) decay at positive
  rw [abs_of_nonneg positive]
  have tail : (2 : ℝ)^(-150 : Int)+FlushToZero.threshold*(2+|real (state i)|) ≤ (2 : ℝ)^(-63 : Int) := by
    have size := (hs i).2
    norm_num [FlushToZero.threshold] at size ⊢
    linarith only [size]
  linarith only [h, tail]

end Inference.Kernels.Delta.DecayStateBounds
