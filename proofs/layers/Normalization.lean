import contracts.mlx.RmsNorm

namespace Inference.Layers.Normalization
open Contracts.Mlx Contracts.Mlx.Numerics
open FloatLib FloatLib.Floats FloatLib.Floats.Formats.BinaryInterchange

-- loadRmsNorm's plusOne option adds one in the stored weight's dtype.
-- Qwen's mathematical weight is 1+w; the bf16 preparation error is included.
def prepare (plusOne : Bool) (weight : BFloat16Arithmetic.Value) : BFloat16Arithmetic.Value :=
  if plusOne then BFloat16Arithmetic.add BFloat16Arithmetic.one weight else weight

noncomputable def targetWeight (plusOne : Bool) (weight : BFloat16Arithmetic.Value) : ℝ :=
  if plusOne then 1 + Model.toReal weight else Model.toReal weight

def PreparationFinite (plusOne : Bool) (weight : BFloat16Arithmetic.Value) : Prop :=
  plusOne = true → Model.isFinite
    (Model.add (BFloat16Arithmetic.flush BFloat16Arithmetic.one) (BFloat16Arithmetic.flush weight)) = true

noncomputable def preparationBudget (plusOne : Bool) (weight : BFloat16Arithmetic.Value) : ℝ :=
  if plusOne then BFloat16Arithmetic.addBudget BFloat16Arithmetic.one weight else 0

theorem prepare_finite (plusOne : Bool) (weight : BFloat16Arithmetic.Value)
    (hw : Model.isFinite weight = true) (hp : PreparationFinite plusOne weight) :
    Model.isFinite (prepare plusOne weight) = true := by
  cases plusOne
  · exact hw
  · exact BFloat16Arithmetic.finite_flush _ (hp rfl)

theorem preparation_error (plusOne : Bool) (weight : BFloat16Arithmetic.Value)
    (hw : Model.isFinite weight = true) (hp : PreparationFinite plusOne weight) :
    |Model.toReal (prepare plusOne weight) - targetWeight plusOne weight| ≤ preparationBudget plusOne weight := by
  cases plusOne
  · simp [prepare, targetWeight, preparationBudget]
  · simpa only [prepare, targetWeight, preparationBudget, ite_true, BFloat16Arithmetic.real_one] using
      BFloat16Arithmetic.add_error BFloat16Arithmetic.one weight BFloat16Arithmetic.finite_one hw (hp rfl)

def forward (platform : RmsNorm.Platform) (input : Fin n → Float32) (storedWeight : Fin n → BFloat16Arithmetic.Value)
    (plusOne : Bool) (width eps : Float32) (scratchBefore inverseBefore : M1Max.WordMemory)
    (scratchBase inverseBase : Nat) (i : Fin n) : Float32 :=
  RmsNorm.output platform input (fun j => prepare plusOne (storedWeight j)) width eps
    scratchBefore inverseBefore scratchBase inverseBase i

def value (platform : RmsNorm.Platform) (input : Fin n → Float32) (storedWeight : Fin n → BFloat16Arithmetic.Value)
    (plusOne : Bool) (width eps : Float32) (scratchBefore : M1Max.WordMemory) (scratchBase : Nat) (i : Fin n) : BFloat16Arithmetic.Value :=
  RmsNorm.value platform input (fun j => prepare plusOne (storedWeight j)) width eps scratchBefore scratchBase i

theorem value_finite (platform : RmsNorm.Platform) (input : Fin n → Float32) (storedWeight : Fin n → BFloat16Arithmetic.Value)
    (plusOne : Bool) (width eps : Float32)
    (hf : NormalizationExecution.Finite platform.divide input (fun j => prepare plusOne (storedWeight j))
      (RmsNorm.expression platform n) width eps platform.rsqrt)
    (scratchBefore : M1Max.WordMemory) (scratchBase : Nat) (i : Fin n) :
    Model.isFinite (value platform input storedWeight plusOne width eps scratchBefore scratchBase i) = true :=
  RmsNorm.value_finite platform input _ width eps hf scratchBefore scratchBase i

theorem forward_eq_widen (platform : RmsNorm.Platform) (input : Fin n → Float32) (storedWeight : Fin n → BFloat16Arithmetic.Value)
    (plusOne : Bool) (width eps : Float32) (scratchBefore inverseBefore : M1Max.WordMemory) (scratchBase inverseBase : Nat) (i : Fin n) :
    forward platform input storedWeight plusOne width eps scratchBefore inverseBefore scratchBase inverseBase i =
      BFloat16.widen (value platform input storedWeight plusOne width eps scratchBefore scratchBase i) :=
  RmsNorm.output_eq_widen platform input _ width eps scratchBefore inverseBefore scratchBase inverseBase i

noncomputable def errorBudget (platform : RmsNorm.Platform) (input : Fin n → Float32)
    (storedWeight : Fin n → BFloat16Arithmetic.Value) (plusOne : Bool) (width eps : Float32)
    (idealEps epsError : ℝ) (target inputError : Fin n → ℝ) (i : Fin n) : ℝ :=
  NormalizationExecution.outputBudget platform.divide platform.divError input (fun j => prepare plusOne (storedWeight j)) (RmsNorm.expression platform n)
    width eps idealEps epsError platform.rsqrt platform.rsqrtError i +
  |Model.toReal (prepare plusOne (storedWeight i))| *
    Contracts.Mlx.Normalization.inputBudget (fun j => real (input j)) target inputError idealEps i +
  preparationBudget plusOne (storedWeight i) * Real.sqrt n

-- Composition includes the previous layer's error, the shared denominator's
-- sensitivity, weight preparation, and every modeled arithmetic rounding.
theorem forward_error (platform : RmsNorm.Platform) (input : Fin n → Float32)
    (storedWeight : Fin n → BFloat16Arithmetic.Value) (plusOne : Bool) (width eps : Float32)
    (idealEps epsError : ℝ) (heps : 0 < idealEps) (he : |real eps - idealEps| ≤ epsError)
    (target inputError : Fin n → ℝ) (hx : ∀ i, |real (input i) - target i| ≤ inputError i)
    (hw : ∀ i, Model.isFinite (storedWeight i) = true) (hp : ∀ i, PreparationFinite plusOne (storedWeight i))
    (hf : NormalizationExecution.Finite platform.divide input (fun j => prepare plusOne (storedWeight j))
      (RmsNorm.expression platform n) width eps platform.rsqrt)
    (scratchBefore inverseBefore : M1Max.WordMemory) (scratchBase inverseBase : Nat) (i : Fin n) :
    |real (forward platform input storedWeight plusOne width eps scratchBefore inverseBefore scratchBase inverseBase i) -
      Contracts.Mlx.Normalization.rmsNorm target (fun j => targetWeight plusOne (storedWeight j)) idealEps i| ≤
      errorBudget platform input storedWeight plusOne width eps idealEps epsError target inputError i := by
  have localError := RmsNorm.output_error platform input (fun j => prepare plusOne (storedWeight j))
    width eps idealEps epsError heps he hf scratchBefore inverseBefore scratchBase inverseBase i
  have propagated := Contracts.Mlx.Normalization.perturbation hf.hPositiveWidth
    (fun j => real (input j)) target inputError (fun j => Model.toReal (prepare plusOne (storedWeight j)))
    (fun j => targetWeight plusOne (storedWeight j)) idealEps heps hx i
    (preparationBudget plusOne (storedWeight i)) (preparation_error plusOne (storedWeight i) (hw i) (hp i))
  unfold forward errorBudget
  calc
    _ = |(real (RmsNorm.output platform input (fun j => prepare plusOne (storedWeight j)) width eps
            scratchBefore inverseBefore scratchBase inverseBase i) -
          Contracts.Mlx.Normalization.rmsNorm (fun j => real (input j))
            (fun j => Model.toReal (prepare plusOne (storedWeight j))) idealEps i) +
        (Contracts.Mlx.Normalization.rmsNorm (fun j => real (input j))
            (fun j => Model.toReal (prepare plusOne (storedWeight j))) idealEps i -
          Contracts.Mlx.Normalization.rmsNorm target (fun j => targetWeight plusOne (storedWeight j)) idealEps i)| := by congr 1; ring
    _ ≤ _ := by
      have h := (abs_add_le _ _).trans (add_le_add localError propagated)
      linarith

theorem value_error (platform : RmsNorm.Platform) (input : Fin n → Float32)
    (storedWeight : Fin n → BFloat16Arithmetic.Value) (plusOne : Bool) (width eps : Float32)
    (idealEps epsError : ℝ) (heps : 0 < idealEps) (he : |real eps - idealEps| ≤ epsError)
    (target inputError : Fin n → ℝ) (hx : ∀ i, |real (input i) - target i| ≤ inputError i)
    (hw : ∀ i, Model.isFinite (storedWeight i) = true) (hp : ∀ i, PreparationFinite plusOne (storedWeight i))
    (hf : NormalizationExecution.Finite platform.divide input (fun j => prepare plusOne (storedWeight j))
      (RmsNorm.expression platform n) width eps platform.rsqrt)
    (scratchBefore : M1Max.WordMemory) (scratchBase : Nat) (i : Fin n) :
    |Model.toReal (value platform input storedWeight plusOne width eps scratchBefore scratchBase i) -
      Contracts.Mlx.Normalization.rmsNorm target (fun j => targetWeight plusOne (storedWeight j)) idealEps i| ≤
      errorBudget platform input storedWeight plusOne width eps idealEps epsError target inputError i := by
  have h := forward_error platform input storedWeight plusOne width eps idealEps epsError heps he
    target inputError hx hw hp hf scratchBefore (fun _ => 0) scratchBase 0 i
  rw [forward_eq_widen, BFloat16.widen_real _ (value_finite platform input storedWeight plusOne width eps hf scratchBefore scratchBase i)] at h
  exact h

end Inference.Layers.Normalization
