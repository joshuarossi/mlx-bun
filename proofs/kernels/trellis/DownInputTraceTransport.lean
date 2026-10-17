import kernels.trellis.DownInputCongruence
import kernels.trellis.DownOutput
namespace Inference.Kernels.Trellis.DownInputTraceTransport
open Contracts.Mlx Contracts.Mlx.M1Max DownCodebook
set_option maxRecDepth 10000

theorem lane_eq (load : ThreadgroupLoad) (memory : WordMemory) (base : Nat)
    (words : DownExecution.PackedMatrix) (k : Nat) (scale input reference : Nat → Float32)
    (same : ∀ row, row<17408 → input row=reference row) (ty sg lane index : Nat) :
    DownFlushToZero.laneSum load memory base words k scale input ty sg lane index=
      DownFlushToZero.laneSum load memory base words k scale reference ty sg lane index := by
  unfold DownFlushToZero.laneSum
  rw [pairedRows_correct,pairedRows_correct]
  apply DownExecution.scalarRows_congr
  intro row lower upper acc
  have yBound : ty%32<32 := Nat.mod_lt _ (by decide)
  have splitBound : sg%4<4 := Nat.mod_lt _ (by decide)
  rw [same row (by omega)]

theorem computations_eq (load : ThreadgroupLoad) (memory : ByteMemory.Bytes) (base : Nat)
    (words : DownExecution.PackedMatrix) (k : Nat) (scale input reference : Nat → Float32)
    (same : ∀ row, row<17408 → input row=reference row) (ty : Nat) :
    DownReadBarrier.computations load memory base words k scale input ty=
      DownReadBarrier.computations load memory base words k scale reference ty := by
  unfold DownReadBarrier.computations
  apply congrArg (DownBarrier.programs base)
  funext sg lane index
  exact lane_eq load (FloatMemory.view memory) base words k scale input reference same ty sg lane index

-- Transport only the total mathematical input view. Every native schedule,
-- read state, store payload, barrier and byte heap remains exactly the same.
def readTrace (trace : DownReadBarrier.Trace load before base words k scale input ty)
    (reference : Nat → Float32) (same : ∀ row, row<17408 → input row=reference row) :
    DownReadBarrier.Trace load before base words k scale reference ty where
  tableSchedule := trace.tableSchedule
  tableRemaining := trace.tableRemaining
  tableExecution := trace.tableExecution
  tableBarrier := trace.tableBarrier
  readSchedule := trace.readSchedule
  readAfter := trace.readAfter
  readExecution := by
    simpa only [computations_eq load _ base words k scale input reference same ty] using trace.readExecution
  readBarrier := by
    simpa only [computations_eq load _ base words k scale input reference same ty] using trace.readBarrier
  scratchSchedule := trace.scratchSchedule
  scratchRemaining := trace.scratchRemaining
  scratchExecution := by
    simpa only [computations_eq load _ base words k scale input reference same ty] using trace.scratchExecution
  scratchBarrier := trace.scratchBarrier

theorem read_value (trace : DownReadBarrier.Trace load before base words k scale input ty)
    (reference : Nat → Float32) (same : ∀ row, row<17408 → input row=reference row) (column : Nat) :
    (readTrace trace reference same).value column=trace.value column := rfl

def deviceTrace (trace : DownDevice.Trace load before base words k scale input)
    (reference : Nat → Float32) (same : ∀ row, row<17408 → input row=reference row) :
    DownDevice.Trace load before base words k scale reference where
  threadgroup := fun ty => readTrace (trace.threadgroup ty) reference same
  partialBefore := trace.partialBefore
  partialBase := trace.partialBase
  partialAligned := trace.partialAligned
  partialBounded := trace.partialBounded
  schedule := trace.schedule
  remaining := trace.remaining
  execution := trace.execution
  completed := trace.completed

theorem device_memory (trace : DownDevice.Trace load before base words k scale input)
    (reference : Nat → Float32) (same : ∀ row, row<17408 → input row=reference row) :
    (deviceTrace trace reference same).memory=trace.memory := rfl

theorem device_output (trace : DownDevice.Trace load before base words k scale input)
    (reference : Nat → Float32) (same : ∀ row, row<17408 → input row=reference row)
    (reduce : DownExecution.SimdReduction) (convert : Float32 → Float32) (column : Nat) :
    DownDevice.output (deviceTrace trace reference same) reduce convert column=
      DownDevice.output trace reduce convert column := rfl

-- Relabel checkpoint parameter functions only after their original-storage
-- attachment equalities have been established. This retains the native trace.
def parameters (trace : DownDevice.Trace load before base words k scale input)
    (referenceWords : DownExecution.PackedMatrix) (referenceScale : Nat → Float32)
    (sameWords : referenceWords=words) (sameScale : referenceScale=scale) :
    DownDevice.Trace load before base referenceWords k referenceScale input := by
  cases sameWords
  cases sameScale
  exact trace

theorem parameters_memory (trace : DownDevice.Trace load before base words k scale input)
    (referenceWords : DownExecution.PackedMatrix) (referenceScale : Nat → Float32)
    (sameWords : referenceWords=words) (sameScale : referenceScale=scale) :
    (parameters trace referenceWords referenceScale sameWords sameScale).memory=trace.memory := by
  cases sameWords
  cases sameScale
  rfl

def parametersOutput (trace : DownDevice.Trace load before base words k scale input)
    (referenceWords : DownExecution.PackedMatrix) (referenceScale : Nat → Float32)
    (sameWords : referenceWords=words) (sameScale : referenceScale=scale)
    (reduce : DownExecution.SimdReduction) (destination : DownOutput.Trace (DownOutput.foldValues trace reduce)) :
    DownOutput.Trace (DownOutput.foldValues (parameters trace referenceWords referenceScale sameWords sameScale) reduce) := by
  cases sameWords
  cases sameScale
  exact destination

theorem parameters_output_memory (trace : DownDevice.Trace load before base words k scale input)
    (referenceWords : DownExecution.PackedMatrix) (referenceScale : Nat → Float32)
    (sameWords : referenceWords=words) (sameScale : referenceScale=scale)
    (reduce : DownExecution.SimdReduction) (destination : DownOutput.Trace (DownOutput.foldValues trace reduce)) :
    (parametersOutput trace referenceWords referenceScale sameWords sameScale reduce destination).memory=destination.memory := by
  cases sameWords
  cases sameScale
  rfl

theorem parameters_output_fields (trace : DownDevice.Trace load before base words k scale input)
    (referenceWords : DownExecution.PackedMatrix) (referenceScale : Nat → Float32)
    (sameWords : referenceWords=words) (sameScale : referenceScale=scale)
    (reduce : DownExecution.SimdReduction) (destination : DownOutput.Trace (DownOutput.foldValues trace reduce)) :
    let result := parametersOutput trace referenceWords referenceScale sameWords sameScale reduce destination
    result.before=destination.before ∧ result.base=destination.base ∧
      result.schedule=destination.schedule ∧ result.remaining=destination.remaining := by
  cases sameWords
  cases sameScale
  exact ⟨rfl,rfl,rfl,rfl⟩

end Inference.Kernels.Trellis.DownInputTraceTransport
