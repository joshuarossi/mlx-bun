import host.ts.renameOrdinary.VectorToConcatCallbackPath
import host.ts.renameOrdinary.VectorToConcatEntryRoles
import host.ts.renameOrdinary.VectorToConcatInvoke
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
set_option Elab.async false
namespace Host.Load.Run.Full.Ordinary.VectorToConcat
open Host.Ts Host.Ts.Owned Host.Ts.Owned.Parametric Host.Mlx.Ffi.Annotated
theorem callback_handle_counter : PointerReturn310.input.ffi.mlx.next = OutputVariable328.input.ffi.mlx.next := by host_kernel_rfl
theorem callback_node_counter : PointerReturn310.input.ffi.mlx.nnext = OutputVariable328.input.ffi.mlx.nnext := by host_kernel_rfl

/-- From the real ptr return, the original callback and native concat execute
27 steps. The incoming fixed cell/buffer roles are carried by proved heap
frames and actual identifier reads; no future call-argument role is assumed. -/
theorem callback_and_concat_status_with_vector (ν₀ ν : Nat → F64) (C₀ C : CSrv) (R : Ren)
    (base : Nat → GraphNode) (boundary : Nat → Prop) (objects : Nat → Object)
    (H N : Nat → Prop) (tail : List NumV) (host : HostSt → HostSt → Prop)
    (live framed : Nat → Prop) (before after : List Val) (old old' : List Event) (s : St LSt)
    (h : StateR (NumberRoles ν₀ ν C₀ C)
      (VectorHost.NativeRelation ν₀ ν C₀ C (ConcatNative.preRoles base) boundary objects H N tail host)
      R live framed before after old old' PointerReturn310.input s)
    (vectorRole : (Annotated.Value.handle 29371).Holds ν C R (cellValueAt s (R.a VectorVariable330.address)))
    (axisRole : (Annotated.Value.literal (.lit (F64.fin false 1 0))).Holds ν C R (cellValueAt s (R.a AxisVariable332.address)))
    (streamRole : (Annotated.Value.handle 2).Holds ν C R (cellValueAt s (R.a StreamVariable334.address)))
    (slotRole : (slotKindRole 0).Holds ν C R (objectKindAt s (R.a 3126700)))
    (signatureFrame : ¬ framed 4409) (vectorLive : H 29371) (firstLive : N 20208) (secondLive : N 22582)
    (nodeBound : s.ffi.mlx.nnext < 2^64) (handleBound : s.ffi.mlx.next < 2^64) (heapBound : s.next+3 ≤ 2^64) :
    ∃ result, runC P.F 27 s C = some (result,C) ∧
      StateR (NumberRoles ν₀ ν C₀ C)
        (VectorHost.NativeRelation ν₀ ν C₀ C (ConcatNative.postRoles base) boundary objects
          (fun a => a = 29372 ∨ H a) (fun i => i = 22587 ∨ N i) tail host)
        R (callbackLive live) framed before after old old' ConcatCall.output result ∧
      (slotKindRole 29372).Holds ν C R (objectKindAt result (R.a 3126700)) ∧
      result.ctl = .ret (.num zeroN) ∧
      (Annotated.Value.handle 29371).Holds ν C R (cellValueAt result (R.a VectorVariable330.address)) := by
  let NR := NumberRoles ν₀ ν C₀ C
  let fr := VectorHost.NativeRelation ν₀ ν C₀ C (ConcatNative.preRoles base) boundary objects H N tail host
  obtain ⟨s328,_,hr310,h328,frame328,_,_,_⟩ := concat_callback_arguments_cuts NR fr R C₀ C live framed
    before after old old' s h heapBound
  obtain ⟨lv,la,ls,lb⟩ := concat_entry_support NR fr R live framed before after old old' s h
  have vr : (Annotated.Value.handle 29371).Holds ν C R (cellValueAt s328 (R.a VectorVariable330.address)) := by
    exact (cellValueAt_heap_at s s328 _ (frame328 _ lv vector_not_pointer_cell)).symm ▸ vectorRole
  have ar : (Annotated.Value.literal (.lit (F64.fin false 1 0))).Holds ν C R (cellValueAt s328 (R.a AxisVariable332.address)) := by
    exact (cellValueAt_heap_at s s328 _ (frame328 _ la axis_not_pointer_cell)).symm ▸ axisRole
  have sr : (Annotated.Value.handle 2).Holds ν C R (cellValueAt s328 (R.a StreamVariable334.address)) := by
    exact (cellValueAt_heap_at s s328 _ (frame328 _ ls stream_not_pointer_cell)).symm ▸ streamRole
  have slot : (slotKindRole 0).Holds ν C R (objectKindAt s328 (R.a 3126700)) := by
    have hh := frame328 _ lb slot_not_pointer_cell
    have he : objectKindAt s328 (R.a 3126700) = objectKindAt s (R.a 3126700) := by simp only [objectKindAt,St.obj?,hh]
    rw [he]; exact slotRole
  have handleEq : s328.ffi.mlx.next = s.ffi.mlx.next := by
    have h₀ := h.native.2.handleMap.head
    have h₁ := h328.native.2.handleMap.head
    change R.handle PointerReturn310.input.ffi.mlx.next = s.ffi.mlx.next at h₀
    change R.handle OutputVariable328.input.ffi.mlx.next = s328.ffi.mlx.next at h₁
    rw [callback_handle_counter] at h₀
    exact h₁.symm.trans h₀
  have nodeEq : s328.ffi.mlx.nnext = s.ffi.mlx.nnext := by
    have h₀ := h.native.2.nodeMap.head
    have h₁ := h328.native.2.nodeMap.head
    change R.node PointerReturn310.input.ffi.mlx.nnext = s.ffi.mlx.nnext at h₀
    change R.node OutputVariable328.input.ffi.mlx.nnext = s328.ffi.mlx.nnext at h₁
    rw [callback_node_counter] at h₀
    exact h₁.symm.trans h₀
  have nextEq : s328.next = s.next+1 := h.target_next_add h328 1 (by host_kernel_rfl)
  have heapBound328 : s328.next < 2^64 := by rw [nextEq]; omega
  obtain ⟨result,hr328,h337,slot337,status337,vectorPost⟩ := read_arguments_and_concat_status_with_vector ν₀ ν C₀ C R base boundary objects H N tail host
    (callbackLive live) framed before after old old' s328 h328 vr ar sr slot signatureFrame vectorLive firstLive secondLive
    (nodeEq.symm ▸ nodeBound) (handleEq.symm ▸ handleBound) heapBound328
  exact ⟨result,runC_join P.F (m := 18) (n := 9) hr310 hr328,h337,slot337,status337,vectorPost⟩

theorem callback_and_concat_status (ν₀ ν : Nat → F64) (C₀ C : CSrv) (R : Ren)
    (base : Nat → GraphNode) (boundary : Nat → Prop) (objects : Nat → Object)
    (H N : Nat → Prop) (tail : List NumV) (host : HostSt → HostSt → Prop)
    (live framed : Nat → Prop) (before after : List Val) (old old' : List Event) (s : St LSt)
    (h : StateR (NumberRoles ν₀ ν C₀ C)
      (VectorHost.NativeRelation ν₀ ν C₀ C (ConcatNative.preRoles base) boundary objects H N tail host)
      R live framed before after old old' PointerReturn310.input s)
    (vectorRole : (Annotated.Value.handle 29371).Holds ν C R (cellValueAt s (R.a VectorVariable330.address)))
    (axisRole : (Annotated.Value.literal (.lit (F64.fin false 1 0))).Holds ν C R (cellValueAt s (R.a AxisVariable332.address)))
    (streamRole : (Annotated.Value.handle 2).Holds ν C R (cellValueAt s (R.a StreamVariable334.address)))
    (slotRole : (slotKindRole 0).Holds ν C R (objectKindAt s (R.a 3126700)))
    (signatureFrame : ¬ framed 4409) (vectorLive : H 29371) (firstLive : N 20208) (secondLive : N 22582)
    (nodeBound : s.ffi.mlx.nnext < 2^64) (handleBound : s.ffi.mlx.next < 2^64) (heapBound : s.next+3 ≤ 2^64) :
    ∃ result, runC P.F 27 s C = some (result,C) ∧
      StateR (NumberRoles ν₀ ν C₀ C)
        (VectorHost.NativeRelation ν₀ ν C₀ C (ConcatNative.postRoles base) boundary objects
          (fun a => a = 29372 ∨ H a) (fun i => i = 22587 ∨ N i) tail host)
        R (callbackLive live) framed before after old old' ConcatCall.output result ∧
      (slotKindRole 29372).Holds ν C R (objectKindAt result (R.a 3126700)) ∧
      result.ctl = .ret (.num zeroN) := by
  obtain ⟨result,run,related,slot,status,_⟩ := callback_and_concat_status_with_vector ν₀ ν C₀ C R base boundary objects H N tail host live framed before after old old' s h vectorRole axisRole streamRole slotRole signatureFrame vectorLive firstLive secondLive nodeBound handleBound heapBound
  exact ⟨result,run,related,slot,status⟩

theorem callback_and_concat (ν₀ ν : Nat → F64) (C₀ C : CSrv) (R : Ren)
    (base : Nat → GraphNode) (boundary : Nat → Prop) (objects : Nat → Object)
    (H N : Nat → Prop) (tail : List NumV) (host : HostSt → HostSt → Prop)
    (live framed : Nat → Prop) (before after : List Val) (old old' : List Event) (s : St LSt)
    (h : StateR (NumberRoles ν₀ ν C₀ C)
      (VectorHost.NativeRelation ν₀ ν C₀ C (ConcatNative.preRoles base) boundary objects H N tail host)
      R live framed before after old old' PointerReturn310.input s)
    (vectorRole : (Annotated.Value.handle 29371).Holds ν C R (cellValueAt s (R.a VectorVariable330.address)))
    (axisRole : (Annotated.Value.literal (.lit (F64.fin false 1 0))).Holds ν C R (cellValueAt s (R.a AxisVariable332.address)))
    (streamRole : (Annotated.Value.handle 2).Holds ν C R (cellValueAt s (R.a StreamVariable334.address)))
    (slotRole : (slotKindRole 0).Holds ν C R (objectKindAt s (R.a 3126700)))
    (signatureFrame : ¬ framed 4409) (vectorLive : H 29371) (firstLive : N 20208) (secondLive : N 22582)
    (nodeBound : s.ffi.mlx.nnext < 2^64) (handleBound : s.ffi.mlx.next < 2^64) (heapBound : s.next+3 ≤ 2^64) :
    ∃ result, runC P.F 27 s C = some (result,C) ∧
      StateR (NumberRoles ν₀ ν C₀ C)
        (VectorHost.NativeRelation ν₀ ν C₀ C (ConcatNative.postRoles base) boundary objects
          (fun a => a = 29372 ∨ H a) (fun i => i = 22587 ∨ N i) tail host)
        R (callbackLive live) framed before after old old' ConcatCall.output result ∧
      (slotKindRole 29372).Holds ν C R (objectKindAt result (R.a 3126700)) := by
  obtain ⟨result,hr,hs,hslot,_⟩ := callback_and_concat_status ν₀ ν C₀ C R base boundary objects H N tail host live framed before after old old' s h vectorRole axisRole streamRole slotRole signatureFrame vectorLive firstLive secondLive nodeBound handleBound heapBound
  exact ⟨result,hr,hs,hslot⟩

theorem callback_and_concat_status_with_caller (ν₀ ν : Nat → F64) (C₀ C : CSrv) (R : Ren)
    (base : Nat → GraphNode) (boundary : Nat → Prop) (objects : Nat → Object)
    (H N : Nat → Prop) (tail : List NumV) (host : HostSt → HostSt → Prop)
    (live framed : Nat → Prop) (before after : List Val) (old old' : List Event) (s : St LSt)
    (h : StateR (NumberRoles ν₀ ν C₀ C)
      (VectorHost.NativeRelation ν₀ ν C₀ C (ConcatNative.preRoles base) boundary objects H N tail host)
      R live framed before after old old' PointerReturn310.input s)
    (vectorRole : (Annotated.Value.handle 29371).Holds ν C R (cellValueAt s (R.a VectorVariable330.address)))
    (axisRole : (Annotated.Value.literal (.lit (F64.fin false 1 0))).Holds ν C R (cellValueAt s (R.a AxisVariable332.address)))
    (streamRole : (Annotated.Value.handle 2).Holds ν C R (cellValueAt s (R.a StreamVariable334.address)))
    (slotRole : (slotKindRole 0).Holds ν C R (objectKindAt s (R.a 3126700)))
    (signatureFrame : ¬ framed 4409) (vectorLive : H 29371) (firstLive : N 20208) (secondLive : N 22582)
    (nodeBound : s.ffi.mlx.nnext < 2^64) (handleBound : s.ffi.mlx.next < 2^64) (heapBound : s.next+3 ≤ 2^64) :
    ∃ result, runC P.F 27 s C = some (result,C) ∧
      StateR (NumberRoles ν₀ ν C₀ C)
        (VectorHost.NativeRelation ν₀ ν C₀ C (ConcatNative.postRoles base) boundary objects
          (fun a => a = 29372 ∨ H a) (fun i => i = 22587 ∨ N i) tail host)
        R (callbackLive live) framed before after old old' ConcatCall.output result ∧
      (slotKindRole 29372).Holds ν C R (objectKindAt result (R.a 3126700)) ∧
      result.ctl = .ret (.num zeroN) ∧
      (Annotated.Value.handle 29371).Holds ν C R (cellValueAt result (R.a VectorVariable330.address)) ∧
      (∀ a, live a → a < 3126665 → result.heap.get (R.a a) = s.heap.get (R.a a)) := by
  let NR := NumberRoles ν₀ ν C₀ C
  let fr := VectorHost.NativeRelation ν₀ ν C₀ C (ConcatNative.preRoles base) boundary objects H N tail host
  obtain ⟨s328,_,hr310,h328,frame328,_,_,_⟩ := concat_callback_arguments_cuts NR fr R C₀ C live framed
    before after old old' s h heapBound
  obtain ⟨lv,la,ls,lb⟩ := concat_entry_support NR fr R live framed before after old old' s h
  have vr : (Annotated.Value.handle 29371).Holds ν C R (cellValueAt s328 (R.a VectorVariable330.address)) := by
    exact (cellValueAt_heap_at s s328 _ (frame328 _ lv vector_not_pointer_cell)).symm ▸ vectorRole
  have ar : (Annotated.Value.literal (.lit (F64.fin false 1 0))).Holds ν C R (cellValueAt s328 (R.a AxisVariable332.address)) := by
    exact (cellValueAt_heap_at s s328 _ (frame328 _ la axis_not_pointer_cell)).symm ▸ axisRole
  have sr : (Annotated.Value.handle 2).Holds ν C R (cellValueAt s328 (R.a StreamVariable334.address)) := by
    exact (cellValueAt_heap_at s s328 _ (frame328 _ ls stream_not_pointer_cell)).symm ▸ streamRole
  have slot : (slotKindRole 0).Holds ν C R (objectKindAt s328 (R.a 3126700)) := by
    have hh := frame328 _ lb slot_not_pointer_cell
    have he : objectKindAt s328 (R.a 3126700) = objectKindAt s (R.a 3126700) := by simp only [objectKindAt,St.obj?,hh]
    rw [he]; exact slotRole
  have handleEq : s328.ffi.mlx.next = s.ffi.mlx.next := by
    have h₀ := h.native.2.handleMap.head
    have h₁ := h328.native.2.handleMap.head
    change R.handle PointerReturn310.input.ffi.mlx.next = s.ffi.mlx.next at h₀
    change R.handle OutputVariable328.input.ffi.mlx.next = s328.ffi.mlx.next at h₁
    rw [callback_handle_counter] at h₀
    exact h₁.symm.trans h₀
  have nodeEq : s328.ffi.mlx.nnext = s.ffi.mlx.nnext := by
    have h₀ := h.native.2.nodeMap.head
    have h₁ := h328.native.2.nodeMap.head
    change R.node PointerReturn310.input.ffi.mlx.nnext = s.ffi.mlx.nnext at h₀
    change R.node OutputVariable328.input.ffi.mlx.nnext = s328.ffi.mlx.nnext at h₁
    rw [callback_node_counter] at h₀
    exact h₁.symm.trans h₀
  have nextEq : s328.next = s.next+1 := h.target_next_add h328 1 (by host_kernel_rfl)
  have heapBound328 : s328.next < 2^64 := by rw [nextEq]; omega
  obtain ⟨result,hr328,h337,slot337,status337,vectorPost,caller337⟩ := read_arguments_and_concat_status_with_caller ν₀ ν C₀ C R base boundary objects H N tail host
    (callbackLive live) framed before after old old' s328 h328 vr ar sr slot signatureFrame vectorLive firstLive secondLive
    (nodeEq.symm ▸ nodeBound) (handleEq.symm ▸ handleBound) heapBound328
  refine ⟨result,runC_join P.F (m := 18) (n := 9) hr310 hr328,h337,slot337,status337,vectorPost,?_⟩
  intro a ha below
  have old : callbackLive live a := by rw [callback_live_eq]; exact Or.inl ha
  exact (caller337 a old below).trans (frame328 a ha (by
    have lower : 3126665 ≤ PointerBinding311.sourceAddress := by decide +kernel
    omega))

end Host.Load.Run.Full.Ordinary.VectorToConcat
