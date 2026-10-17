import contracts.mlx.ArrayFrame

namespace Inference.Contracts.Mlx.ArrayRelocation

-- Relocation maps addresses while preserving each thread's instruction
-- order and the actual legal interleaving. Completion is preserved too.
theorem map_step (f : α → β) {before after : List (List α)} {store : α}
    (step : ThreadgroupWrites.Step before store after) :
    ThreadgroupWrites.Step (before.map (List.map f)) (f store) (after.map (List.map f)) := by
  induction step with
  | head store rest threads =>
    simpa only [List.map_cons] using ThreadgroupWrites.Step.head (f store) (rest.map f) (threads.map (List.map f))
  | tail thread step ih =>
    simpa only [List.map_cons] using ThreadgroupWrites.Step.tail (thread.map f) ih

theorem map_execution (f : α → β) {before after : List (List α)} {schedule : List α}
    (execution : ThreadgroupWrites.Executes before schedule after) :
    ThreadgroupWrites.Executes (before.map (List.map f)) (schedule.map f) (after.map (List.map f)) := by
  induction execution with
  | done threads => exact .done _
  | next step execution ih => exact .next (map_step f step) ih

theorem map_barrier (f : α → β) (threads : List (List α)) (ready : ThreadgroupWrites.AtBarrier threads) :
    ThreadgroupWrites.AtBarrier (threads.map (List.map f)) := by
  intro mapped member
  obtain ⟨thread, originalMember, rfl⟩ := List.mem_map.mp member
  rw [ready thread originalMember]
  rfl

theorem word_programs (base : Nat) (values : Fin n → BitVec 32) :
    (WordArrayWrites.programs 0 values).map (List.map (MemoryRegions.shift32 base))=WordArrayWrites.programs base values := by
  simp only [WordArrayWrites.programs, List.map_map, Function.comp_def, List.map_singleton]
  simp only [WordArrayWrites.entry, MemoryRegions.shift32, Nat.zero_div, Nat.zero_add]

theorem half_programs (base : Nat) (values : Fin n → BitVec 16) :
    (HalfArrayWrites.programs 0 values).map (List.map (MemoryRegions.shift16 base))=HalfArrayWrites.programs base values := by
  simp only [HalfArrayWrites.programs, List.map_map, Function.comp_def, List.map_singleton]
  simp only [HalfArrayWrites.entry, MemoryRegions.shift16, Nat.zero_div, Nat.zero_add]

def words {values : Fin n → BitVec 32} (trace : WordArrayWrites.Trace 0 values)
    (memory : ByteMemory.Bytes) (base : Nat) (aligned : base%4=0) (bounded : base+4*n ≤ 2^64) :
    WordArrayWrites.Trace base values where
  before := memory
  aligned := aligned
  bounded := bounded
  schedule := trace.schedule.map (MemoryRegions.shift32 base)
  remaining := trace.remaining.map (List.map (MemoryRegions.shift32 base))
  execution := by rw [← word_programs]; exact map_execution _ trace.execution
  completed := map_barrier _ _ trace.completed

def halves {values : Fin n → BitVec 16} (trace : HalfArrayWrites.Trace 0 values)
    (memory : ByteMemory.Bytes) (base : Nat) (aligned : base%2=0) (bounded : base+2*n ≤ 2^64) :
    HalfArrayWrites.Trace base values where
  before := memory
  aligned := aligned
  bounded := bounded
  schedule := trace.schedule.map (MemoryRegions.shift16 base)
  remaining := trace.remaining.map (List.map (MemoryRegions.shift16 base))
  execution := by rw [← half_programs]; exact map_execution _ trace.execution
  completed := map_barrier _ _ trace.completed

theorem words_read {values : Fin n → BitVec 32} (trace : WordArrayWrites.Trace 0 values)
    (memory : ByteMemory.Bytes) (base : Nat) (aligned : base%4=0) (bounded : base+4*n ≤ 2^64) (i : Fin n) :
    ByteMemory.load32 (words trace memory base aligned bounded).memory (base+4*i.val)=ByteMemory.load32 trace.memory (4*i.val) := by
  rw [(words trace memory base aligned bounded).read_correct]
  simpa only [Nat.zero_add] using (trace.read_correct i).symm

theorem halves_read {values : Fin n → BitVec 16} (trace : HalfArrayWrites.Trace 0 values)
    (memory : ByteMemory.Bytes) (base : Nat) (aligned : base%2=0) (bounded : base+2*n ≤ 2^64) (i : Fin n) :
    HalfMemory.load (halves trace memory base aligned bounded).memory (base+2*i.val)=HalfMemory.load trace.memory (2*i.val) := by
  rw [(halves trace memory base aligned bounded).read_correct]
  simpa only [Nat.zero_add] using (trace.read_correct i).symm

theorem words_memory {values : Fin n → BitVec 32} (trace : WordArrayWrites.Trace 0 values)
    (memory : ByteMemory.Bytes) (base : Nat) (aligned : base%4=0) (bounded : base+4*n ≤ 2^64) :
    (words trace memory base aligned bounded).memory=ByteMemory.execute (trace.schedule.map (MemoryRegions.shift32 base)) memory := rfl

theorem halves_memory {values : Fin n → BitVec 16} (trace : HalfArrayWrites.Trace 0 values)
    (memory : ByteMemory.Bytes) (base : Nat) (aligned : base%2=0) (bounded : base+2*n ≤ 2^64) :
    (halves trace memory base aligned bounded).memory=HalfMemory.execute (trace.schedule.map (MemoryRegions.shift16 base)) memory := rfl

end Inference.Contracts.Mlx.ArrayRelocation
