import kernels.attention.SdpaScore
import contracts.mlx.ArithmeticFoldBounds

namespace Inference.Kernels.Attention.SdpaScoreRanges
open Contracts.Mlx Contracts.Mlx.Numerics SdpaScore ArithmeticBounds
open FloatLib FloatLib.Floats FloatLib.Floats.Formats.BinaryInterchange

def inputCap (i : Nat) : Float32 :=
  if i < 512 then DyadicBounds.ceiling 1 10 else DyadicBounds.ceiling 1 (-4)

private theorem cap (count : Nat) (exponent : Int) (size : count < 16777216)
    (lo : -149 ≤ exponent) (hi : exponent ≤ 100) :
    (DyadicBounds.ceiling count exponent).isFinite = true ∧
      real (DyadicBounds.ceiling count exponent) = (count : ℝ)*(2 : ℝ)^exponent :=
  DyadicBounds.ceiling_range count exponent size lo hi

theorem certificate (contracted : Bool) (tree : Reduction.Tree 32)
    (coverage : (Reduction.leaves tree).Perm (List.finRange 32)) :
    Certificate inputCap (expression contracted tree) (DyadicBounds.ceiling 256 16) := by
  have q (i : Fin 256) : Certificate inputCap (qExpr i) (DyadicBounds.ceiling 1 6) := by
    exact .mul (.input 512) (.input i.val) _ (cap 1 6 (by decide) (by decide) (by decide)).1 (by
      norm_num [inputCap, show i.val < 512 from by have := i.isLt; omega,
        (cap 1 10 (by decide) (by decide) (by decide)).2,
        (cap 1 (-4) (by decide) (by decide) (by decide)).2,
        (cap 1 6 (by decide) (by decide) (by decide)).2])
  have k (i : Fin 256) : Certificate inputCap (kExpr i) (DyadicBounds.ceiling 1 10) := by
    have h := Certificate.input (inputCap := inputCap) (256+i.val)
    simpa only [kExpr, inputCap, show 256+i.val < 512 from by have := i.isLt; omega, ite_true] using h
  have lanes (lane : Fin 32) : Certificate inputCap (laneExpr contracted lane) (DyadicBounds.ceiling 8 16) := by
    have h := ArithmeticFoldBounds.fold inputCap contracted
      (fun i => qExpr (index lane i)) (fun i => kExpr (index lane i))
      (DyadicBounds.ceiling 1 6) (DyadicBounds.ceiling 1 10) 16 (by decide) (by decide)
      (fun i => q _) (fun i => k _) (by
        norm_num [(cap 1 6 (by decide) (by decide) (by decide)).2,
          (cap 1 10 (by decide) (by decide) (by decide)).2])
      (List.finRange 8) .zero 0 (.zero _ (by
        rw [(cap 0 16 (by decide) (by decide) (by decide)).2]; norm_num)) (by decide)
    simpa only [laneExpr, List.length_finRange, Nat.zero_add] using h
  have hl : (Reduction.leaves tree).length = 32 := by
    simpa only [List.length_finRange] using coverage.length_eq
  have h := ArithmeticFoldBounds.reduction inputCap (laneExpr contracted) 8 16
    (by decide) (by decide) lanes tree (by rw [hl]; decide)
  simpa only [expression, hl] using h

theorem ranges (contracted : Bool) (reduce : (Fin 32 → Float32) → Float32)
    (platform : FlushedReduction.SimdContract reduce) (q k : Fin 256 → BF)
    (hq : ∀ i, Model.isFinite (q i) = true ∧ |Model.toReal (q i)| ≤ 1024)
    (hk : ∀ i, Model.isFinite (k i) = true ∧ |Model.toReal (k i)| ≤ 1024) :
    Arithmetic.Finite (SdpaScore.bind q k) (expression contracted platform.tree) ∧
      |real (source contracted reduce q k)| ≤ (2 : ℝ)^(24 : Nat) := by
  have hi : ∀ i, (SdpaScore.bind q k i).isFinite = true ∧
      |real (SdpaScore.bind q k i)| ≤ real (inputCap i) := by
    intro i
    unfold SdpaScore.bind
    split
    · rename_i h
      exact ⟨BFloat16.widen_finite _ (hq _).1, by
        simpa only [inputCap, show i < 512 from by omega, ite_true,
          BFloat16.widen_real _ (hq _).1, (cap 1 10 (by decide) (by decide) (by decide)).2,
          Nat.cast_one, one_mul, show (2 : ℝ)^(10 : Int) = 1024 from by norm_num] using (hq ⟨i,h⟩).2⟩
    · split
      · rename_i h
        exact ⟨BFloat16.widen_finite _ (hk _).1, by
          simpa only [inputCap, h, ite_true, BFloat16.widen_real _ (hk _).1,
            (cap 1 10 (by decide) (by decide) (by decide)).2, Nat.cast_one, one_mul,
            show (2 : ℝ)^(10 : Int) = 1024 from by norm_num] using (hk ⟨i-256,by omega⟩).2⟩
      · rename_i h
        exact ⟨scale_finite, by norm_num [inputCap, h, scale_value,
          (cap 1 (-4) (by decide) (by decide) (by decide)).2]⟩
  have h := ArithmeticBounds.sound (SdpaScore.bind q k) inputCap hi (certificate contracted platform.tree platform.coverage)
  refine ⟨h.1, ?_⟩
  rw [execution contracted reduce platform] at h
  have ho := h.2
  rw [(cap 256 16 (by decide) (by decide) (by decide)).2] at ho
  norm_num at ho ⊢
  exact ho

end Inference.Kernels.Attention.SdpaScoreRanges
