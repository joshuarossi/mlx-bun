import contracts.mlx.NormalizationExecution
import contracts.mlx.NormalizationReduction

namespace Inference.Contracts.Mlx.RmsNorm
open Numerics
open FloatLib FloatLib.Floats FloatLib.Floats.Formats.BinaryInterchange

-- Reviewed model of MLX v0.32.2's looped RMS kernel. The native API selects
-- the thread count; groups records that count divided by the SIMD width 32.
-- Compiler conformance, scalar primitive accuracy, and barrier semantics
-- are platform boundaries. Coverage and scratch contents are proved below.
structure Platform where
  divide : Float32 → Float32 → Float32
  divError : Float32 → Float32 → ℝ
  division : Division.Contract divide divError
  reduce : (Fin 32 → Float32) → Float32
  reduction : NormalizationReduction.SimdContract reduce
  rsqrt : Float32 → Float32
  rsqrtError : Float32 → ℝ
  rootAccuracy : Normalization.RsqrtContract rsqrt rsqrtError
  groups : Nat
  groupsPositive : 0 < groups
  groupsBounded : groups ≤ 32
  contracted : Bool

def expression (platform : Platform) (width : Nat) : SquaredSum.Expr width :=
  NormalizationReduction.expression platform.contracted platform.groups width
    platform.reduction.tree platform.reduction.tree

theorem coverage (platform : Platform) (width : Nat) :
    (SquaredSum.indices (expression platform width)).Perm (List.finRange width) :=
  NormalizationReduction.expression_coverage platform.contracted platform.groups width
    platform.groupsPositive platform.groupsBounded _ _ platform.reduction.coverage platform.reduction.coverage

def inverse (platform : Platform) (input : Fin n → Float32) (width eps : Float32)
    (before : M1Max.WordMemory) (base : Nat) : Float32 :=
  let acc := NormalizationReduction.sourceSum platform.reduce platform.contracted input before base platform.groups
  platform.rsqrt (FlushToZero.add (platform.divide acc width) eps)

theorem inverse_correct (platform : Platform) (input : Fin n → Float32) (width eps : Float32)
    (before : M1Max.WordMemory) (base : Nat) :
    inverse platform input width eps before base =
      NormalizationExecution.normalizer platform.divide input (expression platform n) width eps platform.rsqrt := by
  unfold inverse
  rw [NormalizationReduction.sourceSum_correct platform.reduce platform.reduction]
  rfl

def inverseMemory (before : M1Max.WordMemory) (base : Nat) (value : Float32) : M1Max.WordMemory :=
  Memory.execute [⟨base, value⟩] before

theorem inverse_read (before : M1Max.WordMemory) (base : Nat) (value : Float32) :
    inverseMemory before base value base = value := by
  simp [inverseMemory, Memory.execute, Memory.write]

def output (platform : Platform) (input : Fin n → Float32) (weight : Fin n → BFloat16Arithmetic.Value)
    (width eps : Float32) (scratchBefore inverseBefore : M1Max.WordMemory) (scratchBase inverseBase : Nat) (i : Fin n) : Float32 :=
  let sharedInverse := inverseMemory inverseBefore inverseBase (inverse platform input width eps scratchBefore scratchBase)
  BFloat16.widen (BFloat16Arithmetic.mul (weight i)
    (BFloat16.narrow (FlushToZero.mul (input i) (sharedInverse inverseBase))))

theorem output_correct (platform : Platform) (input : Fin n → Float32) (weight : Fin n → BFloat16Arithmetic.Value)
    (width eps : Float32) (scratchBefore inverseBefore : M1Max.WordMemory) (scratchBase inverseBase : Nat) (i : Fin n) :
    output platform input weight width eps scratchBefore inverseBefore scratchBase inverseBase i =
      NormalizationExecution.output platform.divide input weight (expression platform n) width eps platform.rsqrt i := by
  unfold output
  dsimp only
  rw [inverse_read, inverse_correct]
  rfl

-- Retain the output's actual bf16 storage at the next kernel boundary.
def value (platform : Platform) (input : Fin n → Float32) (weight : Fin n → BFloat16Arithmetic.Value)
    (width eps : Float32) (scratchBefore : M1Max.WordMemory) (scratchBase : Nat) (i : Fin n) : BFloat16Arithmetic.Value :=
  BFloat16Arithmetic.mul (weight i)
    (BFloat16.narrow (FlushToZero.mul (input i) (inverse platform input width eps scratchBefore scratchBase)))

theorem output_eq_widen (platform : Platform) (input : Fin n → Float32) (weight : Fin n → BFloat16Arithmetic.Value)
    (width eps : Float32) (scratchBefore inverseBefore : M1Max.WordMemory) (scratchBase inverseBase : Nat) (i : Fin n) :
    output platform input weight width eps scratchBefore inverseBefore scratchBase inverseBase i =
      BFloat16.widen (value platform input weight width eps scratchBefore scratchBase i) := by
  unfold output
  dsimp only
  rw [inverse_read]
  rfl

theorem value_finite (platform : Platform) (input : Fin n → Float32) (weight : Fin n → BFloat16Arithmetic.Value)
    (width eps : Float32) (hf : NormalizationExecution.Finite platform.divide input weight (expression platform n) width eps platform.rsqrt)
    (scratchBefore : M1Max.WordMemory) (scratchBase : Nat) (i : Fin n) :
    Model.isFinite (value platform input weight width eps scratchBefore scratchBase i) = true := by
  unfold value
  rw [inverse_correct]
  exact BFloat16Arithmetic.finite_flush _ (hf.hOutput i)

theorem output_error (platform : Platform) (input : Fin n → Float32) (weight : Fin n → BFloat16Arithmetic.Value)
    (width eps : Float32) (idealEps epsError : ℝ) (hp : 0 < idealEps) (he : |real eps - idealEps| ≤ epsError)
    (hf : NormalizationExecution.Finite platform.divide input weight (expression platform n) width eps platform.rsqrt)
    (scratchBefore inverseBefore : M1Max.WordMemory) (scratchBase inverseBase : Nat) (i : Fin n) :
    |real (output platform input weight width eps scratchBefore inverseBefore scratchBase inverseBase i) -
      Normalization.rmsNorm (fun j => real (input j)) (fun j => Model.toReal (weight j)) idealEps i| ≤
      NormalizationExecution.outputBudget platform.divide platform.divError input weight (expression platform n) width eps idealEps epsError
        platform.rsqrt platform.rsqrtError i := by
  rw [output_correct]
  exact NormalizationExecution.accuracy platform.divide platform.divError platform.division input weight _ (coverage platform n) width eps idealEps epsError hp he
    platform.rsqrt platform.rsqrtError platform.rootAccuracy hf i

theorem output_bound (platform : Platform) (input : Fin n → Float32) (weight : Fin n → BFloat16Arithmetic.Value)
    (width eps : Float32) (idealEps epsError : ℝ) (hp : 0 < idealEps) (he : |real eps - idealEps| ≤ epsError)
    (hf : NormalizationExecution.Finite platform.divide input weight (expression platform n) width eps platform.rsqrt)
    (scratchBefore inverseBefore : M1Max.WordMemory) (scratchBase inverseBase : Nat) (i : Fin n) :
    |real (output platform input weight width eps scratchBefore inverseBefore scratchBase inverseBase i)| ≤
      |Model.toReal (weight i)| * Real.sqrt n +
      NormalizationExecution.outputBudget platform.divide platform.divError input weight (expression platform n) width eps idealEps epsError
        platform.rsqrt platform.rsqrtError i := by
  exact Normalization.output_bound_of_error hf.hPositiveWidth _ _ _ hp i _ _
    (output_error platform input weight width eps idealEps epsError hp he hf
      scratchBefore inverseBefore scratchBase inverseBase i)

def outputIndices (platform : Platform) (width : Nat) : List Nat :=
  (NormalizationSchedule.columns (platform.groups * 32) width).map Fin.val

theorem outputIndices_nodup (platform : Platform) (width : Nat) : (outputIndices platform width).Nodup :=
  (NormalizationSchedule.columns_nodup (platform.groups * 32) width (by have := platform.groupsPositive; omega)).map Fin.val_injective

theorem outputIndices_mem (platform : Platform) (i : Fin n) : i.val ∈ outputIndices platform n := by
  apply List.mem_map.mpr
  refine ⟨i, ?_, rfl⟩
  exact (NormalizationSchedule.columns_complete (platform.groups * 32) n
    (by have := platform.groupsPositive; omega)).mem_iff.mpr (List.mem_finRange i)

def cellOutput (weight : Fin n → BFloat16Arithmetic.Value) (factor : Float32)
    (index : Nat) (value : BFloat16Arithmetic.Value) : BFloat16Arithmetic.Value :=
  if h : index < n then BFloat16Arithmetic.mul (weight ⟨index, h⟩)
    (BFloat16.narrow (FlushToZero.mul (BFloat16.widen value) factor)) else value

-- The first pass and reductions complete before the output pass. With a
-- donated input buffer, each owner then reads and replaces its own bf16
-- cell. The cell proof is typed as bf16, independently of scratch word size.
def inPlace (platform : Platform) (before : Nat → BFloat16Arithmetic.Value)
    (weight : Fin n → BFloat16Arithmetic.Value) (width eps : Float32)
    (scratchBefore : M1Max.WordMemory) (scratchBase : Nat) (schedule : List Nat) : Nat → BFloat16Arithmetic.Value :=
  let input := fun i : Fin n => BFloat16.widen (before i.val)
  let factor := inverse platform input width eps scratchBefore scratchBase
  Memory.mapCells (cellOutput weight factor) schedule before

theorem inPlace_correct (platform : Platform) (before : Nat → BFloat16Arithmetic.Value)
    (weight : Fin n → BFloat16Arithmetic.Value) (width eps : Float32)
    (scratchBefore inverseBefore : M1Max.WordMemory) (scratchBase inverseBase : Nat)
    (schedule : List Nat) (order : schedule.Perm (outputIndices platform n)) (i : Fin n) :
    BFloat16.widen (inPlace platform before weight width eps scratchBefore scratchBase schedule i.val) =
      output platform (fun j => BFloat16.widen (before j.val)) weight width eps
        scratchBefore inverseBefore scratchBase inverseBase i := by
  unfold inPlace
  rw [Memory.mapCells_read _ _ _ (order.nodup_iff.mpr (outputIndices_nodup platform n))]
  rw [ite_eq_left (order.mem_iff.mpr (outputIndices_mem platform i))]
  simp only [cellOutput, dite_eq_left i.isLt]
  unfold output
  dsimp only
  rw [inverse_read]

theorem inPlace_error (platform : Platform) (before : Nat → BFloat16Arithmetic.Value)
    (weight : Fin n → BFloat16Arithmetic.Value) (width eps : Float32)
    (idealEps epsError : ℝ) (hp : 0 < idealEps) (he : |real eps - idealEps| ≤ epsError)
    (hf : NormalizationExecution.Finite platform.divide (fun j => BFloat16.widen (before j.val)) weight
      (expression platform n) width eps platform.rsqrt)
    (scratchBefore inverseBefore : M1Max.WordMemory) (scratchBase inverseBase : Nat)
    (schedule : List Nat) (order : schedule.Perm (outputIndices platform n)) (i : Fin n) :
    |real (BFloat16.widen (inPlace platform before weight width eps scratchBefore scratchBase schedule i.val)) -
      Normalization.rmsNorm (fun j => real (BFloat16.widen (before j.val))) (fun j => Model.toReal (weight j)) idealEps i| ≤
      NormalizationExecution.outputBudget platform.divide platform.divError (fun j => BFloat16.widen (before j.val)) weight
        (expression platform n) width eps idealEps epsError platform.rsqrt platform.rsqrtError i := by
  rw [inPlace_correct platform before weight width eps scratchBefore inverseBefore scratchBase inverseBase schedule order i]
  exact output_error platform _ weight width eps idealEps epsError hp he hf
    scratchBefore inverseBefore scratchBase inverseBase i

end Inference.Contracts.Mlx.RmsNorm
