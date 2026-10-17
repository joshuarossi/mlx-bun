import contracts.mlx.SquaredSumEnergyBounds
import contracts.mlx.NormalizationReduction

namespace Inference.Contracts.Mlx.NormalizationEnergyBounds
open Numerics SquaredSum SquaredSumEnergyBounds

theorem step_sites (contracted : Bool) (acc : Expr n) (i : Fin n) :
    sites (step contracted acc i) ≤ sites acc + 2 := by
  cases contracted <;> simp [step, sites]

theorem accumulate_sites (contracted : Bool) (columns : List (Fin n)) (acc : Expr n) :
    sites (accumulate contracted columns acc) ≤ sites acc + 2*columns.length := by
  induction columns generalizing acc with
  | nil => simp [accumulate]
  | cons i rest ih =>
    have h := ih (step contracted acc i)
    have hs := step_sites contracted acc i
    change sites (accumulate contracted rest (step contracted acc i)) ≤ _
    simp only [List.length_cons]
    omega

theorem thread_sites (contracted : Bool) (width : Nat) (thread : Fin threads) :
    sites (NormalizationSchedule.threadExpr contracted width thread) ≤
      2*(indices (NormalizationSchedule.threadExpr contracted width thread)).length := by
  have hs := accumulate_sites contracted (NormalizationSchedule.threadColumns width thread) .zero
  have hi := (accumulate_indices contracted (NormalizationSchedule.threadColumns width thread) .zero).length_eq
  simp only [indices, List.nil_append] at hi
  simpa only [NormalizationSchedule.threadExpr, hi, sites, Nat.zero_add] using hs

-- A binary reduction with k leaves adds exactly k-1 rounding sites. Keeping
-- the extra one on the left avoids truncated natural subtraction.
theorem tree_sites (input : Fin m → Expr n) (extra : Nat)
    (hi : ∀ i, sites (input i) ≤ 2*(indices (input i)).length+extra)
    (tree : Reduction.Tree m) :
    sites (reduceTree input tree)+1 ≤
      2*(indices (reduceTree input tree)).length+(extra+1)*(Reduction.leaves tree).length := by
  induction tree with
  | leaf i =>
    have h := hi i
    simp only [reduceTree, Reduction.leaves, List.length_singleton, Nat.mul_one]
    omega
  | add a b ia ib =>
    simp only [reduceTree, sites, indices, Reduction.leaves, List.length_append]
    nlinarith only [ia, ib]

theorem group_sites (contracted : Bool) (width : Nat) (tree : Reduction.Tree 32)
    (hc : (Reduction.leaves tree).Perm (List.finRange 32)) (group : Fin groups) :
    sites (NormalizationReduction.groupExpr contracted width tree group) ≤
      2*(indices (NormalizationReduction.groupExpr contracted width tree group)).length+31 := by
  have h := tree_sites (fun lane => NormalizationSchedule.threadExpr contracted width
    (NormalizationReduction.laneIndex group lane)) 0
    (fun _ => by simpa using thread_sites contracted width _) tree
  have hn : (Reduction.leaves tree).length = 32 := by simpa using hc.length_eq
  rw [hn] at h
  unfold NormalizationReduction.groupExpr
  omega

theorem scratch_sites (contracted : Bool) (groups width : Nat) (tree : Reduction.Tree 32)
    (hc : (Reduction.leaves tree).Perm (List.finRange 32)) (lane : Fin 32) :
    sites (NormalizationReduction.scratchExpr contracted groups width tree lane) ≤
      2*(indices (NormalizationReduction.scratchExpr contracted groups width tree lane)).length+31 := by
  unfold NormalizationReduction.scratchExpr
  split
  · exact group_sites contracted width tree hc _
  · simp [sites, indices]

-- The two 32-lane reductions contribute at most 32*31+31 sites, including
-- every inactive scratch lane. Once-only coverage accounts for all squares.
theorem expression_sites (contracted : Bool) (groups width : Nat)
    (hg : 0 < groups) (hc : groups ≤ 32) (first second : Reduction.Tree 32)
    (hf : (Reduction.leaves first).Perm (List.finRange 32))
    (hs : (Reduction.leaves second).Perm (List.finRange 32)) :
    sites (NormalizationReduction.expression contracted groups width first second) ≤ 2*width+1023 := by
  have h := tree_sites (NormalizationReduction.scratchExpr contracted groups width first) 31
    (scratch_sites contracted groups width first hf) second
  have hn : (Reduction.leaves second).length = 32 := by simpa using hs.length_eq
  have hi : (indices (NormalizationReduction.expression contracted groups width first second)).length = width := by
    simpa using (NormalizationReduction.expression_coverage contracted groups width hg hc first second hf hs).length_eq
  change sites (NormalizationReduction.expression contracted groups width first second)+1 ≤ _ at h
  change _ ≤ 2*(indices (NormalizationReduction.expression contracted groups width first second)).length+
    32*(Reduction.leaves second).length at h
  rw [hi, hn] at h
  omega

theorem sum_lower (contracted : Bool) (groups width : Nat) (hg : 0 < groups) (hc : groups ≤ 32)
    (hw : width ≤ 7680) (first second : Reduction.Tree 32)
    (hf : (Reduction.leaves first).Perm (List.finRange 32))
    (hs : (Reduction.leaves second).Perm (List.finRange 32)) (input : Fin width → Float32)
    (hx : ∀ i, |real (input i)| ≤ (2 : ℝ)^56)
    (finite : Finite input (NormalizationReduction.expression contracted groups width first second)) :
    (1023/1024 : ℝ)*((List.finRange width).map (fun i => real (input i)^2)).sum -
      (2 : ℝ)^(-46 : Int) ≤
      real (evaluate input (NormalizationReduction.expression contracted groups width first second)) := by
  apply SquaredSumEnergyBounds.sum_lower input _ hx finite
  · have h := expression_sites contracted groups width hg hc first second hf hs
    omega
  · exact NormalizationReduction.expression_coverage contracted groups width hg hc first second hf hs

end Inference.Contracts.Mlx.NormalizationEnergyBounds
