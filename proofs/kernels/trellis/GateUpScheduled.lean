import kernels.trellis.GateUpBarrier
import kernels.trellis.GateUpFlushToZero

namespace Inference.Kernels.Trellis.GateUpScheduled
open Contracts.Mlx Contracts.Mlx.Numerics Contracts.Mlx.M1Max GateUpExecution DownCodebook
open scoped BigOperators

-- This source model reads both arrays from the completed raw threadgroup
-- memory. The input is not supplied by an independent staging oracle.
def step (load : ThreadgroupLoad) (memory : GateUpBarrier.RawMemory) (tableBase inputBase : Nat)
    (words : DownExecution.PackedMatrix) (k : Nat) (scale : Nat → Float32)
    (row run j : Nat) (acc : Accumulators) : Accumulators :=
  GateUpFlushToZero.accumulate j (FlushToZero.mul
    (CodebookLoad.read load (GateUpBarrier.floatMemory memory) tableBase
      (GateUpCodebook.runWords (words row (run/8)) run k) ((31-j)*k)) (scale row))
    (GateUpBarrier.read memory inputBase run (j/8) (j%8)) acc

theorem step_eq (load : ThreadgroupLoad) (memory : GateUpBarrier.RawMemory) (tableBase inputBase : Nat)
    (words : DownExecution.PackedMatrix) (k : Nat) (scale : Nat → Float32) (input : Nat → BitVec 16)
    (ready : GateUpBarrier.Ready memory tableBase inputBase input)
    (row run j : Nat) (hr : run<160) (hj : j<32) (acc : Accumulators) :
    step load memory tableBase inputBase words k scale row run j acc =
      GateUpFlushToZero.sourceStep load (GateUpBarrier.floatMemory memory) tableBase words k scale input row run j acc := by
  unfold step GateUpFlushToZero.sourceStep
  rw [ready.input run (j/8) (j%8) hr (by omega) (by omega)]

def run (load : ThreadgroupLoad) (memory : GateUpBarrier.RawMemory) (tableBase inputBase : Nat)
    (words : DownExecution.PackedMatrix) (k : Nat) (scale : Nat → Float32)
    (row r : Nat) (acc : Accumulators) : Accumulators :=
  tiledRows (step load memory tableBase inputBase words k scale row r) 0 4 8 acc

theorem run_eq (load : ThreadgroupLoad) (memory : GateUpBarrier.RawMemory) (tableBase inputBase : Nat)
    (words : DownExecution.PackedMatrix) (k : Nat) (scale : Nat → Float32) (input : Nat → BitVec 16)
    (ready : GateUpBarrier.Ready memory tableBase inputBase input)
    (row r : Nat) (hr : r<160) (acc : Accumulators) :
    run load memory tableBase inputBase words k scale row r acc =
      GateUpFlushToZero.sourceRun load (GateUpBarrier.floatMemory memory) tableBase words k scale input row r acc := by
  unfold run GateUpFlushToZero.sourceRun
  rw [tiledRows_correct, tiledRows_correct]
  apply DownExecution.scalarRows_congr
  intro j _ hj a
  exact step_eq load memory tableBase inputBase words k scale input ready row r j hr hj a

def lane (load : ThreadgroupLoad) (memory : GateUpBarrier.RawMemory) (tableBase inputBase : Nat)
    (words : DownExecution.PackedMatrix) (k : Nat) (scale : Nat → Float32) (row index : Nat) : Float32 :=
  let acc := scalarRows (fun i => run load memory tableBase inputBase words k scale row (index+32*i)) 0 5 (0, 0)
  FlushToZero.add acc.1 acc.2

theorem lane_eq (load : ThreadgroupLoad) (memory : GateUpBarrier.RawMemory) (tableBase inputBase : Nat)
    (words : DownExecution.PackedMatrix) (k : Nat) (scale : Nat → Float32) (input : Nat → BitVec 16)
    (ready : GateUpBarrier.Ready memory tableBase inputBase input) (row index : Nat) (hi : index<32) :
    lane load memory tableBase inputBase words k scale row index =
      GateUpFlushToZero.sourceLane load (GateUpBarrier.floatMemory memory) tableBase words k scale input row index := by
  have h := DownExecution.scalarRows_congr
    (fun i => run load memory tableBase inputBase words k scale row (index+32*i))
    (fun i => GateUpFlushToZero.sourceRun load (GateUpBarrier.floatMemory memory) tableBase words k scale input row (index+32*i))
    0 5 (0, 0) (fun i _ hi' acc => run_eq load memory tableBase inputBase words k scale input ready
      row (index+32*i) (by omega) acc)
  exact congrArg (fun acc : Accumulators => FlushToZero.add acc.1 acc.2) h

theorem source_error (load : ThreadgroupLoad) (loads : LoadContract load)
    (memory : GateUpBarrier.RawMemory) (tableBase inputBase : Nat)
    (aligned : tableBase%4=0) (address : tableBase+16384 ≤ 2^64)
    (reduce : DownExecution.SimdReduction) (hardware : GateUpFlushToZero.SimdContract reduce)
    (words : DownExecution.PackedMatrix) (k : Nat) (bits : k=2 ∨ k=3 ∨ k=4)
    (scale : Nat → Float32) (input : Nat → BitVec 16) (row : Nat)
    (ready : GateUpBarrier.Ready memory tableBase inputBase input)
    (hf : FlushedDotProduct.Finite (fun col => DownExecution.coefficient words k row col) (fun _ => scale row)
      (fun col => widen (input col)) (GateUpFlushToZero.projectionExpr hardware.tree)) :
    |real (reduce (fun index => lane load memory tableBase inputBase words k scale row index.val)) -
      ∑ c : Fin 5120, GateUpAccuracy.term words k scale input row c.val| ≤
        FlushedDotProduct.budget (fun col => DownExecution.coefficient words k row col) (fun _ => scale row)
          (fun col => widen (input col)) (fun col => |GateUpAccuracy.targetCoefficient words k row col| / 2^23)
          (GateUpFlushToZero.projectionExpr hardware.tree) := by
  have same : (fun index : Fin 32 => lane load memory tableBase inputBase words k scale row index.val) =
      (fun index => GateUpFlushToZero.sourceLane load (GateUpBarrier.floatMemory memory) tableBase words k scale input row index.val) := by
    funext index
    exact lane_eq load memory tableBase inputBase words k scale input ready row index.val index.isLt
  rw [same]
  exact GateUpFlushToZero.source_error load loads (GateUpBarrier.floatMemory memory) tableBase aligned address ready.codebook
    reduce hardware words k bits scale input row hf

theorem after_barrier_error (load : ThreadgroupLoad) (loads : LoadContract load)
    (before : GateUpBarrier.RawMemory) (tableBase inputBase : Nat)
    (aligned : tableBase%4=0) (address : tableBase+16384 ≤ 2^64)
    (separate : GateUpBarrier.Separate tableBase inputBase)
    (reduce : DownExecution.SimdReduction) (hardware : GateUpFlushToZero.SimdContract reduce)
    (words : DownExecution.PackedMatrix) (k : Nat) (bits : k=2 ∨ k=3 ∨ k=4)
    (scale : Nat → Float32) (input : Nat → BitVec 16) (row : Nat)
    (schedule : List GateUpBarrier.Store) (remaining : List (List GateUpBarrier.Store))
    (execution : ThreadgroupWrites.Executes (GateUpBarrier.programs tableBase inputBase input) schedule remaining)
    (barrier : ThreadgroupWrites.AtBarrier remaining)
    (hf : FlushedDotProduct.Finite (fun col => DownExecution.coefficient words k row col) (fun _ => scale row)
      (fun col => widen (input col)) (GateUpFlushToZero.projectionExpr hardware.tree)) :
    |real (reduce (fun index => lane load (MemoryCells.execute schedule before) tableBase inputBase words k scale row index.val)) -
      ∑ c : Fin 5120, GateUpAccuracy.term words k scale input row c.val| ≤
        FlushedDotProduct.budget (fun col => DownExecution.coefficient words k row col) (fun _ => scale row)
          (fun col => widen (input col)) (fun col => |GateUpAccuracy.targetCoefficient words k row col| / 2^23)
          (GateUpFlushToZero.projectionExpr hardware.tree) :=
  source_error load loads (MemoryCells.execute schedule before) tableBase inputBase aligned address reduce hardware
    words k bits scale input row
    (GateUpBarrier.ready before tableBase inputBase input separate schedule remaining execution barrier) hf

end Inference.Kernels.Trellis.GateUpScheduled
