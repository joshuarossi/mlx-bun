import kernels.trellis.DownScratchIndex
import kernels.trellis.DownReadBarrier
import kernels.trellis.GateStoreSource
namespace Inference.Kernels.Trellis.DownScratchSource
open Contracts.Mlx Contracts.Mlx.M1Max DownScratchSyntax DownScratchIndex
set_option maxRecDepth 10000

def attachAlias (base : Nat) : Option Nat :=
  (parse aliasTokens aliasSource).bind (fun code =>
    if code.target="sums" ∧ code.source="codebook" then some base else none)

theorem alias_current (base : Nat) : attachAlias base=some base := by
  rw [attachAlias,parsed_alias,Option.bind_some]
  rfl

def body (k sg lane i base : Nat) (current : Nat → Float32) (code : StoreLoop) : Option Memory.Store :=
  if code.target="sums" then
    (target k sg lane i code).bind (fun index =>
      (valueIndex k sg lane i code).bind (fun source =>
        if source<16 ∧ index<4096 then some ⟨base/4+index,current source⟩ else none))
  else none

attribute [local irreducible] target valueIndex iterations attachAlias parse DownInitialSource.lane

theorem body_selected (k sg lane i base : Nat) (valid : k=2 ∨ k=3 ∨ k=4)
    (sgBound : sg<8) (laneBound : lane<32) (column : i<16) (current : Nat → Float32) :
    body k sg lane i base current store=some
      ⟨base/4+DownCodebook.scratch sg lane i,current i⟩ := by
  unfold body
  rw [show store.target="sums" from rfl,ite_eq_left rfl,target_selected k sg lane i valid sgBound laneBound column,
    Option.bind_some,value_selected k sg lane i valid laneBound column,Option.bind_some,
    ite_eq_left ⟨column,DownCodebook.scratch_bounds sg lane i sgBound laneBound column⟩]

def threadStores (input : PackedArrayDownMaterialization.Input k)
    {values : Fin 17408 → ArrayStorage.BF} (activation : ArrayStorage.BFBuffer values)
    (ty sg lane : Nat) (load : ThreadgroupLoad) (memory : WordMemory) (base : Nat) : Option (List Memory.Store) :=
  (DownInitialSource.lane DownStepSource.flushing input activation ty sg lane load memory base).bind (fun current =>
    (attachAlias base).bind (fun sumsBase =>
      (parse storeTokens storeSource).bind (fun code =>
        (iterations k lane code).bind (fun indices =>
          indices.mapM (fun i => body k sg lane i sumsBase current code)))))

def values (input : PackedArrayDownMaterialization.Input k) (activation : Fin 17408 → ArrayStorage.BF)
    (ty : Nat) (load : ThreadgroupLoad) (memory : WordMemory) (base : Nat) : Nat → Nat → Nat → Float32 :=
  DownFlushToZero.laneSum load memory base input.matrix k (Models.Qwen.CheckpointTrellis.scale input.scales)
    (DownLaneSource.activationValue activation) ty

theorem thread_stores (input : PackedArrayDownMaterialization.Input k)
    {activationValues : Fin 17408 → ArrayStorage.BF} (activation : ArrayStorage.BFBuffer activationValues)
    (ty sg lane : Nat) (tyBound : ty<160) (sgBound : sg<8) (laneBound : lane<32)
    (load : ThreadgroupLoad) (memory : WordMemory) (base : Nat) :
    threadStores input activation ty sg lane load memory base=some
      ((List.range 16).map (fun i => DownMemory.entry base (values input activationValues ty load memory base) sg lane i)) := by
  have selected:=iterations_closed (PackedArrayMaterialization.widthIndex k input.valid) ⟨lane,laneBound⟩
  simp only [PackedArrayMaterialization.width_index] at selected
  cases actual : DownInitialSource.lane DownStepSource.flushing input activation ty sg lane load memory base with
  | none =>
    have impossible:=DownInitialSource.flushing_lane input activation ty sg lane 0 tyBound sgBound laneBound (by decide) load memory base
    rw [actual,Option.map_none] at impossible
    have bad:=congrArg Option.isSome impossible
    cases bad
  | some current =>
    have currentValue : ∀ i, i<16 → current i=values input activationValues ty load memory base sg lane i := by
      intro i bound
      have equal:=DownInitialSource.flushing_lane input activation ty sg lane i tyBound sgBound laneBound bound load memory base
      rw [actual,Option.map_some] at equal
      exact Option.some.inj equal
    rw [threadStores,actual,Option.bind_some,alias_current,Option.bind_some,parsed_store,Option.bind_some,
      selected,Option.bind_some]
    exact GateStoreSource.mapM_exact (List.range 16) _ _ (fun i member => by
      have bound:=List.mem_range.mp member
      rw [body_selected k sg lane i base input.valid sgBound laneBound bound,currentValue i bound]
      rfl)

def programs (input : PackedArrayDownMaterialization.Input k)
    {activationValues : Fin 17408 → ArrayStorage.BF} (activation : ArrayStorage.BFBuffer activationValues)
    (ty : Nat) (load : ThreadgroupLoad) (memory : WordMemory) (base : Nat) : List (List Memory.Store) :=
  ((List.range 8).product (List.range 32)).map (fun point =>
    (threadStores input activation ty point.1 point.2 load memory base).getD [])

theorem programs_eq (input : PackedArrayDownMaterialization.Input k)
    {activationValues : Fin 17408 → ArrayStorage.BF} (activation : ArrayStorage.BFBuffer activationValues)
    (ty : Nat) (tyBound : ty<160) (load : ThreadgroupLoad) (memory : WordMemory) (base : Nat) :
    programs input activation ty load memory base=DownBarrier.programs base
      (values input activationValues ty load memory base) := by
  have all : programs input activation ty load memory base=
      ((List.range 8).product (List.range 32)).map (fun point =>
        (List.range 16).map (fun i => DownMemory.entry base (values input activationValues ty load memory base) point.1 point.2 i)) := by
    unfold programs
    apply List.map_congr_left
    intro point member
    obtain ⟨sgBound,laneBound⟩:=List.mem_product.mp member
    rw [thread_stores input activation ty point.1 point.2 tyBound (List.mem_range.mp sgBound) (List.mem_range.mp laneBound) load memory base]
    rfl
  rw [all]
  simp only [DownBarrier.programs,List.product,List.map_flatMap,List.map_map]
  rfl
end Inference.Kernels.Trellis.DownScratchSource
