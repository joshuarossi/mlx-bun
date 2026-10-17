import kernels.attention.RopeRowsMemory

namespace Inference.Kernels.Attention.RopeRowsDynamicMemory
open Contracts.Mlx
open RopeRowsMemory
abbrev BF := ArrayStorage.BF
set_option maxRecDepth 10000
set_option maxHeartbeats 1000000
variable {rows base : Nat} {x : Fin rows → Fin 256 → BF}
abbrev Reader (rows : Nat) := Fin rows × Fin 32
abbrev Label (rows : Nat) := Reader rows × Fin 2

structure State (rows : Nat) where
  memory : ByteMemory.Bytes
  registers : Reader rows → Option Rope.Inputs
  history : List (Label rows)

def initial (memory : ByteMemory.Bytes) : State rows := ⟨memory,fun _ => none,[]⟩
def read (memory : ByteMemory.Bytes) (base : Nat) (theta : Fin rows → Fin 32 → Float32) (reader : Reader rows) : Rope.Inputs :=
  RopeSharedMemory.capture memory (base+512*reader.1.val) (theta reader.1) reader.2

def fixed (p : Rope.Platform) (base : Nat) (x : Fin rows → Fin 256 → BF)
    (theta : Fin rows → Fin 32 → Float32) (label : Label rows) : HalfMemory.Store :=
  RopeRowsMemory.entry base (rotated p x theta) label.1.1 label.1.2 label.2

def dynamic (p : Rope.Platform) (base : Nat) (reader : Reader rows) (half : Fin 2) (input : Rope.Inputs) : HalfMemory.Store :=
  RopeDynamicMemory.dynamic p (base+512*reader.1.val) reader.2 half input

theorem dynamic_fixed (p : Rope.Platform) (source : Input x base)
    (theta : Fin rows → Fin 32 → Float32) (reader : Reader rows) (half : Fin 2) :
    dynamic p base reader half (Rope.headInputs (x reader.1) (theta reader.1) reader.2)=fixed p base x theta (reader,half) := by
  change RopeDynamicMemory.dynamic p (source.buffer reader.1).base reader.2 half (Rope.headInputs (x reader.1) (theta reader.1) reader.2)=_
  rw [RopeDynamicMemory.dynamic_fixed p (source.buffer reader.1) (theta reader.1) reader.2 half]
  unfold RopeDynamicMemory.fixed fixed MemoryRegions.shift16 RopeDevice.entry RopeRowsMemory.entry
  congr 1
  · change (base+512*reader.1.val)/2+(RopeDevice.index reader.2 half).val=base/2+256*reader.1.val+(RopeDevice.index reader.2 half).val
    omega
  · unfold RopeDevice.rotated rotated
    rw [show (source.buffer reader.1).read=x reader.1 from funext (source.buffer reader.1).read_correct]

theorem read_attached (source : Input x base) (theta : Fin rows → Fin 32 → Float32) (reader : Reader rows) :
    read source.memory base theta reader=Rope.headInputs (x reader.1) (theta reader.1) reader.2 :=
  RopeSharedMemory.capture_attached (source.buffer reader.1) (theta reader.1) reader.2

theorem other_reader (p : Rope.Platform) (base : Nat) (x : Fin rows → Fin 256 → BF)
    (theta : Fin rows → Fin 32 → Float32) (reader other : Reader rows) (different : reader≠other) (half : Fin 2) :
    (fixed p base x theta (other,half)).word≠(base+512*reader.1.val)/2+reader.2.val ∧
    (fixed p base x theta (other,half)).word≠(base+512*reader.1.val)/2+reader.2.val+32 := by
  have rb := reader.2.isLt
  have ob := other.2.isLt
  have hb := half.isLt
  have diff : reader.1.val≠other.1.val ∨ reader.2.val≠other.2.val := by
    by_cases first : reader.1.val=other.1.val
    · refine Or.inr (fun second => different (Prod.ext (Fin.ext first) (Fin.ext second)))
    · exact Or.inl first
  dsimp [fixed,RopeRowsMemory.entry,RopeDevice.index]
  constructor <;> omega

inductive Event (rows : Nat) where
  | capture : Reader rows → Event rows
  | write : Reader rows → Fin 2 → Event rows

def capture (theta : Fin rows → Fin 32 → Float32) (base : Nat) (state : State rows) (reader : Reader rows) : State rows :=
  ⟨state.memory,Function.update state.registers reader (some (read state.memory base theta reader)),state.history⟩

def write (p : Rope.Platform) (base : Nat) (state : State rows) (reader : Reader rows) (half : Fin 2) (input : Rope.Inputs) : State rows :=
  ⟨HalfMemory.store state.memory (2*(dynamic p base reader half input).word) (dynamic p base reader half input).value,
   state.registers,state.history++[(reader,half)]⟩

-- This permits all native per-thread interleavings and a superset in which
-- head rows are independent. The native four-head loop only adds ordering.
inductive Step (p : Rope.Platform) (base : Nat) (theta : Fin rows → Fin 32 → Float32) : State rows → Event rows → State rows → Prop where
  | capture (state : State rows) (reader : Reader rows) (pending : state.registers reader=none) :
      Step p base theta state (.capture reader) (capture theta base state reader)
  | write (state : State rows) (reader : Reader rows) (half : Fin 2) (input : Rope.Inputs)
      (captured : state.registers reader=some input)
      (order : (state.history.filter (fun e => e.1=reader)).length=half.val) :
      Step p base theta state (.write reader half) (write p base state reader half input)

inductive Executes (p : Rope.Platform) (base : Nat) (theta : Fin rows → Fin 32 → Float32) : State rows → List (Event rows) → State rows → Prop where
  | done (state : State rows) : Executes p base theta state [] state
  | next {start middle finish : State rows} {event : Event rows} {events : List (Event rows)} :
      Step p base theta start event middle → Executes p base theta middle events finish → Executes p base theta start (event::events) finish

structure Valid (p : Rope.Platform) (source : Input x base) (theta : Fin rows → Fin 32 → Float32) (state : State rows) : Prop where
  memory : state.memory=HalfMemory.execute (state.history.map (fixed p base x theta)) source.memory
  registers : ∀ reader input, state.registers reader=some input → input=Rope.headInputs (x reader.1) (theta reader.1) reader.2
  owners : ∀ label ∈ state.history, state.registers label.1≠none

variable {p : Rope.Platform} {source : Input x base} {theta : Fin rows → Fin 32 → Float32}
  {state start finish : State rows} {reader : Reader rows} {event : Event rows} {events : List (Event rows)}

theorem initial_valid : Valid p source theta (initial source.memory) := by
  constructor
  · rfl
  · intro reader input h; cases h
  · intro label h; cases h

theorem capture_original (valid : Valid p source theta state) (pending : state.registers reader=none) :
    read state.memory base theta reader=Rope.headInputs (x reader.1) (theta reader.1) reader.2 := by
  rw [valid.memory]
  unfold read
  rw [RopeSharedMemory.capture_stable _ _ _ (by have := source.aligned; omega)]
  · exact read_attached source theta reader
  · intro store member
    obtain ⟨label,present,rfl⟩ := List.mem_map.mp member
    apply other_reader p base x theta reader label.1 _ label.2
    intro same
    have owned := valid.owners label present
    rw [← same,pending] at owned
    exact owned rfl

theorem step_valid (step : Step p base theta start event finish) (valid : Valid p source theta start) : Valid p source theta finish := by
  cases step with
  | capture reader pending =>
    constructor
    · exact valid.memory
    · intro other input h
      by_cases same : other=reader
      · subst other
        have equal : read start.memory base theta reader=input := by simpa [capture] using h
        exact equal.symm.trans (capture_original valid pending)
      · exact valid.registers other input (by simpa only [capture,Function.update_of_ne same] using h)
    · intro label member
      by_cases same : label.1=reader
      · simp [capture,same]
      · simpa only [capture,Function.update_of_ne same] using valid.owners label member
  | write reader half input captured order =>
    have original := valid.registers reader input captured
    have fixedValue := dynamic_fixed p source theta reader half
    rw [← original] at fixedValue
    constructor
    · simp only [write,List.map_append,List.map_singleton,RopeDynamicMemory.execute_append,HalfMemory.execute]
      rw [← valid.memory,← fixedValue]
    · exact valid.registers
    · intro label member
      rcases List.mem_append.mp member with h|h
      · exact valid.owners label h
      · have equal := List.mem_singleton.mp h
        subst label
        simp only [write,captured,ne_eq,reduceCtorEq,not_false_eq_true]

theorem preserves (execution : Executes p base theta start events finish) (valid : Valid p source theta start) : Valid p source theta finish := by
  induction execution with
  | done => exact valid
  | next step execution ih => exact ih (step_valid step valid)

def runPair (p : Rope.Platform) (base : Nat) (theta : Fin rows → Fin 32 → Float32) (state : State rows) (reader : Reader rows) : State rows :=
  let input := read state.memory base theta reader
  let captured := capture theta base state reader
  write p base (write p base captured reader 0 input) reader 1 input

theorem pair_execution (p : Rope.Platform) (base : Nat) (theta : Fin rows → Fin 32 → Float32)
    (state : State rows) (reader : Reader rows) (pending : state.registers reader=none)
    (unwritten : (state.history.filter (fun e => e.1=reader)).length=0) :
    Executes p base theta state [.capture reader, .write reader 0, .write reader 1] (runPair p base theta state reader) := by
  apply Executes.next (Step.capture state reader pending)
  apply Executes.next (Step.write (capture theta base state reader) reader 0 (read state.memory base theta reader) (by simp [capture]) (by exact unwritten))
  apply Executes.next (Step.write (write p base (capture theta base state reader) reader 0 (read state.memory base theta reader)) reader 1 (read state.memory base theta reader) (by simp [write, capture]) (by simp [write, capture, List.filter_append, unwritten]))
  exact Executes.done _

def runReaders (p : Rope.Platform) (base : Nat) (theta : Fin rows → Fin 32 → Float32) : List (Reader rows) → State rows → State rows
  | [], state => state
  | reader::rest, state => runReaders p base theta rest (runPair p base theta state reader)

def readerEvents (reader : Reader rows) : List (Event rows) := [.capture reader, .write reader 0, .write reader 1]
def readerHistory (reader : Reader rows) : List (Reader rows × Fin 2) := [(reader,0),(reader,1)]

theorem runReaders_history (readers : List (Reader rows)) (state : State rows) :
    (runReaders p base theta readers state).history=state.history++readers.flatMap readerHistory := by
  induction readers generalizing state with
  | nil => simp [runReaders]
  | cons reader rest ih =>
    simp only [runReaders, ih, runPair, write, capture, List.flatMap_cons, readerHistory]
    simp [List.append_assoc]

theorem append_execution (left : Executes p base theta start first middle)
    (right : Executes p base theta middle second finish) : Executes p base theta start (first++second) finish := by
  induction left with
  | done => exact right
  | next step execution ih => exact .next step (ih right)

theorem runReaders_execution (readers : List (Reader rows)) (unique : readers.Nodup) (state : State rows)
    (valid : Valid p source theta state) (pending : ∀ reader ∈ readers, state.registers reader=none) :
    Executes p base theta state (readers.flatMap readerEvents) (runReaders p base theta readers state) := by
  induction readers generalizing state with
  | nil => exact .done _
  | cons reader rest ih =>
    have notWritten : (state.history.filter (fun e => e.1=reader)).length=0 := by
      have empty : state.history.filter (fun e => e.1=reader)=[] := by
        apply List.eq_nil_iff_forall_not_mem.mpr
        intro entry member
        obtain ⟨present, same⟩ := List.mem_filter.mp member
        have equal : entry.1=reader := of_decide_eq_true same
        have owner := valid.owners entry present
        rw [equal, pending reader List.mem_cons_self] at owner
        exact owner rfl
      rw [empty]
      rfl
    have pair := pair_execution p base theta state reader (pending reader List.mem_cons_self) notWritten
    apply append_execution pair
    apply ih (List.nodup_cons.mp unique).2 _ (preserves pair valid)
    intro other member
    have different : other≠reader := by
      intro same
      subst other
      exact (List.nodup_cons.mp unique).1 member
    simpa only [runPair, write, capture, Function.update_of_ne different] using pending other (List.mem_cons_of_mem _ member)

structure Execution (p : Rope.Platform) (source : Input x base) (theta : Fin rows → Fin 32 → Float32) where
  events : List (Event rows)
  finish : State rows
  execution : Executes p base theta (initial source.memory) events finish
  physical : RopeRowsMemory.Rotation p source theta
  schedule : finish.history.map (fixed p base x theta)=physical.trace.schedule

def allReaders (rows : Nat) : List (Reader rows) := (List.finRange rows).product (List.finRange 32)

theorem history_programs (p : Rope.Platform) (base : Nat) (x : Fin rows → Fin 256 → BF)
    (theta : Fin rows → Fin 32 → Float32) :
    ((allReaders rows).flatMap readerHistory).map (fixed p base x theta)=(programs base (rotated p x theta)).flatten := by
  simp only [allReaders,List.product,programs,List.flatten_eq_flatMap,List.flatMap_assoc,List.flatMap_map,List.map_flatMap,id_eq]
  change (List.finRange rows).flatMap (fun head => (List.finRange 32).flatMap
      (fun lane => (readerHistory (head,lane)).map (fixed p base x theta)))=
    (List.finRange rows).flatMap (fun head => (List.finRange 32).flatMap
      (fun lane => (List.finRange 2).map (entry base (rotated p x theta) head lane)))
  apply congrArg (List.flatMap · (List.finRange rows))
  funext head
  apply congrArg (List.flatMap · (List.finRange 32))
  funext lane
  simp only [readerHistory,List.map_cons,List.map_nil,List.finRange_succ,List.finRange_zero]
  rfl

def Execution.canonical (p : Rope.Platform) (source : Input x base)
    (theta : Fin rows → Fin 32 → Float32) : Execution p source theta where
  events := (allReaders rows).flatMap readerEvents
  finish := runReaders p base theta (allReaders rows) (initial source.memory)
  execution := runReaders_execution _ ((List.nodup_finRange rows).product (List.nodup_finRange 32)) _ initial_valid (by intro _ _; rfl)
  physical := Rotation.canonical p source theta
  schedule := by
    rw [runReaders_history]
    simp only [initial,List.nil_append]
    exact history_programs p base x theta

theorem Execution.memory_eq (e : Execution p source theta) : e.finish.memory=e.physical.trace.memory := by
  have valid := preserves e.execution initial_valid
  rw [valid.memory,e.schedule]
  unfold RopeRowsMemory.Trace.memory
  rw [e.physical.before]

def Execution.output (e : Execution p source theta) : Input (fun head => Rope.head p (x head) (theta head)) base where
  memory := e.finish.memory
  aligned := source.aligned
  bounded := source.bounded
  attached := by intro head i; rw [e.memory_eq]; exact e.physical.read head i

theorem Execution.frame (e : Execution p source theta) (address : Nat) (outside : address<base ∨ base+512*rows≤address) :
    e.finish.memory address=source.memory address := by
  rw [e.memory_eq,e.physical.trace.frame address outside,e.physical.before]

end Inference.Kernels.Attention.RopeRowsDynamicMemory
