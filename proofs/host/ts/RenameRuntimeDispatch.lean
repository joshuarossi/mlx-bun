import host.ts.RenameRuntimeNotes
import host.ts.RenameParametricArithmeticStep
import host.ts.RenameParametricDescent

set_option Elab.async false
namespace Host.Ts.Owned.Annotated
open Parametric

theorem ForestHolds.head {ν : Nat → F64} {C : CSrv} {R : Ren} {role : Tree} {roles : List Tree}
    {value : Owned.Tree} {values : List Owned.Tree} (h : ForestHolds ν C R (role::roles) (value::values)) :
    role.Holds ν C R value := by cases h with | cons hh _ => exact hh

theorem ForestHolds.tail {ν : Nat → F64} {C : CSrv} {R : Ren} {role : Tree} {roles : List Tree}
    {value : Owned.Tree} {values : List Owned.Tree} (h : ForestHolds ν C R (role::roles) (value::values)) :
    ForestHolds ν C R roles values := by cases h with | cons _ ht => exact ht

theorem Value.Holds.num_denote {ν : Nat → F64} {C : CSrv} {R : Ren} {meaning : SymE} {n : NumV}
    (h : (Value.num meaning).Holds ν C R (.num n)) : NumDenote ν C meaning n := by
  cases h with | num _ _ h => exact h

def RuntimeNotes.returning (notes : RuntimeNotes) (role : Value) : RuntimeNotes :=
  {notes with control := returnNote role}
def RuntimeNotes.binaryLeft (notes : RuntimeNotes) (role : Value) (op : BinOp) (right : Expr)
    (env : Env) (tail : List Tree) : RuntimeNotes :=
  {notes with control := expressionNote right env,stack := binaryRightNote op role::tail}
def RuntimeNotes.binaryResult (notes : RuntimeNotes) (role : Value) (tail : List Tree) : RuntimeNotes :=
  {notes with control := returnNote role,stack := tail}
def RuntimeNotes.binaryDescent (notes : RuntimeNotes) (op : BinOp) (left right : Expr) (env : Env) : RuntimeNotes :=
  {notes with control := expressionNote left env, stack := binaryLeftNote op right env::notes.stack}

theorem RuntimeInventory.binary_descent_step (F : Ffi) (FR : Ren → F.S → F.S → Prop)
    (notes : RuntimeNotes) (ν₀ ν : Nat → F64) (C₀ C : CSrv) (R : Ren)
    (live framed : Nat → Prop) (before after : List Val) (old old' : List Event) (s₀ s : St F.S)
    (h : Parametric.StateR (NumberRoles ν₀ ν C₀ C) FR R live framed before after old old' s₀ s)
    (inventory : RuntimeInventory notes ν₀ ν C₀ C R live s₀ s)
    (op : BinOp) (left right : Expr) (env : Env) (control : s₀.ctl = .ev (.bin op left right) env) :
    let source := (s₀.push (.e (.binL op right env))).go (.ev left env)
    let target := (s.push (.e (.binL op right (R.env env)))).go (.ev left (R.env env))
    interpC (step F s₀).run C₀ = some (source,C₀) ∧
      interpC (step F s).run C = some (target,C) ∧
      Parametric.StateR (NumberRoles ν₀ ν C₀ C) FR R live framed before after old old' source target ∧
      RuntimeInventory (notes.binaryDescent op left right env) ν₀ ν C₀ C R live source target := by
  obtain ⟨sourceRun,targetRun,post⟩ := step_descent_roles F (NumberRoles ν₀ ν C₀ C) FR R C₀ C
    live framed before after old old' s₀ s h (.binary op left right) env (R.env env)
    control (h.control_view control).ev_view
  refine ⟨sourceRun,targetRun,post,inventory.keyLive,?_,?_⟩
  · exact ⟨expressionNote_source ν₀ C₀ left env,.cons
      (by simpa only [identity_environment] using binaryLeftNote_holds ν₀ C₀ identity op right env)
      inventory.source.stack,inventory.source.cells⟩
  · exact ⟨expressionNote_holds ν C R left env,
      .cons (binaryLeftNote_holds ν C R op right env) inventory.target.stack,inventory.target.cells⟩

/-- Literal parsing is a real source interpreter transition. Its output note
is fixed by syntax and replaces only the current control annotation. -/
theorem RuntimeInventory.literal_step (F : Ffi) (FR : Ren → F.S → F.S → Prop)
    (notes : RuntimeNotes) (ν₀ ν : Nat → F64) (C₀ C : CSrv) (R : Ren)
    (live framed : Nat → Prop) (before after : List Val) (old old' : List Event) (s₀ s : St F.S)
    (h : Parametric.StateR (NumberRoles ν₀ ν C₀ C) FR R live framed before after old old' s₀ s)
    (inventory : RuntimeInventory notes ν₀ ν C₀ C R live s₀ s)
    (literal : Lit) (value : Val) (env : Env) (parsed : LiteralValue literal value)
    (control : s₀.ctl = .ev (.lit literal) env) :
    interpC (step F s₀).run C₀ = some (s₀.ret value,C₀) ∧
      interpC (step F s).run C = some (s.ret value,C) ∧
      Parametric.StateR (NumberRoles ν₀ ν C₀ C) FR R live framed before after old old' (s₀.ret value) (s.ret value) ∧
      RuntimeInventory (notes.returning parsed.role) ν₀ ν C₀ C R live (s₀.ret value) (s.ret value) := by
  obtain ⟨left,right,related,sourceRole,targetRole⟩ := step_literal_from_source F FR R ν₀ ν C₀ C live framed
    before after old old' s₀ s h literal value env parsed control
  exact ⟨left,right,related,inventory.returning sourceRole targetRole⟩

/-- A source variable read gets its fixed role from the cell inventory and
installs that same role in the control note. -/
theorem RuntimeInventory.variable_step (F : Ffi) (FR : Ren → F.S → F.S → Prop)
    (notes : RuntimeNotes) (ν₀ ν : Nat → F64) (C₀ C : CSrv) (R : Ren)
    (live framed : Nat → Prop) (before after : List Val) (old old' : List Event) (s₀ s : St F.S)
    (h : Parametric.StateR (NumberRoles ν₀ ν C₀ C) FR R live framed before after old old' s₀ s)
    (inventory : RuntimeInventory notes ν₀ ν C₀ C R live s₀ s)
    (name : Name) (env : Env) (address : Nat) (value : Val) (role : Value)
    (control : s₀.ctl = .ev (.id name) env) (lookup : lookupEnv name env = some address)
    (cell : s₀.heap.get address = some (.cell (some value))) (entry : notes.cells.cells address = some role) :
    ∃ targetValue, interpC (step F s₀).run C₀ = some (s₀.ret value,C₀) ∧
      interpC (step F s).run C = some (s.ret targetValue,C) ∧
      Parametric.StateR (NumberRoles ν₀ ν C₀ C) FR R live framed before after old old' (s₀.ret value) (s.ret targetValue) ∧
      RuntimeInventory (notes.returning role) ν₀ ν C₀ C R live (s₀.ret value) (s.ret targetValue) := by
  obtain ⟨targetValue,left,right,related,_,sourceRole,targetRole⟩ := inventory.cellInventory.variable_step F FR
    notes.cells ν₀ ν C₀ C R live framed before after old old' s₀ s h name env address value role control lookup cell entry
  exact ⟨targetValue,left,right,related,inventory.returning sourceRole targetRole⟩

/-- Binary-left dispatch copies the current fixed value note into its saved
operand frame. No role is chosen when that operand is later consumed. -/
theorem RuntimeInventory.binary_left_step (F : Ffi) (FR : Ren → F.S → F.S → Prop)
    (notes : RuntimeNotes) (ν₀ ν : Nat → F64) (C₀ C : CSrv) (R : Ren)
    (live framed : Nat → Prop) (before after : List Val) (old old' : List Event) (s₀ s : St F.S)
    (h : Parametric.StateR (NumberRoles ν₀ ν C₀ C) FR R live framed before after old old' s₀ s)
    (inventory : RuntimeInventory notes ν₀ ν C₀ C R live s₀ s)
    (value : Val) (role : Value) (op : BinOp) (right : Expr) (env : Env) (frames : List Frame)
    (headNote : Tree) (tailNotes : List Tree)
    (control : s₀.ctl = .ret value) (stack : s₀.stack = .e (.binL op right env)::frames)
    (controlNote : notes.control = returnNote role) (stackNote : notes.stack = headNote::tailNotes) :
    ∃ targetValue targetFrames,
      interpC (step F s₀).run C₀ = some (binaryLeftState {s₀ with stack := frames} op right env value,C₀) ∧
      interpC (step F s).run C =
        some (binaryLeftState {s with stack := targetFrames} op right (R.env env) targetValue,C) ∧
      Parametric.StateR (NumberRoles ν₀ ν C₀ C) FR R live framed before after old old'
        (binaryLeftState {s₀ with stack := frames} op right env value)
        (binaryLeftState {s with stack := targetFrames} op right (R.env env) targetValue) ∧
      RuntimeInventory (notes.binaryLeft role op right env tailNotes) ν₀ ν C₀ C R live
        (binaryLeftState {s₀ with stack := frames} op right env value)
        (binaryLeftState {s with stack := targetFrames} op right (R.env env) targetValue) ∧
      s.stack = .e (.binL op right (R.env env))::targetFrames := by
  obtain ⟨targetValue,targetControl,_⟩ := (h.control_view control).ret_view
  obtain ⟨frame,targetFrames,targetStack,frameRoles,_⟩ := h.stack_view stack
  rw [frameRoles.binL_view] at targetStack
  have sourceControlNote := inventory.source.control
  rw [controlNote,control] at sourceControlNote
  have sourceRole := returnNote_view sourceControlNote
  have targetControlNote := inventory.target.control
  rw [controlNote,targetControl] at targetControlNote
  have targetRole := returnNote_view targetControlNote
  have sourceStackNotes := inventory.source.stack
  rw [stackNote,stack,List.map_cons] at sourceStackNotes
  have targetStackNotes := inventory.target.stack
  rw [stackNote,targetStack,List.map_cons] at targetStackNotes
  obtain ⟨result,left,rightRun,related⟩ := step_binary_left_from_source F (NumberRoles ν₀ ν C₀ C) FR R C₀ C
    live framed before after old old' s₀ s h value op right env frames control stack
  have actual : interpC (step F s).run C =
      some (binaryLeftState {s with stack := targetFrames} op right (R.env env) targetValue,C) := by
    rw [step_binary_left_eq F s targetValue op right (R.env env) targetFrames targetControl targetStack]
    rfl
  have same := congrArg Prod.fst (Option.some.inj (rightRun.symm.trans actual))
  dsimp only [Prod.fst] at same
  rw [same] at related
  refine ⟨targetValue,targetFrames,left,actual,related,?_,targetStack⟩
  refine ⟨inventory.keyLive,?_,?_⟩
  · exact ⟨expressionNote_source ν₀ C₀ right env,
      .cons (binaryRightNote_holds op sourceRole) sourceStackNotes.tail,inventory.source.cells⟩
  · exact ⟨expressionNote_holds ν C R right env,
      .cons (binaryRightNote_holds op targetRole) targetStackNotes.tail,inventory.target.cells⟩

end Host.Ts.Owned.Annotated
