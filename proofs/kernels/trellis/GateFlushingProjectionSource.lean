import kernels.trellis.GateFlushingLaneSource
namespace Inference.Kernels.Trellis.GateFlushingProjectionSource
open Contracts.Mlx Contracts.Mlx.M1Max PackedArrayMaterialization GateAccumulateSource GateProjectionSource
set_option maxRecDepth 10000

-- The parsed addition is rounded before the explicit SIMD collective.
-- FTZ here interprets that addition; the standard source module is untouched.
def evaluateReduction (state : Fin 32 → Dual) (reduce : DownExecution.SimdReduction) (code : Reduction) : Option Float32 := do
  if code.target="gate" ∨ code.target="up" then
    let first ←field state code.first
    let second ←field state code.second
    pure (reduce (fun lane => FlushToZero.add (first lane) (second lane)))
  else none

def reductions (state : Fin 32 → Dual) (reduce : DownExecution.SimdReduction) : Option (Float32 × Float32) := do
  let gate ←evaluateReduction state reduce (←parseReduction gateSource)
  let up ←evaluateReduction state reduce (←parseReduction upSource)
  pure (gate,up)

theorem reductions_correct (state : Fin 32 → Dual) (reduce : DownExecution.SimdReduction) :
    reductions state reduce=some
      (reduce (fun lane => FlushToZero.add (state lane).1.1 (state lane).1.2),
       reduce (fun lane => FlushToZero.add (state lane).2.1 (state lane).2.2)) := by
  have gateParse : parseReduction gateSource=some (reductionAST false) := parsed_reductions false
  have upParse : parseReduction upSource=some (reductionAST true) := parsed_reductions true
  simp [reductions,gateParse,upParse,evaluateReduction,reductionAST,field]

variable {activation : Fin 5120 → ArrayStorage.BF} {source : ArrayStorage.BFBuffer activation}
  {tableBase inputBase : Nat}

def states (input : GateInput kg ku) (actual : GateInputSource.Execution source tableBase inputBase)
    (row : Nat) (load : ThreadgroupLoad) : Fin 32 → Dual := fun lane =>
  (GateFlushingLaneSource.initializedLane input actual row lane.val load).getD ((0,0),(0,0))

theorem state_sums (input : GateInput kg ku) (actual : GateInputSource.Execution source tableBase inputBase)
    (row : Nat) (rowBound : row<17408) (load : ThreadgroupLoad) (hardware : LoadContract load) (lane : Fin 32) :
    (FlushToZero.add (states input actual row load lane).1.1 (states input actual row load lane).1.2,
     FlushToZero.add (states input actual row load lane).2.1 (states input actual row load lane).2.2)=
      (GateUpFlushToZero.referenceLane (input.matrix false) kg (GateLaneBridge.scale input false) (ArrayStorage.bfWords activation) row lane.val,
       GateUpFlushToZero.referenceLane (input.matrix true) ku (GateLaneBridge.scale input true) (ArrayStorage.bfWords activation) row lane.val) := by
  have bridge:=GateFlushingLaneSource.lane_sums input actual row lane.val rowBound lane.isLt load hardware
  unfold GateFlushingLaneSource.laneSums at bridge
  exact getD_map _ _ _ bridge ((0,0),(0,0))

def projection (input : GateInput kg ku) (actual : GateInputSource.Execution source tableBase inputBase)
    (row : Nat) (load : ThreadgroupLoad) (reduce : DownExecution.SimdReduction) : Option (Float32 × Float32) :=
  reductions (states input actual row load) reduce

theorem projection_correct (input : GateInput kg ku) (actual : GateInputSource.Execution source tableBase inputBase)
    (row : Nat) (rowBound : row<17408) (load : ThreadgroupLoad) (hardware : LoadContract load)
    (reduce : DownExecution.SimdReduction) :
    projection input actual row load reduce=some
      (reduce (fun lane => GateUpFlushToZero.referenceLane (input.matrix false) kg (GateLaneBridge.scale input false)
        (ArrayStorage.bfWords activation) row lane.val),
       reduce (fun lane => GateUpFlushToZero.referenceLane (input.matrix true) ku (GateLaneBridge.scale input true)
        (ArrayStorage.bfWords activation) row lane.val)) := by
  rw [projection,reductions_correct]
  apply congrArg some
  apply Prod.ext
  · apply congrArg reduce
    funext lane
    exact congrArg Prod.fst (state_sums input actual row rowBound load hardware lane)
  · apply congrArg reduce
    funext lane
    exact congrArg Prod.snd (state_sums input actual row rowBound load hardware lane)

end Inference.Kernels.Trellis.GateFlushingProjectionSource
