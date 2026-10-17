import contracts.mlx.DyadicBounds
import contracts.mlx.ArithmeticFold

namespace Inference.Contracts.Mlx.AdditionFoldBounds
open Numerics Arithmetic

theorem add_range (input : Nat → Float32) (a b : Expr) (exponent : Int)
    (ma mb : Nat) (lo : -149 ≤ exponent) (hi : exponent ≤ 100)
    (size : ma + mb < 16777216)
    (ha : Finite input a ∧ |real (evaluate input a)| ≤ (ma : ℝ) * (2 : ℝ)^exponent)
    (hb : Finite input b ∧ |real (evaluate input b)| ≤ (mb : ℝ) * (2 : ℝ)^exponent) :
    Finite input (.add a b) ∧
      |real (evaluate input (.add a b))| ≤ ((ma + mb : Nat) : ℝ) * (2 : ℝ)^exponent := by
  have hc := DyadicBounds.ceiling_range (ma+mb) exponent size lo hi
  have h := Float32Bounds.add_range (evaluate input a) (evaluate input b)
    (DyadicBounds.ceiling (ma+mb) exponent)
    (finite_evaluate _ _ ha.1) (finite_evaluate _ _ hb.1) hc.1
    (by rw [hc.2]; calc
        _ ≤ (ma : ℝ) * (2 : ℝ)^exponent + (mb : ℝ) * (2 : ℝ)^exponent := add_le_add ha.2 hb.2
        _ = _ := by push_cast; ring)
  exact ⟨⟨ha.1, hb.1, h.1⟩, by simpa only [evaluate, hc.2] using h.2⟩

theorem fold_range (input : Nat → Float32) (value : α → Expr)
    (exponent : Int) (weight : Nat) (lo : -149 ≤ exponent) (hi : exponent ≤ 100)
    (hv : ∀ i, Finite input (value i) ∧ |real (evaluate input (value i))| ≤ (weight : ℝ) * (2 : ℝ)^exponent)
    (indices : List α) (acc : Expr) (count : Nat) (size : count + indices.length * weight < 16777216)
    (hc : Finite input acc ∧ |real (evaluate input acc)| ≤ (count : ℝ) * (2 : ℝ)^exponent) :
    Finite input (indices.foldl (fun acc i => .add acc (value i)) acc) ∧
      |real (evaluate input (indices.foldl (fun acc i => .add acc (value i)) acc))| ≤
        ((count + indices.length * weight : Nat) : ℝ) * (2 : ℝ)^exponent := by
  induction indices generalizing acc count with
  | nil => simpa only [List.foldl_nil, List.length_nil, Nat.zero_mul, Nat.add_zero] using hc
  | cons i rest ih =>
    have hs : count + weight < 16777216 := by
      simp only [List.length_cons, Nat.add_mul, Nat.one_mul] at size
      omega
    have hstep := add_range input acc (value i) exponent count weight lo hi hs hc (hv i)
    have h := ih (.add acc (value i)) (count+weight)
      (by simp only [List.length_cons, Nat.add_mul, Nat.one_mul] at size; omega) hstep
    simpa only [List.foldl_cons, List.length_cons, Nat.add_mul, Nat.one_mul,
      Nat.add_assoc, Nat.add_comm weight (rest.length * weight)] using h

theorem from_zero (input : Nat → Float32) (value : α → Expr)
    (exponent : Int) (weight : Nat) (lo : -149 ≤ exponent) (hi : exponent ≤ 100)
    (hv : ∀ i, Finite input (value i) ∧ |real (evaluate input (value i))| ≤ (weight : ℝ) * (2 : ℝ)^exponent)
    (indices : List α) (size : indices.length * weight < 16777216) :
    Finite input (indices.foldl (fun acc i => .add acc (value i)) .zero) ∧
      |real (evaluate input (indices.foldl (fun acc i => .add acc (value i)) .zero))| ≤
        ((indices.length * weight : Nat) : ℝ) * (2 : ℝ)^exponent := by
  have hz : real (0 : Float32) = 0 := by
    rw [real_unpack]; exact FloatLib.Floats.Formats.BinaryInterchange.Model.unpackedToReal_zero .positive
  simpa only [Nat.zero_add] using fold_range input value exponent weight lo hi hv indices .zero 0
    (by simpa only [Nat.zero_add] using size)
    ⟨True.intro, by simp only [evaluate, hz, abs_zero, Nat.cast_zero, zero_mul, le_refl]⟩

theorem reduce_range (input : Nat → Float32) (lanes : Fin n → Expr)
    (exponent : Int) (weight : Nat) (lo : -149 ≤ exponent) (hi : exponent ≤ 100)
    (hv : ∀ i, Finite input (lanes i) ∧ |real (evaluate input (lanes i))| ≤ (weight : ℝ) * (2 : ℝ)^exponent)
    (tree : Reduction.Tree n) (size : (Reduction.leaves tree).length * weight < 16777216) :
    Finite input (ArithmeticFold.reduceExpr lanes tree) ∧
      |real (evaluate input (ArithmeticFold.reduceExpr lanes tree))| ≤
        (((Reduction.leaves tree).length * weight : Nat) : ℝ) * (2 : ℝ)^exponent := by
  induction tree with
  | leaf i => simpa only [ArithmeticFold.reduceExpr, Reduction.leaves, List.length_singleton, Nat.one_mul] using hv i
  | add a b ia ib =>
    have hs : (Reduction.leaves a).length * weight + (Reduction.leaves b).length * weight < 16777216 := by
      simpa only [Reduction.leaves, List.length_append, Nat.add_mul] using size
    have ha := ia (by omega)
    have hb := ib (by omega)
    have h := add_range input (ArithmeticFold.reduceExpr lanes a) (ArithmeticFold.reduceExpr lanes b)
      exponent ((Reduction.leaves a).length * weight) ((Reduction.leaves b).length * weight) lo hi hs ha hb
    simpa only [ArithmeticFold.reduceExpr, Reduction.leaves, List.length_append, Nat.add_mul] using h

end Inference.Contracts.Mlx.AdditionFoldBounds
