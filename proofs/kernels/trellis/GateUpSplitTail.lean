import contracts.mlx.BFloat16Arithmetic
import kernels.trellis.GateUpTail
import FloatLib.Floats.Formats.BinaryInterchange.Operations.Compare.Proof

namespace Inference.Kernels.Trellis.GateUpSplitTail
open FloatLib FloatLib.Floats FloatLib.Floats.Formats.BinaryInterchange
open Contracts.Mlx.BFloat16Arithmetic
open Contracts.Mlx.FlushToZero (threshold)
open GateUpTail (sigmoid swiglu inverse_difference)

-- TAIL=1 uses native bf16 at every expression, including exp, 1+exp,
-- division, 1-sigY, and both products. The locked type probe verifies these
-- overload choices in the installed compiler; universal conformance remains
-- a platform premise. expAbs includes the abs operation and native exp.
def zero : Value := Model.zero FloatFormat.bfloat16 false
-- With denormals disabled the sign test compares the flushed input.
def negative (x : Value) : Prop := Model.compare (flush x) zero = some .lt
instance (x : Value) : Decidable (negative x) := inferInstanceAs (Decidable (Model.compare (flush x) zero = some .lt))
def denominator (expAbs : Value → Value) (gate : Value) : Value := add one (expAbs gate)
def sigY (expAbs : Value → Value) (gate : Value) : Value := div one (denominator expAbs gate)
def sigmoidValue (expAbs : Value → Value) (gate : Value) : Value :=
  if negative gate then sigY expAbs gate else sub one (sigY expAbs gate)
def tail (expAbs : Value → Value) (gate up : Value) : Value :=
  mul (mul gate (sigmoidValue expAbs gate)) up

theorem negative_iff (x : Value) (hx : Model.isFinite x=true) : negative x ↔ Model.toReal (flush x) < 0 := by
  have h := Model.compare_eq_some_lt_iff_toReal_lt_of_isFinite (flush x) zero (finite_flush x hx) (by decide)
  simpa only [negative, zero, Model.toReal_zero] using h

theorem negative_real (x : Value) (hx : Model.isFinite x=true) (hn : negative x) : Model.toReal x < 0 := by
  have h := (negative_iff x hx).mp hn
  rcases flush_cases x with e | e
  · rwa [e] at h
  · rw [e.1] at h; exact absurd h (lt_irrefl 0)

-- A nonnegative flushed input is nonnegative or tiny.
theorem nonnegative_real (x : Value) (hx : Model.isFinite x=true) (hn : ¬negative x) :
    0 ≤ Model.toReal x ∨ (Model.toReal x < 0 ∧ |Model.toReal x| < threshold) := by
  by_cases h : Model.toReal x < 0
  · rcases flush_cases x with e | e
    · exact absurd ((negative_iff x hx).mpr (by rwa [e])) hn
    · exact Or.inr ⟨h, e.2.2⟩
  · exact Or.inl (le_of_not_gt h)

structure ExpAbsContract (expAbs : Value → Value) (error : Value → ℝ) : Prop where
  nonnegative : ∀ x, Model.isFinite x=true → Model.isFinite (expAbs x)=true → 0 ≤ Model.toReal (expAbs x)
  accuracy : ∀ x, Model.isFinite x=true → Model.isFinite (expAbs x)=true →
    |Model.toReal (expAbs x)-Real.exp (|Model.toReal x|)| ≤ error x

structure SigmoidFinite (expAbs : Value → Value) (gate : Value) : Prop where
  hGate : Model.isFinite gate=true
  hExp : Model.isFinite (expAbs gate)=true
  hDen : Model.isFinite (Model.add one (flush (expAbs gate)))=true
  hQuot : Model.isFinite (Model.div one (denominator expAbs gate))=true
  hSub : ¬negative gate → Model.isFinite (Model.sub (flush one) (flush (sigY expAbs gate)))=true

theorem denominator_ge_one (expAbs : Value → Value) (error : Value → ℝ)
    (exponential : ExpAbsContract expAbs error) (gate : Value) (hf : SigmoidFinite expAbs gate) :
    1 ≤ Model.toReal (denominator expAbs gate) :=
  add_one_ge_one (expAbs gate) hf.hExp (exponential.nonnegative gate hf.hGate hf.hExp) hf.hDen

theorem denominator_finite (expAbs : Value → Value) (gate : Value) (hf : SigmoidFinite expAbs gate) :
    Model.isFinite (denominator expAbs gate)=true := by
  unfold denominator add
  rw [flush_one]
  exact finite_flush _ hf.hDen

theorem sigY_finite (expAbs : Value → Value) (error : Value → ℝ)
    (exponential : ExpAbsContract expAbs error) (gate : Value) (hf : SigmoidFinite expAbs gate) :
    Model.isFinite (sigY expAbs gate)=true := by
  unfold sigY div
  rw [flush_one, flush_eq_of_one_le _ (denominator_ge_one expAbs error exponential gate hf)]
  exact finite_flushExact _ _ hf.hQuot

theorem sigmoid_finite (expAbs : Value → Value) (error : Value → ℝ)
    (exponential : ExpAbsContract expAbs error) (gate : Value) (hf : SigmoidFinite expAbs gate) :
    Model.isFinite (sigmoidValue expAbs gate)=true := by
  unfold sigmoidValue
  split
  · exact sigY_finite expAbs error exponential gate hf
  · rename_i h
    exact finite_flush _ (hf.hSub h)

noncomputable def reciprocalBudget (expAbs : Value → Value) (error : Value → ℝ) (gate : Value) : ℝ :=
  threshold + epsilon (1/Model.toReal (denominator expAbs gate)) +
    (addBudget one (expAbs gate)+error gate) /
      (Model.toReal (denominator expAbs gate)*(1+Real.exp (|Model.toReal gate|)))

theorem sigY_error (expAbs : Value → Value) (error : Value → ℝ)
    (exponential : ExpAbsContract expAbs error) (gate : Value) (hf : SigmoidFinite expAbs gate) :
    |Model.toReal (sigY expAbs gate)-1/(1+Real.exp (|Model.toReal gate|))| ≤ reciprocalBudget expAbs error gate := by
  have hd : Model.isFinite (Model.add (flush one) (flush (expAbs gate)))=true := by
    simpa only [flush_one] using hf.hDen
  have ed := add_error one (expAbs gate) finite_one hf.hExp hd
  rw [real_one] at ed
  have ee := exponential.accuracy gate hf.hGate hf.hExp
  have ep := denominator_ge_one expAbs error exponential gate hf
  have et := Real.exp_pos |Model.toReal gate|
  have en : |Model.toReal (denominator expAbs gate)-(1+Real.exp (|Model.toReal gate|))| ≤
      addBudget one (expAbs gate)+error gate := by
    calc
      _ = |(Model.toReal (denominator expAbs gate)-(1+Model.toReal (expAbs gate))) +
          (Model.toReal (expAbs gate)-Real.exp (|Model.toReal gate|))| := by congr 1; ring
      _ ≤ _ := (abs_add_le _ _).trans (add_le_add ed ee)
  have ei : |1/Model.toReal (denominator expAbs gate)-1/(1+Real.exp (|Model.toReal gate|))| ≤
      (addBudget one (expAbs gate)+error gate) /
        (Model.toReal (denominator expAbs gate)*(1+Real.exp (|Model.toReal gate|))) := by
    rw [inverse_difference _ _ (by linarith) (by positivity)]
    exact div_le_div_of_nonneg_right en (by positivity)
  have eq := reciprocal_error (denominator expAbs gate) (denominator_finite expAbs gate hf) ep hf.hQuot
  unfold sigY reciprocalBudget
  calc
    _ = |(Model.toReal (div one (denominator expAbs gate))-1/Model.toReal (denominator expAbs gate)) +
        (1/Model.toReal (denominator expAbs gate)-1/(1+Real.exp (|Model.toReal gate|)))| := by congr 1; ring
    _ ≤ _ := (abs_add_le _ _).trans (add_le_add eq ei)

noncomputable def sigmoidBudget (expAbs : Value → Value) (error : Value → ℝ) (gate : Value) : ℝ :=
  reciprocalBudget expAbs error gate + if negative gate then 0 else subBudget one (sigY expAbs gate) + threshold

theorem sigmoid_error (expAbs : Value → Value) (error : Value → ℝ)
    (exponential : ExpAbsContract expAbs error) (gate : Value) (hf : SigmoidFinite expAbs gate) :
    |Model.toReal (sigmoidValue expAbs gate)-sigmoid (Model.toReal gate)| ≤ sigmoidBudget expAbs error gate := by
  have eq := sigY_error expAbs error exponential gate hf
  have target := GateUpTail.stable_sigmoid (Model.toReal gate)
  by_cases hn : negative gate
  · have hr := negative_real gate hf.hGate hn
    simp only [hr, ite_true] at target
    simpa only [sigmoidValue, sigmoidBudget, hn, ite_true, add_zero, ← target] using eq
  · have es := sub_error one (sigY expAbs gate) finite_one (sigY_finite expAbs error exponential gate hf) (hf.hSub hn)
    rw [real_one] at es
    simp only [sigmoidValue, sigmoidBudget, hn, ite_false]
    have hb : |(1-1/(1+Real.exp |Model.toReal gate|))-sigmoid (Model.toReal gate)| ≤ threshold := by
      rcases nonnegative_real gate hf.hGate hn with h | h
      · simp only [not_lt.mpr h, ite_false] at target
        rw [← target, sub_self, abs_zero]
        exact Contracts.Mlx.FlushToZero.threshold_pos.le
      · exact (GateUpTail.upper_branch _ h.1 (h.2.le.trans Contracts.Mlx.FlushToZero.threshold_lt_one.le)).trans h.2.le
    calc
      _ = |((Model.toReal (sub one (sigY expAbs gate))-(1-Model.toReal (sigY expAbs gate))) -
          (Model.toReal (sigY expAbs gate)-1/(1+Real.exp (|Model.toReal gate|)))) +
          ((1-1/(1+Real.exp |Model.toReal gate|))-sigmoid (Model.toReal gate))| := by congr 1; ring
      _ ≤ _ := by
        have h := (abs_add_le _ _).trans (add_le_add ((abs_sub _ _).trans (add_le_add es eq)) hb)
        linarith

-- Infinity is an actual source path: exp(abs(gate)) can overflow even though
-- the sigmoid remains finite. Its reciprocal and subtraction are bit-exact.
theorem sigY_of_exp_inf (expAbs : Value → Value) (gate : Value)
    (he : expAbs gate = Model.posInf FloatFormat.bfloat16) : sigY expAbs gate = zero := by
  unfold sigY denominator
  rw [he]
  decide +kernel

theorem sigmoid_of_exp_inf (expAbs : Value → Value) (gate : Value)
    (he : expAbs gate = Model.posInf FloatFormat.bfloat16) :
    sigmoidValue expAbs gate = if negative gate then zero else one := by
  unfold sigmoidValue
  rw [sigY_of_exp_inf expAbs gate he]
  split
  · rfl
  · decide +kernel

theorem sigmoid_overflow_error (expAbs : Value → Value) (gate : Value)
    (hg : Model.isFinite gate=true) (he : expAbs gate = Model.posInf FloatFormat.bfloat16) :
    |Model.toReal (sigmoidValue expAbs gate)-sigmoid (Model.toReal gate)| ≤
      1/(1+Real.exp (|Model.toReal gate|))+threshold := by
  rw [sigmoid_of_exp_inf expAbs gate he]
  have target := GateUpTail.stable_sigmoid (Model.toReal gate)
  have hp : 0 < 1/(1+Real.exp (|Model.toReal gate|)) := by positivity
  have h0 := Contracts.Mlx.FlushToZero.threshold_pos
  by_cases hn : negative gate
  · have hr := negative_real gate hg hn
    simp only [hn, ite_true, zero, Model.toReal_zero, hr] at target ⊢
    rw [← target, zero_sub, abs_neg, abs_of_pos hp]
    linarith
  · simp only [hn, ite_false, real_one]
    rcases nonnegative_real gate hg hn with h | h
    · simp only [not_lt.mpr h, ite_false] at target
      rw [← target]
      have hs : (1 : ℝ)-(1-1/(1+Real.exp (|Model.toReal gate|))) = 1/(1+Real.exp (|Model.toReal gate|)) := by ring
      rw [hs, abs_of_pos hp]
      linarith
    · have hb := GateUpTail.upper_branch _ h.1 (h.2.le.trans Contracts.Mlx.FlushToZero.threshold_lt_one.le)
      calc
        _ = |((1-1/(1+Real.exp |Model.toReal gate|))-sigmoid (Model.toReal gate)) +
            1/(1+Real.exp |Model.toReal gate|)| := by congr 1; ring
        _ ≤ _ := by
          have := (abs_add_le _ _).trans (add_le_add hb (le_of_eq (abs_of_pos hp)))
          linarith [h.2]

-- This algebraic composition works for either the finite exponential theorem
-- or the explicit overflow theorem above. The error supplied here is therefore
-- derived from the primitive arithmetic, not assumed for the whole activation.
theorem tail_error_of_sigmoid_error (expAbs : Value → Value) (gate up : Value) (sigError : ℝ)
    (hg : Model.isFinite gate=true) (hu : Model.isFinite up=true)
    (hs : Model.isFinite (sigmoidValue expAbs gate)=true)
    (hm : Model.isFinite (Model.mul (flush gate) (flush (sigmoidValue expAbs gate)))=true)
    (ho : Model.isFinite (Model.mul (flush (mul gate (sigmoidValue expAbs gate))) (flush up))=true)
    (es : |Model.toReal (sigmoidValue expAbs gate)-sigmoid (Model.toReal gate)| ≤ sigError) :
    |Model.toReal (tail expAbs gate up)-swiglu (Model.toReal gate) (Model.toReal up)| ≤
      mulBudget (mul gate (sigmoidValue expAbs gate)) up +
        (mulBudget gate (sigmoidValue expAbs gate)+|Model.toReal gate| *sigError)*|Model.toReal up| := by
  have em := mul_error gate (sigmoidValue expAbs gate) hg hs hm
  have eo := mul_error (mul gate (sigmoidValue expAbs gate)) up (mul_finite _ _ hm) hu ho
  have ea : |Model.toReal (mul gate (sigmoidValue expAbs gate))-Model.toReal gate*sigmoid (Model.toReal gate)| ≤
      mulBudget gate (sigmoidValue expAbs gate)+|Model.toReal gate| *sigError := by
    calc
      _ = |(Model.toReal (mul gate (sigmoidValue expAbs gate))-Model.toReal gate*Model.toReal (sigmoidValue expAbs gate)) +
          Model.toReal gate*(Model.toReal (sigmoidValue expAbs gate)-sigmoid (Model.toReal gate))| := by congr 1; ring
      _ ≤ _ := by
        have h := mul_le_mul_of_nonneg_left es (abs_nonneg (Model.toReal gate))
        rw [← abs_mul] at h
        exact (abs_add_le _ _).trans (add_le_add em h)
  unfold tail swiglu
  calc
    _ = |(Model.toReal (mul (mul gate (sigmoidValue expAbs gate)) up)-Model.toReal (mul gate (sigmoidValue expAbs gate))*Model.toReal up) +
        (Model.toReal (mul gate (sigmoidValue expAbs gate))-Model.toReal gate*sigmoid (Model.toReal gate))*Model.toReal up| := by congr 1; ring
    _ ≤ _ := by
      have h := mul_le_mul_of_nonneg_right ea (abs_nonneg (Model.toReal up))
      rw [← abs_mul] at h
      exact (abs_add_le _ _).trans (add_le_add eo h)

structure ProductsFinite (expAbs : Value → Value) (gate up : Value) : Prop where
  hGate : Model.isFinite gate=true
  hUp : Model.isFinite up=true
  hSilu : Model.isFinite (Model.mul (flush gate) (flush (sigmoidValue expAbs gate)))=true
  hOutput : Model.isFinite (Model.mul (flush (mul gate (sigmoidValue expAbs gate))) (flush up))=true

noncomputable def tailBudget (expAbs : Value → Value) (gate up : Value) (sigError : ℝ) : ℝ :=
  mulBudget (mul gate (sigmoidValue expAbs gate)) up +
    (mulBudget gate (sigmoidValue expAbs gate)+|Model.toReal gate| *sigError)*|Model.toReal up|

theorem tail_finite_error (expAbs : Value → Value) (error : Value → ℝ)
    (exponential : ExpAbsContract expAbs error) (gate up : Value)
    (hf : SigmoidFinite expAbs gate) (hp : ProductsFinite expAbs gate up) :
    |Model.toReal (tail expAbs gate up)-swiglu (Model.toReal gate) (Model.toReal up)| ≤
      tailBudget expAbs gate up (sigmoidBudget expAbs error gate) := by
  exact tail_error_of_sigmoid_error expAbs gate up _ hp.hGate hp.hUp
    (sigmoid_finite expAbs error exponential gate hf) hp.hSilu hp.hOutput
    (sigmoid_error expAbs error exponential gate hf)

theorem tail_overflow_error (expAbs : Value → Value) (gate up : Value)
    (hp : ProductsFinite expAbs gate up) (he : expAbs gate=Model.posInf FloatFormat.bfloat16) :
    |Model.toReal (tail expAbs gate up)-swiglu (Model.toReal gate) (Model.toReal up)| ≤
      tailBudget expAbs gate up (1/(1+Real.exp (|Model.toReal gate|))+threshold) := by
  have hs : Model.isFinite (sigmoidValue expAbs gate)=true := by
    rw [sigmoid_of_exp_inf expAbs gate he]
    split
    · decide
    · exact finite_one
  exact tail_error_of_sigmoid_error expAbs gate up _ hp.hGate hp.hUp hs hp.hSilu hp.hOutput
    (sigmoid_overflow_error expAbs gate hp.hGate he)


theorem output_finite (expAbs : Value → Value) (gate up : Value) (hp : ProductsFinite expAbs gate up) :
    Model.isFinite (tail expAbs gate up)=true := mul_finite _ _ hp.hOutput


end Inference.Kernels.Trellis.GateUpSplitTail
