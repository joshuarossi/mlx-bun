import kernels.normalization.ResidualRmsCellMemory

namespace Inference.Kernels.Normalization.ResidualRmsCellSource
open Contracts.Mlx ResidualRmsCellSemantics ResidualRmsCellMemory
set_option maxRecDepth 10000
attribute [local irreducible] NormalizationSchedule.threadColumns List.finRange

variable {x update weight : Fin count → BF} {input : BinaryMemory.Input x update}

theorem allocation (residual : ResidualRmsMemory.Residual input weight)
    (leftFresh : MemoryRegions.Disjoint (2*residual.addition.base) 10240 input.lhs.base 10240)
    (rightFresh : MemoryRegions.Disjoint (2*residual.addition.base) 10240 input.rhs.base 10240) :
    Allocation input.lhs.base input.rhs.base (2*residual.addition.base) :=
  ⟨by omega,residual.addition.bounded,leftFresh,rightFresh⟩

-- This constructor starts from the actual residual/input/weight storages used
-- by the existing normalization execution. It creates every parsed cell run;
-- it accepts no completed thread result or rounded residual buffer.
structure Checked (residual : ResidualRmsMemory.Residual input weight) (contracted : Bool) (thread : Fin 1024) where
  after : State
  execution : Runs contracted input.lhs.base input.rhs.base (2*residual.addition.base)
    (NormalizationSchedule.threadColumns count thread) ⟨input.lhs.bytes,0⟩ after

def checked (residual : ResidualRmsMemory.Residual input weight) (contracted : Bool) (thread : Fin 1024) :
    Checked residual contracted thread where
  after:=run contracted input.lhs.base input.rhs.base (2*residual.addition.base)
    (NormalizationSchedule.threadColumns count thread) ⟨input.lhs.bytes,0⟩
  execution:=canonical _ _ _ _ _ _

variable {residual : ResidualRmsMemory.Residual input weight}

theorem Checked.accumulator_eq (result : Checked residual contracted thread)
    (fresh : Allocation input.lhs.base input.rhs.base (2*residual.addition.base)) :
    result.after.acc=NormalizationReduction.threadSum contracted residual.sourceValues thread := by
  rw [runs_eq result.execution,ResidualRmsMemory.Residual.sourceValues_eq]
  exact thread_accumulator input fresh thread

theorem Checked.memory_eq (result : Checked residual contracted thread)
    (fresh : Allocation input.lhs.base input.rhs.base (2*residual.addition.base)) :
    result.after.memory=HalfMemory.execute
      (writes (2*residual.addition.base) input.lhs.base input.rhs.base input.lhs.bytes
        (NormalizationSchedule.threadColumns count thread)) input.lhs.bytes := by
  rw [runs_eq result.execution]
  exact memory_fixed fresh _ _ (sourceReads_refl _ _ _)

theorem Checked.other_region (result : Checked residual contracted thread)
    (separate : MemoryRegions.Disjoint (2*residual.addition.base) 10240 base size) (offset : Nat) (bound : offset<size) :
    result.after.memory (base+offset)=input.lhs.bytes (base+offset) := by
  rw [runs_eq result.execution]
  exact frame _ _ separate offset bound

def Checked.weightsAfter (result : Checked residual contracted thread) : ArrayStorage.BFBuffer weight :=
  ArrayFrame.bf residual.weights result.after.memory (by
    intro offset bound
    exact (result.other_region residual.weightsSeparate offset bound).trans
      (congrFun residual.shared (residual.weights.base+offset)).symm)

def Checked.leftAfter (result : Checked residual contracted thread)
    (fresh : Allocation input.lhs.base input.rhs.base (2*residual.addition.base)) : ArrayStorage.BFBuffer x :=
  ArrayFrame.bf input.lhs result.after.memory (result.other_region fresh.leftFresh)

def Checked.rightAfter (result : Checked residual contracted thread)
    (fresh : Allocation input.lhs.base input.rhs.base (2*residual.addition.base)) : ArrayStorage.BFBuffer update :=
  ArrayFrame.bf input.rhs result.after.memory (by
    rw [input.shared]
    exact result.other_region fresh.rightFresh)

theorem Checked.storage (result : Checked residual contracted thread)
    (fresh : Allocation input.lhs.base input.rhs.base (2*residual.addition.base)) :
    result.weightsAfter.bytes=result.after.memory ∧ result.weightsAfter.base=residual.weights.base ∧
    (result.leftAfter fresh).bytes=result.after.memory ∧ (result.leftAfter fresh).base=input.lhs.base ∧
    (result.rightAfter fresh).bytes=result.after.memory ∧ (result.rightAfter fresh).base=input.rhs.base :=
  ⟨rfl,rfl,rfl,rfl,rfl,rfl⟩

-- No SIMD/barrier implementation, division, epsilon addition, rsqrt or final
-- normalization stores are interpreted here. In particular the existing
-- RmsNorm.Platform divide/reduce/rsqrt and contraction binding remain explicit.

theorem writes_values (residual : ResidualRmsMemory.Residual input weight) (columns : List (Fin count)) :
    writes (2*residual.addition.base) input.lhs.base input.rhs.base input.lhs.bytes columns=
      columns.map (fun col => HalfArrayWrites.entry (2*residual.addition.base)
        (fun i => ArrayStorage.bits (ResidualRmsNorm.residual (x i) (update i))) col) := by
  apply List.map_congr_left
  intro col _
  rw [input_residual input col]
  rfl

end Inference.Kernels.Normalization.ResidualRmsCellSource
