import host.mlx.NativeBinaryHost
import host.mlx.NativeBufferResultFrame
import host.mlx.NativeAbsentObjectRoles

set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 1000000
namespace Host.Load.Run.Full.Ordinary.BinaryHost
open Host.Ts Host.Ts.Owned Host.Ts.Owned.Parametric Host.Ts.Owned.Annotated
open Host.Mlx.Ffi Host.Mlx.Ffi.NativeRoles Host.Mlx.Ffi.Annotated

/-- Current binary operands, a fixed broadcast layout and the null slot
determine the original call. All six retained families and producer policy
survive, with the slot recording the original fresh array handle. -/
theorem retained_from_source {notes : RetainedNotes}
    (ν₀ ν : Nat → F64) (C₀ C : CSrv) (R : Ren)
    (roles : Nat → GraphNode) (boundary : Nat → Prop) (objects : Nat → Object)
    (roots H N : Nat → Prop) (tail : List NumV) (host : HostSt → HostSt → Prop)
    (live framed : Nat → Prop) (before after : List Val) (old old' : List Event) (s₀ s : Host.Ts.St LSt)
    (h : Parametric.StateR (NumberRoles ν₀ ν C₀ C) (VectorHost.NativeRelation ν₀ ν C₀ C roles boundary objects H N tail host)
      R live framed before after old old' s₀ s)
    (inventory : RetainedInventory notes ν₀ ν C₀ C R live s₀ s)
    (policy : ProducerAnnotations roots H N roles objects)
    (fn types out hx hy x y stream : Nat) (name returns : Name) (function signatureObject : Host.Ts.Obj)
    (receiver : Val) (xn yn : Node) (output : Shape)
    (control : s₀.ctl = .call (.obj fn) receiver [.ptr (.js out) 0,.big (Int.ofNat hx),.big (Int.ofNat hy),.big (Int.ofNat stream)])
    (functionRead : s₀.heap.get fn = some (.obj function))
    (functionKind : function.kind = .fn (.native (.ffi .symbol) [.str name,.obj types,.str returns]))
    (signatureRead : s₀.heap.get types = some (.obj signatureObject)) (signatureKind : signatureObject.kind = .array signature)
    (signatureFrame : ¬ framed types) (mlx : isMlx name = true) (binary : symOf name = some .binary)
    (handlesLive : listSupport H [hx,hy]) (producers : nodesOf s₀.ffi.mlx [hx,hy] = some [x,y])
    (sourceX : s₀.ffi.mlx.nodes.get x = some xn) (sourceY : s₀.ffi.mlx.nodes.get y = some yn)
    (layout : BinaryLayout (roles x).shape (roles y).shape output)
    (sourceNodes : s₀.ffi.mlx.nnext < 2^64) (targetNodes : s.ffi.mlx.nnext < 2^64)
    (sourceHandles : s₀.ffi.mlx.next < 2^64) (targetHandles : s.ffi.mlx.next < 2^64)
    (sourceHeap : out < 2^64) (targetHeap : s.next < 2^64)
    (fnRole thisRole : Annotated.Value)
    (controlNote : notes.runtime.control = callNote fnRole thisRole [.ptr (.js out) 0,.handle hx,.handle hy,.handle stream])
    (slotNote : notes.buffers.owners out = some (handleSlotNotes 0)) :
    let newRoles := nodeWrite roles s₀.ffi.mlx.nnext (binaryRole roles name x y output)
    let newObjects := objectWrite objects s₀.ffi.mlx.next .stream
    let newH := fun a => a = s₀.ffi.mlx.next ∨ H a
    let newN := fun i => i = s₀.ffi.mlx.nnext ∨ N i
    ∃ sourcePost targetPost, interpC (step Host.Load.ffi s₀).run C₀ = some (sourcePost,C₀) ∧
      interpC (step Host.Load.ffi s).run C = some (targetPost,C) ∧
      Parametric.StateR (NumberRoles ν₀ ν C₀ C) (VectorHost.NativeRelation ν₀ ν C₀ C newRoles boundary newObjects newH newN tail host)
        R live framed before after old old' sourcePost targetPost ∧
      RetainedInventory (notes.nativeHandleResult out s₀.ffi.mlx.next) ν₀ ν C₀ C R live sourcePost targetPost ∧
      ProducerAnnotations roots newH newN newRoles newObjects ∧ ProducerSupport roots newH newN sourcePost.ffi.mlx := by
  dsimp only
  obtain ⟨outObject,targetObject,bytes,targetBytes,outputRead,outputKind,targetRead,targetKind,sourceRoles,targetRoles⟩ :=
    inventory.buffers.selected out (handleSlotNotes 0) slotNote
  have exactSource := cellPartNotes_handle_exact .u64 0 8 0 bytes sourceRoles
  change bytes = cellParts .u64 (.big (Int.ofNat 0)) 8 0 at exactSource
  rw [exactSource] at outputKind
  have exactTarget := cellPartNotes_handle_exact .u64 0 8 0 targetBytes targetRoles
  rw [h.native.2.handleZero] at exactTarget
  have outputRole : (fixedBufferRole VectorGetHost.nullRole).Holds ν C R (objectKindAt s (R.a out)) := by
    simpa only [objectKindAt,Host.Ts.St.obj?,targetRead,targetKind,exactTarget,VectorGetHost.null_bytes] using
      fixedBuffer_holds ν C R VectorGetHost.nullRole
  obtain ⟨_,_,targetThis,targetArgs,targetControl,_,_,_,_,_⟩ :=
    h.native_call_view fn function (.ffi .symbol) _ receiver _ control functionRead functionKind
  have current := inventory.runtime.target.control
  rw [controlNote,targetControl] at current
  have argumentRoles : ListR (fun role value => role.role.Holds ν C R value)
      (arguments out hx hy stream) (callArguments s.ctl) := by
    simp only [targetControl,callArguments]
    have held := (callNote_view current).2.2
    cases held with | cons a held =>
      cases held with | cons b held =>
        cases held with | cons c held =>
          cases held with | cons d held =>
            cases held
            exact .cons a (.cons b (.cons c (.cons d .nil)))
  obtain ⟨shape,t,sourceRun,targetRun,post,slotRole,sourceFrame,targetFrame,outside,targetReturn⟩ :=
    from_source ν₀ ν C₀ C R roles boundary objects H N tail host live framed before after old old' s₀ s h
      fn types out hx hy x y stream name returns function signatureObject outObject receiver xn yn output
      control functionRead functionKind signatureRead signatureKind outputRead outputKind signatureFrame mlx binary handlesLive
      producers sourceX sourceY layout argumentRoles outputRole sourceNodes targetNodes sourceHandles targetHandles sourceHeap targetHeap
  let sourcePost := finishBuffer s₀ (resultWorld s₀.ffi name x y shape xn.dtype yn.dtype) out 0 outObject
    (cellParts .u64 (.big (Int.ofNat 0)) 8 0) (cellParts .u64 (.big (Int.ofNat s₀.ffi.mlx.next)) 8 0)
    name (callArgs out hx hy stream (cellParts .u64 (.big (Int.ofNat 0)) 8 0))
  have sourceSlot : (slotKindRole s₀.ffi.mlx.next).Holds ν₀ C₀ identity (objectKindAt sourcePost out) := by
    simp only [sourcePost,objectKindAt,finishBuffer,Host.Ts.St.ret,Host.Ts.St.setTrace,Host.Ts.St.setFfi,
      Host.Ts.St.setObj,Host.Ts.St.obj?,PTrie.get_set_u64 _ _ _ sourceHeap,ite_true]
    exact slot_role ν₀ C₀ identity s₀.ffi.mlx.next
  have sourceOutside : ∀ a, a ≠ out → sourcePost.heap.get a = s₀.heap.get a := by
    intro a different
    change (s₀.heap.set out _).get a = s₀.heap.get a
    rw [PTrie.get_set_u64 _ _ _ sourceHeap,ite_eq_right different]
  have retained := inventory.native_handle_result h.heap out s₀.ffi.mlx.next (handleSlotNotes 0) slotNote
    sourceFrame targetFrame sourceSlot slotRole sourceOutside outside rfl targetReturn
  have absent : sourcePost.ffi.mlx.objs.get s₀.ffi.mlx.next = none := h.native.2.source_fresh_obj (Nat.le_refl _)
  have nativePost := post.native.2.reannotate_absent_object s₀.ffi.mlx.next .stream absent
  have nativePair : VectorHost.NativeRelation ν₀ ν C₀ C
      (nodeWrite roles s₀.ffi.mlx.nnext (binaryRole roles name x y output)) boundary
      (objectWrite objects s₀.ffi.mlx.next .stream) (fun a => a = s₀.ffi.mlx.next ∨ H a)
      (fun i => i = s₀.ffi.mlx.nnext ∨ N i) tail host R sourcePost.ffi t.ffi := ⟨post.native.1,nativePost⟩
  have newPost := post.setFfi sourcePost.ffi t.ffi nativePair
  have supported := h.native.2.nodesOf_support [hx,hy] [x,y] handlesLive producers
  have nodePolicy := policy.write_node s₀.ffi.mlx.nnext (binaryRole roles name x y output)
    (.binary (strip name)) [x,y] rfl supported
  have newPolicy := nodePolicy.new_object s₀.ffi.mlx.next .stream True.intro
  exact ⟨sourcePost,t,sourceRun,targetRun,newPost,retained,newPolicy,newPolicy.source nativePost⟩

end Host.Load.Run.Full.Ordinary.BinaryHost
