import contracts.mlx.BFloat16
import Mathlib.Analysis.SpecialFunctions.Exp

namespace Inference.Kernels.Trellis.GateUpTail
open Contracts.Mlx Contracts.Mlx.Numerics
open FloatLib FloatLib.Floats FloatLib.Floats.Formats.BinaryInterchange

noncomputable def sigmoid (x : ℝ) : ℝ := 1 / (1 + Real.exp (-x))
noncomputable def swiglu (gate up : ℝ) : ℝ := gate * sigmoid gate * up

theorem sigmoid_pos (x : ℝ) : 0 < sigmoid x := by
  unfold sigmoid
  positivity

theorem sigmoid_le_one (x : ℝ) : sigmoid x ≤ 1 := by
  unfold sigmoid
  have h := Real.exp_pos (-x)
  exact (div_le_one (by positivity)).mpr (by linarith)

-- The two source branches have the same exact-real function. Their rounded
-- executions differ, so the numerical proof below is specifically TAIL=0.
theorem stable_sigmoid (x : ℝ) :
    (if x<0 then 1/(1+Real.exp |x|) else 1-1/(1+Real.exp |x|)) = sigmoid x := by
  by_cases hx : x<0
  · simp [hx, abs_of_neg hx, sigmoid]
  · have he := Real.exp_pos x
    simp only [hx, ite_false, abs_of_nonneg (le_of_not_gt hx), sigmoid, Real.exp_neg]
    field_simp
    ring

-- A flushed sign test sends a tiny negative input to the upper branch,
-- whose exact value differs from the sigmoid by at most |x|.
theorem upper_branch (x : ℝ) (hx : x<0) (small : |x| ≤ 1) :
    |(1-1/(1+Real.exp |x|))-sigmoid x| ≤ |x| := by
  have hs := stable_sigmoid x
  simp only [hx, ite_true] at hs
  rw [← hs]
  have ht : 0 ≤ |x| := abs_nonneg x
  have hE := Real.one_le_exp ht
  have hb := Real.abs_exp_sub_one_le (x := |x|) (by rwa [abs_abs])
  rw [abs_abs, abs_of_nonneg (by linarith)] at hb
  have he : (1-1/(1+Real.exp |x|))-1/(1+Real.exp |x|) = (Real.exp |x|-1)/(Real.exp |x|+1) := by
    field_simp; ring
  rw [he, abs_of_nonneg (by apply div_nonneg <;> linarith), div_le_iff₀ (by linarith)]
  nlinarith

def denominator (expNeg : Float32 → Float32) (gate : Float32) : Float32 := 1 + expNeg gate

def quotient (expNeg : Float32 → Float32) (gate : Float32) : Float32 := 1 / denominator expNeg gate
def roundedSigmoid (expNeg : Float32 → Float32) (gate : Float32) : Float32 := BFloat16.cast (quotient expNeg gate)
def roundedMul (x y : Float32) : Float32 := BFloat16.cast (x*y)
def tail (expNeg : Float32 → Float32) (gate up : Float32) : Float32 :=
  roundedMul (roundedMul gate (roundedSigmoid expNeg gate)) up

-- expNeg models precise::exp(-float(gateT)), including the sign change.
-- Only this primitive's error and nonnegativity are assumed here; the rest
-- of the sigmoid and SwiGLU arithmetic is proved below.
structure ExpNegContract (expNeg : Float32 → Float32) (error : Float32 → ℝ) : Prop where
  nonnegative : ∀ x, x.isFinite=true → (expNeg x).isFinite=true → 0 ≤ real (expNeg x)
  accuracy : ∀ x, x.isFinite=true → (expNeg x).isFinite=true →
    |real (expNeg x)-Real.exp (-real x)| ≤ error x

theorem denominator_ge_one (expNeg : Float32 → Float32) (gate : Float32)
    (he : (expNeg gate).isFinite=true) (hn : 0 ≤ real (expNeg gate))
    (hd : (denominator expNeg gate).isFinite=true) :
    1 ≤ real (denominator expNeg gate) := by
  have h := Model.roundAt_mono FloatFormat.binary32 (show (1 : ℝ) ≤ 1+real (expNeg gate) by linarith)
  have hround := Model.roundAt_toReal_eq (model (1 : Float32)) (by rw [finite_model]; decide)
  rw [show Model.toReal (model (1 : Float32))=1 from real_one] at hround
  rw [hround] at h
  unfold denominator
  rw [add_real _ _ (by decide) he hd, real_one]
  exact h

theorem inverse_difference (d t : ℝ) (hd : 0<d) (ht : 0<t) :
    |1/d-1/t| = |d-t|/(d*t) := by
  have he : 1/d-1/t = -(d-t)/(d*t) := by field_simp; ring
  rw [he, abs_div, abs_neg, abs_of_pos (mul_pos hd ht)]

noncomputable def sigmoidBudget (expNeg : Float32 → Float32) (expError : Float32 → ℝ)
    (gate : Float32) : ℝ :=
  BFloat16.epsilon (real (quotient expNeg gate)) + epsilon (1/real (denominator expNeg gate)) +
    (epsilon (1+real (expNeg gate))+expError gate) /
      (real (denominator expNeg gate)*(1+Real.exp (-real gate)))

theorem sigmoid_error (expNeg : Float32 → Float32) (expError : Float32 → ℝ)
    (exponential : ExpNegContract expNeg expError) (gate : Float32)
    (hg : gate.isFinite=true) (he : (expNeg gate).isFinite=true)
    (hd : (denominator expNeg gate).isFinite=true) (hq : (quotient expNeg gate).isFinite=true)
    (hb : Model.isFinite (BFloat16.narrow (quotient expNeg gate))=true) :
    |real (roundedSigmoid expNeg gate)-sigmoid (real gate)| ≤ sigmoidBudget expNeg expError gate := by
  have ed := add_error (1 : Float32) (expNeg gate) (by decide) he hd
  rw [real_one] at ed
  have ee := exponential.accuracy gate hg he
  have ep := denominator_ge_one expNeg gate he (exponential.nonnegative gate hg he) hd
  have et := Real.exp_pos (-real gate)
  have en : |real (denominator expNeg gate)-(1+Real.exp (-real gate))| ≤
      epsilon (1+real (expNeg gate))+expError gate := by
    calc
      _ = |(real (denominator expNeg gate)-(1+real (expNeg gate))) +
          (real (expNeg gate)-Real.exp (-real gate))| := by congr 1; ring
      _ ≤ _ := (abs_add_le _ _).trans (add_le_add ed ee)
  have ei : |1/real (denominator expNeg gate)-sigmoid (real gate)| ≤
      (epsilon (1+real (expNeg gate))+expError gate) /
        (real (denominator expNeg gate)*(1+Real.exp (-real gate))) := by
    rw [sigmoid, inverse_difference _ _ (by linarith) (by positivity)]
    exact div_le_div_of_nonneg_right en (by positivity)
  have eq := div_error (1 : Float32) (denominator expNeg gate) hd hq
  rw [real_one] at eq
  change |real (quotient expNeg gate)-1/real (denominator expNeg gate)| ≤
    epsilon (1/real (denominator expNeg gate)) at eq
  have eb := BFloat16.cast_error (quotient expNeg gate) hq hb
  unfold roundedSigmoid sigmoidBudget
  calc
    _ = |(real (BFloat16.cast (quotient expNeg gate))-real (quotient expNeg gate)) +
        ((real (quotient expNeg gate)-1/real (denominator expNeg gate)) +
          (1/real (denominator expNeg gate)-sigmoid (real gate)))| := by congr 1; ring
    _ ≤ _ := by
      have h := (abs_add_le _ _).trans (add_le_add eb ((abs_add_le _ _).trans (add_le_add eq ei)))
      linarith

noncomputable def mulBudget (x y : Float32) : ℝ :=
  BFloat16.epsilon (real (x*y)) + epsilon (real x*real y)

theorem roundedMul_error (x y : Float32) (hm : (x*y).isFinite=true)
    (hb : Model.isFinite (BFloat16.narrow (x*y))=true) :
    |real (roundedMul x y)-real x*real y| ≤ mulBudget x y := by
  have em := mul_error x y hm
  have eb := BFloat16.cast_error (x*y) hm hb
  unfold roundedMul mulBudget
  calc
    _ = |(real (BFloat16.cast (x*y))-real (x*y)) + (real (x*y)-real x*real y)| := by congr 1; ring
    _ ≤ _ := (abs_add_le _ _).trans (add_le_add eb em)

noncomputable def tailBudget (expNeg : Float32 → Float32) (expError : Float32 → ℝ)
    (gate up : Float32) : ℝ :=
  mulBudget (roundedMul gate (roundedSigmoid expNeg gate)) up +
    (mulBudget gate (roundedSigmoid expNeg gate) + |real gate| * sigmoidBudget expNeg expError gate) * |real up|

theorem tail_error (expNeg : Float32 → Float32) (expError : Float32 → ℝ)
    (exponential : ExpNegContract expNeg expError) (gate up : Float32)
    (hg : gate.isFinite=true) (he : (expNeg gate).isFinite=true)
    (hd : (denominator expNeg gate).isFinite=true) (hq : (quotient expNeg gate).isFinite=true)
    (hb : Model.isFinite (BFloat16.narrow (quotient expNeg gate))=true)
    (hm : (gate * roundedSigmoid expNeg gate).isFinite=true)
    (hmb : Model.isFinite (BFloat16.narrow (gate * roundedSigmoid expNeg gate))=true)
    (ho : (roundedMul gate (roundedSigmoid expNeg gate) * up).isFinite=true)
    (hob : Model.isFinite (BFloat16.narrow (roundedMul gate (roundedSigmoid expNeg gate) * up))=true) :
    |real (tail expNeg gate up)-swiglu (real gate) (real up)| ≤ tailBudget expNeg expError gate up := by
  have es := sigmoid_error expNeg expError exponential gate hg he hd hq hb
  have em := roundedMul_error gate (roundedSigmoid expNeg gate) hm hmb
  have eo := roundedMul_error (roundedMul gate (roundedSigmoid expNeg gate)) up ho hob
  have es' := mul_le_mul_of_nonneg_left es (abs_nonneg (real gate))
  have ea : |real (roundedMul gate (roundedSigmoid expNeg gate))-real gate*sigmoid (real gate)| ≤
      mulBudget gate (roundedSigmoid expNeg gate)+|real gate| * sigmoidBudget expNeg expError gate := by
    calc
      _ = |(real (roundedMul gate (roundedSigmoid expNeg gate))-real gate*real (roundedSigmoid expNeg gate)) +
          real gate*(real (roundedSigmoid expNeg gate)-sigmoid (real gate))| := by congr 1; ring
      _ ≤ _ := by
        have e : |real gate*(real (roundedSigmoid expNeg gate)-sigmoid (real gate))| ≤
            |real gate| * sigmoidBudget expNeg expError gate := by simpa only [abs_mul] using es'
        exact (abs_add_le _ _).trans (add_le_add em e)
  unfold tail swiglu tailBudget
  calc
    _ = |(real (roundedMul (roundedMul gate (roundedSigmoid expNeg gate)) up) -
          real (roundedMul gate (roundedSigmoid expNeg gate))*real up) +
        (real (roundedMul gate (roundedSigmoid expNeg gate))-real gate*sigmoid (real gate))*real up| := by congr 1; ring
    _ ≤ _ := by
      have e : |(real (roundedMul gate (roundedSigmoid expNeg gate))-real gate*sigmoid (real gate))*real up| ≤
          (mulBudget gate (roundedSigmoid expNeg gate)+|real gate| * sigmoidBudget expNeg expError gate)* |real up| := by
        rw [abs_mul]
        exact mul_le_mul_of_nonneg_right ea (abs_nonneg (real up))
      exact (abs_add_le _ _).trans (add_le_add eo e)

end Inference.Kernels.Trellis.GateUpTail
