import host.ts.RenameBufferInventory
import host.ts.RenameRuntimePureEffects

set_option Elab.async false
namespace Host.Ts.Owned.Annotated

theorem BufferInventory.pure_effects {S : Type} {notes : BufferNotes} {ν₀ ν : Nat → F64}
    {C₀ C D₀ D : CSrv} {R : Ren} {live : Nat → Prop} {s₀ s result₀ result : St S}
    (inventory : BufferInventory notes ν₀ ν C₀ C R live s₀ s)
    (source : RuntimePureEffects s₀ result₀) (target : RuntimePureEffects s result)
    (sourceExtension : TableExtends C₀ D₀) (targetExtension : TableExtends C D) :
    BufferInventory notes ν₀ ν D₀ D R live result₀ result :=
  (inventory.mono sourceExtension targetExtension).frame (fun _ held => held)
    (by intro a _ _; rw [source.heap])
    (by intro a _ _; rw [target.heap])

end Host.Ts.Owned.Annotated
