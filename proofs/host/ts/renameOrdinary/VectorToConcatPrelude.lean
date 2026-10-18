import host.ts.renameOrdinary.VectorToConcatInitializeInvoke
import host.ts.renameOrdinary.VectorToConcatPreludeSupport
import host.ts.renameOrdinary.VectorToConcatNativeFrame
import host.mlx.NativeSupport
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
set_option Elab.async false
namespace Host.Load.Run.Full.Ordinary.VectorToConcat
open Host.Ts Host.Ts.Owned Host.Ts.Owned.Parametric Host.Mlx.Ffi.Annotated
theorem vector_concat_handle_counter : ArrayCall.input.ffi.mlx.next = VectorCall.input.ffi.mlx.next+1 := by host_kernel_rfl
theorem vector_concat_node_counter : ArrayCall.input.ffi.mlx.nnext = VectorCall.input.ffi.mlx.nnext := by host_kernel_rfl

/-- The complete original 88-step segment creates the owned input vector,
binds its actual returned handle, constructs the real JS output slot and
executes concat. Intermediate handle, scalar and buffer annotations are all
derived from native returns, actual stores, proved heap frames and reads. -/
theorem vector_to_concat_status (ν₀ ν : Nat → F64) (C₀ C : CSrv) (R : Ren)
    (base : Nat → GraphNode) (boundary : Nat → Prop) (objects : Nat → Object)
    (H N : Nat → Prop) (tail : List NumV) (host : HostSt → HostSt → Prop)
    (live framed : Nat → Prop) (before after : List Val) (old old' : List Event) (s : St LSt)
    (h : StateR (NumberRoles ν₀ ν C₀ C)
      (VectorHost.NativeRelation ν₀ ν C₀ C (ConcatNative.preRoles base) boundary objects H N tail host)
      R live framed before after old old' VectorCall.input s)
    (countRole : (Annotated.Value.ordinaryBig (Int.ofNat 2)).Holds ν C R (callArgument s.ctl 1))
    (bufferRole : (VectorBuffer.role [25732,29363]).Holds ν C R (objectKindAt s (R.a 3126688)))
    (axisRole : (Annotated.Value.literal (.lit (F64.fin false 1 0))).Holds ν C R (cellValueAt s (R.a AxisVariable332.address)))
    (streamRole : (Annotated.Value.handle 2).Holds ν C R (cellValueAt s (R.a StreamVariable334.address)))
    (code : (Annotated.Value.literal (.lit (F64.ofNat 9))).Holds ν C R (nativeDataArgument s (R.a 95) 0))
    (proto : (Annotated.Value.literal (.lit (F64.ofNat 26))).Holds ν C R (nativeDataArgument s (R.a 95) 1))
    (vectorSignatureFrame : ¬ framed 4411) (nullSignatureFrame : ¬ framed 4253) (concatSignatureFrame : ¬ framed 4409)
    (firstLive : H 25732) (secondLive : H 29363)
    (functionProtoLive : live aFunctionProto) (functionProtoFixed : R.a aFunctionProto = aFunctionProto)
    (globalLive : live aGlobal) (globalFixed : R.a aGlobal = aGlobal)
    (arrayProtoLive : live aArrayProto) (arrayProtoFixed : R.a aArrayProto = aArrayProto)
    (bufferProtoLive : live aArrayBufferProto) (bufferProtoFixed : R.a aArrayBufferProto = aArrayBufferProto)
    (typedProtoLive : live 26) (typedProtoFixed : R.a 26 = 26)
    (nodeBound : s.ffi.mlx.nnext < 2^64) (nativeBound : s.ffi.mlx.next+1 < 2^64) (heapBound : s.next+40 ≤ 2^64) :
    ∃ result, runC P.F 88 s C = some (result,C) ∧
      StateR (NumberRoles ν₀ ν C₀ C)
        (VectorHost.NativeRelation ν₀ ν C₀ C (ConcatNative.postRoles base) boundary
          (objectWrite objects 29371 (.vec [20208,22582]))
          (fun a => a = 29372 ∨ a = 29371 ∨ H a) (fun i => i = 22587 ∨ N i) tail host)
        R (callbackLive (initializedSlotLive (outBodyLive live))) framed before after old old' ConcatCall.output result ∧
      (slotKindRole 29372).Holds ν C R (objectKindAt result (R.a 3126700)) ∧
      result.ctl = .ret (.num zeroN) := by
  let NR := NumberRoles ν₀ ν C₀ C
  let initialFR := VectorHost.NativeRelation ν₀ ν C₀ C (ConcatNative.preRoles base) boundary objects H N tail host
  let nextObjects := objectWrite objects 29371 (.vec [20208,22582])
  let nextHandles := fun a => a = 29371 ∨ H a
  let nextFR := VectorHost.NativeRelation ν₀ ν C₀ C (ConcatNative.preRoles base) boundary nextObjects nextHandles N tail host
  obtain ⟨_,la,ls,lc⟩ := vector_prelude_support NR initialFR R live framed before after old old' s h globalLive
  have producers := h.native.2.nodesOf_support [25732,29363] [20208,22582] ⟨firstLive,secondLive,True.intro⟩ VectorCall.source_inputs
  obtain ⟨s250,hr249,h250,hc250,heap250,next250⟩ := vector_native_transport_heap ν₀ ν C₀ C R (ConcatNative.preRoles base)
    boundary objects H N tail host live framed before after old old' s h countRole bufferRole vectorSignatureFrame firstLive secondLive (by omega)
  have bound250 : s250.next+32 ≤ 2^64 := by rw [next250]; omega
  obtain ⟨s295,hr250,h295,stored,frame295⟩ := vector_to_null_initializer_fields ν₀ ν C₀ C nextFR R
    live framed before after old old' s250 h250 functionProtoLive functionProtoFixed globalLive globalFixed bound250
  have vectorCell := stored _ hc250
  rw [vector_cell_address] at vectorCell
  have vr : (Annotated.Value.handle 29371).Holds ν C R (cellValueAt s295 (R.a VectorVariable330.address)) := by
    simp only [cellValueAt,vectorCell]
    exact .handle _
  have oldFrame (a : Nat) (ha : live a) (other : a ≠ VectorBinding251.sourceAddress) :
      s295.heap.get (R.a a) = s.heap.get (R.a a) :=
    (frame295 a ha other).trans (congrArg (fun heap => heap.get (R.a a)) heap250)
  have ar : (Annotated.Value.literal (.lit (F64.fin false 1 0))).Holds ν C R (cellValueAt s295 (R.a AxisVariable332.address)) :=
    (cellValueAt_heap_at s s295 _ (oldFrame _ la axis_not_vector_cell)).symm ▸ axisRole
  have sr : (Annotated.Value.handle 2).Holds ν C R (cellValueAt s295 (R.a StreamVariable334.address)) :=
    (cellValueAt_heap_at s s295 _ (oldFrame _ ls stream_not_vector_cell)).symm ▸ streamRole
  have ctorFrame := oldFrame 95 lc constructor_not_vector_cell
  have code295 : (Annotated.Value.literal (.lit (F64.ofNat 9))).Holds ν C R (nativeDataArgument s295 (R.a 95) 0) := by
    have he : nativeDataArgument s295 (R.a 95) 0 = nativeDataArgument s (R.a 95) 0 := by
      simp only [nativeDataArgument,St.obj?,ctorFrame]
    exact he.symm ▸ code
  have proto295 : (Annotated.Value.literal (.lit (F64.ofNat 26))).Holds ν C R (nativeDataArgument s295 (R.a 95) 1) := by
    have he : nativeDataArgument s295 (R.a 95) 1 = nativeDataArgument s (R.a 95) 1 := by
      simp only [nativeDataArgument,St.obj?,ctorFrame]
    exact he.symm ▸ proto
  have handleEq : s295.ffi.mlx.next = s.ffi.mlx.next+1 := by
    have h₀ := h.native.2.handleMap.fresh 1
    have h₁ := h295.native.2.handleMap.head
    change R.handle ArrayCall.input.ffi.mlx.next = s295.ffi.mlx.next at h₁
    rw [vector_concat_handle_counter] at h₁
    exact h₁.symm.trans h₀
  have nodeEq : s295.ffi.mlx.nnext = s.ffi.mlx.nnext := by
    have h₀ := h.native.2.nodeMap.head
    have h₁ := h295.native.2.nodeMap.head
    change R.node ArrayCall.input.ffi.mlx.nnext = s295.ffi.mlx.nnext at h₁
    rw [vector_concat_node_counter] at h₁
    exact h₁.symm.trans h₀
  have next295 : s295.next = s.next+9 := (h250.target_next_add h295 9 (by host_kernel_rfl)).trans (congrArg (·+9) next250)
  have bound295 : s295.next+6 ≤ 2^64 := by rw [next295]; omega
  obtain ⟨result,hr295,h337,slot337,status337⟩ := initialize_and_concat_status ν₀ ν C₀ C R base boundary nextObjects nextHandles N tail host
    (outBodyLive live) framed before after old old' s295 h295 vr ar sr code295 proto295 nullSignatureFrame concatSignatureFrame
    (Or.inl rfl) producers.1 producers.2.1
    (out_body_grow live _ arrayProtoLive) arrayProtoFixed (out_body_grow live _ bufferProtoLive) bufferProtoFixed
    (out_body_grow live _ typedProtoLive) typedProtoFixed (nodeEq.symm ▸ nodeBound) (handleEq.symm ▸ nativeBound) bound295
  have firstRun : runC P.F 46 s C = some (s295,C) := by
    apply runC_cons P.F 45 s s250 s295 C C C (h.control.isHalt_eq.trans (by host_kernel_rfl)) hr249
    exact hr250
  exact ⟨result,runC_join P.F (m := 46) (n := 42) firstRun hr295,h337,slot337,status337⟩
theorem vector_to_concat (ν₀ ν : Nat → F64) (C₀ C : CSrv) (R : Ren)
    (base : Nat → GraphNode) (boundary : Nat → Prop) (objects : Nat → Object)
    (H N : Nat → Prop) (tail : List NumV) (host : HostSt → HostSt → Prop)
    (live framed : Nat → Prop) (before after : List Val) (old old' : List Event) (s : St LSt)
    (h : StateR (NumberRoles ν₀ ν C₀ C)
      (VectorHost.NativeRelation ν₀ ν C₀ C (ConcatNative.preRoles base) boundary objects H N tail host)
      R live framed before after old old' VectorCall.input s)
    (countRole : (Annotated.Value.ordinaryBig (Int.ofNat 2)).Holds ν C R (callArgument s.ctl 1))
    (bufferRole : (VectorBuffer.role [25732,29363]).Holds ν C R (objectKindAt s (R.a 3126688)))
    (axisRole : (Annotated.Value.literal (.lit (F64.fin false 1 0))).Holds ν C R (cellValueAt s (R.a AxisVariable332.address)))
    (streamRole : (Annotated.Value.handle 2).Holds ν C R (cellValueAt s (R.a StreamVariable334.address)))
    (code : (Annotated.Value.literal (.lit (F64.ofNat 9))).Holds ν C R (nativeDataArgument s (R.a 95) 0))
    (proto : (Annotated.Value.literal (.lit (F64.ofNat 26))).Holds ν C R (nativeDataArgument s (R.a 95) 1))
    (vectorSignatureFrame : ¬ framed 4411) (nullSignatureFrame : ¬ framed 4253) (concatSignatureFrame : ¬ framed 4409)
    (firstLive : H 25732) (secondLive : H 29363)
    (functionProtoLive : live aFunctionProto) (functionProtoFixed : R.a aFunctionProto = aFunctionProto)
    (globalLive : live aGlobal) (globalFixed : R.a aGlobal = aGlobal)
    (arrayProtoLive : live aArrayProto) (arrayProtoFixed : R.a aArrayProto = aArrayProto)
    (bufferProtoLive : live aArrayBufferProto) (bufferProtoFixed : R.a aArrayBufferProto = aArrayBufferProto)
    (typedProtoLive : live 26) (typedProtoFixed : R.a 26 = 26)
    (nodeBound : s.ffi.mlx.nnext < 2^64) (nativeBound : s.ffi.mlx.next+1 < 2^64) (heapBound : s.next+40 ≤ 2^64) :
    ∃ result, runC P.F 88 s C = some (result,C) ∧
      StateR (NumberRoles ν₀ ν C₀ C)
        (VectorHost.NativeRelation ν₀ ν C₀ C (ConcatNative.postRoles base) boundary
          (objectWrite objects 29371 (.vec [20208,22582]))
          (fun a => a = 29372 ∨ a = 29371 ∨ H a) (fun i => i = 22587 ∨ N i) tail host)
        R (callbackLive (initializedSlotLive (outBodyLive live))) framed before after old old' ConcatCall.output result ∧
      (slotKindRole 29372).Holds ν C R (objectKindAt result (R.a 3126700)) := by
  obtain ⟨result,hr,hs,hslot,_⟩ := vector_to_concat_status ν₀ ν C₀ C R base boundary objects H N tail host live framed before after old old' s h countRole bufferRole axisRole streamRole code proto vectorSignatureFrame nullSignatureFrame concatSignatureFrame firstLive secondLive functionProtoLive functionProtoFixed globalLive globalFixed arrayProtoLive arrayProtoFixed bufferProtoLive bufferProtoFixed typedProtoLive typedProtoFixed nodeBound nativeBound heapBound
  exact ⟨result,hr,hs,hslot⟩

end Host.Load.Run.Full.Ordinary.VectorToConcat
