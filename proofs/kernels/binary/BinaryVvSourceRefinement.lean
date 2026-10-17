import kernels.binary.BinaryVvInterleaving

namespace Inference.Kernels.Binary.BinaryVvSourceRefinement
open Contracts.Mlx BinaryVvBody BinaryVvInterleaving
open FloatLib FloatLib.Floats FloatLib.Floats.Formats.BinaryInterchange
set_option maxRecDepth 10000
attribute [local irreducible] List.finRange

variable {valuesLeft valuesRight : Fin count → BFloatAddSource.BF}

def binary (input : BinaryMemory.Input valuesLeft valuesRight) (destination : Nat)
    (allocation : Allocation input.lhs.base input.rhs.base destination) : BinaryMemory.Execution input BFloatAddSource.operation :=
  BinaryMemory.fromBuffers input BFloatAddSource.operation (destination/2)
    (by have := allocation.destinationAligned; have := allocation.destinationBounded; omega)
    (Or.inr (by simpa only [show 2*(destination/2)=destination by have := allocation.destinationAligned; omega]
      using MemoryRegions.disjoint_symm allocation.leftFresh))
    (Or.inr (by simpa only [show 2*(destination/2)=destination by have := allocation.destinationAligned; omega]
      using MemoryRegions.disjoint_symm allocation.rightFresh))

theorem binary_base (input : BinaryMemory.Input valuesLeft valuesRight) (allocation : Allocation input.lhs.base input.rhs.base destination) :
    (binary input destination allocation).buffer.base=destination := by
  change 2*(destination/2)=destination
  have := allocation.destinationAligned
  omega

theorem initial_value (input : BinaryMemory.Input valuesLeft valuesRight) (thread : Fin count) :
    BinaryVvBody.value input.lhs.base input.rhs.base input.lhs.bytes thread=
      ArrayStorage.bits (ElementwiseAdd.forward valuesLeft valuesRight thread) := by
  have lhs := input.lhs.attached thread
  have rhs := input.rhs.attached thread
  rw [input.shared] at rhs
  unfold BinaryVvBody.value
  rw [lhs,rhs]
  rfl

-- Every completed legal separate-load/store execution yields the exact heap of
-- the existing shared-heap BinaryMemory execution, not just output readback.
theorem refines (input : BinaryMemory.Input valuesLeft valuesRight)
    (allocation : Allocation input.lhs.base input.rhs.base destination)
    (execution : Executes input.lhs.base input.rhs.base destination (BinaryVvInterleaving.initial input.lhs.bytes) events after)
    (completed : Completed after) :
    after.memory=(binary input destination allocation).trace.memory := by
  funext address
  by_cases inside : destination≤address ∧ address<destination+2*count
  · let thread : Fin count := ⟨(address-destination)/2,by omega⟩
    let offset := (address-destination)%2
    have bound : offset<2 := by dsimp [offset]; omega
    have atAddress : destination+2*thread.val+offset=address := by dsimp [thread,offset]; omega
    have first := completed_byte allocation execution completed thread offset bound
    rw [initial_value input thread] at first
    have second := congrArg (fun bits => HalfMemory.byte bits offset) ((binary input destination allocation).buffer.attached thread)
    rw [binary_base input allocation,HalfMemory.byte_load _ _ _ bound] at second
    rw [←atAddress]
    exact first.trans second.symm
  · have outside : MemoryRegions.Disjoint destination (2*count) address 1 := by unfold MemoryRegions.Disjoint; omega
    have first := frame allocation execution outside 0 (by decide)
    have second := (binary input destination allocation).other_region (base:=address) (size:=1)
      (by change MemoryRegions.Disjoint (2*(destination/2)) (2*count) address 1
          simpa only [show 2*(destination/2)=destination by have := allocation.destinationAligned; omega] using outside) 0 (by decide)
    simpa only [Nat.add_zero] using first.trans second.symm

-- A source buffer attached to the derived final heap; callers supply no output.
def output (input : BinaryMemory.Input valuesLeft valuesRight)
    (allocation : Allocation input.lhs.base input.rhs.base destination)
    (execution : Executes input.lhs.base input.rhs.base destination (BinaryVvInterleaving.initial input.lhs.bytes) events after)
    (completed : Completed after) : ArrayStorage.BFBuffer (ElementwiseAdd.forward valuesLeft valuesRight) where
  bytes:=after.memory
  base:=destination
  aligned:=allocation.destinationAligned
  bounded:=allocation.destinationBounded
  attached:=fun thread => (completed_read allocation execution completed thread).trans (initial_value input thread)

theorem run_refines (input : BinaryMemory.Input valuesLeft valuesRight)
    (allocation : Allocation input.lhs.base input.rhs.base destination)
    (threads : List (Fin count)) (permutation : threads.Perm (List.finRange count)) :
    BinaryVvBody.run input.lhs.base input.rhs.base destination threads input.lhs.bytes=
      (binary input destination allocation).trace.memory := by
  have actual := drain_exec (left:=input.lhs.base) (right:=input.rhs.base) (destination:=destination)
    threads (BinaryVvInterleaving.initial input.lhs.bytes)
    (permutation.nodup_iff.mpr (List.nodup_finRange _)) (by intros; rfl) (by intros; rfl)
  have completed : Completed (drain input.lhs.base input.rhs.base destination threads (BinaryVvInterleaving.initial input.lhs.bytes)) := by
    intro thread
    rw [drain_done,ite_eq_left (permutation.mem_iff.mpr (List.mem_finRange thread))]
  have equal := refines input allocation actual completed
  rw [drain_memory] at equal
  exact equal

theorem any_launch (input : BinaryMemory.Input valuesLeft valuesRight)
    (allocation : Allocation input.lhs.base input.rhs.base destination)
    (execution : Launch input.lhs.base input.rhs.base destination threads input.lhs.bytes after)
    (permutation : threads.Perm (List.finRange count)) :
    after=(binary input destination allocation).trace.memory :=
  (launch_eq_run execution).trans (run_refines input allocation threads permutation)

theorem isolated_thread (left right destination : Nat) (thread : Fin count) (before : HalfMemory.Bytes) :
    (finalState left right destination thread before).memory=
      (finishCell left right destination (BinaryVvInterleaving.initial before) thread).memory := by
  rw [finishCell_memory]
  rfl

structure Checked (input : BinaryMemory.Input valuesLeft valuesRight) (destination : Nat)
    (allocation : Allocation input.lhs.base input.rhs.base destination) where
  bodyAfter : HalfMemory.Bytes
  bodyExecution : Launch input.lhs.base input.rhs.base destination (List.finRange count) input.lhs.bytes bodyAfter
  eventAfter : BinaryVvInterleaving.Machine
  eventExecution : Executes input.lhs.base input.rhs.base destination (BinaryVvInterleaving.initial input.lhs.bytes)
    ((List.finRange count).flatMap cellEvents) eventAfter
  completed : Completed eventAfter

def checked (input : BinaryMemory.Input valuesLeft valuesRight)
    (allocation : Allocation input.lhs.base input.rhs.base destination) : Checked input destination allocation where
  bodyAfter:=BinaryVvBody.run input.lhs.base input.rhs.base destination (List.finRange count) input.lhs.bytes
  bodyExecution:=launch _ _ _ _ _
  eventAfter:=canonicalAfter input.lhs.base input.rhs.base destination input.lhs.bytes
  eventExecution:=canonical_execution _ _ _ _
  completed:=canonical_completed _ _ _ _

theorem Checked.same_heap {input : BinaryMemory.Input valuesLeft valuesRight}
    {allocation : Allocation input.lhs.base input.rhs.base destination} (result : Checked input destination allocation) :
    result.bodyAfter=result.eventAfter.memory :=
  (any_launch input allocation result.bodyExecution (.refl _)).trans
    (refines input allocation result.eventExecution result.completed).symm

-- Actual arbitrary completed events can be consumed without a supplied
-- thread-atomic execution witness: the parsed body launch is constructed.
theorem from_events (input : BinaryMemory.Input valuesLeft valuesRight)
    (allocation : Allocation input.lhs.base input.rhs.base destination)
    (execution : Executes input.lhs.base input.rhs.base destination (BinaryVvInterleaving.initial input.lhs.bytes) events after)
    (completed : Completed after) :
    Launch input.lhs.base input.rhs.base destination (List.finRange count) input.lhs.bytes after.memory := by
  rw [refines input allocation execution completed,←run_refines input allocation (List.finRange count) (.refl _)]
  exact launch _ _ _ _ _

-- Manual host-selection translation for this selected non-donated row-
-- contiguous BF16 descriptor. Native descriptor/ownership extraction remains
-- explicit; source buffers alone do not establish native contiguous flags.
inductive Route where
  | ss | sv | vs | vv | general
  deriving DecidableEq, Repr

def route (leftSize rightSize : Nat) (leftContiguous rightContiguous leftRow rightRow leftCol rightCol : Bool) : Route :=
  if leftSize=1 ∧ rightSize=1 then .ss
  else if leftSize=1 ∧ rightContiguous then .sv
  else if rightSize=1 ∧ leftContiguous then .vs
  else if (leftRow && rightRow) || (leftCol && rightCol) then .vv else .general

structure Descriptor where
  leftDataSize : Nat
  rightDataSize : Nat
  leftCount : leftDataSize=count
  rightCount : rightDataSize=count
  leftRow : Bool
  rightRow : Bool
  leftRow_true : leftRow=true
  rightRow_true : rightRow=true
  leftContiguous : Bool
  rightContiguous : Bool
  leftCol : Bool
  rightCol : Bool
  leftDonatable : Bool
  rightDonatable : Bool
  leftDonatable_false : leftDonatable=false
  rightDonatable_false : rightDonatable=false

def Descriptor.selectedRoute (descriptor : Descriptor) : Route := route descriptor.leftDataSize descriptor.rightDataSize
  descriptor.leftContiguous descriptor.rightContiguous descriptor.leftRow descriptor.rightRow descriptor.leftCol descriptor.rightCol

def Descriptor.outputDataSize (descriptor : Descriptor) : Nat := descriptor.leftDataSize

def Descriptor.work (descriptor : Descriptor) : Nat :=
  if descriptor.outputDataSize<65536 then 1 else max 1 (8/2)

def Descriptor.grid (descriptor : Descriptor) : Nat :=
  (descriptor.outputDataSize+descriptor.work-1)/descriptor.work

theorem Descriptor.selection (descriptor : Descriptor) :
    descriptor.selectedRoute=.vv ∧ descriptor.work=1 ∧ descriptor.grid=5120 ∧
      descriptor.outputDataSize*2=10240 ∧ descriptor.outputDataSize<2^32 := by
  simp [Descriptor.selectedRoute,route,Descriptor.work,Descriptor.grid,Descriptor.outputDataSize,
    descriptor.leftCount,descriptor.rightCount,descriptor.leftRow_true,descriptor.rightRow_true,count]

def retainedLeft (input : BinaryMemory.Input valuesLeft valuesRight)
    (allocation : Allocation input.lhs.base input.rhs.base destination)
    (execution : Executes input.lhs.base input.rhs.base destination (BinaryVvInterleaving.initial input.lhs.bytes) events after) :
    ArrayStorage.BFBuffer valuesLeft :=
  ArrayFrame.bf input.lhs after.memory (frame allocation execution allocation.leftFresh)

def retainedRight (input : BinaryMemory.Input valuesLeft valuesRight)
    (allocation : Allocation input.lhs.base input.rhs.base destination)
    (execution : Executes input.lhs.base input.rhs.base destination (BinaryVvInterleaving.initial input.lhs.bytes) events after) :
    ArrayStorage.BFBuffer valuesRight :=
  ArrayFrame.bf input.rhs after.memory (by rw [input.shared]; exact frame allocation execution allocation.rightFresh)

theorem retained_bases (input : BinaryMemory.Input valuesLeft valuesRight)
    (allocation : Allocation input.lhs.base input.rhs.base destination)
    (execution : Executes input.lhs.base input.rhs.base destination (BinaryVvInterleaving.initial input.lhs.bytes) events after) :
    (retainedLeft input allocation execution).base=input.lhs.base ∧
    (retainedRight input allocation execution).base=input.rhs.base ∧
    (retainedLeft input allocation execution).bytes=after.memory ∧
    (retainedRight input allocation execution).bytes=after.memory := ⟨rfl,rfl,rfl,rfl⟩

theorem output_read_finite (input : BinaryMemory.Input valuesLeft valuesRight)
    (allocation : Allocation input.lhs.base input.rhs.base destination)
    (execution : Executes input.lhs.base input.rhs.base destination (BinaryVvInterleaving.initial input.lhs.bytes) events after)
    (completed : Completed after) (bounds : ElementwiseAdd.Bounds valuesLeft valuesRight) (thread : Fin count) :
    Model.isFinite (Model.ofBits (HalfMemory.load after.memory (destination+2*thread.val)) : BFloatAddSource.BF)=true := by
  rw [completed_read allocation execution completed,initial_value input thread]
  exact ElementwiseAdd.forward_finite valuesLeft valuesRight bounds thread

theorem allocationFromBuffers (input : BinaryMemory.Input valuesLeft valuesRight) (destination : Nat)
    (aligned : destination%2=0) (bounded : destination+10240≤2^64)
    (leftFresh : MemoryRegions.Disjoint destination 10240 input.lhs.base 10240)
    (rightFresh : MemoryRegions.Disjoint destination 10240 input.rhs.base 10240) :
    Allocation input.lhs.base input.rhs.base destination :=
  ⟨input.lhs.aligned,input.rhs.aligned,aligned,input.lhs.bounded,input.rhs.bounded,bounded,leftFresh,rightFresh⟩

theorem refines_existing (input : BinaryMemory.Input valuesLeft valuesRight)
    (allocation : Allocation input.lhs.base input.rhs.base destination)
    (existing : BinaryMemory.Execution input BFloatAddSource.operation)
    (existingBase : 2*existing.base=destination)
    (execution : Executes input.lhs.base input.rhs.base destination (BinaryVvInterleaving.initial input.lhs.bytes) events after)
    (completed : Completed after) :
    after.memory=existing.trace.memory := by
  funext address
  by_cases inside : destination≤address ∧ address<destination+2*count
  · let thread : Fin count := ⟨(address-destination)/2,by omega⟩
    let offset := (address-destination)%2
    have bound : offset<2 := by dsimp [offset]; omega
    have atAddress : destination+2*thread.val+offset=address := by dsimp [thread,offset]; omega
    have first := completed_byte allocation execution completed thread offset bound
    rw [initial_value input thread] at first
    have second := congrArg (fun bits => HalfMemory.byte bits offset) (existing.buffer.attached thread)
    rw [show existing.buffer.base=destination from existingBase,HalfMemory.byte_load _ _ _ bound] at second
    rw [←atAddress]
    exact first.trans second.symm
  · have outside : MemoryRegions.Disjoint destination (2*count) address 1 := by unfold MemoryRegions.Disjoint; omega
    have first := frame allocation execution outside 0 (by decide)
    have second := existing.other_region (base:=address) (size:=1)
      (by simpa only [existingBase] using outside) 0 (by decide)
    simpa only [Nat.add_zero] using first.trans second.symm

theorem checked_eq_existing (input : BinaryMemory.Input valuesLeft valuesRight)
    (allocation : Allocation input.lhs.base input.rhs.base destination)
    (existing : BinaryMemory.Execution input BFloatAddSource.operation) (existingBase : 2*existing.base=destination) :
    (checked input allocation).bodyAfter=existing.trace.memory ∧
    (checked input allocation).eventAfter.memory=existing.trace.memory := by
  have equal:=refines_existing input allocation existing existingBase
    (checked input allocation).eventExecution (checked input allocation).completed
  exact ⟨(checked input allocation).same_heap.trans equal,equal⟩

end Inference.Kernels.Binary.BinaryVvSourceRefinement
