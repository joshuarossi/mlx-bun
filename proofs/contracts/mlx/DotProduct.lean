import contracts.mlx.Reduction

namespace Inference.Contracts.Mlx.DotProduct
open Numerics

-- The syntax records the actual multiply/FMA/add order. Its real interpretation
-- is a linear combination, independently of the rounded evaluation.
inductive Expr where
  | zero
  | fma (index : Nat) (acc : Expr)
  | add (left right : Expr)

def evaluate (code scale input : Nat → Float32) : Expr → Float32
  | .zero => 0
  | .fma i acc => Float32.fma (code i * scale i) (input i) (evaluate code scale input acc)
  | .add a b => evaluate code scale input a + evaluate code scale input b

noncomputable def ideal (term : Nat → ℝ) : Expr → ℝ
  | .zero => 0
  | .fma i acc => term i + ideal term acc
  | .add a b => ideal term a + ideal term b

def Finite (code scale input : Nat → Float32) : Expr → Prop
  | .zero => True
  | .fma i acc => Finite code scale input acc ∧ (code i * scale i).isFinite=true ∧
      (input i).isFinite=true ∧ (evaluate code scale input (.fma i acc)).isFinite=true
  | .add a b => Finite code scale input a ∧ Finite code scale input b ∧
      (evaluate code scale input (.add a b)).isFinite=true

noncomputable def budget (code scale input : Nat → Float32) (codeError : Nat → ℝ) : Expr → ℝ
  | .zero => 0
  | .fma i acc => budget code scale input codeError acc +
      codeError i * |real (scale i)| * |real (input i)| +
      epsilon (real (code i)*real (scale i)) * |real (input i)| +
      epsilon (real (code i*scale i)*real (input i)+real (evaluate code scale input acc))
  | .add a b => budget code scale input codeError a + budget code scale input codeError b +
      epsilon (real (evaluate code scale input a)+real (evaluate code scale input b))

theorem finite_evaluate (code scale input : Nat → Float32) (e : Expr) (h : Finite code scale input e) :
    (evaluate code scale input e).isFinite=true := by
  cases e with
  | zero => change (0 : Float32).isFinite=true; decide
  | fma => exact h.2.2.2
  | add => exact h.2.2

theorem error (code scale input : Nat → Float32) (target codeError : Nat → ℝ)
    (hc : ∀ i, |real (code i)-target i| ≤ codeError i)
    (e : Expr) (hf : Finite code scale input e) :
    |real (evaluate code scale input e) -
      ideal (fun i => target i * real (scale i) * real (input i)) e| ≤
        budget code scale input codeError e := by
  induction e with
  | zero =>
    have hz : real (0 : Float32)=0 := by
      rw [real_unpack]
      exact FloatLib.Floats.Formats.BinaryInterchange.Model.unpackedToReal_zero .positive
    simp [evaluate, ideal, budget, hz]
  | fma i acc ih =>
    obtain ⟨ha, hw, hx, hout⟩ := hf
    have ea := ih ha
    have en := scaled_fma_error (code i) (scale i) (input i) (evaluate code scale input acc)
      hw hx (finite_evaluate code scale input acc ha) hout
    have ec := mul_le_mul_of_nonneg_right
      (mul_le_mul_of_nonneg_right (hc i) (abs_nonneg (real (scale i)))) (abs_nonneg (real (input i)))
    have ecode : |(real (code i)-target i)*real (scale i)*real (input i)| ≤
        codeError i * |real (scale i)| * |real (input i)| := by simpa only [abs_mul] using ec
    simp only [evaluate, ideal, budget]
    calc
      _ = |(real (Float32.fma (code i*scale i) (input i) (evaluate code scale input acc)) -
            (real (code i)*real (scale i)*real (input i)+real (evaluate code scale input acc))) +
          ((real (code i)-target i)*real (scale i)*real (input i) +
            (real (evaluate code scale input acc)-ideal (fun j => target j*real (scale j)*real (input j)) acc))| := by
        congr 1
        ring
      _ ≤ _ := by
        have h := (abs_add_le _ _).trans (add_le_add en
          ((abs_add_le _ _).trans (add_le_add ecode ea)))
        linarith
  | add a b ia ib =>
    obtain ⟨ha, hb, hout⟩ := hf
    have ea := ia ha
    have eb := ib hb
    have en := add_error (evaluate code scale input a) (evaluate code scale input b)
      (finite_evaluate code scale input a ha) (finite_evaluate code scale input b hb) hout
    simp only [evaluate, ideal, budget]
    calc
      _ = |(real (evaluate code scale input a+evaluate code scale input b) -
            (real (evaluate code scale input a)+real (evaluate code scale input b))) +
          ((real (evaluate code scale input a)-ideal (fun j => target j*real (scale j)*real (input j)) a) +
            (real (evaluate code scale input b)-ideal (fun j => target j*real (scale j)*real (input j)) b))| := by
        congr 1
        ring
      _ ≤ _ := by
        have h := (abs_add_le _ _).trans (add_le_add en ((abs_add_le _ _).trans (add_le_add ea eb)))
        linarith

end Inference.Contracts.Mlx.DotProduct
