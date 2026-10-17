import kernels.normalization.ResidualRmsLoopControl
import kernels.normalization.ResidualRmsFirstPassMemory
import kernels.normalization.ResidualRmsOutputMemory

namespace Inference.Kernels.Normalization.ResidualRmsLoopMemory
open Contracts.Mlx
open FloatLib FloatLib.Floats FloatLib.Floats.Formats.BinaryInterchange
open ResidualRmsCellSemantics (count BF)
set_option maxRecDepth 10000
attribute [local irreducible] List.finRange NormalizationSchedule.threadColumns

-- Each thread obtains its ordered cells by executing the parsed uint loops.
-- The scheduler below drains those programs in thread order; its logical
-- realization is constructed, while physical GPU scheduling remains explicit.
def programs : List (List (Fin count)) :=
  (List.finRange 1024).map (NormalizationSchedule.threadColumns count)

theorem program_source (thread : Fin 1024) :
    ResidualRmsLoopControl.executeSource ResidualRmsLoopSyntax.sourceBody thread=
      some (NormalizationSchedule.threadColumns count thread) := ResidualRmsLoopControl.source_columns thread

theorem coverage : programs.flatten.Perm (List.finRange count) := by
  change ((List.finRange 1024).flatMap (NormalizationSchedule.threadColumns count)).Perm _
  rw [←NormalizationSchedule.columns_by_thread]
  exact NormalizationSchedule.columns_complete 1024 count (by decide)

inductive FirstPass (contracted : Bool) (left right destination : Nat) :
    List (Fin 1024) → ResidualRmsFirstPassMemory.Machine → ResidualRmsFirstPassMemory.Machine → Prop where
  | nil (before) : FirstPass contracted left right destination [] before before
  | next (control : ResidualRmsLoopControl.executeSource ResidualRmsLoopSyntax.sourceBody thread=some columns)
      (cells : ResidualRmsCellMemory.Runs contracted left right destination columns ⟨before.memory,0⟩ middle)
      (rest : FirstPass contracted left right destination threads
        ⟨middle.memory,fun other => if other=thread then middle.acc else before.accumulators other⟩ after) :
      FirstPass contracted left right destination (thread::threads) before after

theorem firstPass (contracted : Bool) (left right destination : Nat) (threads : List (Fin 1024))
    (before : ResidualRmsFirstPassMemory.Machine) :
    FirstPass contracted left right destination threads before
      (ResidualRmsFirstPassMemory.run contracted left right destination threads before) := by
  induction threads generalizing before with
  | nil => exact .nil _
  | cons thread rest ih =>
    exact .next (program_source thread) (ResidualRmsCellMemory.canonical _ _ _ _ _ _) (ih _)

variable {values weight : Fin count → BF} (input : BinaryMemory.Input values weight)

def outputTrace (factor : Float32) (destination : Nat) :
    ElementwiseMemory.Trace (BinaryMemory.kernel input (ResidualRmsMemory.operation factor) destination) where
  programs := programs
  coverage := coverage
  before := input.lhs.bytes
  schedule := programs.flatten
  remaining := List.replicate programs.length []
  execution := ThreadgroupWrites.canonical programs
  completed := ThreadgroupWrites.canonical_barrier programs

def outputExecution {factor : Float32}
    (existing : BinaryMemory.Execution input (ResidualRmsMemory.operation factor)) :
    BinaryMemory.Execution input (ResidualRmsMemory.operation factor) :=
  ⟨existing.base,existing.bounded,outputTrace input factor existing.base,rfl,existing.independent⟩

-- Independently completed once-only owner schedules write the same complete
-- heap. This follows from attached bytes plus the frame theorem, not from an
-- assumption that the generated parsed output equals an existing result.
theorem same_heap {factor : Float32}
    (first second : BinaryMemory.Execution input (ResidualRmsMemory.operation factor))
    (sameBase : first.base=second.base) : first.trace.memory=second.trace.memory := by
  funext address
  by_cases inside : 2*first.base≤address ∧ address<2*first.base+2*count
  · let col : Fin count := ⟨(address-2*first.base)/2,by omega⟩
    let offset := (address-2*first.base)%2
    have bound : offset<2 := by dsimp [offset]; omega
    have atAddress : 2*first.base+2*col.val+offset=address := by dsimp [col,offset]; omega
    have left := congrArg (fun bits => HalfMemory.byte bits offset) (first.buffer.attached col)
    have right := congrArg (fun bits => HalfMemory.byte bits offset) (second.buffer.attached col)
    change HalfMemory.byte (HalfMemory.load first.trace.memory (2*first.base+2*col.val)) offset=_ at left
    change HalfMemory.byte (HalfMemory.load second.trace.memory (2*second.base+2*col.val)) offset=_ at right
    rw [HalfMemory.byte_load _ _ _ bound] at left right
    have sameAddress : 2*second.base+2*col.val+offset=address := by rw [←sameBase]; exact atAddress
    rw [atAddress] at left
    rw [sameAddress] at right
    exact left.trans right.symm
  · have outside : MemoryRegions.Disjoint (2*first.base) (2*count) address 1 := by
      unfold MemoryRegions.Disjoint; omega
    have left := first.other_region outside 0 (by decide)
    have right := second.other_region (by simpa only [sameBase] using outside) 0 (by decide)
    simpa only [Nat.add_zero] using left.trans right.symm

theorem output_heap {factor : Float32}
    (existing : BinaryMemory.Execution input (ResidualRmsMemory.operation factor)) :
    (outputExecution input existing).trace.memory=existing.trace.memory := same_heap input _ _ rfl

-- Loop programs and parsed output-cell stores now jointly construct the
-- normalized heap, instead of borrowing the existing result's owner schedule.
theorem output_stores {factor : Float32}
    (existing : BinaryMemory.Execution input (ResidualRmsMemory.operation factor))
    (inverse : M1Max.WordMemory) (inverseBase : Nat) (factorRead : inverse inverseBase=factor) :
    ResidualRmsOutputMemory.Runs input.lhs.base input.rhs.base (2*existing.base) inverse inverseBase
      programs.flatten input.lhs.bytes existing.trace.memory := by
  have stores := ResidualRmsOutputMemory.checked_existing input (outputExecution input existing) inverse inverseBase factorRead
  change ResidualRmsOutputMemory.Runs _ _ _ _ _ programs.flatten _
    (outputExecution input existing).trace.memory at stores
  rw [output_heap input existing] at stores
  exact stores

end Inference.Kernels.Normalization.ResidualRmsLoopMemory
