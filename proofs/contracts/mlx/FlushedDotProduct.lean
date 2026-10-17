import contracts.mlx.DotProduct
import contracts.mlx.FlushToZero

namespace Inference.Contracts.Mlx.FlushedDotProduct
open Numerics
open DotProduct (Expr ideal)

def evaluate (code scale input : Nat → Float32) : Expr → Float32
  | .zero => 0
  | .fma i acc => FlushToZero.fma (FlushToZero.mul (code i) (scale i)) (input i) (evaluate code scale input acc)
  | .add a b => FlushToZero.add (evaluate code scale input a) (evaluate code scale input b)

def Finite (code scale input : Nat → Float32) : Expr → Prop
  | .zero => True
  | .fma i acc => Finite code scale input acc ∧ (FlushToZero.flush (code i)*FlushToZero.flush (scale i)).isFinite=true ∧
      (input i).isFinite=true ∧ (Float32.fma (FlushToZero.flush (FlushToZero.mul (code i) (scale i)))
        (FlushToZero.flush (input i)) (FlushToZero.flush (evaluate code scale input acc))).isFinite=true
  | .add a b => Finite code scale input a ∧ Finite code scale input b ∧
      (FlushToZero.flush (evaluate code scale input a)+FlushToZero.flush (evaluate code scale input b)).isFinite=true

noncomputable def budget (code scale input : Nat → Float32) (codeError : Nat → ℝ) : Expr → ℝ
  | .zero => 0
  | .fma i acc => budget code scale input codeError acc +
      codeError i * |real (scale i)| * |real (input i)| +
      FlushToZero.mulBudget (code i) (scale i) * |real (input i)| +
      FlushToZero.fmaBudget (FlushToZero.mul (code i) (scale i)) (input i) (evaluate code scale input acc)
  | .add a b => budget code scale input codeError a + budget code scale input codeError b +
      FlushToZero.addBudget (evaluate code scale input a) (evaluate code scale input b)

theorem finite_evaluate (code scale input : Nat → Float32) (e : Expr) (h : Finite code scale input e) :
    (evaluate code scale input e).isFinite=true := by
  cases e with
  | zero => change (0 : Float32).isFinite=true; decide
  | fma => exact FlushToZero.finite_flush _ h.2.2.2
  | add => exact FlushToZero.finite_flush _ h.2.2

-- The exact target is shared with the IEEE proof; every arithmetic node now
-- includes input and output flushing in its execution and error budget.
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
    have en := FlushToZero.scaled_fma_error (code i) (scale i) (input i) (evaluate code scale input acc)
      hw hx (finite_evaluate code scale input acc ha) hout
    have ec := mul_le_mul_of_nonneg_right
      (mul_le_mul_of_nonneg_right (hc i) (abs_nonneg (real (scale i)))) (abs_nonneg (real (input i)))
    have ecode : |(real (code i)-target i)*real (scale i)*real (input i)| ≤
        codeError i * |real (scale i)| * |real (input i)| := by simpa only [abs_mul] using ec
    simp only [evaluate, ideal, budget]
    calc
      _ = |(real (FlushToZero.fma (FlushToZero.mul (code i) (scale i)) (input i) (evaluate code scale input acc)) -
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
    have en := FlushToZero.add_error (evaluate code scale input a) (evaluate code scale input b)
      (finite_evaluate code scale input a ha) (finite_evaluate code scale input b hb) hout
    change |real (FlushToZero.add (evaluate code scale input a) (evaluate code scale input b))-
      (real (evaluate code scale input a)+real (evaluate code scale input b))| ≤
        FlushToZero.addBudget (evaluate code scale input a) (evaluate code scale input b) at en
    simp only [evaluate, ideal, budget]
    calc
      _ = |(real (FlushToZero.add (evaluate code scale input a) (evaluate code scale input b)) -
            (real (evaluate code scale input a)+real (evaluate code scale input b))) +
          ((real (evaluate code scale input a)-ideal (fun j => target j*real (scale j)*real (input j)) a) +
            (real (evaluate code scale input b)-ideal (fun j => target j*real (scale j)*real (input j)) b))| := by
        congr 1
        ring
      _ ≤ _ := by
        have h := (abs_add_le _ _).trans (add_le_add en ((abs_add_le _ _).trans (add_le_add ea eb)))
        linarith

end Inference.Contracts.Mlx.FlushedDotProduct
