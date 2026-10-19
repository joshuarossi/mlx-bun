import host.ts.RenameStateFootprint
import host.ts.RenameRetainedInventory

set_option Elab.async false
namespace Host.Ts.Owned.Annotated
open Parametric

/-- Source-only root obligations for retaining every existing annotation in
a smaller footprint. No target or later execution occurs in this predicate. -/
structure RetainedFootprint {S : Type} (notes : RetainedNotes) (live : Nat → Prop) (source : St S) : Prop where
  cells : notes.runtime.cells.Live live
  privates : notes.privates.Live live
  captures : notes.captures.Live live
  arrays : ∀ a roles, notes.arrays.owners a = some roles → live a
  arrayContents : notes.arrays.Closed live source
  publicFields : notes.publicFields.Live live
  buffers : ∀ a roles, notes.buffers.owners a = some roles → live a

/-- All six inventories retain their exact occurrence meanings when their
source roots and annotated array contents fit in the smaller footprint. -/
theorem RetainedInventory.restrict_live {S : Type} {notes : RetainedNotes}
    {ν₀ ν : Nat → F64} {C₀ C : CSrv} {R : Ren} {live small : Nat → Prop}
    {source target : St S}
    (inventory : RetainedInventory notes ν₀ ν C₀ C R live source target)
    (roots : RetainedFootprint notes small source) :
    RetainedInventory notes ν₀ ν C₀ C R small source target :=
  ⟨⟨roots.cells,inventory.runtime.source,inventory.runtime.target⟩,
    ⟨roots.privates,inventory.privates.source,inventory.privates.target⟩,
    ⟨roots.captures,inventory.captures.source,inventory.captures.target⟩,
    ⟨roots.arrays,inventory.arrays.source,inventory.arrays.target,roots.arrayContents⟩,
    ⟨roots.publicFields,inventory.publicFields.source,inventory.publicFields.target⟩,
    ⟨roots.buffers,inventory.buffers.source,inventory.buffers.target⟩⟩

/-- Discard only allocations excluded by a checked source closure. The full
state and all six inventories remain related, with unchanged resource maps,
fresh-counter laws, numeric meanings, native state and caller prefixes. -/
theorem RetainedInventory.restrict_state {S : Type} {notes : RetainedNotes}
    {ν₀ ν : Nat → F64} {C₀ C : CSrv} {R : Ren} {FR : Ren → S → S → Prop}
    {live small framed : Nat → Prop} {before after : List Val} {old old' : List Event}
    {source target : St S}
    (inventory : RetainedInventory notes ν₀ ν C₀ C R live source target)
    (state : Parametric.StateR (NumberRoles ν₀ ν C₀ C) FR R live framed before after old old' source target)
    (roots : RetainedFootprint notes small source)
    (subset : ∀ a, small a → live a)
    (closed : ∀ a, small a → SlotSupport small framed before a (source.heap.get a))
    (framedLive : ∀ a, framed a → small a)
    (control : treeSupport small (Encode.ctl source.ctl))
    (stack : listSupport (fun f => treeSupport small (Encode.frame f)) source.stack)
    (jobs : listSupport (fun j => treeSupport small (Encode.job j)) source.jobs)
    (stores : treeSupport small (Encode.stores source.stores)) :
    Parametric.StateR (NumberRoles ν₀ ν C₀ C) FR R small framed before after old old' source target ∧
      RetainedInventory notes ν₀ ν C₀ C R small source target :=
  ⟨state.restrict_live subset closed framedLive control stack jobs stores,inventory.restrict_live roots⟩

end Host.Ts.Owned.Annotated
