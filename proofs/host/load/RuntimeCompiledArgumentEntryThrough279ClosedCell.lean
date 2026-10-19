import host.load.RuntimeCompiledArgumentEntryThrough279FirstStore
import host.mlx.NativeClosedArguments
set_option Elab.async false
namespace Host.Load.Run.Full.Ordinary.CompiledArgumentEntry
open Host.Ts Host.Ts.Owned Host.Ts.Owned.Parametric Host.Ts.Owned.Annotated

def literalCellNotes (notes : RetainedNotes) (address : Nat) (literal : F64) : RetainedNotes :=
  notes.withRuntime {notes.runtime with cells := notes.runtime.cells.write address (.literal (.lit literal))}

-- This reannotation reads the already-retained closed role in both heaps.
-- It requires no independent target value and executes no source transition.
theorem retained_closed_cell {S : Type} {notes : RetainedNotes} {ν₀ ν : Nat → F64}
    {C₀ C : CSrv} {R : Ren} {live : Nat → Prop} {source target : St S}
    (inventory : RetainedInventory notes ν₀ ν C₀ C R live source target)
    (address : Nat) (role : Annotated.Value) (literal : F64)
    (selected : notes.runtime.cells.cells address = some role)
    (closed : ClosedLiteralNote role)
    (sourceCell : cellValueAt source address = .num (.lit literal)) :
    RetainedInventory (literalCellNotes notes address literal) ν₀ ν C₀ C R live source target := by
  obtain ⟨alive,sourceRole,targetRole⟩ := inventory.runtime.cellInventory.selected address role selected
  rw [sourceCell] at sourceRole
  have sourceLiteral := closed.exact sourceRole sourceRole
  have targetLiteral := closed.exact sourceRole targetRole
  rw [← sourceCell] at sourceLiteral
  have cells := inventory.runtime.cellInventory.annotate address (.literal (.lit literal)) alive sourceLiteral targetLiteral
  exact ⟨⟨cells.keyLive,⟨inventory.runtime.source.control,inventory.runtime.source.stack,cells.source⟩,
    ⟨inventory.runtime.target.control,inventory.runtime.target.stack,cells.target⟩⟩,
    inventory.privates,inventory.captures,inventory.arrays,inventory.publicFields,inventory.buffers⟩
end Host.Load.Run.Full.Ordinary.CompiledArgumentEntry
