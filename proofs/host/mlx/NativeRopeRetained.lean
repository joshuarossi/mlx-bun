import host.mlx.NativeRopeLiteralFrame
import host.mlx.NativeBufferResultFrame
import host.mlx.NativeAbsentObjectRoles
import host.ts.RenameParametricTypedElements

set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0

namespace Host.Load.Run.Full.Ordinary.RopeHost
open Host.Ts Host.Ts.Owned Host.Ts.Owned.Parametric Host.Ts.Owned.Annotated
open Host.Mlx.Ffi Host.Mlx.Ffi.NativeRoles Host.Mlx.Ffi.NativeRoles.Arguments Host.Mlx.Ffi.Annotated

def literalArgumentNotes (out handle stream : Nat) (dims : F64) (traditional : Bool) (base : Int) (scale : F64) (offset : SymE) : List Value :=
  [.ptr (.js out) 0,.handle handle,.literal (.lit dims),.bool traditional,.ordinaryBig base,.literal (.lit scale),
    .literal offset,.ordinaryBig 0,.handle stream]

private theorem current_offset {ν : Nat → F64} {C : CSrv}
    (out handle stream : Nat) (dims : F64) (traditional : Bool) (base : Int) (scale value : F64) (offset : SymE)
    (held : ListR (fun role actual => role.Holds ν C identity actual)
      (literalArgumentNotes out handle stream dims traditional base scale offset)
      (rawArgs out handle stream dims traditional base scale (.lit value))) :
    (Number.literal offset).Holds ν C (.lit value) := by
  cases held with | cons _ h =>
    cases h with | cons _ h =>
      cases h with | cons _ h =>
        cases h with | cons _ h =>
          cases h with | cons _ h =>
            cases h with | cons _ h =>
              cases h with | cons selected _ =>
                cases selected with | literal _ _ meaning => exact .literal _ _ meaning

private theorem literal_argument_roles {ν : Nat → F64} {C : CSrv} {R : Ren}
    (out handle stream : Nat) (dims : F64) (traditional : Bool) (base : Int) (scale : F64) (offset : SymE)
    (values : List Val) (held : ListR (fun role actual => role.Holds ν C R actual)
      (literalArgumentNotes out handle stream dims traditional base scale offset) values) :
    ListR (ArgumentPattern.Holds ν C R)
      ((beforeArguments out handle dims traditional base scale).map .fixed ++ [.numeric (.literal offset)] ++ (afterArguments stream).map .fixed) values := by
  cases held with | cons a h =>
    cases h with | cons b h =>
      cases h with | cons c h =>
        cases h with | cons d h =>
          cases h with | cons e h =>
            cases h with | cons f h =>
              cases h with | cons g h =>
                cases h with | cons i h =>
                  cases h with | cons j h =>
                    cases h
                    cases g with | literal _ value meaning =>
                      exact .cons a (.cons b (.cons c (.cons d (.cons e (.cons f
                        (.cons ⟨.lit value,rfl,.literal _ _ meaning⟩ (.cons i (.cons j .nil))))))))

/-- A current literal offset note can vary with the loop valuation. Its
original i32 cast is retained explicitly, while both numeric servers remain
unchanged. All six inventories and the indexed producer policy survive. -/
theorem retained_from_source {notes : RetainedNotes}
    (ν₀ ν : Nat → F64) (C₀ C : CSrv) (R : Ren)
    (roles : Nat → GraphNode) (boundary : Nat → Prop) (objects : Nat → Object)
    (H N : Nat → Prop) (tail : List NumV) (host : HostSt → HostSt → Prop)
    (live framed : Nat → Prop) (before after : List Val) (old old' : List Event) (s₀ s : Host.Ts.St LSt)
    (h : StateR (NumberRoles ν₀ ν C₀ C) (VectorHost.NativeRelation ν₀ ν C₀ C roles boundary objects H N tail host)
      R live framed before after old old' s₀ s)
    (inventory : RetainedInventory notes ν₀ ν C₀ C R live s₀ s)
    (fn types out handle input stream dims : Nat) (dimValue : F64) (traditional : Bool) (base : Int) (scale : F64)
    (offset : SymE) (offsetValue : F64) (function signatureObject : Host.Ts.Obj) (returns : Name) (receiver : Val) (node : Node)
    (control : s₀.ctl = .call (.obj fn) receiver (rawArgs out handle stream dimValue traditional base scale (.lit offsetValue)))
    (read : s₀.heap.get fn = some (.obj function))
    (functionKind : function.kind = .fn (.native (.ffi .symbol) [.str symbol,.obj types,.str returns]))
    (signatureRead : s₀.heap.get types = some (.obj signatureObject)) (signatureKind : signatureObject.kind = .array signature)
    (signatureFrame : ¬ framed types) (handleLive : H handle)
    (producer : nodesOf s₀.ffi.mlx [handle] = some [input]) (sourceNode : s₀.ffi.mlx.nodes.get input = some node)
    (dimension : F64.toInt? dimValue = some (Int.ofNat dims)) (dimFixed : F64.un .int32 dimValue = dimValue) (positive : 0 < dims)
    (rank : Nat.ble 3 node.shape.length = true)
    (sourceNodes : s₀.ffi.mlx.nnext < 2^64) (targetNodes : s.ffi.mlx.nnext < 2^64)
    (sourceHandles : s₀.ffi.mlx.next < 2^64) (targetHandles : s.ffi.mlx.next < 2^64)
    (sourceHeap : out < 2^64) (targetHeap : s.next < 2^64)
    (roots : Nat → Prop) (policy : ProducerAnnotations roots H N roles objects)
    (fnRole thisRole : Value)
    (note : notes.runtime.control = callNote fnRole thisRole (literalArgumentNotes out handle stream dimValue traditional base scale offset))
    (selected : notes.buffers.owners out = some (handleSlotNotes 0)) :
    let newRoles := nodeWrite roles s₀.ffi.mlx.nnext (ropeRole roles input dims traditional (baseRole base) (scaleRole scale) ((Number.literal offset).decoded .i32))
    let newObjects := objectWrite objects s₀.ffi.mlx.next .stream
    let newH := fun a => a = s₀.ffi.mlx.next ∨ H a
    let newN := fun i => i = s₀.ffi.mlx.nnext ∨ N i
    ∃ sourcePost targetPost, interpC (step Host.Load.ffi s₀).run C₀ = some (sourcePost,C₀) ∧ interpC (step Host.Load.ffi s).run C = some (targetPost,C) ∧
      StateR (NumberRoles ν₀ ν C₀ C) (VectorHost.NativeRelation ν₀ ν C₀ C newRoles boundary newObjects newH newN tail host)
        R live framed before after old old' sourcePost targetPost ∧
      RetainedInventory (notes.nativeHandleResult out s₀.ffi.mlx.next) ν₀ ν C₀ C R live sourcePost targetPost ∧
      ProducerAnnotations roots newH newN newRoles newObjects ∧ ProducerSupport roots newH newN sourcePost.ffi.mlx := by
  dsimp only
  obtain ⟨outObject,targetObject,bytes,targetBytes,outputRead,outputKind,targetRead,targetKind,sourceRoles,targetRoles⟩ :=
    inventory.buffers.selected out (handleSlotNotes 0) selected
  have exactSource := cellPartNotes_handle_exact .u64 0 8 0 bytes sourceRoles
  change bytes = cellParts .u64 (.big (Int.ofNat 0)) 8 0 at exactSource
  rw [exactSource] at outputKind
  have exactTarget := cellPartNotes_handle_exact .u64 0 8 0 targetBytes targetRoles
  rw [h.native.2.handleZero] at exactTarget
  have outputRole : (fixedBufferRole VectorGetHost.nullRole).Holds ν C R (objectKindAt s (R.a out)) := by
    simpa only [objectKindAt,Host.Ts.St.obj?,targetRead,targetKind,exactTarget,VectorGetHost.null_bytes] using fixedBuffer_holds ν C R VectorGetHost.nullRole
  have sourceCurrent := inventory.runtime.source.control
  rw [note,control] at sourceCurrent
  have sourceOffset := current_offset out handle stream dimValue traditional base scale offsetValue offset (callNote_view sourceCurrent).2.2
  obtain ⟨_,_,targetThis,targetArgs,targetControl,_,_,_,_,_⟩ := h.native_call_view fn function (.ffi .symbol) _ receiver _ control read functionKind
  have targetCurrent := inventory.runtime.target.control
  rw [note,targetControl] at targetCurrent
  have argumentRoles := literal_argument_roles out handle stream dimValue traditional base scale offset targetArgs (callNote_view targetCurrent).2.2
  have argumentRoles' : ListR (ArgumentPattern.Holds ν C R)
      ((beforeArguments out handle dimValue traditional base scale).map .fixed ++ [.numeric (.literal offset)] ++ (afterArguments stream).map .fixed) (callArguments s.ctl) := by
    simpa only [targetControl,callArguments] using argumentRoles
  have supported := h.native.2.nodesOf_support [handle] [input] ⟨handleLive,True.intro⟩ producer
  obtain ⟨_,_,inputRole⟩ := h.native.2.node_view supported.1 sourceNode
  have roleRank : Nat.ble 3 (len (roles input).shape) = true := by rw [inputRole.source.shape.len_eq,len_list_length]; exact rank
  obtain ⟨t,left,right,post,slotRole,_,_,sourceFrame,targetFrame,outside,targetReturn⟩ :=
    from_literal_source_framed ν₀ ν C₀ C R roles boundary objects H N tail host live framed before after old old' s₀ s h
      fn types out handle input stream dims dimValue traditional base scale offset offsetValue function signatureObject outObject returns receiver node
      control read functionKind signatureRead signatureKind outputRead outputKind signatureFrame handleLive producer sourceNode sourceOffset
      argumentRoles' outputRole dimension dimFixed positive roleRank sourceNodes targetNodes sourceHandles targetHandles sourceHeap targetHeap
  let sourcePost := finish s₀ out handle input stream dims dimValue traditional base scale (.lit (F64.un .int32 offsetValue)) node outObject
  have sourceSlot : (slotKindRole s₀.ffi.mlx.next).Holds ν₀ C₀ identity (objectKindAt sourcePost out) := by
    simp only [sourcePost,finish,objectKindAt,finishBuffer,Host.Ts.St.ret,Host.Ts.St.setTrace,Host.Ts.St.setFfi,
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
      (nodeWrite roles s₀.ffi.mlx.nnext (ropeRole roles input dims traditional (baseRole base) (scaleRole scale) ((Number.literal offset).decoded .i32))) boundary
      (objectWrite objects s₀.ffi.mlx.next .stream) (fun a => a = s₀.ffi.mlx.next ∨ H a) (fun i => i = s₀.ffi.mlx.nnext ∨ N i) tail host R sourcePost.ffi t.ffi :=
    ⟨post.native.1,nativePost⟩
  have updated := post.setFfi sourcePost.ffi t.ffi nativePair
  have nodePolicy := policy.write_node s₀.ffi.mlx.nnext (ropeRole roles input dims traditional (baseRole base) (scaleRole scale) ((Number.literal offset).decoded .i32))
    (.rope dims traditional (baseRole base) (scaleRole scale) ((Number.literal offset).decoded .i32)) [input] rfl supported
  have newPolicy := nodePolicy.new_object s₀.ffi.mlx.next .stream True.intro
  exact ⟨sourcePost,t,left,right,updated,retained,newPolicy,newPolicy.source nativePost⟩

end Host.Load.Run.Full.Ordinary.RopeHost
