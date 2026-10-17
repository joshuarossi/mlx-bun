import kernels.trellis.DownPartialControl
import kernels.trellis.DownDevice
namespace Inference.Kernels.Trellis.DownPartialSource
open Contracts.Mlx Contracts.Mlx.M1Max DownPartialSyntax
set_option maxRecDepth 10000

def point (add : DownPartialSum.Addition) (heap : ByteMemory.Bytes) (sharedBase outputBase k lane ty c : Nat) : Option Memory.Store :=
  (DownPartialIndex.columns k lane).bind (fun cols =>
    (DownPartialIndex.group ty c cols).bind (fun coordinates =>
      (DownPartialControl.skip coordinates.2).bind (fun skip => if skip then none else
        (DownPartialSum.stage add heap sharedBase c coordinates.1 cols).bind (fun value =>
          (DownPartialControl.y ty).bind (fun y =>
            (parse storeTokens storeSource).bind (fun code =>
              ((DownPartialIndex.offset y.toNat coordinates.2.toNat code).map BitVec.toNat).map
                (fun index => ⟨outputBase/4+index,value⟩)))))))

def sumValue (add : DownPartialSum.Addition) (heap : ByteMemory.Bytes) (sharedBase c : Nat) : Float32 :=
  DownCodebook.scalarRows (fun split previous => add
    (FloatMemory.load heap (sharedBase+4*((c/512*4+split)*512+c%512))) previous) 0 4 0

attribute [local irreducible] parse DownPartialIndex.columns DownPartialIndex.group DownPartialControl.skip DownPartialSum.stage DownPartialControl.y DownPartialIndex.offset

theorem point_selected (add : DownPartialSum.Addition) (heap : ByteMemory.Bytes) (sharedBase outputBase k lane ty c : Nat)
    (valid : k=2 ∨ k=3 ∨ k=4) (laneBound : lane<32) (tyBound : ty<160) (columnBound : c<1024) :
    point add heap sharedBase outputBase k lane ty c=some
      ⟨outputBase/4+ty%32*5120+DownCodebook.column ty c,sumValue add heap sharedBase c⟩ := by
  have bounds:=DownCodebook.partial_bounds ty c tyBound columnBound
  have colSmall : DownCodebook.column ty c<2^32 := by omega
  have ySmall : ty%32<2^32 := by omega
  rw [point,DownPartialIndex.columns_selected k lane valid laneBound,Option.bind_some,
    DownPartialIndex.group_selected ty c tyBound columnBound,Option.bind_some,
    DownPartialControl.skip_selected _ bounds.2.1,Option.bind_some,ite_eq_right (by decide),
    DownPartialSum.stage_selected add heap sharedBase c columnBound,Option.bind_some,
    DownPartialControl.y_selected ty tyBound,Option.bind_some,parsed_store,Option.bind_some]
  simp only [BitVec.toNat_ofNat,Nat.mod_eq_of_lt colSmall,Nat.mod_eq_of_lt ySmall]
  rw [DownPartialIndex.offset_selected (ty%32) (DownCodebook.column ty c) bounds.1 bounds.2.1,Option.map_some]
  simp only [sumValue,Nat.add_assoc]

-- The producer reads the same completed scratch allocation. Its dispatch
-- completion remains the explicit dependency before the separate FOLD kernel.
def heap (before : ByteMemory.Bytes)
    (trace : DownReadBarrier.Trace load before sharedBase words k scale input ty) : ByteMemory.Bytes :=
  FloatMemory.execute trace.scratchSchedule (FloatMemory.execute trace.tableSchedule before)

def threadStores (input : PackedArrayDownMaterialization.Input k)
    {activationValues : Fin 17408 → ArrayStorage.BF} (_activation : ArrayStorage.BFBuffer activationValues)
    (load : ThreadgroupLoad) (before : Nat → ByteMemory.Bytes) (sharedBase outputBase ty thread : Nat)
    (traces : ∀ ty, DownReadBarrier.Trace load (before ty) sharedBase input.matrix k (Models.Qwen.CheckpointTrellis.scale input.scales)
      (DownLaneSource.activationValue activationValues) ty) : Option (List Memory.Store) :=
  (DownPartialControl.outputColumns k thread).bind (fun columns =>
    columns.mapM (fun c => point FlushToZero.add (heap (before ty) (traces ty)) sharedBase outputBase k (thread%32) ty c))

theorem thread_stores (input : PackedArrayDownMaterialization.Input k)
    {activationValues : Fin 17408 → ArrayStorage.BF} (activation : ArrayStorage.BFBuffer activationValues)
    (load : ThreadgroupLoad) (before : Nat → ByteMemory.Bytes) (sharedBase outputBase ty thread : Nat)
    (traces : ∀ ty, DownReadBarrier.Trace load (before ty) sharedBase input.matrix k (Models.Qwen.CheckpointTrellis.scale input.scales)
      (DownLaneSource.activationValue activationValues) ty) (tyBound : ty<160) (threadBound : thread<256) :
    threadStores input activation load before sharedBase outputBase ty thread traces=some
      ((List.range 4).map (DownPartialMemory.entry outputBase (fun ty c => (traces ty).value c) ty thread)) := by
  rw [threadStores,DownPartialControl.columns_selected k thread input.valid threadBound,Option.bind_some]
  have exactStores:=GateStoreSource.mapM_exact ((List.range 4).map (fun iteration => thread+256*iteration))
    (fun c => point FlushToZero.add (heap (before ty) (traces ty)) sharedBase outputBase k (thread%32) ty c)
    (fun c => (⟨outputBase/4+ty%32*5120+DownCodebook.column ty c,(traces ty).value c⟩ : Memory.Store)) (by
      intro c member
      obtain ⟨iteration,bound,rfl⟩:=List.mem_map.mp member
      have rangeBound:=List.mem_range.mp bound
      rw [point_selected FlushToZero.add _ sharedBase outputBase k (thread%32) ty _ input.valid (Nat.mod_lt _ (by decide)) tyBound (by omega)]
      rfl)
  rw [exactStores]
  simp only [List.map_map]
  rfl

def programs (input : PackedArrayDownMaterialization.Input k)
    {activationValues : Fin 17408 → ArrayStorage.BF} (activation : ArrayStorage.BFBuffer activationValues)
    (load : ThreadgroupLoad) (before : Nat → ByteMemory.Bytes) (sharedBase outputBase : Nat)
    (traces : ∀ ty, DownReadBarrier.Trace load (before ty) sharedBase input.matrix k (Models.Qwen.CheckpointTrellis.scale input.scales)
      (DownLaneSource.activationValue activationValues) ty) : List (List Memory.Store) :=
  ((List.range 160).product (List.range 256)).map (fun point =>
    (threadStores input activation load before sharedBase outputBase point.1 point.2 traces).getD [])

theorem programs_eq (input : PackedArrayDownMaterialization.Input k)
    {activationValues : Fin 17408 → ArrayStorage.BF} (activation : ArrayStorage.BFBuffer activationValues)
    (load : ThreadgroupLoad) (before : Nat → ByteMemory.Bytes) (sharedBase outputBase : Nat)
    (traces : ∀ ty, DownReadBarrier.Trace load (before ty) sharedBase input.matrix k (Models.Qwen.CheckpointTrellis.scale input.scales)
      (DownLaneSource.activationValue activationValues) ty) :
    programs input activation load before sharedBase outputBase traces=
      DownPartialMemory.programs outputBase (fun ty c => (traces ty).value c) := by
  unfold programs DownPartialMemory.programs
  apply List.map_congr_left
  intro pair member
  obtain ⟨tyBound,threadBound⟩:=List.mem_product.mp member
  rw [thread_stores input activation load before sharedBase outputBase pair.1 pair.2 traces (List.mem_range.mp tyBound) (List.mem_range.mp threadBound)]
  rfl
end Inference.Kernels.Trellis.DownPartialSource
