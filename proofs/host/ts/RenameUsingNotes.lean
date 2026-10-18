import host.ts.RenameUsingScope
import host.ts.RenameRuntimeBinding

set_option Elab.async false
namespace Host.Ts.Owned.Parametric

theorem ScopeAt.transport {NR : NumV → NumV → Prop} {R : Ren} :
    ∀ (source target : List Frame) (index : Nat), ListR (FrameR NR R) source target → ScopeAt source index → ScopeAt target index := by
  intro source
  induction source with
  | nil => intro target index _ scope; cases index <;> contradiction
  | cons head rest ih =>
    intro target index related scope
    cases related with | cons h hs =>
      cases index with
      | zero =>
        cases head <;> try contradiction
        case s st =>
          cases st <;> try contradiction
          case scope resources => obtain ⟨_,rfl,_⟩ := h.scope_view; trivial
      | succ index => exact ⟨h.scope_eq ▸ scope.1,ih _ index hs scope.2⟩

end Host.Ts.Owned.Parametric
namespace Host.Ts.Owned.Annotated
open Parametric

def extendScopeNote (resource method : Value) : Tree → Tree
  | .node "Frame.s" [.node "StmtF.scope" [.node "List" resources]] =>
      .node "Frame.s" [.node "StmtF.scope" [.node "List" (.node "pair" [.value resource,.value method]::resources)]]
  | other => other

def registerUsingNotes (resource method : Value) : Nat → List Tree → List Tree
  | 0,head::tail => extendScopeNote resource method head::tail
  | i+1,head::tail => head::registerUsingNotes resource method i tail
  | _,[] => []

theorem extendScopeNote_holds {ν : Nat → F64} {C : CSrv} {R : Ren}
    {resourceRole methodRole : Value} {resource method : Val} {note : Tree} {resources : List (Val × Val)}
    (resourceHeld : resourceRole.Holds ν C R resource) (methodHeld : methodRole.Holds ν C R method)
    (held : note.Holds ν C R (Encode.frame (.s (.scope resources)))) :
    (extendScopeNote resourceRole methodRole note).Holds ν C R (Encode.frame (.s (.scope ((resource,method)::resources)))) := by
  cases held with | node tag outer =>
    cases outer with | cons inner outer =>
      cases outer
      cases inner with | node tag middle =>
        cases middle with | cons pairs middle =>
          cases middle
          cases pairs with | node tag fields =>
            exact .node _ (.cons (.node _ (.cons (.node _ (.cons (.node _ (.cons (.value resourceHeld) (.cons (.value methodHeld) .nil))) fields)) .nil)) .nil)

/-- Update exactly the nearest source-selected scope note. All unrelated
control-stack annotations retain their existing occurrence meanings. -/
theorem registerUsingNotes_holds {ν : Nat → F64} {C : CSrv} {R : Ren}
    {resourceRole methodRole : Value} {resource method : Val}
    (resourceHeld : resourceRole.Holds ν C R resource) (methodHeld : methodRole.Holds ν C R method) :
    ∀ (frames post : List Frame) (notes : List Tree) (index : Nat), ScopeAt frames index →
      ForestHolds ν C R notes (frames.map Encode.frame) → addUsing (resource,method) frames = some post →
      ForestHolds ν C R (registerUsingNotes resourceRole methodRole index notes) (post.map Encode.frame) := by
  intro frames
  induction frames with
  | nil => intro post notes index scope; cases index <;> contradiction
  | cons frame tail ih =>
    intro post notes index scope held registration
    cases held with | cons headHeld tailHeld =>
      cases index with
      | zero =>
        cases frame <;> try contradiction
        case s st =>
          cases st <;> try contradiction
          case scope resources =>
            cases registration
            exact .cons (extendScopeNote_holds resourceHeld methodHeld headHeld) tailHeld
      | succ index =>
        rw [addUsing_cons _ _ _ _ scope.1] at registration
        cases next : addUsing (resource,method) tail with
        | none => simp only [next,Option.map_none] at registration; cases registration
        | some postTail =>
          rw [next,Option.map_some] at registration
          cases registration
          exact .cons headHeld (ih postTail _ index scope.2 tailHeld next)

end Host.Ts.Owned.Annotated
