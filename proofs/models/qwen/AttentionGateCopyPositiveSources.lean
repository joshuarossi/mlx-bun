import models.qwen.AttentionGateCopyGrowthInputs
import models.qwen.AttentionGateCopyParsedCacheAppend
import models.qwen.AttentionKvCallerSelection

namespace Inference.Models.Qwen.AttentionGateCopyPositiveSources
open Contracts.Mlx State Kernels.Copy Kernels.Attention
set_option maxRecDepth 10000
attribute [local irreducible] List.finRange Copy2DMemory.programs CopyExecution.Trace.memory

variable {layer : Attention.Layer} {n : Nat} {cache : Kv.Cache Kv.BF n}
  {values : Fin 5120 → ArrayStorage.BF} {angle : RopeAngles.Inputs}
  {s : AttentionGateCopyReadConstruction.Input layer cache values angle}

-- This route retains the prepared allocation for SliceUpdate. Fresh native
-- preservation copies use the separate capacity-preservation construction.
def Inputs (p : AttentionBlockMemory.Preparation s.oldAfter) : Type :=
  match p with
  | .existing _ => PUnit
  | .growth a => AttentionGateCopyGrowthInputs.Scalars s.oldAfter a

def PreparationSource (p : AttentionBlockMemory.Preparation s.oldAfter)
    (inputs : Inputs p) (supported : n≤262144) : Prop :=
  match p,inputs with
  | .existing _,_ => p.storage.memory=s.oldAfter.memory
  | .growth a,scalars => MlxKvGrowthPairSource.Certificate
      (KvGrowthPairMemory.fromStorage s.oldAfter a)
      (AttentionGateCopyGrowthInputs.sources s.oldAfter a scalars) supported

theorem preparation_checked (p : AttentionBlockMemory.Preparation s.oldAfter)
    (inputs : Inputs p) (supported : n≤262144) : PreparationSource p inputs supported := by
  cases p with
  | existing same => rfl
  | growth a => exact AttentionGateCopyGrowthInputs.checked s.oldAfter a inputs supported

def route (p : AttentionBlockMemory.Preparation s.oldAfter) : AttentionKvCallerSelection.Route :=
  match p with
  | .existing _ => .existing (KvAllocation.capacity n)
  | .growth _ => .growth n

theorem caller_selected (p : AttentionBlockMemory.Preparation s.oldAfter) (positive : 0<n) :
    AttentionKvCallerSelection.select n 1 (AttentionKvCallerSelection.model n)=some (route p) := by
  cases p with
  | existing same =>
    apply AttentionKvCallerSelection.existing n positive
    have bound := (KvAllocation.capacity_bounds (n+1)).1
    omega
  | growth a => exact (AttentionKvCallerSelection.growth n positive a.growing).1

variable (read : AttentionGateCopyReadConstruction.ReadPlan s)

def bounds (supported : n+1≤262144) : AttentionGateCopyParsedCacheAppend.Bounds read where
  capacity := KvAllocation.supported_capacity (n+1) supported
  keySource := s.front.rope.key.output.bounded
  valueSource := s.front.valueBuffer.bounded

-- Every source phase is constructed on its actual incoming heap. The native
-- descriptor, donation eligibility and compiler attachment remain boundaries.
theorem checked (positive : 0<n) (supported : n+1≤262144)
    (inputs : Inputs read.allocation.preparation) :
    PreparationSource read.allocation.preparation inputs (by omega) ∧
    AttentionKvCallerSelection.select n 1 (AttentionKvCallerSelection.model n)=
      some (route read.allocation.preparation) ∧
    (AttentionGateCopyParsedCacheAppend.keyChecked read (bounds read supported)).eventAfter.memory=
      (AttentionGateCopyParsedCacheAppend.keys read).copy.memory ∧
    (AttentionGateCopyParsedCacheAppend.valueChecked read (bounds read supported)).eventAfter.memory=
      read.input.cache.memory :=
  ⟨preparation_checked _ inputs (by omega),caller_selected _ positive,
    (AttentionGateCopyParsedCacheAppend.key_heap read (bounds read supported)).2,
    (AttentionGateCopyParsedCacheAppend.value_heap read (bounds read supported)).2⟩

end Inference.Models.Qwen.AttentionGateCopyPositiveSources
