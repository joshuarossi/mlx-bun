import host.ts.renameOrdinary.VectorToConcatSlotPointer
import host.ts.renameOrdinary.VectorToConcatCallbackInvoke
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
set_option Elab.async false
namespace Host.Load.Run.Full.Ordinary.VectorToConcat
open Host.Ts Host.Ts.Owned Host.Ts.Owned.Parametric Host.Mlx.Ffi.Annotated
def initializedSlotLive (live : Nat → Prop) :=
  LiveAfter (LiveAfter (LiveAfter live Array296.input.next) Typed298.input.next) (Typed298.input.next+1)

theorem initializedSlotLive.old {live : Nat → Prop} {a : Nat} (h : initializedSlotLive live a)
    (h₀ : a ≠ Array296.input.next) (h₁ : a ≠ Typed298.input.next) (h₂ : a ≠ Typed298.input.next+1) : live a := by
  rcases h with ((ha|ha)|ha)|ha
  · exact ha
  · exact False.elim (h₀ ha)
  · exact False.elim (h₁ ha)
  · exact False.elim (h₂ ha)

theorem initializer_handle_counter : ArrayCall.input.ffi.mlx.next = PointerReturn310.input.ffi.mlx.next := by host_kernel_rfl
theorem initializer_node_counter : ArrayCall.input.ffi.mlx.nnext = PointerReturn310.input.ffi.mlx.nnext := by host_kernel_rfl
theorem vector_not_slot_cell : VectorVariable330.address ≠ SlotBinding300.sourceAddress := by decide +kernel
theorem axis_not_slot_cell : AxisVariable332.address ≠ SlotBinding300.sourceAddress := by decide +kernel
theorem stream_not_slot_cell : StreamVariable334.address ≠ SlotBinding300.sourceAddress := by decide +kernel

/-- The original null initializer, typed slot, ptr call, callback and native
concat form one 42-step source segment. All call roles come from the initial
heap cells and the newly created null slot, with no intermediate annotation
or target execution premise. -/
theorem initialize_and_concat (ν₀ ν : Nat → F64) (C₀ C : CSrv) (R : Ren)
    (base : Nat → GraphNode) (boundary : Nat → Prop) (objects : Nat → Object)
    (H N : Nat → Prop) (tail : List NumV) (host : HostSt → HostSt → Prop)
    (live framed : Nat → Prop) (before after : List Val) (old old' : List Event) (s : St LSt)
    (h : StateR (NumberRoles ν₀ ν C₀ C)
      (VectorHost.NativeRelation ν₀ ν C₀ C (ConcatNative.preRoles base) boundary objects H N tail host)
      R live framed before after old old' ArrayCall.input s)
    (vectorRole : (Annotated.Value.handle 29371).Holds ν C R (cellValueAt s (R.a VectorVariable330.address)))
    (axisRole : (Annotated.Value.literal (.lit (F64.fin false 1 0))).Holds ν C R (cellValueAt s (R.a AxisVariable332.address)))
    (streamRole : (Annotated.Value.handle 2).Holds ν C R (cellValueAt s (R.a StreamVariable334.address)))
    (code : (Annotated.Value.literal (.lit (F64.ofNat 9))).Holds ν C R (nativeDataArgument s (R.a 95) 0))
    (proto : (Annotated.Value.literal (.lit (F64.ofNat 26))).Holds ν C R (nativeDataArgument s (R.a 95) 1))
    (signatureFrame : ¬ framed 4253) (concatSignatureFrame : ¬ framed 4409)
    (vectorLive : H 29371) (firstLive : N 20208) (secondLive : N 22582)
    (arrayProtoLive : live aArrayProto) (arrayProtoFixed : R.a aArrayProto = aArrayProto)
    (bufferProtoLive : live aArrayBufferProto) (bufferProtoFixed : R.a aArrayBufferProto = aArrayBufferProto)
    (typedProtoLive : live 26) (typedProtoFixed : R.a 26 = 26)
    (nodeBound : s.ffi.mlx.nnext < 2^64) (handleBound : s.ffi.mlx.next < 2^64) (bound : s.next+6 ≤ 2^64) :
    ∃ result, runC P.F 42 s C = some (result,C) ∧
      StateR (NumberRoles ν₀ ν C₀ C)
        (VectorHost.NativeRelation ν₀ ν C₀ C (ConcatNative.postRoles base) boundary objects
          (fun a => a = 29372 ∨ H a) (fun i => i = 22587 ∨ N i) tail host)
        R (callbackLive (initializedSlotLive live)) framed before after old old' ConcatCall.output result ∧
      (slotKindRole 29372).Holds ν C R (objectKindAt result (R.a 3126700)) := by
  let NR := NumberRoles ν₀ ν C₀ C
  let fr := VectorHost.NativeRelation ν₀ ν C₀ C (ConcatNative.preRoles base) boundary objects H N tail host
  obtain ⟨s310,hr295,h310,_,slot,frame⟩ := initialize_slot_pointer_heap ν₀ ν C₀ C R (ConcatNative.preRoles base)
    boundary objects H N tail host live framed before after old old' s h signatureFrame code proto
    arrayProtoLive arrayProtoFixed bufferProtoLive bufferProtoFixed typedProtoLive typedProtoFixed (by omega)
  obtain ⟨lv,la,ls,_⟩ := concat_entry_support NR fr R (initializedSlotLive live) framed before after old old' s310 h310
  have vectorOld : live VectorVariable330.address := initializedSlotLive.old lv (by decide +kernel) (by decide +kernel) (by decide +kernel)
  have axisOld : live AxisVariable332.address := initializedSlotLive.old la (by decide +kernel) (by decide +kernel) (by decide +kernel)
  have streamOld : live StreamVariable334.address := initializedSlotLive.old ls (by decide +kernel) (by decide +kernel) (by decide +kernel)
  have vr : (Annotated.Value.handle 29371).Holds ν C R (cellValueAt s310 (R.a VectorVariable330.address)) :=
    (cellValueAt_heap_at s s310 _ (frame _ vectorOld vector_not_slot_cell)).symm ▸ vectorRole
  have ar : (Annotated.Value.literal (.lit (F64.fin false 1 0))).Holds ν C R (cellValueAt s310 (R.a AxisVariable332.address)) :=
    (cellValueAt_heap_at s s310 _ (frame _ axisOld axis_not_slot_cell)).symm ▸ axisRole
  have sr : (Annotated.Value.handle 2).Holds ν C R (cellValueAt s310 (R.a StreamVariable334.address)) :=
    (cellValueAt_heap_at s s310 _ (frame _ streamOld stream_not_slot_cell)).symm ▸ streamRole
  have handleEq : s310.ffi.mlx.next = s.ffi.mlx.next := by
    have h₀ := h.native.2.handleMap.head
    have h₁ := h310.native.2.handleMap.head
    change R.handle ArrayCall.input.ffi.mlx.next = s.ffi.mlx.next at h₀
    change R.handle PointerReturn310.input.ffi.mlx.next = s310.ffi.mlx.next at h₁
    rw [initializer_handle_counter] at h₀
    exact h₁.symm.trans h₀
  have nodeEq : s310.ffi.mlx.nnext = s.ffi.mlx.nnext := by
    have h₀ := h.native.2.nodeMap.head
    have h₁ := h310.native.2.nodeMap.head
    change R.node ArrayCall.input.ffi.mlx.nnext = s.ffi.mlx.nnext at h₀
    change R.node PointerReturn310.input.ffi.mlx.nnext = s310.ffi.mlx.nnext at h₁
    rw [initializer_node_counter] at h₀
    exact h₁.symm.trans h₀
  have next310 : s310.next = s.next+3 := h.target_next_add h310 3 (by host_kernel_rfl)
  have bound310 : s310.next+3 ≤ 2^64 := by rw [next310]; omega
  obtain ⟨result,hr310,h337,slot337⟩ := callback_and_concat ν₀ ν C₀ C R base boundary objects H N tail host
    (initializedSlotLive live) framed before after old old' s310 h310 vr ar sr slot concatSignatureFrame vectorLive firstLive secondLive
    (nodeEq.symm ▸ nodeBound) (handleEq.symm ▸ handleBound) bound310
  exact ⟨result,runC_join P.F (m := 15) (n := 27) hr295 hr310,h337,slot337⟩
end Host.Load.Run.Full.Ordinary.VectorToConcat
