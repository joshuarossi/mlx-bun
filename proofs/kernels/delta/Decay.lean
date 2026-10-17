import kernels.delta.Softplus
import contracts.mlx.Negation

namespace Inference.Kernels.Delta.Decay
open FloatLib FloatLib.Floats FloatLib.Floats.Formats.BinaryInterchange
open Contracts.Mlx Contracts.Mlx.Numerics
abbrev BF := BFloat16Arithmetic.Value

-- MLX Exp uses the precise binary32 primitive. Its implementation and error
-- bound are explicit platform parameters, separate from the software proof.
structure ExpContract (exp : Float32 → Float32) (error : Float32 → ℝ) : Prop where
  nonnegative : ∀ x, x.isFinite = true → (exp x).isFinite = true → 0 ≤ real (exp x)
  accuracy : ∀ x, x.isFinite = true → (exp x).isFinite = true →
    |real (exp x) - Real.exp (real x)| ≤ error x

structure Platform where
  exp : Float32 → Float32
  expError : Float32 → ℝ
  exponential : ExpContract exp expError
  expBF : BF → BF
  expBFError : BF → ℝ
  exponentialBF : Softplus.ExpContract expBF expBFError
  log1pBF : BF → BF
  log1pBFError : BF → ℝ
  logarithmBF : Softplus.Log1pContract log1pBF log1pBFError

def biased (a dt : BF) : BF := BFloat16Arithmetic.add a dt
def soft (p : Platform) (a dt : BF) : BF := Softplus.value p.expBF p.log1pBF (biased a dt)
def argument (p : Platform) (aLog : Float32) (a dt : BF) : Float32 :=
  FlushToZero.mul (-p.exp aLog) (BFloat16.widen (soft p a dt))
def value (p : Platform) (aLog : Float32) (a dt : BF) : Float32 := p.exp (argument p aLog a dt)

-- Range obligations remain software obligations. They must eventually be
-- discharged from loaded weights and the graph's incoming range contracts.
structure Finite (p : Platform) (aLog : Float32) (a dt : BF) : Prop where
  aLogFinite : aLog.isFinite = true
  aFinite : Model.isFinite a = true
  dtFinite : Model.isFinite dt = true
  sumFinite : Model.isFinite (Model.add (BFloat16Arithmetic.flush a) (BFloat16Arithmetic.flush dt)) = true
  softFinite : Softplus.Finite p.expBF p.log1pBF (biased a dt)
  expFinite : (p.exp aLog).isFinite = true
  productFinite : (FlushToZero.flush (-p.exp aLog) * FlushToZero.flush (BFloat16.widen (soft p a dt))).isFinite = true
  outputFinite : (value p aLog a dt).isFinite = true

noncomputable def softBudget (p : Platform) (a dt : BF) : ℝ :=
  Softplus.budget p.expBF p.log1pBF p.expBFError p.log1pBFError (biased a dt) + BFloat16Arithmetic.addBudget a dt
noncomputable def argumentBudget (p : Platform) (aLog : Float32) (a dt : BF) : ℝ :=
  FlushToZero.mulBudget (-p.exp aLog) (BFloat16.widen (soft p a dt)) +
    p.expError aLog * Model.toReal (soft p a dt) + Real.exp (real aLog) * softBudget p a dt
noncomputable def budget (p : Platform) (aLog : Float32) (a dt : BF) : ℝ :=
  p.expError (argument p aLog a dt) + argumentBudget p aLog a dt

theorem soft_nonnegative (p : Platform) (aLog : Float32) (a dt : BF) (hf : Finite p aLog a dt) :
    0 ≤ Model.toReal (soft p a dt) :=
  Softplus.value_nonnegative p.expBF p.log1pBF p.expBFError p.log1pBFError
    p.exponentialBF p.logarithmBF (biased a dt) hf.softFinite

theorem soft_finite (p : Platform) (aLog : Float32) (a dt : BF) (hf : Finite p aLog a dt) :
    Model.isFinite (soft p a dt) = true := Softplus.value_finite p.expBF p.log1pBF (biased a dt) hf.softFinite

theorem soft_error (p : Platform) (aLog : Float32) (a dt : BF) (hf : Finite p aLog a dt) :
    |Model.toReal (soft p a dt) - Gates.softplus (Model.toReal a + Model.toReal dt)| ≤ softBudget p a dt := by
  have hl := Softplus.value_error p.expBF p.log1pBF p.expBFError p.log1pBFError
    p.exponentialBF p.logarithmBF (biased a dt) hf.softFinite
  have hi := (Gates.softplus_lipschitz (Model.toReal a + Model.toReal dt) (Model.toReal (biased a dt))).trans
    (BFloat16Arithmetic.add_error a dt hf.aFinite hf.dtFinite hf.sumFinite)
  calc
    _ = |(Model.toReal (soft p a dt) - Gates.softplus (Model.toReal (biased a dt))) +
      (Gates.softplus (Model.toReal (biased a dt)) - Gates.softplus (Model.toReal a + Model.toReal dt))| := by congr 1; ring
    _ ≤ _ := (abs_add_le _ _).trans (add_le_add hl hi)

theorem argument_finite (p : Platform) (aLog : Float32) (a dt : BF) (hf : Finite p aLog a dt) :
    (argument p aLog a dt).isFinite = true := FlushToZero.finite_flushExact _ _ hf.productFinite

theorem argument_nonpositive (p : Platform) (aLog : Float32) (a dt : BF) (hf : Finite p aLog a dt) :
    real (argument p aLog a dt) ≤ 0 := by
  apply FlushToZero.mul_nonpositive _ _ _ _ hf.productFinite
  · rw [Negation.real_neg _ hf.expFinite]
    exact neg_nonpos.mpr (p.exponential.nonnegative aLog hf.aLogFinite hf.expFinite)
  · rw [BFloat16.widen_real _ (soft_finite p aLog a dt hf)]
    exact soft_nonnegative p aLog a dt hf

theorem argument_error (p : Platform) (aLog : Float32) (a dt : BF) (hf : Finite p aLog a dt) :
    |real (argument p aLog a dt) - (-Real.exp (real aLog) * Gates.softplus (Model.toReal a + Model.toReal dt))| ≤
      argumentBudget p aLog a dt := by
  have hm := FlushToZero.mul_error (-p.exp aLog) (BFloat16.widen (soft p a dt)) hf.productFinite
  rw [Negation.real_neg _ hf.expFinite, BFloat16.widen_real _ (soft_finite p aLog a dt hf)] at hm
  have ha := mul_le_mul_of_nonneg_right (p.exponential.accuracy aLog hf.aLogFinite hf.expFinite) (soft_nonnegative p aLog a dt hf)
  have hs := mul_le_mul_of_nonneg_left (soft_error p aLog a dt hf) (Real.exp_pos (real aLog)).le
  have hi : |(-real (p.exp aLog) * Model.toReal (soft p a dt)) -
      (-Real.exp (real aLog) * Gates.softplus (Model.toReal a + Model.toReal dt))| ≤
      p.expError aLog * Model.toReal (soft p a dt) + Real.exp (real aLog) * softBudget p a dt := by
    calc
      _ = |-(real (p.exp aLog) - Real.exp (real aLog)) * Model.toReal (soft p a dt) -
        Real.exp (real aLog) * (Model.toReal (soft p a dt) - Gates.softplus (Model.toReal a + Model.toReal dt))| := by congr 1; ring
      _ ≤ _ := by
        have h := abs_sub (-(real (p.exp aLog) - Real.exp (real aLog)) * Model.toReal (soft p a dt))
          (Real.exp (real aLog) * (Model.toReal (soft p a dt) - Gates.softplus (Model.toReal a + Model.toReal dt)))
        simp only [abs_mul, abs_neg, abs_of_nonneg (soft_nonnegative p aLog a dt hf), abs_of_pos (Real.exp_pos (real aLog))] at h
        exact h.trans (add_le_add ha hs)
  unfold argumentBudget FlushToZero.mulBudget
  calc
    _ = |(real (argument p aLog a dt) - (-real (p.exp aLog) * Model.toReal (soft p a dt))) +
      ((-real (p.exp aLog) * Model.toReal (soft p a dt)) - (-Real.exp (real aLog) * Gates.softplus (Model.toReal a + Model.toReal dt)))| := by congr 1; ring
    _ ≤ _ := by
      have h := (abs_add_le _ _).trans (add_le_add hm hi)
      simpa only [argument, Negation.real_neg _ hf.expFinite,
        BFloat16.widen_real _ (soft_finite p aLog a dt hf), add_assoc] using h

theorem value_error (p : Platform) (aLog : Float32) (a dt : BF) (hf : Finite p aLog a dt) :
    |real (value p aLog a dt) - Gates.decay (real aLog) (Model.toReal a + Model.toReal dt)| ≤ budget p aLog a dt := by
  have he := p.exponential.accuracy (argument p aLog a dt) (argument_finite p aLog a dt hf) hf.outputFinite
  have ha := (Gates.exp_nonpos_lipschitz (-Real.exp (real aLog) * Gates.softplus (Model.toReal a + Model.toReal dt))
    (real (argument p aLog a dt))
    (mul_nonpos_of_nonpos_of_nonneg (neg_nonpos.mpr (Real.exp_pos _).le) (Gates.softplus_positive _).le)
    (argument_nonpositive p aLog a dt hf)).trans (argument_error p aLog a dt hf)
  unfold Gates.decay
  calc
    _ = |(real (value p aLog a dt) - Real.exp (real (argument p aLog a dt))) +
      (Real.exp (real (argument p aLog a dt)) - Real.exp (-Real.exp (real aLog) * Gates.softplus (Model.toReal a + Model.toReal dt)))| := by congr 1; ring
    _ ≤ _ := (abs_add_le _ _).trans (add_le_add he ha)

theorem value_nonnegative (p : Platform) (aLog : Float32) (a dt : BF) (hf : Finite p aLog a dt) :
    0 ≤ real (value p aLog a dt) := p.exponential.nonnegative _ (argument_finite p aLog a dt hf) hf.outputFinite

theorem propagated_error (p : Platform) (aLog : Float32) (a dt : BF) (hf : Finite p aLog a dt)
    (targetALog targetInput scaleError inputError : ℝ)
    (ha : |Real.exp (real aLog) - Real.exp targetALog| ≤ scaleError)
    (hi : |(Model.toReal a + Model.toReal dt) - targetInput| ≤ inputError) :
    |real (value p aLog a dt) - Gates.decay targetALog targetInput| ≤
      budget p aLog a dt + scaleError * Gates.softplus (Model.toReal a + Model.toReal dt) + Real.exp targetALog * inputError := by
  have hl := value_error p aLog a dt hf
  have hp := Gates.decay_perturbation (real aLog) targetALog (Model.toReal a + Model.toReal dt) targetInput scaleError inputError ha hi
  calc
    _ = |(real (value p aLog a dt) - Gates.decay (real aLog) (Model.toReal a + Model.toReal dt)) +
      (Gates.decay (real aLog) (Model.toReal a + Model.toReal dt) - Gates.decay targetALog targetInput)| := by congr 1; ring
    _ ≤ _ := by have h := (abs_add_le _ _).trans (add_le_add hl hp); linarith

end Inference.Kernels.Delta.Decay
