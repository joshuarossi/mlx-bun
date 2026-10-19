import host.ts.RenameRetainedHeapFrame
import host.ts.RenameParametricPrivateAssign
import host.ts.RenameRouteComposition
import host.ts.RenameRuntimeStatements

set_option Elab.async false
namespace Host.Ts.Owned.Annotated.CachedArrayEntry
open Parametric

def indexPutNote (owner index : Nat) : Tree :=
  .node "Frame.a" [.node "AsgF.put" [.atom (Option BinOp) none,
    .node "Target.prop" [.value (.obj owner),.node "PKey.str" [.atom Name (F64.natStr index)]],.value .undef]]

def indexAssignmentResult {S : Type} (s : St S) (owner index : Nat) (rhs : Expr) (env : Env) : St S :=
  (s.push (.a (.put none (.prop (.obj owner) (.str (F64.natStr index))) .undef))).go (.ev rhs env)

/-- Five original steps schedule the receiver variable, parse the literal
index and enter the right-hand expression. No property is stored here. -/
theorem index_assignment_run (F : Ffi) (s : St F.S) (C : CSrv)
    (name : Name) (cell owner index : Nat) (raw : List Char) (x : F64) (rhs : Expr) (env : Env) (opt : Bool)
    (control : s.ctl = .ev (.assign .assign (.expr (.index (.id name) (.lit (.num raw)) opt)) rhs) env)
    (lookup : lookupEnv name env = some cell)
    (read : s.heap.get cell = some (.cell (some (.obj owner))))
    (parsed : F64.ofLit raw = some x) (valid : F64.toIndex? x = some index) :
    runC F 5 s C = some (indexAssignmentResult s owner index rhs env,C) := by
  simp only [runC,runWith_succ,runWith_zero,control,isHalt,Bool.cond_false,step,evStep,evAssign,
    St.push,St.go,St.ret,readVar,lookup,St.cell?,read,retS,stepRet,retStep,retA,
    evLit,parsed,numIndex,valid,asgTarget,M.run,M.pure,interpC_pure,St.rebuild_eq,indexAssignmentResult]

/-- Current environment ownership supplies the target receiver. The source
literal supplies the property key. Both runs and every resulting note are
derived before the right-hand side executes. -/
theorem retained_index_assignment {F : Ffi} {FR : Ren → F.S → F.S → Prop}
    {notes : RetainedNotes} {ν₀ ν : Nat → F64} {C₀ C : CSrv} {R : Ren}
    {live framed : Nat → Prop} {before after : List Val} {old old' : List Event} {source target : St F.S}
    (h : Parametric.StateR (NumberRoles ν₀ ν C₀ C) FR R live framed before after old old' source target)
    (inventory : RetainedInventory notes ν₀ ν C₀ C R live source target)
    (name : Name) (cell owner index : Nat) (raw : List Char) (x : F64) (rhs : Expr) (env : Env) (opt : Bool)
    (control : source.ctl = .ev (.assign .assign (.expr (.index (.id name) (.lit (.num raw)) opt)) rhs) env)
    (lookup : lookupEnv name env = some cell)
    (read : source.heap.get cell = some (.cell (some (.obj owner))))
    (parsed : F64.ofLit raw = some x) (valid : F64.toIndex? x = some index) :
    let sourcePost := indexAssignmentResult source owner index rhs env
    let targetPost := indexAssignmentResult target (R.a owner) index rhs (R.env env)
    runC F 5 source C₀ = some (sourcePost,C₀) ∧ runC F 5 target C = some (targetPost,C) ∧
      Parametric.StateR (NumberRoles ν₀ ν C₀ C) FR R live framed before after old old' sourcePost targetPost ∧
      RetainedInventory (notes.withRuntime ⟨expressionNote rhs env,indexPutNote owner index::notes.runtime.stack,notes.runtime.cells⟩)
        ν₀ ν C₀ C R live sourcePost targetPost := by
  dsimp only
  have envLive := h.controlLive
  rw [control] at envLive
  have cellLive := env_lookup_live name env cell envLive.2.1 lookup
  obtain ⟨value,targetRead,relation,ownerLive⟩ := h.heap.readCell cell (.obj owner) cellLive read
  cases relation
  have targetControl := (h.control_view control).ev_view
  have targetLookup : lookupEnv name (R.env env) = some (R.a cell) := by rw [lookupEnv_map,lookup]; rfl
  have frame : Parametric.FrameR (NumberRoles ν₀ ν C₀ C) R
      (.a (.put none (.prop (.obj owner) (.str (F64.natStr index))) .undef))
      (.a (.put none (.prop (.obj (R.a owner)) (.str (F64.natStr index))) .undef)) := by
    repeat constructor
  have frameLive : treeSupport live (Encode.frame (.a (.put none (.prop (.obj owner) (.str (F64.natStr index))) .undef))) :=
    ⟨⟨True.intro,⟨ownerLive,⟨True.intro,True.intro⟩,True.intro⟩,True.intro,True.intro⟩,True.intro⟩
  have post := (h.restack (.cons frame h.stack) ⟨frameLive,h.stackLive⟩).go
    (c := .ev rhs env) (c' := .ev rhs (R.env env))
    (.node _ (.cons (.atom _ _) (.cons (env_roles _ R env) .nil))) ⟨True.intro,envLive.2.1,True.intro⟩
  have note (ν : Nat → F64) (C : CSrv) (R : Ren) :
      (indexPutNote owner index).Holds ν C R
        (Encode.frame (.a (.put none (.prop (.obj (R.a owner)) (.str (F64.natStr index))) .undef))) := by
    repeat constructor
  have runtime : RuntimeInventory ⟨expressionNote rhs env,indexPutNote owner index::notes.runtime.stack,notes.runtime.cells⟩
      ν₀ ν C₀ C R live (indexAssignmentResult source owner index rhs env)
      (indexAssignmentResult target (R.a owner) index rhs (R.env env)) :=
    ⟨inventory.runtime.keyLive,
      ⟨expressionNote_source ν₀ C₀ rhs env,.cons (note ν₀ C₀ identity) inventory.runtime.source.stack,inventory.runtime.source.cells⟩,
      ⟨expressionNote_holds ν C R rhs env,.cons (note ν C R) inventory.runtime.target.stack,inventory.runtime.target.cells⟩⟩
  exact ⟨index_assignment_run F source C₀ name cell owner index raw x rhs env opt control lookup read parsed valid,
    index_assignment_run F target C name (R.a cell) (R.a owner) index raw x rhs (R.env env) opt targetControl targetLookup targetRead parsed valid,
    post,inventory.heap_step runtime rfl rfl (.refl C₀) (.refl C)⟩

end Host.Ts.Owned.Annotated.CachedArrayEntry
