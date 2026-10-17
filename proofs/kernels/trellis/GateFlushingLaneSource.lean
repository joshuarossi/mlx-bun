import kernels.trellis.GateMemoryOperations
namespace Inference.Kernels.Trellis.GateFlushingLaneSource
open Contracts.Mlx Contracts.Mlx.M1Max PackedArrayMaterialization GateAccumulateSource GateLoopSource
open DownCodebook (scalarRows)
open GateLaneBridge (fold_range fold_congr fold_pair qp_fold scale)
set_option maxRecDepth 10000

-- This is an explicit FTZ primitive interpretation of the existing parsed
-- statements. No standard/FTZ equivalence or arithmetic reassociation occurs.
theorem weight_value (input : GateInput kg ku) (row run j : Nat) (isUp : Bool) (column : j<32) :
    GateWeightOperations.value FlushToZero.mul input row run j isUp=
      FlushToZero.mul (DownExecution.coefficient (input.matrix isUp) (if isUp then ku else kg) row (run*32+j))
        (scale input isUp row) := by
  have block : (run*32+j)/256=run/8 := by omega
  have position : (run*32+j)%256=run%8*32+j := by omega
  simp only [GateWeightOperations.value,GateWeightOperations.coefficient,DownExecution.coefficient,block,position,scale]

variable {activation : Fin 5120 → ArrayStorage.BF} {source : ArrayStorage.BFBuffer activation}
  {tableBase inputBase : Nat}

def projectionStep (input : GateInput kg ku) (row : Nat) (isUp : Bool)
    (point : Nat × Nat × Nat) : GateUpExecution.Accumulators → GateUpExecution.Accumulators :=
  GateUpFlushToZero.referenceStep (input.matrix isUp) (if isUp then ku else kg) (scale input isUp)
    (ArrayStorage.bfWords activation) row point.1 (point.2.1*8+point.2.2)

def pointStep (input : GateInput kg ku) (actual : GateInputSource.Execution source tableBase inputBase)
    (row : Nat) (load : ThreadgroupLoad) (point : Nat × Nat × Nat) (acc : Dual) : Option Dual :=
  (parseColumn columnSource).bind (fun code =>
    (column point.2.1 point.2.2 code).bind (fun j =>
      if j=point.2.1*8+point.2.2 then
        GateMemoryOperations.memoryStep GateMemoryOperations.flushing input actual row point.1 point.2.1 point.2.2 load acc
      else none))

attribute [local irreducible] column parseColumn GateMemoryOperations.memoryStep

theorem point_step (input : GateInput kg ku) (actual : GateInputSource.Execution source tableBase inputBase)
    (row : Nat) (rowBound : row<17408) (load : ThreadgroupLoad) (hardware : LoadContract load)
    (point : Nat × Nat × Nat) (bounds : point.1<160 ∧ point.2.1<4 ∧ point.2.2<8) (acc : Dual) :
    pointStep input actual row load point acc=some
      (projectionStep (activation:=activation) input row false point acc.1,
        projectionStep (activation:=activation) input row true point acc.2) := by
  rw [pointStep,parsed_column,Option.bind_some,column_selected ⟨point.2.1,bounds.2.1⟩ ⟨point.2.2,bounds.2.2⟩,
    Option.bind_some,ite_eq_left rfl]
  rw [GateMemoryOperations.memory_step GateMemoryOperations.flushing input actual row point.1 point.2.1 point.2.2
    rowBound bounds.1 bounds.2.1 bounds.2.2 load hardware acc]
  simp only [GateMemoryOperations.flushing,weight_value input row point.1 (point.2.1*8+point.2.2) false (by omega),
    weight_value input row point.1 (point.2.1*8+point.2.2) true (by omega)]
  simp only [projectionStep,GateUpFlushToZero.referenceStep,GateFmaOperations.accumulate,GateUpFlushToZero.accumulate,Nat.add_assoc,ite_true]

theorem projection_fold (input : GateInput kg ku) (row lane : Nat) (isUp : Bool) (initial : GateUpExecution.Accumulators) :
    (orderedEvents lane).foldl (fun acc point => projectionStep (activation:=activation) input row isUp point acc) initial=
      scalarRows (fun i => GateUpFlushToZero.referenceRun (input.matrix isUp) (if isUp then ku else kg) (scale input isUp)
        (ArrayStorage.bfWords activation) row (lane+32*i)) 0 5 initial := by
  simp only [orderedEvents,List.foldl_flatMap,List.foldl_map,projectionStep]
  have chunks : (fun acc i => (List.range 4).foldl (fun acc q => (List.range 8).foldl
      (fun acc p => GateUpFlushToZero.referenceStep (input.matrix isUp) (if isUp then ku else kg) (scale input isUp)
        (ArrayStorage.bfWords activation) row (lane+32*i) (q*8+p) acc) acc) acc)=
      (fun acc i => GateUpFlushToZero.referenceRun (input.matrix isUp) (if isUp then ku else kg) (scale input isUp)
        (ArrayStorage.bfWords activation) row (lane+32*i) acc) := by
    funext acc i
    exact qp_fold (GateUpFlushToZero.referenceStep (input.matrix isUp) (if isUp then ku else kg) (scale input isUp)
      (ArrayStorage.bfWords activation) row (lane+32*i)) acc
  rw [chunks]
  simpa only [Nat.zero_add] using fold_range (fun i => GateUpFlushToZero.referenceRun (input.matrix isUp) (if isUp then ku else kg) (scale input isUp)
    (ArrayStorage.bfWords activation) row (lane+32*i)) 0 5 initial

def memoryLane (input : GateInput kg ku) (actual : GateInputSource.Execution source tableBase inputBase)
    (row lane : Nat) (load : ThreadgroupLoad) (initial : Dual) : Option Dual :=
  (events lane).bind (fun points => points.foldlM (fun acc point => pointStep input actual row load point acc) initial)

theorem memory_lane (input : GateInput kg ku) (actual : GateInputSource.Execution source tableBase inputBase)
    (row lane : Nat) (rowBound : row<17408) (laneBound : lane<32)
    (load : ThreadgroupLoad) (hardware : LoadContract load) (initial : Dual) :
    memoryLane input actual row lane load initial=some
      (((orderedEvents lane).foldl (fun acc point => projectionStep (activation:=activation) input row false point acc) initial.1),
       ((orderedEvents lane).foldl (fun acc point => projectionStep (activation:=activation) input row true point acc) initial.2)) := by
  rw [memoryLane,events_selected lane laneBound,Option.bind_some]
  rw [fold_exact (orderedEvents lane) (pointStep input actual row load)
    (fun point acc => (projectionStep (activation:=activation) input row false point acc.1,
      projectionStep (activation:=activation) input row true point acc.2))
    (fun point member acc => point_step input actual row rowBound load hardware point (event_bounds lane laneBound point member) acc)]
  rw [fold_pair]

def initializedLane (input : GateInput kg ku) (actual : GateInputSource.Execution source tableBase inputBase)
    (row lane : Nat) (load : ThreadgroupLoad) : Option Dual :=
  GateProjectionSource.initial.bind (memoryLane input actual row lane load)

-- The final addition's FTZ lowering is explicit, separately from the FMAs.
def laneSums (input : GateInput kg ku) (actual : GateInputSource.Execution source tableBase inputBase)
    (row lane : Nat) (load : ThreadgroupLoad) : Option (Float32 × Float32) :=
  (initializedLane input actual row lane load).map (fun acc =>
    (FlushToZero.add acc.1.1 acc.1.2,FlushToZero.add acc.2.1 acc.2.2))

theorem lane_sums (input : GateInput kg ku) (actual : GateInputSource.Execution source tableBase inputBase)
    (row lane : Nat) (rowBound : row<17408) (laneBound : lane<32)
    (load : ThreadgroupLoad) (hardware : LoadContract load) :
    laneSums input actual row lane load=some
      (GateUpFlushToZero.referenceLane (input.matrix false) kg (scale input false) (ArrayStorage.bfWords activation) row lane,
       GateUpFlushToZero.referenceLane (input.matrix true) ku (scale input true) (ArrayStorage.bfWords activation) row lane) := by
  rw [laneSums,initializedLane,GateProjectionSource.initial_zero,Option.bind_some,
    memory_lane input actual row lane rowBound laneBound load hardware,projection_fold,projection_fold]
  rfl

end Inference.Kernels.Trellis.GateFlushingLaneSource
