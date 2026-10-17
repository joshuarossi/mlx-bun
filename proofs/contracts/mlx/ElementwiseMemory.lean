import contracts.mlx.CopyExecution

namespace Inference.Contracts.Mlx.ElementwiseMemory

-- Sources and destinations are aligned 16-bit word addresses. A lane may
-- overwrite its own input, but cannot overwrite another element's input.
structure Kernel (n inputs : Nat) where
  source : Fin n → Fin inputs → Nat
  destination : Fin n → Nat
  evaluate : (Fin inputs → BitVec 16) → BitVec 16

def Independent (kernel : Kernel n inputs) : Prop :=
  ∀ reader writer, reader≠writer → ∀ operand, kernel.source reader operand≠kernel.destination writer

def result (kernel : Kernel n inputs) (memory : ByteMemory.Bytes) (i : Fin n) : BitVec 16 :=
  kernel.evaluate (fun operand => HalfMemory.load memory (2*kernel.source i operand))

def store (kernel : Kernel n inputs) (memory : ByteMemory.Bytes) (i : Fin n) : HalfMemory.Store :=
  ⟨kernel.destination i, result kernel memory i⟩

def execute (kernel : Kernel n inputs) : List (Fin n) → ByteMemory.Bytes → ByteMemory.Bytes
  | [], memory => memory
  | i::rest, memory => execute kernel rest (HalfMemory.store memory (2*kernel.destination i) (result kernel memory i))

theorem execute_fixed_from (kernel : Kernel n inputs) (independent : Independent kernel)
    (schedule : List (Fin n)) (unique : schedule.Nodup) (before current : ByteMemory.Bytes)
    (attached : ∀ i ∈ schedule, ∀ operand,
      HalfMemory.load current (2*kernel.source i operand)=HalfMemory.load before (2*kernel.source i operand)) :
    execute kernel schedule current=HalfMemory.execute (schedule.map (store kernel before)) current := by
  induction schedule generalizing current with
  | nil => rfl
  | cons i rest ih =>
    have nodup := List.nodup_cons.mp unique
    have value : result kernel current i=result kernel before i :=
      congrArg kernel.evaluate (funext (attached i List.mem_cons_self))
    have tailAttached : ∀ j ∈ rest, ∀ operand,
        HalfMemory.load (HalfMemory.store current (2*kernel.destination i) (result kernel current i)) (2*kernel.source j operand)=
          HalfMemory.load before (2*kernel.source j operand) := by
      intro j member operand
      have different : j≠i := by intro same; subst j; exact nodup.1 member
      rw [CopyExecution.load_store_other _ _ _ _ (independent j i different operand)]
      exact attached j (List.mem_cons_of_mem _ member) operand
    rw [execute, ih nodup.2 _ tailAttached]
    simp only [List.map_cons, HalfMemory.execute, store, value]

theorem execute_fixed (kernel : Kernel n inputs) (independent : Independent kernel)
    (schedule : List (Fin n)) (unique : schedule.Nodup) (before : ByteMemory.Bytes) :
    execute kernel schedule before=HalfMemory.execute (schedule.map (store kernel before)) before :=
  execute_fixed_from kernel independent schedule unique before before (by intro _ _ _; rfl)

-- This also covers loads separated from their own stores: no writes from
-- other elements can change any operand held by the current element.
theorem inputs_between_stores (kernel : Kernel n inputs) (independent : Independent kernel)
    (reader : Fin n) (stores : List HalfMemory.Store)
    (owners : ∀ store ∈ stores, ∃ writer, reader≠writer ∧ store.word=kernel.destination writer)
    (before : ByteMemory.Bytes) (operand : Fin inputs) :
    HalfMemory.load (HalfMemory.execute stores before) (2*kernel.source reader operand)=
      HalfMemory.load before (2*kernel.source reader operand) := by
  apply CopyExecution.source_stable
  intro store member
  obtain ⟨writer, different, same⟩ := owners store member
  rw [same]
  exact independent reader writer different operand

structure Trace (kernel : Kernel n inputs) where
  programs : List (List (Fin n))
  coverage : programs.flatten.Perm (List.finRange n)
  before : ByteMemory.Bytes
  schedule : List (Fin n)
  remaining : List (List (Fin n))
  execution : ThreadgroupWrites.Executes programs schedule remaining
  completed : ThreadgroupWrites.AtBarrier remaining

theorem flatten_singletons (indices : List α) : (indices.map (fun i => [i])).flatten=indices := by
  induction indices with
  | nil => rfl
  | cons i rest ih => simp only [List.map_cons, List.flatten_cons, List.singleton_append, ih]

def Trace.canonical (kernel : Kernel n inputs) (before : ByteMemory.Bytes) : Trace kernel :=
  let programs := (List.finRange n).map (fun i => [i])
  { programs := programs
    coverage := by rw [flatten_singletons]
    before := before
    schedule := programs.flatten
    remaining := List.replicate programs.length []
    execution := ThreadgroupWrites.canonical programs
    completed := ThreadgroupWrites.canonical_barrier programs }

variable {n inputs : Nat} {kernel : Kernel n inputs}

theorem Trace.covered (trace : Trace kernel) : trace.schedule.Perm (List.finRange n) :=
  (ThreadgroupWrites.completed_schedule trace.execution trace.completed).trans trace.coverage

theorem Trace.unique (trace : Trace kernel) : trace.schedule.Nodup :=
  trace.covered.nodup_iff.mpr (List.nodup_finRange n)

def Trace.memory (trace : Trace kernel) : ByteMemory.Bytes := execute kernel trace.schedule trace.before

theorem Trace.memory_fixed (trace : Trace kernel) (independent : Independent kernel) :
    trace.memory=HalfMemory.execute (trace.schedule.map (store kernel trace.before)) trace.before :=
  execute_fixed kernel independent trace.schedule trace.unique trace.before

theorem Trace.read_correct (trace : Trace kernel) (independent : Independent kernel)
    (distinct : Function.Injective kernel.destination) (i : Fin n) :
    HalfMemory.load trace.memory (2*kernel.destination i)=result kernel trace.before i := by
  rw [trace.memory_fixed independent, HalfMemory.execute_load _ _ _ (by omega), show 2*kernel.destination i/2=kernel.destination i by omega]
  apply MemoryCells.written_value
  · intro write member same
    obtain ⟨j, _, rfl⟩ := List.mem_map.mp member
    have equal : j=i := distinct same
    subst j
    rfl
  · exact ⟨store kernel trace.before i, List.mem_map.mpr ⟨i, trace.covered.mem_iff.mpr (List.mem_finRange i), rfl⟩, rfl⟩

theorem Trace.other_region (trace : Trace kernel) (independent : Independent kernel) {base size other length : Nat}
    (inside : ∀ i, base ≤ 2*kernel.destination i ∧ 2*kernel.destination i+2 ≤ base+size)
    (separate : MemoryRegions.Disjoint base size other length) (offset : Nat) (bound : offset<length) :
    trace.memory (other+offset)=trace.before (other+offset) := by
  rw [trace.memory_fixed independent]
  apply MemoryRegions.execute16_other _ _ _ separate offset bound
  intro write member
  obtain ⟨i, _, rfl⟩ := List.mem_map.mp member
  exact inside i

def contiguous (sources : Fin inputs → Nat) (destination : Nat) (evaluate : (Fin inputs → BitVec 16) → BitVec 16) : Kernel n inputs where
  source i operand := sources operand+i.val
  destination i := destination+i.val
  evaluate := evaluate

theorem contiguous_distinct (sources : Fin inputs → Nat) (destination : Nat) (evaluate : (Fin inputs → BitVec 16) → BitVec 16) :
    Function.Injective (contiguous (n := n) sources destination evaluate).destination :=
  fun _ _ same => Fin.ext (Nat.add_left_cancel same)

theorem contiguous_independent (sources : Fin inputs → Nat) (destination : Nat) (evaluate : (Fin inputs → BitVec 16) → BitVec 16)
    (aliases : ∀ operand, sources operand=destination ∨
      MemoryRegions.Disjoint (2*sources operand) (2*n) (2*destination) (2*n)) :
    Independent (contiguous (n := n) sources destination evaluate) := by
  intro reader writer different operand same
  change sources operand+reader.val=destination+writer.val at same
  rcases aliases operand with equal|separate
  · rw [equal] at same
    exact different (Fin.ext (Nat.add_left_cancel same))
  · have hr := reader.isLt
    have hw := writer.isLt
    rcases separate with left|right <;> omega

end Inference.Contracts.Mlx.ElementwiseMemory
