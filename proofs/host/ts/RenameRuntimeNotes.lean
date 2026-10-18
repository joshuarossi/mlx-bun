import host.ts.RenameRoleInventory
import host.ts.RenameParametricLiteral

set_option Elab.async false
namespace Host.Ts.Owned.Annotated
open Parametric

/-- The control and saved frames carry fixed occurrence meanings, together
with the live cell inventory. The data is retained across primitive steps. -/
structure RuntimeNotes where
  control : Tree
  stack : List Tree
  cells : Notes

def environmentNote (env : Env) : Tree :=
  .node "List" (env.map fun (name,a) => .node "binding" [.atom Name name,.address a])
def returnNote (role : Value) : Tree := .node "Ctl.ret" [.value role]
def expressionNote (expression : Expr) (env : Env) : Tree :=
  .node "Ctl.ev" [.atom Expr expression,environmentNote env]
def binaryLeftNote (op : BinOp) (right : Expr) (env : Env) : Tree :=
  .node "Frame.e" [.node "ExprF.binL" [.atom BinOp op,.atom Expr right,environmentNote env]]
def binaryRightNote (op : BinOp) (left : Value) : Tree :=
  .node "Frame.e" [.node "ExprF.binR" [.atom BinOp op,.value left]]

structure RuntimeNotes.Holds {S : Type} (notes : RuntimeNotes) (ν : Nat → F64) (C : CSrv)
    (R : Ren) (s : St S) : Prop where
  control : notes.control.Holds ν C R (Encode.ctl s.ctl)
  stack : ForestHolds ν C R notes.stack (s.stack.map Encode.frame)
  cells : notes.cells.Holds ν C R s

structure RuntimeInventory {S : Type} (notes : RuntimeNotes) (ν₀ ν : Nat → F64)
    (C₀ C : CSrv) (R : Ren) (live : Nat → Prop) (s₀ s : St S) : Prop where
  keyLive : notes.cells.Live live
  source : notes.Holds ν₀ C₀ identity s₀
  target : notes.Holds ν C R s

theorem environmentNote_holds (ν : Nat → F64) (C : CSrv) (R : Ren) (env : Env) :
    (environmentNote env).Holds ν C R (Encode.env (R.env env)) := by
  unfold environmentNote Encode.env Encode.seq
  apply Tree.Holds.node
  induction env with
  | nil => exact .nil
  | cons binding env ih =>
    rcases binding with ⟨name,a⟩
    exact .cons (.node _ (.cons (.atom Name name) (.cons (.address a) .nil))) ih

theorem identity_environment (env : Env) : identity.env env = env := by
  induction env with
  | nil => rfl
  | cons binding env ih =>
    rcases binding with ⟨name,a⟩
    change (name,a)::identity.env env = (name,a)::env
    rw [ih]

theorem environmentNote_source (ν : Nat → F64) (C : CSrv) (env : Env) :
    (environmentNote env).Holds ν C identity (Encode.env env) := by
  simpa only [identity_environment] using environmentNote_holds ν C identity env

theorem returnNote_holds {ν : Nat → F64} {C : CSrv} {R : Ren} {role : Value} {v : Val}
    (h : role.Holds ν C R v) : (returnNote role).Holds ν C R (Encode.ctl (.ret v)) :=
  .node _ (.cons (.value h) .nil)

theorem returnNote_view {ν : Nat → F64} {C : CSrv} {R : Ren} {role : Value} {v : Val}
    (h : (returnNote role).Holds ν C R (Encode.ctl (.ret v))) : role.Holds ν C R v := by
  cases h with | node tag hs =>
    cases hs with | cons hv hs =>
      cases hv with | value hv => exact hv

theorem expressionNote_source (ν : Nat → F64) (C : CSrv) (expression : Expr) (env : Env) :
    (expressionNote expression env).Holds ν C identity (Encode.ctl (.ev expression env)) :=
  .node _ (.cons (.atom Expr expression) (.cons (environmentNote_source ν C env) .nil))

theorem expressionNote_holds (ν : Nat → F64) (C : CSrv) (R : Ren) (expression : Expr) (env : Env) :
    (expressionNote expression env).Holds ν C R (Encode.ctl (.ev expression (R.env env))) :=
  .node _ (.cons (.atom Expr expression) (.cons (environmentNote_holds ν C R env) .nil))

theorem binaryLeftNote_holds (ν : Nat → F64) (C : CSrv) (R : Ren) (op : BinOp) (right : Expr) (env : Env) :
    (binaryLeftNote op right env).Holds ν C R (Encode.frame (.e (.binL op right (R.env env)))) :=
  .node _ (.cons (.node _ (.cons (.atom BinOp op) (.cons (.atom Expr right)
    (.cons (environmentNote_holds ν C R env) .nil)))) .nil)

theorem binaryRightNote_holds {ν : Nat → F64} {C : CSrv} {R : Ren} {role : Value} {v : Val}
    (op : BinOp) (h : role.Holds ν C R v) :
    (binaryRightNote op role).Holds ν C R (Encode.frame (.e (.binR op v))) :=
  .node _ (.cons (.node _ (.cons (.atom BinOp op) (.cons (.value h) .nil))) .nil)

theorem binaryRightNote_view {ν : Nat → F64} {C : CSrv} {R : Ren}
    {op : BinOp} {role : Value} {v : Val}
    (h : (binaryRightNote op role).Holds ν C R (Encode.frame (.e (.binR op v)))) : role.Holds ν C R v := by
  cases h with | node tag hs =>
    cases hs with | cons hf hs =>
      cases hf with | node tag fields =>
        cases fields with | cons hop fields =>
          cases fields with | cons hv fields =>
            cases hv with | value hv => exact hv

section
variable {S : Type} {notes : RuntimeNotes} {ν₀ ν : Nat → F64} {C₀ C : CSrv}
  {R : Ren} {live : Nat → Prop} {s₀ s : St S}

theorem RuntimeInventory.cellInventory (h : RuntimeInventory notes ν₀ ν C₀ C R live s₀ s) :
    CellInventory notes.cells ν₀ ν C₀ C R live s₀ s := ⟨h.keyLive,h.source.cells,h.target.cells⟩

theorem RuntimeNotes.Holds.mono {D : CSrv} (extension : TableExtends C D)
    (h : notes.Holds ν C R s) : notes.Holds ν D R s :=
  ⟨h.control.mono extension,ForestHolds.mono extension h.stack,h.cells.mono extension⟩

theorem RuntimeInventory.mono {D₀ D : CSrv} (left : TableExtends C₀ D₀) (right : TableExtends C D)
    (h : RuntimeInventory notes ν₀ ν C₀ C R live s₀ s) : RuntimeInventory notes ν₀ ν D₀ D R live s₀ s :=
  ⟨h.keyLive,h.source.mono left,h.target.mono right⟩

theorem RuntimeInventory.returning (h : RuntimeInventory notes ν₀ ν C₀ C R live s₀ s)
    {role : Value} {v₀ v : Val} (source : role.Holds ν₀ C₀ identity v₀) (target : role.Holds ν C R v) :
    RuntimeInventory {notes with control := returnNote role} ν₀ ν C₀ C R live (s₀.ret v₀) (s.ret v) :=
  ⟨h.keyLive,⟨returnNote_holds source,h.source.stack,h.source.cells⟩,
    ⟨returnNote_holds target,h.target.stack,h.target.cells⟩⟩

theorem RuntimeInventory.control_pair (h : RuntimeInventory notes ν₀ ν C₀ C R live s₀ s) :
    Parametric.ControlR (NumberRoles ν₀ ν C₀ C) R s₀.ctl s.ctl := Tree.paired h.source.control h.target.control

end
end Host.Ts.Owned.Annotated
