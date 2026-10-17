import contracts.mlx.MemoryProjection
import Mathlib.Data.List.ProdSigma
import Mathlib.Data.List.Nodup

namespace Inference.Contracts.Mlx.ReadBeforeOverwrite

-- Threadgroups own disjoint regions. They may overwrite their region
-- after all their readers have captured their inputs. Other groups may
-- read and write concurrently; no device-wide read barrier is assumed.
structure Layout (groups : Nat) where
  base : Fin groups → Nat
  size : Nat
  separate : ∀ first second, first≠second → MemoryRegions.Disjoint (base first) size (base second) size

structure State (groups threads : Nat) (α : Type) where
  memory : ByteMemory.Bytes
  registers : Fin groups → Fin threads → Option α

def initial (before : ByteMemory.Bytes) : State groups threads α := ⟨before, fun _ _ => none⟩

def Ready (state : State groups threads α) (group : Fin groups) : Prop :=
  ∀ thread, state.registers group thread≠none

def Local (layout : Layout groups) (read : ByteMemory.Bytes → Fin groups → Fin threads → α) : Prop :=
  ∀ first second group, (∀ offset < layout.size, first (layout.base group+offset)=second (layout.base group+offset)) →
    ∀ thread, read first group thread=read second group thread

structure Valid (layout : Layout groups) (read : ByteMemory.Bytes → Fin groups → Fin threads → α)
    (before : ByteMemory.Bytes) (state : State groups threads α) : Prop where
  registers : ∀ group thread value, state.registers group thread=some value → value=read before group thread
  pending : ∀ group, ¬Ready state group → ∀ offset < layout.size,
    state.memory (layout.base group+offset)=before (layout.base group+offset)

variable {groups threads : Nat} {α : Type} {layout : Layout groups}
  {read : ByteMemory.Bytes → Fin groups → Fin threads → α} {before : ByteMemory.Bytes}

theorem initial_valid : Valid layout read before (initial before) where
  registers := by intro group thread value impossible; cases impossible
  pending := by intro _ _ _ _; rfl

def capture (read : ByteMemory.Bytes → Fin groups → Fin threads → α) (state : State groups threads α)
    (group : Fin groups) (thread : Fin threads) : State groups threads α where
  memory := state.memory
  registers g t := if g=group ∧ t=thread then some (read state.memory group thread) else state.registers g t

def write (state : State groups threads α) (store : HalfMemory.Store) : State groups threads α :=
  ⟨HalfMemory.store state.memory (2*store.word) store.value, state.registers⟩

theorem ready_capture (state : State groups threads α) (group other : Fin groups) (thread : Fin threads)
    (ready : Ready state other) : Ready (capture read state group thread) other := by
  intro t
  by_cases same : other=group ∧ t=thread
  · simp [capture, same]
  · simpa only [capture, same, ite_false] using ready t

theorem capture_valid (localRead : Local layout read) (state : State groups threads α)
    (valid : Valid layout read before state) (group : Fin groups) (thread : Fin threads)
    (pending : state.registers group thread=none) : Valid layout read before (capture read state group thread) := by
  have notReady : ¬Ready state group := fun ready => ready thread pending
  have value := localRead state.memory before group (valid.pending group notReady) thread
  constructor
  · intro g t captured attached
    by_cases same : g=group ∧ t=thread
    · obtain ⟨hg, ht⟩ := same
      subst g
      subst t
      have equal : read state.memory group thread=captured := by
        simpa only [capture, and_self, ite_true, Option.some.injEq] using attached
      exact equal.symm.trans value
    · exact valid.registers g t captured (by simpa only [capture, same, ite_false] using attached)
  · intro other unread offset bound
    exact valid.pending other (fun ready => unread (ready_capture state group other thread ready)) offset bound

theorem write_valid (state : State groups threads α) (valid : Valid layout read before state)
    (group : Fin groups) (store : HalfMemory.Store) (ready : Ready state group)
    (inside : layout.base group ≤ 2*store.word ∧ 2*store.word+2 ≤ layout.base group+layout.size) :
    Valid layout read before (write state store) := by
  constructor
  · exact valid.registers
  · intro other unread offset bound
    have different : group≠other := by intro same; subst other; exact unread ready
    have preserved := MemoryProjection.half_misses store inside (layout.separate group other different) offset bound state.memory
    exact preserved.trans (valid.pending other unread offset bound)

inductive Event (groups threads : Nat) where
  | capture : Fin groups → Fin threads → Event groups threads
  | write : Fin groups → HalfMemory.Store → Event groups threads

inductive Step (layout : Layout groups) (read : ByteMemory.Bytes → Fin groups → Fin threads → α) :
    State groups threads α → Event groups threads → State groups threads α → Prop where
  | capture (state : State groups threads α) (group : Fin groups) (thread : Fin threads)
      (pending : state.registers group thread=none) :
      Step layout read state (.capture group thread) (ReadBeforeOverwrite.capture read state group thread)
  | write (state : State groups threads α) (group : Fin groups) (store : HalfMemory.Store)
      (ready : Ready state group)
      (inside : layout.base group ≤ 2*store.word ∧ 2*store.word+2 ≤ layout.base group+layout.size) :
      Step layout read state (.write group store) (ReadBeforeOverwrite.write state store)

inductive Executes (layout : Layout groups) (read : ByteMemory.Bytes → Fin groups → Fin threads → α) :
    State groups threads α → List (Event groups threads) → State groups threads α → Prop where
  | done (state : State groups threads α) : Executes layout read state [] state
  | next {start middle finish : State groups threads α} {event : Event groups threads} {events : List (Event groups threads)} :
      Step layout read start event middle → Executes layout read middle events finish → Executes layout read start (event::events) finish

theorem step_valid (localRead : Local layout read) {start finish : State groups threads α} {event : Event groups threads}
    (step : Step layout read start event finish) (valid : Valid layout read before start) : Valid layout read before finish := by
  cases step with
  | capture group thread pending => exact capture_valid localRead start valid group thread pending
  | write group store ready inside => exact write_valid start valid group store ready inside

theorem preserves (localRead : Local layout read) {start finish : State groups threads α} {events : List (Event groups threads)}
    (execution : Executes layout read start events finish) (valid : Valid layout read before start) : Valid layout read before finish := by
  induction execution with
  | done => exact valid
  | next step execution ih => exact ih (step_valid localRead step valid)

def storeProjection : Event groups threads → Option HalfMemory.Store
  | .capture _ _ => none
  | .write _ store => some store

theorem memory {start finish : State groups threads α} {events : List (Event groups threads)}
    (execution : Executes layout read start events finish) :
    finish.memory=HalfMemory.execute (events.filterMap storeProjection) start.memory := by
  induction execution with
  | done => rfl
  | next step execution ih =>
    rw [ih]
    cases step <;> rfl

theorem captured_original (localRead : Local layout read) {finish : State groups threads α} {events : List (Event groups threads)}
    (execution : Executes layout read (initial before) events finish) (group : Fin groups) (thread : Fin threads) (value : α)
    (captured : finish.registers group thread=some value) : value=read before group thread :=
  (preserves localRead execution initial_valid).registers group thread value captured

theorem frame {start finish : State groups threads α} {events : List (Event groups threads)}
    (execution : Executes layout read start events finish) {base size : Nat}
    (separate : ∀ group, MemoryRegions.Disjoint (layout.base group) layout.size base size)
    (offset : Nat) (bound : offset<size) : finish.memory (base+offset)=start.memory (base+offset) := by
  induction execution with
  | done => rfl
  | next step execution ih =>
    apply ih.trans
    cases step with
    | capture group thread pending => rfl
    | write group store ready inside => exact MemoryProjection.half_misses store inside (separate group) offset bound _

def captureMany (read : ByteMemory.Bytes → Fin groups → Fin threads → α) :
    List (Fin groups × Fin threads) → State groups threads α → State groups threads α
  | [], state => state
  | reader::rest, state => captureMany read rest (capture read state reader.1 reader.2)

theorem captureMany_registers (readers : List (Fin groups × Fin threads)) (state : State groups threads α)
    (reader : Fin groups × Fin threads) :
    (captureMany read readers state).registers reader.1 reader.2=
      if reader ∈ readers then some (read state.memory reader.1 reader.2) else state.registers reader.1 reader.2 := by
  induction readers generalizing state with
  | nil => simp only [captureMany, List.not_mem_nil, ite_false]
  | cons next rest ih =>
    rw [captureMany, ih]
    by_cases member : reader ∈ rest
    · simp only [member, ite_true, List.mem_cons, or_true, capture]
    · by_cases same : reader=next
      · subst reader
        simp [member, capture]
      · have different : ¬(reader.1=next.1 ∧ reader.2=next.2) := fun h => same (Prod.ext h.1 h.2)
        simp only [member, ite_false, List.mem_cons, same, or_self, capture, different]

theorem captureMany_valid (readers : List (Fin groups × Fin threads)) (unique : readers.Nodup)
    (state : State groups threads α) (pending : ∀ reader ∈ readers, state.registers reader.1 reader.2=none) :
    Executes layout read state (readers.map (fun reader => Event.capture reader.1 reader.2)) (captureMany read readers state) := by
  induction readers generalizing state with
  | nil => exact .done state
  | cons reader rest ih =>
    have nodup := List.nodup_cons.mp unique
    apply Executes.next (.capture state reader.1 reader.2 (pending reader List.mem_cons_self))
    apply ih nodup.2
    intro other member
    have different : ¬(other.1=reader.1 ∧ other.2=reader.2) := by
      intro same
      have equal : other=reader := Prod.ext same.1 same.2
      subst other
      exact nodup.1 member
    simpa only [capture, different, ite_false] using pending other (List.mem_cons_of_mem _ member)

def allReaders (groups threads : Nat) : List (Fin groups × Fin threads) :=
  (List.finRange groups).product (List.finRange threads)

theorem allReaders_member (reader : Fin groups × Fin threads) : reader ∈ allReaders groups threads :=
  List.mem_product.mpr ⟨List.mem_finRange _, List.mem_finRange _⟩

theorem canonical : Executes layout read (initial before)
    ((allReaders groups threads).map (fun reader => Event.capture reader.1 reader.2))
    (captureMany read (allReaders groups threads) (initial before)) :=
  captureMany_valid _ ((List.nodup_finRange groups).product (List.nodup_finRange threads)) _ (by intro _ _; rfl)

theorem canonical_ready (group : Fin groups) : Ready (captureMany read (allReaders groups threads) (initial before)) group := by
  intro thread
  rw [captureMany_registers _ _ (group, thread), ite_eq_left (allReaders_member (group, thread))]
  simp

theorem append_execution {start middle finish : State groups threads α} {first second : List (Event groups threads)}
    (left : Executes layout read start first middle) (right : Executes layout read middle second finish) :
    Executes layout read start (first++second) finish := by
  induction left with
  | done => exact right
  | next step execution ih => exact .next step (ih right)

def writeMany : List (Fin groups × HalfMemory.Store) → State groups threads α → State groups threads α
  | [], state => state
  | entry::rest, state => writeMany rest (write state entry.2)

theorem writeMany_registers (stores : List (Fin groups × HalfMemory.Store)) (state : State groups threads α) :
    (writeMany stores state).registers=state.registers := by
  induction stores generalizing state with
  | nil => rfl
  | cons entry rest ih => exact ih (write state entry.2)

theorem writeMany_valid (stores : List (Fin groups × HalfMemory.Store)) (state : State groups threads α)
    (ready : ∀ group, Ready state group)
    (inside : ∀ entry ∈ stores, layout.base entry.1 ≤ 2*entry.2.word ∧ 2*entry.2.word+2 ≤ layout.base entry.1+layout.size) :
    Executes layout read state (stores.map (fun entry => Event.write entry.1 entry.2)) (writeMany stores state) := by
  induction stores generalizing state with
  | nil => exact .done state
  | cons entry rest ih =>
    exact .next (.write state entry.1 entry.2 (ready entry.1) (inside entry List.mem_cons_self))
      (ih (write state entry.2) ready (fun next member => inside next (List.mem_cons_of_mem _ member)))

theorem writeMany_ready (stores : List (Fin groups × HalfMemory.Store)) (state : State groups threads α)
    (ready : ∀ group, Ready state group) (group : Fin groups) : Ready (writeMany stores state) group := by
  unfold Ready
  rw [writeMany_registers]
  exact ready group

end Inference.Contracts.Mlx.ReadBeforeOverwrite
