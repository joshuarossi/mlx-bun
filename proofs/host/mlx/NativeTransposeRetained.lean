import host.mlx.NativeTransposeFrame
import host.mlx.NativeSliceDynamicRetained

set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0

namespace Host.Load.Run.Full.Ordinary.TransposeHost
open Host.Ts Host.Ts.Owned Host.Ts.Owned.Parametric Host.Ts.Owned.Annotated
open Host.Mlx.Ffi Host.Mlx.Ffi.NativeRoles Host.Mlx.Ffi.Annotated

def argumentNotes (out handle axisBuffer stream : Nat) (count : Value) : List Value :=
  [.ptr (.js out) 0,.handle handle,.ptr (.js axisBuffer) 0,count,.handle stream]

private theorem arguments_fixed {ν : Nat → F64} {C : CSrv} {R : Ren}
    (out handle axisBuffer count stream : Nat) (countNote : Value)
    (schema : FixedIntegerRole countNote (Int.ofNat count)) (values : List Val)
    (held : ListR (fun role value => role.Holds ν C R value) (argumentNotes out handle axisBuffer stream countNote) values) :
    ListR (fun role value => role.role.Holds ν C R value) (arguments out handle axisBuffer count stream) values := by
  cases held with | cons a h =>
    cases h with | cons b h =>
      cases h with | cons c h =>
        cases h with | cons d h =>
          cases h with | cons e h =>
            cases h
            exact .cons a (.cons b (.cons c (.cons (schema.holds d) (.cons e .nil))))

/-- Current axis bytes determine the permutation. Only the source rank is
needed; variable dimension expressions remain in the indexed output role. -/
theorem retained_from_source {notes : RetainedNotes}
    (ν₀ ν : Nat → F64) (C₀ C : CSrv) (R : Ren)
    (roles : Nat → GraphNode) (boundary : Nat → Prop) (objects : Nat → Object)
    (H N : Nat → Prop) (tail : List NumV) (host : HostSt → HostSt → Prop)
    (live framed : Nat → Prop) (before after : List Val) (old old' : List Event) (s₀ s : Host.Ts.St LSt)
    (h : StateR (NumberRoles ν₀ ν C₀ C) (VectorHost.NativeRelation ν₀ ν C₀ C roles boundary objects H N tail host)
      R live framed before after old old' s₀ s)
    (inventory : RetainedInventory notes ν₀ ν C₀ C R live s₀ s)
    (fn types out handle input axisBuffer stream : Nat) (function signatureObject : Host.Ts.Obj) (returns : Name) (receiver : Val)
    (axisIntegers : List Int) (axes : List Nat) (node : Node)
    (control : s₀.ctl = .call (.obj fn) receiver [.ptr (.js out) 0,.big (Int.ofNat handle),.ptr (.js axisBuffer) 0,
      .big (Int.ofNat axisIntegers.length),.big (Int.ofNat stream)])
    (read : s₀.heap.get fn = some (.obj function))
    (functionKind : function.kind = .fn (.native (.ffi .symbol) [.str symbol,.obj types,.str returns]))
    (signatureRead : s₀.heap.get types = some (.obj signatureObject)) (signatureKind : signatureObject.kind = .array signature)
    (signatureFrame : ¬ framed types) (handleLive : H handle)
    (producer : nodesOf s₀.ffi.mlx [handle] = some [input]) (sourceNode : s₀.ffi.mlx.nodes.get input = some node)
    (sourceAxes : (dimsArg (.jsPtr axisBuffer 0 (shapeBytes (axisIntegers.map Dim.lit)))
      (.big (Int.ofNat axisIntegers.length))).bind natsOfDims = some axes)
    (axisExact : ExactDimensions axisIntegers)
    (guard : (Nat.beq (len axes) node.shape.length &&
      (List.range node.shape.length).all (fun a => axes.any (Nat.beq a))) = true)
    (sourceNodes : s₀.ffi.mlx.nnext < 2^64) (targetNodes : s.ffi.mlx.nnext < 2^64)
    (sourceHandles : s₀.ffi.mlx.next < 2^64) (targetHandles : s.ffi.mlx.next < 2^64)
    (sourceHeap : out < 2^64) (targetHeap : s.next < 2^64)
    (roots : Nat → Prop) (policy : ProducerAnnotations roots H N roles objects)
    (fnRole thisRole countRole : Value) (countSchema : FixedIntegerRole countRole (Int.ofNat axisIntegers.length))
    (note : notes.runtime.control = callNote fnRole thisRole (argumentNotes out handle axisBuffer stream countRole))
    (selected : notes.buffers.owners out = some (handleSlotNotes 0))
    (selectedAxes : notes.buffers.owners axisBuffer = some (literalShapeByteNotes (constantExpressions axisIntegers))) :
    let newRoles := nodeWrite roles s₀.ffi.mlx.nnext (transposeRole roles input axes)
    let newObjects := objectWrite objects s₀.ffi.mlx.next .stream
    let newH := fun a => a = s₀.ffi.mlx.next ∨ H a
    let newN := fun i => i = s₀.ffi.mlx.nnext ∨ N i
    ∃ sourcePost targetPost, interpC (step Host.Load.ffi s₀).run C₀ = some (sourcePost,C₀) ∧
      interpC (step Host.Load.ffi s).run C = some (targetPost,C) ∧
      StateR (NumberRoles ν₀ ν C₀ C) (VectorHost.NativeRelation ν₀ ν C₀ C newRoles boundary newObjects newH newN tail host)
        R live framed before after old old' sourcePost targetPost ∧
      RetainedInventory (notes.nativeHandleResult out s₀.ffi.mlx.next) ν₀ ν C₀ C R live sourcePost targetPost ∧
      ProducerAnnotations roots newH newN newRoles newObjects ∧ ProducerSupport roots newH newN sourcePost.ffi.mlx ∧
      ProducerSupport (resourceImage R.node (fun i => newN i ∧ roots i))
        (resourceImage R.handle newH) (resourceImage R.node newN) targetPost.ffi.mlx := by
  dsimp only
  have av₀ : LiteralDimensions ν₀ ((constantExpressions axisIntegers).map Dimension.literal) axisIntegers := by
    rw [constantExpressions_shape]; exact .constants ν₀ axisIntegers axisExact
  have av : LiteralDimensions ν ((constantExpressions axisIntegers).map Dimension.literal) axisIntegers := by
    rw [constantExpressions_shape]; exact .constants ν axisIntegers axisExact
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
  obtain ⟨axisObject,targetAxisObject,axisBytes,targetAxisBytes,axisRead,axisKind,targetAxisRead,targetAxisKind,axisRoles,targetAxisRoles⟩ :=
    inventory.buffers.selected axisBuffer _ selectedAxes
  have axisBytesEq := literal_shape_bytes_exact _ _ _ av₀ axisRoles
  have targetAxisEq := literal_shape_bytes_exact _ _ _ av targetAxisRoles
  have axisKindFixed : axisObject.kind = .buf ((fixedI32 axisIntegers).map FixedByte.value) := by
    rw [fixedI32_value]; exact axisKind.trans (congrArg Kind.buf axisBytesEq)
  have targetAxisFixed : (fixedBufferRole (fixedI32 axisIntegers)).Holds ν C R (objectKindAt s (R.a axisBuffer)) := by
    simpa only [objectKindAt,Host.Ts.St.obj?,targetAxisRead,targetAxisKind,targetAxisEq,fixedI32_value] using
      fixedBuffer_holds ν C R (fixedI32 axisIntegers)
  have supported := h.native.2.nodesOf_support [handle] [input] ⟨handleLive,True.intro⟩ producer
  obtain ⟨_,_,inputRole⟩ := h.native.2.node_view supported.1 sourceNode
  have roleGuard : (Nat.beq (len axes) (len (roles input).shape) &&
      (List.range (len (roles input).shape)).all (fun a => axes.any (Nat.beq a))) = true := by
    rw [inputRole.source.shape.len_eq]
    simpa only [len_list_length] using guard
  obtain ⟨_,_,targetThis,targetArgs,targetControl,_,_,_,_,_⟩ := h.native_call_view fn function (.ffi .symbol) _ receiver _ control read functionKind
  have current := inventory.runtime.target.control
  rw [note,targetControl] at current
  have argumentRoles := arguments_fixed out handle axisBuffer axisIntegers.length stream countRole countSchema targetArgs (callNote_view current).2.2
  have argumentRoles' : ListR (fun role value => role.role.Holds ν C R value)
      (arguments out handle axisBuffer axisIntegers.length stream) (callArguments s.ctl) := by
    simpa only [targetControl,callArguments] using argumentRoles
  obtain ⟨t,left,right,post,slotRole,sourceFrame,targetFrame,outside,targetReturn⟩ :=
    from_source_framed ν₀ ν C₀ C R roles boundary objects H N tail host live framed before after old old' s₀ s h
      fn types out handle input axisBuffer axisIntegers.length stream function signatureObject outObject axisObject returns receiver
      (fixedI32 axisIntegers) axes node control read functionKind signatureRead signatureKind outputRead outputKind axisRead axisKindFixed
      signatureFrame handleLive producer sourceNode (by simpa only [fixedI32_value] using sourceAxes) roleGuard argumentRoles' outputRole targetAxisFixed
      sourceNodes targetNodes sourceHandles targetHandles sourceHeap targetHeap
  let sourcePost := finishBuffer s₀ (resultWorld s₀.ffi input axes node) out 0 outObject
    (cellParts .u64 (.big (Int.ofNat 0)) 8 0) (cellParts .u64 (.big (Int.ofNat s₀.ffi.mlx.next)) 8 0)
    symbol (callArgs out handle axisBuffer axisIntegers.length stream (cellParts .u64 (.big (Int.ofNat 0)) 8 0)
      ((fixedI32 axisIntegers).map FixedByte.value))
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
  have nativePair : VectorHost.NativeRelation ν₀ ν C₀ C
      (nodeWrite roles s₀.ffi.mlx.nnext (transposeRole roles input axes)) boundary
      (objectWrite objects s₀.ffi.mlx.next .stream) (fun a => a = s₀.ffi.mlx.next ∨ H a)
      (fun i => i = s₀.ffi.mlx.nnext ∨ N i) tail host R sourcePost.ffi t.ffi := ⟨post.native.1,nativePost⟩
  have newPost := post.setFfi sourcePost.ffi t.ffi nativePair
  have nodePolicy := policy.write_node s₀.ffi.mlx.nnext (transposeRole roles input axes) (.transpose axes) [input] rfl supported
  have newPolicy := nodePolicy.new_object s₀.ffi.mlx.next .stream True.intro
  exact ⟨sourcePost,t,left,right,newPost,retained,newPolicy,newPolicy.source nativePost,newPolicy.target nativePost⟩

end Host.Load.Run.Full.Ordinary.TransposeHost
