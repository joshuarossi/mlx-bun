import state.KvCopy
import state.KvConcat
import contracts.mlx.CopyContiguous
import contracts.mlx.CopyIndices

namespace Inference.State.KvDevice
open Contracts.Mlx KvBytes
set_option maxRecDepth 10000

abbrev ZeroFill := CopyContiguous.Trace (blocks := 65536) 0 (fun _ => (0 : BitVec 16))

theorem zero_read (fill : ZeroFill) (capacity : Nat) (label : Copy2D.Label 4 (256*256)) :
    HalfMemory.load fill.memory (Copy2D.sourceAddress (KvConcat.newLayout capacity) label)=0 := by
  let i : Fin (4*65536) := ⟨label.2.val+label.1.val*65536, by have := label.1.isLt; have := label.2.isLt; omega⟩
  simpa only [Copy2D.sourceAddress, KvConcat.newLayout, Nat.mul_one, Nat.zero_add, i] using fill.read_correct i

theorem extension_programs (fill : ZeroFill) (capacity : Nat) :
    Copy2D.programs (KvConcat.newLayout capacity) fill.memory 4 (256*256)=
      Copy2D.programs (KvConcat.newLayout capacity) KvConcat.zeros 4 (256*256) := by
  unfold Copy2D.programs
  apply congrArg (fun f => (Copy2D.labels 4 (256*256)).map f)
  funext label
  have encoded : HalfMemory.load KvConcat.zeros (Copy2D.sourceAddress (KvConcat.newLayout capacity) label)=0 := by
    dsimp [KvConcat.zeros, Copy2D.sourceAddress, KvConcat.newLayout]
    rw [HalfMemory.load_encode _ _ (by omega)]
  simp only [Copy2D.entry, zero_read fill capacity label, encoded]

def growthPrograms (capacity : Nat) (source : HalfMemory.Bytes) (fill : ZeroFill) : List (List HalfMemory.Store) :=
  Copy2D.programs (KvConcat.oldLayout capacity) source 4 (capacity*256) ++
    Copy2D.programs (KvConcat.newLayout capacity) fill.memory 4 (256*256)

theorem growth_programs_eq (capacity : Nat) (source : HalfMemory.Bytes) (fill : ZeroFill) :
    growthPrograms capacity source fill=KvConcat.programs capacity source := by
  unfold growthPrograms
  rw [extension_programs]
  rfl

theorem growth_separated (capacity : Nat) (source : HalfMemory.Bytes) (fill : ZeroFill) :
    WriteOwnership.Separated MemoryCells.Store.word (growthPrograms capacity source fill) := by
  rw [growth_programs_eq]
  exact KvConcat.separated capacity source

structure GrowthTrace (capacity : Nat) (source : HalfMemory.Bytes) where
  fill : ZeroFill
  before : HalfMemory.Bytes
  schedule : List HalfMemory.Store
  remaining : List (List HalfMemory.Store)
  execution : ThreadgroupWrites.Executes (growthPrograms capacity source fill) schedule remaining
  completed : ThreadgroupWrites.AtBarrier remaining

def GrowthTrace.canonical (capacity : Nat) (source : HalfMemory.Bytes) : GrowthTrace capacity source :=
  let fill : ZeroFill := CopyContiguous.Trace.canonical 0 _ (fun _ => 0) (by decide)
  let stores := growthPrograms capacity source fill
  ⟨fill, (fun _ => 0), stores.flatten, List.replicate stores.length [],
    ThreadgroupWrites.canonical stores, ThreadgroupWrites.canonical_barrier stores⟩

def GrowthTrace.toConcat (trace : GrowthTrace capacity source) : KvConcat.Trace capacity source where
  before := trace.before
  schedule := trace.schedule
  remaining := trace.remaining
  execution := by
    rw [← growth_programs_eq capacity source trace.fill]
    exact trace.execution
  completed := trace.completed

def GrowthTrace.memory (trace : GrowthTrace capacity source) : HalfMemory.Bytes :=
  if capacity=0 then trace.fill.memory else trace.toConcat.memory

theorem GrowthTrace.preserves (trace : GrowthTrace capacity source) (head : Fin 4) (time : Fin capacity) (i : Fin 256) :
    HalfMemory.load trace.memory (2*Kv.address (capacity+256) head time.val i)=
      HalfMemory.load source (2*Kv.address capacity head time.val i) := by
  by_cases empty : capacity=0
  · subst capacity
    exact Fin.elim0 time
  · simpa only [GrowthTrace.memory, ite_eq_right empty] using trace.toConcat.preserves head time i

theorem GrowthTrace.extension_zero (trace : GrowthTrace capacity source) (head : Fin 4) (time : Fin 256) (i : Fin 256) :
    HalfMemory.load trace.memory (2*Kv.address (capacity+256) head (capacity+time.val) i)=0 := by
  by_cases empty : capacity=0
  · subst capacity
    let word : Fin (4*65536) := ⟨Kv.address 256 head time.val i, by
      have := Kv.address_bounds 256 head time.val i time.isLt
      omega⟩
    simpa only [GrowthTrace.memory, ite_true, Nat.zero_add, word] using trace.fill.read_correct word
  · simpa only [GrowthTrace.memory, ite_eq_right empty] using trace.toConcat.extension_zero head time i

-- set_copy_output_data either donates the same-dtype allocation or creates
-- a vector copy. Both choices preserve its words, including inactive padding.
inductive Preserve (source : HalfMemory.Bytes) (blocks : Nat) where
  | donated
  | copied (trace : CopyContiguous.Trace (blocks := blocks) 0 (CopyContiguous.vectorValues source 0))

def Preserve.memory : Preserve source blocks → HalfMemory.Bytes
  | .donated => source
  | .copied trace => trace.memory

theorem Preserve.read_correct (trace : Preserve source blocks) (i : Fin (4*blocks)) :
    HalfMemory.load trace.memory (2*i.val)=HalfMemory.load source (2*i.val) := by
  cases trace with
  | donated => rfl
  | copied trace => simpa only [Preserve.memory, Nat.zero_add] using CopyContiguous.vector_read source 0 trace i

def prepared (n : Nat) (before : HalfMemory.Bytes)
    (growth : KvAllocation.capacity n<n+1 → GrowthTrace (KvAllocation.capacity n) before) : HalfMemory.Bytes :=
  if h : KvAllocation.capacity n<n+1 then (growth h).memory else before

theorem prepared_attached (old : History n) (before : HalfMemory.Bytes) (attached : KvAllocation.Attached before old)
    (growth : KvAllocation.capacity n<n+1 → GrowthTrace (KvAllocation.capacity n) before)
    (head : Fin 4) (time : Fin n) (i : Fin 256) :
    HalfMemory.load (prepared n before growth) (2*Kv.address (KvAllocation.capacity (n+1)) head time.val i)=bits (old head time i) := by
  unfold prepared
  by_cases h : KvAllocation.capacity n<n+1
  · rw [dite_eq_left h, KvAllocation.next_capacity, ite_eq_left h]
    rw [(growth h).preserves head ⟨time.val, time.isLt.trans_le (KvAllocation.capacity_bounds n).1⟩ i]
    exact attached head time i
  · rw [dite_eq_right h, KvAllocation.next_capacity, ite_eq_right h]
    exact attached head time i

structure AppendExecution (old : History n) (before : HalfMemory.Bytes) (next : Row) where
  source : KvCopy.Source next
  growth : KvAllocation.capacity n<n+1 → GrowthTrace (KvAllocation.capacity n) before
  preserve : Preserve (prepared n before growth) (KvAllocation.capacity (n+1)*256)
  copy : Copy2D.Trace (KvCopy.layout source 0 (KvAllocation.capacity (n+1)) n) source.bytes 4 256
  copyBefore : copy.before=preserve.memory

def AppendExecution.canonical (old : History n) (before : HalfMemory.Bytes) (next : Row) : AppendExecution old before next :=
  let source := KvCopy.Source.canonical next
  let growth := fun (_ : KvAllocation.capacity n<n+1) => GrowthTrace.canonical (KvAllocation.capacity n) before
  let preserve : Preserve (prepared n before growth) (KvAllocation.capacity (n+1)*256) := .donated
  ⟨source, growth, preserve,
    KvCopy.canonicalCopy source 0 (KvAllocation.capacity (n+1)) n preserve.memory (by decide)
      (Nat.lt_of_lt_of_le (Nat.lt_succ_self n) (KvAllocation.capacity_bounds (n+1)).1), rfl⟩

variable {n : Nat} {old : History n} {before : HalfMemory.Bytes} {next : Row}

def AppendExecution.toTrace (execution : AppendExecution old before next) (attached : KvAllocation.Attached before old) : KvBytes.Trace old next :=
  KvCopy.fromCopy execution.source 0 (KvAllocation.capacity (n+1)) old
    (Nat.lt_of_lt_of_le (Nat.lt_succ_self n) (KvAllocation.capacity_bounds (n+1)).1) (by decide) execution.copy
    (by
      intro head time i
      rw [execution.copyBefore]
      have room : time.val<KvAllocation.capacity (n+1) := by
        have := (KvAllocation.capacity_bounds (n+1)).1
        omega
      let word : Fin (4*(KvAllocation.capacity (n+1)*256)) :=
        ⟨Kv.address (KvAllocation.capacity (n+1)) head time.val i, by
          have := Kv.address_bounds (KvAllocation.capacity (n+1)) head time.val i room
          simpa only [Nat.mul_assoc] using this⟩
      simpa only [Nat.zero_add, word, execution.preserve.read_correct word] using
        prepared_attached old before attached execution.growth head time i)

theorem AppendExecution.read_correct (execution : AppendExecution old before next) (attached : KvAllocation.Attached before old)
    (head : Fin 4) (time : Fin (n+1)) (i : Fin 256) :
    (execution.toTrace attached).read head time i=Kv.appendRows (fun t => old head t i) (next head i) time :=
  KvBytes.Trace.read_correct _ head time i

theorem AppendExecution.capacity_eq (execution : AppendExecution old before next) (attached : KvAllocation.Attached before old) :
    (execution.toTrace attached).capacity=KvAllocation.capacity (n+1) := rfl

theorem AppendExecution.base_eq (execution : AppendExecution old before next) (attached : KvAllocation.Attached before old) :
    (execution.toTrace attached).base=0 := rfl

theorem AppendExecution.attached_after (execution : AppendExecution old before next) (attached : KvAllocation.Attached before old)
    (head : Fin 4) (time : Fin (n+1)) (i : Fin 256) :
    HalfMemory.load (execution.toTrace attached).memory (2*Kv.address (KvAllocation.capacity (n+1)) head time.val i)=
      bits (Kv.appendRows (fun t => old head t i) (next head i) time) := by
  simpa only [AppendExecution.capacity_eq, AppendExecution.base_eq, Nat.zero_add] using
    (execution.toTrace attached).load_correct head time i

structure Execution {cache : Kv.Cache BF n} (storage : KvAllocation.Storage cache) (key value : Row) where
  keys : AppendExecution cache.keys storage.keys key
  values : AppendExecution cache.values storage.values value

def Execution.canonical {cache : Kv.Cache BF n} (storage : KvAllocation.Storage cache) (key value : Row) : Execution storage key value :=
  ⟨AppendExecution.canonical _ _ _, AppendExecution.canonical _ _ _⟩

variable {cache : Kv.Cache BF n} {storage : KvAllocation.Storage cache} {key value : Row}

def Execution.toKvBytes (execution : Execution storage key value) : KvBytes.Execution cache key value :=
  ⟨execution.keys.toTrace storage.keysAttached, execution.values.toTrace storage.valuesAttached⟩

def Execution.after (execution : Execution storage key value) : KvAllocation.Storage (Kv.append cache key value) where
  keys := (execution.toKvBytes).keys.memory
  values := (execution.toKvBytes).values.memory
  keysAttached := by
    intro head time i
    simpa only [Execution.toKvBytes, Kv.append] using execution.keys.attached_after storage.keysAttached head time i
  valuesAttached := by
    intro head time i
    simpa only [Execution.toKvBytes, Kv.append] using execution.values.attached_after storage.valuesAttached head time i

theorem Execution.cache_eq (execution : Execution storage key value) :
    KvBytes.cacheAfter execution.toKvBytes=Kv.append cache key value := KvBytes.cacheAfter_eq _

theorem Execution.next_keys (execution : Execution storage key value) :
    execution.after.keys=(execution.toKvBytes).keys.memory := rfl

theorem Execution.next_values (execution : Execution storage key value) :
    execution.after.values=(execution.toKvBytes).values.memory := rfl

-- Supported KV allocations select four-word scalar/vector copies, fit the
-- signed 32-bit GeneralGeneral index specialization, and have no tail.
theorem allocation_geometry (n : Nat) (supported : n+1 ≤ 262144) :
    let capacity := KvAllocation.capacity (n+1)
    256 ≤ capacity ∧ capacity ≤ 262144 ∧ 65536 ≤ 4*capacity*256 ∧
      4*capacity*256<2^31 ∧ (4*capacity*256)%4=0 ∧ (4*capacity*256+3)/4=capacity*256 := by
  have bound := KvAllocation.supported_capacity (n+1) supported
  have lower := (KvAllocation.capacity_bounds (n+1)).1
  have multiple := KvAllocation.capacity_multiple (n+1)
  dsimp only
  omega

theorem append_layout (n : Nat) (sourceBatch sourceHead sourceTime sourceCoordinate : Nat) :
    let capacity := KvAllocation.capacity (n+1)
    CopyShape.collapse (2^31-1) [⟨1, sourceBatch, 4*capacity*256⟩, ⟨4, sourceHead, capacity*256⟩,
      ⟨1, sourceTime, 256⟩, ⟨256, sourceCoordinate, 1⟩]=
      [⟨4, sourceHead, capacity*256⟩, ⟨256, sourceCoordinate, 1⟩] := by
  have lower := (KvAllocation.capacity_bounds (n+1)).1
  have multiple := KvAllocation.capacity_multiple (n+1)
  exact CopyShape.append_axes _ (by omega) _ _ _ _

theorem growth_old_layout (n : Nat) (positive : 0<KvAllocation.capacity n) (supported : n ≤ 262144) :
    let capacity := KvAllocation.capacity n
    CopyShape.collapse (2^31-1) [⟨1, 4*capacity*256, 4*(capacity+256)*256⟩, ⟨4, capacity*256, (capacity+256)*256⟩,
      ⟨capacity, 256, 256⟩, ⟨256, 1, 1⟩]=
      [⟨4, capacity*256, (capacity+256)*256⟩, ⟨capacity*256, 1, 1⟩] :=
  CopyShape.concat_axes _ _ positive (by omega) (KvAllocation.supported_capacity n supported)

theorem growth_extension_layout (capacity : Nat) (positive : 0<capacity) :
    CopyShape.collapse (2^31-1) [⟨1, 4*256*256, 4*(capacity+256)*256⟩, ⟨4, 256*256, (capacity+256)*256⟩,
      ⟨256, 256, 256⟩, ⟨256, 1, 1⟩]=
      [⟨4, 256*256, (capacity+256)*256⟩, ⟨256*256, 1, 1⟩] :=
  CopyShape.concat_axes _ _ (by decide) (by omega) (by decide)

theorem signed_index (capacity : Nat) (supported : capacity ≤ 262144)
    (label : Copy2D.Label 4 (capacity*256)) :
    (CopyIndices.elem2 label.2.val label.1.val 1 (capacity*256)).toInt=
      Int.ofNat (label.2.val+label.1.val*(capacity*256)) := by
  have headBound : label.1.val ≤ 3 := by have := label.1.isLt; omega
  have rowBound := Nat.mul_le_mul_right (capacity*256) headBound
  have columnBound := label.2.isLt
  have bounded : label.2.val*1+label.1.val*(capacity*256)<2^31 := by omega
  simpa only [Nat.mul_one] using CopyIndices.elem2_signed label.2.val label.1.val 1 (capacity*256)
    (by omega) (by omega) (by decide) (by omega) bounded

end Inference.State.KvDevice
