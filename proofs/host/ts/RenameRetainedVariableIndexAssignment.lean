import host.ts.RenameCachedArrayEntryAssignment
import host.ts.RenameParametricArrayBuffer

set_option Elab.async false
namespace Host.Ts.Owned.Annotated
open Parametric CachedArrayEntry

/-- The original indexed assignment evaluates both local variables before
entering its right-hand side. The index is the currently stored literal. -/
theorem variable_index_assignment_run (F : Ffi) (s : St F.S) (C : CSrv)
    (name indexName : Name) (cell indexCell owner index : Nat) (x : F64)
    (rhs : Expr) (env : Env) (opt : Bool)
    (control : s.ctl = .ev (.assign .assign (.expr (.index (.id name) (.id indexName) opt)) rhs) env)
    (lookup : lookupEnv name env = some cell) (indexLookup : lookupEnv indexName env = some indexCell)
    (read : s.heap.get cell = some (.cell (some (.obj owner))))
    (indexRead : s.heap.get indexCell = some (.cell (some (.num (.lit x)))))
    (valid : F64.toIndex? x = some index) :
    runC F 5 s C = some (indexAssignmentResult s owner index rhs env,C) := by
  simp only [runC,runWith_succ,runWith_zero,control,isHalt,Bool.cond_false,step,evStep,evAssign,
    St.push,St.go,St.ret,readVar,lookup,indexLookup,St.cell?,read,indexRead,retS,stepRet,retStep,retA,
    numIndex,valid,asgTarget,M.run,M.pure,interpC_pure,St.rebuild_eq,indexAssignmentResult]

/-- Derive the target receiver and literal index from the current related
heap and current index-cell note. No target operand or future note is supplied. -/
theorem RetainedInventory.variable_index_assignment
    {F : Ffi} {FR : Ren → F.S → F.S → Prop}
    {notes : RetainedNotes} {ν₀ ν : Nat → F64} {C₀ C : CSrv} {R : Ren}
    {live framed : Nat → Prop} {before after : List Val} {old old' : List Event} {source target : St F.S}
    (inventory : RetainedInventory notes ν₀ ν C₀ C R live source target)
    (h : Parametric.StateR (NumberRoles ν₀ ν C₀ C) FR R live framed before after old old' source target)
    (name indexName : Name) (cell indexCell owner index : Nat) (x : F64)
    (rhs : Expr) (env : Env) (opt : Bool)
    (control : source.ctl = .ev (.assign .assign (.expr (.index (.id name) (.id indexName) opt)) rhs) env)
    (lookup : lookupEnv name env = some cell) (indexLookup : lookupEnv indexName env = some indexCell)
    (read : source.heap.get cell = some (.cell (some (.obj owner))))
    (indexRead : source.heap.get indexCell = some (.cell (some (.num (.lit x)))))
    (valid : F64.toIndex? x = some index)
    (indexNote : notes.runtime.cells.cells indexCell = some (.literal (.lit x))) :
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
  have indexLive := env_lookup_live indexName env indexCell envLive.2.1 indexLookup
  obtain ⟨value,targetRead,relation,ownerLive⟩ := h.heap.readCell cell (.obj owner) cellLive read
  cases relation
  obtain ⟨indexValue,targetIndexRead,indexRelation,_⟩ :=
    h.heap.readCell indexCell (.num (.lit x)) indexLive indexRead
  have held := inventory.runtime.target.cells indexCell (.literal (.lit x)) indexNote
  have exactIndex : indexValue = .num (.lit x) := by
    apply fixed_literal_value
    simpa only [cellValueAt,targetIndexRead] using held
  rw [exactIndex] at targetIndexRead
  have targetControl := (h.control_view control).ev_view
  have targetLookup : lookupEnv name (R.env env) = some (R.a cell) := by rw [lookupEnv_map,lookup]; rfl
  have targetIndexLookup : lookupEnv indexName (R.env env) = some (R.a indexCell) := by rw [lookupEnv_map,indexLookup]; rfl
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
  exact ⟨variable_index_assignment_run F source C₀ name indexName cell indexCell owner index x rhs env opt
      control lookup indexLookup read indexRead valid,
    variable_index_assignment_run F target C name indexName (R.a cell) (R.a indexCell) (R.a owner) index x rhs (R.env env) opt
      targetControl targetLookup targetIndexLookup targetRead targetIndexRead valid,
    post,inventory.heap_step runtime rfl rfl (.refl C₀) (.refl C)⟩

end Host.Ts.Owned.Annotated
