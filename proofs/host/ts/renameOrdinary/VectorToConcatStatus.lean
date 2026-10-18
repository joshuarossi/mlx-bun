import host.ts.renameOrdinary.VectorToConcatPrelude
import host.ts.renameOrdinary.ConcatStatusPath
import host.ts.RenameResourceFields
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
set_option Elab.async false
namespace Host.Load.Run.Full.Ordinary.VectorToConcat
open Host.Ts Host.Ts.Owned Host.Ts.Owned.Parametric Host.Mlx.Ffi.Annotated

/-- The real vector/slot/callback/native sequence and return initialization
execute 93 source steps. Both the output handle and the exact status cell
are derived from the original call, with no future value/run premise. -/
theorem vector_to_status_cell_with_vector (ν₀ ν : Nat → F64) (C₀ C : CSrv) (R : Ren)
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
    ∃ result, runC P.F 93 s C = some (result,C) ∧
      StateR (NumberRoles ν₀ ν C₀ C)
        (VectorHost.NativeRelation ν₀ ν C₀ C (ConcatNative.postRoles base) boundary
          (objectWrite objects 29371 (.vec [20208,22582]))
          (fun a => a = 29372 ∨ a = 29371 ∨ H a) (fun i => i = 22587 ∨ N i) tail host)
        R (callbackLive (initializedSlotLive (outBodyLive live))) framed before after old old' StatusDone341.output result ∧
      (slotKindRole 29372).Holds ν C R (objectKindAt result (R.a 3126700)) ∧
      result.heap.get (R.a StatusBinding340.sourceAddress) = some (.cell (some (.num zeroN))) ∧
      (Annotated.Value.handle 29371).Holds ν C R (cellValueAt result (R.a VectorVariable330.address)) := by
  obtain ⟨s337,hr249,h337,slot337,status337,vector337⟩ := vector_to_concat_status_with_vector ν₀ ν C₀ C R base boundary objects H N tail host live framed before after old old' s h countRole bufferRole axisRole streamRole code proto vectorSignatureFrame nullSignatureFrame concatSignatureFrame firstLive secondLive functionProtoLive functionProtoFixed globalLive globalFixed arrayProtoLive arrayProtoFixed bufferProtoLive bufferProtoFixed typedProtoLive typedProtoFixed nodeBound nativeBound heapBound
  have next337 : s337.next = s.next+13 := h.heap.target_next_add h337.heap 13 (by host_kernel_rfl)
  obtain ⟨result,hr337,h342,stored,frame⟩ := concat_status_storage (NumberRoles ν₀ ν C₀ C)
    (VectorHost.NativeRelation ν₀ ν C₀ C (ConcatNative.postRoles base) boundary
      (objectWrite objects 29371 (.vec [20208,22582]))
      (fun a => a = 29372 ∨ a = 29371 ∨ H a) (fun i => i = 22587 ∨ N i) tail host)
    R C₀ C (callbackLive (initializedSlotLive (outBodyLive live))) framed before after old old' s337 h337 status337 (by rw [next337]; omega)
  have bufferLive : (callbackLive (initializedSlotLive (outBodyLive live))) 3126700 := by
    rw [callback_live_eq]
    exact Or.inl (Or.inl (Or.inr (by host_kernel_rfl)))
  have hh := frame 3126700 bufferLive (by decide +kernel)
  have slot : (slotKindRole 29372).Holds ν C R (objectKindAt result (R.a 3126700)) := by
    have he : objectKindAt result (R.a 3126700) = objectKindAt s337 (R.a 3126700) := by
      simp only [objectKindAt,St.obj?,hh]
    exact he.symm ▸ slot337
  have vectorOld := (vector_prelude_support (NumberRoles ν₀ ν C₀ C) _ R live framed before after old old' s h globalLive).1
  have vectorLive : (callbackLive (initializedSlotLive (outBodyLive live))) VectorVariable330.address := by
    rw [callback_live_eq]
    exact Or.inl (Or.inl (Or.inl (Or.inl (out_body_grow live _ vectorOld))))
  have vectorFrame := frame VectorVariable330.address vectorLive (by decide +kernel)
  have vectorPost : (Annotated.Value.handle 29371).Holds ν C R (cellValueAt result (R.a VectorVariable330.address)) :=
    (cellValueAt_heap_at s337 result _ vectorFrame).symm ▸ vector337
  exact ⟨result,runC_join P.F (m := 88) (n := 5) hr249 hr337,h342,slot,stored,vectorPost⟩

theorem vector_to_status_cell (ν₀ ν : Nat → F64) (C₀ C : CSrv) (R : Ren)
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
    ∃ result, runC P.F 93 s C = some (result,C) ∧
      StateR (NumberRoles ν₀ ν C₀ C)
        (VectorHost.NativeRelation ν₀ ν C₀ C (ConcatNative.postRoles base) boundary
          (objectWrite objects 29371 (.vec [20208,22582]))
          (fun a => a = 29372 ∨ a = 29371 ∨ H a) (fun i => i = 22587 ∨ N i) tail host)
        R (callbackLive (initializedSlotLive (outBodyLive live))) framed before after old old' StatusDone341.output result ∧
      (slotKindRole 29372).Holds ν C R (objectKindAt result (R.a 3126700)) ∧
      result.heap.get (R.a StatusBinding340.sourceAddress) = some (.cell (some (.num zeroN))) := by
  obtain ⟨result,run,related,slot,status,_⟩ := vector_to_status_cell_with_vector ν₀ ν C₀ C R base boundary objects H N tail host live framed before after old old' s h countRole bufferRole axisRole streamRole code proto vectorSignatureFrame nullSignatureFrame concatSignatureFrame firstLive secondLive functionProtoLive functionProtoFixed globalLive globalFixed arrayProtoLive arrayProtoFixed bufferProtoLive bufferProtoFixed typedProtoLive typedProtoFixed nodeBound nativeBound heapBound
  exact ⟨result,run,related,slot,status⟩

theorem vector_to_status_cell_with_caller (ν₀ ν : Nat → F64) (C₀ C : CSrv) (R : Ren)
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
    ∃ result, runC P.F 93 s C = some (result,C) ∧
      StateR (NumberRoles ν₀ ν C₀ C)
        (VectorHost.NativeRelation ν₀ ν C₀ C (ConcatNative.postRoles base) boundary
          (objectWrite objects 29371 (.vec [20208,22582]))
          (fun a => a = 29372 ∨ a = 29371 ∨ H a) (fun i => i = 22587 ∨ N i) tail host)
        R (callbackLive (initializedSlotLive (outBodyLive live))) framed before after old old' StatusDone341.output result ∧
      (slotKindRole 29372).Holds ν C R (objectKindAt result (R.a 3126700)) ∧
      result.heap.get (R.a StatusBinding340.sourceAddress) = some (.cell (some (.num zeroN))) ∧
      (Annotated.Value.handle 29371).Holds ν C R (cellValueAt result (R.a VectorVariable330.address)) ∧
      (∀ a, live a → a < 3126665 → result.heap.get (R.a a) = s.heap.get (R.a a)) := by
  obtain ⟨s337,hr249,h337,slot337,status337,vector337,caller337⟩ := vector_to_concat_status_with_caller ν₀ ν C₀ C R base boundary objects H N tail host live framed before after old old' s h countRole bufferRole axisRole streamRole code proto vectorSignatureFrame nullSignatureFrame concatSignatureFrame firstLive secondLive functionProtoLive functionProtoFixed globalLive globalFixed arrayProtoLive arrayProtoFixed bufferProtoLive bufferProtoFixed typedProtoLive typedProtoFixed nodeBound nativeBound heapBound
  have next337 : s337.next = s.next+13 := h.heap.target_next_add h337.heap 13 (by host_kernel_rfl)
  obtain ⟨result,hr337,h342,stored,frame⟩ := concat_status_storage (NumberRoles ν₀ ν C₀ C)
    (VectorHost.NativeRelation ν₀ ν C₀ C (ConcatNative.postRoles base) boundary
      (objectWrite objects 29371 (.vec [20208,22582]))
      (fun a => a = 29372 ∨ a = 29371 ∨ H a) (fun i => i = 22587 ∨ N i) tail host)
    R C₀ C (callbackLive (initializedSlotLive (outBodyLive live))) framed before after old old' s337 h337 status337 (by rw [next337]; omega)
  have bufferLive : (callbackLive (initializedSlotLive (outBodyLive live))) 3126700 := by
    rw [callback_live_eq]
    exact Or.inl (Or.inl (Or.inr (by host_kernel_rfl)))
  have hh := frame 3126700 bufferLive (by decide +kernel)
  have slot : (slotKindRole 29372).Holds ν C R (objectKindAt result (R.a 3126700)) := by
    have he : objectKindAt result (R.a 3126700) = objectKindAt s337 (R.a 3126700) := by
      simp only [objectKindAt,St.obj?,hh]
    exact he.symm ▸ slot337
  have vectorOld := (vector_prelude_support (NumberRoles ν₀ ν C₀ C) _ R live framed before after old old' s h globalLive).1
  have vectorLive : (callbackLive (initializedSlotLive (outBodyLive live))) VectorVariable330.address := by
    rw [callback_live_eq]
    exact Or.inl (Or.inl (Or.inl (Or.inl (out_body_grow live _ vectorOld))))
  have vectorFrame := frame VectorVariable330.address vectorLive (by decide +kernel)
  have vectorPost : (Annotated.Value.handle 29371).Holds ν C R (cellValueAt result (R.a VectorVariable330.address)) :=
    (cellValueAt_heap_at s337 result _ vectorFrame).symm ▸ vector337
  refine ⟨result,runC_join P.F (m := 88) (n := 5) hr249 hr337,h342,slot,stored,vectorPost,?_⟩
  intro a ha below
  have alive : (callbackLive (initializedSlotLive (outBodyLive live))) a := by
    rw [callback_live_eq]
    exact Or.inl (Or.inl (Or.inl (Or.inl (out_body_grow live _ ha))))
  exact (frame a alive (by
    have lower : 3126665 ≤ StatusBinding340.sourceAddress := by decide +kernel
    omega)).trans (caller337 a ha below)

end Host.Load.Run.Full.Ordinary.VectorToConcat
