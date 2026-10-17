import state.KvSlicePreparationMemory

-- updateAndFetch on null K/V installs the new zero slabs directly. Each
-- SliceUpdate then explicitly donates or preserves its input by a full copy,
-- followed by the row update. No empty-cache concatenation is executed.
namespace Inference.State.KvInitialPairMemory
open Contracts.Mlx KvBytes KvSlicePreparationMemory
set_option maxRecDepth 10000
attribute [local irreducible] CopyContiguous.programs Copy2DMemory.programs CopyExecution.Trace.memory

abbrev Zeros := fun _ : Fin (4*65536) => (0 : BitVec 16)

structure ZeroPair (layout : KvRegions.Layout 1) (before : ByteMemory.Bytes) where
  keys : CopyContiguous.Trace (blocks:=65536) layout.keyBase Zeros
  values : CopyContiguous.Trace (blocks:=65536) layout.valueBase Zeros
  initial : keys.before=before
  linked : values.before=keys.memory

private theorem canonical_before {blocks : Nat} (base : Nat) (values : Fin (4*blocks) → BitVec 16)
    (before : ByteMemory.Bytes) (aligned : base%2=0) :
    (CopyContiguous.Trace.canonical base values before aligned).before=before := rfl

variable {layout : KvRegions.Layout 1} {before : ByteMemory.Bytes}

def ZeroPair.canonical (layout : KvRegions.Layout 1) (before : ByteMemory.Bytes) : ZeroPair layout before :=
  let keys := CopyContiguous.Trace.canonical layout.keyBase Zeros before layout.keyAligned
  ⟨keys,CopyContiguous.Trace.canonical layout.valueBase Zeros keys.memory layout.valueAligned,
    canonical_before _ _ _ _,canonical_before _ _ _ _⟩

def ZeroPair.memory (zeros : ZeroPair layout before) : ByteMemory.Bytes := zeros.values.memory

theorem ZeroPair.keys_preserved (zeros : ZeroPair layout before) (offset : Nat) (bound : offset<bytes) :
    zeros.memory (layout.keyBase+offset)=zeros.keys.memory (layout.keyBase+offset) :=
  (trace_frame zeros.values (MemoryRegions.disjoint_symm layout.separate) offset bound).trans (congrFun zeros.linked _)

theorem ZeroPair.key_zero (zeros : ZeroPair layout before) (i : Fin words) :
    HalfMemory.load zeros.memory (layout.keyBase+2*i.val)=0 := by
  have same := ArrayFrame.half_congr zeros.keys.memory zeros.memory layout.keyBase bytes (2*i.val)
    zeros.keys_preserved (by have := i.isLt; unfold words bytes at *; omega)
  exact same.trans (zeros.keys.read_correct i)

theorem ZeroPair.value_zero (zeros : ZeroPair layout before) (i : Fin words) :
    HalfMemory.load zeros.memory (layout.valueBase+2*i.val)=0 := zeros.values.read_correct i

theorem ZeroPair.frame (zeros : ZeroPair layout before)
    (keySafe : MemoryRegions.Disjoint layout.keyBase bytes base size)
    (valueSafe : MemoryRegions.Disjoint layout.valueBase bytes base size) (offset : Nat) (bound : offset<size) :
    zeros.memory (base+offset)=before (base+offset) :=
  (trace_frame zeros.values valueSafe offset bound).trans ((congrFun zeros.linked _).trans
    ((trace_frame zeros.keys keySafe offset bound).trans (congrFun zeros.initial _)))

structure SourceSafe (layout : KvRegions.Layout 1) (source : KvCopy.Source row) : Prop where
  keys : MemoryRegions.Disjoint layout.keyBase bytes source.base (KvAppendMemory.sourceBytes source)
  values : MemoryRegions.Disjoint layout.valueBase bytes source.base (KvAppendMemory.sourceBytes source)

def ZeroPair.source (zeros : ZeroPair layout before) (source : KvCopy.Source row) (shared : source.bytes=before)
    (safe : SourceSafe layout source) : KvCopy.Source row :=
  KvAppendMemory.reframe source zeros.memory (fun offset bound =>
    (zeros.frame safe.keys safe.values offset bound).trans (congrFun shared _).symm)

-- This single-array execution consumes the exact current heap between the
-- two SliceUpdate calls, including an optional full preservation dispatch.
structure Slice (old : History 0) (next : Row) (before : ByteMemory.Bytes) (slab : Nat) where
  choice : Choice slab
  source : KvCopy.Source next
  shared : source.bytes=before
  safe : MemoryRegions.Disjoint choice.destination bytes source.base (KvAppendMemory.sourceBytes source)

variable {old : History 0} {next : Row} {slab : Nat}

def Slice.preservation (slice : Slice old next before slab) : Preparation before slab := slice.choice.prepare before

def Slice.input (slice : Slice old next before slab) : KvCopy.Source next :=
  KvAppendMemory.reframe slice.source slice.preservation.memory (fun offset bound =>
    (slice.preservation.frame (by unfold Slice.preservation; rw [Choice.destination_prepare]; exact slice.safe) offset bound).trans (congrFun slice.shared _).symm)

def Slice.appended (slice : Slice old next before slab) : KvAppendMemory.Execution old next :=
  KvAppendMemory.Execution.canonical old next slice.input slice.choice.destination 256 slice.choice.aligned (by decide) slice.safe
    (fun _ time _ => Fin.elim0 time)

theorem Slice.appended_base (slice : Slice old next before slab) : slice.appended.base=slice.choice.destination := rfl
theorem Slice.appended_capacity (slice : Slice old next before slab) : slice.appended.capacity=256 := rfl
theorem Slice.appended_before (slice : Slice old next before slab) : slice.appended.copy.before=slice.preservation.memory :=
  slice.appended.shared
attribute [local irreducible] Slice.appended

def Slice.memory (slice : Slice old next before slab) : ByteMemory.Bytes := slice.appended.copy.memory

private theorem append_read_at (execution : KvAppendMemory.Execution old next) (base : Nat)
    (baseEq : execution.base=base) (capacityEq : execution.capacity=256)
    (head : Fin 4) (time : Fin 1) (i : Fin 256) :
    HalfMemory.load execution.copy.memory (base+2*Kv.address 256 head time.val i)=
      bits (Kv.appendRows (fun t => old head t i) (next head i) time) := by
  have address := congrArg₂ (fun b c => b+2*Kv.address c head time.val i) baseEq capacityEq
  exact (congrArg (HalfMemory.load execution.copy.memory) address).symm.trans (execution.load_correct head time i)

theorem Slice.read (slice : Slice old next before slab) (head : Fin 4) (time : Fin 1) (i : Fin 256) :
    HalfMemory.load slice.memory (slice.choice.destination+2*Kv.address 256 head time.val i)=
      bits (Kv.appendRows (fun t => old head t i) (next head i) time) :=
  append_read_at slice.appended _ slice.appended_base slice.appended_capacity head time i

theorem Slice.frame (slice : Slice old next before slab)
    (safe : MemoryRegions.Disjoint slice.choice.destination bytes base size) (offset : Nat) (bound : offset<size) :
    slice.memory (base+offset)=before (base+offset) :=
  (slice.appended.other_region (by rw [slice.appended_base,slice.appended_capacity]; exact safe) offset bound).trans
    ((congrFun slice.appended_before _).trans
      (slice.preservation.frame (by unfold Slice.preservation; rw [Choice.destination_prepare]; exact safe) offset bound))

structure Allocation (layout : KvRegions.Layout 1) (keySource : KvCopy.Source key) (valueSource : KvCopy.Source value) where
  keySourceBound : keySource.base+KvAppendMemory.sourceBytes keySource≤2^64
  valueSourceBound : valueSource.base+KvAppendMemory.sourceBytes valueSource≤2^64
  keyChoice : Choice layout.keyBase
  valueChoice : Choice layout.valueBase
  keyZerosSafe : SourceSafe layout keySource
  valueZerosSafe : SourceSafe layout valueSource
  keySafe : MemoryRegions.Disjoint keyChoice.destination bytes keySource.base (KvAppendMemory.sourceBytes keySource)
  valueSafe : MemoryRegions.Disjoint valueChoice.destination bytes valueSource.base (KvAppendMemory.sourceBytes valueSource)
  keyKeepsValueSource : MemoryRegions.Disjoint keyChoice.destination bytes valueSource.base (KvAppendMemory.sourceBytes valueSource)
  keyKeepsZeroValues : MemoryRegions.Disjoint keyChoice.destination bytes layout.valueBase bytes
  separate : MemoryRegions.Disjoint keyChoice.destination bytes valueChoice.destination bytes

variable {cache : Kv.Cache BF 0} {key value : Row} {keySource : KvCopy.Source key} {valueSource : KvCopy.Source value}
  (zeros : ZeroPair layout before) (allocation : Allocation layout keySource valueSource)
  (keyShared : keySource.bytes=before) (valueShared : valueSource.bytes=before)

def keys : Slice cache.keys key zeros.memory layout.keyBase where
  choice := allocation.keyChoice
  source := zeros.source keySource keyShared allocation.keyZerosSafe
  shared := rfl
  safe := allocation.keySafe

def valueInput : KvCopy.Source value :=
  let input := zeros.source valueSource valueShared allocation.valueZerosSafe
  KvAppendMemory.reframe input (keys (cache:=cache) zeros allocation keyShared).memory
    (fun offset bound => (keys (cache:=cache) zeros allocation keyShared).frame allocation.keyKeepsValueSource offset bound)

def values : Slice cache.values value (keys (cache:=cache) zeros allocation keyShared).memory layout.valueBase where
  choice := allocation.valueChoice
  source := valueInput (cache:=cache) zeros allocation keyShared valueShared
  shared := rfl
  safe := allocation.valueSafe

def memory : ByteMemory.Bytes := (values (cache:=cache) zeros allocation keyShared valueShared).memory

theorem keys_preserved (offset : Nat) (bound : offset<bytes) :
    memory (cache:=cache) zeros allocation keyShared valueShared (allocation.keyChoice.destination+offset)=
      (keys (cache:=cache) zeros allocation keyShared).memory (allocation.keyChoice.destination+offset) :=
  (values (cache:=cache) zeros allocation keyShared valueShared).frame (MemoryRegions.disjoint_symm allocation.separate) offset bound

def outputLayout : KvRegions.Layout 1 where
  keyBase := allocation.keyChoice.destination
  valueBase := allocation.valueChoice.destination
  keyAligned := allocation.keyChoice.aligned
  valueAligned := allocation.valueChoice.aligned
  keyBound := allocation.keyChoice.bounded
  valueBound := allocation.valueChoice.bounded
  separate := allocation.separate

def after : KvRegions.Storage (Kv.append cache key value) where
  layout := outputLayout allocation
  memory := memory (cache:=cache) zeros allocation keyShared valueShared
  keys := by
    intro head time i
    have same := ArrayFrame.half_congr (keys (cache:=cache) zeros allocation keyShared).memory (memory (cache:=cache) zeros allocation keyShared valueShared)
      allocation.keyChoice.destination bytes (2*Kv.address 256 head time.val i)
      (keys_preserved (cache:=cache) zeros allocation keyShared valueShared) (by
        have := KvRegions.active_bounds (n:=1) head time i
        exact this)
    change HalfMemory.load (memory (cache:=cache) zeros allocation keyShared valueShared)
      (allocation.keyChoice.destination+2*Kv.address 256 head time.val i)=_
    rw [same]
    exact (keys (cache:=cache) zeros allocation keyShared).read head time i
  values := by
    intro head time i
    exact (values (cache:=cache) zeros allocation keyShared valueShared).read head time i

structure Safe (layout : KvRegions.Layout 1) (allocation : Allocation layout keySource valueSource) (base size : Nat) : Prop where
  keyZero : MemoryRegions.Disjoint layout.keyBase bytes base size
  valueZero : MemoryRegions.Disjoint layout.valueBase bytes base size
  keyOutput : MemoryRegions.Disjoint allocation.keyChoice.destination bytes base size
  valueOutput : MemoryRegions.Disjoint allocation.valueChoice.destination bytes base size

theorem other_region (safe : Safe layout allocation base size) (offset : Nat) (bound : offset<size) :
    (after (cache:=cache) zeros allocation keyShared valueShared).memory (base+offset)=before (base+offset) :=
  ((values (cache:=cache) zeros allocation keyShared valueShared).frame safe.valueOutput offset bound).trans
    (((keys (cache:=cache) zeros allocation keyShared).frame safe.keyOutput offset bound).trans
      (zeros.frame safe.keyZero safe.valueZero offset bound))

theorem key_prepared_zero (i : Fin words) :
    HalfMemory.load (keys (cache:=cache) zeros allocation keyShared).preservation.memory
      ((keys (cache:=cache) zeros allocation keyShared).preservation.destination+2*i.val)=0 :=
  ((keys (cache:=cache) zeros allocation keyShared).preservation.read i).trans (zeros.key_zero i)

theorem value_zero_before_preserve (i : Fin words) :
    HalfMemory.load (keys (cache:=cache) zeros allocation keyShared).memory (layout.valueBase+2*i.val)=0 := by
  have same := ArrayFrame.half_congr zeros.memory (keys (cache:=cache) zeros allocation keyShared).memory
    layout.valueBase bytes (2*i.val)
    ((keys (cache:=cache) zeros allocation keyShared).frame allocation.keyKeepsZeroValues)
    (by have := i.isLt; unfold words bytes at *; omega)
  exact same.trans (zeros.value_zero i)

theorem value_prepared_zero (i : Fin words) :
    HalfMemory.load (values (cache:=cache) zeros allocation keyShared valueShared).preservation.memory
      ((values (cache:=cache) zeros allocation keyShared valueShared).preservation.destination+2*i.val)=0 :=
  ((values (cache:=cache) zeros allocation keyShared valueShared).preservation.read i).trans
    (value_zero_before_preserve (cache:=cache) zeros allocation keyShared i)


-- Raw routes, addresses and source attachments construct the execution;
-- neither the cache contents nor a final-heap equality is an input.
structure Execution (cache : Kv.Cache BF 0) (key value : Row) where
  before : ByteMemory.Bytes
  layout : KvRegions.Layout 1
  zeros : ZeroPair layout before
  keySource : KvCopy.Source key
  valueSource : KvCopy.Source value
  keyShared : keySource.bytes=before
  valueShared : valueSource.bytes=before
  allocation : Allocation layout keySource valueSource

def fromSources (before : ByteMemory.Bytes) (layout : KvRegions.Layout 1)
    (keySource : KvCopy.Source key) (valueSource : KvCopy.Source value)
    (keyShared : keySource.bytes=before) (valueShared : valueSource.bytes=before)
    (allocation : Allocation layout keySource valueSource) : Execution cache key value :=
  ⟨before,layout,ZeroPair.canonical layout before,keySource,valueSource,keyShared,valueShared,allocation⟩

def Execution.after (execution : Execution cache key value) : KvRegions.Storage (Kv.append cache key value) :=
  KvInitialPairMemory.after execution.zeros execution.allocation execution.keyShared execution.valueShared

def Execution.Safe (execution : Execution cache key value) (base size : Nat) : Prop :=
  KvInitialPairMemory.Safe execution.layout execution.allocation base size

theorem Execution.other_region (execution : Execution cache key value) (safe : execution.Safe base size)
    (offset : Nat) (bound : offset<size) : execution.after.memory (base+offset)=execution.before (base+offset) :=
  KvInitialPairMemory.other_region execution.zeros execution.allocation execution.keyShared execution.valueShared safe offset bound

theorem Execution.key_read (execution : Execution cache key value) (head : Fin 4) (time : Fin 1) (i : Fin 256) :
    HalfMemory.load execution.after.memory (execution.after.layout.keyBase+2*Kv.address 256 head time.val i)=
      bits ((Kv.append cache key value).keys head time i) := execution.after.keys head time i

theorem Execution.value_read (execution : Execution cache key value) (head : Fin 4) (time : Fin 1) (i : Fin 256) :
    HalfMemory.load execution.after.memory (execution.after.layout.valueBase+2*Kv.address 256 head time.val i)=
      bits ((Kv.append cache key value).values head time i) := execution.after.values head time i

def Execution.sourceAfter (execution : Execution cache key value) (source : KvCopy.Source row)
    (shared : source.bytes=execution.before) (safe : execution.Safe source.base (KvAppendMemory.sourceBytes source)) : KvCopy.Source row :=
  KvAppendMemory.reframe source execution.after.memory (fun offset bound =>
    (execution.other_region safe offset bound).trans (congrFun shared _).symm)

def Execution.bufferAfter {values : Fin count → ArrayStorage.BF} (execution : Execution cache key value)
    (buffer : ArrayStorage.BFBuffer values) (shared : buffer.bytes=execution.before)
    (safe : execution.Safe buffer.base (2*count)) : ArrayStorage.BFBuffer values :=
  ArrayFrame.bf buffer execution.after.memory (fun offset bound =>
    (execution.other_region safe offset bound).trans (congrFun shared _).symm)

theorem Execution.bufferAfter_shared {values : Fin count → ArrayStorage.BF} (execution : Execution cache key value)
    (buffer : ArrayStorage.BFBuffer values) (shared : buffer.bytes=execution.before)
    (safe : execution.Safe buffer.base (2*count)) : (execution.bufferAfter buffer shared safe).bytes=execution.after.memory := rfl

end Inference.State.KvInitialPairMemory
