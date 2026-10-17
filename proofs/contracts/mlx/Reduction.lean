import contracts.mlx.Numerics

namespace Inference.Contracts.Mlx.Reduction
open Numerics

/- SIMD addition order is a platform property. This proof works for every
   binary addition tree, so an accuracy contract need not pretend that rounded
   addition is associative. Coverage remains a separate premise on its leaves. -/
inductive Tree (n : Nat) where
  | leaf : Fin n → Tree n
  | add : Tree n → Tree n → Tree n

def leaves : Tree n → List (Fin n)
  | .leaf i => [i]
  | .add a b => leaves a ++ leaves b

def evaluate (input : Fin n → Float32) : Tree n → Float32
  | .leaf i => input i
  | .add a b => evaluate input a + evaluate input b

noncomputable def ideal (input : Fin n → ℝ) : Tree n → ℝ
  | .leaf i => input i
  | .add a b => ideal input a + ideal input b

def Finite (input : Fin n → Float32) : Tree n → Prop
  | .leaf i => (input i).isFinite=true
  | .add a b => Finite input a ∧ Finite input b ∧ (evaluate input a + evaluate input b).isFinite=true

noncomputable def budget (input : Fin n → Float32) (inputError : Fin n → ℝ) : Tree n → ℝ
  | .leaf i => inputError i
  | .add a b => budget input inputError a + budget input inputError b +
      epsilon (real (evaluate input a)+real (evaluate input b))

theorem finite_evaluate (input : Fin n → Float32) (t : Tree n) (h : Finite input t) :
    (evaluate input t).isFinite=true := by
  cases t with
  | leaf => exact h
  | add => exact h.2.2

theorem error (input : Fin n → Float32) (target inputError : Fin n → ℝ)
    (hinput : ∀ i, |real (input i)-target i| ≤ inputError i)
    (t : Tree n) (hfinite : Finite input t) :
    |real (evaluate input t) - ideal target t| ≤ budget input inputError t := by
  induction t with
  | leaf i => exact hinput i
  | add a b ia ib =>
    obtain ⟨ha, hb, hout⟩ := hfinite
    have ea := ia ha
    have eb := ib hb
    have en := add_error (evaluate input a) (evaluate input b)
      (finite_evaluate input a ha) (finite_evaluate input b hb) hout
    simp only [evaluate, ideal, budget]
    calc
      _ = |(real (evaluate input a + evaluate input b) -
            (real (evaluate input a)+real (evaluate input b))) +
          ((real (evaluate input a)-ideal target a)+(real (evaluate input b)-ideal target b))| := by
        congr 1
        ring
      _ ≤ _ := (abs_add_le _ _).trans ((add_le_add en ((abs_add_le _ _).trans (add_le_add ea eb))).trans (by ring_nf; rfl))

theorem ideal_leaves (input : Fin n → ℝ) (t : Tree n) :
    ideal input t = ((leaves t).map input).sum := by
  induction t with
  | leaf i => simp [ideal, leaves]
  | add a b ia ib => simp [ideal, leaves, ia, ib, List.map_append, List.sum_append]

theorem ideal_complete (input : Fin n → ℝ) (t : Tree n)
    (coverage : (leaves t).Perm (List.finRange n)) :
    ideal input t = ((List.finRange n).map input).sum := by
  rw [ideal_leaves]
  exact (coverage.map input).sum_eq

-- A primitive instruction contract records both its tree and the once-only
-- contribution of each lane. It does not assume the desired accuracy result.
structure SimdContract (reduce : (Fin 32 → Float32) → Float32) where
  tree : Tree 32
  coverage : (leaves tree).Perm (List.finRange 32)
  execution : ∀ input, reduce input = evaluate input tree

-- A consistency witness for the contract, without asserting this is the
-- physical chip's particular tree.
def orderedTree : Tree 32 :=
  (List.finRange 31).foldl (fun t i => .add t (.leaf ⟨i.val+1, by omega⟩)) (.leaf ⟨0, by decide⟩)

theorem ordered_coverage : (leaves orderedTree).Perm (List.finRange 32) := by decide +kernel

def orderedContract : SimdContract (fun input => evaluate input orderedTree) :=
  ⟨orderedTree, ordered_coverage, fun _ => rfl⟩

theorem simd_error (reduce : (Fin 32 → Float32) → Float32) (hardware : SimdContract reduce)
    (input : Fin 32 → Float32) (target inputError : Fin 32 → ℝ)
    (hinput : ∀ i, |real (input i)-target i| ≤ inputError i)
    (hfinite : Finite input hardware.tree) :
    |real (reduce input) - ((List.finRange 32).map target).sum| ≤ budget input inputError hardware.tree := by
  rw [hardware.execution, ← ideal_complete target hardware.tree hardware.coverage]
  exact error input target inputError hinput hardware.tree hfinite

end Inference.Contracts.Mlx.Reduction
