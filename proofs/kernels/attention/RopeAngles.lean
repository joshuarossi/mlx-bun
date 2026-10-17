import kernels.attention.Rope
import kernels.delta.Gates
import kernels.trellis.CodebookAccuracy
import contracts.mlx.Division

namespace Inference.Kernels.Attention.RopeAngles
open Contracts.Mlx Contracts.Mlx.Numerics
open FloatLib FloatLib.Floats FloatLib.Floats.Formats.BinaryInterchange
set_option maxHeartbeats 2000000

-- Host log2(base), integer-position conversion, and the scale enter as
-- explicit software inputs. Their errors must be discharged at the caller;
-- they are not included in the GPU exponential primitive's contract.
structure Inputs where
  base : Float32
  position : Float32
  scale : Float32
structure Target where
  base : ℝ
  position : ℝ
  scale : ℝ
structure InputError (x : Inputs) (target error : Target) : Prop where
  base : |real x.base - target.base| ≤ error.base
  position : |real x.position - target.position| ≤ error.position
  scale : |real x.scale - target.scale| ≤ error.scale

noncomputable def exp2 (x : ℝ) : ℝ := Real.exp (Real.log 2 * x)
structure Exp2Contract (fn : Float32 → Float32) (error : Float32 → ℝ) : Prop where
  accuracy : ∀ x, x.isFinite = true → real x ≤ 0 → (fn x).isFinite = true →
    |real (fn x) - exp2 (real x)| ≤ error x
structure Platform where
  divide : Float32 → Float32 → Float32
  divError : Float32 → Float32 → ℝ
  division : Division.Contract divide divError
  exp2 : Float32 → Float32
  expError : Float32 → ℝ
  exponential : Exp2Contract exp2 expError

def indexFloat (i : Fin 32) : Float32 := Float32.ofInt i.val
def width : Float32 := 32

set_option maxRecDepth 10000 in
set_option maxHeartbeats 0 in
theorem index_checked : ∀ i : Fin 32,
    Trellis.Codebook.FloatingPoint.representable (indexFloat i) = true ∧
    Trellis.Codebook.FloatingPoint.scaled (indexFloat i) = (i.val : ℤ) * 2^32 ∧
    (indexFloat i).isFinite = true := by decide +kernel

theorem index_value (i : Fin 32) : real (indexFloat i) = i.val := by
  rw [Trellis.CodebookAccuracy.scaled_real _ (index_checked i).1, (index_checked i).2.1]
  push_cast
  ring

theorem width_value : real width = 32 := by
  rw [real_unpack]
  change Model.unpackedToReal (.finite .positive 8388608 (-18) (by decide)) = 32
  rw [Model.unpackedToReal_finite]
  norm_num [Model.modelSignBit, FloatLib.Floats.Formats.Flocq.bpow]
  change 8388608 * ((2 : ℝ)^18)⁻¹ = 32
  norm_num

theorem width_finite : width.isFinite = true := by decide +kernel
theorem width_domain : Division.DivisorDomain width := by
  unfold Division.DivisorDomain
  rw [width_value]
  norm_num

def ratio (p : Platform) (i : Fin 32) : Float32 := p.divide (indexFloat i) width
def argument (p : Platform) (x : Inputs) (i : Fin 32) : Float32 := FlushToZero.mul (-ratio p i) x.base
def frequency (p : Platform) (x : Inputs) (i : Fin 32) : Float32 := p.exp2 (argument p x i)
noncomputable def targetArgument (x : Target) (i : Fin 32) : ℝ := -((i.val : ℝ) / 32) * x.base
noncomputable def targetFrequency (x : Target) (i : Fin 32) : ℝ := exp2 (targetArgument x i)

structure FrequencyFinite (p : Platform) (x : Inputs) (i : Fin 32) : Prop where
  baseFinite : x.base.isFinite = true
  baseNonnegative : 0 ≤ real x.base
  ratioFinite : (ratio p i).isFinite = true
  productFinite : (FlushToZero.flush (-ratio p i) * FlushToZero.flush x.base).isFinite = true
  exponentialFinite : (frequency p x i).isFinite = true

theorem ratio_error (p : Platform) (i : Fin 32) (hf : (ratio p i).isFinite = true) :
    |real (ratio p i) - (i.val : ℝ) / 32| ≤ p.divError (indexFloat i) width := by
  have h := p.division.accuracy (indexFloat i) width (index_checked i).2.2 width_finite width_domain hf
  rwa [index_value, width_value] at h

theorem argument_nonpositive (p : Platform) (x : Inputs) (i : Fin 32) (hf : FrequencyFinite p x i) : real (argument p x i) ≤ 0 := by
  apply FlushToZero.mul_nonpositive _ _ _ hf.baseNonnegative hf.productFinite
  rw [Negation.real_neg _ hf.ratioFinite]
  apply neg_nonpos.mpr
  apply p.division.nonnegative (indexFloat i) width (index_checked i).2.2 width_finite _ width_domain hf.ratioFinite
  rw [index_value]
  positivity

noncomputable def argumentBudget (p : Platform) (x : Inputs) (error : Target) (i : Fin 32) : ℝ :=
  FlushToZero.mulBudget (-ratio p i) x.base + p.divError (indexFloat i) width * |real x.base| +
    |(i.val : ℝ) / 32| * error.base

theorem argument_error (p : Platform) (x : Inputs) (target error : Target) (i : Fin 32)
    (hf : FrequencyFinite p x i) (he : InputError x target error) :
    |real (argument p x i) - targetArgument target i| ≤ argumentBudget p x error i := by
  have hm := FlushToZero.mul_error (-ratio p i) x.base hf.productFinite
  rw [Negation.real_neg _ hf.ratioFinite] at hm
  have hd := mul_le_mul_of_nonneg_right (ratio_error p i hf.ratioFinite) (abs_nonneg (real x.base))
  have hb := mul_le_mul_of_nonneg_left he.base (abs_nonneg ((i.val : ℝ)/32))
  rw [← abs_mul] at hd hb
  have ha : |(-real (ratio p i) * real x.base) - targetArgument target i| ≤
      p.divError (indexFloat i) width * |real x.base| + |(i.val : ℝ)/32| * error.base := by
    calc
      _ = |-((real (ratio p i) - (i.val : ℝ)/32) * real x.base + ((i.val : ℝ)/32) * (real x.base - target.base))| := by
        unfold targetArgument; congr 1; ring
      _ ≤ _ := by rw [abs_neg]; exact (abs_add_le _ _).trans (add_le_add hd hb)
  unfold argumentBudget
  calc
    _ = |(real (argument p x i) - (-real (ratio p i) * real x.base)) +
      ((-real (ratio p i) * real x.base) - targetArgument target i)| := by congr 1; ring
    _ ≤ _ := by
      have h := (abs_add_le _ _).trans (add_le_add hm ha)
      simpa only [argument, FlushToZero.mulBudget, Negation.real_neg _ hf.ratioFinite, add_assoc] using h

theorem exp2_nonpos_lipschitz (x y : ℝ) (hx : x ≤ 0) (hy : y ≤ 0) :
    |exp2 x - exp2 y| ≤ Real.log 2 * |x-y| := by
  have hl : 0 ≤ Real.log 2 := Real.log_nonneg (by norm_num)
  have h := Delta.Gates.exp_nonpos_lipschitz (Real.log 2 * y) (Real.log 2 * x)
    (mul_nonpos_of_nonneg_of_nonpos hl hy) (mul_nonpos_of_nonneg_of_nonpos hl hx)
  simpa only [exp2, ← mul_sub, abs_mul, abs_of_nonneg hl] using h

noncomputable def frequencyBudget (p : Platform) (x : Inputs) (error : Target) (i : Fin 32) : ℝ :=
  p.expError (argument p x i) + Real.log 2 * argumentBudget p x error i

theorem frequency_error (p : Platform) (x : Inputs) (target error : Target) (i : Fin 32)
    (hf : FrequencyFinite p x i) (he : InputError x target error) (hb : 0 ≤ target.base) :
    |real (frequency p x i) - targetFrequency target i| ≤ frequencyBudget p x error i := by
  have ha := argument_nonpositive p x i hf
  have ht : targetArgument target i ≤ 0 := mul_nonpos_of_nonpos_of_nonneg (neg_nonpos.mpr (by positivity)) hb
  have hl := p.exponential.accuracy _ (FlushToZero.finite_flushExact _ _ hf.productFinite) ha hf.exponentialFinite
  have hp := (exp2_nonpos_lipschitz _ _ ha ht).trans
    (mul_le_mul_of_nonneg_left (argument_error p x target error i hf he) (Real.log_nonneg (by norm_num)))
  calc
    _ = |(real (frequency p x i) - exp2 (real (argument p x i))) +
      (exp2 (real (argument p x i)) - exp2 (targetArgument target i))| := by unfold targetFrequency; congr 1; ring
    _ ≤ _ := (abs_add_le _ _).trans (add_le_add hl hp)

def bind (p : Platform) (x : Inputs) (i : Fin 32) (j : Nat) : Float32 :=
  if j = 0 then x.scale else if j = 1 then x.position else frequency p x i
noncomputable def targetBind (x : Target) (i : Fin 32) (j : Nat) : ℝ :=
  if j = 0 then x.scale else if j = 1 then x.position else targetFrequency x i
noncomputable def inputBudget (p : Platform) (x : Inputs) (error : Target) (i : Fin 32) (j : Nat) : ℝ :=
  if j = 0 then error.scale else if j = 1 then error.position else frequencyBudget p x error i

def expression : Arithmetic.Expr := .mul (.mul (.input 0) (.input 1)) (.input 2)
def value (p : Platform) (x : Inputs) (i : Fin 32) : Float32 :=
  FlushToZero.mul (FlushToZero.mul x.scale x.position) (frequency p x i)
noncomputable def targetValue (x : Target) (i : Fin 32) : ℝ := x.scale * x.position * targetFrequency x i
noncomputable def budget (p : Platform) (x : Inputs) (target error : Target) (i : Fin 32) : ℝ :=
  Arithmetic.budget (bind p x i) (targetBind target i) (inputBudget p x error i) expression
structure Finite (p : Platform) (x : Inputs) (i : Fin 32) : Prop where
  frequency : FrequencyFinite p x i
  arithmetic : Arithmetic.Finite (bind p x i) expression

theorem value_error (p : Platform) (x : Inputs) (target error : Target) (i : Fin 32)
    (hf : Finite p x i) (he : InputError x target error) (hb : 0 ≤ target.base) :
    |real (value p x i) - targetValue target i| ≤ budget p x target error i := by
  apply Arithmetic.error (bind p x i) (targetBind target i) (inputBudget p x error i) _ expression hf.arithmetic
  intro j
  unfold bind targetBind inputBudget
  split
  · exact he.scale
  · split
    · exact he.position
    · exact frequency_error p x target error i hf.frequency he hb

theorem execution (p : Platform) (x : Inputs) (i : Fin 32) :
    Arithmetic.evaluate (bind p x i) expression = value p x i := rfl

theorem value_finite (p : Platform) (x : Inputs) (i : Fin 32) (hf : Finite p x i) : (value p x i).isFinite = true := by
  have h := Arithmetic.finite_evaluate (bind p x i) expression hf.arithmetic
  rwa [execution] at h

-- Connect the frequency convention to the mathematical RoPE power law.
theorem base_frequency (base position scale : ℝ) (i : Fin 32) :
    targetValue ⟨Real.log base / Real.log 2, position, scale⟩ i =
      scale * position * Real.exp (-((i.val : ℝ)/32) * Real.log base) := by
  have hlog : Real.log 2 ≠ 0 := ne_of_gt (Real.log_pos (by norm_num))
  unfold targetValue targetFrequency exp2 targetArgument
  congr 2
  dsimp
  field_simp

end Inference.Kernels.Attention.RopeAngles
