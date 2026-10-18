import host.ts.RenameRuntimeParameterNotes
import host.ts.RenameParametricClassFields

set_option Elab.async false
namespace Host.Ts.Owned.Annotated
open Parametric

def privateMemberNote : InstMember → Tree
  | .privField brand name init =>
      .node "InstMember.privField" [.address brand,.atom Name name,.atom (Option Expr) init]
  | other => .atom InstMember other
def privateMembersNote (members : List InstMember) : Tree := .node "List" (members.map privateMemberNote)
def classFieldsFrameNote (owner : Nat) (members : List InstMember) (env : Env) : Tree :=
  .node "Frame.k" [.node "FnF.fields" [.address owner,privateMembersNote members,environmentNote env]]
def constructorBodyFrameNote (receiver : Value) (fn : Func) (env : Env) (args : List Value) : Tree :=
  .node "Frame.k" [.node "FnF.ctorBody" [.value receiver,.atom Func fn,environmentNote env,valuesNote args]]
def constructorBoundaryNote (receiver : Value) : Tree :=
  .node "Frame.k" [.node "FnF.fn" [.node "Boundary.ctor" [.value receiver]]]

theorem privateMembersNote_holds {ν : Nat → F64} {C : CSrv} {R : Ren}
    {NR : NumV → NumV → Prop} {members target : List InstMember}
    (privateFields : PrivateFields members) (related : ClassFieldsR NR R members target) :
    (privateMembersNote members).Holds ν C R (Encode.seq (target.map Encode.inst)) := by
  have forest : ForestHolds ν C R (members.map privateMemberNote) (target.map Encode.inst) := by
    induction privateFields generalizing target with
    | nil => rw [related.nil_view]; exact .nil
    | @cons brand name init rest privateFields ih =>
      obtain ⟨tail,rfl,tailRelated⟩ := related.private_view
      exact .cons (.node _ (.cons (.address brand) (.cons (.atom Name name)
        (.cons (.atom (Option Expr) init) .nil)))) (ih tailRelated)
  exact .node _ forest

theorem classFieldsFrameNote_holds {ν : Nat → F64} {C : CSrv} {R : Ren}
    {NR : NumV → NumV → Prop} (owner : Nat) (members target : List InstMember) (env : Env)
    (privateFields : PrivateFields members) (related : ClassFieldsR NR R members target) :
    (classFieldsFrameNote owner members env).Holds ν C R
      (Encode.frame (.k (.fields (R.a owner) target (R.env env)))) :=
  .node _ (.cons (.node _ (.cons (.address owner) (.cons (privateMembersNote_holds privateFields related)
    (.cons (environmentNote_holds ν C R env) .nil)))) .nil)

theorem constructorBodyFrameNote_holds {ν : Nat → F64} {C : CSrv} {R : Ren}
    (receiver : Value) (fn : Func) (env : Env) (roles : List Value) (this : Val) (args : List Val)
    (thisRole : receiver.Holds ν C R this)
    (arguments : ListR (fun role value => role.Holds ν C R value) roles args) :
    (constructorBodyFrameNote receiver fn env roles).Holds ν C R
      (Encode.frame (.k (.ctorBody this fn (R.env env) args))) :=
  .node _ (.cons (.node _ (.cons (.value thisRole) (.cons (.atom Func fn)
    (.cons (environmentNote_holds ν C R env) (.cons (valuesNote_holds arguments) .nil))))) .nil)

theorem constructorBodyFrameNote_view {ν : Nat → F64} {C : CSrv} {R : Ren}
    (receiver : Value) (fn : Func) (env : Env) (roles : List Value) (this : Val) (args : List Val)
    (held : (constructorBodyFrameNote receiver fn env roles).Holds ν C R
      (Encode.frame (.k (.ctorBody this fn (R.env env) args)))) :
    receiver.Holds ν C R this ∧ ListR (fun role value => role.Holds ν C R value) roles args := by
  cases held with | node _ outer => cases outer with | cons inner _ =>
    cases inner with | node _ fields => cases fields with | cons receiverNote fields =>
      cases fields with | cons _ fields => cases fields with | cons _ fields =>
        cases fields with | cons argsNote _ =>
          cases receiverNote with | value receiverNote => exact ⟨receiverNote,valuesNote_view argsNote⟩

theorem constructorBoundaryNote_holds {ν : Nat → F64} {C : CSrv} {R : Ren}
    (receiver : Value) (this : Val) (held : receiver.Holds ν C R this) :
    (constructorBoundaryNote receiver).Holds ν C R (Encode.frame (.k (.fn (.ctor this)))) :=
  .node _ (.cons (.node _ (.cons (.node _ (.cons (.value held) .nil)) .nil)) .nil)

end Host.Ts.Owned.Annotated
