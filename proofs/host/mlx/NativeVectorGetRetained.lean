import host.mlx.NativeVectorGetFrame
import host.mlx.NativeBufferResultFrame
import host.mlx.NativeAbsentObjectRoles
import host.mlx.NativeBufferVectorInventory

set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0

namespace Host.Load.Run.Full.Ordinary.VectorGetHost
open Host.Ts Host.Ts.Owned Host.Ts.Owned.Parametric Host.Ts.Owned.Annotated
open Host.Mlx.Ffi Host.Mlx.Ffi.NativeRoles Host.Mlx.Ffi.NativeRoles.Arguments Host.Mlx.Ffi.Annotated

private theorem nth_support {N : Nat → Prop} : ∀ entries index node,
    listSupport N entries → nth? entries index = some node → N node := by
  intro entries
  induction entries with
  | nil => intro index node _ read; cases read
  | cons head rest ih =>
    intro index node held read
    cases index with
    | zero => cases read; exact held.1
    | succ index => exact ih index node held.2 read

/-- Element access consumes the currently retained vector/index/output notes.
Its producer is obtained from the current vector support, so no independent
post-replay node-liveness or target metadata premise is needed. -/
theorem retained_from_source {notes : RetainedNotes}
    (ν₀ ν : Nat → F64) (C₀ C : CSrv) (R : Ren)
    (roles : Nat → GraphNode) (boundary : Nat → Prop) (objects : Nat → Object)
    (H N : Nat → Prop) (tail : List NumV) (host : HostSt → HostSt → Prop)
    (live framed : Nat → Prop) (before after : List Val) (old old' : List Event) (s₀ s : Host.Ts.St LSt)
    (h : StateR (NumberRoles ν₀ ν C₀ C) (VectorHost.NativeRelation ν₀ ν C₀ C roles boundary objects H N tail host)
      R live framed before after old old' s₀ s)
    (inventory : RetainedInventory notes ν₀ ν C₀ C R live s₀ s)
    (fn types out handle index node : Nat) (function signatureObject outObject : Host.Ts.Obj) (returns : Name) (receiver : Val)
    (entries : List Nat)
    (control : s₀.ctl = .call (.obj fn) receiver [.ptr (.js out) 0,.big (Int.ofNat handle),.big (Int.ofNat index)])
    (read : s₀.heap.get fn = some (.obj function))
    (functionKind : function.kind = .fn (.native (.ffi .symbol) [.str chars!"mlx_vector_array_get",.obj types,.str returns]))
    (signatureRead : s₀.heap.get types = some (.obj signatureObject))
    (signatureKind : signatureObject.kind = .array [.str chars!"ptr",.str chars!"u64",.str chars!"u64"])
    (signatureFrame : ¬ framed types) (handleLive : H handle)
    (sourceVector : s₀.ffi.mlx.obj? handle = some (.vec entries)) (sourceIndex : nth? entries index = some node)
    (outputRead : s₀.heap.get out = some (.obj outObject))
    (sourceHandles : s₀.ffi.mlx.next < 2^64) (targetHandles : s.ffi.mlx.next < 2^64)
    (sourceHeap : out < 2^64) (targetHeap : s.next < 2^64)
    (roots : Nat → Prop) (policy : ProducerAnnotations roots H N roles objects)
    (fnRole thisRole indexRole : Value) (indexSchema : FixedIntegerRole indexRole (Int.ofNat index))
    (note : notes.runtime.control = callNote fnRole thisRole [.ptr (.js out) 0,.handle handle,indexRole])
    (selected : notes.buffers.owners out = some (handleSlotNotes 0)) :
    let newObjects := objectWrite objects s₀.ffi.mlx.next .stream
    let newH := fun a => a = s₀.ffi.mlx.next ∨ H a
    ∃ sourcePost targetPost, interpC (step Host.Load.ffi s₀).run C₀ = some (sourcePost,C₀) ∧
      interpC (step Host.Load.ffi s).run C = some (targetPost,C) ∧
      StateR (NumberRoles ν₀ ν C₀ C) (VectorHost.NativeRelation ν₀ ν C₀ C roles boundary newObjects newH N tail host)
        R live framed before after old old' sourcePost targetPost ∧
      RetainedInventory (notes.nativeHandleResult out s₀.ffi.mlx.next) ν₀ ν C₀ C R live sourcePost targetPost ∧
      ProducerAnnotations roots newH N roles newObjects ∧ ProducerSupport roots newH N sourcePost.ffi.mlx ∧
      ProducerSupport (resourceImage R.node (fun i => N i ∧ roots i))
        (resourceImage R.handle newH) (resourceImage R.node N) targetPost.ffi.mlx := by
  dsimp only
  obtain ⟨sourceObject,targetObject,bytes,targetBytes,sourceRead,sourceKind,targetRead,targetKind,sourceRoles,targetRoles⟩ :=
    inventory.buffers.selected out (handleSlotNotes 0) selected
  have sameObject : sourceObject = outObject := by exact Option.some.inj (sourceRead.symm.trans outputRead) |> Host.Ts.HObj.obj.inj
  subst sourceObject
  have exactSource := cellPartNotes_handle_exact .u64 0 8 0 bytes sourceRoles
  change bytes = cellParts .u64 (.big (Int.ofNat 0)) 8 0 at exactSource
  rw [exactSource] at sourceKind
  have exactTarget := cellPartNotes_handle_exact .u64 0 8 0 targetBytes targetRoles
  rw [h.native.2.handleZero] at exactTarget
  have outputRole : (fixedBufferRole nullRole).Holds ν C R (objectKindAt s (R.a out)) := by
    simpa only [objectKindAt,Host.Ts.St.obj?,targetRead,targetKind,exactTarget,null_bytes] using fixedBuffer_holds ν C R nullRole
  have handleRole := (inventory.runtime.call_argument_role fnRole thisRole [.ptr (.js out) 0,.handle handle,indexRole]
    (.obj fn) receiver _ control note 1 (.handle handle) rfl).2
  have indexValue := (inventory.runtime.call_argument_role fnRole thisRole [.ptr (.js out) 0,.handle handle,indexRole]
    (.obj fn) receiver _ control note 2 indexRole rfl).2
  have exactIndex := indexSchema.holds indexValue
  have nodeLive := nth_support entries index node ((policy.source h.native.2).vector handle entries handleLive sourceVector) sourceIndex
  obtain ⟨t,left,right,post,slotRole,sourceFrame,targetFrame,outside,targetReturn⟩ :=
    from_source_framed ν₀ ν C₀ C R roles boundary objects H N tail host live framed before after old old' s₀ s h
      fn types out handle index node function signatureObject outObject returns receiver entries control read functionKind signatureRead signatureKind
      outputRead sourceKind signatureFrame handleLive nodeLive sourceVector sourceIndex sourceHandles targetHandles sourceHeap targetHeap
      handleRole exactIndex outputRole
  let sourcePost := finishBuffer s₀ (Host.Load.Owned.vectorElement s₀.ffi node) out 0 outObject
    (cellParts .u64 (.big (Int.ofNat 0)) 8 0) (cellParts .u64 (.big (Int.ofNat s₀.ffi.mlx.next)) 8 0)
    chars!"mlx_vector_array_get" [.jsPtr out 0 (cellParts .u64 (.big (Int.ofNat 0)) 8 0),.big (Int.ofNat handle),.big (Int.ofNat index)]
  have sourceSlot : (slotKindRole s₀.ffi.mlx.next).Holds ν₀ C₀ identity (objectKindAt sourcePost out) := by
    simp only [sourcePost,objectKindAt,finishBuffer,Host.Ts.St.ret,Host.Ts.St.setTrace,Host.Ts.St.setFfi,
      Host.Ts.St.setObj,Host.Ts.St.obj?,PTrie.get_set_u64 _ _ _ sourceHeap,ite_true]
    exact slot_role ν₀ C₀ identity s₀.ffi.mlx.next
  have sourceOutside : ∀ a, a ≠ out → sourcePost.heap.get a = s₀.heap.get a := by
    intro a different
    change (s₀.heap.set out _).get a = s₀.heap.get a
    rw [PTrie.get_set_u64 _ _ _ sourceHeap,ite_eq_right different]
  have retained := inventory.native_handle_result h.heap out s₀.ffi.mlx.next (handleSlotNotes 0) selected
    sourceFrame targetFrame sourceSlot slotRole sourceOutside outside rfl targetReturn
  have absent : sourcePost.ffi.mlx.objs.get s₀.ffi.mlx.next = none := h.native.2.source_fresh_obj (Nat.le_refl _)
  have nativePost := post.native.2.reannotate_absent_object s₀.ffi.mlx.next .stream absent
  have nativePair : VectorHost.NativeRelation ν₀ ν C₀ C roles boundary
      (objectWrite objects s₀.ffi.mlx.next .stream) (fun a => a = s₀.ffi.mlx.next ∨ H a) N tail host R sourcePost.ffi t.ffi :=
    ⟨post.native.1,nativePost⟩
  have updated := post.setFfi sourcePost.ffi t.ffi nativePair
  have newPolicy := policy.new_object s₀.ffi.mlx.next .stream True.intro
  exact ⟨sourcePost,t,left,right,updated,retained,newPolicy,newPolicy.source nativePost,newPolicy.target nativePost⟩

end Host.Load.Run.Full.Ordinary.VectorGetHost
