import kernels.sampling.LogSumExpDevice
import contracts.mlx.ArrayFrame
import contracts.mlx.MemoryProjection

namespace Inference.Kernels.Sampling.LogSumExpMemory
open Contracts.Mlx
abbrev BF := ArrayStorage.BF
set_option maxRecDepth 10000
set_option maxHeartbeats 400000
variable {logits : Fin 248320 → BF}

-- Bounds are tested before the BF16 heap load. Padding lanes do not read
-- past the vocabulary allocation in the final loop iteration.
def capture (memory : ByteMemory.Bytes) (base : Nat) (iteration : Fin 61)
    (thread : Fin 1024) (read : Fin 4) : Float32 :=
  if LogSumExpLayout.offset iteration thread read<248320 then
    BFloat16.widen (FloatLib.Floats.Formats.BinaryInterchange.Model.ofBits
      (HalfMemory.load memory (base+2*LogSumExpLayout.offset iteration thread read)))
  else LogSumExpExponentRanges.negativeInfinity

theorem capture_source (source : ArrayStorage.BFBuffer logits) (iteration : Fin 61)
    (thread : Fin 1024) (read : Fin 4) :
    capture source.bytes source.base iteration thread read=
      LogSumExpLoopRanges.values (fun i => BFloat16.widen (logits i)) iteration thread read := by
  unfold capture LogSumExpLoopRanges.values
  split
  · rename_i inside
    change BFloat16.widen (source.read ⟨LogSumExpLayout.offset iteration thread read,inside⟩)=_
    rw [source.read_correct]
  · rfl

-- These stores inhabit threadgroup memory, not the global device heap.
-- Each SIMD group has one lane-zero writer; completion models each native
-- threadgroup barrier before the subsequent cross-SIMD reads.
def scratchTrace (base : Nat) (values : Fin 32 → Float32) (before : ByteMemory.Bytes)
    (aligned : base%4=0) (bounded : base+128≤2^64) : FloatArrayWrites.Trace base values :=
  ⟨before,aligned,bounded,(FloatArrayWrites.programs base values).flatten,
   List.replicate (FloatArrayWrites.programs base values).length [],
   ThreadgroupWrites.canonical _,ThreadgroupWrites.canonical_barrier _⟩

def scalarTrace (base : Nat) (value : BF) (before : ByteMemory.Bytes)
    (aligned : base%2=0) (bounded : base+2≤2^64) :
    HalfArrayWrites.Trace base (fun _ : Fin 1 => ArrayStorage.bits value) :=
  ⟨before,aligned,bounded,(HalfArrayWrites.programs base (fun _ : Fin 1 => ArrayStorage.bits value)).flatten,
   List.replicate (HalfArrayWrites.programs base (fun _ : Fin 1 => ArrayStorage.bits value)).length [],
   ThreadgroupWrites.canonical _,ThreadgroupWrites.canonical_barrier _⟩

def maximum (p : LogSumExpRanges.Platform) (source : ArrayStorage.BFBuffer logits)
    (maxima : FloatArrayWrites.Trace maxBase (fun group => (LogSumExpDevice.groups p source group).maximum)) : Float32 :=
  Maximum.tree maxima.buffer.read p.maximumTree

theorem maximum_eq (p : LogSumExpRanges.Platform) (source : ArrayStorage.BFBuffer logits)
    (maxima : FloatArrayWrites.Trace maxBase (fun group => (LogSumExpDevice.groups p source group).maximum)) :
    maximum p source maxima=LogSumExpMergeRanges.maximum (LogSumExpDevice.groups p source) p.maximumTree := by
  have read : maxima.buffer.read=(fun group => (LogSumExpDevice.groups p source group).maximum) := funext maxima.buffer.read_correct
  unfold maximum
  rw [read]
  rfl

@[irreducible] def adjusted (p : LogSumExpRanges.Platform) (source : ArrayStorage.BFBuffer logits)
    (maxima : FloatArrayWrites.Trace maxBase (fun group => (LogSumExpDevice.groups p source group).maximum)) (group : Fin 32) : Float32 :=
  FlushToZero.mul (LogSumExpDevice.groups p source group).normalizer
    (Attention.SdpaUpdate.exponential p.scalar (LogSumExpDevice.groups p source group).maximum (maximum p source maxima))

@[irreducible] def finish (p : LogSumExpRanges.Platform) (source : ArrayStorage.BFBuffer logits)
    (maxima : FloatArrayWrites.Trace maxBase (fun group => (LogSumExpDevice.groups p source group).maximum))
    (normalizers : FloatArrayWrites.Trace normBase (adjusted p source maxima)) : BF :=
  LogSumExpRanges.finish p ⟨maximum p source maxima,FlushedReduction.evaluate normalizers.buffer.read p.sumTree⟩

theorem finish_eq (p : LogSumExpRanges.Platform) (source : ArrayStorage.BFBuffer logits)
    (maxima : FloatArrayWrites.Trace maxBase (fun group => (LogSumExpDevice.groups p source group).maximum))
    (normalizers : FloatArrayWrites.Trace normBase (adjusted p source maxima)) :
    finish p source maxima normalizers=LogSumExpRanges.value p logits := by
  have read : normalizers.buffer.read=adjusted p source maxima := funext normalizers.buffer.read_correct
  have adjustedEq : adjusted p source maxima=(fun group => FlushToZero.mul (LogSumExpDevice.groups p source group).normalizer
      (Attention.SdpaUpdate.exponential p.scalar (LogSumExpDevice.groups p source group).maximum
        (LogSumExpMergeRanges.maximum (LogSumExpDevice.groups p source) p.maximumTree))) := by
    funext group
    unfold adjusted
    rw [maximum_eq]
  unfold finish
  rw [maximum_eq,read,adjustedEq,← LogSumExpMergeRanges.execution,LogSumExpDevice.groups_eq]
  rfl

structure Scratch (p : LogSumExpRanges.Platform) (source : ArrayStorage.BFBuffer logits) where
  maxBase : Nat
  normBase : Nat
  maxima : FloatArrayWrites.Trace maxBase (fun group => (LogSumExpDevice.groups p source group).maximum)
  normalizers : FloatArrayWrites.Trace normBase (adjusted p source maxima)
  afterMaxima : normalizers.before=maxima.memory
  separate : MemoryRegions.Disjoint normBase 128 maxBase 128

variable {p : LogSumExpRanges.Platform} {source : ArrayStorage.BFBuffer logits}

def Scratch.canonical (p : LogSumExpRanges.Platform) (source : ArrayStorage.BFBuffer logits)
    (localBefore : ByteMemory.Bytes) : Scratch p source :=
  let maxima := scratchTrace 0 (fun group => (LogSumExpDevice.groups p source group).maximum) localBefore (by decide) (by decide)
  ⟨0,128,maxima,scratchTrace 128 (adjusted p source maxima) maxima.memory (by decide) (by decide),rfl,Or.inr (by decide)⟩

theorem Scratch.maxima_during (scratch : Scratch p source) (stores : List ByteMemory.Store)
    (subset : ∀ store ∈ stores, store ∈ scratch.normalizers.schedule) (offset : Nat) (bound : offset<128) :
    ByteMemory.execute stores scratch.normalizers.before (scratch.maxBase+offset)=
      scratch.maxima.memory (scratch.maxBase+offset) := by
  rw [scratch.afterMaxima]
  apply MemoryRegions.execute32_other _ _ _ scratch.separate offset bound
  intro store present
  exact ArrayFrame.float_stores_inside scratch.normalizers store (subset store present)

def Scratch.maximaDuring (scratch : Scratch p source) (stores : List ByteMemory.Store)
    (subset : ∀ store ∈ stores, store ∈ scratch.normalizers.schedule) :
    ArrayStorage.FloatBuffer (fun group => (LogSumExpDevice.groups p source group).maximum) :=
  ArrayFrame.fp scratch.maxima.buffer (ByteMemory.execute stores scratch.normalizers.before)
    (scratch.maxima_during stores subset)

theorem Scratch.maximum_during (scratch : Scratch p source) (stores : List ByteMemory.Store)
    (subset : ∀ store ∈ stores, store ∈ scratch.normalizers.schedule) :
    Maximum.tree (scratch.maximaDuring stores subset).read p.maximumTree=maximum p source scratch.maxima := by
  have read : (scratch.maximaDuring stores subset).read=scratch.maxima.buffer.read := by
    funext group
    rw [ArrayStorage.FloatBuffer.read_correct,ArrayStorage.FloatBuffer.read_correct]
  rw [read]
  rfl

def Scratch.maximaAfter (scratch : Scratch p source) :
    ArrayStorage.FloatBuffer (fun group => (LogSumExpDevice.groups p source group).maximum) :=
  ArrayFrame.fp scratch.maxima.buffer scratch.normalizers.memory
    (scratch.maxima_during scratch.normalizers.schedule (fun _ member => member))

theorem Scratch.maximum_after (scratch : Scratch p source) :
    Maximum.tree scratch.maximaAfter.read p.maximumTree=maximum p source scratch.maxima := by
  have read : scratch.maximaAfter.read=scratch.maxima.buffer.read := by
    funext group
    rw [scratch.maximaAfter.read_correct,scratch.maxima.buffer.read_correct]
  rw [read]
  rfl

theorem Scratch.maxima_ownership (scratch : Scratch p source) :
    WriteOwnership.Separated MemoryCells.Store.word
      (FloatArrayWrites.programs scratch.maxBase (fun group => (LogSumExpDevice.groups p source group).maximum)) :=
  FloatArrayWrites.separated _ _

theorem Scratch.normalizer_ownership (scratch : Scratch p source) :
    WriteOwnership.Separated MemoryCells.Store.word (FloatArrayWrites.programs scratch.normBase (adjusted p source scratch.maxima)) :=
  FloatArrayWrites.separated _ _

-- Local scratch evolves independently. The single global output write
-- starts from the same heap containing the borrowed logits and is disjoint
-- from them so normalized-argmax can keep reading those logits afterward.
structure Execution (p : LogSumExpRanges.Platform) (source : ArrayStorage.BFBuffer logits) where
  scratch : Scratch p source
  destination : Nat
  output : HalfArrayWrites.Trace destination (fun _ : Fin 1 => ArrayStorage.bits (finish p source scratch.maxima scratch.normalizers))
  initial : output.before=source.bytes
  sourceSafe : MemoryRegions.Disjoint destination 2 source.base 496640

variable {execution : Execution p source}

def Execution.canonical (p : LogSumExpRanges.Platform) (source : ArrayStorage.BFBuffer logits)
    (localBefore : ByteMemory.Bytes) (destination : Nat) (aligned : destination%2=0)
    (bounded : destination+2≤2^64) (separate : MemoryRegions.Disjoint destination 2 source.base 496640) : Execution p source :=
  let scratch := Scratch.canonical p source localBefore
  ⟨scratch,destination,scalarTrace destination (finish p source scratch.maxima scratch.normalizers) source.bytes aligned bounded,rfl,separate⟩

def Execution.memory (execution : Execution p source) : ByteMemory.Bytes := execution.output.memory

theorem Execution.other_region (execution : Execution p source) {base size : Nat}
    (separate : MemoryRegions.Disjoint execution.destination 2 base size) (offset : Nat) (bound : offset<size) :
    execution.memory (base+offset)=source.bytes (base+offset) := by
  unfold Execution.memory HalfArrayWrites.Trace.memory
  rw [execution.initial]
  exact MemoryRegions.execute16_other _ _ (ArrayFrame.half_stores_inside execution.output) separate offset bound

theorem Execution.logits_during (execution : Execution p source) (stores : List HalfMemory.Store)
    (subset : ∀ store ∈ stores, store ∈ execution.output.schedule) (offset : Nat) (bound : offset<496640) :
    HalfMemory.execute stores source.bytes (source.base+offset)=source.bytes (source.base+offset) := by
  apply MemoryRegions.execute16_other _ _ _ execution.sourceSafe offset bound
  intro store present
  exact ArrayFrame.half_stores_inside execution.output store (subset store present)

def Execution.sourceDuring (execution : Execution p source) (stores : List HalfMemory.Store)
    (subset : ∀ store ∈ stores, store ∈ execution.output.schedule) : ArrayStorage.BFBuffer logits :=
  ArrayFrame.bf source (HalfMemory.execute stores source.bytes) (execution.logits_during stores subset)

theorem Execution.source_during (execution : Execution p source) (stores : List HalfMemory.Store)
    (subset : ∀ store ∈ stores, store ∈ execution.output.schedule) (i : Fin 248320) :
    (execution.sourceDuring stores subset).read i=logits i := ArrayStorage.BFBuffer.read_correct _ i

theorem Execution.capture_during (execution : Execution p source) (stores : List HalfMemory.Store)
    (subset : ∀ store ∈ stores, store ∈ execution.output.schedule) (iteration : Fin 61)
    (thread : Fin 1024) (read : Fin 4) :
    capture (HalfMemory.execute stores source.bytes) source.base iteration thread read=
      LogSumExpLoopRanges.values (fun i => BFloat16.widen (logits i)) iteration thread read :=
  capture_source (execution.sourceDuring stores subset) iteration thread read

theorem Execution.groups_during (execution : Execution p source) (stores : List HalfMemory.Store)
    (subset : ∀ store ∈ stores, store ∈ execution.output.schedule) :
    LogSumExpDevice.groups p (execution.sourceDuring stores subset)=LogSumExpDevice.groups p source := by
  rw [LogSumExpDevice.groups_eq,LogSumExpDevice.groups_eq]

def Execution.logitsAfter (execution : Execution p source) : ArrayStorage.BFBuffer logits :=
  ArrayFrame.bf source execution.memory (execution.other_region execution.sourceSafe)

def Execution.buffer (execution : Execution p source) : ArrayStorage.BFBuffer (fun _ : Fin 1 => LogSumExpRanges.value p logits) where
  bytes := execution.memory
  base := execution.destination
  aligned := execution.output.aligned
  bounded := execution.output.bounded
  attached := by
    intro i
    unfold Execution.memory
    rw [execution.output.read_correct,finish_eq]

theorem Execution.value_eq (execution : Execution p source) : execution.buffer.read 0=LogSumExpRanges.value p logits :=
  execution.buffer.read_correct 0

theorem Execution.shared (execution : Execution p source) :
    execution.logitsAfter.bytes=execution.memory ∧ execution.buffer.bytes=execution.memory := ⟨rfl,rfl⟩

def Execution.preserveBF {values : Fin n → BF} (execution : Execution p source) (buffer : ArrayStorage.BFBuffer values)
    (shared : buffer.bytes=source.bytes) (separate : MemoryRegions.Disjoint execution.destination 2 buffer.base (2*n)) : ArrayStorage.BFBuffer values :=
  ArrayFrame.bf buffer execution.memory (fun offset bound => (execution.other_region separate offset bound).trans (congrFun shared _).symm)

def Execution.preserveFloat {values : Fin n → Float32} (execution : Execution p source) (buffer : ArrayStorage.FloatBuffer values)
    (shared : buffer.bytes=source.bytes) (separate : MemoryRegions.Disjoint execution.destination 2 buffer.base (4*n)) : ArrayStorage.FloatBuffer values :=
  ArrayFrame.fp buffer execution.memory (fun offset bound => (execution.other_region separate offset bound).trans (congrFun shared _).symm)

end Inference.Kernels.Sampling.LogSumExpMemory
