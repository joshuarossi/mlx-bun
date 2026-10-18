import host.mlx.NativeUnaryHost
import host.mlx.NativeBufferResultFrame
import host.mlx.NativeAbsentObjectRoles

set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 1000000
namespace Host.Load.Run.Full.Ordinary.UnaryHost
open Host.Ts Host.Ts.Owned Host.Ts.Owned.Parametric Host.Ts.Owned.Annotated
open Host.Mlx.Ffi Host.Mlx.Ffi.NativeRoles Host.Mlx.Ffi.Annotated

/-- The current input and null-slot notes suffice for the original unary
dispatch. Every retained inventory and the indexed producer policy survive;
the output slot records the actual fresh native handle. -/
theorem retained_from_source {notes : RetainedNotes}
    (ν₀ ν : Nat → F64) (C₀ C : CSrv) (R : Ren)
    (nodes : Nat → GraphNode) (boundary : Nat → Prop) (objects : Nat → Object)
    (roots H N : Nat → Prop) (tail : List NumV) (host : HostSt → HostSt → Prop)
    (live framed : Nat → Prop) (before after : List Val) (old old' : List Event) (s₀ s : Host.Ts.St LSt)
    (h : Parametric.StateR (NumberRoles ν₀ ν C₀ C) (VectorHost.NativeRelation ν₀ ν C₀ C nodes boundary objects H N tail host)
      R live framed before after old old' s₀ s)
    (inventory : RetainedInventory notes ν₀ ν C₀ C R live s₀ s)
    (policy : ProducerAnnotations roots H N nodes objects)
    (name : Name) (fn types out handle stream input : Nat) (node : Node)
    (function signatureObject : Host.Ts.Obj) (returns : Name) (receiver : Val)
    (mlx : isMlx name = true) (unary : symOf name = some .unary)
    (control : s₀.ctl = .call (.obj fn) receiver [.ptr (.js out) 0,.big (Int.ofNat handle),.big (Int.ofNat stream)])
    (functionRead : s₀.heap.get fn = some (.obj function))
    (functionKind : function.kind = .fn (.native (.ffi .symbol) [.str name,.obj types,.str returns]))
    (signatureRead : s₀.heap.get types = some (.obj signatureObject))
    (signatureKind : signatureObject.kind = .array [.str chars!"ptr",.str chars!"u64",.str chars!"u64"])
    (signatureFrame : ¬ framed types) (handleLive : H handle)
    (producer : s₀.ffi.mlx.nodeId? handle = some input) (sourceNode : s₀.ffi.mlx.nodes.get input = some node)
    (sourceNodes : s₀.ffi.mlx.nnext < 2^64) (targetNodes : s.ffi.mlx.nnext < 2^64)
    (sourceHandles : s₀.ffi.mlx.next < 2^64) (targetHandles : s.ffi.mlx.next < 2^64)
    (sourceHeap : out < 2^64) (targetHeap : s.next < 2^64)
    (fnRole thisRole : Annotated.Value)
    (controlNote : notes.runtime.control = callNote fnRole thisRole [.ptr (.js out) 0,.handle handle,.handle stream])
    (slotNote : notes.buffers.owners out = some (handleSlotNotes 0)) :
    let newRoles := nodeWrite nodes s₀.ffi.mlx.nnext (unaryRole nodes name input)
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
  have handleRole := (inventory.runtime.call_argument_role fnRole thisRole
    [.ptr (.js out) 0,.handle handle,.handle stream] (.obj fn) receiver _ control controlNote 1 (.handle handle) rfl).2
  have streamRole := (inventory.runtime.call_argument_role fnRole thisRole
    [.ptr (.js out) 0,.handle handle,.handle stream] (.obj fn) receiver _ control controlNote 2 (.handle stream) rfl).2
  obtain ⟨t,sourceRun,targetRun,post,slotRole,sourceFrame,targetFrame,outside,targetReturn⟩ :=
    from_source ν₀ ν C₀ C R nodes boundary objects H N tail host live framed before after old old' s₀ s h
      name fn types out handle stream input node function signatureObject outObject returns receiver mlx unary
      control functionRead functionKind signatureRead signatureKind outputRead outputKind signatureFrame handleLive producer sourceNode
      sourceNodes targetNodes sourceHandles targetHandles sourceHeap targetHeap handleRole streamRole outputRole
  let sourcePost := finishBuffer s₀ (Host.Load.Owned.unaryWorld s₀.ffi name input node) out 0 outObject
    (cellParts .u64 (.big (Int.ofNat 0)) 8 0) (cellParts .u64 (.big (Int.ofNat s₀.ffi.mlx.next)) 8 0)
    name [.jsPtr out 0 (cellParts .u64 (.big (Int.ofNat 0)) 8 0),.big (Int.ofNat handle),.big (Int.ofNat stream)]
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
      (nodeWrite nodes s₀.ffi.mlx.nnext (unaryRole nodes name input)) boundary
      (objectWrite objects s₀.ffi.mlx.next .stream) (fun a => a = s₀.ffi.mlx.next ∨ H a)
      (fun i => i = s₀.ffi.mlx.nnext ∨ N i) tail host R sourcePost.ffi t.ffi := ⟨post.native.1,nativePost⟩
  have newPost := post.setFfi sourcePost.ffi t.ffi nativePair
  have supported : N input := h.native.2.arrLive handle input handleLive (by
    have nonzero : handle ≠ 0 := by
      intro same
      subst handle
      simp only [Host.Mlx.Ffi.St.nodeId?,Nat.beq_refl,Bool.cond_true] at producer
      cases producer
    have beq : Nat.beq handle 0 = false := by
      cases equal : Nat.beq handle 0
      · rfl
      · exact False.elim (nonzero (Nat.eq_of_beq_eq_true equal))
    simpa only [Host.Mlx.Ffi.St.nodeId?,beq,Bool.cond_false] using producer)
  have nodePolicy := policy.write_node s₀.ffi.mlx.nnext (unaryRole nodes name input)
    (.unary (strip name)) [input] rfl ⟨supported,True.intro⟩
  have newPolicy := nodePolicy.new_object s₀.ffi.mlx.next .stream True.intro
  exact ⟨sourcePost,t,sourceRun,targetRun,newPost,retained,newPolicy,newPolicy.source nativePost⟩

end Host.Load.Run.Full.Ordinary.UnaryHost
