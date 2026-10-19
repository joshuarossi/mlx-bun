import host.ts.renameOrdinary.RankOriginCompiledArgumentFacts
import host.ts.renameOrdinary.RankOriginInitializedCacheConcatEntry

set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 1000000
namespace Host.Load.Run.Full.Ordinary.RankOrigin.CompiledArgumentInputFacts
open Host.Ts Host.Ts.Owned Host.Ts.Owned.Parametric Host.Ts.Owned.Annotated

theorem weight_candidate : InitialArrayHandles.candidate input PrivateSeed.native PrivateSeed.prototype
    PrivateSeed.brand PrivateSeed.name 221129 = some (40,10) := by host_kernel_rfl

theorem bias_candidate : InitialArrayHandles.candidate input PrivateSeed.native PrivateSeed.prototype
    PrivateSeed.brand PrivateSeed.name 221295 = some (41,11) := by host_kernel_rfl

theorem weight_initial : PrivateSeed.notes.owners 221129 = some ⟨4852,chars!"handle",.handle 40⟩ := by
  have selected := InitialArrayHandles.entry input PrivateSeed.native PrivateSeed.live
    PrivateSeed.prototype PrivateSeed.brand PrivateSeed.name 221129 40 10
    (by rw [PrivateSeed.live,InitialClosure.source_address_limit]; decide +kernel) weight_candidate
  simpa only [PrivateSeed.notes,PrivateSeed.brand_value,PrivateSeed.name_value] using selected

theorem bias_initial : PrivateSeed.notes.owners 221295 = some ⟨4852,chars!"handle",.handle 41⟩ := by
  have selected := InitialArrayHandles.entry input PrivateSeed.native PrivateSeed.live
    PrivateSeed.prototype PrivateSeed.brand PrivateSeed.name 221295 41 11
    (by rw [PrivateSeed.live,InitialClosure.source_address_limit]; decide +kernel) bias_candidate
  simpa only [PrivateSeed.notes,PrivateSeed.brand_value,PrivateSeed.name_value] using selected

noncomputable def entryNotes (ic : Annotated.Tree) (is : List Annotated.Tree)
    (control : Annotated.Tree) (fnRole thisRole : Annotated.Value) (saved : Annotated.Tree)
    (caller : List Annotated.Tree) : RetainedNotes :=
  CompiledArgumentFacts.inputNotes (RankShapeRetained.EntryNotes (InitializedCache.entryNotes ic is)
    control fnRole thisRole saved caller) caller

theorem current_constructor (ic : Annotated.Tree) (is : List Annotated.Tree)
    (control : Annotated.Tree) (fnRole thisRole : Annotated.Value) (saved : Annotated.Tree)
    (caller : List Annotated.Tree) :
    (entryNotes ic is control fnRole thisRole saved caller).captures.owners 95 =
      some InitializedHandleBuffer.constructorMetadata := by
  change (RankShapeRetained.EntryNotes (InitializedCache.entryNotes ic is)
    control fnRole thisRole saved caller).captures.owners 95 = _
  exact InitializedCacheConcatEntry.constructor_selected ic is control fnRole thisRole saved caller

theorem current_weight (ic : Annotated.Tree) (is : List Annotated.Tree)
    (control : Annotated.Tree) (fnRole thisRole : Annotated.Value) (saved : Annotated.Tree)
    (caller : List Annotated.Tree) :
    (entryNotes ic is control fnRole thisRole saved caller).privates.owners 221129 =
      some ⟨4852,chars!"handle",.handle 40⟩ := by
  calc
    _ = (PrivateSeed.notes.owners 221129).map (fun note => note.mapRole (Annotated.Value.subst LoopVariables.oracleVariables)) := by host_kernel_rfl
    _ = _ := by rw [weight_initial]; rfl

theorem current_bias (ic : Annotated.Tree) (is : List Annotated.Tree)
    (control : Annotated.Tree) (fnRole thisRole : Annotated.Value) (saved : Annotated.Tree)
    (caller : List Annotated.Tree) :
    (entryNotes ic is control fnRole thisRole saved caller).privates.owners 221295 =
      some ⟨4852,chars!"handle",.handle 41⟩ := by
  calc
    _ = (PrivateSeed.notes.owners 221295).map (fun note => note.mapRole (Annotated.Value.subst LoopVariables.oracleVariables)) := by host_kernel_rfl
    _ = _ := by rw [bias_initial]; rfl

theorem current_input (ic : Annotated.Tree) (is : List Annotated.Tree)
    (control : Annotated.Tree) (fnRole thisRole : Annotated.Value) (saved : Annotated.Tree)
    (caller : List Annotated.Tree) :
    (entryNotes ic is control fnRole thisRole saved caller).privates.owners 3126874 =
      some ⟨4852,chars!"handle",.handle 29375⟩ := by host_kernel_rfl

end Host.Load.Run.Full.Ordinary.RankOrigin.CompiledArgumentInputFacts
