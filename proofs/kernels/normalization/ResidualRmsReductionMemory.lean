import kernels.normalization.ResidualRmsFirstPassMemory

namespace Inference.Kernels.Normalization.ResidualRmsReductionMemory
open Contracts.Mlx
open FloatLib FloatLib.Floats FloatLib.Floats.Formats.BinaryInterchange
open ResidualRmsCellSemantics (count BF)
set_option maxRecDepth 10000
attribute [local irreducible] ResidualRmsFirstPassMemory.complete

-- This is the reduction phase after the parsed first pass. SIMD operations
-- remain explicit hardware primitives. Each store phase may be permuted;
-- phase ordering models the two threadgroup barriers. Hardware visibility and
-- translation of the source control flow remain separate obligations.
def groupValues (reduce : (Fin 32 → Float32) → Float32)
    (state : ResidualRmsFirstPassMemory.Machine) (group : Fin 32) : Float32 :=
  reduce (fun lane => state.accumulators (NormalizationReduction.laneIndex group lane))

def scratch (before : M1Max.WordMemory) (initial partials : List Memory.Store) : M1Max.WordMemory :=
  NormalizationReduction.shared before initial partials

def sum (reduce : (Fin 32 → Float32) → Float32)
    (before : M1Max.WordMemory) (base : Nat) (initial partials : List Memory.Store) : Float32 :=
  reduce (fun lane => scratch before initial partials (base+lane.val))

variable {x update : Fin count → BF} (input : BinaryMemory.Input x update)
  (allocation : ResidualRmsCellMemory.Allocation input.lhs.base input.rhs.base destination)
  {contracted : Bool} (reduce : (Fin 32 → Float32) → Float32)

include allocation in
theorem groupValues_eq (group : Fin 32) :
    groupValues reduce (ResidualRmsFirstPassMemory.complete input destination contracted) group=
      NormalizationReduction.groupSum reduce contracted (ResidualRmsNorm.residualInput x update) group := by
  unfold groupValues NormalizationReduction.groupSum
  congr 1
  funext lane
  exact ResidualRmsFirstPassMemory.complete_accumulators input allocation _

include allocation in
theorem scratch_read (before : M1Max.WordMemory) (base : Nat) (initial partials : List Memory.Store)
    (hi : initial.Perm (NormalizationReduction.initialStores base))
    (hp : partials.Perm (NormalizationReduction.partialStores base
      (groupValues reduce (ResidualRmsFirstPassMemory.complete input destination contracted)))) (lane : Fin 32) :
    scratch before initial partials (base+lane.val)=
      NormalizationReduction.groupSum reduce contracted (ResidualRmsNorm.residualInput x update) lane := by
  rw [scratch,NormalizationReduction.shared_read before base _ initial partials hi hp lane]
  rw [dite_eq_left lane.isLt]
  exact groupValues_eq input allocation reduce lane

include allocation in
theorem sum_eq (before : M1Max.WordMemory) (base : Nat) (initial partials : List Memory.Store)
    (hi : initial.Perm (NormalizationReduction.initialStores base))
    (hp : partials.Perm (NormalizationReduction.partialStores base
      (groupValues reduce (ResidualRmsFirstPassMemory.complete input destination contracted)))) :
    sum reduce before base initial partials=
      NormalizationReduction.sourceSum reduce contracted (ResidualRmsNorm.residualInput x update) before base 32 := by
  unfold sum NormalizationReduction.sourceSum
  congr 1
  funext lane
  rw [scratch_read input allocation reduce before base initial partials hi hp lane]
  rw [NormalizationReduction.shared_read before base _ _ _ (List.Perm.refl _) (List.Perm.refl _) lane,
    dite_eq_left lane.isLt]

-- Lane zero writes inv[0] after the second SIMD reduction. Reading it after
-- the device/threadgroup barrier gives the existing RMS inverse exactly,
-- including division, epsilon addition and the explicit rsqrt primitive.
def inverse (platform : RmsNorm.Platform) (width eps : Float32)
    (before : M1Max.WordMemory) (base : Nat) (initial partials : List Memory.Store) : Float32 :=
  platform.rsqrt (FlushToZero.add (platform.divide
    (sum platform.reduce before base initial partials) width) eps)

include allocation in
theorem inverse_read (platform : RmsNorm.Platform) (groups : platform.groups=32) (contract : platform.contracted=contracted)
    (width eps : Float32) (before inverseBefore : M1Max.WordMemory) (base inverseBase : Nat)
    (initial partials : List Memory.Store)
    (hi : initial.Perm (NormalizationReduction.initialStores base))
    (hp : partials.Perm (NormalizationReduction.partialStores base
      (groupValues platform.reduce (ResidualRmsFirstPassMemory.complete input destination contracted)))) :
    RmsNorm.inverseMemory inverseBefore inverseBase (inverse platform width eps before base initial partials) inverseBase=
      RmsNorm.inverse platform (ResidualRmsNorm.residualInput x update) width eps before base := by
  rw [RmsNorm.inverse_read]
  unfold inverse RmsNorm.inverse
  rw [sum_eq input allocation platform.reduce before base initial partials hi hp,groups,contract]

-- The output pass consumes the actual BF16 residual bytes, rather than a
-- supplied residual vector. This establishes its register value; output
-- stores and source parsing of the tail are still separate boundaries.
include allocation in
theorem output_value (platform : RmsNorm.Platform) (groups : platform.groups=32) (contract : platform.contracted=contracted)
    (weight : Fin count → BF) (width eps : Float32) (before inverseBefore : M1Max.WordMemory)
    (base inverseBase : Nat) (initial partials : List Memory.Store)
    (hi : initial.Perm (NormalizationReduction.initialStores base))
    (hp : partials.Perm (NormalizationReduction.partialStores base
      (groupValues platform.reduce (ResidualRmsFirstPassMemory.complete input destination contracted)))) (col : Fin count) :
    BFloat16Arithmetic.mul (weight col) (BFloat16.narrow (FlushToZero.mul
      (BFloat16.widen (Model.ofBits (HalfMemory.load
        (ResidualRmsFirstPassMemory.complete input destination contracted).memory (destination+2*col.val))))
      (RmsNorm.inverseMemory inverseBefore inverseBase (inverse platform width eps before base initial partials) inverseBase)))=
      ResidualRmsNorm.normalized platform x update weight width eps before base col := by
  rw [ResidualRmsFirstPassMemory.complete_read input allocation col,
    inverse_read input allocation platform groups contract width eps before inverseBefore base inverseBase initial partials hi hp]
  rfl

end Inference.Kernels.Normalization.ResidualRmsReductionMemory
