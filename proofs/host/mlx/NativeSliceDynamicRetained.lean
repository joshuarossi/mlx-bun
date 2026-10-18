import host.mlx.NativeSliceDynamicFrame
import host.ts.RenameParametricTypedElements
import host.mlx.NativeFixedSliceGeometry
import host.mlx.NativeShapeBufferInventory
import host.mlx.NativeBufferResultFrame
import host.mlx.NativeAbsentObjectRoles
import host.mlx.NativeBufferVectorInventory

set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0

namespace Host.Ts.Owned.Annotated
open Host.Mlx.Ffi Host.Mlx.Ffi.Annotated

theorem fixedI32_value (integers : List Int) :
    (fixedI32 integers).map FixedByte.value = shapeBytes (integers.map Dim.lit) := by
  induction integers with
  | nil => rfl
  | cons i rest ih =>
    simp only [fixedI32,List.flatMap_cons,List.map_append,fixedI32Parts_value,List.map_cons]
    exact congrArg (_ ++ ·) ih

end Host.Ts.Owned.Annotated

namespace Host.Load.Run.Full.Ordinary.SliceDynamicHost
open Host.Ts Host.Ts.Owned Host.Ts.Owned.Parametric Host.Ts.Owned.Annotated
open Host.Mlx.Ffi Host.Mlx.Ffi.NativeRoles Host.Mlx.Ffi.Annotated

def dynamicArgumentNotes (out handle start axisBuffer sizeBuffer stream : Nat)
    (axisCount sizeCount : Value) : List Value :=
  [.ptr (.js out) 0,.handle handle,.handle start,.ptr (.js axisBuffer) 0,axisCount,
    .ptr (.js sizeBuffer) 0,sizeCount,.handle stream]

private theorem dynamic_arguments_fixed {ν : Nat → F64} {C : CSrv} {R : Ren}
    (out handle start axisBuffer axisCount sizeBuffer sizeCount stream : Nat) (axisNote sizeNote : Value)
    (axisSchema : FixedIntegerRole axisNote (Int.ofNat axisCount))
    (sizeSchema : FixedIntegerRole sizeNote (Int.ofNat sizeCount)) (values : List Val)
    (held : ListR (fun role value => role.Holds ν C R value)
      (dynamicArgumentNotes out handle start axisBuffer sizeBuffer stream axisNote sizeNote) values) :
    ListR (fun role value => role.role.Holds ν C R value)
      (arguments out handle start axisBuffer axisCount sizeBuffer sizeCount stream) values := by
  cases held with | cons a h =>
    cases h with | cons b h =>
      cases h with | cons c h =>
        cases h with | cons d h =>
          cases h with | cons e h =>
            cases h with | cons f h =>
              cases h with | cons g h =>
                cases h with | cons i h =>
                  cases h
                  exact .cons a (.cons b (.cons c (.cons d (.cons (axisSchema.holds e)
                    (.cons f (.cons (sizeSchema.holds g) (.cons i .nil)))))))

/-- Current exact size-buffer notes determine both original dynamic-slice
calls. Input/start metadata guards follow the indexed producer relation;
all retained notes and producer/object support survive the output write. -/
theorem retained_from_source {notes : RetainedNotes}
    (ν₀ ν : Nat → F64) (C₀ C : CSrv) (R : Ren)
    (roles : Nat → GraphNode) (boundary : Nat → Prop) (objects : Nat → Object)
    (H N : Nat → Prop) (tail : List NumV) (host : HostSt → HostSt → Prop)
    (live framed : Nat → Prop) (before after : List Val) (old old' : List Event) (s₀ s : Host.Ts.St LSt)
    (h : StateR (NumberRoles ν₀ ν C₀ C) (VectorHost.NativeRelation ν₀ ν C₀ C roles boundary objects H N tail host)
      R live framed before after old old' s₀ s)
    (inventory : RetainedInventory notes ν₀ ν C₀ C R live s₀ s)
    (fn types out handle start input startInput axisBuffer sizeBuffer stream : Nat)
    (function signatureObject : Host.Ts.Obj) (returns : Name) (receiver : Val)
    (axisIntegers sizes : List Int) (axes : List Nat) (node startNode : Node)
    (control : s₀.ctl = .call (.obj fn) receiver [.ptr (.js out) 0,.big (Int.ofNat handle),.big (Int.ofNat start),
      .ptr (.js axisBuffer) 0,.big (Int.ofNat axisIntegers.length),.ptr (.js sizeBuffer) 0,
      .big (Int.ofNat sizes.length),.big (Int.ofNat stream)])
    (read : s₀.heap.get fn = some (.obj function))
    (functionKind : function.kind = .fn (.native (.ffi .symbol) [.str symbol,.obj types,.str returns]))
    (signatureRead : s₀.heap.get types = some (.obj signatureObject)) (signatureKind : signatureObject.kind = .array signature)
    (signatureFrame : ¬ framed types) (handleLive : H handle) (startLive : H start)
    (producers : nodesOf s₀.ffi.mlx [handle,start] = some [input,startInput])
    (sourceNode : s₀.ffi.mlx.nodes.get input = some node) (sourceStart : s₀.ffi.mlx.nodes.get startInput = some startNode)
    (sourceAxes : (dimsArg (.jsPtr axisBuffer 0 (shapeBytes (axisIntegers.map Dim.lit)))
      (.big (Int.ofNat axisIntegers.length))).bind natsOfDims = some axes)
    (axisExact : ExactDimensions axisIntegers) (sizesExact : ExactDimensions sizes)
    (rank : sizes.length = node.shape.length) (integer : isInteger startNode.dtype = true)
    (startRank : Nat.ble startNode.shape.length 1 = true)
    (bounds : axes.all (Nat.blt · node.shape.length) = true)
    (sourceNodes : s₀.ffi.mlx.nnext < 2^64) (targetNodes : s.ffi.mlx.nnext < 2^64)
    (sourceHandles : s₀.ffi.mlx.next < 2^64) (targetHandles : s.ffi.mlx.next < 2^64)
    (sourceHeap : out < 2^64) (targetHeap : s.next < 2^64)
    (roots : Nat → Prop) (policy : ProducerAnnotations roots H N roles objects)
    (fnRole thisRole axisCount sizeCount : Value)
    (axisSchema : FixedIntegerRole axisCount (Int.ofNat axisIntegers.length))
    (sizeSchema : FixedIntegerRole sizeCount (Int.ofNat sizes.length))
    (note : notes.runtime.control = callNote fnRole thisRole
      (dynamicArgumentNotes out handle start axisBuffer sizeBuffer stream axisCount sizeCount))
    (selected : notes.buffers.owners out = some (handleSlotNotes 0))
    (selectedAxes : notes.buffers.owners axisBuffer = some (literalShapeByteNotes (constantExpressions axisIntegers)))
    (selectedSizes : notes.buffers.owners sizeBuffer = some (literalShapeByteNotes (constantExpressions sizes))) :
    let newRoles := nodeWrite roles s₀.ffi.mlx.nnext (sliceDynamicRole roles input startInput axes (constantShape sizes))
    let newObjects := objectWrite objects s₀.ffi.mlx.next .stream
    let newH := fun a => a = s₀.ffi.mlx.next ∨ H a
    let newN := fun i => i = s₀.ffi.mlx.nnext ∨ N i
    ∃ sourcePost targetPost, interpC (step Host.Load.ffi s₀).run C₀ = some (sourcePost,C₀) ∧
      interpC (step Host.Load.ffi s).run C = some (targetPost,C) ∧
      StateR (NumberRoles ν₀ ν C₀ C) (VectorHost.NativeRelation ν₀ ν C₀ C newRoles boundary newObjects newH newN tail host)
        R live framed before after old old' sourcePost targetPost ∧
      RetainedInventory (notes.nativeHandleResult out s₀.ffi.mlx.next) ν₀ ν C₀ C R live sourcePost targetPost ∧
      ProducerAnnotations roots newH newN newRoles newObjects ∧
      ProducerSupport roots newH newN sourcePost.ffi.mlx := by
  dsimp only
  have av₀ : LiteralDimensions ν₀ ((constantExpressions axisIntegers).map Dimension.literal) axisIntegers := by
    rw [constantExpressions_shape]; exact .constants ν₀ axisIntegers axisExact
  have av : LiteralDimensions ν ((constantExpressions axisIntegers).map Dimension.literal) axisIntegers := by
    rw [constantExpressions_shape]; exact .constants ν axisIntegers axisExact
  have sv₀ : LiteralDimensions ν₀ ((constantExpressions sizes).map Dimension.literal) sizes := by
    rw [constantExpressions_shape]; exact .constants ν₀ sizes sizesExact
  have sv : LiteralDimensions ν ((constantExpressions sizes).map Dimension.literal) sizes := by
    rw [constantExpressions_shape]; exact .constants ν sizes sizesExact
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
  obtain ⟨sizeObject,_,sizeBytes,_,sizeRead,sizeKind,_,_,sizeRoles,_⟩ :=
    inventory.buffers.selected sizeBuffer _ selectedSizes
  have sourceSizes : ShapeBuffer.Holds (constantShape sizes) ν₀ C₀ sizeBytes :=
    ⟨sizes.map Dim.lit,(LiteralDimensions.constants ν₀ sizes sizesExact).holds C₀,literal_shape_bytes_exact _ _ _ sv₀ sizeRoles⟩
  have targetSizes : ShapeBuffer.Holds (constantShape sizes) ν C (ShapeBuffer.bytesAt s (R.a sizeBuffer)) := by
    simpa only [constantExpressions_shape] using (inventory.buffers.target sizeBuffer _ selectedSizes).literal_shape _ _ sv
  have supported := h.native.2.nodesOf_support [handle,start] [input,startInput] ⟨handleLive,startLive,True.intro⟩ producers
  obtain ⟨_,_,inputRole⟩ := h.native.2.node_view supported.1 sourceNode
  obtain ⟨_,_,startRole⟩ := h.native.2.node_view supported.2.1 sourceStart
  have roleRank : len (constantShape sizes) = len (roles input).shape := by
    have lengths := inputRole.source.shape.len_eq
    simp only [len_list_length] at lengths ⊢
    simp only [constantShape,List.length_map]
    exact rank.trans lengths.symm
  have roleInteger : isInteger (roles startInput).dtype = true := by rw [←startRole.source.dtype]; exact integer
  have roleStartRank : Nat.ble (len (roles startInput).shape) 1 = true := by
    rw [startRole.source.shape.len_eq,len_list_length]; exact startRank
  have roleBounds : axes.all (Nat.blt · (len (roles input).shape)) = true := by
    rw [inputRole.source.shape.len_eq,len_list_length]; exact bounds
  obtain ⟨_,_,targetThis,targetArgs,targetControl,_,_,_,_,_⟩ :=
    h.native_call_view fn function (.ffi .symbol) _ receiver _ control read functionKind
  have current := inventory.runtime.target.control
  rw [note,targetControl] at current
  have argumentRoles := dynamic_arguments_fixed out handle start axisBuffer axisIntegers.length sizeBuffer sizes.length
    stream axisCount sizeCount axisSchema sizeSchema targetArgs (callNote_view current).2.2
  have argumentRoles' : ListR (fun role value => role.role.Holds ν C R value)
      (arguments out handle start axisBuffer axisIntegers.length sizeBuffer (constantShape sizes).length stream) (callArguments s.ctl) := by
    simpa only [targetControl,callArguments,constantShape,List.length_map] using argumentRoles
  have control' : s₀.ctl = .call (.obj fn) receiver [.ptr (.js out) 0,.big (Int.ofNat handle),.big (Int.ofNat start),
      .ptr (.js axisBuffer) 0,.big (Int.ofNat axisIntegers.length),.ptr (.js sizeBuffer) 0,
      .big (Int.ofNat (constantShape sizes).length),.big (Int.ofNat stream)] := by
    simpa only [constantShape,List.length_map] using control
  obtain ⟨dimensions,t,sourceRun,targetRun,post,slotRole,sourceFrame,targetFrame,outside,targetReturn⟩ :=
    from_source_framed ν₀ ν C₀ C R roles boundary objects H N tail host live framed before after old old' s₀ s h
      fn types out handle start input startInput axisBuffer axisIntegers.length sizeBuffer stream function signatureObject outObject
      axisObject sizeObject returns receiver (fixedI32 axisIntegers) sizeBytes axes (constantShape sizes) node startNode
      control' read functionKind signatureRead signatureKind outputRead outputKind axisRead axisKindFixed sizeRead sizeKind
      signatureFrame handleLive startLive producers sourceNode sourceStart (by simpa only [fixedI32_value] using sourceAxes)
      sourceSizes (by rw [←constantExpressions_shape]; exact literal_shape_decodable _) roleRank roleInteger roleStartRank roleBounds
      argumentRoles' outputRole targetAxisFixed targetSizes sourceNodes targetNodes sourceHandles targetHandles sourceHeap targetHeap
  let sourcePost := finishBuffer s₀ (resultWorld s₀.ffi input startInput axes dimensions node.dtype) out 0 outObject
    (cellParts .u64 (.big (Int.ofNat 0)) 8 0) (cellParts .u64 (.big (Int.ofNat s₀.ffi.mlx.next)) 8 0)
    symbol (callArgs out handle start axisBuffer axisIntegers.length sizeBuffer (constantShape sizes).length stream
      (cellParts .u64 (.big (Int.ofNat 0)) 8 0) ((fixedI32 axisIntegers).map FixedByte.value) sizeBytes)
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
      (nodeWrite roles s₀.ffi.mlx.nnext (sliceDynamicRole roles input startInput axes (constantShape sizes))) boundary
      (objectWrite objects s₀.ffi.mlx.next .stream) (fun a => a = s₀.ffi.mlx.next ∨ H a)
      (fun i => i = s₀.ffi.mlx.nnext ∨ N i) tail host R sourcePost.ffi t.ffi := ⟨post.native.1,nativePost⟩
  have newPost := post.setFfi sourcePost.ffi t.ffi nativePair
  have nodePolicy := policy.write_node s₀.ffi.mlx.nnext (sliceDynamicRole roles input startInput axes (constantShape sizes))
    (.sliceDynamic axes (constantShape sizes)) [input,startInput] rfl supported
  have newPolicy := nodePolicy.new_object s₀.ffi.mlx.next .stream True.intro
  exact ⟨sourcePost,t,sourceRun,targetRun,newPost,retained,newPolicy,newPolicy.source nativePost⟩

end Host.Load.Run.Full.Ordinary.SliceDynamicHost
