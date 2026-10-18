import host.ts.renameOrdinary.MapSetupFields
import host.ts.renameOrdinary.MapToVector

set_option maxRecDepth 1000000
set_option maxHeartbeats 0
set_option Elab.async false
namespace Host.Load.Run.Full.Ordinary
open Host.Ts Host.Ts.Owned Host.Ts.Owned.Parametric Host.Mlx.Ffi.Annotated

theorem map_setup_live_grow (live : Nat → Prop) (a : Nat) (ha : live a) : mapSetupCompleteLive live a := by
  apply Or.inl
  apply CellsLive.grow
  exact Or.inl ha

/-- The complete actual map prelude, both iterations, typed-array construction
and vector argument preparation derive their local numeric and handle inputs. -/
theorem map_setup_to_vector (FR : Ren → P.F.S → P.F.S → Prop) (R : Ren)
    (ν₀ ν : Nat → F64) (C₀ C : CSrv) (live framed : Nat → Prop)
    (before after : List Val) (old old' : List Event) (s : St P.F.S)
    (h : StateR (NumberRoles ν₀ ν C₀ C) FR R live framed before after old old' MapSetup74.input s)
    (inputNotFramed : ¬ framed 3126664)
    (firstField : PrivateData s (R.a MapBody138.sourceAddress) (R.a MapBody138.sourceBrand)
      MapBody138.sourceName (.big (Int.ofNat (R.handle 25732))))
    (secondField : PrivateData s (R.a MapBody195.sourceAddress) (R.a MapBody195.sourceBrand)
      MapBody195.sourceName (.big (Int.ofNat (R.handle 29363))))
    (code : (Annotated.Value.literal (.lit MapTyped223.sourceCode)).Holds ν C R
      (nativeDataArgument s (R.a MapTyped223.sourceFunction) 0))
    (proto : (Annotated.Value.literal (.lit MapTyped223.sourceProtoNumber)).Holds ν C R
      (nativeDataArgument s (R.a MapTyped223.sourceFunction) 1))
    (handles : ∀ h ∈ MapTyped223.sourceHandles.map R.handle, h < 2^64)
    (arrayProtoLive : live aArrayProto) (arrayProtoFixed : R.a aArrayProto = aArrayProto)
    (bufferProtoLive : live aArrayBufferProto) (bufferProtoFixed : R.a aArrayBufferProto = aArrayBufferProto)
    (typedProtoLive : live MapTyped223.sourceProto) (typedProtoFixed : R.a MapTyped223.sourceProto = MapTyped223.sourceProto)
    (globalLive : live aGlobal) (globalFixed : R.a aGlobal = aGlobal)
    (bound : s.next+13 ≤ 2^64) :
    ∃ result, runC P.F 175 s C = some (result,C) ∧
      StateR (NumberRoles ν₀ ν C₀ C) FR R (mapTypedLive (mapCompleteLive (mapSetupCompleteLive live)))
        framed before after old old' VectorInput248.output result ∧
      (Annotated.Value.ordinaryBig 2).Holds ν C R (callArgument result.ctl 1) ∧
      (VectorBuffer.role [25732,29363]).Holds ν C R (objectKindAt result (R.a 3126688)) ∧
      (∀ k, live k → k ≠ 3126675 → k ≠ 3126676 → k ≠ VectorInput225.sourceAddress →
        result.heap.get (R.a k) = s.heap.get (R.a k)) := by
  let NR := NumberRoles ν₀ ν C₀ C
  let L := mapSetupCompleteLive live
  obtain ⟨s100,run100,h100,index100,length100,frame100⟩ := map_setup_guard_fields FR R ν₀ ν C₀ C live framed before after old old'
    s h inputNotFramed arrayProtoLive arrayProtoFixed (by omega)
  have next100 : s100.next = s.next+3 := h.target_next_add h100 3 (by host_kernel_rfl)
  obtain ⟨firstLive,secondLive,constructorLive⟩ := map_setup_receivers_live NR FR R live framed before after old old' s h inputNotFramed
  have lengthLive := map_setup_length_live NR FR R live framed before after old old' s h
  have resultNotFramed : ¬ framed 3126677 := by
    intro hf
    have impossible := h.heap.sourceBound _ (h.heap.prefixLive _ hf)
    have fresh : 3126677 = MapSetup74.input.next := by host_kernel_rfl
    rw [fresh] at impossible
    omega
  have arrayLive100 : L 3126677 := by
    apply Or.inl
    apply CellsLive.grow
    apply Or.inr
    rfl
  have indexLive100 : L 3126679 := Or.inr rfl
  have field1 := firstField.heap_at (frame100 _ firstLive (by decide +kernel) (by decide +kernel))
  have field2 := secondField.heap_at (frame100 _ secondLive (by decide +kernel) (by decide +kernel))
  have constructorHeap : s100.heap.get (R.a MapTyped223.sourceFunction) =
      s.heap.get (R.a MapTyped223.sourceFunction) :=
    frame100 _ constructorLive (by decide +kernel) (by decide +kernel)
  have code100 : (Annotated.Value.literal (.lit MapTyped223.sourceCode)).Holds ν C R
      (nativeDataArgument s100 (R.a MapTyped223.sourceFunction) 0) := by
    simpa only [nativeDataArgument,St.obj?,constructorHeap] using code
  have proto100 : (Annotated.Value.literal (.lit MapTyped223.sourceProtoNumber)).Holds ν C R
      (nativeDataArgument s100 (R.a MapTyped223.sourceFunction) 1) := by
    simpa only [nativeDataArgument,St.obj?,constructorHeap] using proto
  obtain ⟨result,run,hpost,count,buffer,frame⟩ := map_to_vector FR R ν₀ ν C₀ C L framed before after old old'
    s100 h100 resultNotFramed inputNotFramed arrayLive100 indexLive100 (map_setup_live_grow _ _ lengthLive)
    (map_setup_live_grow _ _ secondLive) (map_setup_live_grow _ _ constructorLive) index100 length100 field1 field2
    code100 proto100 handles (map_setup_live_grow _ _ bufferProtoLive) bufferProtoFixed
    (map_setup_live_grow _ _ typedProtoLive) typedProtoFixed (map_setup_live_grow _ _ globalLive) globalFixed
    (by rw [next100]; omega)
  have mappedFresh : R.a 3126677 = s.next := by
    have fresh : 3126677 = MapSetup74.input.next := by host_kernel_rfl
    rw [fresh]
    simpa only [Nat.add_zero] using h.heap.fresh 0
  have handlesLive : live VectorInput225.sourceAddress := h.stack_address_live _ (by host_kernel_rfl)
  refine ⟨result,runC_join P.F run100 run,hpost,count,buffer,?_⟩
  intro k hk kn kr kh
  have old := h.heap.targetBound _ hk
  have other : R.a k ≠ R.a 3126677 := by rw [mappedFresh]; exact Nat.ne_of_lt old
  have otherHandle : R.a k ≠ R.a VectorInput225.sourceAddress := fun eq =>
    kh (h.heap.inj _ _ hk handlesLive eq)
  rw [frame _ (by rw [next100]; omega) other otherHandle]
  exact frame100 k hk kn kr

end Host.Load.Run.Full.Ordinary
