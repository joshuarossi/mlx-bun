import host.ts.renameOrdinary.MapIterations
import host.ts.renameOrdinary.MapReturnTyped
import host.ts.renameOrdinary.VectorInputPath

set_option maxRecDepth 1000000
set_option maxHeartbeats 0
set_option Elab.async false
namespace Host.Load.Run.Full.Ordinary
open Host.Ts Host.Ts.Owned Host.Ts.Owned.Parametric Host.Mlx.Ffi.Annotated

theorem map_complete_live_grow (live : Nat → Prop) (a : Nat) (ha : live a) : mapCompleteLive live a := by
  apply Or.inl
  apply CellsLive.grow
  apply ClosureLive.grow
  apply ClosureLive.grow
  apply Or.inl
  apply CellsLive.grow
  apply ClosureLive.grow
  apply ClosureLive.grow
  exact ha

/-- The actual map loop, iterable construction, ptr and BigInt calls derive
both native vector inputs. No intermediate target buffer or argument is assumed. -/
theorem map_to_vector (FR : Ren → P.F.S → P.F.S → Prop) (R : Ren)
    (ν₀ ν : Nat → F64) (C₀ C : CSrv) (live framed : Nat → Prop)
    (before after : List Val) (old old' : List Event) (s : St P.F.S)
    (h : StateR (NumberRoles ν₀ ν C₀ C) FR R live framed before after old old' MapBody100.input s)
    (resultNotFramed : ¬ framed 3126677) (inputNotFramed : ¬ framed MapBody113.sourceAddress)
    (arrayLive : live 3126677) (indexLive : live 3126679) (lengthLive : live 3126675)
    (secondLive : live 3126165) (constructorLive : live 95)
    (indexCell : s.heap.get (R.a 3126679) = some (.cell (some (natV 0))))
    (lengthCell : s.heap.get (R.a 3126675) = some (.cell (some (natV 2))))
    (firstField : PrivateData s (R.a MapBody138.sourceAddress) (R.a MapBody138.sourceBrand)
      MapBody138.sourceName (.big (Int.ofNat (R.handle 25732))))
    (secondField : PrivateData s (R.a MapBody195.sourceAddress) (R.a MapBody195.sourceBrand)
      MapBody195.sourceName (.big (Int.ofNat (R.handle 29363))))
    (code : (Annotated.Value.literal (.lit MapTyped223.sourceCode)).Holds ν C R
      (nativeDataArgument s (R.a MapTyped223.sourceFunction) 0))
    (proto : (Annotated.Value.literal (.lit MapTyped223.sourceProtoNumber)).Holds ν C R
      (nativeDataArgument s (R.a MapTyped223.sourceFunction) 1))
    (handles : ∀ h ∈ MapTyped223.sourceHandles.map R.handle, h < 2^64)
    (bufferProtoLive : live aArrayBufferProto) (bufferProtoFixed : R.a aArrayBufferProto = aArrayBufferProto)
    (typedProtoLive : live MapTyped223.sourceProto) (typedProtoFixed : R.a MapTyped223.sourceProto = MapTyped223.sourceProto)
    (globalLive : live aGlobal) (globalFixed : R.a aGlobal = aGlobal)
    (bound : s.next+10 ≤ 2^64) :
    ∃ result, runC P.F 149 s C = some (result,C) ∧
      StateR (NumberRoles ν₀ ν C₀ C) FR R (mapTypedLive (mapCompleteLive live)) framed before after old old'
        VectorInput248.output result ∧
      (Annotated.Value.ordinaryBig 2).Holds ν C R (callArgument result.ctl 1) ∧
      (VectorBuffer.role [25732,29363]).Holds ν C R (objectKindAt result (R.a 3126688)) ∧
      (∀ a, a < s.next → a ≠ R.a 3126677 → a ≠ R.a VectorInput225.sourceAddress →
        result.heap.get a = s.heap.get a) := by
  let NR := NumberRoles ν₀ ν C₀ C
  let L := mapCompleteLive live
  let LT := mapTypedLive L
  obtain ⟨s214,run214,h214,_,array214,frame214⟩ := map_iterations FR R ν₀ ν C₀ C live framed before after old old'
    s h resultNotFramed inputNotFramed arrayLive indexLive lengthLive secondLive indexCell lengthCell firstField secondField (by omega)
  have next214 : s214.next = s.next+8 := h.target_next_add h214 8 (by host_kernel_rfl)
  have constructorOld : R.a MapTyped223.sourceFunction < s.next := h.heap.targetBound _ constructorLive
  have constructorOther : R.a MapTyped223.sourceFunction ≠ R.a 3126677 := fun eq => by
    have bad := h.heap.inj _ _ constructorLive arrayLive eq
    have different : MapTyped223.sourceFunction ≠ 3126677 := by decide +kernel
    exact different bad
  have heapConstructor := frame214 _ constructorOld constructorOther
  have code214 : (Annotated.Value.literal (.lit MapTyped223.sourceCode)).Holds ν C R
      (nativeDataArgument s214 (R.a MapTyped223.sourceFunction) 0) := by
    simpa only [nativeDataArgument,St.obj?,heapConstructor] using code
  have proto214 : (Annotated.Value.literal (.lit MapTyped223.sourceProtoNumber)).Holds ν C R
      (nativeDataArgument s214 (R.a MapTyped223.sourceFunction) 1) := by
    simpa only [nativeDataArgument,St.obj?,heapConstructor] using proto
  obtain ⟨s224,run224,h224,buffer224,frame224⟩ := map_return_typed NR FR R C₀ C ν L framed before after old old'
    s214 h214 array214 code214 proto214 handles (map_complete_live_grow _ _ bufferProtoLive) bufferProtoFixed
    (map_complete_live_grow _ _ typedProtoLive) typedProtoFixed (by rw [next214]; omega)
  have next224 : s224.next = s.next+10 := h.target_next_add h224 10 (by host_kernel_rfl)
  obtain ⟨result,run249,h249,count249,frame249⟩ := vector_input_path FR R ν₀ ν C₀ C LT framed before after old old'
    s224 h224 inputNotFramed (Or.inl (Or.inl (map_complete_live_grow _ _ globalLive))) globalFixed
    (by rw [next224]; exact bound)
  have bufferLive : LT 3126688 := by
    apply Or.inl
    apply Or.inr
    rfl
  have handlesLive : LT VectorInput225.sourceAddress := by
    have hl := h224.stackLive
    change listSupport (fun f => treeSupport LT (Encode.frame f)) VectorInput224.input.stack at hl
    have src : VectorInput224.input.stack =
      .s (.decl VectorInput224.sourceKind VectorInput224.sourcePattern VectorInput224.sourceRest VectorInput224.sourceEnv)::VectorInput224.sourceTail :=
        VectorInput224.source_frame
    rw [src] at hl
    have lookup : lookupEnv VectorInput225.sourceName VectorInput224.sourceEnv = some VectorInput225.sourceAddress := by host_kernel_rfl
    exact env_lookup_live _ _ _ hl.1.1.2.2.2.1 lookup
  have bufferOther : R.a 3126688 ≠ R.a VectorInput225.sourceAddress := fun eq => by
    have bad := h224.heap.inj _ _ bufferLive handlesLive eq
    have different : 3126688 ≠ VectorInput225.sourceAddress := by decide +kernel
    exact different bad
  have bufferHeap := frame249 _ bufferOther
  have buffer249 : (VectorBuffer.role [25732,29363]).Holds ν C R (objectKindAt result (R.a 3126688)) := by
    simpa only [objectKindAt,St.obj?,bufferHeap] using buffer224
  have run124 : runC P.F 124 s C = some (s224,C) := runC_join P.F run214 run224
  refine ⟨result,runC_join P.F run124 run249,h249,?_,buffer249,?_⟩
  · rw [count249]
    exact .ordinaryBig 2
  · intro a ha other otherCell
    rw [frame249 a otherCell,frame224 a (by rw [next214]; omega)]
    exact frame214 a ha other

end Host.Load.Run.Full.Ordinary
