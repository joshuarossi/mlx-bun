import host.mlx.NativeKvAppendGeometry
import host.mlx.NativeShapeBufferInventory
import host.mlx.NativeSliceUpdateFrame
import host.mlx.NativeBufferResultFrame
import host.mlx.NativeAbsentObjectRoles
import host.mlx.NativeBufferVectorInventory

set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0

namespace Host.Load.Run.Full.Ordinary.SliceUpdateHost
open Host.Ts Host.Ts.Owned Host.Ts.Owned.Parametric Host.Ts.Owned.Annotated
open Host.Mlx.Ffi Host.Mlx.Ffi.NativeRoles Host.Mlx.Ffi.Annotated

def kvArgumentNotes (out handle update st sp sr stream : Nat) (startCount stopCount strideCount : Value) : List Value :=
  [.ptr (.js out) 0,.handle handle,.handle update,.ptr (.js st) 0,startCount,
    .ptr (.js sp) 0,stopCount,.ptr (.js sr) 0,strideCount,.handle stream]

private theorem kv_arguments_fixed {ν : Nat → F64} {C : CSrv} {R : Ren}
    (out handle update st sn sp en sr rn stream : Nat) (startCount stopCount strideCount : Value)
    (startSchema : FixedIntegerRole startCount (Int.ofNat sn))
    (stopSchema : FixedIntegerRole stopCount (Int.ofNat en))
    (strideSchema : FixedIntegerRole strideCount (Int.ofNat rn)) (values : List Val)
    (held : ListR (fun role value => role.Holds ν C R value)
      (kvArgumentNotes out handle update st sp sr stream startCount stopCount strideCount) values) :
    ListR (fun role value => role.role.Holds ν C R value)
      (arguments out handle update st sn sp en sr rn stream) values := by
  cases held with | cons a h =>
    cases h with | cons b h =>
      cases h with | cons c h =>
        cases h with | cons d h =>
          cases h with | cons e h =>
            cases h with | cons f h =>
              cases h with | cons g h =>
                cases h with | cons i h =>
                  cases h with | cons j h =>
                    cases h with | cons k h =>
                      cases h
                      exact .cons a (.cons b (.cons c (.cons d (.cons (startSchema.holds e)
                        (.cons f (.cons (stopSchema.holds g) (.cons i (.cons (strideSchema.holds j) (.cons k .nil)))))))))

/-- A one-token KV append consumes only the current cache/update producer
roles and retained int32 buffer notes. Pure integer bounds derive both native
inferences; the real output write installs its fresh handle note and preserves
all six inventories and every indexed native object/producer annotation. -/
theorem retained_kv_from_source {notes : RetainedNotes}
    (ν₀ ν : Nat → F64) (C₀ C : CSrv) (R : Ren)
    (roles : Nat → GraphNode) (boundary : Nat → Prop) (objects : Nat → Object)
    (H N : Nat → Prop) (tail : List NumV) (host : HostSt → HostSt → Prop)
    (live framed : Nat → Prop) (before after : List Val) (old old' : List Event) (s₀ s : Host.Ts.St LSt)
    (h : StateR (NumberRoles ν₀ ν C₀ C) (VectorHost.NativeRelation ν₀ ν C₀ C roles boundary objects H N tail host)
      R live framed before after old old' s₀ s)
    (inventory : RetainedInventory notes ν₀ ν C₀ C R live s₀ s)
    (fn types out handle update input updateInput st sp sr stream : Nat)
    (function signatureObject : Host.Ts.Obj) (returns : Name) (receiver : Val)
    (startExpressions stopExpressions strideExpressions : List SymE) (node updateNode : Node)
    (control : s₀.ctl = .call (.obj fn) receiver [.ptr (.js out) 0,.big (Int.ofNat handle),.big (Int.ofNat update),
      .ptr (.js st) 0,.big (Int.ofNat startExpressions.length),.ptr (.js sp) 0,.big (Int.ofNat stopExpressions.length),
      .ptr (.js sr) 0,.big (Int.ofNat strideExpressions.length),.big (Int.ofNat stream)])
    (read : s₀.heap.get fn = some (.obj function))
    (kind : function.kind = .fn (.native (.ffi .symbol) [.str symbol,.obj types,.str returns]))
    (signatureRead : s₀.heap.get types = some (.obj signatureObject)) (signatureKind : signatureObject.kind = .array signature)
    (signatureFrame : ¬ framed types) (handleLive : H handle) (updateLive : H update)
    (producers : nodesOf s₀.ffi.mlx [handle,update] = some [input,updateInput])
    (sourceNode : s₀.ffi.mlx.nodes.get input = some node) (sourceUpdate : s₀.ffi.mlx.nodes.get updateInput = some updateNode)
    (sourceValues : KvAppendValues ν₀ (roles input).shape (roles updateInput).shape
      (startExpressions.map Dimension.literal) (stopExpressions.map Dimension.literal) (strideExpressions.map Dimension.literal))
    (targetValues : KvAppendValues ν (roles input).shape (roles updateInput).shape
      (startExpressions.map Dimension.literal) (stopExpressions.map Dimension.literal) (strideExpressions.map Dimension.literal))
    (sourceNodes : s₀.ffi.mlx.nnext < 2^64) (targetNodes : s.ffi.mlx.nnext < 2^64)
    (sourceHandles : s₀.ffi.mlx.next < 2^64) (targetHandles : s.ffi.mlx.next < 2^64)
    (sourceHeap : out < 2^64) (targetHeap : s.next < 2^64)
    (roots : Nat → Prop) (policy : ProducerAnnotations roots H N roles objects)
    (fnRole thisRole startCount stopCount strideCount : Value)
    (startSchema : FixedIntegerRole startCount (Int.ofNat startExpressions.length))
    (stopSchema : FixedIntegerRole stopCount (Int.ofNat stopExpressions.length))
    (strideSchema : FixedIntegerRole strideCount (Int.ofNat strideExpressions.length))
    (note : notes.runtime.control = callNote fnRole thisRole
      (kvArgumentNotes out handle update st sp sr stream startCount stopCount strideCount))
    (selected : notes.buffers.owners out = some (handleSlotNotes 0))
    (selectedStart : notes.buffers.owners st = some (literalShapeByteNotes startExpressions))
    (selectedStop : notes.buffers.owners sp = some (literalShapeByteNotes stopExpressions))
    (selectedStride : notes.buffers.owners sr = some (literalShapeByteNotes strideExpressions)) :
    let starts := startExpressions.map Dimension.literal
    let stops := stopExpressions.map Dimension.literal
    let strides := strideExpressions.map Dimension.literal
    let newRoles := nodeWrite roles s₀.ffi.mlx.nnext (sliceUpdateRole roles input updateInput starts stops strides)
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
  let starts := startExpressions.map Dimension.literal
  let stops := stopExpressions.map Dimension.literal
  let strides := strideExpressions.map Dimension.literal
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
  obtain ⟨startObject,_,startBytes,_,startRead,startKind,_,_,startRoles,_⟩ :=
    inventory.buffers.selected st (literalShapeByteNotes startExpressions) selectedStart
  obtain ⟨stopObject,_,stopBytes,_,stopRead,stopKind,_,_,stopRoles,_⟩ :=
    inventory.buffers.selected sp (literalShapeByteNotes stopExpressions) selectedStop
  obtain ⟨strideObject,_,strideBytes,_,strideRead,strideKind,_,_,strideRoles,_⟩ :=
    inventory.buffers.selected sr (literalShapeByteNotes strideExpressions) selectedStride
  have sourceStarts : ShapeBuffer.Holds starts ν₀ C₀ startBytes :=
    ⟨_,sourceValues.startValues.holds C₀,literal_shape_bytes_exact _ _ _ sourceValues.startValues startRoles⟩
  have sourceStops : ShapeBuffer.Holds stops ν₀ C₀ stopBytes :=
    ⟨_,sourceValues.stopValues.holds C₀,literal_shape_bytes_exact _ _ _ sourceValues.stopValues stopRoles⟩
  have sourceStrides : ShapeBuffer.Holds strides ν₀ C₀ strideBytes :=
    ⟨_,sourceValues.strideValues.holds C₀,literal_shape_bytes_exact _ _ _ sourceValues.strideValues strideRoles⟩
  have targetStarts := (inventory.buffers.target st _ selectedStart).literal_shape _ _ targetValues.startValues
  have targetStops := (inventory.buffers.target sp _ selectedStop).literal_shape _ _ targetValues.stopValues
  have targetStrides := (inventory.buffers.target sr _ selectedStride).literal_shape _ _ targetValues.strideValues
  obtain ⟨_,_,targetThis,targetArgs,targetControl,_,_,_,_,_⟩ :=
    h.native_call_view fn function (.ffi .symbol) _ receiver _ control read kind
  have current := inventory.runtime.target.control
  rw [note,targetControl] at current
  have currentArguments := (callNote_view current).2.2
  have argumentRoles := kv_arguments_fixed out handle update st startExpressions.length sp stopExpressions.length
    sr strideExpressions.length stream startCount stopCount strideCount startSchema stopSchema strideSchema targetArgs currentArguments
  have argumentRoles' : ListR (fun role value => role.role.Holds ν C R value)
      (arguments out handle update st starts.length sp stops.length sr strides.length stream) (callArguments s.ctl) := by
    simpa only [targetControl,callArguments,starts,stops,strides,List.length_map] using argumentRoles
  have control' : s₀.ctl = .call (.obj fn) receiver [.ptr (.js out) 0,.big (Int.ofNat handle),.big (Int.ofNat update),
      .ptr (.js st) 0,.big (Int.ofNat starts.length),.ptr (.js sp) 0,.big (Int.ofNat stops.length),
      .ptr (.js sr) 0,.big (Int.ofNat strides.length),.big (Int.ofNat stream)] := by
    simpa only [starts,stops,strides,List.length_map] using control
  obtain ⟨stDims,spDims,srDims,t,sourceRun,targetRun,post,slotRole,sourceFrame,targetFrame,outside,targetReturn⟩ :=
    from_source_framed ν₀ ν C₀ C R roles boundary objects H N tail host live framed before after old old' s₀ s h
      fn types out handle update input updateInput st sp sr stream function signatureObject outObject startObject stopObject strideObject
      returns receiver startBytes stopBytes strideBytes starts stops strides node updateNode control' read kind signatureRead signatureKind
      outputRead outputKind startRead startKind stopRead stopKind strideRead strideKind signatureFrame handleLive updateLive
      producers sourceNode sourceUpdate sourceStarts sourceStops sourceStrides
      (literal_shape_decodable startExpressions) (literal_shape_decodable stopExpressions) (literal_shape_decodable strideExpressions)
      sourceValues.geometry targetValues.geometry argumentRoles' outputRole targetStarts targetStops targetStrides
      sourceNodes targetNodes sourceHandles targetHandles sourceHeap targetHeap
  let native₀ := resultWorld s₀.ffi input updateInput stDims spDims srDims node
  let beforeBytes := cellParts .u64 (.big (Int.ofNat 0)) 8 0
  let afterBytes := cellParts .u64 (.big (Int.ofNat s₀.ffi.mlx.next)) 8 0
  let sourcePost := finishBuffer s₀ native₀ out 0 outObject beforeBytes afterBytes symbol
    (callArgs out handle update st starts.length sp stops.length sr strides.length stream beforeBytes startBytes stopBytes strideBytes)
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
    sourceFrame targetFrame sourceSlot slotRole sourceOutside outside rfl targetReturn
  have absent : sourcePost.ffi.mlx.objs.get s₀.ffi.mlx.next = none := by
    change s₀.ffi.mlx.objs.get s₀.ffi.mlx.next = none
    exact h.native.2.source_fresh_obj (Nat.le_refl _)
  have nativePost := post.native.2.reannotate_absent_object s₀.ffi.mlx.next .stream absent
  have nativePair : VectorHost.NativeRelation ν₀ ν C₀ C
      (nodeWrite roles s₀.ffi.mlx.nnext (sliceUpdateRole roles input updateInput starts stops strides)) boundary
      (objectWrite objects s₀.ffi.mlx.next .stream) (fun a => a = s₀.ffi.mlx.next ∨ H a)
      (fun i => i = s₀.ffi.mlx.nnext ∨ N i) tail host R sourcePost.ffi t.ffi := ⟨post.native.1,nativePost⟩
  have newPost := post.setFfi sourcePost.ffi t.ffi nativePair
  have supported := h.native.2.nodesOf_support [handle,update] [input,updateInput] ⟨handleLive,updateLive,True.intro⟩ producers
  have nodePolicy := policy.write_node s₀.ffi.mlx.nnext (sliceUpdateRole roles input updateInput starts stops strides)
    (.sliceUpdate starts stops strides) [input,updateInput] rfl supported
  have newPolicy := nodePolicy.new_object s₀.ffi.mlx.next .stream True.intro
  exact ⟨sourcePost,t,sourceRun,targetRun,newPost,retained,newPolicy,newPolicy.source nativePost⟩

/-- A checked original source cut additionally transports its current number-server
instantiation. Only the source equation is supplied; target execution and every
post inventory/native role are derived by the append theorem. -/
theorem retained_kv_cut {notes : RetainedNotes}
    (ν₀ ν : Nat → F64) (C₀ C : CSrv) (R : Ren)
    (roles : Nat → GraphNode) (boundary : Nat → Prop) (objects : Nat → Object)
    (H N : Nat → Prop) (tail : List NumV) (host : HostSt → HostSt → Prop)
    (live framed : Nat → Prop) (before after : List Val) (old old' : List Event) (s₀ s : Host.Ts.St LSt)
    (h : StateR (NumberRoles ν₀ ν C₀ C) (VectorHost.NativeRelation ν₀ ν C₀ C roles boundary objects H N tail host)
      R live framed before after old old' s₀ s)
    (inventory : RetainedInventory notes ν₀ ν C₀ C R live s₀ s)
    (fn types out handle update input updateInput st sp sr stream : Nat)
    (function signatureObject : Host.Ts.Obj) (returns : Name) (receiver : Val)
    (startExpressions stopExpressions strideExpressions : List SymE) (node updateNode : Node)
    (control : s₀.ctl = .call (.obj fn) receiver [.ptr (.js out) 0,.big (Int.ofNat handle),.big (Int.ofNat update),
      .ptr (.js st) 0,.big (Int.ofNat startExpressions.length),.ptr (.js sp) 0,.big (Int.ofNat stopExpressions.length),
      .ptr (.js sr) 0,.big (Int.ofNat strideExpressions.length),.big (Int.ofNat stream)])
    (read : s₀.heap.get fn = some (.obj function))
    (kind : function.kind = .fn (.native (.ffi .symbol) [.str symbol,.obj types,.str returns]))
    (signatureRead : s₀.heap.get types = some (.obj signatureObject)) (signatureKind : signatureObject.kind = .array signature)
    (signatureFrame : ¬ framed types) (handleLive : H handle) (updateLive : H update)
    (producers : nodesOf s₀.ffi.mlx [handle,update] = some [input,updateInput])
    (sourceNode : s₀.ffi.mlx.nodes.get input = some node) (sourceUpdate : s₀.ffi.mlx.nodes.get updateInput = some updateNode)
    (sourceValues : KvAppendValues ν₀ (roles input).shape (roles updateInput).shape
      (startExpressions.map Dimension.literal) (stopExpressions.map Dimension.literal) (strideExpressions.map Dimension.literal))
    (targetValues : KvAppendValues ν (roles input).shape (roles updateInput).shape
      (startExpressions.map Dimension.literal) (stopExpressions.map Dimension.literal) (strideExpressions.map Dimension.literal))
    (sourceNodes : s₀.ffi.mlx.nnext < 2^64) (targetNodes : s.ffi.mlx.nnext < 2^64)
    (sourceHandles : s₀.ffi.mlx.next < 2^64) (targetHandles : s.ffi.mlx.next < 2^64)
    (sourceHeap : out < 2^64) (targetHeap : s.next < 2^64)
    (roots : Nat → Prop) (policy : ProducerAnnotations roots H N roles objects)
    (fnRole thisRole startCount stopCount strideCount : Value)
    (startSchema : FixedIntegerRole startCount (Int.ofNat startExpressions.length))
    (stopSchema : FixedIntegerRole stopCount (Int.ofNat stopExpressions.length))
    (strideSchema : FixedIntegerRole strideCount (Int.ofNat strideExpressions.length))
    (note : notes.runtime.control = callNote fnRole thisRole
      (kvArgumentNotes out handle update st sp sr stream startCount stopCount strideCount))
    (selected : notes.buffers.owners out = some (handleSlotNotes 0))
    (selectedStart : notes.buffers.owners st = some (literalShapeByteNotes startExpressions))
    (selectedStop : notes.buffers.owners sp = some (literalShapeByteNotes stopExpressions))
    (selectedStride : notes.buffers.owners sr = some (literalShapeByteNotes strideExpressions))
    (sourceOutput : Host.Ts.St LSt) (initialServer nextServer : SSrv)
    (inst : Inst ν₀ initialServer C₀)
    (sourceStep : interpS (step Host.Load.ffi s₀).run initialServer = some (sourceOutput,nextServer)) :
    let starts := startExpressions.map Dimension.literal
    let stops := stopExpressions.map Dimension.literal
    let strides := strideExpressions.map Dimension.literal
    let newRoles := nodeWrite roles s₀.ffi.mlx.nnext (sliceUpdateRole roles input updateInput starts stops strides)
    let newObjects := objectWrite objects s₀.ffi.mlx.next .stream
    let newHandles := fun a => a = s₀.ffi.mlx.next ∨ H a
    let newNodes := fun i => i = s₀.ffi.mlx.nnext ∨ N i
    ∃ targetPost, interpC (step Host.Load.ffi s₀).run C₀ = some (sourceOutput,C₀) ∧
      interpC (step Host.Load.ffi s).run C = some (targetPost,C) ∧
      StateR (NumberRoles ν₀ ν C₀ C) (VectorHost.NativeRelation ν₀ ν C₀ C newRoles boundary newObjects newHandles newNodes tail host)
        R live framed before after old old' sourceOutput targetPost ∧
      RetainedInventory (notes.nativeHandleResult out s₀.ffi.mlx.next) ν₀ ν C₀ C R live sourceOutput targetPost ∧
      ProducerAnnotations roots newHandles newNodes newRoles newObjects ∧
      ProducerSupport roots newHandles newNodes sourceOutput.ffi.mlx ∧ Inst ν₀ nextServer C₀ := by
  dsimp only
  obtain ⟨sourcePost,targetPost,left,right,post,retained,policyPost,support⟩ :=
    retained_kv_from_source ν₀ ν C₀ C R roles boundary objects H N tail host live framed before after old old' s₀ s
      h inventory fn types out handle update input updateInput st sp sr stream function signatureObject returns receiver
      startExpressions stopExpressions strideExpressions node updateNode control read kind signatureRead signatureKind signatureFrame
      handleLive updateLive producers sourceNode sourceUpdate sourceValues targetValues sourceNodes targetNodes sourceHandles targetHandles
      sourceHeap targetHeap roots policy fnRole thisRole startCount stopCount strideCount startSchema stopSchema strideSchema
      note selected selectedStart selectedStop selectedStride
  obtain ⟨D,actual,instAfter⟩ := interp_sim ν₀ (step Host.Load.ffi s₀).run initialServer C₀ sourceOutput nextServer inst sourceStep
  have equality := Option.some.inj (left.symm.trans actual)
  have same : sourcePost = sourceOutput := congrArg Prod.fst equality
  have table : C₀ = D := congrArg Prod.snd equality
  rw [same] at left post retained support
  exact ⟨targetPost,left,right,post,retained,policyPost,support,table ▸ instAfter⟩

end Host.Load.Run.Full.Ordinary.SliceUpdateHost
