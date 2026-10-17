import contracts.mlx.DyadicBounds
import contracts.mlx.ArithmeticBounds
import contracts.mlx.ArithmeticFold

namespace Inference.Contracts.Mlx.ArithmeticFoldBounds
open Numerics Arithmetic ArithmeticFold ArithmeticBounds

theorem madd_range (input : Nat → Float32) (contracted : Bool) (a b acc : Expr)
    (ea eb : Int) (count : Nat) (lo : -149 ≤ ea + eb) (hi : ea + eb ≤ 100)
    (size : count + 1 < 16777216)
    (ha : Finite input a ∧ |real (evaluate input a)| ≤ (2 : ℝ)^ea)
    (hb : Finite input b ∧ |real (evaluate input b)| ≤ (2 : ℝ)^eb)
    (hc : Finite input acc ∧ |real (evaluate input acc)| ≤ (count : ℝ) * (2 : ℝ)^(ea+eb)) :
    Finite input (madd contracted a b acc) ∧
      |real (evaluate input (madd contracted a b acc))| ≤ ((count + 1 : Nat) : ℝ) * (2 : ℝ)^(ea+eb) := by
  have hp : |real (evaluate input a)| * |real (evaluate input b)| ≤ (2 : ℝ)^(ea+eb) := by
    rw [zpow_add₀ (by norm_num : (2 : ℝ) ≠ 0)]
    exact mul_le_mul ha.2 hb.2 (abs_nonneg _) (zpow_nonneg (by norm_num) _)
  have hout := DyadicBounds.ceiling_range (count + 1) (ea+eb) size lo hi
  cases contracted
  · have hproduct := DyadicBounds.ceiling_range 1 (ea+eb) (by decide) lo hi
    have hm := NativeMultiplication.range (evaluate input a) (evaluate input b) (DyadicBounds.ceiling 1 (ea+eb))
      (finite_evaluate _ _ ha.1) (finite_evaluate _ _ hb.1) hproduct.1
      (by simpa only [hproduct.2, Nat.cast_one, one_mul] using hp)
    have hadd := Float32Bounds.add_range (evaluate input acc) (FlushToZero.mul (evaluate input a) (evaluate input b))
      (DyadicBounds.ceiling (count+1) (ea+eb)) (finite_evaluate _ _ hc.1) (FlushToZero.mul_finite _ _ hm.1) hout.1
      (by rw [hout.2]; have hm' := hm.2; rw [hproduct.2, Nat.cast_one] at hm';
          calc
            _ ≤ (count : ℝ) * (2 : ℝ)^(ea+eb) + 1 * (2 : ℝ)^(ea+eb) := add_le_add hc.2 hm'
            _ = _ := by push_cast; ring)
    exact ⟨⟨hc.1, ⟨ha.1, hb.1, hm.1⟩, hadd.1⟩, by simpa only [madd, Bool.false_eq_true, ite_false, evaluate, hout.2] using hadd.2⟩
  · have hm := NativeFma.range (evaluate input a) (evaluate input b) (evaluate input acc)
      (DyadicBounds.ceiling (count+1) (ea+eb)) (finite_evaluate _ _ ha.1) (finite_evaluate _ _ hb.1)
      (finite_evaluate _ _ hc.1) hout.1
      (by rw [hout.2]; calc
          _ ≤ (2 : ℝ)^(ea+eb) + (count : ℝ) * (2 : ℝ)^(ea+eb) := add_le_add hp hc.2
          _ = _ := by push_cast; ring)
    exact ⟨⟨ha.1, hb.1, hc.1, hm.1⟩, by simpa only [madd, ite_true, evaluate, hout.2] using hm.2⟩

theorem fold_range (input : Nat → Float32) (contracted : Bool) (a b : α → Expr)
    (ea eb : Int) (lo : -149 ≤ ea + eb) (hi : ea + eb ≤ 100)
    (ha : ∀ i, Finite input (a i) ∧ |real (evaluate input (a i))| ≤ (2 : ℝ)^ea)
    (hb : ∀ i, Finite input (b i) ∧ |real (evaluate input (b i))| ≤ (2 : ℝ)^eb)
    (indices : List α) (acc : Expr) (count : Nat) (size : count + indices.length < 16777216)
    (hc : Finite input acc ∧ |real (evaluate input acc)| ≤ (count : ℝ) * (2 : ℝ)^(ea+eb)) :
    Finite input (indices.foldl (fun acc i => madd contracted (a i) (b i) acc) acc) ∧
      |real (evaluate input (indices.foldl (fun acc i => madd contracted (a i) (b i) acc) acc))| ≤
        ((count + indices.length : Nat) : ℝ) * (2 : ℝ)^(ea+eb) := by
  induction indices generalizing acc count with
  | nil => simpa only [List.foldl_nil, List.length_nil, Nat.add_zero] using hc
  | cons i rest ih =>
    have hstep := madd_range input contracted (a i) (b i) acc ea eb count lo hi (by simp only [List.length_cons] at size; omega)
      (ha i) (hb i) hc
    have h := ih (madd contracted (a i) (b i) acc) (count+1) (by simp only [List.length_cons] at size; omega) hstep
    simpa only [List.foldl_cons, List.length_cons, Nat.add_assoc, Nat.add_comm 1 rest.length] using h

theorem from_zero (input : Nat → Float32) (contracted : Bool) (a b : α → Expr)
    (ea eb : Int) (lo : -149 ≤ ea + eb) (hi : ea + eb ≤ 100)
    (ha : ∀ i, Finite input (a i) ∧ |real (evaluate input (a i))| ≤ (2 : ℝ)^ea)
    (hb : ∀ i, Finite input (b i) ∧ |real (evaluate input (b i))| ≤ (2 : ℝ)^eb)
    (indices : List α) (size : indices.length < 16777216) :
    Finite input (indices.foldl (fun acc i => madd contracted (a i) (b i) acc) .zero) ∧
      |real (evaluate input (indices.foldl (fun acc i => madd contracted (a i) (b i) acc) .zero))| ≤
        (indices.length : ℝ) * (2 : ℝ)^(ea+eb) := by
  have hz : real (0 : Float32) = 0 := by
    rw [real_unpack]; exact FloatLib.Floats.Formats.BinaryInterchange.Model.unpackedToReal_zero .positive
  simpa only [Nat.zero_add] using fold_range input contracted a b ea eb lo hi ha hb indices .zero 0
    (by simpa only [Nat.zero_add] using size) ⟨True.intro, by simp only [evaluate, hz, abs_zero, Nat.cast_zero, zero_mul, le_refl]⟩

theorem fold (inputCap : Nat → Float32) (contracted : Bool) (a b : α → Expr)
    (ca cb : Float32) (exponent : Int) (lo : -149 ≤ exponent) (hi : exponent ≤ 100)
    (ha : ∀ i, Certificate inputCap (a i) ca) (hb : ∀ i, Certificate inputCap (b i) cb)
    (product : real ca * real cb ≤ (2 : ℝ)^exponent)
    (indices : List α) (acc : Expr) (count : Nat)
    (initial : Certificate inputCap acc (DyadicBounds.ceiling count exponent))
    (size : count + indices.length < 16777216) :
    Certificate inputCap (indices.foldl (fun acc i => madd contracted (a i) (b i) acc) acc)
      (DyadicBounds.ceiling (count + indices.length) exponent) := by
  induction indices generalizing acc count with
  | nil => simpa only [List.foldl_nil, List.length_nil, Nat.add_zero] using initial
  | cons i rest ih =>
    have hcount : count < 16777216 := by simp only [List.length_cons] at size; omega
    have hnext : count+1 < 16777216 := by simp only [List.length_cons] at size; omega
    have hc := DyadicBounds.ceiling_range count exponent hcount lo hi
    have hn := DyadicBounds.ceiling_range (count+1) exponent hnext lo hi
    have hp := DyadicBounds.ceiling_range 1 exponent (by decide) lo hi
    have step : Certificate inputCap (madd contracted (a i) (b i) acc)
        (DyadicBounds.ceiling (count+1) exponent) := by
      cases contracted with
      | false =>
        exact .add initial (.mul (ha i) (hb i) (DyadicBounds.ceiling 1 exponent) hp.1
          (by simpa only [hp.2, Nat.cast_one, one_mul] using product)) _ hn.1
          (by rw [hc.2, hp.2, hn.2]; push_cast; ring_nf; exact le_refl _)
      | true =>
        exact .fma (ha i) (hb i) initial _ hn.1 (by
          rw [hc.2, hn.2]
          calc
            _ ≤ (2 : ℝ)^exponent + (count : ℝ)*(2 : ℝ)^exponent := add_le_add_left product _
            _ = _ := by push_cast; ring)
    have h := ih (madd contracted (a i) (b i) acc) (count+1) step
      (by simp only [List.length_cons] at size; omega)
    simpa only [List.foldl_cons, List.length_cons, show count+1+rest.length = count+(rest.length+1) from by omega] using h

theorem reduction (inputCap : Nat → Float32) (lanes : Fin n → Expr)
    (perLane : Nat) (exponent : Int) (lo : -149 ≤ exponent) (hi : exponent ≤ 100)
    (hl : ∀ i, Certificate inputCap (lanes i) (DyadicBounds.ceiling perLane exponent))
    (tree : Reduction.Tree n) (size : (Reduction.leaves tree).length * perLane < 16777216) :
    Certificate inputCap (reduceExpr lanes tree)
      (DyadicBounds.ceiling ((Reduction.leaves tree).length * perLane) exponent) := by
  induction tree with
  | leaf i => simpa only [reduceExpr, Reduction.leaves, List.length_singleton, Nat.one_mul] using hl i
  | add a b ia ib =>
    have hs : ((Reduction.leaves a).length + (Reduction.leaves b).length)*perLane < 16777216 := by
      simpa only [Reduction.leaves, List.length_append] using size
    have sa : (Reduction.leaves a).length*perLane < 16777216 := by nlinarith
    have sb : (Reduction.leaves b).length*perLane < 16777216 := by nlinarith
    have ca := DyadicBounds.ceiling_range _ exponent sa lo hi
    have cb := DyadicBounds.ceiling_range _ exponent sb lo hi
    have c := DyadicBounds.ceiling_range _ exponent size lo hi
    exact .add (ia sa) (ib sb) _ c.1 (by
      rw [ca.2, cb.2, c.2]
      simp only [Reduction.leaves, List.length_append, Nat.cast_add, add_mul, le_refl])

end Inference.Contracts.Mlx.ArithmeticFoldBounds
