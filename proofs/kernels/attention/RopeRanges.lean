import kernels.attention.Rope
import contracts.mlx.ArithmeticBounds
import contracts.mlx.DyadicBounds
import contracts.mlx.BFloat16DyadicBounds
import contracts.mlx.BFloat16ConversionBounds

namespace Inference.Kernels.Attention.RopeRanges
open Contracts.Mlx Contracts.Mlx.Numerics Rope ArithmeticBounds
open FloatLib FloatLib.Floats FloatLib.Floats.Formats.BinaryInterchange
abbrev BF := BFloat16Arithmetic.Value

def inputCap (i : Nat) : Float32 :=
  if i = 0 ∨ i = 1 ∨ i = 4 then DyadicBounds.ceiling 1 8
  else if i = 5 then DyadicBounds.ceiling 1 9 else DyadicBounds.ceiling 1 1
def productCap : Float32 := DyadicBounds.ceiling 1 9
def outputCap : Float32 := DyadicBounds.ceiling 1 10
def storeCap : BF := BFloat16DyadicBounds.ceiling 1 10

private theorem cap (e : Int) (bounds : 0 ≤ e ∧ e ≤ 100) :
    (DyadicBounds.ceiling 1 e).isFinite = true ∧ real (DyadicBounds.ceiling 1 e) = (2 : ℝ)^e := by
  simpa only [Nat.cast_one, one_mul] using
    DyadicBounds.ceiling_range 1 e (by decide) (by omega) bounds.2

theorem certificate (p : Platform) (second : Bool) : Certificate inputCap (expression p second) outputCap := by
  have m02 : Certificate inputCap (.mul (.input 0) (.input 2)) productCap :=
    .mul (.input 0) (.input 2) productCap (cap 9 (by decide)).1 (by
      norm_num [inputCap, productCap, (cap 8 (by decide)).2, (cap 1 (by decide)).2, (cap 9 (by decide)).2])
  have m13 : Certificate inputCap (.mul (.input 1) (.input 3)) productCap :=
    .mul (.input 1) (.input 3) productCap (cap 9 (by decide)).1 (by
      norm_num [inputCap, productCap, (cap 8 (by decide)).2, (cap 1 (by decide)).2, (cap 9 (by decide)).2])
  have m03 : Certificate inputCap (.mul (.input 0) (.input 3)) productCap :=
    .mul (.input 0) (.input 3) productCap (cap 9 (by decide)).1 (by
      norm_num [inputCap, productCap, (cap 8 (by decide)).2, (cap 1 (by decide)).2, (cap 9 (by decide)).2])
  have m12 : Certificate inputCap (.mul (.input 1) (.input 2)) productCap :=
    .mul (.input 1) (.input 2) productCap (cap 9 (by decide)).1 (by
      norm_num [inputCap, productCap, (cap 8 (by decide)).2, (cap 1 (by decide)).2, (cap 9 (by decide)).2])
  have sum : real productCap + real productCap ≤ real outputCap := by
    norm_num [productCap, outputCap, (cap 9 (by decide)).2, (cap 10 (by decide)).2]
  have outputFinite := (cap 10 (by decide)).1
  cases second with
  | false =>
    cases h : p.first <;> simp only [expression, Bool.false_eq_true, ite_false, h, firstExpr]
    · exact .sub m02 m13 outputCap outputFinite sum
    · exact .fma (.input 0) (.input 2) (.input 5) outputCap outputFinite (by
        norm_num [inputCap, outputCap, (cap 8 (by decide)).2, (cap 1 (by decide)).2, (cap 9 (by decide)).2, (cap 10 (by decide)).2])
    · exact .fma (.input 4) (.input 3) m02 outputCap outputFinite (by
        norm_num [inputCap, productCap, outputCap, (cap 8 (by decide)).2, (cap 1 (by decide)).2, (cap 9 (by decide)).2, (cap 10 (by decide)).2])
  | true =>
    cases h : p.second <;> simp only [expression, ite_true, h, secondExpr]
    · exact .add m03 m12 outputCap outputFinite sum
    · exact .fma (.input 0) (.input 3) m12 outputCap outputFinite (by
        norm_num [inputCap, productCap, outputCap, (cap 8 (by decide)).2, (cap 1 (by decide)).2, (cap 9 (by decide)).2, (cap 10 (by decide)).2])
    · exact .fma (.input 1) (.input 2) m03 outputCap outputFinite (by
        norm_num [inputCap, productCap, outputCap, (cap 8 (by decide)).2, (cap 1 (by decide)).2, (cap 9 (by decide)).2, (cap 10 (by decide)).2])

-- Scalar trigonometric range conformance stays separate from its existing
-- approximation contract and from the software angle calculation.
structure TrigRanges (p : Platform) : Prop where
  sine : ∀ theta, theta.isFinite = true → p.domain theta →
    (p.sin theta).isFinite = true ∧ |real (p.sin theta)| ≤ 2
  cosine : ∀ theta, theta.isFinite = true → p.domain theta →
    (p.cos theta).isFinite = true ∧ |real (p.cos theta)| ≤ 2

theorem ranges (p : Platform) (primitive : TrigRanges p) (x : Inputs)
    (h1 : Model.isFinite x.first = true ∧ |Model.toReal x.first| ≤ 256)
    (h2 : Model.isFinite x.second = true ∧ |Model.toReal x.second| ≤ 256)
    (ht : x.theta.isFinite = true) (domain : p.domain x.theta) :
    Rope.Finite p x ∧ ∀ second, |Model.toReal (value p x second)| ≤ 1024 := by
  have hs := primitive.sine x.theta ht domain
  have hc := primitive.cosine x.theta ht domain
  have hw1 := BFloat16.widen_finite _ h1.1
  have hw2 := BFloat16.widen_finite _ h2.1
  have hp := NativeMultiplication.range (BFloat16.widen x.second) (p.sin x.theta) productCap hw2 hs.1
    (cap 9 (by decide)).1 (by
      rw [BFloat16.widen_real _ h2.1]
      have h := mul_le_mul h2.2 hs.2 (abs_nonneg _) (by norm_num : (0 : ℝ) ≤ 256)
      norm_num at h
      simpa only [productCap, (cap 9 (by decide)).2, show (2 : ℝ)^(9 : Int) = 512 from by norm_num] using h)
  have hpf : (product p x).isFinite = true := FlushToZero.finite_flushExact _ _ hp.1
  have hi : ∀ i, (Rope.bind p x i).isFinite = true ∧ |real (Rope.bind p x i)| ≤ real (inputCap i) := by
    intro i
    by_cases h4 : i = 4
    · subst i
      exact ⟨Negation.finite_neg _ hw2, by
        simpa [Rope.bind, inputCap, Negation.real_neg _ hw2, BFloat16.widen_real _ h2.1, (cap 8 (by decide)).2,
          show (2 : ℝ)^(8 : Int) = 256 from by norm_num] using h2.2⟩
    by_cases h5 : i = 5
    · subst i
      exact ⟨Negation.finite_neg _ hpf, by
        change |real (-product p x)| ≤ real productCap
        rw [Negation.real_neg _ hpf, abs_neg]
        exact hp.2⟩
    by_cases h0 : i = 0
    · subst i
      exact ⟨hw1, by simpa [Rope.bind, baseBind, inputCap, BFloat16.widen_real _ h1.1, (cap 8 (by decide)).2,
        show (2 : ℝ)^(8 : Int) = 256 from by norm_num] using h1.2⟩
    by_cases h1i : i = 1
    · subst i
      exact ⟨hw2, by simpa [Rope.bind, baseBind, inputCap, BFloat16.widen_real _ h2.1, (cap 8 (by decide)).2,
        show (2 : ℝ)^(8 : Int) = 256 from by norm_num] using h2.2⟩
    by_cases h2i : i = 2
    · subst i
      simpa [Rope.bind, baseBind, inputCap, (cap 1 (by decide)).2] using hc
    · simpa [Rope.bind, baseBind, inputCap, h4, h5, h0, h1i, h2i, (cap 1 (by decide)).2] using hs
  have ha second := ArithmeticBounds.sound (Rope.bind p x) inputCap hi (certificate p second)
  have hstore := BFloat16DyadicBounds.ceiling_range 1 10 (by decide) (by decide) (by decide)
  have hn second := BFloat16ConversionBounds.narrow_range (source p x second) storeCap
    (by rw [← execution]; exact Arithmetic.finite_evaluate _ _ (ha second).1) hstore.1 (by
      rw [← execution]
      exact (ha second).2.trans (by
        change real outputCap ≤ Model.toReal (BFloat16DyadicBounds.ceiling 1 10)
        rw [hstore.2]
        norm_num [outputCap, (cap 10 (by decide)).2]))
  exact ⟨⟨⟨h1.1, h2.1, ht, domain, hs.1, hc.1, hp.1⟩, fun second => (ha second).1,
    fun second => (hn second).1⟩, fun second => by simpa only [value, storeCap, hstore.2, Nat.cast_one, one_mul, show (2 : ℝ)^(10 : Int) = 1024 from by norm_num] using (hn second).2⟩

end Inference.Kernels.Attention.RopeRanges
