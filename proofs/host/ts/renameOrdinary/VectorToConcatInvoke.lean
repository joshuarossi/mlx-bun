import host.ts.renameOrdinary.VectorToConcatArguments
import host.ts.RenameConcatStatus
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
set_option Elab.async false
namespace Host.Load.Run.Full.Ordinary.VectorToConcat
open Host.Ts Host.Ts.Owned Host.Ts.Owned.Parametric Host.Mlx.Ffi.Annotated

/-- The actual four source argument reads feed the original native concat
implementation. Fixed incoming cell annotations determine every decoded
scalar/handle argument; the native call creates the annotated output and
writes its fresh handle to the existing real JS slot. -/
theorem read_arguments_and_concat_status_with_vector (ν₀ ν : Nat → F64) (C₀ C : CSrv) (R : Ren)
    (base : Nat → GraphNode) (boundary : Nat → Prop) (objects : Nat → Object)
    (H N : Nat → Prop) (tail : List NumV) (host : HostSt → HostSt → Prop)
    (live framed : Nat → Prop) (before after : List Val) (old old' : List Event) (s : St LSt)
    (h : StateR (NumberRoles ν₀ ν C₀ C)
      (VectorHost.NativeRelation ν₀ ν C₀ C (ConcatNative.preRoles base) boundary objects H N tail host)
      R live framed before after old old' OutputVariable328.input s)
    (vectorRole : (Annotated.Value.handle 29371).Holds ν C R (cellValueAt s (R.a VectorVariable330.address)))
    (axisRole : (Annotated.Value.literal (.lit (F64.fin false 1 0))).Holds ν C R (cellValueAt s (R.a AxisVariable332.address)))
    (streamRole : (Annotated.Value.handle 2).Holds ν C R (cellValueAt s (R.a StreamVariable334.address)))
    (slotRole : (slotKindRole 0).Holds ν C R (objectKindAt s (R.a 3126700)))
    (signatureFrame : ¬ framed 4409) (vectorLive : H 29371) (firstLive : N 20208) (secondLive : N 22582)
    (nodeBound : s.ffi.mlx.nnext < 2^64) (handleBound : s.ffi.mlx.next < 2^64) (heapBound : s.next < 2^64) :
    ∃ result, runC P.F 9 s C = some (result,C) ∧
      StateR (NumberRoles ν₀ ν C₀ C)
        (VectorHost.NativeRelation ν₀ ν C₀ C (ConcatNative.postRoles base) boundary objects
          (fun a => a = 29372 ∨ H a) (fun i => i = 22587 ∨ N i) tail host)
        R live framed before after old old' ConcatCall.output result ∧
      (slotKindRole 29372).Holds ν C R (objectKindAt result (R.a 3126700)) ∧
      result.ctl = .ret (.num zeroN) ∧
      (Annotated.Value.handle 29371).Holds ν C R (cellValueAt result (R.a VectorVariable330.address)) := by
  obtain ⟨s336,hr328,h336,vector,axis,stream,heap336,ffi336,next336⟩ := concat_argument_roles
    (NumberRoles ν₀ ν C₀ C)
    (VectorHost.NativeRelation ν₀ ν C₀ C (ConcatNative.preRoles base) boundary objects H N tail host)
    R ν C₀ C live framed before after old old' s h vectorRole axisRole streamRole
  have slot : (slotKindRole 0).Holds ν C R (objectKindAt s336 (R.a 3126700)) := by
    simpa only [objectKindAt,St.obj?,heap336] using slotRole
  obtain ⟨result,_,hr336,h337,outputSlot,status337,_,nativeFrame⟩ := ConcatHost.transport_status ν₀ ν C₀ C R base boundary objects H N tail host
    live framed before after old old' s336 h336 vector axis stream slot signatureFrame vectorLive firstLive secondLive
    ((congrArg (fun x : LSt => x.mlx.nnext) ffi336).symm ▸ nodeBound)
    ((congrArg (fun x : LSt => x.mlx.next) ffi336).symm ▸ handleBound) (next336.symm ▸ heapBound)
  have run : runC P.F 1 s336 C = some (result,C) := by
    apply runC_cons P.F 0 s336 result result C C C (h336.control.isHalt_eq.trans (by host_kernel_rfl)) hr336
    rfl
  have vectorCellLive : live VectorVariable330.address := by
    have hl := h.controlLive
    rw [OutputVariable328.source_control] at hl
    exact env_lookup_live _ _ _ hl.2.1 argument_source_lookup_vector
  have bufferLive : live 3126700 := by
    have hl := h336.controlLive
    change treeSupport live (Encode.ctl ConcatCall.input.ctl) at hl
    rw [ConcatCall.source_control] at hl
    exact hl.2.2.1.1
  have other : R.a VectorVariable330.address ≠ R.a 3126700 := fun he =>
    (by decide +kernel : VectorVariable330.address ≠ 3126700) (h336.heap.inj _ _ vectorCellLive bufferLive he)
  have cellFrame := (nativeFrame _ other).trans (congrArg (fun hp => hp.get (R.a VectorVariable330.address)) heap336)
  have vectorPost : (Annotated.Value.handle 29371).Holds ν C R (cellValueAt result (R.a VectorVariable330.address)) :=
    (cellValueAt_heap_at s result _ cellFrame).symm ▸ vectorRole
  exact ⟨result,runC_join P.F (m := 8) (n := 1) hr328 run,h337,outputSlot,status337,vectorPost⟩

theorem read_arguments_and_concat_status (ν₀ ν : Nat → F64) (C₀ C : CSrv) (R : Ren)
    (base : Nat → GraphNode) (boundary : Nat → Prop) (objects : Nat → Object)
    (H N : Nat → Prop) (tail : List NumV) (host : HostSt → HostSt → Prop)
    (live framed : Nat → Prop) (before after : List Val) (old old' : List Event) (s : St LSt)
    (h : StateR (NumberRoles ν₀ ν C₀ C)
      (VectorHost.NativeRelation ν₀ ν C₀ C (ConcatNative.preRoles base) boundary objects H N tail host)
      R live framed before after old old' OutputVariable328.input s)
    (vectorRole : (Annotated.Value.handle 29371).Holds ν C R (cellValueAt s (R.a VectorVariable330.address)))
    (axisRole : (Annotated.Value.literal (.lit (F64.fin false 1 0))).Holds ν C R (cellValueAt s (R.a AxisVariable332.address)))
    (streamRole : (Annotated.Value.handle 2).Holds ν C R (cellValueAt s (R.a StreamVariable334.address)))
    (slotRole : (slotKindRole 0).Holds ν C R (objectKindAt s (R.a 3126700)))
    (signatureFrame : ¬ framed 4409) (vectorLive : H 29371) (firstLive : N 20208) (secondLive : N 22582)
    (nodeBound : s.ffi.mlx.nnext < 2^64) (handleBound : s.ffi.mlx.next < 2^64) (heapBound : s.next < 2^64) :
    ∃ result, runC P.F 9 s C = some (result,C) ∧
      StateR (NumberRoles ν₀ ν C₀ C)
        (VectorHost.NativeRelation ν₀ ν C₀ C (ConcatNative.postRoles base) boundary objects
          (fun a => a = 29372 ∨ H a) (fun i => i = 22587 ∨ N i) tail host)
        R live framed before after old old' ConcatCall.output result ∧
      (slotKindRole 29372).Holds ν C R (objectKindAt result (R.a 3126700)) ∧
      result.ctl = .ret (.num zeroN) := by
  obtain ⟨result,run,related,slot,status,_⟩ := read_arguments_and_concat_status_with_vector ν₀ ν C₀ C R base boundary objects H N tail host live framed before after old old' s h vectorRole axisRole streamRole slotRole signatureFrame vectorLive firstLive secondLive nodeBound handleBound heapBound
  exact ⟨result,run,related,slot,status⟩
theorem read_arguments_and_concat (ν₀ ν : Nat → F64) (C₀ C : CSrv) (R : Ren)
    (base : Nat → GraphNode) (boundary : Nat → Prop) (objects : Nat → Object)
    (H N : Nat → Prop) (tail : List NumV) (host : HostSt → HostSt → Prop)
    (live framed : Nat → Prop) (before after : List Val) (old old' : List Event) (s : St LSt)
    (h : StateR (NumberRoles ν₀ ν C₀ C)
      (VectorHost.NativeRelation ν₀ ν C₀ C (ConcatNative.preRoles base) boundary objects H N tail host)
      R live framed before after old old' OutputVariable328.input s)
    (vectorRole : (Annotated.Value.handle 29371).Holds ν C R (cellValueAt s (R.a VectorVariable330.address)))
    (axisRole : (Annotated.Value.literal (.lit (F64.fin false 1 0))).Holds ν C R (cellValueAt s (R.a AxisVariable332.address)))
    (streamRole : (Annotated.Value.handle 2).Holds ν C R (cellValueAt s (R.a StreamVariable334.address)))
    (slotRole : (slotKindRole 0).Holds ν C R (objectKindAt s (R.a 3126700)))
    (signatureFrame : ¬ framed 4409) (vectorLive : H 29371) (firstLive : N 20208) (secondLive : N 22582)
    (nodeBound : s.ffi.mlx.nnext < 2^64) (handleBound : s.ffi.mlx.next < 2^64) (heapBound : s.next < 2^64) :
    ∃ result, runC P.F 9 s C = some (result,C) ∧
      StateR (NumberRoles ν₀ ν C₀ C)
        (VectorHost.NativeRelation ν₀ ν C₀ C (ConcatNative.postRoles base) boundary objects
          (fun a => a = 29372 ∨ H a) (fun i => i = 22587 ∨ N i) tail host)
        R live framed before after old old' ConcatCall.output result ∧
      (slotKindRole 29372).Holds ν C R (objectKindAt result (R.a 3126700)) := by
  obtain ⟨result,hr,hs,hslot,_⟩ := read_arguments_and_concat_status ν₀ ν C₀ C R base boundary objects H N tail host live framed before after old old' s h vectorRole axisRole streamRole slotRole signatureFrame vectorLive firstLive secondLive nodeBound handleBound heapBound
  exact ⟨result,hr,hs,hslot⟩

end Host.Load.Run.Full.Ordinary.VectorToConcat
