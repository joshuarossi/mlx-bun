import host.load.RuntimeNamespacedVectorEntry
import host.load.RuntimeVectorPreludeBatch
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Full.Ordinary.NamespacedVectorEntryBatch
open Host.Ts Host.Ts.Owned Host.Ts.Owned.Annotated

theorem final_notes_eq (notes : RetainedNotes) (caller : List Annotated.Tree) :
    finalNotes notes caller = RetainedVectorPreludeBatch.entryNotes notes caller := rfl

theorem end_live_eq (live : Nat → Prop) : endLive live = RetainedVectorEntryBatch.endLive live := rfl

theorem array_notes_eq (notes : RetainedNotes) (caller : List Annotated.Tree) :
    NamespacedMap.arrayNotes notes caller = RankOrigin.InitializedHandleArray.endNotes notes caller := rfl

end Host.Load.Run.Full.Ordinary.NamespacedVectorEntryBatch
