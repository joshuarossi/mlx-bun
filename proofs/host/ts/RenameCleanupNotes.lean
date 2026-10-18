import host.ts.RenameParametricCleanup
import host.ts.RenameRetainedHeapFrame

set_option Elab.async false
namespace Host.Ts.Owned.Annotated
open Parametric

def cleanupCompletionNote : Tree → Tree
  | .node "Ctl.ret" values => .node "Comp.normal" values
  | .node "Ctl.abr" values => .node "Comp.abrupt" values
  | other => other

def cleanupControlNote : Tree → Tree
  | .node "Comp.normal" values => .node "Ctl.ret" values
  | .node "Comp.abrupt" values => .node "Ctl.abr" values
  | other => other

def cleanupScopeNote (resources : Tree) : Tree := .node "Frame.s" [.node "StmtF.scope" [resources]]
def cleanupDisposeNote (resources pending : Tree) : Tree := .node "Frame.s" [.node "StmtF.dispose" [resources,pending]]

/-- Move existing occurrence notes, without choosing new meanings for the
resource, method or saved normal/abrupt completion. -/
def RuntimeNotes.cleanup (notes : RuntimeNotes) (resources pending : Tree) (tail : List Tree) : RuntimeNotes :=
  match resources with
  | .node "List" [] => {notes with control := cleanupControlNote pending,stack := tail}
  | .node "List" (.node "pair" [resource,method]::rest) =>
      {notes with control := .node "Ctl.call" [method,resource,.node "List" []],stack := cleanupDisposeNote (.node "List" rest) pending::tail}
  | _ => notes

theorem RuntimeNotes.cleanup_cells (notes : RuntimeNotes) (resources pending : Tree) (tail : List Tree) :
    (notes.cleanup resources pending tail).cells = notes.cells := by
  unfold RuntimeNotes.cleanup
  split <;> rfl

theorem cleanupCompletionNote_holds {ν : Nat → F64} {C : CSrv} {R : Ren} {note : Tree} {pending : Comp}
    (held : note.Holds ν C R (Encode.ctl (completionControl pending))) :
    (cleanupCompletionNote note).Holds ν C R (Encode.comp pending) := by
  cases pending <;> cases held with | node tag fields => exact .node _ fields

theorem cleanupControlNote_holds {ν : Nat → F64} {C : CSrv} {R : Ren} {note : Tree} {pending : Comp}
    (held : note.Holds ν C R (Encode.comp pending)) :
    (cleanupControlNote note).Holds ν C R (Encode.ctl (completionControl pending)) := by
  cases pending <;> cases held with | node tag fields => exact .node _ fields

theorem cleanupScopeNote_view {ν : Nat → F64} {C : CSrv} {R : Ren} {note : Tree} {resources : List (Val × Val)}
    (held : (cleanupScopeNote note).Holds ν C R (Encode.frame (.s (.scope resources)))) :
    note.Holds ν C R (Encode.pairs resources) := by
  cases held with | node tag fields => cases fields with | cons inner fields =>
    cases inner with | node tag fields => cases fields with | cons pairs fields => exact pairs

theorem cleanupDisposeNote_view {ν : Nat → F64} {C : CSrv} {R : Ren} {pairs pending : Tree}
    {resources : List (Val × Val)} {completion : Comp}
    (held : (cleanupDisposeNote pairs pending).Holds ν C R (Encode.frame (.s (.dispose resources completion)))) :
    pairs.Holds ν C R (Encode.pairs resources) ∧ pending.Holds ν C R (Encode.comp completion) := by
  cases held with | node tag fields => cases fields with | cons inner fields =>
    cases inner with | node tag fields => cases fields with | cons pairs fields =>
      cases fields with | cons pending fields => exact ⟨pairs,pending⟩

/-- The note transformation follows exactly the interpreter's next-resource or
resume branch. Both branches retain all untouched saved frames and cells. -/
theorem RuntimeNotes.cleanup_holds {S : Type} {notes : RuntimeNotes} {ν : Nat → F64} {C : CSrv} {R : Ren}
    {s : St S} {frames : List Frame} {resources : List (Val × Val)} {pending : Comp}
    {resourceNotes pendingNote : Tree} {tail : List Tree}
    (pairs : resourceNotes.Holds ν C R (Encode.pairs resources))
    (completion : pendingNote.Holds ν C R (Encode.comp pending))
    (saved : ForestHolds ν C R tail (frames.map Encode.frame)) (cells : notes.cells.Holds ν C R s) :
    (notes.cleanup resourceNotes pendingNote tail).Holds ν C R (cleanupNext {s with stack := frames} resources pending) := by
  cases resources with
  | nil =>
    cases pairs with | node tag fields =>
      cases fields
      simp only [RuntimeNotes.cleanup,cleanupNext,resume_control]
      exact ⟨cleanupControlNote_holds completion,saved,cells⟩
  | cons head rest =>
    rcases head with ⟨resource,method⟩
    cases pairs with | node tag fields => cases fields with | cons pair pairs =>
      cases pair with | node tag fields => cases fields with | cons resourceHeld fields =>
        cases fields with | cons methodHeld fields =>
          cases fields
          exact ⟨.node _ (.cons methodHeld (.cons resourceHeld (.cons (.node _ .nil) .nil))),
            .cons (.node _ (.cons (.node _ (.cons (.node _ pairs) (.cons completion .nil))) .nil)) saved,cells⟩

end Host.Ts.Owned.Annotated
