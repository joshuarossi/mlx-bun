import host.ts.RenameRuntimeCallStart
import host.ts.RenameParametricExpressionEntry
import host.ts.RenameParametricMethod
set_option Elab.async false
namespace Host.Ts.Owned.Annotated
open Parametric

inductive CallEntry where
  | identifier (name : Name)
  | method (receiver : Expr) (name : Name) (optional : Bool)
def CallEntry.callee : CallEntry → Expr
  | .identifier name => .id name
  | .method receiver name optional => .member receiver name optional
def CallEntry.focus : CallEntry → Expr
  | .identifier name => .id name
  | .method receiver _ _ => receiver
def CallEntry.frame (args : List Elem) (optional : Bool) (env : Env) : CallEntry → Frame
  | .identifier _ => .c (.callee args env optional)
  | .method _ name optObj => .c (.member (.str name) args env optObj optional)
def CallEntry.frameNote (args : List Elem) (optional : Bool) (env : Env) : CallEntry → Tree
  | .identifier _ => callStartFrameNote (.callee optional) .undef args env
  | .method _ name optObj => .node "Frame.c" [.node "CallF.member"
      [.node "PKey.str" [.atom Name name],.atom (List Elem) args,environmentNote env,.atom Bool optObj,.atom Bool optional]]
def RuntimeNotes.callEntry (notes : RuntimeNotes) (entry : CallEntry) (args : List Elem) (optional : Bool) (env : Env) : RuntimeNotes :=
  {notes with control := expressionNote entry.focus env,stack := entry.frameNote args optional env::notes.stack}

theorem CallEntry.frameNote_holds (ν : Nat → F64) (C : CSrv) (R : Ren) (entry : CallEntry)
    (args : List Elem) (optional : Bool) (env : Env) :
    (entry.frameNote args optional env).Holds ν C R (Encode.frame (entry.frame args optional (R.env env))) := by
  cases entry <;> dsimp only [CallEntry.frameNote,CallEntry.frame,callStartFrameNote,Encode.frame,Encode.callF,Encode.key,Encode.atom]
  all_goals repeat first | exact environmentNote_holds ν C R env | constructor

/-- Identifier and named-method call entries schedule the original source
callee with fixed syntax/receiver continuations, retaining all older notes. -/
theorem RuntimeInventory.call_entry_step (F : Ffi) (FR : Ren → F.S → F.S → Prop)
    (notes : RuntimeNotes) (ν₀ ν : Nat → F64) (C₀ C : CSrv) (R : Ren)
    (live framed : Nat → Prop) (before after : List Val) (old old' : List Event) (s₀ s : St F.S)
    (h : Parametric.StateR (NumberRoles ν₀ ν C₀ C) FR R live framed before after old old' s₀ s)
    (inventory : RuntimeInventory notes ν₀ ν C₀ C R live s₀ s)
    (entry : CallEntry) (args : List Elem) (optional : Bool) (env : Env)
    (control : s₀.ctl = .ev (.call entry.callee args optional) env) :
    interpC (step F s₀).run C₀ = some ((s₀.push (entry.frame args optional env)).go (.ev entry.focus env),C₀) ∧
      interpC (step F s).run C = some ((s.push (entry.frame args optional (R.env env))).go (.ev entry.focus (R.env env)),C) ∧
      Parametric.StateR (NumberRoles ν₀ ν C₀ C) FR R live framed before after old old'
        ((s₀.push (entry.frame args optional env)).go (.ev entry.focus env))
        ((s.push (entry.frame args optional (R.env env))).go (.ev entry.focus (R.env env))) ∧
      RuntimeInventory (notes.callEntry entry args optional env) ν₀ ν C₀ C R live
        ((s₀.push (entry.frame args optional env)).go (.ev entry.focus env))
        ((s.push (entry.frame args optional (R.env env))).go (.ev entry.focus (R.env env))) := by
  have runs : interpC (step F s₀).run C₀ = some ((s₀.push (entry.frame args optional env)).go (.ev entry.focus env),C₀) ∧
      interpC (step F s).run C = some ((s.push (entry.frame args optional (R.env env))).go (.ev entry.focus (R.env env)),C) ∧
      Parametric.StateR (NumberRoles ν₀ ν C₀ C) FR R live framed before after old old'
        ((s₀.push (entry.frame args optional env)).go (.ev entry.focus env))
        ((s.push (entry.frame args optional (R.env env))).go (.ev entry.focus (R.env env))) := by
    cases entry with
    | identifier name =>
      exact step_identifier_call_descent_from_source F (NumberRoles ν₀ ν C₀ C) FR R C₀ C
        live framed before after old old' s₀ s h name args optional env control
    | method receiver name optObj =>
      exact step_method_descent_from_source F (NumberRoles ν₀ ν C₀ C) FR R C₀ C
        live framed before after old old' s₀ s h receiver name args env optObj optional control
  refine ⟨runs.1,runs.2.1,runs.2.2,inventory.keyLive,?_,?_⟩
  · exact ⟨expressionNote_source ν₀ C₀ entry.focus env,
      .cons (by simpa only [identity_environment] using entry.frameNote_holds ν₀ C₀ identity args optional env)
        inventory.source.stack,inventory.source.cells⟩
  · exact ⟨expressionNote_holds ν C R entry.focus env,
      .cons (entry.frameNote_holds ν C R args optional env) inventory.target.stack,inventory.target.cells⟩

end Host.Ts.Owned.Annotated
