import contracts.mlx.ArithmeticFoldBounds

namespace Inference.Contracts.Mlx.ArithmeticVaryingBounds
open Numerics Arithmetic ArithmeticFold

-- Per-operand exponents may differ at each term while the product ceiling
-- stays fixed. This captures packed masks paired with divided inputs.
theorem madd_range (input : Nat → Float32) (contracted : Bool) (a b acc : Expr)
    (ea eb exponent : Int) (count : Nat) (same : ea+eb = exponent)
    (lo : -149 ≤ exponent) (hi : exponent ≤ 100) (size : count+1 < 16777216)
    (ha : Finite input a ∧ |real (evaluate input a)| ≤ (2 : ℝ)^ea)
    (hb : Finite input b ∧ |real (evaluate input b)| ≤ (2 : ℝ)^eb)
    (hc : Finite input acc ∧ |real (evaluate input acc)| ≤ (count : ℝ) * (2 : ℝ)^exponent) :
    Finite input (madd contracted a b acc) ∧
      |real (evaluate input (madd contracted a b acc))| ≤ ((count+1 : Nat) : ℝ) * (2 : ℝ)^exponent := by
  have h := ArithmeticFoldBounds.madd_range input contracted a b acc ea eb count
    (by rwa [same]) (by rwa [same]) size ha hb (by simpa only [same] using hc)
  simpa only [same] using h

theorem sites_range (input : Nat → Float32) (contracted : α → Bool) (a b : α → Expr)
    (ea eb : α → Int) (exponent : Int) (same : ∀ i, ea i + eb i = exponent)
    (lo : -149 ≤ exponent) (hi : exponent ≤ 100)
    (ha : ∀ i, Finite input (a i) ∧ |real (evaluate input (a i))| ≤ (2 : ℝ)^(ea i))
    (hb : ∀ i, Finite input (b i) ∧ |real (evaluate input (b i))| ≤ (2 : ℝ)^(eb i))
    (indices : List α) (acc : Expr) (count : Nat) (size : count+indices.length < 16777216)
    (hc : Finite input acc ∧ |real (evaluate input acc)| ≤ (count : ℝ) * (2 : ℝ)^exponent) :
    Finite input (indices.foldl (fun acc i => madd (contracted i) (a i) (b i) acc) acc) ∧
      |real (evaluate input (indices.foldl (fun acc i => madd (contracted i) (a i) (b i) acc) acc))| ≤
        ((count+indices.length : Nat) : ℝ) * (2 : ℝ)^exponent := by
  induction indices generalizing acc count with
  | nil => simpa only [List.foldl_nil, List.length_nil, Nat.add_zero] using hc
  | cons i rest ih =>
    have hs := madd_range input (contracted i) (a i) (b i) acc (ea i) (eb i) exponent count (same i)
      lo hi (by simp only [List.length_cons] at size; omega) (ha i) (hb i) hc
    have h := ih (madd (contracted i) (a i) (b i) acc) (count+1)
      (by simp only [List.length_cons] at size; omega) hs
    simpa only [List.foldl_cons, List.length_cons, Nat.add_assoc, Nat.add_comm 1 rest.length] using h

theorem fold_range (input : Nat → Float32) (contracted : Bool) (a b : α → Expr)
    (ea eb : α → Int) (exponent : Int) (same : ∀ i, ea i + eb i = exponent)
    (lo : -149 ≤ exponent) (hi : exponent ≤ 100)
    (ha : ∀ i, Finite input (a i) ∧ |real (evaluate input (a i))| ≤ (2 : ℝ)^(ea i))
    (hb : ∀ i, Finite input (b i) ∧ |real (evaluate input (b i))| ≤ (2 : ℝ)^(eb i))
    (indices : List α) (acc : Expr) (count : Nat) (size : count+indices.length < 16777216)
    (hc : Finite input acc ∧ |real (evaluate input acc)| ≤ (count : ℝ) * (2 : ℝ)^exponent) :
    Finite input (indices.foldl (fun acc i => madd contracted (a i) (b i) acc) acc) ∧
      |real (evaluate input (indices.foldl (fun acc i => madd contracted (a i) (b i) acc) acc))| ≤
        ((count+indices.length : Nat) : ℝ) * (2 : ℝ)^exponent :=
  sites_range input (fun _ => contracted) a b ea eb exponent same lo hi ha hb indices acc count size hc

end Inference.Contracts.Mlx.ArithmeticVaryingBounds
