import layers.TrellisCodebookGateUp
import layers.TrellisCodebookDown
import kernels.trellis.CodebookRanges
import contracts.mlx.FlushedDotProductBounds
import contracts.mlx.BFloat16ConversionBounds
import contracts.mlx.BFloat16DyadicBounds

namespace Inference.Layers.TrellisCodebookRanges
open Contracts.Mlx Contracts.Mlx.Numerics Kernels.Trellis
open FloatLib FloatLib.Floats FloatLib.Floats.Formats.BinaryInterchange

theorem gate_count (tree : Reduction.Tree 32)
    (coverage : (Reduction.leaves tree).Perm (List.finRange 32)) :
    FlushedDotProductBounds.count (GateUpFlushToZero.projectionExpr tree) = 5120 := by
  have h := FlushedDotProductBounds.count_ideal (GateUpFlushToZero.projectionExpr tree)
  rw [GateUpFlushToZero.projection_ideal, Reduction.ideal_complete _ tree coverage,
    GateUpAccuracy.ideal_projection] at h
  simp only [Finset.sum_const, Finset.card_univ, Fintype.card_fin, nsmul_eq_mul, mul_one] at h
  exact_mod_cast h

theorem down_count (tree : Reduction.Tree 32)
    (coverage : (Reduction.leaves tree).Perm (List.finRange 32)) :
    FlushedDotProductBounds.count (DownFlushToZero.projectionExpr tree) = 17408 := by
  have h := FlushedDotProductBounds.count_ideal (DownFlushToZero.projectionExpr tree)
  rw [DownFlushToZero.projection_ideal _ tree coverage] at h
  simp only [Finset.sum_const, Finset.card_univ, Fintype.card_fin, nsmul_eq_mul, mul_one] at h
  exact_mod_cast h

theorem gate_raw (p : TrellisCodebookGateUp.Platform) (w : TrellisCodebookGateUp.Projection)
    (input : Nat → BitVec 16) (row : Nat) (es ei : Int) (weightCount : Nat) (size : 5120*weightCount < 16777216)
    (weightLo : -149 ≤ 2+es) (weightHi : 2+es ≤ 100)
    (termLo : -149 ≤ 2+es+ei) (termHi : 2+es+ei ≤ 100)
    (hs : (w.scale row).isFinite = true ∧ |real (w.scale row)| ≤ (weightCount : ℝ)*(2 : ℝ)^es)
    (hx : ∀ i, (GateUpExecution.widen (input i)).isFinite = true ∧
      |real (GateUpExecution.widen (input i))| ≤ (2 : ℝ)^ei) :
    TrellisCodebookGateUp.Finite p w input row ∧
      |real (TrellisCodebookGateUp.raw p w input row)| ≤ (5120*weightCount : Nat) * (2 : ℝ)^(2+es+ei) := by
  have hcount := gate_count p.reduction.tree p.reduction.coverage
  have h := FlushedDotProductBounds.ranges_weighted (fun col => DownExecution.coefficient w.words w.width row col)
    (fun _ => w.scale row) (fun col => GateUpExecution.widen (input col)) 2 es ei 1 weightCount (by omega)
    weightLo weightHi termLo termHi
    (fun col => by norm_num only [zpow_ofNat]; exact CodebookRanges.ranges _) (fun _ => hs)
    (by simpa only [Nat.cast_one, one_mul] using hx)
    (GateUpFlushToZero.projectionExpr p.reduction.tree) (by simpa only [hcount, Nat.mul_one] using size)
  refine ⟨h.1, ?_⟩
  rw [TrellisCodebookGateUp.raw_eq]
  simpa only [hcount, Nat.mul_one, Nat.cast_ofNat] using h.2

theorem down_raw (p : TrellisCodebookDown.Platform) (w : TrellisCodebookDown.Projection)
    (input : Nat → Float32) (es ei : Int) (multiplicity : Nat) (size : 17408*multiplicity < 16777216)
    (weightLo : -149 ≤ 2+es) (weightHi : 2+es ≤ 100)
    (termLo : -149 ≤ 2+es+ei) (termHi : 2+es+ei ≤ 100)
    (hs : ∀ i, (w.scale i).isFinite = true ∧ |real (w.scale i)| ≤ (2 : ℝ)^es)
    (hx : ∀ i, (input i).isFinite = true ∧ |real (input i)| ≤ (multiplicity : ℝ)*(2 : ℝ)^ei) (col : Fin 5120) :
    DownFlushToZero.Finite w.words w.width w.scale input col.val p.reduction.tree ∧
      (TrellisCodebookDown.raw p w input col).isFinite = true ∧
      |real (TrellisCodebookDown.raw p w input col)| ≤ (17408*multiplicity : Nat) * (2 : ℝ)^(2+es+ei) := by
  have hcount := down_count p.reduction.tree p.reduction.coverage
  have h := FlushedDotProductBounds.ranges_scaled (fun row => DownExecution.coefficient w.words w.width row col.val)
    w.scale input 2 es ei multiplicity weightLo weightHi termLo termHi
    (fun row => by norm_num only [zpow_ofNat]; exact CodebookRanges.ranges _) hs hx
    (DownFlushToZero.projectionExpr p.reduction.tree) (by rw [hcount]; exact size)
  have he : TrellisCodebookDown.raw p w input col =
      FlushedDotProduct.evaluate (fun row => DownExecution.coefficient w.words w.width row col.val)
        w.scale input (DownFlushToZero.projectionExpr p.reduction.tree) := by
    rw [TrellisCodebookDown.raw, p.reduction.execution, DownFlushToZero.evaluate_projection]
  refine ⟨h.1, ?_, ?_⟩
  · rw [he]; exact FlushedDotProduct.finite_evaluate _ _ _ _ h.1
  · rw [he]; simpa only [hcount, Nat.cast_ofNat] using h.2

end Inference.Layers.TrellisCodebookRanges
