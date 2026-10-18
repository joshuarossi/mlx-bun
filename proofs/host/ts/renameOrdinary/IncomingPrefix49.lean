import host.ts.renameOrdinary.RankOriginResult
import host.ts.renameOrdinary.Prefix49
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
set_option Elab.async false
namespace Host.Load.Run.Full.Ordinary
open Host.Ts Host.Ts.Owned Host.Ts.Owned.Parametric

/-- The explicit live set after entering the real shape getter, allocating its
buffer/views/shape list, and binding the concat helper's parameters. -/
def Incoming49Live (live : Nat → Prop) : Nat → Prop :=
  CellsLive (ClosureLive (LiveAfter (LiveAfter (LiveAfter (LiveAfter (RankOrigin.GetterLive live)
    NativeBuffer.input.next) TypedBuffer.input.next) ShapeSpread.input.next) P.RestStream.micro0.micro0.s35.next)
    callInput.next false .undef Host.Ts.Sources.Mlx.Ops.ast_n172) P.RestStream.micro0.micro0.s48.next (blockNames Parameter48.sourceBody)

theorem incoming_next : Prefix.input.next = RankOrigin.input.next+2 := by host_kernel_rfl
theorem getter_parameter_names : paramNames RankOrigin.EnterGetter28.sourceFunction = [] := by host_kernel_rfl

/-- A continuous 107-step original-source transport starts at the real ndim
call and derives the fixed concat axis. The rank is initialized by that native
call and Number conversion; it is not a premise at the ordinary-body entry. -/
theorem incoming_prefix49_transport
    (FR : Ren → LSt → LSt → Prop) (R : Ren) (ν₀ ν : Nat → F64) (C₀ C : CSrv)
    (roles : Nat → Host.Mlx.Ffi.Annotated.GraphNode)
    (ObjRel : Ren → Nat → Host.Mlx.Ffi.Obj → Host.Mlx.Ffi.Obj → Prop)
    (boundary H N : Nat → Prop) (tail : List NumV)
    (live framed : Nat → Prop) (before after : List Val) (old old' : List Event) (s : St LSt)
    (h : StateR (NumberRoles ν₀ ν C₀ C) (Prefix.NativeFrame FR ν₀ ν C₀ C roles ObjRel boundary H N tail)
      R live framed before after old old' RankOrigin.input s)
    (code : (Annotated.Value.literal (.lit (F64.ofNat 4))).Holds ν C R (nativeDataArgument s (R.a 90) 0))
    (proto : (Annotated.Value.literal (.lit (F64.ofNat 21))).Holds ν C R (nativeDataArgument s (R.a 90) 1))
    (field : PrivateData s (R.a RankOrigin.Handle40.sourceAddress) (R.a RankOrigin.Handle40.sourceBrand)
      RankOrigin.Handle40.sourceName (.big (Int.ofNat (R.handle 29363))))
    (rankSignature : ¬ framed RankOrigin.signature) (shapeSignature : ¬ framed RankOrigin.ShapeNative.signature)
    (handleRole : (Annotated.Value.handle 29363).Holds ν C R (callArgument s.ctl 0))
    (globalLive : live aGlobal) (globalFixed : R.a aGlobal = aGlobal)
    (bufferProtoLive : live aArrayBufferProto) (bufferProtoFixed : R.a aArrayBufferProto = aArrayBufferProto)
    (typedProtoLive : live 21) (typedProtoFixed : R.a 21 = 21)
    (arrayProtoLive : live aArrayProto) (arrayProtoFixed : R.a aArrayProto = aArrayProto)
    (nativeHandle : H 29363) (region : R.region 117452 = 4*R.handle 29363)
    (bound : s.next + 11 + (blockNames Parameter48.sourceBody).length ≤ 2^64) :
    ∃ result, runC P.F 107 s C = some (result,C) ∧
      StateR (NumberRoles ν₀ ν C₀ C) (Prefix.NativeFrame FR ν₀ ν C₀ C roles ObjRel boundary H N tail)
        R (Incoming49Live live) framed before after old old' P.RestStream.micro0.micro0.s49 result ∧
      result.heap.get (R.a Parameter43.sourceAddress) = some (.cell (some (natV 1))) := by
  let NR := NumberRoles ν₀ ν C₀ C
  let fr := Prefix.NativeFrame FR ν₀ ν C₀ C roles ObjRel boundary H N tail
  have shape : ∀ i n n', Host.Mlx.Ffi.Annotated.NodeRel roles ν₀ ν C₀ C R boundary i n n' →
      Host.Mlx.Ffi.Parametric.ShapeR NR n.shape n'.shape := fun _ _ _ h => h.base.1
  have bound58 : s.next + 2 + (paramNames RankOrigin.EnterGetter28.sourceFunction).length ≤ 2^64 := by
    rw [getter_parameter_names]
    simp only [List.length_nil,Nat.add_zero]
    omega
  obtain ⟨s59,hr59,h59,rank59,_,frame59⟩ := RankOrigin.initialize_shape_entry fr R ν₀ ν C₀ C live framed before after old old'
    s h (Host.Mlx.Ffi.Annotated.NodeRel roles ν₀ ν C₀ C R boundary) (ObjRel R) H N tail h.native.2 shape
    rankSignature shapeSignature nativeHandle handleRole field region bound58 globalLive globalFixed
  obtain ⟨rankLive,_⟩ := RankOrigin.initial_owned_addresses NR fr R live framed before after old old' s h
  have pointerLive := RankOrigin.initial_pointer_live NR fr R live framed before after old old' s h
  have ctorLive := RankOrigin.initial_constructor_live NR fr R live framed before after old old' s h globalLive
  have rankNeq : R.a 90 ≠ R.a Variable5.address := by
    intro he
    have heq := h.heap.inj _ _ ctorLive rankLive he
    have hn : 90 ≠ Variable5.address := by decide +kernel
    exact hn heq
  have pointerNeq : R.a 90 ≠ R.a RankOrigin.PointerBinding48.sourceAddress := by
    intro he
    have heq := h.heap.inj _ _ ctorLive pointerLive he
    have hn : 90 ≠ RankOrigin.PointerBinding48.sourceAddress := by decide +kernel
    exact hn heq
  have heapCtor := frame59 (R.a 90) (h.heap.targetBound _ ctorLive) rankNeq pointerNeq
  have code59 : (Annotated.Value.literal (.lit (F64.ofNat 4))).Holds ν C R (nativeDataArgument s59 (R.a 90) 0) := by
    rw [Prefix.nativeDataArgument_heap_eq s59 s (R.a 90) 0 heapCtor]
    exact code
  have proto59 : (Annotated.Value.literal (.lit (F64.ofNat 21))).Holds ν C R (nativeDataArgument s59 (R.a 90) 1) := by
    rw [Prefix.nativeDataArgument_heap_eq s59 s (R.a 90) 1 heapCtor]
    exact proto
  have grow : ∀ a, live a → RankOrigin.GetterLive live a := ClosureLive.grow live RankOrigin.EnterGetter28.input.next
    RankOrigin.EnterGetter28.sourceArrow RankOrigin.EnterGetter28.sourceHome RankOrigin.EnterGetter28.sourceFunction
  have next59 : s59.next = s.next+2 := Prefix.counter_add h h59 2 incoming_next
  have bound49 : s59.next + 9 + (blockNames Parameter48.sourceBody).length ≤ 2^64 := by rw [next59]; omega
  obtain ⟨result,hr49,h49,axis49⟩ := Prefix.first_fortynine_transport FR R ν₀ ν C₀ C roles ObjRel boundary H N tail
    (RankOrigin.GetterLive live) framed before after old old' s59 h59 rank59 code59 proto59
    (grow _ bufferProtoLive) bufferProtoFixed (grow _ typedProtoLive) typedProtoFixed
    (grow _ arrayProtoLive) arrayProtoFixed nativeHandle region bound49
  exact ⟨result,runC_join P.F (m:=58) (n:=49) hr59 hr49,h49,axis49⟩
end Host.Load.Run.Full.Ordinary
