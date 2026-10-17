import contracts.mlx.RmsNorm

namespace Inference.Kernels.ResidualRmsNorm
open Contracts.Mlx Contracts.Mlx.Numerics
open FloatLib FloatLib.Floats FloatLib.Floats.Formats.BinaryInterchange
abbrev BF := BFloat16Arithmetic.Value

-- residual-rms-norm.ts explicitly widens both operands, adds in binary32,
-- then rounds to bf16. Keep both rounding sites in the source model.
def added (x update : BF) : Float32 := FlushToZero.add (BFloat16.widen x) (BFloat16.widen update)
def residual (x update : BF) : BF := BFloat16.narrow (added x update)

theorem widen_finite (x : BF) (hx : Model.isFinite x = true) : (BFloat16.widen x).isFinite = true := by
  exact BFloat16.widen_finite x hx

structure AddFinite (x update : BF) : Prop where
  input : Model.isFinite x = true
  updateFinite : Model.isFinite update = true
  sum : (FlushToZero.flush (BFloat16.widen x) + FlushToZero.flush (BFloat16.widen update)).isFinite = true
  cast : Model.isFinite (residual x update) = true

noncomputable def residualBudget (x update : BF) : ℝ :=
  BFloat16.epsilon (real (added x update)) + FlushToZero.addBudget (BFloat16.widen x) (BFloat16.widen update)

theorem residual_error (x update : BF) (hf : AddFinite x update) :
    |Model.toReal (residual x update) - (Model.toReal x + Model.toReal update)| ≤ residualBudget x update := by
  have ha := FlushToZero.add_error (BFloat16.widen x) (BFloat16.widen update)
    (widen_finite x hf.input) (widen_finite update hf.updateFinite) hf.sum
  rw [BFloat16.widen_real _ hf.input, BFloat16.widen_real _ hf.updateFinite] at ha
  have hc := BFloat16.narrow_error (added x update) (FlushToZero.finite_flush _ hf.sum) hf.cast
  unfold residualBudget FlushToZero.addBudget
  calc
    _ = |(Model.toReal (residual x update) - real (added x update)) +
      (real (added x update) - (Model.toReal x + Model.toReal update))| := by congr 1; ring
    _ ≤ _ := (abs_add_le _ _).trans (add_le_add hc ha)

theorem residual_input_error (x update : BF) (hf : AddFinite x update)
    (targetX targetUpdate errorX errorUpdate : ℝ)
    (hx : |Model.toReal x - targetX| ≤ errorX) (hu : |Model.toReal update - targetUpdate| ≤ errorUpdate) :
    |Model.toReal (residual x update) - (targetX + targetUpdate)| ≤ residualBudget x update + errorX + errorUpdate := by
  have hl := residual_error x update hf
  calc
    _ = |(Model.toReal (residual x update) - (Model.toReal x + Model.toReal update)) +
      ((Model.toReal x - targetX) + (Model.toReal update - targetUpdate))| := by congr 1; ring
    _ ≤ _ := by
      have h := (abs_add_le _ _).trans (add_le_add hl ((abs_add_le _ _).trans (add_le_add hx hu)))
      linarith

def residualInput (x update : Fin n → BF) : Fin n → Float32 :=
  fun i => BFloat16.widen (residual (x i) (update i))

-- The first pass computes this same value before both its store and square.
-- This equality retains the source's ordered accumulation within each thread.
def accumulate (contracted : Bool) (x update : Fin n → BF) (columns : List (Fin n)) (acc : Float32) : Float32 :=
  columns.foldl (fun acc i =>
    let value := residual (x i) (update i)
    let v := BFloat16.widen value
    if contracted then FlushToZero.fma v v acc else FlushToZero.add acc (FlushToZero.mul v v)) acc

theorem accumulate_execution (contracted : Bool) (x update : Fin n → BF) (columns : List (Fin n)) (acc : Float32) :
    accumulate contracted x update columns acc =
      columns.foldl (SquaredSum.arithmeticStep contracted (residualInput x update)) acc := rfl

-- Device barrier visibility is a platform premise. The stored value and its
-- preservation across any once-only owner schedule are proved here.
def stored (x update before : Nat → BF) (schedule : List Nat) : Nat → BF :=
  Memory.writeCells (fun i => residual (x i) (update i)) schedule before

theorem stored_read (x update before : Nat → BF) (schedule : List Nat) (i : Nat) (hi : i ∈ schedule) :
    stored x update before schedule i = residual (x i) (update i) := by
  rw [stored, Memory.writeCells_read, ite_eq_left hi]

def inPlace (x update : Nat → BF) (schedule : List Nat) : Nat → BF :=
  Memory.mapCells (fun i value => residual value (update i)) schedule x

theorem inPlace_read (x update : Nat → BF) (schedule : List Nat) (hn : schedule.Nodup) (i : Nat) :
    inPlace x update schedule i = if i ∈ schedule then residual (x i) (update i) else x i :=
  Memory.mapCells_read _ _ _ hn i

def normalized (p : RmsNorm.Platform) (x update weight : Fin n → BF) (width eps : Float32)
    (scratch : M1Max.WordMemory) (base : Nat) (i : Fin n) : BF :=
  RmsNorm.value p (residualInput x update) weight width eps scratch base i

def NormFinite (p : RmsNorm.Platform) (x update weight : Fin n → BF) (width eps : Float32) : Prop :=
  NormalizationExecution.Finite p.divide (residualInput x update) weight (RmsNorm.expression p n) width eps p.rsqrt

noncomputable def normalizedBudget (p : RmsNorm.Platform) (x update weight : Fin n → BF)
    (width eps : Float32) (idealEps epsError : ℝ) (targetX targetUpdate errorX errorUpdate : Fin n → ℝ) (i : Fin n) : ℝ :=
  NormalizationExecution.outputBudget p.divide p.divError (residualInput x update) weight (RmsNorm.expression p n)
    width eps idealEps epsError p.rsqrt p.rsqrtError i + |Model.toReal (weight i)| *
    Normalization.inputBudget (fun j => real (residualInput x update j)) (fun j => targetX j + targetUpdate j)
      (fun j => residualBudget (x j) (update j) + errorX j + errorUpdate j) idealEps i

theorem normalized_input_error (p : RmsNorm.Platform) (x update weight : Fin n → BF)
    (width eps : Float32) (idealEps epsError : ℝ) (hp : 0 < idealEps) (he : |real eps - idealEps| ≤ epsError)
    (ha : ∀ j, AddFinite (x j) (update j)) (hf : NormFinite p x update weight width eps)
    (targetX targetUpdate errorX errorUpdate : Fin n → ℝ)
    (hx : ∀ j, |Model.toReal (x j) - targetX j| ≤ errorX j)
    (hu : ∀ j, |Model.toReal (update j) - targetUpdate j| ≤ errorUpdate j)
    (scratch : M1Max.WordMemory) (base : Nat) (i : Fin n) :
    |Model.toReal (normalized p x update weight width eps scratch base i) -
      Normalization.rmsNorm (fun j => targetX j + targetUpdate j) (fun j => Model.toReal (weight j)) idealEps i| ≤
      normalizedBudget p x update weight width eps idealEps epsError targetX targetUpdate errorX errorUpdate i := by
  have hl := RmsNorm.output_error p (residualInput x update) weight width eps idealEps epsError hp he hf
    scratch scratch base base i
  rw [RmsNorm.output_eq_widen, BFloat16.widen_real _ (RmsNorm.value_finite p (residualInput x update) weight width eps hf scratch base i)] at hl
  have hi : ∀ j, |real (residualInput x update j) - (targetX j + targetUpdate j)| ≤
      residualBudget (x j) (update j) + errorX j + errorUpdate j := by
    intro j
    rw [residualInput, BFloat16.widen_real _ (ha j).cast]
    exact residual_input_error (x j) (update j) (ha j) _ _ _ _ (hx j) (hu j)
  have ht := Normalization.input_perturbation (fun j => real (residualInput x update j)) (fun j => targetX j + targetUpdate j)
    (fun j => residualBudget (x j) (update j) + errorX j + errorUpdate j) (fun j => Model.toReal (weight j)) idealEps hp hi i
  calc
    _ = |(Model.toReal (normalized p x update weight width eps scratch base i) -
      Normalization.rmsNorm (fun j => real (residualInput x update j)) (fun j => Model.toReal (weight j)) idealEps i) +
      (Normalization.rmsNorm (fun j => real (residualInput x update j)) (fun j => Model.toReal (weight j)) idealEps i -
      Normalization.rmsNorm (fun j => targetX j + targetUpdate j) (fun j => Model.toReal (weight j)) idealEps i)| := by congr 1; ring
    _ ≤ _ := (abs_add_le _ _).trans (add_le_add hl ht)

end Inference.Kernels.ResidualRmsNorm
