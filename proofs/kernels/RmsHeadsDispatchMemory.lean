import kernels.RmsHeadsFreshMemory

namespace Inference.Kernels.RmsHeadsDispatchMemory
open Contracts.Mlx
set_option maxRecDepth 10000
attribute [local irreducible] RmsHeadsMemory.sourceValues RmsHeadsMemory.produced RmsScratch.Trace.factor
  MultiOutputWrites.programs ReadBeforeOverwrite.allReaders ReadBeforeOverwrite.captureMany

variable {heads sourceBase : Nat} {values : Fin heads → Fin 256 → ArrayStorage.BF} {weight : Fin 256 → ArrayStorage.BF}

-- Mode is an explicit ownership/allocation choice. Deriving it from native
-- is_donatable/refcount metadata remains a separate boundary obligation.
inductive Allocation (input : RmsHeadsMemory.Input values weight sourceBase) where
  | donated (geometry : RmsHeadStores.Geometry heads sourceBase)
      (weightSeparate : MemoryRegions.Disjoint sourceBase (512*heads) input.weight.base 512)
  | fresh (destination : Nat) (geometry : RmsHeadStores.Geometry heads destination)
      (sourceSeparate : MemoryRegions.Disjoint destination (512*heads) sourceBase (512*heads))
      (weightSeparate : MemoryRegions.Disjoint destination (512*heads) input.weight.base 512)

def Allocation.base {input : RmsHeadsMemory.Input values weight sourceBase} : Allocation input → Nat
  | .donated _ _ => sourceBase
  | .fresh destination _ _ _ => destination

inductive Execution (input : RmsHeadsMemory.Input values weight sourceBase) (p : RmsNorm.Platform) (width eps : Float32) where
  | donated : RmsHeadsMemory.Execution input p width eps → Execution input p width eps
  | fresh : RmsHeadsFreshMemory.Execution input p width eps → Execution input p width eps

variable {input : RmsHeadsMemory.Input values weight sourceBase} {p : RmsNorm.Platform} {width eps : Float32}

def canonical (input : RmsHeadsMemory.Input values weight sourceBase) (p : RmsNorm.Platform) (width eps : Float32)
    (dispatch : p.groups=2) : Allocation input → Execution input p width eps
  | .donated geometry weightSeparate => .donated (RmsHeadsMemory.canonical input p width eps dispatch geometry weightSeparate)
  | .fresh destination geometry sourceSeparate weightSeparate =>
    .fresh (RmsHeadsFreshMemory.canonical input p width eps dispatch destination geometry sourceSeparate weightSeparate)

def Execution.base : Execution input p width eps → Nat
  | .donated _ => sourceBase
  | .fresh execution => execution.destination

def Execution.memory : Execution input p width eps → ByteMemory.Bytes
  | .donated execution => execution.stores.memory
  | .fresh execution => execution.stores.memory

def Execution.output (execution : Execution input p width eps) (head : Fin heads) : Fin 256 → ArrayStorage.BF :=
  match execution with
  | .donated execution => execution.output head
  | .fresh execution => execution.output head

theorem Execution.output_eq (execution : Execution input p width eps) (head : Fin heads) (before : M1Max.WordMemory) (scratchBase : Nat) :
    execution.output head=RmsNorm.value p (fun i => BFloat16.widen (values head i)) weight width eps before scratchBase := by
  cases execution with
  | donated execution => exact execution.output_eq head before scratchBase
  | fresh execution => exact execution.output_eq head before scratchBase

def Execution.forwardBuffer (execution : Execution input p width eps) (head : Fin heads) (before : M1Max.WordMemory) (scratchBase : Nat) :
    ArrayStorage.BFBuffer (RmsNorm.value p (fun i => BFloat16.widen (values head i)) weight width eps before scratchBase) :=
  match execution with
  | .donated execution => execution.forwardBuffer head before scratchBase
  | .fresh execution => execution.forwardBuffer head before scratchBase

theorem Execution.forward_bytes (execution : Execution input p width eps) (head : Fin heads) (before : M1Max.WordMemory) (scratchBase : Nat) :
    (execution.forwardBuffer head before scratchBase).bytes=execution.memory := by
  cases execution with
  | donated execution =>
    unfold Execution.forwardBuffer RmsHeadsMemory.Execution.forwardBuffer
    rw [ArrayViews.reindex_bytes]
    rfl
  | fresh execution =>
    unfold Execution.forwardBuffer RmsHeadsFreshMemory.Execution.forwardBuffer
    rw [ArrayViews.reindex_bytes]
    rfl

theorem Execution.forward_base (execution : Execution input p width eps) (head : Fin heads) (before : M1Max.WordMemory) (scratchBase : Nat) :
    (execution.forwardBuffer head before scratchBase).base=execution.base+head.val*512 := by
  cases execution with
  | donated execution =>
    unfold Execution.forwardBuffer RmsHeadsMemory.Execution.forwardBuffer
    rw [ArrayViews.reindex_base]
    rfl
  | fresh execution =>
    unfold Execution.forwardBuffer RmsHeadsFreshMemory.Execution.forwardBuffer
    rw [ArrayViews.reindex_base]
    rfl

theorem Execution.other_region (execution : Execution input p width eps) {region size : Nat}
    (separate : MemoryRegions.Disjoint execution.base (512*heads) region size) (offset : Nat) (bound : offset<size) :
    execution.memory (region+offset)=input.source.memory (region+offset) := by
  cases execution with
  | donated execution => exact execution.other_region separate offset bound
  | fresh execution => exact execution.other_region separate offset bound

def Execution.weightsAfter (execution : Execution input p width eps) : ArrayStorage.BFBuffer weight :=
  match execution with
  | .donated execution => execution.weightsAfter
  | .fresh execution => execution.weightsAfter

theorem Execution.weights_shared (execution : Execution input p width eps) : execution.weightsAfter.bytes=execution.memory := by
  cases execution <;> rfl

theorem Execution.aligned (execution : Execution input p width eps) : execution.base%2=0 := by
  cases execution with
  | donated execution => exact execution.geometry.aligned
  | fresh execution => exact execution.geometry.aligned

theorem Execution.bounded (execution : Execution input p width eps) : execution.base+512*heads ≤ 2^64 := by
  cases execution with
  | donated execution => exact execution.geometry.bounded
  | fresh execution => exact execution.geometry.bounded

theorem canonical_base (input : RmsHeadsMemory.Input values weight sourceBase) (p : RmsNorm.Platform) (width eps : Float32)
    (dispatch : p.groups=2) (allocation : Allocation input) :
    (canonical input p width eps dispatch allocation).base=allocation.base := by cases allocation <;> rfl

end Inference.Kernels.RmsHeadsDispatchMemory
