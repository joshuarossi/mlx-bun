import host.ts.renameOrdinary.Prefix49
import host.ts.renameOrdinary.PrefixSequence39
import host.ts.renameOrdinary.ParameterFrame
import host.ts.renameOrdinary.ParameterStream
import host.ts.RenameClosureEffects
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
set_option Elab.async false
namespace Host.Load.Run.Full.Ordinary.Prefix
open Host.Ts Host.Ts.Owned Host.Ts.Owned.Parametric
theorem first_fortynine_sequence_frame_transport
    (FR : Ren → LSt → LSt → Prop) (R : Ren) (ν₀ ν : Nat → F64) (C₀ C : CSrv)
    (roles : Nat → Host.Mlx.Ffi.Annotated.GraphNode)
    (ObjRel : Ren → Nat → Host.Mlx.Ffi.Obj → Host.Mlx.Ffi.Obj → Prop)
    (boundary H N : Nat → Prop) (tail : List NumV)
    (live framed : Nat → Prop) (before after : List Val) (old old' : List Event) (s : St LSt)
    (h : StateR (NumberRoles ν₀ ν C₀ C) (NativeFrame FR ν₀ ν C₀ C roles ObjRel boundary H N tail)
      R live framed before after old old' input s)
    (rank : s.heap.get (R.a Variable5.address) = some (.cell (some (natV 3))))
    (code : (Annotated.Value.literal (.lit (F64.ofNat 4))).Holds ν C R (nativeDataArgument s (R.a 90) 0))
    (proto : (Annotated.Value.literal (.lit (F64.ofNat 21))).Holds ν C R (nativeDataArgument s (R.a 90) 1))
    (bufferProtoLive : live aArrayBufferProto) (bufferProtoFixed : R.a aArrayBufferProto = aArrayBufferProto)
    (typedProtoLive : live 21) (typedProtoFixed : R.a 21 = 21)
    (arrayProtoLive : live aArrayProto) (arrayProtoFixed : R.a aArrayProto = aArrayProto)
    (dimension : (roles 22582).shape[1]? = some (.literal (.lit (F64.ofNat 1))))
    (nativeHandle : H 29363) (region : R.region 117452 = 4*R.handle 29363)
    (bound : s.next + 9 + (blockNames Parameter48.sourceBody).length ≤ 2^64) :
    ∃ result, runC P.F 49 s C = some (result,C) ∧
      StateR (NumberRoles ν₀ ν C₀ C) (NativeFrame FR ν₀ ν C₀ C roles ObjRel boundary H N tail) R
        (CellsLive (ClosureLive (LiveAfter (LiveAfter (LiveAfter (LiveAfter live NativeBuffer.input.next)
          TypedBuffer.input.next) ShapeSpread.input.next) P.RestStream.micro0.micro0.s35.next)
          callInput.next false .undef Host.Ts.Sources.Mlx.Ops.ast_n172) P.RestStream.micro0.micro0.s48.next (blockNames Parameter48.sourceBody))
        framed before after old old' P.RestStream.micro0.micro0.s49 result ∧
      result.heap.get (R.a Parameter43.sourceAddress) = some (.cell (some (natV 1))) ∧
      result.heap.get (R.a Binding20.sourceAddress) = some (.cell (some (natV 1))) ∧
      (CellsLive (ClosureLive (LiveAfter (LiveAfter (LiveAfter (LiveAfter live NativeBuffer.input.next)
          TypedBuffer.input.next) ShapeSpread.input.next) P.RestStream.micro0.micro0.s35.next)
          callInput.next false .undef Host.Ts.Sources.Mlx.Ops.ast_n172) P.RestStream.micro0.micro0.s48.next
          (blockNames Parameter48.sourceBody)) Binding20.sourceAddress ∧
      (∀ a, live a → a < 3126641 → result.heap.get (R.a a) = s.heap.get (R.a a)) ∧
      (live Parameter45.address → cellValueAt result (R.a Parameter47.sourceAddress) = cellValueAt s (R.a Parameter45.address)) := by
  let fr := NativeFrame FR ν₀ ν C₀ C roles ObjRel boundary H N tail
  let live40 := ClosureLive (LiveAfter (LiveAfter (LiveAfter (LiveAfter live NativeBuffer.input.next)
    TypedBuffer.input.next) ShapeSpread.input.next) P.RestStream.micro0.micro0.s35.next)
    callInput.next false .undef Host.Ts.Sources.Mlx.Ops.ast_n172
  let live39 := LiveAfter (LiveAfter (LiveAfter (LiveAfter live NativeBuffer.input.next)
    TypedBuffer.input.next) ShapeSpread.input.next) P.RestStream.micro0.micro0.s35.next
  obtain ⟨s39,hr39,h39,axis39,stored39,sequenceLive39,frame39⟩ := transport_axis_sequence_frame FR R ν₀ ν C₀ C roles ObjRel boundary H N tail
    live framed before after old old' s h rank code proto bufferProtoLive bufferProtoFixed typedProtoLive typedProtoFixed
    arrayProtoLive arrayProtoFixed dimension nativeHandle region (by omega)
  have hn39 : s39.next = s.next+4 := counter_add h h39 4 (by host_kernel_rfl)
  have names39 : (paramNames FirstCall.sourceFunction).length = 3 := by decide +kernel
  have bound39 : s39.next+2+(paramNames FirstCall.sourceFunction).length ≤ 2^64 := by rw [names39,hn39]; omega
  obtain ⟨s40,hr39step,h40,axis40⟩ := call_axis_transport (NumberRoles ν₀ ν C₀ C) fr R C₀ C
    live39 framed before after old old' s39 h39 bound39 (fun v => v = natV 1) axis39
  have heap40 := step_closure_heap_below P.F (NumberRoles ν₀ ν C₀ C) fr R live39 framed before after old old'
    callInput s39 s40 C C h39 FirstCall.address FirstCall.object FirstCall.sourceFunction FirstCall.sourceEnv
    FirstCall.sourceArrow FirstCall.sourceHome FirstCall.sourceThis FirstCall.sourceArgs
    FirstCall.source_control FirstCall.source_heap FirstCall.source_kind bound39 hr39step
  have stored40 : s40.heap.get (R.a Binding20.sourceAddress) = some (.cell (some (natV 1))) :=
    (heap40 _ (h39.heap.targetBound _ sequenceLive39)).trans stored39
  have sequenceLive40 : live40 Binding20.sourceAddress := ClosureLive.grow _ _ _ _ _ _ sequenceLive39
  have one40 : runC P.F 1 s39 C = some (s40,C) := runC_cons P.F 0 s39 s40 s40 C C C
    (h39.control.isHalt_eq.trans (by host_kernel_rfl)) hr39step rfl
  have hr40 : runC P.F 40 s C = some (s40,C) := runC_join P.F (m:=39) (n:=1) hr39 one40
  have hn40 : s40.next = s.next+8 := counter_add h h40 8 (by host_kernel_rfl)
  have hb40 : s40.next + (blockNames Parameter48.sourceBody).length ≤ 2^64 := by rw [hn40]; omega
  obtain ⟨result,hr49,h49,v,hv,axis49⟩ := concat_parameter_axis_preserved (NumberRoles ν₀ ν C₀ C) fr R C₀ C
    live40 framed before after old old' s40 h40 hb40 (fun v => v = natV 1) axis40
  subst v
  obtain ⟨result',run',_,heap49⟩ := concat_parameters_heap_frame (NumberRoles ν₀ ν C₀ C) fr R C₀ C
    live40 framed before after old old' s40 h40 hb40
  have same : result' = result := congrArg Prod.fst (Option.some.inj (run'.symm.trans hr49))
  rw [same] at heap49
  have stored49 := (heap49 Binding20.sourceAddress sequenceLive40
    (by decide +kernel) (by decide +kernel) (by decide +kernel)).trans stored40
  refine ⟨result,runC_join P.F (m:=40) (n:=9) hr40 hr49,h49,hv,stored49,
    CellsLive.grow _ _ _ _ sequenceLive40,?_,?_⟩
  · intro a alive below
    have grow39 : live39 a := Or.inl (Or.inl (Or.inl (Or.inl alive)))
    have grow40 : live40 a := ClosureLive.grow _ _ _ _ _ _ grow39
    have neArrays : a ≠ Parameter41.sourceAddress := by
      have hn : 3126641 ≤ Parameter41.sourceAddress := by decide +kernel
      omega
    have neAxis : a ≠ Parameter43.sourceAddress := by
      have hn : 3126641 ≤ Parameter43.sourceAddress := by decide +kernel
      omega
    have neStream : a ≠ Parameter47.sourceAddress := by
      have hn : 3126641 ≤ Parameter47.sourceAddress := by decide +kernel
      omega
    have neS : a ≠ Binding20.sourceAddress := by
      have hn : 3126641 ≤ Binding20.sourceAddress := by decide +kernel
      omega
    have neD : a ≠ Binding22.sourceAddress := by
      have hn : 3126641 ≤ Binding22.sourceAddress := by decide +kernel
      omega
    rw [heap49 a grow40 neArrays neAxis neStream,heap40 _ (h39.heap.targetBound _ grow39),frame39 a alive neS neD]
  · intro gpuLive
    have gpuLive39 : live39 Parameter45.address := Or.inl (Or.inl (Or.inl (Or.inl gpuLive)))
    have gpuHeap39 := frame39 Parameter45.address gpuLive (by decide +kernel) (by decide +kernel)
    have gpuHeap40 := heap40 _ (h39.heap.targetBound _ gpuLive39)
    have gpu40 : cellValueAt s40 (R.a Parameter45.address) = cellValueAt s (R.a Parameter45.address) := by
      simp only [cellValueAt,gpuHeap40,gpuHeap39]
    obtain ⟨streamResult,streamRun,_,value,streamCell,valueEq⟩ := concat_parameter_stream_preserved
      (NumberRoles ν₀ ν C₀ C) fr R C₀ C live40 framed before after old old' s40 h40 hb40
      (fun v => v = cellValueAt s (R.a Parameter45.address)) gpu40
    have sameStream : streamResult = result := congrArg Prod.fst (Option.some.inj (streamRun.symm.trans hr49))
    rw [sameStream] at streamCell
    simpa only [cellValueAt,streamCell] using valueEq


theorem first_fortynine_sequence_transport
    (FR : Ren → LSt → LSt → Prop) (R : Ren) (ν₀ ν : Nat → F64) (C₀ C : CSrv)
    (roles : Nat → Host.Mlx.Ffi.Annotated.GraphNode)
    (ObjRel : Ren → Nat → Host.Mlx.Ffi.Obj → Host.Mlx.Ffi.Obj → Prop)
    (boundary H N : Nat → Prop) (tail : List NumV)
    (live framed : Nat → Prop) (before after : List Val) (old old' : List Event) (s : St LSt)
    (h : StateR (NumberRoles ν₀ ν C₀ C) (NativeFrame FR ν₀ ν C₀ C roles ObjRel boundary H N tail)
      R live framed before after old old' input s)
    (rank : s.heap.get (R.a Variable5.address) = some (.cell (some (natV 3))))
    (code : (Annotated.Value.literal (.lit (F64.ofNat 4))).Holds ν C R (nativeDataArgument s (R.a 90) 0))
    (proto : (Annotated.Value.literal (.lit (F64.ofNat 21))).Holds ν C R (nativeDataArgument s (R.a 90) 1))
    (bufferProtoLive : live aArrayBufferProto) (bufferProtoFixed : R.a aArrayBufferProto = aArrayBufferProto)
    (typedProtoLive : live 21) (typedProtoFixed : R.a 21 = 21)
    (arrayProtoLive : live aArrayProto) (arrayProtoFixed : R.a aArrayProto = aArrayProto)
    (dimension : (roles 22582).shape[1]? = some (.literal (.lit (F64.ofNat 1))))
    (nativeHandle : H 29363) (region : R.region 117452 = 4*R.handle 29363)
    (bound : s.next + 9 + (blockNames Parameter48.sourceBody).length ≤ 2^64) :
    ∃ result, runC P.F 49 s C = some (result,C) ∧
      StateR (NumberRoles ν₀ ν C₀ C) (NativeFrame FR ν₀ ν C₀ C roles ObjRel boundary H N tail) R
        (CellsLive (ClosureLive (LiveAfter (LiveAfter (LiveAfter (LiveAfter live NativeBuffer.input.next)
          TypedBuffer.input.next) ShapeSpread.input.next) P.RestStream.micro0.micro0.s35.next)
          callInput.next false .undef Host.Ts.Sources.Mlx.Ops.ast_n172) P.RestStream.micro0.micro0.s48.next (blockNames Parameter48.sourceBody))
        framed before after old old' P.RestStream.micro0.micro0.s49 result ∧
      result.heap.get (R.a Parameter43.sourceAddress) = some (.cell (some (natV 1))) ∧
      result.heap.get (R.a Binding20.sourceAddress) = some (.cell (some (natV 1))) ∧
      (CellsLive (ClosureLive (LiveAfter (LiveAfter (LiveAfter (LiveAfter live NativeBuffer.input.next)
          TypedBuffer.input.next) ShapeSpread.input.next) P.RestStream.micro0.micro0.s35.next)
          callInput.next false .undef Host.Ts.Sources.Mlx.Ops.ast_n172) P.RestStream.micro0.micro0.s48.next
          (blockNames Parameter48.sourceBody)) Binding20.sourceAddress := by
  obtain ⟨result,run,relation,axis,stored,alive,_,_⟩ := first_fortynine_sequence_frame_transport FR R ν₀ ν C₀ C roles ObjRel boundary H N tail
    live framed before after old old' s h rank code proto bufferProtoLive bufferProtoFixed typedProtoLive typedProtoFixed
    arrayProtoLive arrayProtoFixed dimension nativeHandle region bound
  exact ⟨result,run,relation,axis,stored,alive⟩

end Host.Load.Run.Full.Ordinary.Prefix
