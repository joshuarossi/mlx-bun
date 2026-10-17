import kernels.GatedRmsNormDevice
import contracts.mlx.ArrayFrame

namespace Inference.Kernels.GatedRmsNormMemory
open Contracts.Mlx Delta.GatedInputs
open GatedRmsNormDevice (Rows)
set_option maxRecDepth 10000
attribute [local irreducible] CopyContiguous.programs

structure Input (x gate : Rows) (weights : Fin 128 → BF) where
  storage : GatedRmsNormDevice.Storage x gate weights
  gateShared : storage.gate.bytes=storage.input.bytes
  weightShared : storage.weight.bytes=storage.input.bytes

variable {x gate : Rows} {weights : Fin 128 → BF}

def Input.reframe (input : Input x gate weights) (after : ByteMemory.Bytes)
    (xSame : ∀ offset < 12288, after (input.storage.input.base+offset)=input.storage.input.bytes (input.storage.input.base+offset))
    (gateSame : ∀ offset < 12288, after (input.storage.gate.base+offset)=input.storage.input.bytes (input.storage.gate.base+offset))
    (weightSame : ∀ offset < 256, after (input.storage.weight.base+offset)=input.storage.input.bytes (input.storage.weight.base+offset)) :
    Input x gate weights where
  storage := {
    input := ArrayFrame.bf input.storage.input after xSame
    gate := ArrayFrame.bf input.storage.gate after (by
      intro offset bound
      exact (gateSame offset bound).trans (congrFun input.gateShared _).symm)
    weight := ArrayFrame.bf input.storage.weight after (by
      intro offset bound
      exact (weightSame offset bound).trans (congrFun input.weightShared _).symm) }
  gateShared := rfl
  weightShared := rfl

-- The selected 128-wide custom kernel requests an owned output. No input
-- donation is needed here; all reads are stable across output stores.
structure Execution (input : Input x gate weights) (p : GatedRmsNorm.Platform) (width eps : Float32) where
  base : Nat
  bounded : base+12288 ≤ 2^64
  stores : CopyContiguous.Trace base (blocks := 1536)
    (fun i => ArrayStorage.bits (flatten (GatedRmsNormDevice.produced p width eps input.storage) i))
  shared : stores.before=input.storage.input.bytes
  inputSeparate : MemoryRegions.Disjoint base 12288 input.storage.input.base 12288
  gateSeparate : MemoryRegions.Disjoint base 12288 input.storage.gate.base 12288
  weightsSeparate : MemoryRegions.Disjoint base 12288 input.storage.weight.base 256

variable {input : Input x gate weights} {p : GatedRmsNorm.Platform} {width eps : Float32}

def canonical (input : Input x gate weights) (p : GatedRmsNorm.Platform) (width eps : Float32)
    (base : Nat) (aligned : base%2=0) (bounded : base+12288 ≤ 2^64)
    (inputSeparate : MemoryRegions.Disjoint base 12288 input.storage.input.base 12288)
    (gateSeparate : MemoryRegions.Disjoint base 12288 input.storage.gate.base 12288)
    (weightsSeparate : MemoryRegions.Disjoint base 12288 input.storage.weight.base 256) : Execution input p width eps :=
  ⟨base, bounded, CopyContiguous.Trace.canonical base _ input.storage.input.bytes aligned,
    rfl, inputSeparate, gateSeparate, weightsSeparate⟩

def Execution.during (execution : Execution input p width eps) (stores : List HalfMemory.Store)
    (inside : MemoryRegions.Inside16 execution.base 12288 stores) : Input x gate weights :=
  input.reframe (HalfMemory.execute stores input.storage.input.bytes)
    (MemoryRegions.execute16_other stores _ inside execution.inputSeparate)
    (MemoryRegions.execute16_other stores _ inside execution.gateSeparate)
    (MemoryRegions.execute16_other stores _ inside execution.weightsSeparate)

theorem Execution.partial_produced (execution : Execution input p width eps) (stores : List HalfMemory.Store)
    (inside : MemoryRegions.Inside16 execution.base 12288 stores) :
    GatedRmsNormDevice.produced p width eps (execution.during stores inside).storage=
      GatedRmsNormDevice.produced p width eps input.storage := by
  rw [GatedRmsNormDevice.produced_eq, GatedRmsNormDevice.produced_eq]

theorem Execution.stores_inside (execution : Execution input p width eps) :
    MemoryRegions.Inside16 execution.base 12288 execution.stores.schedule := by
  intro store member
  have original := (ThreadgroupWrites.completed_schedule execution.stores.execution execution.stores.completed).mem_iff.mp member
  obtain ⟨thread, offset, rfl⟩ := CopyContiguous.member _ _ store original
  have bound := (CopyContiguous.index thread offset).isLt
  have aligned := execution.stores.aligned
  dsimp only [CopyContiguous.entry]
  omega

def Execution.buffer (execution : Execution input p width eps) :
    ArrayStorage.BFBuffer (flatten (GatedRmsNormDevice.produced p width eps input.storage)) where
  bytes := execution.stores.memory
  base := execution.base
  aligned := execution.stores.aligned
  bounded := execution.bounded
  attached := execution.stores.read_correct

def Execution.output (execution : Execution input p width eps) (head : Fin 48) (i : Fin 128) : BF :=
  execution.buffer.read (index head i)

theorem Execution.output_eq (execution : Execution input p width eps) :
    execution.output=fun head => GatedRmsNorm.value p (x head) (gate head) weights width eps := by
  funext head i
  unfold Execution.output
  rw [ArrayStorage.BFBuffer.read_correct, flatten_index, GatedRmsNormDevice.produced_eq]

def Execution.outputBuffer (execution : Execution input p width eps) : ArrayStorage.BFBuffer (flatten execution.output) where
  bytes := execution.stores.memory
  base := execution.base
  aligned := execution.stores.aligned
  bounded := execution.bounded
  attached := by
    intro i
    change HalfMemory.load execution.stores.memory (execution.base+2*i.val)=
      HalfMemory.load execution.stores.memory (execution.base+2*(i.val/128*128+i.val%128))
    congr 2
    omega

theorem Execution.other_region (execution : Execution input p width eps) {base size : Nat}
    (separate : MemoryRegions.Disjoint execution.base 12288 base size) (offset : Nat) (bound : offset<size) :
    execution.outputBuffer.bytes (base+offset)=input.storage.input.bytes (base+offset) :=
  (MemoryRegions.execute16_other execution.stores.schedule execution.stores.before execution.stores_inside separate offset bound).trans
    (congrFun execution.shared _)

end Inference.Kernels.GatedRmsNormMemory
