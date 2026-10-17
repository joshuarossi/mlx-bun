import layers.QuantizedEmbeddingDevice
import state.TokenStorage
import contracts.mlx.ArrayFrame

namespace Inference.Layers.QuantizedEmbeddingMemory
open Contracts.Mlx Kernels.Quantization
open FloatLib FloatLib.Floats FloatLib.Floats.Formats.BinaryInterchange

abbrev BF := ArrayStorage.BF
set_option maxRecDepth 100000
set_option maxHeartbeats 2000000

structure Regions where
  packed : Nat
  scales : Nat
  biases : Nat
  output : Nat

def Regions.Live (r : Regions) (base size : Nat) : Prop :=
  MemoryRegions.Disjoint r.packed 2560 base size ∧ MemoryRegions.Disjoint r.scales 160 base size ∧
  MemoryRegions.Disjoint r.biases 160 base size ∧ MemoryRegions.Disjoint r.output 10240 base size

structure Shared (storage : QuantizedEmbeddingDevice.Storage layer) (tokenBuffer : State.TokenStorage.Buffer token) : Prop where
  packed : storage.packed=tokenBuffer.bytes
  scales : storage.scales.bytes=tokenBuffer.bytes
  biases : storage.biases.bytes=tokenBuffer.bytes

structure Allocation (storage : QuantizedEmbeddingDevice.Storage layer) (tokenBuffer : State.TokenStorage.Buffer token) (r : Regions) : Prop where
  packedAligned : r.packed%4=0
  scalesAligned : r.scales%2=0
  biasesAligned : r.biases%2=0
  outputAligned : r.output%2=0
  packedBounded : r.packed+2560 ≤ 2^64
  scalesBounded : r.scales+160 ≤ 2^64
  biasesBounded : r.biases+160 ≤ 2^64
  outputBounded : r.output+10240 ≤ 2^64
  packedLive : r.Live storage.packedBase (4*(248320*640))
  scalesLive : r.Live storage.scales.base (2*(248320*80))
  biasesLive : r.Live storage.biases.base (2*(248320*80))
  tokenLive : r.Live tokenBuffer.base 4
  scalesPacked : MemoryRegions.Disjoint r.scales 160 r.packed 2560
  biasesPacked : MemoryRegions.Disjoint r.biases 160 r.packed 2560
  biasesScales : MemoryRegions.Disjoint r.biases 160 r.scales 160
  outputPacked : MemoryRegions.Disjoint r.output 10240 r.packed 2560
  outputScales : MemoryRegions.Disjoint r.output 10240 r.scales 160
  outputBiases : MemoryRegions.Disjoint r.output 10240 r.biases 160

structure Prefix (r : Regions) (initial : ByteMemory.Bytes) where
  memory : ByteMemory.Bytes
  same : ∀ base size, r.Live base size → ∀ offset < size, memory (base+offset)=initial (base+offset)

def Prefix.initial (r : Regions) (memory : ByteMemory.Bytes) : Prefix r memory := ⟨memory,fun _ _ _ _ _ => rfl⟩

def wordTrace (before : ByteMemory.Bytes) (base : Nat) (values : Fin n → BitVec 32)
    (aligned : base%4=0) (bounded : base+4*n ≤ 2^64) : WordArrayWrites.Trace base values :=
  let programs := WordArrayWrites.programs base values
  ⟨before,aligned,bounded,programs.flatten,List.replicate programs.length [],
    ThreadgroupWrites.canonical programs,ThreadgroupWrites.canonical_barrier programs⟩

def halfTrace (before : ByteMemory.Bytes) (base : Nat) (values : Fin n → BitVec 16)
    (aligned : base%2=0) (bounded : base+2*n ≤ 2^64) : HalfArrayWrites.Trace base values :=
  let programs := HalfArrayWrites.programs base values
  ⟨before,aligned,bounded,programs.flatten,List.replicate programs.length [],
    ThreadgroupWrites.canonical programs,ThreadgroupWrites.canonical_barrier programs⟩

def Prefix.afterWord (heap : Prefix r beforeMemory) (base : Nat) (values : Fin n → BitVec 32)
    (aligned : base%4=0) (bounded : base+4*n ≤ 2^64)
    (live : ∀ b s, r.Live b s → MemoryRegions.Disjoint base (4*n) b s) : Prefix r beforeMemory :=
  let trace := wordTrace heap.memory base values aligned bounded
  ⟨trace.memory,fun b s h offset bound =>
    (MemoryRegions.execute32_other trace.schedule heap.memory (ArrayFrame.word_stores_inside trace) (live b s h) offset bound).trans
      (heap.same b s h offset bound)⟩

def Prefix.afterHalf (heap : Prefix r beforeMemory) (base : Nat) (values : Fin n → BitVec 16)
    (aligned : base%2=0) (bounded : base+2*n ≤ 2^64)
    (live : ∀ b s, r.Live b s → MemoryRegions.Disjoint base (2*n) b s) : Prefix r beforeMemory :=
  let trace := halfTrace heap.memory base values aligned bounded
  ⟨trace.memory,fun b s h offset bound =>
    (MemoryRegions.execute16_other trace.schedule heap.memory (ArrayFrame.half_stores_inside trace) (live b s h) offset bound).trans
      (heap.same b s h offset bound)⟩

theorem wordTrace_frame (before : ByteMemory.Bytes) (base : Nat) (values : Fin n → BitVec 32)
    (aligned : base%4=0) (bounded : base+4*n ≤ 2^64)
    (safe : MemoryRegions.Disjoint base (4*n) other size) (offset : Nat) (bound : offset<size) :
    (wordTrace before base values aligned bounded).memory (other+offset)=before (other+offset) :=
  MemoryRegions.execute32_other _ before (ArrayFrame.word_stores_inside _) safe offset bound

theorem halfTrace_frame (before : ByteMemory.Bytes) (base : Nat) (values : Fin n → BitVec 16)
    (aligned : base%2=0) (bounded : base+2*n ≤ 2^64)
    (safe : MemoryRegions.Disjoint base (2*n) other size) (offset : Nat) (bound : offset<size) :
    (halfTrace before base values aligned bounded).memory (other+offset)=before (other+offset) :=
  MemoryRegions.execute16_other _ before (ArrayFrame.half_stores_inside _) safe offset bound

attribute [local irreducible] wordTrace halfTrace

structure Execution (layer : QuantizedEmbedding.Layer) (token : Fin 248320) where
  storage : QuantizedEmbeddingDevice.Storage layer
  tokenBuffer : State.TokenStorage.Buffer token
  shared : Shared storage tokenBuffer
  regions : Regions
  allocation : Allocation storage tokenBuffer regions

def fromStorage (storage : QuantizedEmbeddingDevice.Storage layer) (tokenBuffer : State.TokenStorage.Buffer token)
    (shared : Shared storage tokenBuffer) (regions : Regions) (allocation : Allocation storage tokenBuffer regions) : Execution layer token :=
  ⟨storage,tokenBuffer,shared,regions,allocation⟩

variable (execution : Execution layer token)

def Execution.storageAt (heap : Prefix execution.regions execution.tokenBuffer.bytes) : QuantizedEmbeddingDevice.Storage layer where
  packed := heap.memory
  packedBase := execution.storage.packedBase
  aligned := execution.storage.aligned
  bounded := execution.storage.bounded
  attached := by
    intro row i
    rw [ArrayFrame.word_congr execution.tokenBuffer.bytes heap.memory execution.storage.packedBase (4*(248320*640)) _
      (heap.same _ _ execution.allocation.packedLive) (by have := QuantizedEmbedding.takeRow_bounds 640 row i; omega)]
    rw [← execution.shared.packed]
    exact execution.storage.attached row i
  scales := ArrayFrame.bf execution.storage.scales heap.memory (fun offset bound =>
    (heap.same _ _ execution.allocation.scalesLive offset bound).trans (congrFun execution.shared.scales _).symm)
  biases := ArrayFrame.bf execution.storage.biases heap.memory (fun offset bound =>
    (heap.same _ _ execution.allocation.biasesLive offset bound).trans (congrFun execution.shared.biases _).symm)

def Execution.tokenAt (heap : Prefix execution.regions execution.tokenBuffer.bytes) : State.TokenStorage.Buffer token where
  bytes := heap.memory
  base := execution.tokenBuffer.base
  aligned := execution.tokenBuffer.aligned
  bounded := execution.tokenBuffer.bounded
  attached := by
    have same := ArrayFrame.word_congr execution.tokenBuffer.bytes heap.memory execution.tokenBuffer.base 4 0
      (heap.same _ _ execution.allocation.tokenLive) (by decide)
    simpa only [Nat.add_zero] using same.trans execution.tokenBuffer.attached

def Execution.row (heap : Prefix execution.regions execution.tokenBuffer.bytes) : Fin 248320 :=
  ⟨(execution.tokenAt heap).read,by rw [(execution.tokenAt heap).read_correct]; exact token.isLt⟩

theorem Execution.row_eq (heap : Prefix execution.regions execution.tokenBuffer.bytes) : execution.row heap=token :=
  Fin.ext (execution.tokenAt heap).read_correct

def Execution.p0 : Prefix execution.regions execution.tokenBuffer.bytes := Prefix.initial _ _
def Execution.packedValues := QuantizedEmbeddingDevice.packedLoads (execution.storageAt execution.p0) (execution.row execution.p0)
def Execution.packed := wordTrace execution.p0.memory execution.regions.packed execution.packedValues
  execution.allocation.packedAligned execution.allocation.packedBounded

def Execution.p1 := execution.p0.afterWord execution.regions.packed execution.packedValues
  execution.allocation.packedAligned execution.allocation.packedBounded (fun _ _ h => h.1)

def Execution.scaleValues := QuantizedEmbeddingDevice.parameterLoads (execution.storageAt execution.p1).scales (execution.row execution.p1)
def Execution.scales := halfTrace execution.p1.memory execution.regions.scales (fun i => ArrayStorage.bits (execution.scaleValues i))
  execution.allocation.scalesAligned execution.allocation.scalesBounded

def Execution.p2 := execution.p1.afterHalf execution.regions.scales (fun i => ArrayStorage.bits (execution.scaleValues i))
  execution.allocation.scalesAligned execution.allocation.scalesBounded (fun _ _ h => h.2.1)

def Execution.biasValues := QuantizedEmbeddingDevice.parameterLoads (execution.storageAt execution.p2).biases (execution.row execution.p2)
def Execution.biases := halfTrace execution.p2.memory execution.regions.biases (fun i => ArrayStorage.bits (execution.biasValues i))
  execution.allocation.biasesAligned execution.allocation.biasesBounded

def Execution.p3 := execution.p2.afterHalf execution.regions.biases (fun i => ArrayStorage.bits (execution.biasValues i))
  execution.allocation.biasesAligned execution.allocation.biasesBounded (fun _ _ h => h.2.2.1)

theorem Execution.packedValues_eq : execution.packedValues=layer.words token := by
  unfold Execution.packedValues
  rw [QuantizedEmbeddingDevice.packedLoads_eq,execution.row_eq]

theorem Execution.scaleValues_eq : execution.scaleValues=layer.scales token := by
  unfold Execution.scaleValues
  rw [QuantizedEmbeddingDevice.parameterLoads_eq,execution.row_eq]

theorem Execution.biasValues_eq : execution.biasValues=layer.biases token := by
  unfold Execution.biasValues
  rw [QuantizedEmbeddingDevice.parameterLoads_eq,execution.row_eq]


theorem Execution.packed_retained (offset : Nat) (bound : offset<2560) :
    execution.p3.memory (execution.regions.packed+offset)=execution.packed.memory (execution.regions.packed+offset) :=
  (halfTrace_frame execution.p2.memory execution.regions.biases _ execution.allocation.biasesAligned execution.allocation.biasesBounded
    execution.allocation.biasesPacked offset bound).trans
    (halfTrace_frame execution.p1.memory execution.regions.scales _ execution.allocation.scalesAligned execution.allocation.scalesBounded
      execution.allocation.scalesPacked offset bound)

def Execution.scaleBuffer : ArrayStorage.BFBuffer execution.scaleValues :=
  ArrayFrame.bf execution.scales.buffer execution.p3.memory
    (halfTrace_frame execution.p2.memory execution.regions.biases _ execution.allocation.biasesAligned execution.allocation.biasesBounded
      execution.allocation.biasesScales)

def Execution.biasBuffer : ArrayStorage.BFBuffer execution.biasValues := execution.biases.buffer

private theorem word_byte (word : BitVec 32) (offset : Fin 4) :
    ByteMemory.byte word offset.val=(word >>> (8*offset.val)).setWidth 8 := by
  apply BitVec.eq_of_getLsbD_eq
  intro i hi
  simp [ByteMemory.byte,BitVec.getLsbD_ushiftRight,hi,Nat.add_comm]

theorem Execution.packed_byte (i : Fin 2560) :
    execution.p3.memory (execution.regions.packed+i.val)=QuantizedEmbedding.bytes (layer.words token) i := by
  rw [execution.packed_retained i.val i.isLt]
  have copied := execution.packed.byte_correct (QuantizedEmbedding.wordByte i) ⟨i.val%4,by omega⟩
  have loaded := congrArg (fun word => ByteMemory.byte word (i.val%4))
    (congrFun execution.packedValues_eq (QuantizedEmbedding.wordByte i))
  have result := copied.trans loaded
  rw [word_byte _ ⟨i.val%4,by omega⟩] at result
  simpa only [QuantizedEmbedding.wordByte,QuantizedEmbedding.bytes,
    show execution.regions.packed+4*(i.val/4)+i.val%4=execution.regions.packed+i.val by omega] using result

def dequantize (layer : QuantizedEmbedding.Layer) (r : Regions) (memory : ByteMemory.Bytes) (i : Fin 5120) : BF :=
  AffineDequantize.value layer.contracted
    (Model.ofBits (HalfMemory.load memory (r.scales+2*(AffineDequantize.groupIndex i).val)))
    (Model.ofBits (HalfMemory.load memory (r.biases+2*(AffineDequantize.groupIndex i).val)))
    (AffineDequantize.code (memory (r.packed+(AffineDequantize.byteIndex i).val)) (AffineDequantize.byteCoordinate i))

def Execution.produced (i : Fin 5120) : BF :=
  AffineDequantize.value layer.contracted (execution.scaleBuffer.read (AffineDequantize.groupIndex i))
    (execution.biasBuffer.read (AffineDequantize.groupIndex i))
    (AffineDequantize.code (execution.p3.memory (execution.regions.packed+(AffineDequantize.byteIndex i).val))
      (AffineDequantize.byteCoordinate i))

theorem Execution.p3_biases : execution.p3.memory=execution.biases.memory := rfl

private theorem value_congr {s1 s2 b1 b2 : BF} {q1 q2 : Fin 16}
    (contracted : Bool) (hs : s1=s2) (hb : b1=b2) (hq : q1=q2) :
    AffineDequantize.value contracted s1 b1 q1=AffineDequantize.value contracted s2 b2 q2 := by
  cases hs; cases hb; cases hq; rfl

theorem Execution.produced_eq : execution.produced=layer.forward token := by
  funext i
  unfold Execution.produced QuantizedEmbedding.Layer.forward AffineDequantize.row
  exact value_congr layer.contracted
    ((execution.scaleBuffer.read_correct _).trans (congrFun execution.scaleValues_eq _))
    ((execution.biasBuffer.read_correct _).trans (congrFun execution.biasValues_eq _))
    (congrArg (fun byte => AffineDequantize.code byte (AffineDequantize.byteCoordinate i)) (execution.packed_byte _))

def Execution.output := halfTrace execution.p3.memory execution.regions.output (fun i => ArrayStorage.bits (execution.produced i))
  execution.allocation.outputAligned execution.allocation.outputBounded

def Execution.values : Fin 5120 → BF := execution.output.buffer.read

def Execution.outputBuffer : ArrayStorage.BFBuffer execution.values := ArrayViews.readback execution.output.buffer

theorem Execution.output_eq : execution.values=layer.forward token := by
  funext i
  exact (execution.output.buffer.read_correct i).trans (congrFun execution.produced_eq i)

def Execution.forwardBuffer : ArrayStorage.BFBuffer (layer.forward token) :=
  ArrayViews.reindex execution.output_eq execution.outputBuffer

def Execution.p4 := execution.p3.afterHalf execution.regions.output (fun i => ArrayStorage.bits (execution.produced i))
  execution.allocation.outputAligned execution.allocation.outputBounded (fun _ _ h => h.2.2.2)

theorem Execution.other_region {base size : Nat} (safe : execution.regions.Live base size) (offset : Nat) (bound : offset<size) :
    execution.outputBuffer.bytes (base+offset)=execution.tokenBuffer.bytes (base+offset) :=
  execution.p4.same base size safe offset bound


-- gather_front<bf16,...,2> owns two adjacent cells per native thread.
-- Its canonical native schedule is exactly the scalar readback schedule.
def parameterPrograms (base : Nat) (values : Fin 80 → BitVec 16) : List (List HalfMemory.Store) :=
  (List.finRange 40).map (fun thread =>
    [HalfArrayWrites.entry base values ⟨2*thread.val,by have := thread.isLt; omega⟩,
      HalfArrayWrites.entry base values ⟨2*thread.val+1,by have := thread.isLt; omega⟩])

theorem parameter_flatten (base : Nat) (values : Fin 80 → BitVec 16) :
    (parameterPrograms base values).flatten=(HalfArrayWrites.programs base values).flatten := by rfl

theorem parameter_native (before : ByteMemory.Bytes) (base : Nat) (values : Fin 80 → BitVec 16)
    (aligned : base%2=0) (bounded : base+160 ≤ 2^64) :
    ThreadgroupWrites.Executes (parameterPrograms base values) (halfTrace before base values aligned bounded).schedule
      (List.replicate 40 []) := by
  have same : (halfTrace before base values aligned bounded).schedule=(parameterPrograms base values).flatten := by
    unfold halfTrace
    exact (parameter_flatten base values).symm
  rw [same]
  exact ThreadgroupWrites.canonical _

theorem Execution.produced_memory (i : Fin 5120) :
    execution.produced i=dequantize layer execution.regions execution.p3.memory i := by
  unfold Execution.produced dequantize
  exact value_congr layer.contracted rfl
    (congrArg (fun bytes => (Model.ofBits (HalfMemory.load bytes
      (execution.regions.biases+2*(AffineDequantize.groupIndex i).val)) : BF)) execution.p3_biases.symm) rfl

def Prefix.wordStores (heap : Prefix r beforeMemory) (stores : List ByteMemory.Store)
    (inside : MemoryRegions.Inside32 base size stores)
    (safe : ∀ b s, r.Live b s → MemoryRegions.Disjoint base size b s) : Prefix r beforeMemory :=
  ⟨ByteMemory.execute stores heap.memory,fun b s h offset bound =>
    (MemoryRegions.execute32_other stores heap.memory inside (safe b s h) offset bound).trans (heap.same b s h offset bound)⟩

def Prefix.halfStores (heap : Prefix r beforeMemory) (stores : List HalfMemory.Store)
    (inside : MemoryRegions.Inside16 base size stores)
    (safe : ∀ b s, r.Live b s → MemoryRegions.Disjoint base size b s) : Prefix r beforeMemory :=
  ⟨HalfMemory.execute stores heap.memory,fun b s h offset bound =>
    (MemoryRegions.execute16_other stores heap.memory inside (safe b s h) offset bound).trans (heap.same b s h offset bound)⟩

def Execution.duringPacked (stores : List ByteMemory.Store) (subset : ∀ store ∈ stores, store ∈ execution.packed.schedule) :=
  execution.p0.wordStores stores
    (fun store member => ArrayFrame.word_stores_inside execution.packed store (subset store member)) (fun _ _ h => h.1)

def Execution.duringScales (stores : List HalfMemory.Store) (subset : ∀ store ∈ stores, store ∈ execution.scales.schedule) :=
  execution.p1.halfStores stores
    (fun store member => ArrayFrame.half_stores_inside execution.scales store (subset store member)) (fun _ _ h => h.2.1)

def Execution.duringBiases (stores : List HalfMemory.Store) (subset : ∀ store ∈ stores, store ∈ execution.biases.schedule) :=
  execution.p2.halfStores stores
    (fun store member => ArrayFrame.half_stores_inside execution.biases store (subset store member)) (fun _ _ h => h.2.2.1)

-- Applies to every preceding prefix and every partial native store subset.
-- All three source arrays and the actual token word retain their reads.
theorem Execution.source_reads (heap : Prefix execution.regions execution.tokenBuffer.bytes) :
    (execution.tokenAt heap).read=token.val ∧
    QuantizedEmbeddingDevice.packedLoads (execution.storageAt heap) (execution.row heap)=layer.words token ∧
    QuantizedEmbeddingDevice.parameterLoads (execution.storageAt heap).scales (execution.row heap)=layer.scales token ∧
    QuantizedEmbeddingDevice.parameterLoads (execution.storageAt heap).biases (execution.row heap)=layer.biases token := by
  refine ⟨(execution.tokenAt heap).read_correct,?_,?_,?_⟩
  · rw [QuantizedEmbeddingDevice.packedLoads_eq,execution.row_eq]
  · rw [QuantizedEmbeddingDevice.parameterLoads_eq,execution.row_eq]
  · rw [QuantizedEmbeddingDevice.parameterLoads_eq,execution.row_eq]

theorem Execution.during_dequantize (stores : List HalfMemory.Store)
    (inside : MemoryRegions.Inside16 execution.regions.output 10240 stores) (i : Fin 5120) :
    dequantize layer execution.regions (HalfMemory.execute stores execution.p3.memory) i=execution.produced i := by
  apply Eq.trans _ (execution.produced_memory i).symm
  unfold dequantize
  apply value_congr layer.contracted
  · apply congrArg Model.ofBits
    exact ArrayFrame.half_congr execution.p3.memory _ execution.regions.scales 160 _
      (MemoryRegions.execute16_other stores execution.p3.memory inside execution.allocation.outputScales)
      (by have := (AffineDequantize.groupIndex i).isLt; omega)
  · apply congrArg Model.ofBits
    exact ArrayFrame.half_congr execution.p3.memory _ execution.regions.biases 160 _
      (MemoryRegions.execute16_other stores execution.p3.memory inside execution.allocation.outputBiases)
      (by have := (AffineDequantize.groupIndex i).isLt; omega)
  · exact congrArg (fun byte => AffineDequantize.code byte (AffineDequantize.byteCoordinate i))
      (MemoryRegions.execute16_other stores execution.p3.memory inside execution.allocation.outputPacked _ (AffineDequantize.byteIndex i).isLt)

def Execution.storageAfter : QuantizedEmbeddingDevice.Storage layer := execution.storageAt execution.p4

def Execution.tokenAfter : State.TokenStorage.Buffer token := execution.tokenAt execution.p4

def Execution.bufferAfter {n : Nat} {contents : Fin n → BF} (buffer : ArrayStorage.BFBuffer contents) (shared : buffer.bytes=execution.tokenBuffer.bytes)
    (safe : execution.regions.Live buffer.base (2*n)) : ArrayStorage.BFBuffer contents :=
  ArrayFrame.bf buffer execution.outputBuffer.bytes (fun offset bound =>
    (execution.other_region safe offset bound).trans (congrFun shared _).symm)


theorem Execution.signed_index (heap : Prefix execution.regions execution.tokenBuffer.bytes) :
    (execution.tokenAt heap).read<2^31 := (execution.tokenAt heap).int32_index

theorem Execution.scales_native :
    ThreadgroupWrites.Executes (parameterPrograms execution.regions.scales (fun i => ArrayStorage.bits (execution.scaleValues i)))
      execution.scales.schedule (List.replicate 40 []) :=
  parameter_native execution.p1.memory execution.regions.scales (fun i => ArrayStorage.bits (execution.scaleValues i))
    execution.allocation.scalesAligned execution.allocation.scalesBounded

theorem Execution.biases_native :
    ThreadgroupWrites.Executes (parameterPrograms execution.regions.biases (fun i => ArrayStorage.bits (execution.biasValues i)))
      execution.biases.schedule (List.replicate 40 []) :=
  parameter_native execution.p2.memory execution.regions.biases (fun i => ArrayStorage.bits (execution.biasValues i))
    execution.allocation.biasesAligned execution.allocation.biasesBounded

theorem Execution.forward_base : execution.forwardBuffer.base=execution.regions.output :=
  (ArrayViews.reindex_base execution.output_eq execution.outputBuffer).trans rfl

theorem Execution.buffers_shared :
    execution.forwardBuffer.bytes=execution.outputBuffer.bytes ∧
    execution.storageAfter.packed=execution.outputBuffer.bytes ∧
    execution.storageAfter.scales.bytes=execution.outputBuffer.bytes ∧
    execution.storageAfter.biases.bytes=execution.outputBuffer.bytes ∧
    execution.tokenAfter.bytes=execution.outputBuffer.bytes :=
  ⟨ArrayViews.reindex_bytes execution.output_eq execution.outputBuffer,rfl,rfl,rfl,rfl⟩

end Inference.Layers.QuantizedEmbeddingMemory
