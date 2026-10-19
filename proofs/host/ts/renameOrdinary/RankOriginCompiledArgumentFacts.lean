import host.ts.renameOrdinary.RankOriginInitializedPostConcatFree
import host.load.RuntimeCompiledArgumentEntryClosures
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 1000000
namespace Host.Load.Run.Full.Ordinary.RankOrigin.CompiledArgumentFacts
open Host.Ts Host.Ts.Owned Host.Ts.Owned.Parametric Host.Ts.Owned.Annotated
open NamespacedDecode
noncomputable def inputNotes := InitializedPostConcatFree.resultNotes
def cellRole : Annotated.Value := .obj 2672303
def receiverRole : Annotated.Value := .obj 329095

theorem source_entry : CompiledArgumentEntry.Region.s0 = Free2056.output := by host_kernel_rfl
theorem source_server : CompiledArgumentEntry.Head.Span0.Block0.initialServer = Free2056.nextServer := by
  host_kernel_rfl
theorem source_receiver : input.heap.get 329097 = some (.cell (some (.obj 329095))) := by host_kernel_rfl
theorem initial_receiver : InitialRetained.cells.cells 329097 = some receiverRole :=
  InitialCells.object_entry _ _
    (by rw [InitialRetained.live,InitialClosure.source_address_limit]; decide +kernel)
    source_receiver (by decide +kernel)
theorem current_control (notes : RetainedNotes) (caller : List Annotated.Tree) :
    (inputNotes notes caller).runtime.control = returnNote nativeStatusRole := by host_kernel_rfl
theorem current_cell (ic : Annotated.Tree) (is : List Annotated.Tree)
    (control : Annotated.Tree) (fnRole thisRole : Annotated.Value)
    (saved : Annotated.Tree) (caller : List Annotated.Tree) :
    (inputNotes (RankShapeRetained.EntryNotes (InitializedCache.entryNotes ic is)
      control fnRole thisRole saved caller) caller).runtime.cells.cells
      CompiledArgumentEntry.Head.Span4.Block7.sourceAddress = some cellRole := by
  calc
    _ = (InitialRetained.cells.cells 3126589).map (Annotated.Value.subst LoopVariables.oracleVariables) := by
      host_kernel_rfl
    _ = some cellRole := by rw [PostConcatFacts.initial_outer]; rfl
theorem current_receiver (ic : Annotated.Tree) (is : List Annotated.Tree)
    (control : Annotated.Tree) (fnRole thisRole : Annotated.Value)
    (saved : Annotated.Tree) (caller : List Annotated.Tree) :
    (inputNotes (RankShapeRetained.EntryNotes (InitializedCache.entryNotes ic is)
      control fnRole thisRole saved caller) caller).runtime.cells.cells
      CompiledArgumentEntry.From12.Span12.Block24.sourceAddress = some receiverRole := by
  calc
    _ = (InitialRetained.cells.cells 329097).map (Annotated.Value.subst LoopVariables.oracleVariables) := by
      host_kernel_rfl
    _ = some receiverRole := by rw [initial_receiver]; rfl

end Host.Load.Run.Full.Ordinary.RankOrigin.CompiledArgumentFacts
