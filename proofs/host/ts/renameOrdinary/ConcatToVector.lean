import host.ts.renameOrdinary.ConcatMapEntry
import host.ts.renameOrdinary.MapSetupToVector

set_option maxRecDepth 1000000
set_option maxHeartbeats 0
set_option Elab.async false
namespace Host.Load.Run.Full.Ordinary
open Host.Ts Host.Ts.Owned Host.Ts.Owned.Parametric Host.Mlx.Ffi.Annotated

theorem concat_map_live_grow (live : Nat → Prop) (a : Nat) (ha : live a) : concatMapLive live a := by
  apply CellsLive.grow
  apply ClosureLive.grow
  exact Or.inl ha

/-- The actual concat helper evaluates map, both handle getters and pushes,
the typed array, ptr and count conversion before the native vector operation. -/
theorem concat_to_vector (FR : Ren → P.F.S → P.F.S → Prop) (R : Ren)
    (ν₀ ν : Nat → F64) (C₀ C : CSrv) (live framed : Nat → Prop)
    (before after : List Val) (old old' : List Event) (s : St P.F.S)
    (h : StateR (NumberRoles ν₀ ν C₀ C) FR R live framed before after old old' Callback49.input s)
    (inputNotFramed : ¬ framed Callback56.sourceAddress)
    (firstField : PrivateData s (R.a MapBody138.sourceAddress) (R.a MapBody138.sourceBrand)
      MapBody138.sourceName (.big (Int.ofNat (R.handle 25732))))
    (secondField : PrivateData s (R.a MapBody195.sourceAddress) (R.a MapBody195.sourceBrand)
      MapBody195.sourceName (.big (Int.ofNat (R.handle 29363))))
    (code : (Annotated.Value.literal (.lit MapTyped223.sourceCode)).Holds ν C R
      (nativeDataArgument s (R.a MapTyped223.sourceFunction) 0))
    (proto : (Annotated.Value.literal (.lit MapTyped223.sourceProtoNumber)).Holds ν C R
      (nativeDataArgument s (R.a MapTyped223.sourceFunction) 1))
    (handles : ∀ h ∈ MapTyped223.sourceHandles.map R.handle, h < 2^64)
    (functionProtoLive : live aFunctionProto) (functionProtoFixed : R.a aFunctionProto = aFunctionProto)
    (arrayProtoLive : live aArrayProto) (arrayProtoFixed : R.a aArrayProto = aArrayProto)
    (bufferProtoLive : live aArrayBufferProto) (bufferProtoFixed : R.a aArrayBufferProto = aArrayBufferProto)
    (typedProtoLive : live MapTyped223.sourceProto) (typedProtoFixed : R.a MapTyped223.sourceProto = MapTyped223.sourceProto)
    (globalLive : live aGlobal) (globalFixed : R.a aGlobal = aGlobal)
    (bound : s.next+19 ≤ 2^64) :
    ∃ result, runC P.F 200 s C = some (result,C) ∧
      StateR (NumberRoles ν₀ ν C₀ C) FR R
        (mapTypedLive (mapCompleteLive (mapSetupCompleteLive (concatMapLive live))))
        framed before after old old' VectorInput248.output result ∧
      (Annotated.Value.ordinaryBig 2).Holds ν C R (callArgument result.ctl 1) ∧
      (VectorBuffer.role [25732,29363]).Holds ν C R (objectKindAt result (R.a 3126688)) ∧
      (∀ k, live k → k ≠ VectorInput225.sourceAddress → result.heap.get (R.a k) = s.heap.get (R.a k)) := by
  let NR := NumberRoles ν₀ ν C₀ C
  let L := concatMapLive live
  obtain ⟨s74,run74,h74,frame74⟩ := concat_map_entry NR FR R C₀ C live framed before after old old'
    s h inputNotFramed functionProtoLive functionProtoFixed globalLive globalFixed (by omega)
  have next74 : s74.next = s.next+6 := h.target_next_add h74 6 (by host_kernel_rfl)
  obtain ⟨firstLive,secondLive,constructorLive⟩ := concat_initial_live NR FR R live framed before after old old' s h inputNotFramed globalLive
  have field1 := firstField.heap_at (frame74 _ (h.heap.targetBound _ firstLive))
  have field2 := secondField.heap_at (frame74 _ (h.heap.targetBound _ secondLive))
  have constructorHeap : s74.heap.get (R.a MapTyped223.sourceFunction) = s.heap.get (R.a MapTyped223.sourceFunction) :=
    frame74 _ (h.heap.targetBound _ constructorLive)
  have code74 : (Annotated.Value.literal (.lit MapTyped223.sourceCode)).Holds ν C R
      (nativeDataArgument s74 (R.a MapTyped223.sourceFunction) 0) := by
    simpa only [nativeDataArgument,St.obj?,constructorHeap] using code
  have proto74 : (Annotated.Value.literal (.lit MapTyped223.sourceProtoNumber)).Holds ν C R
      (nativeDataArgument s74 (R.a MapTyped223.sourceFunction) 1) := by
    simpa only [nativeDataArgument,St.obj?,constructorHeap] using proto
  obtain ⟨result,run,hpost,count,buffer,frame⟩ := map_setup_to_vector FR R ν₀ ν C₀ C L framed before after old old'
    s74 h74 inputNotFramed field1 field2 code74 proto74 handles (concat_map_live_grow _ _ arrayProtoLive) arrayProtoFixed
    (concat_map_live_grow _ _ bufferProtoLive) bufferProtoFixed (concat_map_live_grow _ _ typedProtoLive) typedProtoFixed
    (concat_map_live_grow _ _ globalLive) globalFixed (by rw [next74]; exact bound)
  refine ⟨result,runC_join P.F run74 run,hpost,count,buffer,?_⟩
  intro k hk kh
  have sourceOld := h.heap.sourceBound _ hk
  have beforeLocals : Callback49.input.next ≤ 3126675 := by decide +kernel
  have kn : k ≠ 3126675 := by omega
  have kr : k ≠ 3126676 := by omega
  rw [frame k (concat_map_live_grow _ _ hk) kn kr kh]
  exact frame74 _ (h.heap.targetBound _ hk)

end Host.Load.Run.Full.Ordinary
