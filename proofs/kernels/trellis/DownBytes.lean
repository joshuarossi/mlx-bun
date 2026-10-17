import contracts.mlx.FloatMemory
import kernels.trellis.DownScheduled

namespace Inference.Kernels.Trellis.DownBytes
open Contracts.Mlx Contracts.Mlx.M1Max
open DownExecution (PackedMatrix SimdReduction)

-- The second phase reuses the same byte storage. Its values come from the
-- codebook bytes written by the completed first phase.
structure Trace (load : ThreadgroupLoad) (before : ByteMemory.Bytes) (base : Nat)
    (words : PackedMatrix) (k : Nat) (scale input : Nat → Float32) (ty : Nat) where
  tableSchedule : List Memory.Store
  tableRemaining : List (List Memory.Store)
  tableExecution : ThreadgroupWrites.Executes (CodebookBarrier.programs base 256) tableSchedule tableRemaining
  tableBarrier : ThreadgroupWrites.AtBarrier tableRemaining
  scratchSchedule : List Memory.Store
  scratchRemaining : List (List Memory.Store)
  scratchExecution : ThreadgroupWrites.Executes
    (DownBarrier.programs base (DownFlushToZero.laneSum load
      (FloatMemory.view (FloatMemory.execute tableSchedule before)) base words k scale input ty))
    scratchSchedule scratchRemaining
  scratchBarrier : ThreadgroupWrites.AtBarrier scratchRemaining

def Trace.canonical (load : ThreadgroupLoad) (before : ByteMemory.Bytes) (base : Nat)
    (words : PackedMatrix) (k : Nat) (scale input : Nat → Float32) (ty : Nat) : Trace load before base words k scale input ty :=
  let tablePrograms := CodebookBarrier.programs base 256
  let scratchPrograms := DownBarrier.programs base (DownFlushToZero.laneSum load
    (FloatMemory.view (FloatMemory.execute tablePrograms.flatten before)) base words k scale input ty)
  ⟨tablePrograms.flatten, List.replicate tablePrograms.length [],
    ThreadgroupWrites.canonical tablePrograms, ThreadgroupWrites.canonical_barrier tablePrograms,
    scratchPrograms.flatten, List.replicate scratchPrograms.length [],
    ThreadgroupWrites.canonical scratchPrograms, ThreadgroupWrites.canonical_barrier scratchPrograms⟩

def Trace.toScheduled (trace : Trace load before base words k scale input ty) :
    DownScheduled.Trace load (FloatMemory.view before) base words k scale input ty where
  tableSchedule := trace.tableSchedule
  tableRemaining := trace.tableRemaining
  tableExecution := trace.tableExecution
  tableBarrier := trace.tableBarrier
  scratchSchedule := trace.scratchSchedule
  scratchRemaining := trace.scratchRemaining
  scratchExecution := by simpa only [FloatMemory.execute_view] using trace.scratchExecution
  scratchBarrier := trace.scratchBarrier

def Trace.value (trace : Trace load before base words k scale input ty) (column : Nat) : Float32 :=
  DownFlushToZero.firstStage
    (fun j => FloatMemory.load (FloatMemory.execute trace.scratchSchedule
      (FloatMemory.execute trace.tableSchedule before)) (base+4*j)) column

theorem Trace.value_eq (trace : Trace load before base words k scale input ty) (aligned : base%4=0) (column : Nat) :
    trace.value column=trace.toScheduled.value column := by
  unfold Trace.value DownScheduled.Trace.value
  apply congrArg (fun values => DownFlushToZero.firstStage values column)
  funext j
  rw [FloatMemory.execute_load _ _ _ (by omega), FloatMemory.execute_view,
    show (base+4*j)/4=base/4+j by omega]
  rfl

theorem Trace.correct (trace : Trace load before base words k scale input ty) (hardware : LoadContract load)
    (aligned : base%4=0) (address : base+16384 ≤ 2^64) (bits : k=2 ∨ k=3 ∨ k=4)
    (column : Nat) (hc : column<1024) :
    trace.value column=DownFlushToZero.partialSum words k scale input (ty%32) (DownCodebook.column ty column) := by
  rw [Trace.value_eq _ aligned]
  exact trace.toScheduled.correct hardware aligned address bits column hc

def output (load : ThreadgroupLoad) (before : Nat → ByteMemory.Bytes) (base : Nat)
    (words : PackedMatrix) (k : Nat) (scale input : Nat → Float32)
    (traces : ∀ ty, Trace load (before ty) base words k scale input ty)
    (reduce : SimdReduction) (convert : Float32 → Float32) (column : Nat) : Float32 :=
  convert (reduce (fun y => (traces (32*(column/1024)+y.val)).value (column%1024)))

theorem output_eq (load : ThreadgroupLoad) (before : Nat → ByteMemory.Bytes) (base : Nat) (aligned : base%4=0)
    (words : PackedMatrix) (k : Nat) (scale input : Nat → Float32)
    (traces : ∀ ty, Trace load (before ty) base words k scale input ty)
    (reduce : SimdReduction) (convert : Float32 → Float32) (column : Nat) :
    output load before base words k scale input traces reduce convert column=
      DownScheduled.output load (fun ty => FloatMemory.view (before ty)) base words k scale input
        (fun ty => (traces ty).toScheduled) reduce convert column := by
  unfold output DownScheduled.output
  apply congrArg convert
  apply congrArg reduce
  funext y
  exact Trace.value_eq _ aligned _

theorem output_correct (load : ThreadgroupLoad) (hardware : LoadContract load)
    (before : Nat → ByteMemory.Bytes) (base : Nat) (aligned : base%4=0) (address : base+16384 ≤ 2^64)
    (words : PackedMatrix) (k : Nat) (bits : k=2 ∨ k=3 ∨ k=4) (scale input : Nat → Float32)
    (traces : ∀ ty, Trace load (before ty) base words k scale input ty)
    (reduce : SimdReduction) (convert : Float32 → Float32) (column : Nat) (hc : column<5120) :
    output load before base words k scale input traces reduce convert column=
      convert (reduce (fun y => DownFlushToZero.partialSum words k scale input y.val column)) := by
  rw [output_eq load before base aligned]
  exact DownScheduled.output_correct load hardware _ base aligned address words k bits scale input _ reduce convert column hc

end Inference.Kernels.Trellis.DownBytes
