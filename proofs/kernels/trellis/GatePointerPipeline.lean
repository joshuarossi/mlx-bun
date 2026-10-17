import kernels.trellis.GatePointerSource
import kernels.trellis.GateStoreSource
namespace Inference.Kernels.Trellis.GatePointerPipeline
open Contracts.Mlx Contracts.Mlx.M1Max PackedArrayMaterialization GateAccumulateSource
set_option maxRecDepth 10000
variable {activation : Fin 5120 → ArrayStorage.BF} {source : ArrayStorage.BFBuffer activation}
  {tableBase inputBase : Nat}

-- Substitute the parsed pointer/private-array producer at every actual call.
-- The following equalities are of machine state transitions, not real sums.
def pointStep (input : GateInput kg ku) (actual : GateInputSource.Execution source tableBase inputBase)
    (row : Nat) (load : ThreadgroupLoad) (point : Nat × Nat × Nat) (acc : Dual) : Option Dual := do
  let j ←GateLoopSource.column point.2.1 point.2.2 (←GateLoopSource.parseColumn GateLoopSource.columnSource)
  if j=point.2.1*8+point.2.2 then
    GatePointerSource.memoryStep input actual row point.1 point.2.1 point.2.2 load acc
  else none

theorem point_step_eq (input : GateInput kg ku) (actual : GateInputSource.Execution source tableBase inputBase)
    (row : Nat) (load : ThreadgroupLoad) (point : Nat × Nat × Nat) (runBound : point.1<160) (acc : Dual) :
    pointStep input actual row load point acc=GateLoopSource.pointStep input actual row load point acc := by
  unfold pointStep GateLoopSource.pointStep
  rw [GatePointerSource.memory_step_eq input actual row point.1 point.2.1 point.2.2 runBound]

attribute [local irreducible] pointStep GateLoopSource.pointStep GateLoopSource.referenceStep

def memoryLane (input : GateInput kg ku) (actual : GateInputSource.Execution source tableBase inputBase)
    (row lane : Nat) (load : ThreadgroupLoad) (initial : Dual) : Option Dual :=
  (GateLoopSource.events lane).bind (fun points =>
    points.foldlM (fun acc point => pointStep input actual row load point acc) initial)

theorem memory_lane_eq (input : GateInput kg ku) (actual : GateInputSource.Execution source tableBase inputBase)
    (row lane : Nat) (rowBound : row<17408) (laneBound : lane<32) (load : ThreadgroupLoad) (hardware : LoadContract load) (initial : Dual) :
    memoryLane input actual row lane load initial=GateLoopSource.memoryLane input actual row lane load initial := by
  unfold memoryLane
  rw [GateLoopSource.events_selected lane laneBound, Option.bind_some,
    GateLoopSource.memory_lane input actual row lane rowBound laneBound load hardware initial]
  exact GateLoopSource.fold_exact (GateLoopSource.orderedEvents lane) (pointStep input actual row load)
    (GateLoopSource.referenceStep (activation:=activation) input row) (by
      intro point member acc
      have bounds:=GateLoopSource.event_bounds lane laneBound point member
      rw [point_step_eq input actual row load point bounds.1]
      exact GateLoopSource.point_step input actual row rowBound load hardware point bounds acc) initial

def initializedLane (input : GateInput kg ku) (actual : GateInputSource.Execution source tableBase inputBase)
    (row lane : Nat) (load : ThreadgroupLoad) : Option Dual :=
  GateProjectionSource.initial.bind (fun initial => memoryLane input actual row lane load initial)

theorem initialized_lane_eq (input : GateInput kg ku) (actual : GateInputSource.Execution source tableBase inputBase)
    (row lane : Nat) (rowBound : row<17408) (laneBound : lane<32) (load : ThreadgroupLoad) (hardware : LoadContract load) :
    initializedLane input actual row lane load=GateProjectionSource.initializedLane input actual row lane load := by
  unfold initializedLane GateProjectionSource.initializedLane
  rw [GateProjectionSource.initial_zero, Option.bind_some]
  exact memory_lane_eq input actual row lane rowBound laneBound load hardware _

def states (input : GateInput kg ku) (actual : GateInputSource.Execution source tableBase inputBase)
    (row : Nat) (load : ThreadgroupLoad) : Fin 32 → Dual := fun lane =>
  (initializedLane input actual row lane.val load).getD ((0,0),(0,0))

theorem states_eq (input : GateInput kg ku) (actual : GateInputSource.Execution source tableBase inputBase)
    (row : Nat) (rowBound : row<17408) (load : ThreadgroupLoad) (hardware : LoadContract load) :
    states input actual row load=GateProjectionSource.states input actual row load := by
  funext lane
  unfold states GateProjectionSource.states
  rw [initialized_lane_eq input actual row lane.val rowBound lane.isLt load hardware]

def projection (input : GateInput kg ku) (actual : GateInputSource.Execution source tableBase inputBase)
    (row : Nat) (load : ThreadgroupLoad) (reduce : DownExecution.SimdReduction) : Option (Float32 × Float32) :=
  GateProjectionSource.reductions (states input actual row load) reduce

theorem projection_eq (input : GateInput kg ku) (actual : GateInputSource.Execution source tableBase inputBase)
    (row : Nat) (rowBound : row<17408) (load : ThreadgroupLoad) (hardware : LoadContract load) (reduce : DownExecution.SimdReduction) :
    projection input actual row load reduce=GateProjectionSource.projection input actual row load reduce := by
  unfold projection GateProjectionSource.projection
  rw [states_eq input actual row rowBound load hardware]

open GateTailSource (FloatOperations BF)
def output (input : GateInput kg ku) (actual : GateInputSource.Execution source tableBase inputBase)
    (row : Nat) (load : ThreadgroupLoad) (reduce : DownExecution.SimdReduction)
    (ops : FloatOperations) (expPrecise : Float32 → Float32) (expAbs : BF → BF) (split : Bool) : Option BF :=
  (projection input actual row load reduce).bind (fun pair =>
    GateTailSource.run ops expPrecise expAbs (if split then 1 else 0) pair.1 pair.2)

theorem output_eq (input : GateInput kg ku) (actual : GateInputSource.Execution source tableBase inputBase)
    (row : Nat) (rowBound : row<17408) (load : ThreadgroupLoad) (hardware : LoadContract load) (reduce : DownExecution.SimdReduction)
    (ops : FloatOperations) (expPrecise : Float32 → Float32) (expAbs : BF → BF) (split : Bool) :
    output input actual row load reduce ops expPrecise expAbs split=
      GateTailSource.output input actual row load reduce ops expPrecise expAbs (if split then 1 else 0) := by
  unfold output GateTailSource.output
  rw [projection_eq input actual row rowBound load hardware reduce]
  rfl

theorem output_value (input : GateInput kg ku) (actual : GateInputSource.Execution source tableBase inputBase)
    (row : Nat) (rowBound : row<17408) (load : ThreadgroupLoad) (hardware : LoadContract load) (reduce : DownExecution.SimdReduction)
    (ops : FloatOperations) (expPrecise : Float32 → Float32) (expAbs : BF → BF) (split : Bool) :
    output input actual row load reduce ops expPrecise expAbs split=some
      (GateStoreSource.values (activation:=activation) input reduce ops expPrecise expAbs split row) := by
  rw [output_eq input actual row rowBound load hardware reduce]
  exact GateStoreSource.output_value input actual row rowBound load hardware reduce ops expPrecise expAbs split

def thread (input : GateInput kg ku) (actual : GateInputSource.Execution source tableBase inputBase)
    (base group index : Nat) (load : ThreadgroupLoad) (reduce : DownExecution.SimdReduction)
    (ops : FloatOperations) (expPrecise : Float32 → Float32) (expAbs : BF → BF) (split : Bool) : Option (List HalfMemory.Store) := do
  let active ←GateRowSource.writer (index%32)
  if active then
    let rows ←GateRowSource.rows group (index/32)
    rows.mapM (fun row => do
      let value ←output input actual row load reduce ops expPrecise expAbs split
      pure ⟨base/2+row,value.bits⟩)
  else pure []

attribute [local irreducible] output GateRowSource.writer GateRowSource.rows

theorem thread_eq (input : GateInput kg ku) (actual : GateInputSource.Execution source tableBase inputBase)
    (base group index : Nat) (groupBound : group<160) (threadBound : index<1024)
    (load : ThreadgroupLoad) (hardware : LoadContract load) (reduce : DownExecution.SimdReduction)
    (ops : FloatOperations) (expPrecise : Float32 → Float32) (expAbs : BF → BF) (split : Bool) :
    thread input actual base group index load reduce ops expPrecise expAbs split=some
      (GateUpOutput.threadStores base (GateStoreSource.values (activation:=activation) input reduce ops expPrecise expAbs split) group index) := by
  unfold thread
  rw [GateRowSource.writer_selected ⟨index%32,Nat.mod_lt _ (by decide)⟩]
  by_cases active : index%32=0
  · simp only [active,decide_true]
    rw [GateRowSource.rows_selected group (index/32) groupBound (by omega)]
    change (GateRowSource.expected group (index/32)).mapM _=_
    rw [GateStoreSource.mapM_exact (GateRowSource.expected group (index/32)) _
      (fun row => (⟨base/2+row,(GateStoreSource.values (activation:=activation) input reduce ops expPrecise expAbs split row).bits⟩ : HalfMemory.Store)) (by
        intro row member
        obtain ⟨iteration,iterationBound,valid,equal⟩:=GateRowSource.row_member group (index/32) row member
        have bound : row<17408 := by omega
        rw [output_value input actual row bound load hardware reduce ops expPrecise expAbs split]
        rfl)]
    simp only [GateRowSource.expected,GateUpOutput.threadStores,active,ite_true,List.map_map]
    rfl
  · simp [active,GateUpOutput.threadStores]

def programs (input : GateInput kg ku) (actual : Nat → GateInputSource.Execution source tableBase inputBase)
    (base : Nat) (load : ThreadgroupLoad) (reduce : DownExecution.SimdReduction)
    (ops : FloatOperations) (expPrecise : Float32 → Float32) (expAbs : BF → BF) (split : Bool) : List (List HalfMemory.Store) :=
  ((List.range 160).product (List.range 1024)).map (fun pair =>
    (thread input (actual pair.1) base pair.1 pair.2 load reduce ops expPrecise expAbs split).getD [])

theorem programs_eq (input : GateInput kg ku) (actual : Nat → GateInputSource.Execution source tableBase inputBase)
    (base : Nat) (load : ThreadgroupLoad) (hardware : LoadContract load) (reduce : DownExecution.SimdReduction)
    (ops : FloatOperations) (expPrecise : Float32 → Float32) (expAbs : BF → BF) (split : Bool) :
    programs input actual base load reduce ops expPrecise expAbs split=
      GateStoreSource.programs input actual base load reduce ops expPrecise expAbs split := by
  rw [GateStoreSource.programs_eq input actual base load hardware]
  unfold programs GateUpOutput.programs
  apply List.map_congr_left
  intro pair member
  obtain ⟨groupBound,threadBound⟩:=List.mem_product.mp member
  rw [thread_eq input (actual pair.1) base pair.1 pair.2 (List.mem_range.mp groupBound)
    (List.mem_range.mp threadBound) load hardware reduce ops expPrecise expAbs split]
  rfl

-- The SAME completed schedule/current destination heap realizes the complete
-- pointer-derived program. No replacement output allocation or value premise.
theorem source_execution (input : GateInput kg ku) (actual : Nat → GateInputSource.Execution source tableBase inputBase)
    (load : ThreadgroupLoad) (hardware : LoadContract load) (reduce : DownExecution.SimdReduction)
    (ops : FloatOperations) (expPrecise : Float32 → Float32) (expAbs : BF → BF) (split : Bool)
    (state : GateStoreSource.Execution input actual load reduce ops expPrecise expAbs split) :
    ThreadgroupWrites.Executes (programs input actual state.base load reduce ops expPrecise expAbs split) state.schedule state.remaining := by
  rw [programs_eq input actual state.base load hardware]
  exact state.execution

theorem stored_current_bytes (input : GateInput kg ku) (actual : Nat → GateInputSource.Execution source tableBase inputBase)
    (load : ThreadgroupLoad) (hardware : LoadContract load) (reduce : DownExecution.SimdReduction)
    (ops : FloatOperations) (expPrecise : Float32 → Float32) (expAbs : BF → BF) (split : Bool)
    (state : GateStoreSource.Execution input actual load reduce ops expPrecise expAbs split)
    (row offset : Nat) (rowBound : row<17408) (offsetBound : offset<2) :
    ThreadgroupWrites.Executes (programs input actual state.base load reduce ops expPrecise expAbs split) state.schedule state.remaining ∧
    state.memory (state.base+2*row+offset)=HalfMemory.byte
      (GateStoreSource.values (activation:=activation) input reduce ops expPrecise expAbs split row).bits offset :=
  ⟨source_execution input actual load hardware reduce ops expPrecise expAbs split state,
    state.current_bytes hardware row offset rowBound offsetBound⟩
end Inference.Kernels.Trellis.GatePointerPipeline
