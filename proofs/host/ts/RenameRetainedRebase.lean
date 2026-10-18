import host.ts.RenameRetainedInventory
import host.ts.RenameRuntimeRebase
import host.ts.RenamePrivateRebase
import host.ts.RenameCaptureRebase
import host.ts.RenameArrayRebase
import host.ts.RenamePublicRebase
import host.ts.RenameBufferRebase
set_option Elab.async false
namespace Host.Ts.Owned.Annotated
open Parametric

def RetainedNotes.subst (notes : RetainedNotes) (θ : Nat → SymE) : RetainedNotes :=
  ⟨notes.runtime.subst θ,notes.privates.mapRoles (Value.subst θ),notes.captures.mapRoles (Value.subst θ),
    notes.arrays.mapRoles (Value.subst θ),notes.publicFields.mapRoles (Value.subst θ),notes.buffers.mapRoles (Byte.subst θ)⟩

theorem RetainedInventory.subst {S : Type} {notes : RetainedNotes} {ν₀ ν : Nat → F64}
    {C₀ C : CSrv} {R : Ren} {live : Nat → Prop} {s₀ s : St S} (θ : Nat → SymE)
    (inventory : RetainedInventory notes (nextValuation θ ν₀) (nextValuation θ ν) C₀ C R live s₀ s) :
    RetainedInventory (notes.subst θ) ν₀ ν C₀ C R live s₀ s :=
  ⟨inventory.runtime.subst θ,inventory.privates.subst θ,inventory.captures.subst θ,
    inventory.arrays.subst θ,inventory.publicFields.subst θ,inventory.buffers.subst θ⟩

/-- One side of the six-family inventory, for composing a source template with
the reached next cut. Live-key and producer-support invariants remain separate
obligations of the full state relation. -/
structure RetainedNotes.Holds {S : Type} (notes : RetainedNotes) (ν : Nat → F64) (C : CSrv) (R : Ren)
    (s : St S) : Prop where
  runtime : notes.runtime.Holds ν C R s
  privates : notes.privates.Holds ν C R s
  captures : notes.captures.Holds ν C R s
  arrays : notes.arrays.Holds ν C R s
  publicFields : notes.publicFields.Holds ν C R s
  buffers : notes.buffers.Holds ν C R s

theorem RetainedInventory.sourceHolds {S : Type} {notes : RetainedNotes} {ν₀ ν : Nat → F64}
    {C₀ C : CSrv} {R : Ren} {live : Nat → Prop} {s₀ s : St S}
    (inventory : RetainedInventory notes ν₀ ν C₀ C R live s₀ s) : notes.Holds ν₀ C₀ identity s₀ :=
  ⟨inventory.runtime.source,inventory.privates.source,inventory.captures.source,
    inventory.arrays.source,inventory.publicFields.source,inventory.buffers.source⟩
theorem RetainedInventory.targetHolds {S : Type} {notes : RetainedNotes} {ν₀ ν : Nat → F64}
    {C₀ C : CSrv} {R : Ren} {live : Nat → Prop} {s₀ s : St S}
    (inventory : RetainedInventory notes ν₀ ν C₀ C R live s₀ s) : notes.Holds ν C R s :=
  ⟨inventory.runtime.target,inventory.privates.target,inventory.captures.target,
    inventory.arrays.target,inventory.publicFields.target,inventory.buffers.target⟩

structure RetainedNotes.RenameCovers (notes renamed : RetainedNotes) (K : Ren) : Prop where
  runtime : notes.runtime.RenameCovers renamed.runtime K
  privates : notes.privates.RenameCovers renamed.privates K
  captures : notes.captures.RenameCovers renamed.captures K
  arrays : notes.arrays.RenameCovers renamed.arrays K
  publicFields : notes.publicFields.RenameCovers renamed.publicFields K
  buffers : notes.buffers.RenameCovers renamed.buffers K

/-- All retained source-template meanings use one common resource map and
next-iteration numeric substitution. Matching the reached notes is required;
the theorem does not assume or manufacture another iteration's execution. -/
theorem RetainedNotes.Holds.rebase {S : Type} {notes renamed : RetainedNotes} {ν : Nat → F64}
    {C : CSrv} {R : Ren} {s : St S} (K : Ren) (θ : Nat → SymE)
    (covers : notes.RenameCovers renamed K) (held : (renamed.subst θ).Holds ν C R s) :
    notes.Holds (nextValuation θ ν) C (composeResources R K) s :=
  ⟨RuntimeNotes.Holds.rebase K θ covers.runtime held.runtime,
    PrivateNotes.Holds.rebase K θ covers.privates held.privates,
    NativeCaptureNotes.Holds.rebase K θ covers.captures held.captures,
    ArrayNotes.Holds.rebase K θ covers.arrays held.arrays,
    PublicNotes.Holds.rebase K θ covers.publicFields held.publicFields,
    BufferNotes.Holds.rebase K θ covers.buffers held.buffers⟩
end Host.Ts.Owned.Annotated
