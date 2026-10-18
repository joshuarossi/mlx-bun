import host.mlx.NativeRmsHost
import host.mlx.NativeClosedArguments
import host.mlx.NativeBufferResultFrame
import host.mlx.NativeAbsentObjectRoles

set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 1000000
namespace Host.Load.Run.Full.Ordinary.RmsHost
open Host.Ts Host.Ts.Owned Host.Ts.Owned.Parametric Host.Ts.Owned.Annotated
open Host.Mlx.Ffi Host.Mlx.Ffi.NativeRoles Host.Mlx.Ffi.Annotated

/-- The actual f32 epsilon decoder and current producer geometry determine
the original RMS operation, fresh handle write and all retained resources. -/
theorem retained_from_source {notes : RetainedNotes}
    (ν₀ ν : Nat → F64) (C₀ C : CSrv) (R : Ren)
    (roles : Nat → GraphNode) (boundary : Nat → Prop) (objects : Nat → Object)
    (roots H N : Nat → Prop) (tail : List NumV) (host : HostSt → HostSt → Prop)
    (live framed : Nat → Prop) (before after : List Val) (old old' : List Event) (s₀ s : Host.Ts.St LSt)
    (h : Parametric.StateR (NumberRoles ν₀ ν C₀ C) (VectorHost.NativeRelation ν₀ ν C₀ C roles boundary objects H N tail host)
      R live framed before after old old' s₀ s)
    (inventory : RetainedInventory notes ν₀ ν C₀ C R live s₀ s)
    (policy : ProducerAnnotations roots H N roles objects)
    (fn types out hx hw x w stream : Nat) (epsilon : F64)
    (function signatureObject : Host.Ts.Obj) (returns : Name) (receiver : Val) (xn wn : Node)
    (control : s₀.ctl = .call (.obj fn) receiver [.ptr (.js out) 0,.big (Int.ofNat hx),.big (Int.ofNat hw),.num (.lit epsilon),.big (Int.ofNat stream)])
    (functionRead : s₀.heap.get fn = some (.obj function))
    (functionKind : function.kind = .fn (.native (.ffi .symbol) [.str symbol,.obj types,.str returns]))
    (signatureRead : s₀.heap.get types = some (.obj signatureObject)) (signatureKind : signatureObject.kind = .array signature)
    (signatureFrame : ¬ framed types) (handlesLive : listSupport H [hx,hw]) (weightNonzero : hw ≠ 0)
    (producers : nodesOf s₀.ffi.mlx [hx,hw] = some [x,w])
    (sourceX : s₀.ffi.mlx.nodes.get x = some xn) (sourceW : s₀.ffi.mlx.nodes.get w = some wn)
    (geometry : RmsGeometry (roles x).shape (roles w).shape)
    (float : isFloat (promote (roles x).dtype (roles w).dtype) = true)
    (sourceNodes : s₀.ffi.mlx.nnext < 2^64) (targetNodes : s.ffi.mlx.nnext < 2^64)
    (sourceHandles : s₀.ffi.mlx.next < 2^64) (targetHandles : s.ffi.mlx.next < 2^64)
    (sourceHeap : out < 2^64) (targetHeap : s.next < 2^64)
    (fnRole thisRole epsilonNote : Annotated.Value) (epsilonSchema : ClosedLiteralNote epsilonNote)
    (controlNote : notes.runtime.control = callNote fnRole thisRole
      [.ptr (.js out) 0,.handle hx,.handle hw,epsilonNote,.handle stream])
    (slotNote : notes.buffers.owners out = some (handleSlotNotes 0)) :
    let newRoles := nodeWrite roles s₀.ffi.mlx.nnext (rmsRole roles x w (epsilonRole epsilon))
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
  have sourceCurrent := inventory.runtime.source.control
  rw [controlNote,control] at sourceCurrent
  have targetCurrent := inventory.runtime.target.control
  rw [controlNote,targetControl] at targetCurrent
  have argumentRoles : ListR (fun role value => role.role.Holds ν C R value)
      (arguments out hx hw stream epsilon) (callArguments s.ctl) := by
    simp only [targetControl,callArguments]
    have src := (callNote_view sourceCurrent).2.2
    have dst := (callNote_view targetCurrent).2.2
    cases src with | cons _ src =>
      cases src with | cons _ src =>
        cases src with | cons _ src =>
          cases src with | cons se src =>
            cases src with | cons _ src =>
              cases src
              cases dst with | cons a dst =>
                cases dst with | cons b dst =>
                  cases dst with | cons c dst =>
                    cases dst with | cons e dst =>
                      cases dst with | cons d dst =>
                        cases dst
                        exact .cons a (.cons b (.cons c (.cons (epsilonSchema.exact se e) (.cons d .nil))))
  obtain ⟨t,sourceRun,targetRun,post,slotRole,sourceFrame,targetFrame,outside,targetReturn⟩ :=
    from_source ν₀ ν C₀ C R roles boundary objects H N tail host live framed before after old old' s₀ s h
      fn types out hx hw x w stream epsilon returns function signatureObject outObject receiver xn wn
      control functionRead functionKind signatureRead signatureKind outputRead outputKind signatureFrame handlesLive weightNonzero
      producers sourceX sourceW geometry float argumentRoles outputRole sourceNodes targetNodes sourceHandles targetHandles sourceHeap targetHeap
  let sourcePost := finishBuffer s₀ (resultWorld s₀.ffi x w epsilon xn wn) out 0 outObject
    (cellParts .u64 (.big (Int.ofNat 0)) 8 0) (cellParts .u64 (.big (Int.ofNat s₀.ffi.mlx.next)) 8 0)
    symbol (callArgs out hx hw stream epsilon (cellParts .u64 (.big (Int.ofNat 0)) 8 0))
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
      (nodeWrite roles s₀.ffi.mlx.nnext (rmsRole roles x w (epsilonRole epsilon))) boundary
      (objectWrite objects s₀.ffi.mlx.next .stream) (fun a => a = s₀.ffi.mlx.next ∨ H a)
      (fun i => i = s₀.ffi.mlx.nnext ∨ N i) tail host R sourcePost.ffi t.ffi := ⟨post.native.1,nativePost⟩
  have newPost := post.setFfi sourcePost.ffi t.ffi nativePair
  have supported := h.native.2.nodesOf_support [hx,hw] [x,w] handlesLive producers
  have nodePolicy := policy.write_node s₀.ffi.mlx.nnext (rmsRole roles x w (epsilonRole epsilon))
    (.rmsNorm (epsilonRole epsilon)) [x,w] rfl supported
  have newPolicy := nodePolicy.new_object s₀.ffi.mlx.next .stream True.intro
  exact ⟨sourcePost,t,sourceRun,targetRun,newPost,retained,newPolicy,newPolicy.source nativePost⟩

end Host.Load.Run.Full.Ordinary.RmsHost
