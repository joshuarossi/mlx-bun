import host.ts.RenameRuntimeDispatch
import host.ts.RenamePrivateInventory
import host.ts.RenameParametricMapControl
import host.ts.RenameParametricExpressionEntry
set_option Elab.async false
namespace Host.Ts.Owned.Annotated
open Parametric

/-- `this` reads the actual lexical cell and inherits its one retained role. -/
theorem RuntimeInventory.this_step (F : Ffi) (FR : Ren → F.S → F.S → Prop)
    (notes : RuntimeNotes) (ν₀ ν : Nat → F64) (C₀ C : CSrv) (R : Ren)
    (live framed : Nat → Prop) (before after : List Val) (old old' : List Event) (s₀ s : St F.S)
    (h : Parametric.StateR (NumberRoles ν₀ ν C₀ C) FR R live framed before after old old' s₀ s)
    (inventory : RuntimeInventory notes ν₀ ν C₀ C R live s₀ s)
    (env : Env) (a : Nat) (value : Val) (role : Value)
    (control : s₀.ctl = .ev .this env) (lookup : lookupEnv nThis env = some a)
    (cell : s₀.heap.get a = some (.cell (some value))) (entry : notes.cells.cells a = some role) :
    ∃ targetValue, interpC (step F s₀).run C₀ = some (s₀.ret value,C₀) ∧
      interpC (step F s).run C = some (s.ret targetValue,C) ∧
      Parametric.StateR (NumberRoles ν₀ ν C₀ C) FR R live framed before after old old' (s₀.ret value) (s.ret targetValue) ∧
      RuntimeInventory (notes.returning role) ν₀ ν C₀ C R live (s₀.ret value) (s.ret targetValue) := by
  have alive := inventory.keyLive a role entry
  obtain ⟨targetValue,targetCell,_,valueLive⟩ := h.heap.readCell a value alive cell
  have targetLookup : lookupEnv nThis (R.env env) = some (R.a a) := by rw [lookupEnv_map,lookup]; rfl
  have sourceRole : role.Holds ν₀ C₀ identity value := by
    simpa only [cellValueAt,identity,id_eq,cell] using inventory.source.cells a role entry
  have targetRole : role.Holds ν C R targetValue := by
    simpa only [cellValueAt,targetCell] using inventory.target.cells a role entry
  refine ⟨targetValue,?_,?_,?_,inventory.returning sourceRole targetRole⟩
  · rw [step_this_eq F s₀ env a value control lookup cell]; rfl
  · rw [step_this_eq F s (R.env env) (R.a a) targetValue (h.control_view control).ev_view targetLookup targetCell]; rfl
  · exact h.go (.node _ (.cons (.value (Value.paired sourceRole targetRole)) .nil)) ⟨valueLive,True.intro⟩

def privateReadFrameNote (brand : Nat) (name : Name) (optional : Bool) : Tree :=
  .node "Frame.e" [.node "ExprF.priv" [.address brand,.atom Name name,.atom Bool optional]]
def RuntimeNotes.privateDescent (notes : RuntimeNotes) (receiver : Expr) (brand : Nat) (name : Name) (optional : Bool) (env : Env) : RuntimeNotes :=
  {notes with control := expressionNote receiver env,stack := privateReadFrameNote brand name optional::notes.stack}

theorem privateReadFrameNote_holds (ν : Nat → F64) (C : CSrv) (R : Ren) (brand : Nat) (name : Name) (optional : Bool) :
    (privateReadFrameNote brand name optional).Holds ν C R (Encode.frame (.e (.priv (R.a brand) name optional))) :=
  .node _ (.cons (.node _ (.cons (.address brand) (.cons (.atom Name name) (.cons (.atom Bool optional) .nil)))) .nil)

/-- The source environment selects the private brand before its receiver is
executed. The saved brand note is mapped with the same resource renaming. -/
theorem RuntimeInventory.private_descent_step (F : Ffi) (FR : Ren → F.S → F.S → Prop)
    (notes : RuntimeNotes) (ν₀ ν : Nat → F64) (C₀ C : CSrv) (R : Ren)
    (live framed : Nat → Prop) (before after : List Val) (old old' : List Event) (s₀ s : St F.S)
    (h : Parametric.StateR (NumberRoles ν₀ ν C₀ C) FR R live framed before after old old' s₀ s)
    (inventory : RuntimeInventory notes ν₀ ν C₀ C R live s₀ s)
    (receiver : Expr) (brand : Nat) (name : Name) (optional : Bool) (env : Env)
    (control : s₀.ctl = .ev (.priv receiver name optional) env)
    (lookup : lookupEnv (privName name) env = some brand) :
    interpC (step F s₀).run C₀ = some ((s₀.push (.e (.priv brand name optional))).go (.ev receiver env),C₀) ∧
    interpC (step F s).run C = some ((s.push (.e (.priv (R.a brand) name optional))).go (.ev receiver (R.env env)),C) ∧
    Parametric.StateR (NumberRoles ν₀ ν C₀ C) FR R live framed before after old old'
      ((s₀.push (.e (.priv brand name optional))).go (.ev receiver env))
      ((s.push (.e (.priv (R.a brand) name optional))).go (.ev receiver (R.env env))) ∧
    RuntimeInventory (notes.privateDescent receiver brand name optional env) ν₀ ν C₀ C R live
      ((s₀.push (.e (.priv brand name optional))).go (.ev receiver env))
      ((s.push (.e (.priv (R.a brand) name optional))).go (.ev receiver (R.env env))) := by
  obtain ⟨sourceRun,targetRun,post⟩ := step_private_descent_from_source F (NumberRoles ν₀ ν C₀ C) FR R C₀ C live framed
    before after old old' s₀ s h receiver name optional env brand control lookup
  refine ⟨sourceRun,targetRun,post,inventory.keyLive,?_,?_⟩
  · exact ⟨expressionNote_source ν₀ C₀ receiver env,
      .cons (privateReadFrameNote_holds ν₀ C₀ identity brand name optional) inventory.source.stack,inventory.source.cells⟩
  · exact ⟨expressionNote_holds ν C R receiver env,
      .cons (privateReadFrameNote_holds ν C R brand name optional) inventory.target.stack,inventory.target.cells⟩

/-- A private data read returns the existing owning-field annotation. The
source descriptor and saved stack select both actual interpreter transitions. -/
theorem RuntimeInventory.private_read_step (F : Ffi) (FR : Ren → F.S → F.S → Prop)
    (notes : RuntimeNotes) (privates : PrivateNotes) (ν₀ ν : Nat → F64) (C₀ C : CSrv) (R : Ren)
    (live framed : Nat → Prop) (before after : List Val) (old old' : List Event) (s₀ s : St F.S)
    (h : Parametric.StateR (NumberRoles ν₀ ν C₀ C) FR R live framed before after old old' s₀ s)
    (inventory : RuntimeInventory notes ν₀ ν C₀ C R live s₀ s)
    (privateInventory : PrivateInventory privates ν₀ ν C₀ C R live s₀ s)
    (owner brand : Nat) (name : Name) (role : Value) (o₀ : Obj) (value : Val) (w e : Bool)
    (frames : List Frame) (headNote : Tree) (tailNotes : List Tree)
    (entry : privates.owners owner = some ⟨brand,name,role⟩)
    (control : s₀.ctl = .ret (.obj owner)) (stack : s₀.stack = .e (.priv brand name false)::frames)
    (object : s₀.heap.get owner = some (.obj o₀)) (ordinary : o₀.kind = .ordinary)
    (descriptor : findPriv brand name o₀.priv = some (.data value w e))
    (stackNotes : notes.stack = headNote::tailNotes) :
    ∃ (targetValue : Val) (targetFrames : List Frame),
      interpC (step F s₀).run C₀ = some ({s₀ with stack := frames}.ret value,C₀) ∧
      interpC (step F s).run C = some ({s with stack := targetFrames}.ret targetValue,C) ∧
      Parametric.StateR (NumberRoles ν₀ ν C₀ C) FR R live framed before after old old'
        ({s₀ with stack := frames}.ret value) ({s with stack := targetFrames}.ret targetValue) ∧
      RuntimeInventory {notes with control := returnNote role,stack := tailNotes} ν₀ ν C₀ C R live
        ({s₀ with stack := frames}.ret value) ({s with stack := targetFrames}.ret targetValue) ∧
      PrivateInventory privates ν₀ ν C₀ C R live ({s₀ with stack := frames}.ret value) ({s with stack := targetFrames}.ret targetValue) := by
  obtain ⟨receiver,targetControl,receiverRole⟩ := (h.control_view control).ret_view
  cases receiverRole
  obtain ⟨frame,targetFrames,targetStack,frameRelation,_⟩ := h.stack_view stack
  rw [frameRelation.private_view] at targetStack
  obtain ⟨targetValue,targetField,targetRole⟩ := privateInventory.target owner _ entry
  obtain ⟨otherValue,otherFrames,sourceRun,targetRun,post,_,sourceRole,_⟩ := privateInventory.read_step F FR
    privates ν₀ ν C₀ C R live framed before after old old' s₀ s h owner brand name role o₀ value w e frames
    entry control stack object ordinary descriptor
  have actual : interpC (step F s).run C = some ({s with stack := targetFrames}.ret targetValue,C) := by
    rw [step_private_data_eq F s (R.a owner) (R.a brand) name targetValue targetFrames targetControl targetStack targetField]
    rfl
  have same := congrArg Prod.fst (Option.some.inj (targetRun.symm.trans actual))
  dsimp only at same
  rw [same] at post
  have sourceStack := inventory.source.stack
  have targetStackRole := inventory.target.stack
  rw [stackNotes,stack,List.map_cons] at sourceStack
  rw [stackNotes,targetStack,List.map_cons] at targetStackRole
  exact ⟨targetValue,targetFrames,sourceRun,actual,post,
    ⟨inventory.keyLive,⟨returnNote_holds sourceRole,sourceStack.tail,inventory.source.cells⟩,
      ⟨returnNote_holds targetRole,targetStackRole.tail,inventory.target.cells⟩⟩,
    privateInventory.frame (fun _ h => h) (fun _ _ _ => rfl) (fun _ _ _ => rfl)⟩
end Host.Ts.Owned.Annotated
