import contracts.mlx.FlushToZero
import FloatLib.Floats.Formats.IEEE754.Native.AddSub

namespace Inference.Contracts.Mlx.Arithmetic
open Numerics
open FloatLib FloatLib.Floats FloatLib.Floats.Formats.BinaryInterchange

-- Connect native subtraction to the independently proved real semantics.
theorem sub_bridge (x y : Float32) (hx : x.isFinite = true) (hy : y.isFinite = true) :
    model (x-y) = Model.sub (model x) (model y) := by
  change Model.ofFloat32Model (Float32.Model.sub x.toModel y.toModel) = _
  rw [Float32.Model.sub, Model.ofFloat32Model_pack]
  exact (Model.sub_eq_ofModel_sub_of_isFinite (by decide) (model x) (model y)
    (by simpa only [model, Model.toModel_ofFloat32Model, Float32.isFinite, Float32.Model.isFinite] using hx)
    (by simpa only [model, Model.toModel_ofFloat32Model, Float32.isFinite, Float32.Model.isFinite] using hy)).symm

theorem raw_sub_error (x y : Float32) (hx : x.isFinite = true) (hy : y.isFinite = true)
    (ho : (x-y).isFinite = true) : |real (x-y) - (real x-real y)| ≤ epsilon (real x-real y) := by
  have hb := sub_bridge x y hx hy
  have hf : Model.isFinite (Model.sub (model x) (model y)) = true := by
    rw [← hb, finite_model]
    exact ho
  have he := Model.abs_toReal_sub_sub_le (model x) (model y) (by decide)
    (by rw [finite_model]; exact hx) (by rw [finite_model]; exact hy) hf
  rw [← hb] at he
  exact he

def sub (x y : Float32) : Float32 := FlushToZero.flush (FlushToZero.flush x - FlushToZero.flush y)

noncomputable def subBudget (x y : Float32) : ℝ :=
  3 * FlushToZero.threshold + epsilon (real (FlushToZero.flush x) - real (FlushToZero.flush y))

theorem sub_error (x y : Float32) (hx : x.isFinite = true) (hy : y.isFinite = true)
    (ho : (FlushToZero.flush x - FlushToZero.flush y).isFinite = true) :
    |real (sub x y) - (real x - real y)| ≤ subBudget x y := by
  have eo := FlushToZero.flush_error (FlushToZero.flush x - FlushToZero.flush y)
  have er := raw_sub_error (FlushToZero.flush x) (FlushToZero.flush y)
    (FlushToZero.finite_flush x hx) (FlushToZero.finite_flush y hy) ho
  have ex := FlushToZero.flush_error x
  have ey := FlushToZero.flush_error y
  unfold sub subBudget
  calc
    _ = |(real (FlushToZero.flush (FlushToZero.flush x - FlushToZero.flush y)) - real (FlushToZero.flush x - FlushToZero.flush y)) +
      ((real (FlushToZero.flush x - FlushToZero.flush y) - (real (FlushToZero.flush x) - real (FlushToZero.flush y))) +
        ((real (FlushToZero.flush x) - real x) - (real (FlushToZero.flush y) - real y)))| := by congr 1; ring
    _ ≤ _ := by
      have h := (abs_add_le _ _).trans (add_le_add eo ((abs_add_le _ _).trans (add_le_add er
        ((abs_sub _ _).trans (add_le_add ex ey)))))
      linarith

-- Retain every rounding site. Source models select fused or separate
-- operations statically; this syntax never reassociates their execution.
inductive Expr where
  | input : Nat → Expr
  | zero : Expr
  | add : Expr → Expr → Expr
  | sub : Expr → Expr → Expr
  | mul : Expr → Expr → Expr
  | fma : Expr → Expr → Expr → Expr

def evaluate (input : Nat → Float32) : Expr → Float32
  | .input i => input i
  | .zero => 0
  | .add a b => FlushToZero.add (evaluate input a) (evaluate input b)
  | .sub a b => sub (evaluate input a) (evaluate input b)
  | .mul a b => FlushToZero.mul (evaluate input a) (evaluate input b)
  | .fma a b c => FlushToZero.fma (evaluate input a) (evaluate input b) (evaluate input c)

noncomputable def ideal (input : Nat → ℝ) : Expr → ℝ
  | .input i => input i
  | .zero => 0
  | .add a b => ideal input a + ideal input b
  | .sub a b => ideal input a - ideal input b
  | .mul a b => ideal input a * ideal input b
  | .fma a b c => ideal input a * ideal input b + ideal input c

def Finite (input : Nat → Float32) : Expr → Prop
  | .input i => (input i).isFinite = true
  | .zero => True
  | .add a b => Finite input a ∧ Finite input b ∧
      (FlushToZero.flush (evaluate input a) + FlushToZero.flush (evaluate input b)).isFinite = true
  | .sub a b => Finite input a ∧ Finite input b ∧
      (FlushToZero.flush (evaluate input a) - FlushToZero.flush (evaluate input b)).isFinite = true
  | .mul a b => Finite input a ∧ Finite input b ∧
      (FlushToZero.flush (evaluate input a) * FlushToZero.flush (evaluate input b)).isFinite = true
  | .fma a b c => Finite input a ∧ Finite input b ∧ Finite input c ∧
      (Float32.fma (FlushToZero.flush (evaluate input a)) (FlushToZero.flush (evaluate input b))
        (FlushToZero.flush (evaluate input c))).isFinite = true

noncomputable def budget (input : Nat → Float32) (target inputError : Nat → ℝ) : Expr → ℝ
  | .input i => inputError i
  | .zero => 0
  | .add a b => FlushToZero.addBudget (evaluate input a) (evaluate input b) + budget input target inputError a + budget input target inputError b
  | .sub a b => subBudget (evaluate input a) (evaluate input b) + budget input target inputError a + budget input target inputError b
  | .mul a b => FlushToZero.mulBudget (evaluate input a) (evaluate input b) +
      budget input target inputError a * |real (evaluate input b)| + |ideal target a| * budget input target inputError b
  | .fma a b c => FlushToZero.fmaBudget (evaluate input a) (evaluate input b) (evaluate input c) +
      budget input target inputError a * |real (evaluate input b)| + |ideal target a| * budget input target inputError b + budget input target inputError c

theorem finite_evaluate (input : Nat → Float32) (expr : Expr) (h : Finite input expr) :
    (evaluate input expr).isFinite = true := by
  cases expr with
  | input i => exact h
  | zero => change (0 : Float32).isFinite = true; decide +kernel
  | add a b => exact FlushToZero.finite_flush _ h.2.2
  | sub a b => exact FlushToZero.finite_flush _ h.2.2
  | mul a b => exact FlushToZero.finite_flush _ h.2.2
  | fma a b c => exact FlushToZero.finite_flush _ h.2.2.2

private theorem product_error (x y X Y ex ey : ℝ) (hx : |x-X| ≤ ex) (hy : |y-Y| ≤ ey) :
    |x*y-X*Y| ≤ ex*|y| + |X| *ey := by
  have ha := mul_le_mul_of_nonneg_right hx (abs_nonneg y)
  have hb := mul_le_mul_of_nonneg_left hy (abs_nonneg X)
  rw [← abs_mul] at ha hb
  calc
    _ = |(x-X)*y+X*(y-Y)| := by congr 1; ring
    _ ≤ _ := (abs_add_le _ _).trans (add_le_add ha hb)

theorem error (input : Nat → Float32) (target inputError : Nat → ℝ)
    (hi : ∀ i, |real (input i) - target i| ≤ inputError i) (expr : Expr) (hf : Finite input expr) :
    |real (evaluate input expr) - ideal target expr| ≤ budget input target inputError expr := by
  induction expr with
  | input i => exact hi i
  | zero =>
    have hz : real (0 : Float32) = 0 := by rw [real_unpack]; exact Model.unpackedToReal_zero .positive
    simp [evaluate, ideal, budget, hz]
  | add a b ia ib =>
    obtain ⟨ha, hb, ho⟩ := hf
    have ea := ia ha
    have eb := ib hb
    have er := FlushToZero.add_error (evaluate input a) (evaluate input b)
      (finite_evaluate input a ha) (finite_evaluate input b hb) ho
    simp only [evaluate, ideal, budget, FlushToZero.addBudget]
    calc
      _ = |(real (FlushToZero.add (evaluate input a) (evaluate input b)) -
          (real (evaluate input a) + real (evaluate input b))) +
        ((real (evaluate input a) - ideal target a) + (real (evaluate input b) - ideal target b))| := by congr 1; ring
      _ ≤ _ := by
        have h := (abs_add_le _ _).trans (add_le_add er ((abs_add_le _ _).trans (add_le_add ea eb)))
        linarith
  | sub a b ia ib =>
    obtain ⟨ha, hb, ho⟩ := hf
    have ea := ia ha
    have eb := ib hb
    have er := sub_error (evaluate input a) (evaluate input b) (finite_evaluate input a ha) (finite_evaluate input b hb) ho
    simp only [evaluate, ideal, budget]
    calc
      _ = |(real (sub (evaluate input a) (evaluate input b)) -
          (real (evaluate input a) - real (evaluate input b))) +
        ((real (evaluate input a) - ideal target a) - (real (evaluate input b) - ideal target b))| := by congr 1; ring
      _ ≤ _ := by
        have h := (abs_add_le _ _).trans (add_le_add er ((abs_sub _ _).trans (add_le_add ea eb)))
        linarith
  | mul a b ia ib =>
    obtain ⟨ha, hb, ho⟩ := hf
    have ep := product_error _ _ _ _ _ _ (ia ha) (ib hb)
    have er := FlushToZero.mul_error (evaluate input a) (evaluate input b) ho
    simp only [evaluate, ideal, budget, FlushToZero.mulBudget]
    calc
      _ = |(real (FlushToZero.mul (evaluate input a) (evaluate input b)) - real (evaluate input a)*real (evaluate input b)) +
        (real (evaluate input a)*real (evaluate input b) - ideal target a*ideal target b)| := by congr 1; ring
      _ ≤ _ := by have h := (abs_add_le _ _).trans (add_le_add er ep); linarith
  | fma a b c ia ib ic =>
    obtain ⟨ha, hb, hc, ho⟩ := hf
    have ep := product_error _ _ _ _ _ _ (ia ha) (ib hb)
    have ec := ic hc
    have er := FlushToZero.fma_error (evaluate input a) (evaluate input b) (evaluate input c)
      (finite_evaluate input a ha) (finite_evaluate input b hb) (finite_evaluate input c hc) ho
    simp only [evaluate, ideal, budget, FlushToZero.fmaBudget]
    calc
      _ = |(real (FlushToZero.fma (evaluate input a) (evaluate input b) (evaluate input c)) -
          (real (evaluate input a)*real (evaluate input b) + real (evaluate input c))) +
        ((real (evaluate input a)*real (evaluate input b) - ideal target a*ideal target b) +
          (real (evaluate input c) - ideal target c))| := by congr 1; ring
      _ ≤ _ := by
        have h := (abs_add_le _ _).trans (add_le_add er ((abs_add_le _ _).trans (add_le_add ep ec)))
        linarith

end Inference.Contracts.Mlx.Arithmetic
