import kernels.trellis.DownBarrier

namespace Inference.Kernels.Trellis.DownScheduled
open Contracts.Mlx Contracts.Mlx.Numerics Contracts.Mlx.M1Max
open DownExecution (PackedMatrix SimdReduction)

-- The written phases carry their legal schedules and completed barriers.
-- Partial values are computed from the table produced by the first phase.
structure Trace (load : ThreadgroupLoad) (before : WordMemory) (base : Nat)
    (words : PackedMatrix) (k : Nat) (scale input : Nat → Float32) (ty : Nat) where
  tableSchedule : List Memory.Store
  tableRemaining : List (List Memory.Store)
  tableExecution : ThreadgroupWrites.Executes (CodebookBarrier.programs base 256) tableSchedule tableRemaining
  tableBarrier : ThreadgroupWrites.AtBarrier tableRemaining
  scratchSchedule : List Memory.Store
  scratchRemaining : List (List Memory.Store)
  scratchExecution : ThreadgroupWrites.Executes
    (DownBarrier.programs base (DownFlushToZero.laneSum load (Memory.execute tableSchedule before) base words k scale input ty))
    scratchSchedule scratchRemaining
  scratchBarrier : ThreadgroupWrites.AtBarrier scratchRemaining

def Trace.canonical (load : ThreadgroupLoad) (before : WordMemory) (base : Nat)
    (words : PackedMatrix) (k : Nat) (scale input : Nat → Float32) (ty : Nat) :
    Trace load before base words k scale input ty :=
  let tablePrograms := CodebookBarrier.programs base 256
  let scratchPrograms := DownBarrier.programs base
    (DownFlushToZero.laneSum load (Memory.execute tablePrograms.flatten before) base words k scale input ty)
  ⟨tablePrograms.flatten, List.replicate tablePrograms.length [],
    ThreadgroupWrites.canonical tablePrograms, ThreadgroupWrites.canonical_barrier tablePrograms,
    scratchPrograms.flatten, List.replicate scratchPrograms.length [],
    ThreadgroupWrites.canonical scratchPrograms, ThreadgroupWrites.canonical_barrier scratchPrograms⟩

def Trace.value (trace : Trace load before base words k scale input ty) (c : Nat) : Float32 :=
  DownFlushToZero.firstStage
    (fun j => Memory.execute trace.scratchSchedule (Memory.execute trace.tableSchedule before) (base/4+j)) c

theorem Trace.correct (trace : Trace load before base words k scale input ty) (hardware : LoadContract load)
    (aligned : base%4=0) (address : base+16384 ≤ 2^64) (bits : k=2 ∨ k=3 ∨ k=4)
    (c : Nat) (hc : c<1024) : trace.value c = DownFlushToZero.partialSum words k scale input (ty%32) (DownCodebook.column ty c) :=
  DownBarrier.threadgroup_correct load hardware before base aligned address words k bits scale input ty c hc
    trace.tableSchedule trace.tableRemaining trace.tableExecution trace.tableBarrier
    trace.scratchSchedule trace.scratchRemaining trace.scratchExecution trace.scratchBarrier

def output (load : ThreadgroupLoad) (before : Nat → WordMemory) (base : Nat)
    (words : PackedMatrix) (k : Nat) (scale input : Nat → Float32)
    (traces : ∀ ty, Trace load (before ty) base words k scale input ty)
    (reduce : SimdReduction) (convert : Float32 → Float32) (col : Nat) : Float32 :=
  convert (reduce (fun y => (traces (32*(col/1024)+y.val)).value (col%1024)))

theorem output_correct (load : ThreadgroupLoad) (loads : LoadContract load)
    (before : Nat → WordMemory) (base : Nat) (aligned : base%4=0) (address : base+16384 ≤ 2^64)
    (words : PackedMatrix) (k : Nat) (bits : k=2 ∨ k=3 ∨ k=4) (scale input : Nat → Float32)
    (traces : ∀ ty, Trace load (before ty) base words k scale input ty)
    (reduce : SimdReduction) (convert : Float32 → Float32) (col : Nat) (hc : col<5120) :
    output load before base words k scale input traces reduce convert col =
      convert (reduce (fun y => DownFlushToZero.partialSum words k scale input y.val col)) := by
  unfold output
  apply congrArg convert
  apply congrArg reduce
  funext y
  rw [Trace.correct _ loads aligned address bits _ (by omega)]
  obtain ⟨_, _, hy, hcol⟩ := DownCodebook.partial_coverage y.val col y.isLt hc
  rw [hy, hcol]

-- The scheduled-memory output inherits the original real dot-product bound,
-- including codebook approximation, flushed FP32 arithmetic and BF16 store.
theorem output_bfloat_error (load : ThreadgroupLoad) (loads : LoadContract load)
    (before : Nat → WordMemory) (base : Nat) (aligned : base%4=0) (address : base+16384 ≤ 2^64)
    (words : PackedMatrix) (k : Nat) (bits : k=2 ∨ k=3 ∨ k=4) (scale input : Nat → Float32)
    (traces : ∀ ty, Trace load (before ty) base words k scale input ty) (col : Nat) (hc : col<5120)
    (reduce : SimdReduction) (hardware : GateUpFlushToZero.SimdContract reduce)
    (convert : Float32 → Float32) (conversion : BFloat16.RneContract convert)
    (hf : DownFlushToZero.Finite words k scale input col hardware.tree)
    (hb : FloatLib.Floats.Formats.BinaryInterchange.Model.isFinite
      (BFloat16.narrow (reduce (fun y => DownFlushToZero.partialSum words k scale input y.val col)))=true) :
    |real (output load before base words k scale input traces reduce convert col)-
      DownReduction.dotProduct words k scale input col| ≤
      DownFlushToZero.budget words k scale input col hardware.tree+
        BFloat16.epsilon (real (reduce (fun y => DownFlushToZero.partialSum words k scale input y.val col))) := by
  rw [output_correct load loads before base aligned address words k bits scale input traces reduce convert col hc]
  have h := DownFlushToZero.output_bfloat_error load loads before base aligned address words k bits scale input col hc
    reduce hardware convert conversion hf hb
  rw [DownFlushToZero.output_correct load loads before base aligned address words k bits scale input reduce convert col hc] at h
  exact h

end Inference.Kernels.Trellis.DownScheduled
