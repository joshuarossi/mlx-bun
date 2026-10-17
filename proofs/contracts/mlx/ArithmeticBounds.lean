import contracts.mlx.NativeFma

namespace Inference.Contracts.Mlx.ArithmeticBounds
open Numerics Arithmetic

-- A static certificate supplies a representable upper bound at each rounding
-- site. No constructor assumes that an arithmetic result is finite.
inductive Certificate (inputCap : Nat → Float32) : Expr → Float32 → Prop where
  | input (i : Nat) : Certificate inputCap (.input i) (inputCap i)
  | zero (cap : Float32) (nonnegative : 0 ≤ real cap) : Certificate inputCap .zero cap
  | add {a b : Expr} {ca cb : Float32} (ha : Certificate inputCap a ca) (hb : Certificate inputCap b cb)
      (cap : Float32) (finite : cap.isFinite = true) (capacity : real ca + real cb ≤ real cap) :
      Certificate inputCap (.add a b) cap
  | sub {a b : Expr} {ca cb : Float32} (ha : Certificate inputCap a ca) (hb : Certificate inputCap b cb)
      (cap : Float32) (finite : cap.isFinite = true) (capacity : real ca + real cb ≤ real cap) :
      Certificate inputCap (.sub a b) cap
  | mul {a b : Expr} {ca cb : Float32} (ha : Certificate inputCap a ca) (hb : Certificate inputCap b cb)
      (cap : Float32) (finite : cap.isFinite = true) (capacity : real ca * real cb ≤ real cap) :
      Certificate inputCap (.mul a b) cap
  | fma {a b c : Expr} {ca cb cc : Float32}
      (ha : Certificate inputCap a ca) (hb : Certificate inputCap b cb) (hc : Certificate inputCap c cc)
      (cap : Float32) (finite : cap.isFinite = true) (capacity : real ca * real cb + real cc ≤ real cap) :
      Certificate inputCap (.fma a b c) cap

theorem sound (input inputCap : Nat → Float32)
    (hi : ∀ i, (input i).isFinite = true ∧ |real (input i)| ≤ real (inputCap i))
    {expr : Expr} {cap : Float32} (certificate : Certificate inputCap expr cap) :
    Finite input expr ∧ |real (evaluate input expr)| ≤ real cap := by
  induction certificate with
  | input i => exact hi i
  | zero cap nonnegative =>
    have hz : real (0 : Float32) = 0 := by
      rw [real_unpack]; exact FloatLib.Floats.Formats.BinaryInterchange.Model.unpackedToReal_zero .positive
    exact ⟨True.intro, by simpa only [evaluate, hz, abs_zero] using nonnegative⟩
  | add ha hb cap finite capacity ia ib =>
    have h := Float32Bounds.add_range _ _ cap (finite_evaluate _ _ ia.1) (finite_evaluate _ _ ib.1)
      finite ((add_le_add ia.2 ib.2).trans capacity)
    exact ⟨⟨ia.1, ib.1, h.1⟩, h.2⟩
  | sub ha hb cap finite capacity ia ib =>
    have h := Float32Bounds.sub_range _ _ cap (finite_evaluate _ _ ia.1) (finite_evaluate _ _ ib.1)
      finite ((add_le_add ia.2 ib.2).trans capacity)
    exact ⟨⟨ia.1, ib.1, h.1⟩, h.2⟩
  | mul ha hb cap finite capacity ia ib =>
    have h := NativeMultiplication.range _ _ cap (finite_evaluate _ _ ia.1) (finite_evaluate _ _ ib.1)
      finite ((mul_le_mul ia.2 ib.2 (abs_nonneg _) ((abs_nonneg _).trans ia.2)).trans capacity)
    exact ⟨⟨ia.1, ib.1, h.1⟩, h.2⟩
  | fma ha hb hc cap finite capacity ia ib ic =>
    have h := NativeFma.range _ _ _ cap (finite_evaluate _ _ ia.1) (finite_evaluate _ _ ib.1)
      (finite_evaluate _ _ ic.1) finite
      ((add_le_add (mul_le_mul ia.2 ib.2 (abs_nonneg _) ((abs_nonneg _).trans ia.2)) ic.2).trans capacity)
    exact ⟨⟨ia.1, ib.1, ic.1, h.1⟩, h.2⟩

theorem accuracy (input inputCap : Nat → Float32) (target inputError : Nat → ℝ)
    (hi : ∀ i, (input i).isFinite = true ∧ |real (input i)| ≤ real (inputCap i))
    (he : ∀ i, |real (input i) - target i| ≤ inputError i)
    {expr : Expr} {cap : Float32} (certificate : Certificate inputCap expr cap) :
    (evaluate input expr).isFinite = true ∧ |real (evaluate input expr)| ≤ real cap ∧
      |real (evaluate input expr) - ideal target expr| ≤ budget input target inputError expr := by
  have h := sound input inputCap hi certificate
  exact ⟨finite_evaluate _ _ h.1, h.2, error input target inputError he expr h.1⟩

end Inference.Contracts.Mlx.ArithmeticBounds
