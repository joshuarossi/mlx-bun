import contracts.mlx.FlushToZero
import kernels.trellis.GateUpTail
import kernels.trellis.SwiGLUStability

namespace Inference.Kernels.Trellis.GateUpTailFlushToZero
open Contracts.Mlx Contracts.Mlx.Numerics
open FloatLib FloatLib.Floats FloatLib.Floats.Formats.BinaryInterchange
open GateUpTail (sigmoid swiglu ExpNegContract inverse_difference)

-- TAIL=0: arithmetic flushes; float-to-bfloat conversion does not. expNeg is
-- the primitive precise::exp(-float(gateT)), with its target-specific error.
def denominator (expNeg : Float32 → Float32) (gate : Float32) : Float32 :=
  FlushToZero.add 1 (expNeg gate)
def quotient (expNeg : Float32 → Float32) (gate : Float32) : Float32 :=
  FlushToZero.div 1 (denominator expNeg gate)
def roundedSigmoid (expNeg : Float32 → Float32) (gate : Float32) : Float32 :=
  BFloat16.cast (quotient expNeg gate)
def roundedMul (x y : Float32) : Float32 := BFloat16.cast (FlushToZero.mul x y)
def tail (expNeg : Float32 → Float32) (gate up : Float32) : Float32 :=
  roundedMul (roundedMul gate (roundedSigmoid expNeg gate)) up

theorem denominator_finite (expNeg : Float32 → Float32) (gate : Float32)
    (hd : ((1 : Float32)+FlushToZero.flush (expNeg gate)).isFinite=true) :
    (denominator expNeg gate).isFinite=true := by
  unfold denominator FlushToZero.add
  rw [FlushToZero.flush_one]
  exact FlushToZero.finite_flush _ hd

theorem quotient_finite (expNeg : Float32 → Float32) (gate : Float32)
    (hn : 1 ≤ real (denominator expNeg gate))
    (hq : ((1 : Float32)/denominator expNeg gate).isFinite=true) :
    (quotient expNeg gate).isFinite=true := by
  unfold quotient FlushToZero.div
  rw [FlushToZero.flush_one, FlushToZero.flush_eq_of_one_le _ hn]
  exact FlushToZero.finite_flush _ hq

noncomputable def sigmoidBudget (expNeg : Float32 → Float32) (expError : Float32 → ℝ)
    (gate : Float32) : ℝ :=
  BFloat16.epsilon (real (quotient expNeg gate)) + FlushToZero.threshold +
    epsilon (1/real (denominator expNeg gate)) +
    (FlushToZero.addBudget 1 (expNeg gate)+expError gate) /
      (real (denominator expNeg gate)*(1+Real.exp (-real gate)))

theorem sigmoid_error (expNeg : Float32 → Float32) (expError : Float32 → ℝ)
    (exponential : ExpNegContract expNeg expError) (gate : Float32)
    (hg : gate.isFinite=true) (he : (expNeg gate).isFinite=true)
    (hd : ((1 : Float32)+FlushToZero.flush (expNeg gate)).isFinite=true)
    (hq : ((1 : Float32)/denominator expNeg gate).isFinite=true)
    (hb : Model.isFinite (BFloat16.narrow (quotient expNeg gate))=true) :
    |real (roundedSigmoid expNeg gate)-sigmoid (real gate)| ≤ sigmoidBudget expNeg expError gate := by
  have hd' : (FlushToZero.flush (1 : Float32)+FlushToZero.flush (expNeg gate)).isFinite=true := by
    rwa [FlushToZero.flush_one]
  have ed := FlushToZero.add_error (1 : Float32) (expNeg gate) (by decide) he hd'
  rw [real_one] at ed
  change |real (denominator expNeg gate)-(1+real (expNeg gate))| ≤ FlushToZero.addBudget 1 (expNeg gate) at ed
  have ee := exponential.accuracy gate hg he
  have ep := FlushToZero.add_one_ge_one (expNeg gate) he (exponential.nonnegative gate hg he) hd
  change 1 ≤ real (denominator expNeg gate) at ep
  have et := Real.exp_pos (-real gate)
  have en : |real (denominator expNeg gate)-(1+Real.exp (-real gate))| ≤
      FlushToZero.addBudget 1 (expNeg gate)+expError gate := by
    calc
      _ = |(real (denominator expNeg gate)-(1+real (expNeg gate))) +
          (real (expNeg gate)-Real.exp (-real gate))| := by congr 1; ring
      _ ≤ _ := (abs_add_le _ _).trans (add_le_add ed ee)
  have ei : |1/real (denominator expNeg gate)-sigmoid (real gate)| ≤
      (FlushToZero.addBudget 1 (expNeg gate)+expError gate) /
        (real (denominator expNeg gate)*(1+Real.exp (-real gate))) := by
    rw [sigmoid, inverse_difference _ _ (by linarith) (by positivity)]
    exact div_le_div_of_nonneg_right en (by positivity)
  have eq := FlushToZero.reciprocal_error (denominator expNeg gate) (denominator_finite expNeg gate hd) ep hq
  change |real (quotient expNeg gate)-1/real (denominator expNeg gate)| ≤
    FlushToZero.threshold + epsilon (1/real (denominator expNeg gate)) at eq
  have eb := BFloat16.cast_error (quotient expNeg gate) (quotient_finite expNeg gate ep hq) hb
  unfold roundedSigmoid sigmoidBudget
  calc
    _ = |(real (BFloat16.cast (quotient expNeg gate))-real (quotient expNeg gate)) +
        ((real (quotient expNeg gate)-1/real (denominator expNeg gate)) +
          (1/real (denominator expNeg gate)-sigmoid (real gate)))| := by congr 1; ring
    _ ≤ _ := by
      have h := (abs_add_le _ _).trans (add_le_add eb ((abs_add_le _ _).trans (add_le_add eq ei)))
      linarith

noncomputable def mulBudget (x y : Float32) : ℝ :=
  BFloat16.epsilon (real (FlushToZero.mul x y)) + FlushToZero.mulBudget x y

theorem roundedMul_error (x y : Float32)
    (hm : (FlushToZero.flush x*FlushToZero.flush y).isFinite=true)
    (hb : Model.isFinite (BFloat16.narrow (FlushToZero.mul x y))=true) :
    |real (roundedMul x y)-real x*real y| ≤ mulBudget x y := by
  have em := FlushToZero.mul_error x y hm
  have eb := BFloat16.cast_error (FlushToZero.mul x y) (FlushToZero.finite_flush _ hm) hb
  unfold roundedMul mulBudget FlushToZero.mulBudget
  calc
    _ = |(real (BFloat16.cast (FlushToZero.mul x y))-real (FlushToZero.mul x y)) +
        (real (FlushToZero.mul x y)-real x*real y)| := by congr 1; ring
    _ ≤ _ := (abs_add_le _ _).trans (add_le_add eb em)

noncomputable def tailBudget (expNeg : Float32 → Float32) (expError : Float32 → ℝ)
    (gate up : Float32) : ℝ :=
  mulBudget (roundedMul gate (roundedSigmoid expNeg gate)) up +
    (mulBudget gate (roundedSigmoid expNeg gate) + |real gate| * sigmoidBudget expNeg expError gate) * |real up|

structure Finite (expNeg : Float32 → Float32) (gate up : Float32) : Prop where
  hGate : gate.isFinite=true
  hExponential : (expNeg gate).isFinite=true
  hDenominator : ((1 : Float32)+FlushToZero.flush (expNeg gate)).isFinite=true
  hQuotient : ((1 : Float32)/denominator expNeg gate).isFinite=true
  hSigmoid : Model.isFinite (BFloat16.narrow (quotient expNeg gate))=true
  hSilu : (FlushToZero.flush gate * FlushToZero.flush (roundedSigmoid expNeg gate)).isFinite=true
  hSiluBfloat : Model.isFinite (BFloat16.narrow (FlushToZero.mul gate (roundedSigmoid expNeg gate)))=true
  hOutput : (FlushToZero.flush (roundedMul gate (roundedSigmoid expNeg gate)) * FlushToZero.flush up).isFinite=true
  hOutputBfloat : Model.isFinite (BFloat16.narrow (FlushToZero.mul (roundedMul gate (roundedSigmoid expNeg gate)) up))=true

theorem tail_error (expNeg : Float32 → Float32) (expError : Float32 → ℝ)
    (exponential : ExpNegContract expNeg expError) (gate up : Float32)
    (hf : Finite expNeg gate up) :
    |real (tail expNeg gate up)-swiglu (real gate) (real up)| ≤ tailBudget expNeg expError gate up := by
  have es := sigmoid_error expNeg expError exponential gate hf.hGate hf.hExponential hf.hDenominator hf.hQuotient hf.hSigmoid
  have em := roundedMul_error gate (roundedSigmoid expNeg gate) hf.hSilu hf.hSiluBfloat
  have eo := roundedMul_error (roundedMul gate (roundedSigmoid expNeg gate)) up hf.hOutput hf.hOutputBfloat
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

theorem sigmoid_of_exp_inf (expNeg : Float32 → Float32) (gate : Float32)
    (he : expNeg gate=Float32.inf) : roundedSigmoid expNeg gate = 0 := by
  unfold roundedSigmoid quotient denominator
  rw [he]
  decide +kernel

structure ProductsFinite (expNeg : Float32 → Float32) (gate up : Float32) : Prop where
  hSilu : (FlushToZero.flush gate * FlushToZero.flush (roundedSigmoid expNeg gate)).isFinite=true
  hSiluBfloat : Model.isFinite (BFloat16.narrow (FlushToZero.mul gate (roundedSigmoid expNeg gate)))=true
  hOutput : (FlushToZero.flush (roundedMul gate (roundedSigmoid expNeg gate)) * FlushToZero.flush up).isFinite=true
  hOutputBfloat : Model.isFinite (BFloat16.narrow (FlushToZero.mul (roundedMul gate (roundedSigmoid expNeg gate)) up))=true

noncomputable def overflowBudget (expNeg : Float32 → Float32) (gate up : Float32) : ℝ :=
  mulBudget (roundedMul gate (roundedSigmoid expNeg gate)) up +
    (mulBudget gate (roundedSigmoid expNeg gate)+|real gate| *sigmoid (real gate))*|real up|

theorem tail_overflow_error (expNeg : Float32 → Float32) (gate up : Float32)
    (he : expNeg gate=Float32.inf) (hp : ProductsFinite expNeg gate up) :
    |real (tail expNeg gate up)-swiglu (real gate) (real up)| ≤ overflowBudget expNeg gate up := by
  have hs : |real (roundedSigmoid expNeg gate)-sigmoid (real gate)| ≤ sigmoid (real gate) := by
    rw [sigmoid_of_exp_inf expNeg gate he]
    have hz : real (0 : Float32)=0 := by
      rw [real_unpack]
      exact Model.unpackedToReal_zero .positive
    rw [hz, zero_sub, abs_neg, abs_of_pos (GateUpTail.sigmoid_pos _)]
  exact SwiGLUStability.arithmetic_composition _ _ _ _ _ _ _ _ hs
    (roundedMul_error gate (roundedSigmoid expNeg gate) hp.hSilu hp.hSiluBfloat)
    (roundedMul_error (roundedMul gate (roundedSigmoid expNeg gate)) up hp.hOutput hp.hOutputBfloat)

end Inference.Kernels.Trellis.GateUpTailFlushToZero
