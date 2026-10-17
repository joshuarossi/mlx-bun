import kernels.attention.SdpaUpdateBounds
import Mathlib.Analysis.Complex.ExponentialBounds

namespace Inference.Kernels.Attention.SdpaLoopBounds
open Contracts.Mlx Contracts.Mlx.Numerics SdpaUpdate

noncomputable def ratio (count : Nat) : ℝ := (1+(2 : ℝ)^(-19 : Int))^count*(2 : ℝ)^(23 : Nat)

theorem ratio_bounds (count : Nat) (bound : count ≤ 8192) :
    (2 : ℝ)^(23 : Nat) ≤ ratio count ∧ ratio count ≤ (2 : ℝ)^(25 : Nat) := by
  have lower : 1 ≤ (1+(2 : ℝ)^(-19 : Int))^count := one_le_pow₀ (by norm_num)
  have exponential : 1+(2 : ℝ)^(-19 : Int) ≤ Real.exp ((2 : ℝ)^(-19 : Int)) := by
    simpa only [add_comm] using Real.add_one_le_exp ((2 : ℝ)^(-19 : Int))
  have power := pow_le_pow_left₀ (by positivity : (0 : ℝ) ≤ 1+(2 : ℝ)^(-19 : Int)) exponential count
  rw [← Real.exp_nat_mul] at power
  have duration : (count : ℝ)*(2 : ℝ)^(-19 : Int) ≤ 1 := by
    have h : (count : ℝ) ≤ 8192 := by exact_mod_cast bound
    norm_num
    linarith only [h]
  have upper := power.trans ((Real.exp_le_exp.mpr duration).trans Real.exp_one_lt_three.le)
  constructor
  · simpa only [ratio, one_mul] using mul_le_mul_of_nonneg_right lower (by positivity : (0 : ℝ) ≤ 2^23)
  · have h := mul_le_mul_of_nonneg_right upper (by positivity : (0 : ℝ) ≤ 2^23)
    change ratio count ≤ 3*(2 : ℝ)^(23 : Nat) at h
    exact h.trans (by norm_num)

theorem ratio_next (count : Nat) : ratio (count+1) = (1+(2 : ℝ)^(-19 : Int))*ratio count := by
  unfold ratio
  rw [pow_succ]
  ring

theorem from_state (p : SdpaVector.Platform) (maximum : SdpaInitialLoopRanges.Maximum p)
    (primitive : SdpaExponentRanges.Primitive p.merge.scalar) (scores values : α → Float32)
    (hs : ∀ i, (scores i).isFinite = true ∧ |real (scores i)| ≤ (2 : ℝ)^(24 : Nat))
    (hv : ∀ i, (values i).isFinite = true ∧ |real (values i)| ≤ (2 : ℝ)^(23 : Nat))
    (indices : List α) (state : State) (count : Nat) (bound : count+indices.length ≤ 8192)
    (initial : SdpaUpdateBounds.Bounds state count (ratio count)) :
    SdpaLoop.Finite p.merge.scalar p.maximum scores values indices state ∧
      SdpaUpdateBounds.Bounds (SdpaLoop.run p.merge.scalar p.maximum scores values indices state)
        (count+indices.length) (ratio (count+indices.length)) := by
  induction indices generalizing state count with
  | nil => exact ⟨True.intro, by simpa only [List.length_nil, Nat.add_zero, SdpaLoop.run] using initial⟩
  | cons i rest ih =>
    have hc : count ≤ 8192 := by simp only [List.length_cons] at bound; omega
    have next := SdpaUpdateBounds.step p maximum primitive state (scores i) (values i) count hc
      (ratio count) (ratio_bounds count hc).1 (ratio_bounds count hc).2 initial (hs i) (hv i)
    rw [← ratio_next] at next
    have tail := ih (SdpaLoop.next p.merge.scalar p.maximum scores values i state) (count+1)
      (by simp only [List.length_cons] at bound; omega) next.2
    refine ⟨⟨next.1, tail.1⟩, ?_⟩
    simpa only [SdpaLoop.run, List.length_cons, Nat.add_assoc, Nat.add_comm, Nat.add_left_comm] using tail.2

theorem initialized (p : SdpaVector.Platform) (maximum : SdpaInitialLoopRanges.Maximum p)
    (primitive : SdpaExponentRanges.Primitive p.merge.scalar) (scores values : α → Float32)
    (hs : ∀ i, (scores i).isFinite = true ∧ |real (scores i)| ≤ (2 : ℝ)^(24 : Nat))
    (hv : ∀ i, (values i).isFinite = true ∧ |real (values i)| ≤ (2 : ℝ)^(23 : Nat))
    (indices : List α) (nonempty : indices ≠ []) (bound : indices.length ≤ 8192) :
    SdpaLoop.Finite p.merge.scalar p.maximum scores values indices (SdpaLoop.initial SdpaVector.initialShift) ∧
      SdpaUpdateBounds.Bounds
        (SdpaLoop.run p.merge.scalar p.maximum scores values indices (SdpaLoop.initial SdpaVector.initialShift))
        indices.length (ratio indices.length) := by
  cases indices with
  | nil => exact False.elim (nonempty rfl)
  | cons i rest =>
    have first := SdpaInitialUpdateRanges.ranges p.merge.scalar primitive (scores i) (values i)
      (hs i).1 (hs i).2 (hv i).1 (hv i).2
    have finite := SdpaUpdate.step_finite _ _ _ _ _ first.1
    have choose := SdpaInitialLoopRanges.choose_initial p maximum (scores i) (hs i).1 (hs i).2
    have initial : SdpaUpdateBounds.Bounds
        (SdpaUpdate.step p.merge.scalar (SdpaLoop.initial SdpaVector.initialShift) (scores i) (values i) (scores i))
        1 (ratio 1) := by
      refine ⟨hs i, ⟨finite.2.1, ?_, ?_⟩, ⟨finite.2.2, ?_⟩⟩
      · rw [first.2.1]
      · rw [first.2.1]; norm_num
      · rw [first.2.1, mul_one]
        exact first.2.2.trans (ratio_bounds 1 (by decide)).1
    have tail := from_state p maximum primitive scores values hs hv rest _ 1
      (by simp only [List.length_cons] at bound; omega) initial
    refine ⟨?_, ?_⟩
    · change SdpaUpdate.Finite p.merge.scalar (SdpaLoop.initial SdpaVector.initialShift)
        (scores i) (values i) (p.maximum SdpaVector.initialShift (scores i)) ∧ _
      rw [choose]
      exact ⟨first.1, by simpa only [SdpaLoop.next, SdpaLoop.initial, choose] using tail.1⟩
    · simpa only [SdpaLoop.run, SdpaLoop.next, SdpaLoop.initial, choose, List.length_cons, Nat.add_comm] using tail.2

end Inference.Kernels.Attention.SdpaLoopBounds
