import host.mlx.NativeVectorFreeHost
import host.mlx.NativeBufferInventory
import host.ts.RenameRetainedInventory

set_option Elab.async false

namespace Host.Ts.Owned.Annotated
open Parametric

/-- The current argument note supplies the vector handle. The original free
branch leaves native resources intact and returns its fixed status, retaining
all host occurrence inventories and the complete native relation. -/
theorem RetainedInventory.vector_free_step {notes : RetainedNotes}
    {ν₀ ν : Nat → F64} {C₀ C : CSrv} {R : Ren}
    (FR : Ren → Host.Load.LSt → Host.Load.LSt → Prop)
    {live framed : Nat → Prop} {before after : List Val} {old old' : List Event} {s₀ s : St Host.Load.LSt}
    (inventory : RetainedInventory notes ν₀ ν C₀ C R live s₀ s)
    (h : Parametric.StateR (NumberRoles ν₀ ν C₀ C) FR R live framed before after old old' s₀ s)
    (fn types handle : Nat) (function signatureObject : Obj) (returns : Name) (receiver : Val)
    (control : s₀.ctl = .call (.obj fn) receiver [.big (Int.ofNat handle)])
    (read : s₀.heap.get fn = some (.obj function))
    (kind : function.kind = .fn (.native (.ffi .symbol) [.str chars!"mlx_vector_array_free",.obj types,.str returns]))
    (signatureRead : s₀.heap.get types = some (.obj signatureObject))
    (signatureKind : signatureObject.kind = .array [.str chars!"u64"]) (signatureFrame : ¬ framed types)
    (fnRole thisRole : Value) (note : notes.runtime.control = callNote fnRole thisRole [.handle handle]) :
    let sourcePost := finishStatus s₀ s₀.ffi chars!"mlx_vector_array_free" [.big (Int.ofNat handle)]
    let targetPost := finishStatus s s.ffi chars!"mlx_vector_array_free" [.big (Int.ofNat (R.handle handle))]
    interpC (step Host.Load.ffi s₀).run C₀ = some (sourcePost,C₀) ∧
      interpC (step Host.Load.ffi s).run C = some (targetPost,C) ∧
      Parametric.StateR (NumberRoles ν₀ ν C₀ C) FR R live framed before after old old' sourcePost targetPost ∧
      RetainedInventory (notes.withRuntime {notes.runtime with control := returnNote nativeStatusRole})
        ν₀ ν C₀ C R live sourcePost targetPost := by
  dsimp only
  have role := (inventory.runtime.call_argument_role fnRole thisRole [.handle handle] (.obj fn) receiver _ control note 0 (.handle handle) rfl).2
  have zero : NumberRoles ν₀ ν C₀ C zeroN zeroN := ⟨.lit (F64.zero false),⟨rfl,rfl⟩⟩
  obtain ⟨left,right,post⟩ := step_vector_free_from_source (NumberRoles ν₀ ν C₀ C) FR R C₀ C ν live framed before after old old'
    s₀ s h fn types handle function signatureObject returns receiver control read kind signatureRead signatureKind signatureFrame zero role
  have runtime : RuntimeInventory {notes.runtime with control := returnNote nativeStatusRole} ν₀ ν C₀ C R live
      (finishStatus s₀ s₀.ffi chars!"mlx_vector_array_free" [.big (Int.ofNat handle)])
      (finishStatus s s.ffi chars!"mlx_vector_array_free" [.big (Int.ofNat (R.handle handle))]) :=
    ⟨inventory.runtime.keyLive,⟨returnNote_holds (nativeStatusRole_holds ν₀ C₀ identity),inventory.runtime.source.stack,inventory.runtime.source.cells⟩,
      ⟨returnNote_holds (nativeStatusRole_holds ν C R),inventory.runtime.target.stack,inventory.runtime.target.cells⟩⟩
  exact ⟨left,right,post,runtime,
    inventory.privates.frame (fun _ alive => alive) (fun _ _ _ => rfl) (fun _ _ _ => rfl),
    inventory.captures.frame (fun _ alive => alive) (fun _ _ _ => rfl) (fun _ _ _ => rfl),
    inventory.arrays.frame (fun _ alive => alive) (fun _ _ _ => rfl) (fun _ _ _ => rfl),
    inventory.publicFields.frame (fun _ alive => alive) (fun _ _ _ _ => rfl) (fun _ _ _ _ => rfl),
    inventory.buffers.frame (fun _ alive => alive) (fun _ _ _ => rfl) (fun _ _ _ => rfl)⟩

end Host.Ts.Owned.Annotated
