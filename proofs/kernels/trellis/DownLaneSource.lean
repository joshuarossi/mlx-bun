import kernels.trellis.DownLaneFold
import kernels.trellis.DownFlushToZero
namespace Inference.Kernels.Trellis.DownLaneSource
open Contracts.Mlx Contracts.Mlx.M1Max DownLoopSource DownStepSource
open FloatLib FloatLib.Floats FloatLib.Floats.Formats.BinaryInterchange
set_option maxRecDepth 10000

def activationValue (values : Fin 17408 → ArrayStorage.BF) (row : Nat) : Float32 :=
  BFloat16.widen (Model.ofBits (ArrayStorage.bfWords values row))

theorem activation_value (values : Fin 17408 → ArrayStorage.BF) (row : Nat) (bound : row<17408) :
    BFloat16.widen (values ⟨row,bound⟩)=activationValue values row := by
  unfold activationValue ArrayStorage.bfWords
  rw [dite_eq_left bound]
  rfl

def scalarStep (ops : Operations) (input : PackedArrayDownMaterialization.Input k)
    (values : Fin 17408 → ArrayStorage.BF) (block lane : Nat)
    (load : ThreadgroupLoad) (memory : WordMemory) (base row column : Nat) (previous : Float32) : Float32 :=
  ops.fma (ops.mul (CodebookLoad.read load memory base
    (DownCodebook.Lane.alignedWord (input.matrix row block) k lane) (column*k))
    (Models.Qwen.CheckpointTrellis.scale input.scales row)) (activationValue values row) previous

def pointStep (ops : Operations) (input : PackedArrayDownMaterialization.Input k)
    {values : Fin 17408 → ArrayStorage.BF} (activation : ArrayStorage.BFBuffer values)
    (start block lane : Nat) (load : ThreadgroupLoad) (memory : WordMemory) (base : Nat)
    (point : Event) (current : Nat → Float32) : Option (Nat → Float32) :=
  (memoryStep ops input activation start point.r point.u block lane point.i point.paired load memory base (current point.i)).map
    (fun result => fun column => if column=result.1 then result.2 else current column)

theorem point_step (ops : Operations) (input : PackedArrayDownMaterialization.Input k)
    {values : Fin 17408 → ArrayStorage.BF} (activation : ArrayStorage.BFBuffer values)
    (start block lane : Nat) (startBound : start+136≤17408) (blockBound : block<20) (laneBound : lane<16)
    (load : ThreadgroupLoad) (memory : WordMemory) (base : Nat)
    (point : Event) (member : point∈orderedEvents) (current : Nat → Float32) :
    pointStep ops input activation start block lane load memory base point current=some
      (DownLaneFold.action (scalarStep ops input values block lane load memory base) start current point) := by
  have bounds:=event_bounds point member
  unfold pointStep
  rw [bounds.2.2.2.2.1]
  have pairBound : row1 start point.r true<17408 := by unfold row1; simp only [ite_true]; omega
  rw [memory_step ops input activation start point.r point.u block lane point.i true pairBound bounds.2.2.1 blockBound laneBound bounds.2.2.2.1 load memory base,
    Option.map_some]
  simp only [ite_true]
  rw [activation_value values (start+point.r+point.u) (by omega)]
  rfl

attribute [local irreducible] pointStep DownLaneFold.action

def memoryLane (ops : Operations) (input : PackedArrayDownMaterialization.Input k)
    {values : Fin 17408 → ArrayStorage.BF} (activation : ArrayStorage.BFBuffer values)
    (ty sg lane : Nat) (load : ThreadgroupLoad) (memory : WordMemory) (base : Nat)
    (initial : Nat → Float32) : Option (Nat → Float32) :=
  (DownDispatchSource.dispatch k ty sg lane).bind (fun point =>
    (events k ty sg lane).bind (fun points => points.foldlM
      (fun current event => pointStep ops input activation point.2.2.toNat point.2.1.toNat (lane%16) load memory base event current) initial))

theorem memory_lane (ops : Operations) (input : PackedArrayDownMaterialization.Input k)
    {values : Fin 17408 → ArrayStorage.BF} (activation : ArrayStorage.BFBuffer values)
    (ty sg lane : Nat) (tyBound : ty<160) (sgBound : sg<8) (laneBound : lane<32)
    (load : ThreadgroupLoad) (memory : WordMemory) (base : Nat) (initial : Nat → Float32) :
    memoryLane ops input activation ty sg lane load memory base initial=some
      (orderedEvents.foldl (DownLaneFold.action
        (scalarStep ops input values ((2*(ty/32)+sg/4)*2+lane/16) (lane%16) load memory base)
        ((ty%32+32*(sg%4))*136)) initial) := by
  have splitBound : ty%32+32*(sg%4)<128 := by omega
  have blockBound : (2*(ty/32)+sg/4)*2+lane/16<20 := by omega
  have startBound : (ty%32+32*(sg%4))*136+136≤17408 := by omega
  have blockSmall : (2*(ty/32)+sg/4)*2+lane/16<2^32 := by omega
  have startSmall : (ty%32+32*(sg%4))*136<2^32 := by omega
  rw [memoryLane,DownDispatchSource.dispatch_selected k ty sg lane input.valid tyBound sgBound laneBound,Option.bind_some,
    events_selected k ty sg lane input.valid tyBound sgBound laneBound,Option.bind_some]
  simp only [BitVec.toNat_ofNat,Nat.mod_eq_of_lt blockSmall,Nat.mod_eq_of_lt startSmall]
  exact GateLoopSource.fold_exact orderedEvents _ _
    (fun point member current => point_step ops input activation _ _ _ startBound blockBound (Nat.mod_lt _ (by decide)) load memory base point member current) initial

theorem reference_lane (ops : Operations) (input : PackedArrayDownMaterialization.Input k)
    {values : Fin 17408 → ArrayStorage.BF} (activation : ArrayStorage.BFBuffer values)
    (ty sg lane column : Nat) (tyBound : ty<160) (sgBound : sg<8) (laneBound : lane<32) (columnBound : column<16)
    (load : ThreadgroupLoad) (memory : WordMemory) (base : Nat) (initial : Nat → Float32) :
    (memoryLane ops input activation ty sg lane load memory base initial).map (fun state => state column)=some
      (DownCodebook.pairedRows
        (fun row previous => scalarStep ops input values ((2*(ty/32)+sg/4)*2+lane/16) (lane%16) load memory base row column previous)
        ((ty%32+32*(sg%4))*136) 68 (initial column)) := by
  rw [memory_lane ops input activation ty sg lane tyBound sgBound laneBound load memory base initial,Option.map_some,
    DownLaneFold.ordered_fold _ _ column columnBound]

theorem standard_lane (input : PackedArrayDownMaterialization.Input k)
    {values : Fin 17408 → ArrayStorage.BF} (activation : ArrayStorage.BFBuffer values)
    (ty sg lane column : Nat) (tyBound : ty<160) (sgBound : sg<8) (laneBound : lane<32) (columnBound : column<16)
    (load : ThreadgroupLoad) (memory : WordMemory) (base : Nat) :
    (memoryLane standard input activation ty sg lane load memory base (fun _ => 0)).map (fun state => state column)=some
      (DownExecution.laneSum load memory base input.matrix k (Models.Qwen.CheckpointTrellis.scale input.scales)
        (activationValue values) ty sg lane column) := by
  rw [reference_lane standard input activation ty sg lane column tyBound sgBound laneBound columnBound load memory base]
  rfl

theorem flushing_lane (input : PackedArrayDownMaterialization.Input k)
    {values : Fin 17408 → ArrayStorage.BF} (activation : ArrayStorage.BFBuffer values)
    (ty sg lane column : Nat) (tyBound : ty<160) (sgBound : sg<8) (laneBound : lane<32) (columnBound : column<16)
    (load : ThreadgroupLoad) (memory : WordMemory) (base : Nat) :
    (memoryLane flushing input activation ty sg lane load memory base (fun _ => 0)).map (fun state => state column)=some
      (DownFlushToZero.laneSum load memory base input.matrix k (Models.Qwen.CheckpointTrellis.scale input.scales)
        (activationValue values) ty sg lane column) := by
  rw [reference_lane flushing input activation ty sg lane column tyBound sgBound laneBound columnBound load memory base]
  rfl
end Inference.Kernels.Trellis.DownLaneSource
