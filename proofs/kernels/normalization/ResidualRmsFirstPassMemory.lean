import kernels.normalization.ResidualRmsCellSource

namespace Inference.Kernels.Normalization.ResidualRmsFirstPassMemory
open Contracts.Mlx
open ResidualRmsCellSemantics (count BF)
open ResidualRmsCellMemory (Allocation SourceReads)
open FloatLib FloatLib.Floats FloatLib.Floats.Formats.BinaryInterchange
set_option maxRecDepth 10000
attribute [local irreducible] List.finRange NormalizationSchedule.threadColumns

-- A completed first-pass thread runs the parsed cell block in its selected
-- column order and records its own accumulator. The outer-loop translation,
-- physical scheduling, SIMD reduction and barriers remain separate boundaries.
structure Machine where
  memory : HalfMemory.Bytes
  accumulators : Fin 1024 → Float32

def finish (contracted : Bool) (left right destination : Nat) (thread : Fin 1024) (before : Machine) : Machine :=
  let after := ResidualRmsCellMemory.run contracted left right destination
    (NormalizationSchedule.threadColumns count thread) ⟨before.memory,0⟩
  ⟨after.memory,fun other => if other=thread then after.acc else before.accumulators other⟩

def run (contracted : Bool) (left right destination : Nat) : List (Fin 1024) → Machine → Machine
  | [],before => before
  | thread::rest,before => run contracted left right destination rest (finish contracted left right destination thread before)

inductive Launch (contracted : Bool) (left right destination : Nat) : List (Fin 1024) → Machine → Machine → Prop where
  | nil (before) : Launch contracted left right destination [] before before
  | cons (cells : ResidualRmsCellMemory.Runs contracted left right destination
        (NormalizationSchedule.threadColumns count thread) ⟨before.memory,0⟩ middle)
      (rest : Launch contracted left right destination threads
        ⟨middle.memory,fun other => if other=thread then middle.acc else before.accumulators other⟩ after) :
      Launch contracted left right destination (thread::threads) before after

theorem launch (contracted : Bool) (left right destination : Nat) (threads : List (Fin 1024)) (before : Machine) :
    Launch contracted left right destination threads before (run contracted left right destination threads before) := by
  induction threads generalizing before with
  | nil => exact .nil _
  | cons thread rest ih => exact .cons (ResidualRmsCellMemory.canonical _ _ _ _ _ _) (ih _)

theorem launch_eq (execution : Launch contracted left right destination threads before after) :
    after=run contracted left right destination threads before := by
  induction execution with
  | nil => rfl
  | cons cells rest ih => rw [ResidualRmsCellMemory.runs_eq cells] at ih; exact ih

theorem finish_frame (thread : Fin 1024) (before : Machine)
    (separate : MemoryRegions.Disjoint destination (2*count) base size) (offset : Nat) (bound : offset<size) :
    (finish contracted left right destination thread before).memory (base+offset)=before.memory (base+offset) :=
  ResidualRmsCellMemory.frame _ _ separate offset bound

theorem frame (threads : List (Fin 1024)) (before : Machine)
    (separate : MemoryRegions.Disjoint destination (2*count) base size) (offset : Nat) (bound : offset<size) :
    (run contracted left right destination threads before).memory (base+offset)=before.memory (base+offset) := by
  induction threads generalizing before with
  | nil => rfl
  | cons thread rest ih => exact (ih _).trans (finish_frame thread before separate offset bound)

theorem finish_sources (allocation : Allocation left right destination) (thread : Fin 1024) (state : Machine)
    (reads : SourceReads left right before state.memory) :
    SourceReads left right before (finish contracted left right destination thread state).memory where
  leftRead col := (ArrayFrame.half_congr state.memory _ left (2*count) (2*col.val)
    (finish_frame thread state allocation.leftFresh) (by have := col.isLt; omega)).trans (reads.leftRead col)
  rightRead col := (ArrayFrame.half_congr state.memory _ right (2*count) (2*col.val)
    (finish_frame thread state allocation.rightFresh) (by have := col.isLt; omega)).trans (reads.rightRead col)

variable {x update : Fin count → BF} (input : BinaryMemory.Input x update)
  (allocation : Allocation input.lhs.base input.rhs.base destination)
  {contracted : Bool}

include allocation in
private theorem local_accumulator (thread : Fin 1024) (state : Machine)
    (reads : SourceReads input.lhs.base input.rhs.base input.lhs.bytes state.memory) :
    (ResidualRmsCellMemory.run contracted input.lhs.base input.rhs.base destination
      (NormalizationSchedule.threadColumns count thread) ⟨state.memory,0⟩).acc=
      NormalizationReduction.threadSum contracted (ResidualRmsNorm.residualInput x update) thread := by
  rw [ResidualRmsCellMemory.accumulator allocation _ _ reads]
  have operation : (fun acc col => ResidualRmsCellSemantics.step contracted
      (ResidualRmsCellSemantics.residual input.lhs.base input.rhs.base input.lhs.bytes col) acc)=
    (fun acc col => ResidualRmsCellSemantics.step contracted (ResidualRmsNorm.residual (x col) (update col)) acc) := by
    funext acc col
    rw [ResidualRmsCellMemory.input_residual input col]
  rw [operation]
  exact ResidualRmsNorm.accumulate_execution contracted x update (NormalizationSchedule.threadColumns count thread) 0

include allocation in
theorem accumulators (threads : List (Fin 1024)) (state : Machine)
    (reads : SourceReads input.lhs.base input.rhs.base input.lhs.bytes state.memory) (thread : Fin 1024) :
    (run contracted input.lhs.base input.rhs.base destination threads state).accumulators thread=
      if thread∈threads then NormalizationReduction.threadSum contracted (ResidualRmsNorm.residualInput x update) thread
      else state.accumulators thread := by
  induction threads generalizing state with
  | nil => simp [run]
  | cons first rest ih =>
    rw [run,ih _ (finish_sources allocation first state reads)]
    by_cases inRest : thread∈rest
    · simp only [ite_eq_left inRest,List.mem_cons_of_mem first inRest,ite_true]
    · rw [ite_eq_right inRest]
      by_cases same : thread=first
      · subst thread
        change (if first=first then _ else _)=_
        rw [ite_eq_left rfl,local_accumulator input allocation first state reads]
        simp
      · change (if thread=first then _ else _)=_
        simp only [ite_eq_right same,List.mem_cons,not_or_intro same inRest,ite_false]

private theorem execute_append (first second : List HalfMemory.Store) (before : HalfMemory.Bytes) :
    HalfMemory.execute (first++second) before=HalfMemory.execute second (HalfMemory.execute first before) := by
  induction first generalizing before with
  | nil => rfl
  | cons store rest ih => exact ih _

include allocation in
theorem memory (threads : List (Fin 1024)) (state : Machine)
    (reads : SourceReads input.lhs.base input.rhs.base input.lhs.bytes state.memory) :
    (run contracted input.lhs.base input.rhs.base destination threads state).memory=
      HalfMemory.execute (ResidualRmsCellMemory.writes destination input.lhs.base input.rhs.base input.lhs.bytes
        (threads.flatMap (NormalizationSchedule.threadColumns count))) state.memory := by
  induction threads generalizing state with
  | nil => rfl
  | cons thread rest ih =>
    rw [run,ih _ (finish_sources allocation thread state reads)]
    have first := ResidualRmsCellMemory.memory_fixed (contracted:=contracted) allocation
      (NormalizationSchedule.threadColumns count thread) ⟨state.memory,0⟩ reads
    change (finish contracted input.lhs.base input.rhs.base destination thread state).memory=_ at first
    rw [first]
    simp only [List.flatMap_cons,ResidualRmsCellMemory.writes,List.map_append,execute_append]

def initial (input : BinaryMemory.Input x update) : Machine := ⟨input.lhs.bytes,fun _ => 0⟩

def complete (input : BinaryMemory.Input x update) (destination : Nat) (contracted : Bool) : Machine :=
  run contracted input.lhs.base input.rhs.base destination (List.finRange 1024) (initial input)

theorem complete_execution : Launch contracted input.lhs.base input.rhs.base destination (List.finRange 1024)
    (initial input) (complete input destination contracted) := launch _ _ _ _ _ _

include allocation in
theorem complete_accumulators (thread : Fin 1024) :
    (complete input destination contracted).accumulators thread=
      NormalizationReduction.threadSum contracted (ResidualRmsNorm.residualInput x update) thread := by
  rw [complete,accumulators input allocation _ _ (ResidualRmsCellMemory.sourceReads_refl _ _ _)]
  exact ite_eq_left (List.mem_finRange thread)

include allocation in
theorem complete_memory :
    (complete input destination contracted).memory=
      HalfMemory.execute (ResidualRmsCellMemory.writes destination input.lhs.base input.rhs.base input.lhs.bytes
        (NormalizationSchedule.columns 1024 count)) input.lhs.bytes := by
  rw [complete,memory input allocation _ _ (ResidualRmsCellMemory.sourceReads_refl _ _ _)]
  rw [←NormalizationSchedule.columns_by_thread]
  rfl

include allocation in
theorem complete_read (col : Fin count) :
    HalfMemory.load (complete input destination contracted).memory (destination+2*col.val)=
      ArrayStorage.bits (ResidualRmsNorm.residual (x col) (update col)) := by
  rw [complete_memory input allocation]
  rw [HalfMemory.execute_load _ _ _ (by have := allocation.destinationAligned; omega)]
  rw [show (destination+2*col.val)/2=destination/2+col.val by omega]
  apply MemoryCells.written_value
  · intro store member same
    obtain ⟨other,_,rfl⟩ := List.mem_map.mp member
    have equal : other=col := Fin.ext (by dsimp only at same; omega)
    subst other
    exact congrArg ArrayStorage.bits (ResidualRmsCellMemory.input_residual input col)
  · refine ⟨⟨destination/2+col.val,ArrayStorage.bits
      (ResidualRmsCellSemantics.residual input.lhs.base input.rhs.base input.lhs.bytes col)⟩,?_,rfl⟩
    exact List.mem_map.mpr ⟨col,ResidualRmsCellMemory.all_columns.mem_iff.mpr (List.mem_finRange col),rfl⟩

-- The first-pass source execution produces the exact shared heap of the
-- existing residual-addition stage. Its accumulator registers are proved
-- separately in source order; no floating-point reassociation is used.
include allocation in
theorem refines_existing (existing : BinaryMemory.Execution input ResidualRmsNorm.residual)
    (existingBase : 2*existing.base=destination) :
    (complete input destination contracted).memory=existing.trace.memory := by
  funext address
  by_cases inside : destination≤address ∧ address<destination+2*count
  · let col : Fin count := ⟨(address-destination)/2,by omega⟩
    let offset := (address-destination)%2
    have bound : offset<2 := by dsimp [offset]; omega
    have atAddress : destination+2*col.val+offset=address := by dsimp [col,offset]; omega
    have first := congrArg (fun bits => HalfMemory.byte bits offset) (complete_read input allocation col (contracted:=contracted))
    rw [HalfMemory.byte_load _ _ _ bound] at first
    have second := congrArg (fun bits => HalfMemory.byte bits offset) (existing.buffer.attached col)
    rw [show existing.buffer.base=destination from existingBase,HalfMemory.byte_load _ _ _ bound] at second
    rw [←atAddress]
    exact first.trans second.symm
  · have outside : MemoryRegions.Disjoint destination (2*count) address 1 := by unfold MemoryRegions.Disjoint; omega
    have first := frame (contracted:=contracted) (left:=input.lhs.base) (right:=input.rhs.base)
      (List.finRange 1024) (initial input) outside 0 (by decide)
    have second := existing.other_region (base:=address) (size:=1)
      (by simpa only [existingBase] using outside) 0 (by decide)
    simpa only [complete,Nat.add_zero] using first.trans second.symm

def output : ArrayStorage.BFBuffer (fun col => ResidualRmsNorm.residual (x col) (update col)) where
  bytes := (complete input destination contracted).memory
  base := destination
  aligned := allocation.destinationAligned
  bounded := allocation.destinationBounded
  attached := complete_read input allocation

variable {weight : Fin count → BF}

theorem residual_heap (residual : ResidualRmsMemory.Residual input weight)
    (fresh : Allocation input.lhs.base input.rhs.base (2*residual.addition.base)) :
    (complete input (2*residual.addition.base) contracted).memory=residual.addition.trace.memory :=
  refines_existing input fresh residual.addition rfl

def weightsAfter (residual : ResidualRmsMemory.Residual input weight)
    (fresh : Allocation input.lhs.base input.rhs.base (2*residual.addition.base)) : ArrayStorage.BFBuffer weight :=
  ArrayFrame.bf residual.weights (complete input (2*residual.addition.base) contracted).memory (by
    intro offset bound
    rw [residual_heap input residual fresh]
    exact (residual.addition.other_region residual.weightsSeparate offset bound).trans
      (congrFun residual.shared (residual.weights.base+offset)).symm)

-- The constructed parsed execution and existing high-level stage can therefore
-- share the same residual heap and the same 1024 source-order local sums.
theorem checked_residual (residual : ResidualRmsMemory.Residual input weight)
    (fresh : Allocation input.lhs.base input.rhs.base (2*residual.addition.base)) :
    Launch contracted input.lhs.base input.rhs.base (2*residual.addition.base) (List.finRange 1024)
      (initial input) (complete input (2*residual.addition.base) contracted) ∧
    (complete input (2*residual.addition.base) contracted).memory=residual.addition.trace.memory ∧
    ∀ thread, (complete input (2*residual.addition.base) contracted).accumulators thread=
      NormalizationReduction.threadSum contracted residual.sourceValues thread := by
  refine ⟨complete_execution input,residual_heap input residual fresh,?_⟩
  intro thread
  rw [residual.sourceValues_eq]
  exact complete_accumulators input fresh thread

end Inference.Kernels.Normalization.ResidualRmsFirstPassMemory
