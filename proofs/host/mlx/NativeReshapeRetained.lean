import host.mlx.NativeReshapeHost
import host.mlx.NativeShapeBufferInventory
import host.mlx.NativeBufferResultFrame
import host.mlx.NativeAbsentObjectRoles
import host.mlx.NativeBufferVectorInventory

set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 1000000
namespace Host.Load.Run.Full.Ordinary.ReshapeHost
open Host.Ts Host.Ts.Owned Host.Ts.Owned.Parametric Host.Ts.Owned.Annotated
open Host.Mlx.Ffi Host.Mlx.Ffi.NativeRoles Host.Mlx.Ffi.Annotated

/-- Exact current shape-byte notes and pure integer product guards determine
both original reshape calls. The post-slot and all six inventory families
follow from execution; no target buffer or native-call premise is needed. -/
theorem retained_from_source {notes : RetainedNotes}
    (ν₀ ν : Nat → F64) (C₀ C : CSrv) (R : Ren)
    (roles : Nat → GraphNode) (boundary : Nat → Prop) (objects : Nat → Object)
    (roots H N : Nat → Prop) (tail : List NumV) (host : HostSt → HostSt → Prop)
    (live framed : Nat → Prop) (before after : List Val) (old old' : List Event) (s₀ s : Host.Ts.St LSt)
    (h : Parametric.StateR (NumberRoles ν₀ ν C₀ C) (VectorHost.NativeRelation ν₀ ν C₀ C roles boundary objects H N tail host)
      R live framed before after old old' s₀ s)
    (inventory : RetainedInventory notes ν₀ ν C₀ C R live s₀ s)
    (policy : ProducerAnnotations roots H N roles objects)
    (fn types out handle input shapeBuffer stream : Nat) (function signatureObject : Host.Ts.Obj)
    (returns : Name) (receiver : Val) (expressions : List SymE) (node : Node)
    (control : s₀.ctl = .call (.obj fn) receiver [.ptr (.js out) 0,.big (Int.ofNat handle),.ptr (.js shapeBuffer) 0,
      .big (Int.ofNat expressions.length),.big (Int.ofNat stream)])
    (functionRead : s₀.heap.get fn = some (.obj function))
    (functionKind : function.kind = .fn (.native (.ffi .symbol) [.str symbol,.obj types,.str returns]))
    (signatureRead : s₀.heap.get types = some (.obj signatureObject)) (signatureKind : signatureObject.kind = .array signature)
    (signatureFrame : ¬ framed types) (handleLive : H handle)
    (producer : nodesOf s₀.ffi.mlx [handle] = some [input]) (sourceNode : s₀.ffi.mlx.nodes.get input = some node)
    (sourceIntegers targetIntegers : List Int)
    (sourceValues : LiteralDimensions ν₀ (expressions.map Dimension.literal) sourceIntegers)
    (targetValues : LiteralDimensions ν (expressions.map Dimension.literal) targetIntegers)
    (sourceGeometry : ReshapeGeometry ν₀ (roles input).shape (expressions.map Dimension.literal))
    (targetGeometry : ReshapeGeometry ν (roles input).shape (expressions.map Dimension.literal))
    (sourceNodes : s₀.ffi.mlx.nnext < 2^64) (targetNodes : s.ffi.mlx.nnext < 2^64)
    (sourceHandles : s₀.ffi.mlx.next < 2^64) (targetHandles : s.ffi.mlx.next < 2^64)
    (sourceHeap : out < 2^64) (targetHeap : s.next < 2^64)
    (fnRole thisRole countRole : Annotated.Value) (countSchema : FixedIntegerRole countRole (Int.ofNat expressions.length))
    (controlNote : notes.runtime.control = callNote fnRole thisRole
      [.ptr (.js out) 0,.handle handle,.ptr (.js shapeBuffer) 0,countRole,.handle stream])
    (slotNote : notes.buffers.owners out = some (handleSlotNotes 0))
    (shapeNote : notes.buffers.owners shapeBuffer = some (literalShapeByteNotes expressions)) :
    let newRoles := nodeWrite roles s₀.ffi.mlx.nnext (reshapeRole roles input (expressions.map Dimension.literal))
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
  obtain ⟨shapeObject,_,shapeBytes,_,shapeRead,shapeKind,_,_,shapeRoles,_⟩ :=
    inventory.buffers.selected shapeBuffer _ shapeNote
  have sourceShape : ShapeBuffer.Holds (expressions.map Dimension.literal) ν₀ C₀ shapeBytes :=
    ⟨sourceIntegers.map Dim.lit,sourceValues.holds C₀,literal_shape_bytes_exact expressions sourceIntegers shapeBytes sourceValues shapeRoles⟩
  have targetShape := (inventory.buffers.target shapeBuffer _ shapeNote).literal_shape expressions targetIntegers targetValues
  obtain ⟨_,_,targetThis,targetArgs,targetControl,_,_,_,_,_⟩ :=
    h.native_call_view fn function (.ffi .symbol) _ receiver _ control functionRead functionKind
  have current := inventory.runtime.target.control
  rw [controlNote,targetControl] at current
  have argumentRoles : ListR (fun role value => role.role.Holds ν C R value)
      (arguments out handle shapeBuffer expressions.length stream) (callArguments s.ctl) := by
    simp only [targetControl,callArguments]
    have held := (callNote_view current).2.2
    cases held with | cons a held =>
      cases held with | cons b held =>
        cases held with | cons c held =>
          cases held with | cons d held =>
            cases held with | cons e held =>
              cases held
              exact .cons a (.cons b (.cons c (.cons (countSchema.holds d) (.cons e .nil))))
  have control' : s₀.ctl = .call (.obj fn) receiver [.ptr (.js out) 0,.big (Int.ofNat handle),.ptr (.js shapeBuffer) 0,
      .big (Int.ofNat (expressions.map Dimension.literal).length),.big (Int.ofNat stream)] := by
    simpa only [List.length_map] using control
  obtain ⟨shape,t,sourceRun,targetRun,post,slotRole,sourceFrame,targetFrame,outside,targetReturn⟩ :=
    from_source ν₀ ν C₀ C R roles boundary objects H N tail host live framed before after old old' s₀ s h
      fn types out handle input shapeBuffer stream function signatureObject outObject shapeObject returns receiver shapeBytes
      (expressions.map Dimension.literal) node control' functionRead functionKind signatureRead signatureKind outputRead outputKind
      shapeRead shapeKind signatureFrame handleLive producer sourceNode sourceShape (literal_shape_decodable expressions)
      sourceGeometry targetGeometry (by simpa only [List.length_map] using argumentRoles) outputRole targetShape
      sourceNodes targetNodes sourceHandles targetHandles sourceHeap targetHeap
  let sourcePost := finishBuffer s₀ (resultWorld s₀.ffi input shape node.dtype) out 0 outObject
    (cellParts .u64 (.big (Int.ofNat 0)) 8 0) (cellParts .u64 (.big (Int.ofNat s₀.ffi.mlx.next)) 8 0)
    symbol (callArgs out handle shapeBuffer (expressions.map Dimension.literal).length stream
      (cellParts .u64 (.big (Int.ofNat 0)) 8 0) shapeBytes)
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
      (nodeWrite roles s₀.ffi.mlx.nnext (reshapeRole roles input (expressions.map Dimension.literal))) boundary
      (objectWrite objects s₀.ffi.mlx.next .stream) (fun a => a = s₀.ffi.mlx.next ∨ H a)
      (fun i => i = s₀.ffi.mlx.nnext ∨ N i) tail host R sourcePost.ffi t.ffi := ⟨post.native.1,nativePost⟩
  have newPost := post.setFfi sourcePost.ffi t.ffi nativePair
  have supported := h.native.2.nodesOf_support [handle] [input] ⟨handleLive,True.intro⟩ producer
  have nodePolicy := policy.write_node s₀.ffi.mlx.nnext (reshapeRole roles input (expressions.map Dimension.literal))
    (.reshape (expressions.map Dimension.literal)) [input] rfl supported
  have newPolicy := nodePolicy.new_object s₀.ffi.mlx.next .stream True.intro
  exact ⟨sourcePost,t,sourceRun,targetRun,newPost,retained,newPolicy,newPolicy.source nativePost⟩

end Host.Load.Run.Full.Ordinary.ReshapeHost
