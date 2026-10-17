import kernels.trellis.CodebookBarrier
import kernels.trellis.DownFlushToZero

namespace Inference.Kernels.Trellis.DownBarrier
open Contracts.Mlx Contracts.Mlx.M1Max
open DownExecution (PackedMatrix scratchMemory scalarRows_congr)

def programs (base : Nat) (values : Nat → Nat → Nat → Float32) : List (List Memory.Store) :=
  (List.range 8).flatMap fun sg => (List.range 32).map fun lane =>
    (List.range 16).map fun i => DownMemory.entry base values sg lane i

theorem flatten_programs (base : Nat) (values : Nat → Nat → Nat → Float32) :
    (programs base values).flatten=DownMemory.stores base values := by
  simp [programs, DownMemory.stores, List.flatMap, List.flatten_flatten, List.map_map, Function.comp_def]

theorem scratch_written (before : WordMemory) (base : Nat) (values : Nat → Nat → Nat → Float32)
    (schedule : List Memory.Store) (remaining : List (List Memory.Store))
    (execution : ThreadgroupWrites.Executes (programs base values) schedule remaining)
    (barrier : ThreadgroupWrites.AtBarrier remaining) (j : Nat) (hj : j<4096) :
    Memory.execute schedule before (base/4+j) = scratchMemory values j := by
  have order := ThreadgroupWrites.completed_schedule execution barrier
  rw [flatten_programs] at order
  exact DownMemory.scratch_written before base values schedule order j hj

-- Each phase accepts any legal interleaving. The first barrier exposes the
-- codebook; the later barrier exposes all 4096 partials before their reads.
-- laneSum models the intervening read/computation phase. Its completion and
-- the native barriers' implementation still require execution correspondence.
theorem threadgroup_correct (load : ThreadgroupLoad) (hardware : LoadContract load)
    (before : WordMemory) (base : Nat) (aligned : base%4=0) (address : base+16384≤2^64)
    (words : PackedMatrix) (k : Nat) (bits : k=2 ∨ k=3 ∨ k=4)
    (scale input : Nat → Float32) (ty c : Nat) (column : c<1024)
    (tableSchedule : List Memory.Store) (tableRemaining : List (List Memory.Store))
    (tableExecution : ThreadgroupWrites.Executes (CodebookBarrier.programs base 256) tableSchedule tableRemaining)
    (tableBarrier : ThreadgroupWrites.AtBarrier tableRemaining)
    (scratchSchedule : List Memory.Store) (scratchRemaining : List (List Memory.Store))
    (scratchExecution : ThreadgroupWrites.Executes
      (programs base (DownFlushToZero.laneSum load (Memory.execute tableSchedule before) base words k scale input ty))
      scratchSchedule scratchRemaining)
    (scratchBarrier : ThreadgroupWrites.AtBarrier scratchRemaining) :
    DownFlushToZero.firstStage
      (fun j => Memory.execute scratchSchedule (Memory.execute tableSchedule before) (base/4+j)) c =
      DownFlushToZero.partialSum words k scale input (ty%32) (DownCodebook.column ty c) := by
  let table := Memory.execute tableSchedule before
  let values := DownFlushToZero.laneSum load table base words k scale input ty
  have initialized := CodebookBarrier.initialized before base 256 (Or.inl rfl)
    tableSchedule tableRemaining tableExecution tableBarrier
  have reads : DownFlushToZero.firstStage
      (fun j => Memory.execute scratchSchedule table (base/4+j)) c =
      DownFlushToZero.firstStage (scratchMemory values) c := by
    unfold DownFlushToZero.firstStage
    apply scalarRows_congr
    intro s _ hs acc
    dsimp only
    rw [scratch_written table base values scratchSchedule scratchRemaining scratchExecution scratchBarrier _ (by omega)]
  exact reads.trans (DownFlushToZero.first_correct load hardware table base aligned address initialized
    words k bits scale input ty c column)

end Inference.Kernels.Trellis.DownBarrier
