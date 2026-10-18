import host.ts.renameOrdinary.IncomingPrefix49
import host.ts.renameOrdinary.PrefixSequence49
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
set_option Elab.async false
namespace Host.Load.Run.Full.Ordinary
open Host.Ts Host.Ts.Owned Host.Ts.Owned.Parametric
theorem incoming_prefix49_sequence_frame_transport
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
    (dimension : (roles 22582).shape[1]? = some (.literal (.lit (F64.ofNat 1))))
    (nativeHandle : H 29363) (region : R.region 117452 = 4*R.handle 29363)
    (bound : s.next + 11 + (blockNames Parameter48.sourceBody).length ≤ 2^64) :
    ∃ result, runC P.F 107 s C = some (result,C) ∧
      StateR (NumberRoles ν₀ ν C₀ C) (Prefix.NativeFrame FR ν₀ ν C₀ C roles ObjRel boundary H N tail)
        R (Incoming49Live live) framed before after old old' P.RestStream.micro0.micro0.s49 result ∧
      result.heap.get (R.a Parameter43.sourceAddress) = some (.cell (some (natV 1))) ∧
      result.heap.get (R.a Binding20.sourceAddress) = some (.cell (some (natV 1))) ∧
      Incoming49Live live Binding20.sourceAddress ∧
      (∀ a, live a → a < 3126641 → result.heap.get (R.a a) = s.heap.get (R.a a)) ∧
      (live Parameter45.address → cellValueAt result (R.a Parameter47.sourceAddress) = cellValueAt s (R.a Parameter45.address)) := by
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
  obtain ⟨result,hr49,h49,axis49,stored49,sequenceLive49,frame49,stream49⟩ := Prefix.first_fortynine_sequence_frame_transport FR R ν₀ ν C₀ C roles ObjRel boundary H N tail
    (RankOrigin.GetterLive live) framed before after old old' s59 h59 rank59 code59 proto59
    (grow _ bufferProtoLive) bufferProtoFixed (grow _ typedProtoLive) typedProtoFixed
    (grow _ arrayProtoLive) arrayProtoFixed dimension nativeHandle region bound49
  refine ⟨result,runC_join P.F (m:=58) (n:=49) hr59 hr49,h49,axis49,stored49,sequenceLive49,?_,?_⟩
  · intro a alive below
    have neqRank : a ≠ Variable5.address := by
      have hb : 3126641 ≤ Variable5.address := by decide +kernel
      omega
    have neqPointer : a ≠ RankOrigin.PointerBinding48.sourceAddress := by
      have hb : 3126641 ≤ RankOrigin.PointerBinding48.sourceAddress := by decide +kernel
      omega
    have neqRank' : R.a a ≠ R.a Variable5.address := fun e => neqRank (h.heap.inj _ _ alive rankLive e)
    have neqPointer' : R.a a ≠ R.a RankOrigin.PointerBinding48.sourceAddress := fun e => neqPointer (h.heap.inj _ _ alive pointerLive e)
    exact (frame49 a (grow _ alive) below).trans (frame59 _ (h.heap.targetBound _ alive) neqRank' neqPointer')
  · intro gpuLive
    have neqRank : Parameter45.address ≠ Variable5.address := by decide +kernel
    have neqPointer : Parameter45.address ≠ RankOrigin.PointerBinding48.sourceAddress := by decide +kernel
    have neqRank' : R.a Parameter45.address ≠ R.a Variable5.address := fun e => neqRank (h.heap.inj _ _ gpuLive rankLive e)
    have neqPointer' : R.a Parameter45.address ≠ R.a RankOrigin.PointerBinding48.sourceAddress := fun e => neqPointer (h.heap.inj _ _ gpuLive pointerLive e)
    have heap59 := frame59 _ (h.heap.targetBound _ gpuLive) neqRank' neqPointer'
    exact (stream49 (grow _ gpuLive)).trans (cellValueAt_heap_at s s59 _ heap59)

theorem incoming_prefix49_sequence_transport
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
    (dimension : (roles 22582).shape[1]? = some (.literal (.lit (F64.ofNat 1))))
    (nativeHandle : H 29363) (region : R.region 117452 = 4*R.handle 29363)
    (bound : s.next + 11 + (blockNames Parameter48.sourceBody).length ≤ 2^64) :
    ∃ result, runC P.F 107 s C = some (result,C) ∧
      StateR (NumberRoles ν₀ ν C₀ C) (Prefix.NativeFrame FR ν₀ ν C₀ C roles ObjRel boundary H N tail)
        R (Incoming49Live live) framed before after old old' P.RestStream.micro0.micro0.s49 result ∧
      result.heap.get (R.a Parameter43.sourceAddress) = some (.cell (some (natV 1))) ∧
      result.heap.get (R.a Binding20.sourceAddress) = some (.cell (some (natV 1))) ∧
      Incoming49Live live Binding20.sourceAddress := by
  obtain ⟨result,run,relation,axis,stored,alive,_,_⟩ := incoming_prefix49_sequence_frame_transport FR R ν₀ ν C₀ C roles ObjRel boundary H N tail
    live framed before after old old' s h code proto field rankSignature shapeSignature handleRole globalLive globalFixed
    bufferProtoLive bufferProtoFixed typedProtoLive typedProtoFixed arrayProtoLive arrayProtoFixed dimension nativeHandle region bound
  exact ⟨result,run,relation,axis,stored,alive⟩
end Host.Load.Run.Full.Ordinary
