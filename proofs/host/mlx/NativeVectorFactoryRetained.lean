import host.mlx.NativeVectorFactoryHost
import host.mlx.NativeAnnotationPolicy
import host.mlx.NativeBufferInventory
import host.ts.RenameRetainedHeapFrame

set_option Elab.async false
namespace Host.Load.Run.Full.Ordinary.VectorFactoryInventory
open Host.Ts Host.Ts.Owned Host.Ts.Owned.Parametric Host.Ts.Owned.Annotated
open Host.Mlx.Ffi Host.Mlx.Ffi.NativeRoles Host.Mlx.Ffi.Annotated

/-- An empty vector constructor introduces its fixed payload role at
the fresh handle. Host occurrence annotations and the graph policy survive. -/
theorem retained_from_source {notes : RetainedNotes}
    (ν₀ ν : Nat → F64) (C₀ C : CSrv) (R : Ren)
    (nodes : Nat → GraphNode) (boundary : Nat → Prop) (objects : Nat → Object)
    (roots H N : Nat → Prop) (tail : List NumV) (host : HostSt → HostSt → Prop)
    (live framed : Nat → Prop) (before after : List Val) (old old' : List Event) (s₀ s : Host.Ts.St LSt)
    (h : Parametric.StateR (NumberRoles ν₀ ν C₀ C)
      (VectorHost.NativeRelation ν₀ ν C₀ C nodes boundary objects H N tail host)
      R live framed before after old old' s₀ s)
    (inventory : RetainedInventory notes ν₀ ν C₀ C R live s₀ s)
    (policy : ProducerAnnotations roots H N nodes objects)
    (fn types : Nat) (function signatureObject : Host.Ts.Obj) (returns : Name) (receiver : Val)
    (control : s₀.ctl = .call (.obj fn) receiver [])
    (functionRead : s₀.heap.get fn = some (.obj function))
    (functionKind : function.kind = .fn (.native (.ffi .symbol) [.str chars!"mlx_vector_array_new",.obj types,.str returns]))
    (signatureRead : s₀.heap.get types = some (.obj signatureObject))
    (signatureKind : signatureObject.kind = .array []) (signatureFrame : ¬ framed types)
    (sourceBound : s₀.ffi.mlx.next < 2^64) (targetBound : s.ffi.mlx.next < 2^64) :
    let sourcePost := finishBig s₀ (Host.Load.Owned.newVector s₀.ffi) chars!"mlx_vector_array_new" [] (Int.ofNat s₀.ffi.mlx.next)
    let targetPost := finishBig s (Host.Load.Owned.newVector s.ffi) chars!"mlx_vector_array_new" [] (Int.ofNat s.ffi.mlx.next)
    let newObjects := objectWrite objects s₀.ffi.mlx.next (.vec [])
    let newHandles := fun i => i = s₀.ffi.mlx.next ∨ H i
    interpC (step Host.Load.ffi s₀).run C₀ = some (sourcePost,C₀) ∧
      interpC (step Host.Load.ffi s).run C = some (targetPost,C) ∧
      Parametric.StateR (NumberRoles ν₀ ν C₀ C)
        (VectorHost.NativeRelation ν₀ ν C₀ C nodes boundary newObjects newHandles N tail host)
        R live framed before after old old' sourcePost targetPost ∧
      RetainedInventory (notes.withRuntime {notes.runtime with control := returnNote (.handle s₀.ffi.mlx.next)})
        ν₀ ν C₀ C R live sourcePost targetPost ∧
      ProducerAnnotations roots newHandles N nodes newObjects ∧
      ProducerSupport roots newHandles N sourcePost.ffi.mlx ∧
      ProducerSupport (resourceImage R.node (fun i => N i ∧ roots i))
        (resourceImage R.handle newHandles) (resourceImage R.node N) targetPost.ffi.mlx := by
  dsimp only
  obtain ⟨left,right,post⟩ := VectorFactoryHost.from_source ν₀ ν C₀ C R nodes boundary objects H N tail host
    live framed before after old old' s₀ s h fn types function signatureObject returns receiver control functionRead
    functionKind signatureRead signatureKind signatureFrame sourceBound targetBound
  have targetReturn : (Annotated.Value.handle s₀.ffi.mlx.next).Holds ν C R (.big (Int.ofNat s.ffi.mlx.next)) := by
    rw [←h.native.2.handleMap.head]
    exact .handle _
  have runtime : RuntimeInventory {notes.runtime with control := returnNote (.handle s₀.ffi.mlx.next)} ν₀ ν C₀ C R live
      (finishBig s₀ (Host.Load.Owned.newVector s₀.ffi) chars!"mlx_vector_array_new" [] (Int.ofNat s₀.ffi.mlx.next))
      (finishBig s (Host.Load.Owned.newVector s.ffi) chars!"mlx_vector_array_new" [] (Int.ofNat s.ffi.mlx.next)) :=
    ⟨inventory.runtime.keyLive,
      ⟨returnNote_holds (.handle _),inventory.runtime.source.stack,inventory.runtime.source.cells⟩,
      ⟨returnNote_holds targetReturn,inventory.runtime.target.stack,inventory.runtime.target.cells⟩⟩
  have retained := inventory.heap_step runtime rfl rfl (.refl C₀) (.refl C)
  have updatedPolicy := policy.new_object s₀.ffi.mlx.next (.vec []) True.intro
  exact ⟨left,right,post,retained,updatedPolicy,updatedPolicy.source post.native.2,updatedPolicy.target post.native.2⟩

end Host.Load.Run.Full.Ordinary.VectorFactoryInventory
