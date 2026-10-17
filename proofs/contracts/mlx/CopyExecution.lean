import contracts.mlx.ArrayRelocation

namespace Inference.Contracts.Mlx.CopyExecution

-- Aligned BF16 copy instructions, with values read from the current heap.
-- The source-stability theorem below also covers loads interspersed with
-- arbitrary destination stores, without assuming an atomic load/store pair.
structure Operation where
  source : Nat
  destination : Nat

def store (memory : ByteMemory.Bytes) (operation : Operation) : HalfMemory.Store :=
  ⟨operation.destination, HalfMemory.load memory (2*operation.source)⟩

def execute : List Operation → ByteMemory.Bytes → ByteMemory.Bytes
  | [], memory => memory
  | operation::rest, memory =>
    execute rest (HalfMemory.store memory (2*operation.destination) (HalfMemory.load memory (2*operation.source)))

theorem load_store_other (memory : ByteMemory.Bytes) (source destination : Nat) (value : BitVec 16)
    (separate : source≠destination) :
    HalfMemory.load (HalfMemory.store memory (2*destination) value) (2*source)=HalfMemory.load memory (2*source) := by
  have first : ¬(2*destination ≤ 2*source+0 ∧ 2*source+0<2*destination+2) := by omega
  have second : ¬(2*destination ≤ 2*source+1 ∧ 2*source+1<2*destination+2) := by omega
  simp only [HalfMemory.load, HalfMemory.store, first, second, ite_false]

-- Destination writes cannot change a disjoint source, even when the stores
-- contain values from earlier loads held in thread-local registers.
theorem source_stable (stores : List HalfMemory.Store) (memory : ByteMemory.Bytes) (source : Nat)
    (separate : ∀ write ∈ stores, source≠write.word) :
    HalfMemory.load (HalfMemory.execute stores memory) (2*source)=HalfMemory.load memory (2*source) := by
  induction stores generalizing memory with
  | nil => rfl
  | cons write rest ih =>
    rw [HalfMemory.execute, ih (separate := fun s hs => separate s (List.mem_cons_of_mem _ hs))]
    exact load_store_other memory source write.word write.value (separate write List.mem_cons_self)

def NoAlias (operations : List Operation) : Prop :=
  ∀ reader ∈ operations, ∀ writer ∈ operations, reader.source≠writer.destination

theorem no_alias_subset (whole subset : List Operation) (contained : ∀ op ∈ subset, op ∈ whole)
    (separate : NoAlias whole) : NoAlias subset :=
  fun reader hr writer hw => separate reader (contained reader hr) writer (contained writer hw)

theorem loads_between_stores (operations : List Operation) (separate : NoAlias operations)
    (writes : List HalfMemory.Store) (destinations : ∀ write ∈ writes, ∃ op ∈ operations, write.word=op.destination)
    (memory : ByteMemory.Bytes) (reader : Operation) (present : reader ∈ operations) :
    HalfMemory.load (HalfMemory.execute writes memory) (2*reader.source)=HalfMemory.load memory (2*reader.source) := by
  apply source_stable
  intro write hw
  obtain ⟨writer, member, same⟩ := destinations write hw
  rw [same]
  exact separate reader present writer member

theorem execute_fixed_from (operations : List Operation) (before current : ByteMemory.Bytes)
    (separate : NoAlias operations)
    (attached : ∀ op ∈ operations, HalfMemory.load current (2*op.source)=HalfMemory.load before (2*op.source)) :
    execute operations current=HalfMemory.execute (operations.map (store before)) current := by
  induction operations generalizing current with
  | nil => rfl
  | cons operation rest ih =>
    have tailSeparate : NoAlias rest := no_alias_subset _ _ (fun op h => List.mem_cons_of_mem _ h) separate
    have source := attached operation List.mem_cons_self
    have tailAttached : ∀ op ∈ rest,
        HalfMemory.load (HalfMemory.store current (2*operation.destination) (HalfMemory.load current (2*operation.source)))
          (2*op.source)=HalfMemory.load before (2*op.source) := by
      intro op present
      rw [load_store_other _ _ _ _ (separate op (List.mem_cons_of_mem _ present) operation List.mem_cons_self)]
      exact attached op (List.mem_cons_of_mem _ present)
    rw [execute, ih _ tailSeparate tailAttached]
    simp only [List.map_cons, HalfMemory.execute, store, source]

theorem execute_fixed (operations : List Operation) (memory : ByteMemory.Bytes) (separate : NoAlias operations) :
    execute operations memory=HalfMemory.execute (operations.map (store memory)) memory :=
  execute_fixed_from operations memory memory separate (by intro _ _; rfl)

structure Trace (programs : List (List Operation)) where
  before : ByteMemory.Bytes
  schedule : List Operation
  remaining : List (List Operation)
  execution : ThreadgroupWrites.Executes programs schedule remaining
  completed : ThreadgroupWrites.AtBarrier remaining

def Trace.canonical (programs : List (List Operation)) (memory : ByteMemory.Bytes) : Trace programs :=
  ⟨memory, programs.flatten, List.replicate programs.length [],
    ThreadgroupWrites.canonical programs, ThreadgroupWrites.canonical_barrier programs⟩

variable {programs : List (List Operation)}

def Trace.memory (trace : Trace programs) : ByteMemory.Bytes := execute trace.schedule trace.before

theorem Trace.schedule_separate (trace : Trace programs) (separate : NoAlias programs.flatten) : NoAlias trace.schedule :=
  no_alias_subset _ _ (fun _ h => (ThreadgroupWrites.completed_schedule trace.execution trace.completed).mem_iff.mp h) separate

theorem Trace.memory_fixed (trace : Trace programs) (separate : NoAlias programs.flatten) :
    trace.memory=HalfMemory.execute (trace.schedule.map (store trace.before)) trace.before :=
  execute_fixed trace.schedule trace.before (trace.schedule_separate separate)

theorem Trace.fixed_execution (trace : Trace programs) :
    ThreadgroupWrites.Executes (programs.map (List.map (store trace.before)))
      (trace.schedule.map (store trace.before)) (trace.remaining.map (List.map (store trace.before))) :=
  ArrayRelocation.map_execution _ trace.execution

theorem Trace.fixed_completed (trace : Trace programs) :
    ThreadgroupWrites.AtBarrier (trace.remaining.map (List.map (store trace.before))) :=
  ArrayRelocation.map_barrier _ _ trace.completed

theorem fixed_member (programs : List (List Operation)) (memory : ByteMemory.Bytes) (write : HalfMemory.Store)
    (member : write ∈ (programs.map (List.map (store memory))).flatten) :
    ∃ op ∈ programs.flatten, write=store memory op := by
  obtain ⟨thread, threadMember, writeMember⟩ := List.mem_flatten.mp member
  obtain ⟨original, originalMember, rfl⟩ := List.mem_map.mp threadMember
  obtain ⟨op, opMember, rfl⟩ := List.mem_map.mp writeMember
  exact ⟨op, List.mem_flatten.mpr ⟨original, originalMember, opMember⟩, rfl⟩

theorem fixed_covers (programs : List (List Operation)) (memory : ByteMemory.Bytes) (op : Operation)
    (member : op ∈ programs.flatten) : store memory op ∈ (programs.map (List.map (store memory))).flatten := by
  obtain ⟨thread, threadMember, opMember⟩ := List.mem_flatten.mp member
  exact List.mem_flatten.mpr ⟨thread.map (store memory), List.mem_map.mpr ⟨thread, threadMember, rfl⟩,
    List.mem_map.mpr ⟨op, opMember, rfl⟩⟩

theorem Trace.read_correct (trace : Trace programs) (separate : NoAlias programs.flatten) (word : Nat) (value : BitVec 16)
    (values : ∀ op ∈ programs.flatten, op.destination=word → HalfMemory.load trace.before (2*op.source)=value)
    (covered : ∃ op ∈ programs.flatten, op.destination=word) : HalfMemory.load trace.memory (2*word)=value := by
  rw [trace.memory_fixed separate, HalfMemory.execute_load _ _ _ (by omega), show 2*word/2=word by omega]
  apply MemoryCells.completed_value trace.fixed_execution trace.fixed_completed
  · intro write member same
    obtain ⟨op, opMember, rfl⟩ := fixed_member programs trace.before write member
    exact values op opMember same
  · obtain ⟨op, member, same⟩ := covered
    exact ⟨store trace.before op, fixed_covers programs trace.before op member, same⟩

-- Spatial allocation contracts supply the alias precondition. Every reader
-- lies in a source region disjoint from the whole destination region.
theorem no_alias_regions (operations : List Operation) (destination size : Nat)
    (writes : ∀ op ∈ operations, destination ≤ 2*op.destination ∧ 2*op.destination+2 ≤ destination+size)
    (reads : ∀ op ∈ operations, ∃ base length,
      base ≤ 2*op.source ∧ 2*op.source+2 ≤ base+length ∧ MemoryRegions.Disjoint destination size base length) :
    NoAlias operations := by
  intro reader hr writer hw same
  obtain ⟨base, length, lower, upper, separate⟩ := reads reader hr
  have writerBounds := writes writer hw
  dsimp [MemoryRegions.Disjoint] at separate
  omega

end Inference.Contracts.Mlx.CopyExecution
