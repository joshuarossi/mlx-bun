import models.qwen.TrellisMlpParsedGateTail
namespace Inference.Models.Qwen.TrellisMlpParsedGateStore
open Contracts.Mlx Contracts.Mlx.M1Max Kernels.Trellis Layers WrittenLayers PackedArrayMaterialization
open TrellisMlpParsedGateTail (BF Exponential)
set_option maxRecDepth 10000

def values (mlp : GateDown) (input : Fin 5120 → BF) (row : Nat) : BF :=
  TrellisMlpParsedGateTail.value mlp.activation
    (TrellisCodebookGateUp.raw mlp.gatePlatform mlp.gate (ArrayStorage.bfWords input) row)
    (TrellisCodebookGateUp.raw mlp.gatePlatform mlp.up (ArrayStorage.bfWords input) row)

variable {mlp : GateDown} {input : Fin 5120 → BF} {source : ArrayStorage.BFBuffer input}
  {tableBase : Nat} {inputBase : Nat → Nat}

def thread (packed : GateInput mlp.gate.width mlp.up.width)
    (actual : ∀ group, GateInputSource.Execution source tableBase (inputBase group))
    (precise : Float32 → Float32) (absolute : BF → BF) (base group index : Nat) : Option (List HalfMemory.Store) := do
  let active ←GateRowSource.writer (index%32)
  if active then
    let rows ←GateRowSource.rows group (index/32)
    rows.mapM (fun row => do
      let value ←TrellisMlpParsedGateTail.output mlp input source (actual group) packed precise absolute row
      pure ⟨base/2+row,value.bits⟩)
  else pure []

attribute [local irreducible] GateRowSource.writer GateRowSource.rows TrellisMlpParsedGateTail.output

theorem thread_eq (packed : GateInput mlp.gate.width mlp.up.width)
    (parameters : TrellisMlpParsedGateProjection.Parameters mlp packed)
    (actual : ∀ group, GateInputSource.Execution source tableBase (inputBase group))
    (precise : Float32 → Float32) (absolute : BF → BF) (exponential : Exponential mlp.activation precise absolute)
    (base group index : Nat) (groupBound : group<160) (threadBound : index<1024) :
    thread packed actual precise absolute base group index=some
      (GateUpOutput.threadStores base (values mlp input) group index) := by
  unfold thread
  rw [GateRowSource.writer_selected ⟨index%32,Nat.mod_lt _ (by decide)⟩]
  by_cases active : index%32=0
  · simp only [active,decide_true]
    rw [GateRowSource.rows_selected group (index/32) groupBound (by omega)]
    change (GateRowSource.expected group (index/32)).mapM _=_
    rw [GateStoreSource.mapM_exact (GateRowSource.expected group (index/32)) _
      (fun row => (⟨base/2+row,(values mlp input row).bits⟩ : HalfMemory.Store)) (by
        intro row member
        obtain ⟨iteration,iterationBound,valid,equal⟩:=GateRowSource.row_member group (index/32) row member
        rw [TrellisMlpParsedGateTail.output_eq mlp input source (actual group) packed parameters precise absolute exponential row (by omega)]
        rfl)]
    simp only [GateRowSource.expected,GateUpOutput.threadStores,active,ite_true,List.map_map]
    rfl
  · simp [active,GateUpOutput.threadStores]

def programs (packed : GateInput mlp.gate.width mlp.up.width)
    (actual : ∀ group, GateInputSource.Execution source tableBase (inputBase group))
    (precise : Float32 → Float32) (absolute : BF → BF) (base : Nat) : List (List HalfMemory.Store) :=
  ((List.range 160).product (List.range 1024)).map (fun pair =>
    (thread packed actual precise absolute base pair.1 pair.2).getD [])

theorem programs_eq (packed : GateInput mlp.gate.width mlp.up.width)
    (parameters : TrellisMlpParsedGateProjection.Parameters mlp packed)
    (actual : ∀ group, GateInputSource.Execution source tableBase (inputBase group))
    (precise : Float32 → Float32) (absolute : BF → BF) (exponential : Exponential mlp.activation precise absolute)
    (base : Nat) :
    programs packed actual precise absolute base=GateUpOutput.programs base (values mlp input) := by
  unfold programs GateUpOutput.programs
  apply List.map_congr_left
  intro pair member
  obtain ⟨groupBound,threadBound⟩:=List.mem_product.mp member
  rw [thread_eq packed parameters actual precise absolute exponential base pair.1 pair.2
    (List.mem_range.mp groupBound) (List.mem_range.mp threadBound)]
  rfl

-- The reference gate traces in preceding are used only to identify the logical
-- activation. The parsed producer reads actual's current native staging heaps;
-- both attach to the same original activation and the SAME middle destination.
theorem source_execution (preceding : TrellisMlpSource.Execution mlp input)
    (packed : GateInput mlp.gate.width mlp.up.width) (parameters : TrellisMlpParsedGateProjection.Parameters mlp packed)
    (actual : ∀ group, GateInputSource.Execution preceding.source tableBase (inputBase group))
    (precise : Float32 → Float32) (absolute : BF → BF) (exponential : Exponential mlp.activation precise absolute) :
    ThreadgroupWrites.Executes (programs packed actual precise absolute preceding.kernel.middle.base)
      preceding.kernel.middle.schedule preceding.kernel.middle.remaining := by
  rw [programs_eq packed parameters actual precise absolute exponential]
  have equal : values mlp input=TrellisMlpDevice.activation mlp (ArrayStorage.bfWords input) preceding.kernel.gate := by
    funext row
    exact TrellisMlpParsedGateTail.value_eq_activation mlp (ArrayStorage.bfWords input) preceding.kernel.gate row
  rw [equal]
  exact preceding.kernel.middle.execution

end Inference.Models.Qwen.TrellisMlpParsedGateStore
