import host.mlx.NativeArrayFreeHost
import host.mlx.NativeAnnotationSupport
import host.mlx.NativeBufferInventory
import host.ts.RenameRetainedHeapFrame

set_option Elab.async false
namespace Host.Load.Run.Full.Ordinary.ArrayFreeInventory
open Host.Ts Host.Ts.Owned Host.Ts.Owned.Parametric Host.Ts.Owned.Annotated
open Host.Mlx.Ffi Host.Mlx.Ffi.NativeRoles Host.Mlx.Ffi.Annotated

/-- Disposal removes only the released array handle from native live support.
All host occurrence annotations retain their fixed meanings, while graph
nodes, other objects and their producer policy survive the original free. -/
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
    (fn types handle : Nat) (function signatureObject : Host.Ts.Obj) (returns : Name) (receiver : Val)
    (control : s₀.ctl = .call (.obj fn) receiver [.big (Int.ofNat handle)])
    (functionRead : s₀.heap.get fn = some (.obj function))
    (functionKind : function.kind = .fn (.native (.ffi .symbol) [.str chars!"mlx_array_free",.obj types,.str returns]))
    (signatureRead : s₀.heap.get types = some (.obj signatureObject))
    (signatureKind : signatureObject.kind = .array [.str chars!"u64"])
    (signatureFrame : ¬ framed types) (handleLive : H handle) (nonzero : handle ≠ 0)
    (sourceBound : handle < 2^64) (targetBound : s.ffi.mlx.next < 2^64)
    (fnRole thisRole : Annotated.Value)
    (controlNote : notes.runtime.control = callNote fnRole thisRole [.handle handle]) :
    let sourcePost := finishStatus s₀ (Host.Load.Owned.freeArray s₀.ffi handle) chars!"mlx_array_free" [.big (Int.ofNat handle)]
    let targetPost := finishStatus s (Host.Load.Owned.freeArray s.ffi (R.handle handle)) chars!"mlx_array_free" [.big (Int.ofNat (R.handle handle))]
    interpC (step Host.Load.ffi s₀).run C₀ = some (sourcePost,C₀) ∧
      interpC (step Host.Load.ffi s).run C = some (targetPost,C) ∧
      Parametric.StateR (NumberRoles ν₀ ν C₀ C)
        (VectorHost.NativeRelation ν₀ ν C₀ C nodes boundary objects (fun i => H i ∧ i ≠ handle) N tail host)
        R live framed before after old old' sourcePost targetPost ∧
      RetainedInventory (notes.withRuntime {notes.runtime with control := returnNote nativeStatusRole})
        ν₀ ν C₀ C R live sourcePost targetPost ∧
      ProducerAnnotations roots (fun i => H i ∧ i ≠ handle) N nodes objects ∧
      ProducerSupport roots (fun i => H i ∧ i ≠ handle) N sourcePost.ffi.mlx ∧
      ProducerSupport (resourceImage R.node (fun i => N i ∧ roots i))
        (resourceImage R.handle (fun i => H i ∧ i ≠ handle)) (resourceImage R.node N) targetPost.ffi.mlx := by
  dsimp only
  have role := (inventory.runtime.call_argument_role fnRole thisRole [.handle handle]
    (.obj fn) receiver _ control controlNote 0 (.handle handle) rfl).2
  obtain ⟨left,right,post⟩ := ArrayFreeHost.from_source ν₀ ν C₀ C R nodes boundary objects H N tail host
    live framed before after old old' s₀ s h fn types handle function signatureObject returns receiver
    control functionRead functionKind signatureRead signatureKind signatureFrame handleLive nonzero sourceBound targetBound role
  have runtime : RuntimeInventory {notes.runtime with control := returnNote nativeStatusRole} ν₀ ν C₀ C R live
      (finishStatus s₀ (Host.Load.Owned.freeArray s₀.ffi handle) chars!"mlx_array_free" [.big (Int.ofNat handle)])
      (finishStatus s (Host.Load.Owned.freeArray s.ffi (R.handle handle)) chars!"mlx_array_free" [.big (Int.ofNat (R.handle handle))]) :=
    ⟨inventory.runtime.keyLive,
      ⟨returnNote_holds (nativeStatusRole_holds ν₀ C₀ identity),inventory.runtime.source.stack,inventory.runtime.source.cells⟩,
      ⟨returnNote_holds (nativeStatusRole_holds ν C R),inventory.runtime.target.stack,inventory.runtime.target.cells⟩⟩
  have retained := inventory.heap_step runtime rfl rfl (.refl C₀) (.refl C)
  have updatedPolicy : ProducerAnnotations roots (fun i => H i ∧ i ≠ handle) N nodes objects :=
    ⟨fun i held => policy.objects i held.1,policy.roots,policy.nodes⟩
  exact ⟨left,right,post,retained,updatedPolicy,updatedPolicy.source post.native.2,updatedPolicy.target post.native.2⟩

end Host.Load.Run.Full.Ordinary.ArrayFreeInventory
