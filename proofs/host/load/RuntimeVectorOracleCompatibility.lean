import host.load.RuntimeVectorOracleReady
import host.load.RuntimeVectorReadyBatch

set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 1000000
namespace Host.Load.Run.Full.Ordinary.RetainedVectorOracleBatch
open Host.Ts Host.Ts.Owned Host.Ts.Owned.Annotated

/- Oracle namespacing changes symbolic server expressions, while these
inventories retain the same current occurrence meanings and native resources. -/
theorem entry_notes_eq (notes : RetainedNotes) (caller : List Annotated.Tree) :
    entryNotes notes caller = RetainedVectorPreludeBatch.entryNotes notes caller := rfl

theorem ready_notes_eq (notes : RetainedNotes) (caller : List Annotated.Tree) :
    readyNotes notes caller = RetainedVectorPreludeBatch.readyNotes notes caller := rfl

theorem ready_live_eq (live : Nat → Prop) :
    readyLive live = RetainedVectorPreludeBatch.readyLive live := rfl

end Host.Load.Run.Full.Ordinary.RetainedVectorOracleBatch
