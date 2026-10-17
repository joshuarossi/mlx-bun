import kernels.normalization.ResidualRmsCellSemantics
import kernels.copy.VectorCopyInterleaving

namespace Inference.Kernels.Normalization.ResidualRmsCellMemory
open Contracts.Mlx ResidualRmsCellSemantics
open FloatLib FloatLib.Floats FloatLib.Floats.Formats.BinaryInterchange
set_option maxRecDepth 10000
attribute [local irreducible] List.finRange NormalizationSchedule.threadColumns

structure Allocation (left right destination : Nat) : Prop where
  destinationAligned : destination%2=0
  destinationBounded : destination+2*count≤2^64
  leftFresh : MemoryRegions.Disjoint destination (2*count) left (2*count)
  rightFresh : MemoryRegions.Disjoint destination (2*count) right (2*count)

structure State where
  memory : HalfMemory.Bytes
  acc : Float32

def cell (contracted : Bool) (left right destination : Nat) (col : Fin count) (state : State) : State :=
  let value:=ResidualRmsCellSemantics.residual left right state.memory col
  ⟨HalfMemory.store state.memory (destination+2*col.val) (ArrayStorage.bits value),step contracted value state.acc⟩

def run (contracted : Bool) (left right destination : Nat) : List (Fin count) → State → State
  | [],state => state
  | col::rest,state => run contracted left right destination rest (cell contracted left right destination col state)

-- Every modeled cell invocation has an execution of the parsed five statements.
-- The accumulation reads the captured rounded BF16 value, not a precomputed
-- scalar or a later output buffer supplied by the caller.
inductive Runs (contracted : Bool) (left right destination : Nat) : List (Fin count) → State → State → Prop where
  | nil (state) : Runs contracted left right destination [] state state
  | next (bodyExecution : execute contracted left right destination ResidualRmsCellSyntax.body
        (initial col before.acc before.memory)=some middle)
      (accRead : middle.env "acc"=some (.floating nextAcc))
      (rest : Runs contracted left right destination columns ⟨middle.memory,nextAcc⟩ after) :
      Runs contracted left right destination (col::columns) before after

theorem canonical (contracted : Bool) (left right destination : Nat) (columns : List (Fin count)) (state : State) :
    Runs contracted left right destination columns state (run contracted left right destination columns state) := by
  induction columns generalizing state with
  | nil => exact .nil _
  | cons col rest ih =>
    refine .next (execution contracted left right destination col state.acc state.memory) ?_ (ih _)
    simp [finalState,ResidualRmsCellSemantics.set]

theorem runs_eq (actual : Runs contracted left right destination columns before after) :
    after=run contracted left right destination columns before := by
  induction actual with
  | nil => rfl
  | @next col middle nextAcc columns after before executed accRead rest ih =>
    have state_eq:=any_execution contracted left right destination col before.acc before.memory middle executed
    rw [state_eq] at accRead ih
    have acc_eq : step contracted (ResidualRmsCellSemantics.residual left right before.memory col) before.acc=nextAcc := by
      exact Value.floating.inj (Option.some.inj (by simpa only [finalState,ResidualRmsCellSemantics.set,ite_true] using accRead))
    rw [←acc_eq] at ih
    exact ih

theorem cell_frame (col : Fin count) (state : State)
    (separate : MemoryRegions.Disjoint destination (2*count) base size) (offset : Nat) (bound : offset<size) :
    (cell contracted left right destination col state).memory (base+offset)=state.memory (base+offset) := by
  have small : MemoryRegions.Disjoint (destination+2*col.val) 2 base size := by
    have := col.isLt
    rcases separate with first|second
    · exact Or.inl (by omega)
    · exact Or.inr (by omega)
  exact Copy.VectorCopyInterleaving.store_other state.memory _ _ small offset bound

theorem frame (columns : List (Fin count)) (state : State)
    (separate : MemoryRegions.Disjoint destination (2*count) base size) (offset : Nat) (bound : offset<size) :
    (run contracted left right destination columns state).memory (base+offset)=state.memory (base+offset) := by
  induction columns generalizing state with
  | nil => rfl
  | cons col rest ih => exact (ih _).trans (cell_frame col state separate offset bound)

structure SourceReads (left right : Nat) (before current : HalfMemory.Bytes) : Prop where
  leftRead : ∀ col : Fin count, HalfMemory.load current (left+2*col.val)=HalfMemory.load before (left+2*col.val)
  rightRead : ∀ col : Fin count, HalfMemory.load current (right+2*col.val)=HalfMemory.load before (right+2*col.val)

theorem sourceReads_refl (left right : Nat) (before : HalfMemory.Bytes) : SourceReads left right before before :=
  ⟨by intros; rfl,by intros; rfl⟩

theorem cell_sources (allocation : Allocation left right destination) (col : Fin count) (state : State)
    (reads : SourceReads left right before state.memory) :
    SourceReads left right before (cell contracted left right destination col state).memory where
  leftRead := by
    intro other
    exact (ArrayFrame.half_congr state.memory _ left (2*count) (2*other.val)
      (cell_frame col state allocation.leftFresh) (by have := other.isLt; omega)).trans (reads.leftRead other)
  rightRead := by
    intro other
    exact (ArrayFrame.half_congr state.memory _ right (2*count) (2*other.val)
      (cell_frame col state allocation.rightFresh) (by have := other.isLt; omega)).trans (reads.rightRead other)

theorem residual_eq (reads : SourceReads left right before current) (col : Fin count) :
    ResidualRmsCellSemantics.residual left right current col=ResidualRmsCellSemantics.residual left right before col := by
  unfold ResidualRmsCellSemantics.residual
  rw [reads.leftRead,reads.rightRead]

-- Sequential source order is retained literally by foldl: no real-arithmetic
-- reassociation or permutation is used for the floating accumulator.
theorem accumulator (allocation : Allocation left right destination) (columns : List (Fin count)) (state : State)
    (reads : SourceReads left right before state.memory) :
    (run contracted left right destination columns state).acc=
      columns.foldl (fun acc col => step contracted (ResidualRmsCellSemantics.residual left right before col) acc) state.acc := by
  induction columns generalizing state with
  | nil => rfl
  | cons col rest ih =>
    rw [run,ih _ (cell_sources allocation col state reads)]
    simp only [List.foldl_cons,cell]
    rw [residual_eq reads col]

def writes (destination : Nat) (left right : Nat) (before : HalfMemory.Bytes) (columns : List (Fin count)) : List HalfMemory.Store :=
  columns.map (fun col => ⟨destination/2+col.val,ArrayStorage.bits (ResidualRmsCellSemantics.residual left right before col)⟩)

theorem memory_fixed (allocation : Allocation left right destination) (columns : List (Fin count)) (state : State)
    (reads : SourceReads left right before state.memory) :
    (run contracted left right destination columns state).memory=
      HalfMemory.execute (writes destination left right before columns) state.memory := by
  induction columns generalizing state with
  | nil => rfl
  | cons col rest ih =>
    rw [run,ih _ (cell_sources allocation col state reads)]
    simp only [writes,List.map_cons,HalfMemory.execute,cell]
    rw [residual_eq reads col]
    rw [show 2*(destination/2+col.val)=destination+2*col.val by have := allocation.destinationAligned; omega]

theorem writes_inside (allocation : Allocation left right destination) (columns : List (Fin count)) (before : HalfMemory.Bytes) :
    MemoryRegions.Inside16 destination (2*count) (writes destination left right before columns) := by
  intro write member
  obtain ⟨col,_,rfl⟩:=List.mem_map.mp member
  have := allocation.destinationAligned
  have := col.isLt
  dsimp only
  omega

variable {x update : Fin count → BF}

theorem input_residual (input : BinaryMemory.Input x update) (col : Fin count) :
    ResidualRmsCellSemantics.residual input.lhs.base input.rhs.base input.lhs.bytes col=ResidualRmsNorm.residual (x col) (update col) := by
  have right:=input.rhs.attached col
  rw [input.shared] at right
  unfold ResidualRmsCellSemantics.residual
  rw [input.lhs.attached,right]
  rfl

theorem input_accumulator (input : BinaryMemory.Input x update)
    (allocation : Allocation input.lhs.base input.rhs.base destination) (columns : List (Fin count)) (acc : Float32) :
    (run contracted input.lhs.base input.rhs.base destination columns ⟨input.lhs.bytes,acc⟩).acc=
      ResidualRmsNorm.accumulate contracted x update columns acc := by
  rw [accumulator allocation columns _ (sourceReads_refl _ _ _)]
  have operations : (fun acc col => step contracted (ResidualRmsCellSemantics.residual input.lhs.base input.rhs.base input.lhs.bytes col) acc)=
      (fun acc col => step contracted (ResidualRmsNorm.residual (x col) (update col)) acc) := by
    funext current col
    exact congrArg (fun value => step contracted value current) (input_residual input col)
  exact congrArg (fun operation : Float32 → Fin count → Float32 => columns.foldl operation acc) operations

theorem thread_accumulator (input : BinaryMemory.Input x update)
    (allocation : Allocation input.lhs.base input.rhs.base destination) (thread : Fin 1024) :
    (run contracted input.lhs.base input.rhs.base destination (NormalizationSchedule.threadColumns count thread)
      ⟨input.lhs.bytes,0⟩).acc=
      NormalizationReduction.threadSum contracted (ResidualRmsNorm.residualInput x update) thread := by
  rw [input_accumulator input allocation,ResidualRmsNorm.accumulate_execution]
  rfl

theorem all_columns : (NormalizationSchedule.columns 1024 count).Perm (List.finRange count) :=
  NormalizationSchedule.columns_complete _ _ (by decide)

theorem selected_dispatch : min 1024 (((5120+127)/128)*32)=1024 ∧ 1024*4=4096 ∧ 1024/32=32 := by decide

theorem selected_visit (visit : NormalizationSchedule.Visit 1024) (valid : NormalizationSchedule.address visit<count) :
    visit.iteration<2 ∧ visit.iteration*4096+visit.thread.val*4+visit.element.val<5120 ∧
      visit.iteration*4096+visit.thread.val*4+visit.element.val<2^32 := by
  dsimp [NormalizationSchedule.address,count] at valid
  have := visit.thread.isLt
  have := visit.element.isLt
  omega

theorem input_addresses (input : BinaryMemory.Input x update)
    (allocation : Allocation input.lhs.base input.rhs.base destination) (col : Fin count) :
    input.lhs.base+2*col.val+2≤2^64 ∧ input.rhs.base+2*col.val+2≤2^64 ∧ destination+2*col.val+2≤2^64 ∧
      (input.lhs.base+2*col.val)%2=0 ∧ (input.rhs.base+2*col.val)%2=0 ∧ (destination+2*col.val)%2=0 := by
  have := input.lhs.bounded
  have := input.rhs.bounded
  have := allocation.destinationBounded
  have := input.lhs.aligned
  have := input.rhs.aligned
  have := allocation.destinationAligned
  have := col.isLt
  omega

end Inference.Kernels.Normalization.ResidualRmsCellMemory
