import contracts.mlx.ReadOnlyThreads
import kernels.trellis.DownBytes
import kernels.trellis.WriteOwnership

namespace Inference.Kernels.Trellis.DownReadBarrier
open Contracts.Mlx Contracts.Mlx.M1Max
open DownExecution (PackedMatrix)

@[irreducible] def computations (load : ThreadgroupLoad) (table : ByteMemory.Bytes) (base : Nat)
    (words : PackedMatrix) (k : Nat) (scale input : Nat → Float32) (ty : Nat) : List (List Memory.Store) :=
  DownBarrier.programs base (DownFlushToZero.laneSum load (FloatMemory.view table) base words k scale input ty)

-- The read phase performs no stores. Each thread must finish computing its
-- partials before the barrier releases any overwrite of the shared table.
-- This models phase ordering; native instruction/barrier correspondence is
-- still supplied by the target's execution contract.
structure Trace (load : ThreadgroupLoad) (before : ByteMemory.Bytes) (base : Nat)
    (words : PackedMatrix) (k : Nat) (scale input : Nat → Float32) (ty : Nat) where
  tableSchedule : List Memory.Store
  tableRemaining : List (List Memory.Store)
  tableExecution : ThreadgroupWrites.Executes (CodebookBarrier.programs base 256) tableSchedule tableRemaining
  tableBarrier : ThreadgroupWrites.AtBarrier tableRemaining
  readSchedule : List Nat
  readAfter : ReadOnlyThreads.State (List Memory.Store)
  readExecution : ReadOnlyThreads.Executes
    (computations load (FloatMemory.execute tableSchedule before) base words k scale input ty).length
    (fun thread => ((computations load (FloatMemory.execute tableSchedule before) base words k scale input ty)[thread]?).getD [])
    ReadOnlyThreads.initial readSchedule readAfter
  readBarrier : ReadOnlyThreads.AtBarrier
    (computations load (FloatMemory.execute tableSchedule before) base words k scale input ty).length readAfter
  scratchSchedule : List Memory.Store
  scratchRemaining : List (List Memory.Store)
  scratchExecution : ThreadgroupWrites.Executes
    (ReadOnlyThreads.values (computations load (FloatMemory.execute tableSchedule before) base words k scale input ty).length readAfter [])
    scratchSchedule scratchRemaining
  scratchBarrier : ThreadgroupWrites.AtBarrier scratchRemaining

theorem Trace.completed_reads (trace : Trace load before base words k scale input ty) :
    ReadOnlyThreads.values (computations load (FloatMemory.execute trace.tableSchedule before) base words k scale input ty).length
      trace.readAfter [] = computations load (FloatMemory.execute trace.tableSchedule before) base words k scale input ty :=
  ReadOnlyThreads.completed_list _ [] trace.readExecution trace.readBarrier

def Trace.toBytes (trace : Trace load before base words k scale input ty) : DownBytes.Trace load before base words k scale input ty where
  tableSchedule := trace.tableSchedule
  tableRemaining := trace.tableRemaining
  tableExecution := trace.tableExecution
  tableBarrier := trace.tableBarrier
  scratchSchedule := trace.scratchSchedule
  scratchRemaining := trace.scratchRemaining
  scratchExecution := by
    have issued := trace.scratchExecution
    rw [trace.completed_reads] at issued
    simpa only [computations] using issued
  scratchBarrier := trace.scratchBarrier

def Trace.canonical (load : ThreadgroupLoad) (before : ByteMemory.Bytes) (base : Nat)
    (words : PackedMatrix) (k : Nat) (scale input : Nat → Float32) (ty : Nat) : Trace load before base words k scale input ty :=
  let table := CodebookBarrier.programs base 256
  let reads := computations load (FloatMemory.execute table.flatten before) base words k scale input ty
  let compute := fun thread => (reads[thread]?).getD []
  let readAfter := ReadOnlyThreads.run compute (List.range reads.length) ReadOnlyThreads.initial
  let writes := ReadOnlyThreads.values reads.length readAfter []
  ⟨table.flatten, List.replicate table.length [], ThreadgroupWrites.canonical table, ThreadgroupWrites.canonical_barrier table,
    List.range reads.length, readAfter, ReadOnlyThreads.canonical reads.length compute, ReadOnlyThreads.canonical_barrier reads.length compute,
    writes.flatten, List.replicate writes.length [], ThreadgroupWrites.canonical writes, ThreadgroupWrites.canonical_barrier writes⟩

def Trace.value (trace : Trace load before base words k scale input ty) (column : Nat) : Float32 :=
  DownFlushToZero.firstStage (fun j => FloatMemory.load (FloatMemory.execute trace.scratchSchedule
    (FloatMemory.execute trace.tableSchedule before)) (base+4*j)) column

theorem Trace.correct (trace : Trace load before base words k scale input ty) (hardware : LoadContract load)
    (aligned : base%4=0) (address : base+16384 ≤ 2^64) (bits : k=2 ∨ k=3 ∨ k=4)
    (column : Nat) (hc : column<1024) :
    trace.value column=DownFlushToZero.partialSum words k scale input (ty%32) (DownCodebook.column ty column) :=
  trace.toBytes.correct hardware aligned address bits column hc

theorem Trace.scratch_separated (trace : Trace load before base words k scale input ty) :
    Contracts.Mlx.WriteOwnership.Separated Memory.Store.word
      (ReadOnlyThreads.values (computations load (FloatMemory.execute trace.tableSchedule before) base words k scale input ty).length
        trace.readAfter []) := by
  rw [trace.completed_reads]
  unfold computations
  exact WriteOwnership.down base _

end Inference.Kernels.Trellis.DownReadBarrier
