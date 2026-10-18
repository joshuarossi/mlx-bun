import host.mlx.NativeConcatHost
import host.mlx.NativeBufferResultFrame
import host.mlx.NativeAbsentObjectRoles

set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0

namespace Host.Load.Run.Full.Ordinary.ConcatFamilyHost
open Host.Ts Host.Ts.Owned Host.Ts.Owned.Parametric Host.Ts.Owned.Annotated
open Host.Mlx.Ffi Host.Mlx.Ffi.NativeRoles Host.Mlx.Ffi.Annotated

/-- Concatenation consumes the current vector/call/null-slot notes. Its real
write replaces only the result-slot meaning, and its real producer extends
the fixed graph policy without dropping any live object annotations. -/
theorem retained_from_source {notes : RetainedNotes}
    (ν₀ ν : Nat → F64) (C₀ C : CSrv) (R : Ren)
    (roles : Nat → GraphNode) (boundary : Nat → Prop) (objects : Nat → Object)
    (H N : Nat → Prop) (tail : List NumV) (host : HostSt → HostSt → Prop)
    (live framed : Nat → Prop) (before after : List Val) (old old' : List Event) (s₀ s : Host.Ts.St LSt)
    (h : StateR (NumberRoles ν₀ ν C₀ C) (VectorHost.NativeRelation ν₀ ν C₀ C roles boundary objects H N tail host)
      R live framed before after old old' s₀ s)
    (inventory : RetainedInventory notes ν₀ ν C₀ C R live s₀ s)
    (fn types out vec x y axis stream : Nat) (axisValue : F64) (axisInt : Int) (returns : Name)
    (fo signature₀ : Host.Ts.Obj) (receiver : Val) (xn yn : Node) (output : Shape)
    (control : s₀.ctl = .call (.obj fn) receiver [.ptr (.js out) 0,.big (Int.ofNat vec),.num (.lit axisValue),.big (Int.ofNat stream)])
    (read : s₀.heap.get fn = some (.obj fo))
    (kind : fo.kind = .fn (.native (.ffi .symbol) [.str symbol,.obj types,.str returns]))
    (signatureRead : s₀.heap.get types = some (.obj signature₀)) (signatureKind : signature₀.kind = .array signature)
    (signatureFrame : ¬ framed types) (vectorLive : H vec)
    (sourceVector : s₀.ffi.mlx.obj? vec = some (.vec [x,y]))
    (sourceX : s₀.ffi.mlx.nodes.get x = some xn) (sourceY : s₀.ffi.mlx.nodes.get y = some yn)
    (axisFixed : F64.un .int32 axisValue = axisValue) (axisDecode : F64.toInt? axisValue = some axisInt)
    (normalize : axisOf axisInt (len (roles x).shape) = some axis)
    (sourceGeometry : ConcatGeometry ν₀ (roles x).shape (roles y).shape output axis)
    (targetGeometry : ConcatGeometry ν (roles x).shape (roles y).shape output axis)
    (roots : Nat → Prop) (policy : ProducerAnnotations roots H N roles objects)
    (sourceNodes : s₀.ffi.mlx.nnext < 2^64) (targetNodes : s.ffi.mlx.nnext < 2^64)
    (sourceHandles : s₀.ffi.mlx.next < 2^64) (targetHandles : s.ffi.mlx.next < 2^64)
    (sourceHeap : out < 2^64) (targetHeap : s.next < 2^64)
    (fnRole thisRole : Value)
    (note : notes.runtime.control = callNote fnRole thisRole ((arguments out vec stream axisValue).map FixedArgument.role))
    (selected : notes.buffers.owners out = some (handleSlotNotes 0)) :
    let newRoles := nodeWrite roles s₀.ffi.mlx.nnext (concatRole roles x y axis output)
    let newObjects := objectWrite objects s₀.ffi.mlx.next .stream
    let newHandles := fun a => a = s₀.ffi.mlx.next ∨ H a
    let newNodes := fun i => i = s₀.ffi.mlx.nnext ∨ N i
    ∃ sourcePost targetPost, interpC (step Host.Load.ffi s₀).run C₀ = some (sourcePost,C₀) ∧
      interpC (step Host.Load.ffi s).run C = some (targetPost,C) ∧
      StateR (NumberRoles ν₀ ν C₀ C) (VectorHost.NativeRelation ν₀ ν C₀ C newRoles boundary newObjects newHandles newNodes tail host)
        R live framed before after old old' sourcePost targetPost ∧
      RetainedInventory (notes.nativeHandleResult out s₀.ffi.mlx.next) ν₀ ν C₀ C R live sourcePost targetPost ∧
      ProducerAnnotations roots newHandles newNodes newRoles newObjects ∧
      ProducerSupport roots newHandles newNodes sourcePost.ffi.mlx := by
  dsimp only
  obtain ⟨outObject,targetObject,bytes,targetBytes,outputRead,outputKind,targetRead,targetKind,sourceRoles,targetRoles⟩ :=
    inventory.buffers.selected out (handleSlotNotes 0) selected
  have exactSource := cellPartNotes_handle_exact .u64 0 8 0 bytes sourceRoles
  change bytes = cellParts .u64 (.big (Int.ofNat 0)) 8 0 at exactSource
  rw [exactSource] at outputKind
  have exactTarget := cellPartNotes_handle_exact .u64 0 8 0 targetBytes targetRoles
  rw [h.native.2.handleZero] at exactTarget
  have outputRole : (fixedBufferRole VectorGetHost.nullRole).Holds ν C R (objectKindAt s (R.a out)) := by
    simpa only [objectKindAt,Host.Ts.St.obj?,targetRead,targetKind,exactTarget,VectorGetHost.null_bytes] using
      fixedBuffer_holds ν C R VectorGetHost.nullRole
  have argumentRoles := (inventory.runtime.native_arguments fnRole thisRole (arguments out vec stream axisValue)
    (.obj fn) receiver _ control note).2
  have supported := (policy.source h.native.2).vector vec [x,y] vectorLive sourceVector
  obtain ⟨shape,t,sourceRun,targetRun,post,slotRole,next,stack,outside,_,sourceFrame,targetFrame,targetControl⟩ :=
    from_source_framed ν₀ ν C₀ C R roles boundary objects H N tail host live framed before after old old' s₀ s h
      fn types out vec x y axis stream axisValue axisInt returns fo signature₀ outObject receiver xn yn output
      control read kind signatureRead signatureKind outputRead outputKind signatureFrame vectorLive supported
      sourceVector sourceX sourceY axisFixed axisDecode normalize sourceGeometry targetGeometry argumentRoles outputRole
      sourceNodes targetNodes sourceHandles targetHandles sourceHeap targetHeap
  let native₀ := resultWorld s₀.ffi x y axis shape xn.dtype yn.dtype
  let beforeBytes := cellParts .u64 (.big (Int.ofNat 0)) 8 0
  let afterBytes := cellParts .u64 (.big (Int.ofNat s₀.ffi.mlx.next)) 8 0
  let sourcePost := finishBuffer s₀ native₀ out 0 outObject beforeBytes afterBytes symbol (callArgs out vec stream axisValue beforeBytes)
  have patch : beforeBytes.take 0 ++ afterBytes ++ beforeBytes.drop (0+len afterBytes) = afterBytes := rfl
  have sourceSlot : (slotKindRole s₀.ffi.mlx.next).Holds ν₀ C₀ identity (objectKindAt sourcePost out) := by
    simp only [sourcePost,objectKindAt,finishBuffer,Host.Ts.St.ret,Host.Ts.St.setTrace,Host.Ts.St.setFfi,
      Host.Ts.St.setObj,Host.Ts.St.obj?,PTrie.get_set_u64 _ _ _ sourceHeap,ite_true,patch]
    exact slot_role ν₀ C₀ identity s₀.ffi.mlx.next
  have sourceOutside : ∀ a, a ≠ out → sourcePost.heap.get a = s₀.heap.get a := by
    intro a different
    change (s₀.heap.set out _).get a = s₀.heap.get a
    rw [PTrie.get_set_u64 _ _ _ sourceHeap,ite_eq_right different]
  have retained := inventory.native_handle_result h.heap out s₀.ffi.mlx.next (handleSlotNotes 0) selected
    sourceFrame targetFrame sourceSlot slotRole sourceOutside outside rfl targetControl
  have absent : sourcePost.ffi.mlx.objs.get s₀.ffi.mlx.next = none := by
    change s₀.ffi.mlx.objs.get s₀.ffi.mlx.next = none
    exact h.native.2.source_fresh_obj (Nat.le_refl _)
  have nativePost := post.native.2.reannotate_absent_object s₀.ffi.mlx.next .stream absent
  have nativePair : VectorHost.NativeRelation ν₀ ν C₀ C
      (nodeWrite roles s₀.ffi.mlx.nnext (concatRole roles x y axis output)) boundary
      (objectWrite objects s₀.ffi.mlx.next .stream) (fun a => a = s₀.ffi.mlx.next ∨ H a)
      (fun i => i = s₀.ffi.mlx.nnext ∨ N i) tail host R sourcePost.ffi t.ffi := ⟨post.native.1,nativePost⟩
  have newPost := post.setFfi sourcePost.ffi t.ffi nativePair
  have nodePolicy := policy.write_node s₀.ffi.mlx.nnext (concatRole roles x y axis output) (.concat axis) [x,y] rfl supported
  have newPolicy := nodePolicy.new_object s₀.ffi.mlx.next .stream True.intro
  exact ⟨sourcePost,t,sourceRun,targetRun,newPost,retained,newPolicy,newPolicy.source nativePost⟩

end Host.Load.Run.Full.Ordinary.ConcatFamilyHost
