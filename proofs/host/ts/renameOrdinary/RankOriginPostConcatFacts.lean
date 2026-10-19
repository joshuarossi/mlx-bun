import host.ts.renameOrdinary.RankOriginInitializedConvolutionFree
import host.load.RuntimePostConcatCleanup

set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 1000000
namespace Host.Load.Run.Full.Ordinary.RankOrigin.PostConcatFacts
open Host.Ts Host.Ts.Owned Host.Ts.Owned.Parametric Host.Ts.Owned.Annotated
open NamespacedDecode

noncomputable def inputNotes := InitializedConvolutionFree.resultNotes
def outerRole : Annotated.Value := .obj 2672303
def localRole : Annotated.Value := .null

theorem source_outer : input.heap.get 3126589 = some (.cell (some (.obj 2672303))) := by host_kernel_rfl
theorem source_local : input.heap.get 3126600 = some (.cell (some .null)) := by host_kernel_rfl
theorem initial_outer : InitialRetained.cells.cells 3126589 = some outerRole :=
  InitialCells.object_entry _ _
    (by rw [InitialRetained.live,InitialClosure.source_address_limit]; decide +kernel)
    source_outer (by decide +kernel)
theorem initial_local : InitialRetained.cells.cells 3126600 = some localRole := by
  have other : 3126600 ≠ Parameter45.address := by decide +kernel
  simp only [InitialRetained.cells,Notes.write,ite_eq_right other]
  exact structuralCells.entry
    (by rw [InitialRetained.live,InitialClosure.source_address_limit]; decide +kernel) source_local rfl

theorem source_entry : PostConcatCleanup.Region.s0 = Free1978.output := by host_kernel_rfl
theorem source_server : PostConcatCleanup.Before.Block0.initialServer = Free1978.nextServer := by
  host_kernel_rfl
theorem current_control (notes : RetainedNotes) (caller : List Annotated.Tree) :
    (inputNotes notes caller).runtime.control = returnNote nativeStatusRole := by host_kernel_rfl
theorem current_outer (ic : Annotated.Tree) (is : List Annotated.Tree)
    (control : Annotated.Tree) (fnRole thisRole : Annotated.Value)
    (saved : Annotated.Tree) (caller : List Annotated.Tree) :
    (inputNotes (RankShapeRetained.EntryNotes (InitializedCache.entryNotes ic is)
      control fnRole thisRole saved caller) caller).runtime.cells.cells PostConcatCleanup.Mid.Block25.sourceAddress =
      some outerRole := by
  calc
    _ = (InitialRetained.cells.cells 3126589).map (Annotated.Value.subst LoopVariables.oracleVariables) := by
      host_kernel_rfl
    _ = some outerRole := by rw [initial_outer]; rfl
theorem current_local (ic : Annotated.Tree) (is : List Annotated.Tree)
    (control : Annotated.Tree) (fnRole thisRole : Annotated.Value)
    (saved : Annotated.Tree) (caller : List Annotated.Tree) :
    (inputNotes (RankShapeRetained.EntryNotes (InitializedCache.entryNotes ic is)
      control fnRole thisRole saved caller) caller).runtime.cells.cells PostConcatCleanup.AfterA.Block31.address =
      some localRole := by
  calc
    _ = (InitialRetained.cells.cells 3126600).map (Annotated.Value.subst LoopVariables.oracleVariables) := by
      host_kernel_rfl
    _ = some localRole := by rw [initial_local]; rfl
theorem current_handle (ic : Annotated.Tree) (is : List Annotated.Tree)
    (control : Annotated.Tree) (fnRole thisRole : Annotated.Value)
    (saved : Annotated.Tree) (caller : List Annotated.Tree) :
    (inputNotes (RankShapeRetained.EntryNotes (InitializedCache.entryNotes ic is)
      control fnRole thisRole saved caller) caller).privates.owners PostConcatCleanup.DisposedStore.sourceAddress =
      some ⟨PostConcatCleanup.AfterB.Block75.sourceBrand,PostConcatCleanup.AfterB.Block75.sourceName,
        .handle 25732⟩ := by
  change (PrivateSeed.notes.owners 2978923).map
    (fun note => {note with role := note.role.subst LoopVariables.oracleVariables}) = _
  rw [PrivateSeed.first_entry]
  rfl

theorem intrinsic_live (a : Nat) (small : a < 100) : InitializedConvolutionFree.live a := by
  unfold InitializedConvolutionFree.live InitializedConvolutionFreeEntry.live
    InitializedConvolutionFreeEntry.connectedLive InitializedConvolutionCleanup.live
    InitializedConvolutionCleanup.connectedLive
  repeat first | apply CellsLive.grow | apply ClosureLive.grow | apply Or.inl
  rw [InitialRetained.live,InitialClosure.source_address_limit]
  omega

end Host.Load.Run.Full.Ordinary.RankOrigin.PostConcatFacts
