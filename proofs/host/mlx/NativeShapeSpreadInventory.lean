import host.mlx.NativeShapeValueRoles
import host.ts.RenameRetainedAllocation
import host.ts.RenameParametricShapeSpread
import host.ts.RenameArrayAllocation

set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0

namespace Host.Ts.Owned.Annotated
open Parametric

theorem ForestHolds.tail {ν : Nat → F64} {C : CSrv} {R : Ren} {roles : List Tree} {values : List Owned.Tree}
    (held : ForestHolds ν C R roles values) : ForestHolds ν C R roles.tail values.tail := by
  cases held with
  | nil => exact .nil
  | cons _ rest => exact rest

def RetainedNotes.shapeSpread (notes : RetainedNotes) (fresh : Nat) (elements : List Value) : RetainedNotes :=
  {notes with runtime := {notes.runtime with control := returnNote (.obj fresh),stack := notes.runtime.stack.tail}, arrays := notes.arrays.write fresh elements}

/-- The actual final typed spread reads the owned native shape through the
original typed element path. The selected source node fixes all new element
roles; target dimensions, reads and the retained array contents are derived. -/
theorem RetainedInventory.shape_spread_step
    (FR : Ren → Host.Load.LSt → Host.Load.LSt → Prop) {notes : RetainedNotes}
    {ν₀ ν : Nat → F64} {C₀ C : CSrv} {R : Ren} {live framed : Nat → Prop}
    {before after : List Val} {old old' : List Event} {s₀ s : St Host.Load.LSt}
    (h : Parametric.StateR (NumberRoles ν₀ ν C₀ C) FR R live framed before after old old' s₀ s)
    (inventory : RetainedInventory notes ν₀ ν C₀ C R live s₀ s)
    (roles : Nat → Host.Mlx.Ffi.Annotated.GraphNode)
    (ObjRel : Nat → Host.Mlx.Ffi.Obj → Host.Mlx.Ffi.Obj → Prop)
    (boundary H N : Nat → Prop) (tail : List NumV)
    (native : Host.Mlx.Ffi.NativeRoles.Live (NumberRoles ν₀ ν C₀ C) R
      (Host.Mlx.Ffi.Annotated.NodeRel roles ν₀ ν C₀ C R boundary) ObjRel H N tail s₀.ffi.mlx s.ffi.mlx)
    (view buffer handle : Nat) (object backing : Obj) (node : Host.Mlx.Ffi.Node) (env : Env) (frames : List Frame)
    (control : s₀.ctl = .ret (.obj view)) (stack : s₀.stack = .l (.spread [] [] env)::frames)
    (read : s₀.heap.get view = some (.obj object)) (kind : object.kind = .typed .i32 buffer 0 (len node.shape))
    (bufferRead : s₀.heap.get buffer = some (.obj backing))
    (bufferKind : backing.kind = .extBuf (4*handle) 0 (len node.shape*4))
    (sourceNode : s₀.ffi.mlx.node? handle = some node) (handleLive : H handle)
    (region : R.region (4*handle) = 4*R.handle handle)
    (protoLive : live aArrayProto) (protoFixed : R.a aArrayProto = aArrayProto)
    (sourceBound : s₀.next < 2^64) (targetBound : s.next < 2^64) :
    ∃ (i : Nat) (targetNode : Host.Mlx.Ffi.Node) (targetFrames : List Frame),
      s₀.ffi.mlx.arrs.get handle = some i ∧ s.ffi.mlx.node? (R.handle handle) = some targetNode ∧
      Host.Mlx.Ffi.Annotated.NodeRel roles ν₀ ν C₀ C R boundary i node targetNode ∧
      let sourcePost := ({s₀ with stack := frames}.alloc (valueArray (node.shape.map (fun d : Host.Mlx.Ffi.Dim => Val.num d.num)))).2.ret (.obj s₀.next)
      let targetPost := ({s with stack := targetFrames}.alloc (valueArray (targetNode.shape.map (fun d : Host.Mlx.Ffi.Dim => Val.num d.num)))).2.ret (.obj s.next)
      interpC (step Host.Load.ffi s₀).run C₀ = some (sourcePost,C₀) ∧
      interpC (step Host.Load.ffi s).run C = some (targetPost,C) ∧
      Parametric.StateR (NumberRoles ν₀ ν C₀ C) FR R (LiveAfter live s₀.next)
        framed before after old old' sourcePost targetPost ∧
      RetainedInventory (notes.shapeSpread s₀.next (roles i).shape.valueRoles)
        ν₀ ν C₀ C R (LiveAfter live s₀.next) sourcePost targetPost := by
  obtain ⟨value,targetControl,valueRole⟩ := (h.control_view control).ret_view
  cases valueRole
  obtain ⟨frame,targetFrames,targetStack,frameRole,tailRole⟩ := h.stack_view stack
  rw [frameRole.emptySpread_view] at targetStack
  have viewLive : live view := by have held := h.controlLive; rw [control] at held; exact held.1
  obtain ⟨targetView,targetViewRead,targetViewKind,bufferLive⟩ :=
    h.heap.read_typedBuffer view buffer 0 (len node.shape) object .i32 viewLive read kind
  obtain ⟨targetBuffer,targetBufferRead,targetBufferKind⟩ :=
    h.heap.read_externalBuffer buffer backing (4*handle) 0 (len node.shape*4) bufferLive bufferRead bufferKind
  obtain ⟨i,targetNode,index,targetNodeRead,nodeRole,shape,length⟩ :=
    Host.Load.Annotated.node_shape native handle handleLive node sourceNode
  rw [region,←length] at targetBufferKind
  rw [←length] at targetViewKind
  have sourceElements := Host.Load.Parametric.elemsOf_shape {s₀ with stack := frames} view buffer handle
    object backing node read kind bufferRead bufferKind sourceNode
  have targetElements := Host.Load.Parametric.elemsOf_shape {s with stack := targetFrames} (R.a view) (R.a buffer) (R.handle handle)
    targetView targetBuffer targetNode targetViewRead targetViewKind targetBufferRead targetBufferKind targetNodeRead
  have sourceRoles := nodeRole.source.shape.valueRoles identity
  have targetRoles := nodeRole.target.shape.valueRoles R
  have valuesRelated := annotated_values_paired sourceRoles targetRoles
  have sourceLive : listSupport (valueSupport live) (node.shape.map (fun d : Host.Mlx.Ffi.Dim => Val.num d.num)) := by
    generalize node.shape = dimensions
    induction dimensions with
    | nil => trivial
    | cons dimension dimensions ih => exact ⟨True.intro,ih⟩
  have stackLive := h.stackLive
  rw [stack] at stackLive
  have popped := h.restack tailRole stackLive.2
  have sourceTail := inventory.runtime.source.stack.tail
  have targetTail := inventory.runtime.target.stack.tail
  rw [stack,List.map_cons,List.tail_cons] at sourceTail
  rw [targetStack,List.map_cons,List.tail_cons] at targetTail
  let poppedNotes := notes.withRuntime {notes.runtime with stack := notes.runtime.stack.tail}
  have poppedInventory : RetainedInventory poppedNotes ν₀ ν C₀ C R live
      {s₀ with stack := frames} {s with stack := targetFrames} :=
    ⟨⟨inventory.runtime.keyLive,⟨inventory.runtime.source.control,sourceTail,inventory.runtime.source.cells⟩,
        ⟨inventory.runtime.target.control,targetTail,inventory.runtime.target.cells⟩⟩,
      inventory.privates.frame (fun _ held => held) (fun _ _ _ => rfl) (fun _ _ _ => rfl),
      inventory.captures.frame (fun _ held => held) (fun _ _ _ => rfl) (fun _ _ _ => rfl),
      inventory.arrays.frame (fun _ held => held) (fun _ _ _ => rfl) (fun _ _ _ => rfl),
      inventory.publicFields.frame (fun _ held => held) (fun _ _ _ _ => rfl) (fun _ _ _ _ => rfl),
      inventory.buffers.frame (fun _ held => held) (fun _ _ _ => rfl) (fun _ _ _ => rfl)⟩
  let sourceObject := valueArray (node.shape.map (fun d : Host.Mlx.Ffi.Dim => Val.num d.num))
  let targetObject := valueArray (targetNode.shape.map (fun d : Host.Mlx.Ffi.Dim => Val.num d.num))
  have post := popped.alloc_valueArray _ _ valuesRelated sourceLive protoLive protoFixed sourceBound targetBound
  have retained := poppedInventory.allocate_return popped.heap sourceObject targetObject sourceBound targetBound
  have arraysPost := poppedInventory.arrays.allocate popped.heap (roles i).shape.valueRoles
    _ _ sourceRoles targetRoles sourceLive sourceBound targetBound
  refine ⟨i,targetNode,targetFrames,index,targetNodeRead,nodeRole,?_,?_,post,?_⟩
  · rw [step_spread_final_eq Host.Load.ffi s₀ (.obj view) env frames _ control stack sourceElements]; rfl
  · rw [step_spread_final_eq Host.Load.ffi s (.obj (R.a view)) (R.env env) targetFrames _ targetControl targetStack targetElements]; rfl
  · exact ⟨retained.runtime,retained.privates,retained.captures,arraysPost,retained.publicFields,retained.buffers⟩

end Host.Ts.Owned.Annotated
