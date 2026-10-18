import host.mlx.NativeConfigFreeHost
import host.mlx.NativeBufferInventory
import host.ts.RenameRetainedHeapFrame

set_option Elab.async false
namespace Host.Ts.Owned.Annotated
open Parametric

/-- The original configuration-free model returns undefined and keeps its
native stores. The current handle meaning and all six inventories survive. -/
theorem RetainedInventory.config_free_step {notes : RetainedNotes}
    {ν₀ ν : Nat → F64} {C₀ C : CSrv} {R : Ren}
    {live framed : Nat → Prop} {before after : List Val} {old old' : List Event}
    {s₀ s : St Host.Load.LSt}
    (inventory : RetainedInventory notes ν₀ ν C₀ C R live s₀ s)
    (FR : Ren → Host.Load.LSt → Host.Load.LSt → Prop)
    (h : Parametric.StateR (NumberRoles ν₀ ν C₀ C) FR R live framed before after old old' s₀ s)
    (fn types handle : Nat) (function signatureObject : Obj) (returns : Name) (receiver : Val)
    (control : s₀.ctl = .call (.obj fn) receiver [.big (Int.ofNat handle)])
    (functionRead : s₀.heap.get fn = some (.obj function))
    (functionKind : function.kind = .fn (.native (.ffi .symbol) [.str chars!"mlx_fast_metal_kernel_config_free",.obj types,.str returns]))
    (signatureRead : s₀.heap.get types = some (.obj signatureObject))
    (signatureKind : signatureObject.kind = .array [.str chars!"u64"]) (signatureFrame : ¬ framed types)
    (fnRole thisRole : Value)
    (controlNote : notes.runtime.control = callNote fnRole thisRole [.handle handle]) :
    let sourcePost := finishVoid s₀ s₀.ffi chars!"mlx_fast_metal_kernel_config_free" [.big (Int.ofNat handle)]
    let targetPost := finishVoid s s.ffi chars!"mlx_fast_metal_kernel_config_free" [.big (Int.ofNat (R.handle handle))]
    interpC (step Host.Load.ffi s₀).run C₀ = some (sourcePost,C₀) ∧
      interpC (step Host.Load.ffi s).run C = some (targetPost,C) ∧
      Parametric.StateR (NumberRoles ν₀ ν C₀ C) FR R live framed before after old old' sourcePost targetPost ∧
      RetainedInventory (notes.withRuntime {notes.runtime with control := returnNote .undef})
        ν₀ ν C₀ C R live sourcePost targetPost := by
  dsimp only
  have role := (inventory.runtime.call_argument_role fnRole thisRole [.handle handle]
    (.obj fn) receiver _ control controlNote 0 (.handle handle) rfl).2
  obtain ⟨left,right,post⟩ := step_config_free_from_source (NumberRoles ν₀ ν C₀ C) FR R C₀ C ν live framed
    before after old old' s₀ s h fn types handle function signatureObject returns receiver control functionRead
    functionKind signatureRead signatureKind signatureFrame role
  have runtime : RuntimeInventory {notes.runtime with control := returnNote .undef} ν₀ ν C₀ C R live
      (finishVoid s₀ s₀.ffi chars!"mlx_fast_metal_kernel_config_free" [.big (Int.ofNat handle)])
      (finishVoid s s.ffi chars!"mlx_fast_metal_kernel_config_free" [.big (Int.ofNat (R.handle handle))]) :=
    ⟨inventory.runtime.keyLive,
      ⟨returnNote_holds .undef,inventory.runtime.source.stack,inventory.runtime.source.cells⟩,
      ⟨returnNote_holds .undef,inventory.runtime.target.stack,inventory.runtime.target.cells⟩⟩
  exact ⟨left,right,post,inventory.heap_step runtime rfl rfl (.refl C₀) (.refl C)⟩

end Host.Ts.Owned.Annotated
