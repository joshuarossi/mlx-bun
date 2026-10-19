import host.ts.renameOrdinary.RankOriginInitialCells

set_option Elab.async false
set_option maxRecDepth 1000000
namespace Host.Load.Run.Full.Ordinary.RankOrigin.DynamicSliceStartSeed
open Host.Ts Host.Ts.Owned Host.Ts.Owned.Parametric Host.Ts.Owned.Annotated

noncomputable def node : Nat := (PrivateSeed.native.arrs.get 18170).getD 0

/-- Class/private-field metadata and actual initialized native membership
identify this dynamic-slice start wrapper before the source loop begins. -/
theorem candidate : InitialArrayHandles.candidate input PrivateSeed.native PrivateSeed.prototype
    PrivateSeed.brand PrivateSeed.name 2674420 = some (18170,node) := by host_kernel_rfl

theorem native_array : PrivateSeed.native.arrs.get 18170 = some node := by host_kernel_rfl

theorem initial_note : PrivateSeed.notes.owners 2674420 = some ⟨4852,chars!"handle",.handle 18170⟩ := by
  have selected := InitialArrayHandles.entry input PrivateSeed.native PrivateSeed.live
    PrivateSeed.prototype PrivateSeed.brand PrivateSeed.name 2674420 18170 node
    (by rw [PrivateSeed.live,InitialClosure.source_address_limit]; decide +kernel) candidate
  simpa only [PrivateSeed.notes,PrivateSeed.brand_value,PrivateSeed.name_value] using selected

theorem entry_note (ic : Annotated.Tree) (is : List Annotated.Tree)
    (control : Annotated.Tree) (fnRole thisRole : Annotated.Value) (saved : Annotated.Tree)
    (caller : List Annotated.Tree) :
    (RankShapeRetained.EntryNotes (InitialRetained.notes ic is) control fnRole thisRole saved caller).privates.owners
      2674420 = some ⟨4852,chars!"handle",.handle 18170⟩ := initial_note

end Host.Load.Run.Full.Ordinary.RankOrigin.DynamicSliceStartSeed
