import kernels.trellis.DownInitialSyntax
namespace Inference.Kernels.Trellis.DownInitialSource
open DownInitialSyntax Contracts.Mlx PackedArraySemantics
set_option maxRecDepth 10000

def integer (expression : PackedArraySyntax.Expr) : Option (BitVec 32) :=
  (evaluate 16 ⟨[("P",.signed 16)],[],[]⟩ expression).bind asUInt

def zeroLiteral : GateTailSyntax.Expr → Option Float32
  | .floating 0 _decimalPlaces => some 0
  | _ => none

def plan : Option (Nat × List Nat × Float32) :=
  (parse declarationTokens declarationSource).bind (fun declaration =>
    (parse initializerTokens initializerSource).bind (fun code =>
      if declaration.target=code.target ∧ code.counter=code.test ∧ code.counter=code.increment then
        match code.index with
        | .variable name => if name=code.counter then
            (integer declaration.dimension).bind (fun dimension =>
              (integer code.start).bind (fun start => (integer code.bound).bind (fun bound =>
                (GateLoopSource.iterations 18 start bound 1).bind (fun indices =>
                  if indices.all (fun i => decide (i<dimension.toNat)) then
                    (zeroLiteral code.value).map (fun zero => (dimension.toNat,indices,zero))
                  else none))))
            else none
        | _ => none
      else none))

theorem plan_selected : plan=some (16,List.range 16,0) := rfl

def cells : Option (Nat → Option Float32) :=
  plan.map (fun plan => plan.2.1.foldl
    (DownLaneFold.update (fun _ _ => some plan.2.2)) (fun _ => none))

theorem cell_initialized (i : Nat) (bound : i<16) :
    cells.map (fun state => state i)=some (some 0) := by
  rw [cells,plan_selected,Option.map_some,Option.map_some,DownLaneFold.columns,ite_eq_left bound]

-- Every observed source accumulator cell is initialized (above). The getD
-- merely totalizes unobserved indices outside the declared sixteen cells.
def initial : Option (Nat → Float32) := cells.map (fun state i => (state i).getD 0)

theorem initial_zero : initial=some (fun _ => 0) := by
  rw [initial,cells,plan_selected,Option.map_some,Option.map_some]
  congr 1
  funext i
  rw [DownLaneFold.columns]
  by_cases bound : i<16 <;> simp only [bound,ite_true,ite_false,Option.getD_some,Option.getD_none]

open Contracts.Mlx.M1Max DownStepSource

def lane (ops : Operations) (input : PackedArrayDownMaterialization.Input k)
    {values : Fin 17408 → ArrayStorage.BF} (activation : ArrayStorage.BFBuffer values)
    (ty sg index : Nat) (load : ThreadgroupLoad) (memory : WordMemory) (base : Nat) : Option (Nat → Float32) :=
  initial.bind (DownLaneSource.memoryLane ops input activation ty sg index load memory base)

theorem standard_lane (input : PackedArrayDownMaterialization.Input k)
    {values : Fin 17408 → ArrayStorage.BF} (activation : ArrayStorage.BFBuffer values)
    (ty sg index column : Nat) (tyBound : ty<160) (sgBound : sg<8) (laneBound : index<32) (columnBound : column<16)
    (load : ThreadgroupLoad) (memory : WordMemory) (base : Nat) :
    (lane standard input activation ty sg index load memory base).map (fun state => state column)=some
      (DownExecution.laneSum load memory base input.matrix k (Models.Qwen.CheckpointTrellis.scale input.scales)
        (DownLaneSource.activationValue values) ty sg index column) := by
  rw [lane,initial_zero,Option.bind_some]
  exact DownLaneSource.standard_lane input activation ty sg index column tyBound sgBound laneBound columnBound load memory base

theorem flushing_lane (input : PackedArrayDownMaterialization.Input k)
    {values : Fin 17408 → ArrayStorage.BF} (activation : ArrayStorage.BFBuffer values)
    (ty sg index column : Nat) (tyBound : ty<160) (sgBound : sg<8) (laneBound : index<32) (columnBound : column<16)
    (load : ThreadgroupLoad) (memory : WordMemory) (base : Nat) :
    (lane flushing input activation ty sg index load memory base).map (fun state => state column)=some
      (DownFlushToZero.laneSum load memory base input.matrix k (Models.Qwen.CheckpointTrellis.scale input.scales)
        (DownLaneSource.activationValue values) ty sg index column) := by
  rw [lane,initial_zero,Option.bind_some]
  exact DownLaneSource.flushing_lane input activation ty sg index column tyBound sgBound laneBound columnBound load memory base
end Inference.Kernels.Trellis.DownInitialSource
