import host.ts.RenameHeapInventory
import host.ts.RenamePrivateKindFrame
import host.ts.RenameCaptureKindFrame
set_option Elab.async false
namespace Host.Ts.Owned.Annotated
open Parametric

/-- Array mutations change the retained elements but preserve lexical-cell,
private-descriptor and native-capture annotations, including private fields
whose owner is the array being updated. -/
theorem HeapInventory.setArray {S : Type} {notes : HeapNotes} {ν₀ ν : Nat → F64} {C₀ C : CSrv} {R : Ren}
    {live framed : Nat → Prop} {before after : List Val} {s₀ s : St S}
    (inventory : HeapInventory notes ν₀ ν C₀ C R live s₀ s)
    (heap : Parametric.HeapR (NumberRoles ν₀ ν C₀ C) R live framed before after s₀ s)
    (a : Nat) (o₀ o : Obj) (oldValues values₀ values : List Val) (v₀ v : Val) (alive : live a)
    (sourceObject : s₀.heap.get a = some (.obj o₀)) (sourceKind : o₀.kind = .array oldValues)
    (targetObject : s.heap.get (R.a a) = some (.obj o))
    (sourceBound : a < 2^64) (targetBound : R.a a < 2^64) :
    HeapInventory notes ν₀ ν C₀ C R live
      ((s₀.setObj a {o₀ with kind := .array values₀}).ret v₀)
      ((s.setObj (R.a a) {o with kind := .array values}).ret v) := by
  refine ⟨inventory.cells.setObject heap a o₀ o _ _ v₀ v alive sourceObject targetObject sourceBound targetBound,?_,?_⟩
  · exact (inventory.privates.setKind a o₀ o (.array values₀) (.array values)
      sourceObject targetObject sourceBound targetBound).frame (fun _ h => h) (fun _ _ _ => rfl) (fun _ _ _ => rfl)
  · apply inventory.captures.setNonNativeKind heap a o₀ _ _ v₀ v alive sourceObject ?_ sourceBound targetBound
    intro code data impossible
    rw [sourceKind] at impossible
    cases impossible
end Host.Ts.Owned.Annotated
