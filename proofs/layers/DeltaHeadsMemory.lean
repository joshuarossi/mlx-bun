import layers.DeltaHeadsDevice
import contracts.mlx.MultiOutputWrites

namespace Inference.Layers.DeltaHeadsMemory
open Contracts.Mlx Kernels.Delta
open FloatLib FloatLib.Floats FloatLib.Floats.Formats.BinaryInterchange
set_option maxRecDepth 10000
abbrev BF := ArrayStorage.BF

def blocks (output : Fin 3) : Nat := if output.val<2 then 512 else 1536
def size (output : Fin 3) : Nat := 2*(4*blocks output)

def vector (bases : Fin 3 → Nat) (values : DeltaHeads.Output 1 BF) (output : Fin 3) : MultiOutputWrites.Vector :=
  match output.val with
  | 0 => ⟨512, bases output, fun i => ArrayStorage.bits (GatedInputs.flatten (values.q 0) i)⟩
  | 1 => ⟨512, bases output, fun i => ArrayStorage.bits (GatedInputs.flatten (values.k 0) i)⟩
  | _ => ⟨1536, bases output, fun i => ArrayStorage.bits (GatedInputs.flatten (values.v 0) i)⟩

theorem vector_base (bases : Fin 3 → Nat) (values : DeltaHeads.Output 1 BF) (output : Fin 3) :
    (vector bases values output).base=bases output := by fin_cases output <;> rfl

theorem vector_blocks (bases : Fin 3 → Nat) (values : DeltaHeads.Output 1 BF) (output : Fin 3) :
    (vector bases values output).blocks=blocks output := by fin_cases output <;> rfl

structure Geometry where
  base : Fin 3 → Nat
  aligned : ∀ i, base i%2=0
  bounded : ∀ i, base i+size i ≤ 2^64
  separate : ∀ i j, i≠j → MemoryRegions.Disjoint (base i) (size i) (base j) (size j)

def Geometry.layout (geometry : Geometry) (values : DeltaHeads.Output 1 BF) : MultiOutputWrites.Layout 3 where
  output := vector geometry.base values
  aligned := by intro i; rw [vector_base]; exact geometry.aligned i
  bounded := by intro i; rw [vector_base, vector_blocks]; exact geometry.bounded i
  separate := by intro i j different; rw [vector_base, vector_base, vector_blocks, vector_blocks]; exact geometry.separate i j different

structure Input (values : Fin 10240 → BF) (qScale kScale : Fin 128 → BF) where
  storage : DeltaHeadsDevice.Storage values qScale kScale
  queryShared : storage.qScale.bytes=storage.input.bytes
  keyShared : storage.kScale.bytes=storage.input.bytes

variable {values : Fin 10240 → BF} {qScale kScale : Fin 128 → BF}

def Input.reframe (input : Input values qScale kScale) (after : ByteMemory.Bytes)
    (sourceSame : ∀ offset < 20480, after (input.storage.input.base+offset)=input.storage.input.bytes (input.storage.input.base+offset))
    (querySame : ∀ offset < 256, after (input.storage.qScale.base+offset)=input.storage.input.bytes (input.storage.qScale.base+offset))
    (keySame : ∀ offset < 256, after (input.storage.kScale.base+offset)=input.storage.input.bytes (input.storage.kScale.base+offset)) :
    Input values qScale kScale where
  storage := {
    input := ArrayFrame.bf input.storage.input after sourceSame
    qScale := ArrayFrame.bf input.storage.qScale after (fun offset bound => (querySame offset bound).trans (congrFun input.queryShared _).symm)
    kScale := ArrayFrame.bf input.storage.kScale after (fun offset bound => (keySame offset bound).trans (congrFun input.keyShared _).symm) }
  queryShared := rfl
  keyShared := rfl

structure Execution (input : Input values qScale kScale) (p : SiluRmsHeads.Platform) (width eps : Float32) where
  geometry : Geometry
  trace : MultiOutputWrites.Trace (geometry.layout (DeltaHeadsDevice.produced p width eps input.storage))
  shared : trace.before=input.storage.input.bytes
  sourceSeparate : ∀ i, MemoryRegions.Disjoint (geometry.base i) (size i) input.storage.input.base 20480
  querySeparate : ∀ i, MemoryRegions.Disjoint (geometry.base i) (size i) input.storage.qScale.base 256
  keySeparate : ∀ i, MemoryRegions.Disjoint (geometry.base i) (size i) input.storage.kScale.base 256

variable {input : Input values qScale kScale} {p : SiluRmsHeads.Platform} {width eps : Float32}

def canonical (input : Input values qScale kScale) (p : SiluRmsHeads.Platform) (width eps : Float32) (geometry : Geometry)
    (sourceSeparate : ∀ i, MemoryRegions.Disjoint (geometry.base i) (size i) input.storage.input.base 20480)
    (querySeparate : ∀ i, MemoryRegions.Disjoint (geometry.base i) (size i) input.storage.qScale.base 256)
    (keySeparate : ∀ i, MemoryRegions.Disjoint (geometry.base i) (size i) input.storage.kScale.base 256) : Execution input p width eps :=
  ⟨geometry, MultiOutputWrites.canonical _ input.storage.input.bytes, rfl, sourceSeparate, querySeparate, keySeparate⟩

theorem Execution.partial_frame (execution : Execution input p width eps) {base bytes : Nat}
    (stores : List HalfMemory.Store) (subset : ∀ store ∈ stores, store ∈ execution.trace.schedule)
    (separate : ∀ i, MemoryRegions.Disjoint (execution.geometry.base i) (size i) base bytes)
    (offset : Nat) (bound : offset<bytes) :
    HalfMemory.execute stores execution.trace.before (base+offset)=input.storage.input.bytes (base+offset) := by
  have safe : ∀ i, MemoryRegions.Disjoint
      ((execution.geometry.layout (DeltaHeadsDevice.produced p width eps input.storage)).output i).base
      (2*(4*((execution.geometry.layout (DeltaHeadsDevice.produced p width eps input.storage)).output i).blocks)) base bytes := by
    intro i
    dsimp only [Geometry.layout]
    rw [vector_base, vector_blocks]
    exact separate i
  exact (execution.trace.during_other stores subset safe offset bound).trans (congrFun execution.shared _)

def Execution.during (execution : Execution input p width eps) (stores : List HalfMemory.Store)
    (subset : ∀ store ∈ stores, store ∈ execution.trace.schedule) : Input values qScale kScale :=
  input.reframe (HalfMemory.execute stores execution.trace.before)
    (execution.partial_frame stores subset execution.sourceSeparate)
    (execution.partial_frame stores subset execution.querySeparate)
    (execution.partial_frame stores subset execution.keySeparate)

theorem Execution.partial_produced (execution : Execution input p width eps) (stores : List HalfMemory.Store)
    (subset : ∀ store ∈ stores, store ∈ execution.trace.schedule) :
    DeltaHeadsDevice.produced p width eps (execution.during stores subset).storage=
      DeltaHeadsDevice.produced p width eps input.storage := by
  rw [DeltaHeadsDevice.produced_eq, DeltaHeadsDevice.produced_eq]

def Execution.queryBuffer (execution : Execution input p width eps) :
    ArrayStorage.BFBuffer (GatedInputs.flatten ((DeltaHeadsDevice.produced p width eps input.storage).q 0)) where
  bytes := execution.trace.memory
  base := execution.geometry.base 0
  aligned := execution.geometry.aligned 0
  bounded := execution.geometry.bounded 0
  attached := execution.trace.read_correct 0

def Execution.keyBuffer (execution : Execution input p width eps) :
    ArrayStorage.BFBuffer (GatedInputs.flatten ((DeltaHeadsDevice.produced p width eps input.storage).k 0)) where
  bytes := execution.trace.memory
  base := execution.geometry.base 1
  aligned := execution.geometry.aligned 1
  bounded := execution.geometry.bounded 1
  attached := execution.trace.read_correct 1

def Execution.valueBuffer (execution : Execution input p width eps) :
    ArrayStorage.BFBuffer (GatedInputs.flatten ((DeltaHeadsDevice.produced p width eps input.storage).v 0)) where
  bytes := execution.trace.memory
  base := execution.geometry.base 2
  aligned := execution.geometry.aligned 2
  bounded := execution.geometry.bounded 2
  attached := execution.trace.read_correct 2

def Execution.output (execution : Execution input p width eps) : DeltaHeads.Output 1 BF where
  q _ head i := execution.queryBuffer.read (GatedInputs.index head i)
  k _ head i := execution.keyBuffer.read (GatedInputs.index head i)
  v _ head i := execution.valueBuffer.read (GatedInputs.index head i)

theorem Execution.output_eq (execution : Execution input p width eps) :
    execution.output=DeltaHeads.forward p (fun _ => values) qScale kScale width eps := by
  unfold Execution.output
  simp only [ArrayStorage.BFBuffer.read_correct, GatedInputs.flatten_index, DeltaHeadsDevice.produced_eq]
  rfl

theorem Execution.buffers_shared (execution : Execution input p width eps) :
    execution.queryBuffer.bytes=execution.keyBuffer.bytes ∧ execution.keyBuffer.bytes=execution.valueBuffer.bytes := ⟨rfl,rfl⟩

theorem Execution.other_region (execution : Execution input p width eps) {base bytes : Nat}
    (separate : ∀ i, MemoryRegions.Disjoint (execution.geometry.base i) (size i) base bytes)
    (offset : Nat) (bound : offset<bytes) : execution.trace.memory (base+offset)=input.storage.input.bytes (base+offset) :=
  execution.partial_frame execution.trace.schedule (fun _ member => member) separate offset bound

end Inference.Layers.DeltaHeadsMemory
