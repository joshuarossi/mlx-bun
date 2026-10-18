import host.ts.RenameRuntimeDispatch
set_option Elab.async false
namespace Host.Ts.Owned.Annotated
open Parametric

def descentFrameNote (env : Env) : Descent → Tree
  | .binary op _ right => binaryLeftNote op right env
  | .logical op _ right => .node "Frame.e" [.node "ExprF.logL" [.atom LogOp op,.atom Expr right,environmentNote env]]
  | .conditional _ yes no => .node "Frame.e" [.node "ExprF.cond" [.atom Expr yes,.atom Expr no,environmentNote env]]
  | .sequence _ right => .node "Frame.e" [.node "ExprF.seq" [.atom Expr right,environmentNote env]]
  | .member _ name optional => .node "Frame.e" [.node "ExprF.member" [.node "PKey.str" [.atom Name name],.atom Bool optional]]
  | .index _ key optional => .node "Frame.e" [.node "ExprF.indexL" [.atom Expr key,environmentNote env,.atom Bool optional]]
  | .construct _ args => .node "Frame.c" [.node "CallF.newCallee" [.atom (List Elem) args,environmentNote env]]
  | .chain _ => .node "Frame.e" [.node "ExprF.chain" []]
  | .await _ => .node "Frame.k" [.node "FnF.await" []]
  | .yield _ delegate => .node "Frame.k" [.node "FnF.yield" [.atom Bool delegate]]
def RuntimeNotes.descent (notes : RuntimeNotes) (d : Descent) (env : Env) : RuntimeNotes :=
  {notes with control := expressionNote d.focus env,stack := descentFrameNote env d::notes.stack}

theorem descentFrameNote_holds (ν : Nat → F64) (C : CSrv) (R : Ren) (d : Descent) (env : Env) :
    (descentFrameNote env d).Holds ν C R (Encode.frame (d.frame (R.env env))) := by
  cases d <;> dsimp only [descentFrameNote,binaryLeftNote,Descent.frame,Encode.frame,Encode.exprF,
    Encode.callF,Encode.fnF,Encode.key,Encode.atom]
  all_goals repeat first | exact environmentNote_holds ν C R env | constructor

/-- Every supported original expression descent adds a fixed structural frame,
preserving every older operand annotation and cell meaning. -/
theorem RuntimeInventory.descent_step (F : Ffi) (FR : Ren → F.S → F.S → Prop)
    (notes : RuntimeNotes) (ν₀ ν : Nat → F64) (C₀ C : CSrv) (R : Ren)
    (live framed : Nat → Prop) (before after : List Val) (old old' : List Event) (s₀ s : St F.S)
    (h : Parametric.StateR (NumberRoles ν₀ ν C₀ C) FR R live framed before after old old' s₀ s)
    (inventory : RuntimeInventory notes ν₀ ν C₀ C R live s₀ s)
    (d : Descent) (env : Env) (control : s₀.ctl = .ev d.whole env) :
    interpC (step F s₀).run C₀ = some ((s₀.push (d.frame env)).go (.ev d.focus env),C₀) ∧
      interpC (step F s).run C = some ((s.push (d.frame (R.env env))).go (.ev d.focus (R.env env)),C) ∧
      Parametric.StateR (NumberRoles ν₀ ν C₀ C) FR R live framed before after old old'
        ((s₀.push (d.frame env)).go (.ev d.focus env)) ((s.push (d.frame (R.env env))).go (.ev d.focus (R.env env))) ∧
      RuntimeInventory (notes.descent d env) ν₀ ν C₀ C R live
        ((s₀.push (d.frame env)).go (.ev d.focus env)) ((s.push (d.frame (R.env env))).go (.ev d.focus (R.env env))) := by
  obtain ⟨left,right,related⟩ := step_descent_roles F (NumberRoles ν₀ ν C₀ C) FR R C₀ C live framed before after old old'
    s₀ s h d env (R.env env) control (h.control_view control).ev_view
  refine ⟨left,right,related,inventory.keyLive,?_,?_⟩
  · exact ⟨expressionNote_source ν₀ C₀ d.focus env,
      .cons (by simpa only [identity_environment] using descentFrameNote_holds ν₀ C₀ identity d env)
        inventory.source.stack,inventory.source.cells⟩
  · exact ⟨expressionNote_holds ν C R d.focus env,
      .cons (descentFrameNote_holds ν C R d env) inventory.target.stack,inventory.target.cells⟩

end Host.Ts.Owned.Annotated
