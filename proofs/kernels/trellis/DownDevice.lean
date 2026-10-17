import kernels.trellis.DownReadBarrier
import kernels.trellis.DownPartialMemory

namespace Inference.Kernels.Trellis.DownDevice
open Contracts.Mlx Contracts.Mlx.Numerics Contracts.Mlx.M1Max
open DownExecution (PackedMatrix SimdReduction)

-- Per-threadgroup computations feed a separate device buffer. Completion
-- of its producing dispatch precedes every fold read. The native command
-- dependency and buffer allocation must implement this ordering contract.
structure Trace (load : ThreadgroupLoad) (before : Nat → ByteMemory.Bytes) (base : Nat)
    (words : PackedMatrix) (k : Nat) (scale input : Nat → Float32) where
  threadgroup : ∀ ty, DownReadBarrier.Trace load (before ty) base words k scale input ty
  partialBefore : ByteMemory.Bytes
  partialBase : Nat
  partialAligned : partialBase%16=0
  partialBounded : partialBase+4*(32*5120) ≤ 2^64
  schedule : List Memory.Store
  remaining : List (List Memory.Store)
  execution : ThreadgroupWrites.Executes
    (DownPartialMemory.programs partialBase (fun ty column => (threadgroup ty).value column)) schedule remaining
  completed : ThreadgroupWrites.AtBarrier remaining

def Trace.canonical (load : ThreadgroupLoad) (before : Nat → ByteMemory.Bytes) (base : Nat)
    (words : PackedMatrix) (k : Nat) (scale input : Nat → Float32)
    (partialBefore : ByteMemory.Bytes) (partialBase : Nat) (aligned : partialBase%16=0)
    (bounded : partialBase+4*(32*5120) ≤ 2^64) : Trace load before base words k scale input :=
  let threadgroup := fun ty => DownReadBarrier.Trace.canonical load (before ty) base words k scale input ty
  let stores := DownPartialMemory.programs partialBase (fun ty column => (threadgroup ty).value column)
  ⟨threadgroup, partialBefore, partialBase, aligned, bounded, stores.flatten, List.replicate stores.length [],
    ThreadgroupWrites.canonical stores, ThreadgroupWrites.canonical_barrier stores⟩

def Trace.memory (trace : Trace load before base words k scale input) : ByteMemory.Bytes :=
  FloatMemory.execute trace.schedule trace.partialBefore

def Trace.read (trace : Trace load before base words k scale input) (lane column : Nat) : Float32 :=
  FloatMemory.load trace.memory (trace.partialBase+4*(lane*5120+column))

theorem Trace.read_correct (trace : Trace load before base words k scale input) (hardware : LoadContract load)
    (aligned : base%4=0) (address : base+16384 ≤ 2^64) (bits : k=2 ∨ k=3 ∨ k=4)
    (lane column : Nat) (hl : lane<32) (hc : column<5120) :
    trace.read lane column=DownFlushToZero.partialSum words k scale input lane column := by
  unfold Trace.read Trace.memory
  rw [DownPartialMemory.stored_bytes trace.partialBefore trace.partialBase (by have := trace.partialAligned; omega)
    _ trace.schedule trace.remaining trace.execution trace.completed lane column hl hc]
  rw [DownReadBarrier.Trace.correct _ hardware aligned address bits _ (by omega)]
  obtain ⟨_, _, sameLane, sameColumn⟩ := DownCodebook.partial_coverage lane column hl hc
  rw [sameLane, sameColumn]

def output (trace : Trace load before base words k scale input) (reduce : SimdReduction)
    (convert : Float32 → Float32) (column : Nat) : Float32 :=
  convert (reduce (fun lane => trace.read lane.val column))

theorem output_correct (trace : Trace load before base words k scale input) (hardware : LoadContract load)
    (aligned : base%4=0) (address : base+16384 ≤ 2^64) (bits : k=2 ∨ k=3 ∨ k=4)
    (reduce : SimdReduction) (convert : Float32 → Float32) (column : Nat) (hc : column<5120) :
    output trace reduce convert column=convert (reduce (fun lane => DownFlushToZero.partialSum words k scale input lane.val column)) := by
  unfold output
  apply congrArg convert
  apply congrArg reduce
  funext lane
  exact trace.read_correct hardware aligned address bits lane.val column lane.isLt hc

def vectorAddress (partialBase group sg lane : Nat) : Nat := partialBase+4*(lane*5120+group*32+sg*4)

theorem vector_aligned (partialBase group sg lane : Nat) (aligned : partialBase%16=0) :
    vectorAddress partialBase group sg lane%16=0 := by
  unfold vectorAddress
  omega

theorem vector_bounds (partialBase group sg lane : Nat) (hg : group<160) (hs : sg<8) (hl : lane<32)
    (bounded : partialBase+4*(32*5120) ≤ 2^64) :
    partialBase ≤ vectorAddress partialBase group sg lane ∧
      vectorAddress partialBase group sg lane+16 ≤ partialBase+4*(32*5120) ∧
      vectorAddress partialBase group sg lane+16 ≤ 2^64 := by
  unfold vectorAddress
  omega

def readVector (trace : Trace load before base words k scale input) (group sg lane : Nat) (component : Fin 4) : Float32 :=
  FloatMemory.load trace.memory (vectorAddress trace.partialBase group sg lane+4*component.val)

theorem vector_component (trace : Trace load before base words k scale input) (group sg lane : Nat) (component : Fin 4) :
    readVector trace group sg lane component=trace.read lane (group*32+sg*4+component.val) := by
  unfold readVector Trace.read vectorAddress
  congr 1
  omega

theorem vector_coverage (column : Nat) (hc : column<5120) :
    column/32<160 ∧ column%32/4<8 ∧ column%4<4 ∧ column/32*32+(column%32/4)*4+column%4=column := by omega

theorem output_bfloat_error (trace : Trace load before base words k scale input) (loads : LoadContract load)
    (aligned : base%4=0) (address : base+16384 ≤ 2^64) (bits : k=2 ∨ k=3 ∨ k=4)
    (column : Nat) (hc : column<5120) (reduce : SimdReduction) (hardware : GateUpFlushToZero.SimdContract reduce)
    (convert : Float32 → Float32) (conversion : BFloat16.RneContract convert)
    (hf : DownFlushToZero.Finite words k scale input column hardware.tree)
    (hb : FloatLib.Floats.Formats.BinaryInterchange.Model.isFinite
      (BFloat16.narrow (reduce (fun lane => DownFlushToZero.partialSum words k scale input lane.val column)))=true) :
    |real (output trace reduce convert column)-DownReduction.dotProduct words k scale input column| ≤
      DownFlushToZero.budget words k scale input column hardware.tree+
        BFloat16.epsilon (real (reduce (fun lane => DownFlushToZero.partialSum words k scale input lane.val column))) := by
  rw [output_correct trace loads aligned address bits reduce convert column hc]
  have numeric := DownScheduled.output_bfloat_error load loads (fun ty => FloatMemory.view (before ty)) base aligned address
    words k bits scale input (fun ty => (trace.threadgroup ty).toBytes.toScheduled) column hc reduce hardware convert conversion hf hb
  rw [DownScheduled.output_correct load loads _ base aligned address words k bits scale input _ reduce convert column hc] at numeric
  exact numeric

end Inference.Kernels.Trellis.DownDevice
