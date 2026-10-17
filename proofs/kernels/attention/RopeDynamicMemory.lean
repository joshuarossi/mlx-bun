import kernels.attention.RopeSharedMemory

namespace Inference.Kernels.Attention.RopeDynamicMemory
open Contracts.Mlx
open RopeSharedMemory
abbrev BF := ArrayStorage.BF
variable {x : Fin 256 → BF}
set_option maxHeartbeats 1000000
set_option maxRecDepth 10000

structure State where
  memory : ByteMemory.Bytes
  registers : Fin 32 → Option Rope.Inputs
  history : List (Fin 32 × Fin 2)

def initial (memory : ByteMemory.Bytes) : State := ⟨memory, fun _ => none, []⟩

def fixed (p : Rope.Platform) (source : ArrayStorage.BFBuffer x)
    (theta : Fin 32 → Float32) (entry : Fin 32 × Fin 2) : HalfMemory.Store :=
  MemoryRegions.shift16 source.base (RopeDevice.entry (RopeDevice.rotated p source theta) entry.1 entry.2)

def dynamic (p : Rope.Platform) (base : Nat) (lane : Fin 32) (half : Fin 2) (input : Rope.Inputs) : HalfMemory.Store :=
  ⟨base/2+(RopeDevice.index lane half).val, ArrayStorage.bits (Rope.value p input (decide (half.val=1)))⟩

theorem dynamic_fixed (p : Rope.Platform) (source : ArrayStorage.BFBuffer x)
    (theta : Fin 32 → Float32) (lane : Fin 32) (half : Fin 2) :
    dynamic p source.base lane half (Rope.headInputs x theta lane)=fixed p source theta (lane,half) := by
  have readback : source.read=x := funext source.read_correct
  have bound := half.isLt
  have cases : half=0 ∨ half=1 := by
    rcases (show half.val=0 ∨ half.val=1 by omega) with h|h
    · exact Or.inl (Fin.ext h)
    · exact Or.inr (Fin.ext h)
  rcases cases with rfl|rfl
  · simp only [dynamic, fixed, MemoryRegions.shift16, RopeDevice.entry, RopeDevice.rotated_first, readback]
    rfl
  · simp only [dynamic, fixed, MemoryRegions.shift16, RopeDevice.entry, RopeDevice.rotated_second, readback]
    rfl

inductive Event where
  | capture : Fin 32 → Event
  | write : Fin 32 → Fin 2 → Event

def capture (theta : Fin 32 → Float32) (base : Nat) (state : State) (lane : Fin 32) : State :=
  ⟨state.memory, Function.update state.registers lane (some (RopeSharedMemory.capture state.memory base theta lane)), state.history⟩

def write (p : Rope.Platform) (base : Nat) (state : State) (lane : Fin 32) (half : Fin 2) (input : Rope.Inputs) : State :=
  ⟨HalfMemory.store state.memory (2*(dynamic p base lane half input).word) (dynamic p base lane half input).value,
   state.registers, state.history++[(lane,half)]⟩

-- Each lane captures both operands before its first write and writes the
-- first coordinate before the second, exactly as rope_single_impl does.
inductive Step (p : Rope.Platform) (base : Nat) (theta : Fin 32 → Float32) : State → Event → State → Prop where
  | capture (state : State) (lane : Fin 32) (pending : state.registers lane=none) :
      Step p base theta state (.capture lane) (capture theta base state lane)
  | write (state : State) (lane : Fin 32) (half : Fin 2) (input : Rope.Inputs)
      (captured : state.registers lane=some input)
      (order : (state.history.filter (fun e => e.1=lane)).length=half.val) :
      Step p base theta state (.write lane half) (write p base state lane half input)

inductive Executes (p : Rope.Platform) (base : Nat) (theta : Fin 32 → Float32) : State → List Event → State → Prop where
  | done (state : State) : Executes p base theta state [] state
  | next {start middle finish : State} {event : Event} {events : List Event} :
      Step p base theta start event middle → Executes p base theta middle events finish →
      Executes p base theta start (event::events) finish

def runPair (p : Rope.Platform) (base : Nat) (theta : Fin 32 → Float32) (state : State) (lane : Fin 32) : State :=
  let input := RopeSharedMemory.capture state.memory base theta lane
  let captured := capture theta base state lane
  write p base (write p base captured lane 0 input) lane 1 input

theorem pair_execution (p : Rope.Platform) (base : Nat) (theta : Fin 32 → Float32)
    (state : State) (lane : Fin 32) (pending : state.registers lane=none)
    (unwritten : (state.history.filter (fun e => e.1=lane)).length=0) :
    Executes p base theta state [.capture lane, .write lane 0, .write lane 1] (runPair p base theta state lane) := by
  apply Executes.next (Step.capture state lane pending)
  apply Executes.next (Step.write (capture theta base state lane) lane 0 (RopeSharedMemory.capture state.memory base theta lane) (by simp [capture]) (by exact unwritten))
  apply Executes.next (Step.write (write p base (capture theta base state lane) lane 0 (RopeSharedMemory.capture state.memory base theta lane)) lane 1 (RopeSharedMemory.capture state.memory base theta lane) (by simp [write, capture]) (by simp [write, capture, List.filter_append, unwritten]))
  exact Executes.done _

theorem runPair_memory (p : Rope.Platform) (base : Nat) (theta : Fin 32 → Float32) (state : State) (lane : Fin 32) :
    (runPair p base theta state lane).memory=
      HalfMemory.execute (RopeSharedMemory.pairedStores p base lane
        (RopeSharedMemory.capture state.memory base theta lane)) state.memory := by
  simp only [runPair, write, capture, HalfMemory.execute, RopeSharedMemory.pairedStores, dynamic,
    RopeDevice.index]
  rfl

structure Valid (p : Rope.Platform) (source : ArrayStorage.BFBuffer x) (theta : Fin 32 → Float32) (state : State) : Prop where
  memory : state.memory=HalfMemory.execute (state.history.map (fixed p source theta)) source.bytes
  registers : ∀ lane input, state.registers lane=some input → input=Rope.headInputs x theta lane
  owners : ∀ entry ∈ state.history, state.registers entry.1≠none

theorem initial_valid (p : Rope.Platform) (source : ArrayStorage.BFBuffer x) (theta : Fin 32 → Float32) :
    Valid p source theta (initial source.bytes) := by
  constructor
  · rfl
  · intro lane input h; cases h
  · intro entry h; cases h

variable {p : Rope.Platform} {source : ArrayStorage.BFBuffer x} {theta : Fin 32 → Float32}
  {state start finish : State} {lane : Fin 32} {event : Event} {events : List Event}

theorem capture_original (valid : Valid p source theta state) (pending : state.registers lane=none) :
    RopeSharedMemory.capture state.memory source.base theta lane=Rope.headInputs x theta lane := by
  rw [valid.memory]
  apply capture_after_other_lanes source theta lane (RopeDevice.rotated p source theta)
  intro store member
  obtain ⟨entry, present, rfl⟩ := List.mem_map.mp member
  refine ⟨entry.1,entry.2,?_,rfl⟩
  intro same
  have owned := valid.owners entry present
  rw [← same, pending] at owned
  exact owned rfl

theorem execute_append (first second : List HalfMemory.Store) (memory : ByteMemory.Bytes) :
    HalfMemory.execute (first++second) memory=HalfMemory.execute second (HalfMemory.execute first memory) := by
  induction first generalizing memory with
  | nil => rfl
  | cons store rest ih => exact ih _

theorem step_valid (step : Step p source.base theta start event finish)
    (valid : Valid p source theta start) : Valid p source theta finish := by
  cases step with
  | capture lane pending =>
    constructor
    · exact valid.memory
    · intro other input h
      by_cases same : other=lane
      · subst other
        have equal : RopeSharedMemory.capture start.memory source.base theta lane=input := by
          simpa [capture] using h
        exact equal.symm.trans (capture_original valid pending)
      · exact valid.registers other input (by simpa only [capture, Function.update_of_ne same] using h)
    · intro entry member
      by_cases same : entry.1=lane
      · simp [capture, same]
      · simpa only [capture, Function.update_of_ne same] using valid.owners entry member
  | write lane half input captured order =>
    have original := valid.registers lane input captured
    have fixedValue := dynamic_fixed p source theta lane half
    rw [← original] at fixedValue
    constructor
    · simp only [write, List.map_append, List.map_singleton, execute_append, HalfMemory.execute]
      rw [← valid.memory, ← fixedValue]
    · exact valid.registers
    · intro entry member
      rcases List.mem_append.mp member with h|h
      · exact valid.owners entry h
      · have equal := List.mem_singleton.mp h
        subst entry
        simp only [write, captured, ne_eq, reduceCtorEq, not_false_eq_true]

theorem preserves (execution : Executes p source.base theta start events finish)
    (valid : Valid p source theta start) : Valid p source theta finish := by
  induction execution with
  | done => exact valid
  | next step execution ih => exact ih (step_valid step valid)

def runLanes (p : Rope.Platform) (base : Nat) (theta : Fin 32 → Float32) : List (Fin 32) → State → State
  | [], state => state
  | lane::rest, state => runLanes p base theta rest (runPair p base theta state lane)

def laneEvents (lane : Fin 32) : List Event := [.capture lane, .write lane 0, .write lane 1]
def laneHistory (lane : Fin 32) : List (Fin 32 × Fin 2) := [(lane,0),(lane,1)]

theorem runLanes_history (lanes : List (Fin 32)) (state : State) :
    (runLanes p base theta lanes state).history=state.history++lanes.flatMap laneHistory := by
  induction lanes generalizing state with
  | nil => simp [runLanes]
  | cons lane rest ih =>
    simp only [runLanes, ih, runPair, write, capture, List.flatMap_cons, laneHistory]
    simp [List.append_assoc]

theorem append_execution (left : Executes p base theta start first middle)
    (right : Executes p base theta middle second finish) : Executes p base theta start (first++second) finish := by
  induction left with
  | done => exact right
  | next step execution ih => exact .next step (ih right)

theorem runLanes_execution (lanes : List (Fin 32)) (unique : lanes.Nodup) (state : State)
    (valid : Valid p source theta state) (pending : ∀ lane ∈ lanes, state.registers lane=none) :
    Executes p source.base theta state (lanes.flatMap laneEvents) (runLanes p source.base theta lanes state) := by
  induction lanes generalizing state with
  | nil => exact .done _
  | cons lane rest ih =>
    have notWritten : (state.history.filter (fun e => e.1=lane)).length=0 := by
      have empty : state.history.filter (fun e => e.1=lane)=[] := by
        apply List.eq_nil_iff_forall_not_mem.mpr
        intro entry member
        obtain ⟨present, same⟩ := List.mem_filter.mp member
        have equal : entry.1=lane := of_decide_eq_true same
        have owner := valid.owners entry present
        rw [equal, pending lane List.mem_cons_self] at owner
        exact owner rfl
      rw [empty]
      rfl
    have pair := pair_execution p source.base theta state lane (pending lane List.mem_cons_self) notWritten
    apply append_execution pair
    apply ih (List.nodup_cons.mp unique).2 _ (preserves pair valid)
    intro other member
    have different : other≠lane := by
      intro same
      subst other
      exact (List.nodup_cons.mp unique).1 member
    simpa only [runPair, write, capture, Function.update_of_ne different] using pending other (List.mem_cons_of_mem _ member)

structure Execution (p : Rope.Platform) (source : ArrayStorage.BFBuffer x) (theta : Fin 32 → Float32) where
  events : List Event
  finish : State
  execution : Executes p source.base theta (initial source.bytes) events finish
  physical : RopeSharedMemory.Trace source.base (RopeDevice.rotated p source theta)
  before : physical.before=source.bytes
  schedule : finish.history.map (fixed p source theta)=physical.schedule

def physicalCanonical (source : ArrayStorage.BFBuffer x) (p : Rope.Platform) (theta : Fin 32 → Float32) :
    RopeSharedMemory.Trace source.base (RopeDevice.rotated p source theta) where
  before := source.bytes
  aligned := source.aligned
  localTrace := RopeDevice.Trace.canonical _ (MemoryRegions.view source.bytes source.base)
  attached := rfl

theorem history_programs (source : ArrayStorage.BFBuffer x) (p : Rope.Platform) (theta : Fin 32 → Float32) :
    ((List.finRange 32).flatMap laneHistory).map (fixed p source theta)=
      ((RopeDevice.programs (RopeDevice.rotated p source theta)).flatten.map (MemoryRegions.shift16 source.base)) := by
  change ((List.finRange 32).flatMap laneHistory).map (fixed p source theta)=
    ((List.finRange 32).flatMap (fun lane => (List.finRange 2).map (RopeDevice.entry (RopeDevice.rotated p source theta) lane))).map (MemoryRegions.shift16 source.base)
  simp only [List.map_flatMap]
  apply congrArg (List.flatMap · (List.finRange 32))
  funext lane
  simp only [laneHistory, List.map_cons, List.map_nil, List.map_map, Function.comp_def]
  simp only [List.finRange_succ, List.finRange_zero, List.map_cons, List.map_nil]
  rfl

def Execution.canonical (source : ArrayStorage.BFBuffer x) (p : Rope.Platform) (theta : Fin 32 → Float32) :
    Execution p source theta where
  events := (List.finRange 32).flatMap laneEvents
  finish := runLanes p source.base theta (List.finRange 32) (initial source.bytes)
  execution := runLanes_execution _ (List.nodup_finRange 32) _ (initial_valid p source theta) (by intro _ _; rfl)
  physical := physicalCanonical source p theta
  before := rfl
  schedule := by
    rw [runLanes_history]
    simp only [initial, List.nil_append]
    exact history_programs source p theta

theorem Execution.memory_eq (e : Execution p source theta) : e.finish.memory=e.physical.memory := by
  have valid := preserves e.execution (initial_valid p source theta)
  rw [valid.memory, e.schedule]
  unfold RopeSharedMemory.Trace.memory
  rw [e.before]

theorem Execution.captured_original (e : Execution p source theta) (lane : Fin 32) (input : Rope.Inputs)
    (captured : e.finish.registers lane=some input) : input=Rope.headInputs x theta lane :=
  (preserves e.execution (initial_valid p source theta)).registers lane input captured

theorem Execution.read (e : Execution p source theta) (i : Fin 256) :
    HalfMemory.load e.finish.memory (source.base+2*i.val)=ArrayStorage.bits (Rope.head p x theta i) := by
  rw [e.memory_eq]
  by_cases inside : i.val<64
  · rw [e.physical.read ⟨i.val,inside⟩]
    unfold RopeDevice.rotated
    rw [show source.read=x from funext source.read_correct]
  · rw [e.physical.unchanged i (by omega), e.before, source.attached,
      Rope.unchanged p x theta i (by omega)]

def Execution.buffer (e : Execution p source theta) : ArrayStorage.BFBuffer (Rope.head p x theta) where
  bytes := e.finish.memory
  base := source.base
  aligned := source.aligned
  bounded := source.bounded
  attached := e.read

theorem Execution.output_eq (e : Execution p source theta) : e.buffer.read=Rope.head p x theta :=
  funext e.buffer.read_correct

theorem Execution.frame (e : Execution p source theta) (address : Nat)
    (outside : address<source.base ∨ source.base+128≤address) : e.finish.memory address=source.bytes address := by
  rw [e.memory_eq, e.physical.frame address outside, e.before]

end Inference.Kernels.Attention.RopeDynamicMemory
