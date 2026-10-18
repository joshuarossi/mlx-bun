import host.mlx.NativeBufferVectorInventory
import host.mlx.NativeVectorDataHost
import host.mlx.NativeAnnotationPolicy
import host.ts.RenameRetainedInventory

set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0

namespace Host.Load.Run.Full.Ordinary.VectorDataHost
open Host.Ts Host.Ts.Owned Host.Ts.Owned.Parametric Host.Ts.Owned.Annotated
open Host.Mlx.Ffi Host.Mlx.Ffi.NativeRoles Host.Mlx.Ffi.Annotated

/-- The real vector constructor consumes existing handle-byte and argument
notes. The exact count schema excludes rounded-only integer meanings. All six
inventories and the updated fresh-vector producer policy are returned. -/
theorem retained_from_source {notes : RetainedNotes}
    (ν₀ ν : Nat → F64) (C₀ C : CSrv) (R : Ren)
    (roles : Nat → GraphNode) (boundary : Nat → Prop) (objects : Nat → Object)
    (H N : Nat → Prop) (tail : List NumV) (host : HostSt → HostSt → Prop)
    (live framed : Nat → Prop) (before after : List Val) (old old' : List Event) (s₀ s : Host.Ts.St LSt)
    (h : StateR (NumberRoles ν₀ ν C₀ C) (VectorHost.NativeRelation ν₀ ν C₀ C roles boundary objects H N tail host)
      R live framed before after old old' s₀ s)
    (inventory : RetainedInventory notes ν₀ ν C₀ C R live s₀ s)
    (fn types buffer : Nat) (function signatureObject : Host.Ts.Obj) (returns : Name) (receiver : Val) (handles nodes : List Nat)
    (control : s₀.ctl = .call (.obj fn) receiver [.ptr (.js buffer) 0,.big (Int.ofNat handles.length)])
    (read : s₀.heap.get fn = some (.obj function))
    (kind : function.kind = .fn (.native (.ffi .symbol) [.str chars!"mlx_vector_array_new_data",.obj types,.str returns]))
    (signatureRead : s₀.heap.get types = some (.obj signatureObject))
    (signatureKind : signatureObject.kind = .array [.str chars!"ptr",.str chars!"u64"])
    (signatureFrame : ¬ framed types) (owned : listSupport H handles)
    (sourceNodes : nodesOf s₀.ffi.mlx handles = some nodes)
    (sourceBound : s₀.ffi.mlx.next < 2^64) (targetBound : s.ffi.mlx.next < 2^64)
    (roots : Nat → Prop) (policy : ProducerAnnotations roots H N roles objects)
    (fnRole thisRole countRole : Value) (countSchema : FixedIntegerRole countRole (Int.ofNat handles.length))
    (note : notes.runtime.control = callNote fnRole thisRole [.ptr (.js buffer) 0,countRole])
    (selected : notes.buffers.owners buffer = some (handleArrayBytes handles)) :
    let sourcePost := finishBig s₀ (resultWorld s₀.ffi nodes) chars!"mlx_vector_array_new_data"
      [.jsPtr buffer 0 (VectorBuffer.bytes handles),.big (Int.ofNat handles.length)] (Int.ofNat s₀.ffi.mlx.next)
    let targetPost := finishBig s (resultWorld s.ffi (nodes.map R.node)) chars!"mlx_vector_array_new_data"
      [.jsPtr (R.a buffer) 0 (VectorBuffer.bytes (handles.map R.handle)),.big (Int.ofNat handles.length)] (Int.ofNat s.ffi.mlx.next)
    let newObjects := objectWrite objects s₀.ffi.mlx.next (.vec nodes)
    let newHandles := fun a => a = s₀.ffi.mlx.next ∨ H a
    interpC (step Host.Load.ffi s₀).run C₀ = some (sourcePost,C₀) ∧
      interpC (step Host.Load.ffi s).run C = some (targetPost,C) ∧
      StateR (NumberRoles ν₀ ν C₀ C) (VectorHost.NativeRelation ν₀ ν C₀ C roles boundary newObjects newHandles N tail host)
        R live framed before after old old' sourcePost targetPost ∧
      RetainedInventory (notes.withRuntime ⟨returnNote (.handle s₀.ffi.mlx.next),notes.runtime.stack,notes.runtime.cells⟩)
        ν₀ ν C₀ C R live sourcePost targetPost ∧
      ProducerAnnotations roots newHandles N roles newObjects ∧ ProducerSupport roots newHandles N sourcePost.ffi.mlx := by
  dsimp only
  obtain ⟨sourceBuffer,targetBuffer,sourceBytes,targetBytes,sourceRead,sourceKind,targetRead,targetKind,sourceRoles,targetRoles⟩ :=
    inventory.buffers.selected buffer (handleArrayBytes handles) selected
  have sourceVectorRole := buffer_bytes_vector_role sourceRoles
  have exactSourceBytes := VectorBuffer.exact_bytes sourceVectorRole
  have identityHandles : identity.handle = id := by funext handle; rfl
  rw [identityHandles,List.map_id] at exactSourceBytes
  rw [exactSourceBytes] at sourceKind
  have targetVectorRole := (inventory.buffers.target buffer _ selected).vector_role
  have targetCountRole := (inventory.runtime.call_argument_role fnRole thisRole [.ptr (.js buffer) 0,countRole]
    (.obj fn) receiver _ control note 1 countRole rfl).2
  have count := countSchema.holds targetCountRole
  obtain ⟨sourceRun,targetRun,post⟩ := from_source ν₀ ν C₀ C R roles boundary objects H N tail host live framed
    before after old old' s₀ s h fn types buffer function signatureObject sourceBuffer returns receiver handles nodes
    control read kind signatureRead signatureKind sourceRead sourceKind signatureFrame owned sourceNodes sourceBound targetBound count targetVectorRole
  have heapPost := inventory.heapInventory.frame (fun _ alive => alive) (fun _ _ => rfl) (fun _ _ => rfl)
  have targetReturn : (Value.handle s₀.ffi.mlx.next).Holds ν C R (.big (Int.ofNat s.ffi.mlx.next)) := by
    rw [←h.native.2.handleMap.head]
    exact .handle _
  have runtimePost : RuntimeInventory ⟨returnNote (.handle s₀.ffi.mlx.next),notes.runtime.stack,notes.runtime.cells⟩ ν₀ ν C₀ C R live
      (finishBig s₀ (resultWorld s₀.ffi nodes) chars!"mlx_vector_array_new_data"
        [.jsPtr buffer 0 (VectorBuffer.bytes handles),.big (Int.ofNat handles.length)] (Int.ofNat s₀.ffi.mlx.next))
      (finishBig s (resultWorld s.ffi (nodes.map R.node)) chars!"mlx_vector_array_new_data"
        [.jsPtr (R.a buffer) 0 (VectorBuffer.bytes (handles.map R.handle)),.big (Int.ofNat handles.length)] (Int.ofNat s.ffi.mlx.next)) :=
    ⟨inventory.runtime.keyLive,⟨returnNote_holds (.handle _),inventory.runtime.source.stack,heapPost.cells.source⟩,
      ⟨returnNote_holds targetReturn,inventory.runtime.target.stack,heapPost.cells.target⟩⟩
  have retained : RetainedInventory (notes.withRuntime ⟨returnNote (.handle s₀.ffi.mlx.next),notes.runtime.stack,notes.runtime.cells⟩)
      ν₀ ν C₀ C R live
      (finishBig s₀ (resultWorld s₀.ffi nodes) chars!"mlx_vector_array_new_data"
        [.jsPtr buffer 0 (VectorBuffer.bytes handles),.big (Int.ofNat handles.length)] (Int.ofNat s₀.ffi.mlx.next))
      (finishBig s (resultWorld s.ffi (nodes.map R.node)) chars!"mlx_vector_array_new_data"
        [.jsPtr (R.a buffer) 0 (VectorBuffer.bytes (handles.map R.handle)),.big (Int.ofNat handles.length)] (Int.ofNat s.ffi.mlx.next)) :=
    ⟨runtimePost,
      inventory.privates.frame (fun _ alive => alive) (fun _ _ _ => rfl) (fun _ _ _ => rfl),
      inventory.captures.frame (fun _ alive => alive) (fun _ _ _ => rfl) (fun _ _ _ => rfl),
      inventory.arrays.frame (fun _ alive => alive) (fun _ _ _ => rfl) (fun _ _ _ => rfl),
      inventory.publicFields.frame (fun _ alive => alive) (fun _ _ _ _ => rfl) (fun _ _ _ _ => rfl),
      inventory.buffers.frame (fun _ alive => alive) (fun _ _ _ => rfl) (fun _ _ _ => rfl)⟩
  have supported := h.native.2.nodesOf_support handles nodes owned sourceNodes
  have newPolicy := policy.new_object s₀.ffi.mlx.next (.vec nodes) supported
  exact ⟨sourceRun,targetRun,post,retained,newPolicy,newPolicy.source post.native.2⟩

end Host.Load.Run.Full.Ordinary.VectorDataHost
