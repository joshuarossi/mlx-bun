import host.ts.RenameRetainedNullishAssignment
import host.ts.RenameParametricVariables
import host.ts.RenameParametricParameters
set_option Elab.async false
namespace Host.Ts.Owned.Annotated
open Parametric

def nullishVariableFrameNote (name : Name) (rhs : Expr) (env : Env) : Tree :=
  .node "Frame.a" [.node "AsgF.old" [.atom AsgOp (.log .nullish),
    .node "Target.var" [.atom Name name,environmentNote env],.atom Expr rhs,environmentNote env]]

theorem nullishVariableFrameNote_holds (ν : Nat → F64) (C : CSrv) (R : Ren)
    (name : Name) (rhs : Expr) (env : Env) :
    (nullishVariableFrameNote name rhs env).Holds ν C R
      (Encode.frame (.a (.old (.log .nullish) (.var name (R.env env)) rhs (R.env env)))) := by
  repeat first | exact environmentNote_holds ν C R env | constructor

theorem step_nullish_variable_eq (F : Ffi) (s : St F.S) (name : Name) (rhs : Expr)
    (env : Env) (cell : Nat) (value : Val)
    (control : s.ctl = .ev (.assign (.log .nullish) (.id name) rhs) env)
    (lookup : lookupEnv name env = some cell) (read : s.heap.get cell = some (.cell (some value))) :
    step F s = M.pure ((s.push (.a (.old (.log .nullish) (.var name env) rhs env))).ret value) := by
  simp only [step,control,evStep,evAssign,asgTarget,readTarget,readVar,lookup,St.cell?,St.push,read,retS]

theorem RetainedInventory.nullish_variable_object_step {F : Ffi} {FR : Ren → F.S → F.S → Prop}
    {notes : RetainedNotes} {ν₀ ν : Nat → F64} {C₀ C : CSrv} {R : Ren} {live framed : Nat → Prop}
    {before after : List Val} {old old' : List Event} {s₀ s : St F.S}
    (inventory : RetainedInventory notes ν₀ ν C₀ C R live s₀ s)
    (h : Parametric.StateR (NumberRoles ν₀ ν C₀ C) FR R live framed before after old old' s₀ s)
    (name : Name) (rhs : Expr) (env : Env) (cell owner : Nat)
    (control : s₀.ctl = .ev (.assign (.log .nullish) (.id name) rhs) env)
    (lookup : lookupEnv name env = some cell) (read : s₀.heap.get cell = some (.cell (some (.obj owner)))) :
    let t₀ := (s₀.push (.a (.old (.log .nullish) (.var name env) rhs env))).ret (.obj owner)
    let t := (s.push (.a (.old (.log .nullish) (.var name (R.env env)) rhs (R.env env)))).ret (.obj (R.a owner))
    interpC (step F s₀).run C₀ = some (t₀,C₀) ∧ interpC (step F s).run C = some (t,C) ∧
      Parametric.StateR (NumberRoles ν₀ ν C₀ C) FR R live framed before after old old' t₀ t ∧
      RetainedInventory (notes.withRuntime ⟨returnNote (.obj owner),nullishVariableFrameNote name rhs env::notes.runtime.stack,notes.runtime.cells⟩)
        ν₀ ν C₀ C R live t₀ t := by
  have targetControl := (h.control_view control).ev_view
  have controlLive := h.controlLive
  rw [control] at controlLive
  have envLive := controlLive.2.1
  have cellLive := env_lookup_live name env cell envLive lookup
  obtain ⟨value,targetRead,related,ownerLive⟩ := h.heap.readCell cell (.obj owner) cellLive read
  cases related
  have targetLookup : lookupEnv name (R.env env) = some (R.a cell) := by rw [lookupEnv_map,lookup]; rfl
  have frame : Parametric.FrameR (NumberRoles ν₀ ν C₀ C) R
      (.a (.old (.log .nullish) (.var name env) rhs env))
      (.a (.old (.log .nullish) (.var name (R.env env)) rhs (R.env env))) := by
    repeat first | exact env_roles (NumberRoles ν₀ ν C₀ C) R env | constructor
  have frameLive : treeSupport live (Encode.frame (.a (.old (.log .nullish) (.var name env) rhs env))) := by
    repeat first | exact envLive | trivial | constructor
  have post : Parametric.StateR (NumberRoles ν₀ ν C₀ C) FR R live framed before after old old'
      ((s₀.push (.a (.old (.log .nullish) (.var name env) rhs env))).ret (.obj owner))
      ((s.push (.a (.old (.log .nullish) (.var name (R.env env)) rhs (R.env env)))).ret (.obj (R.a owner))) :=
    (h.restack (.cons frame h.stack) ⟨frameLive,h.stackLive⟩).go
    (.node _ (.cons (.value (.obj owner)) .nil)) ⟨ownerLive,True.intro⟩
  have runtime : RuntimeInventory ⟨returnNote (.obj owner),nullishVariableFrameNote name rhs env::notes.runtime.stack,notes.runtime.cells⟩ ν₀ ν C₀ C R live
      ((s₀.push (.a (.old (.log .nullish) (.var name env) rhs env))).ret (.obj owner))
      ((s.push (.a (.old (.log .nullish) (.var name (R.env env)) rhs (R.env env)))).ret (.obj (R.a owner))) :=
    ⟨inventory.runtime.keyLive,
      ⟨returnNote_holds (.obj owner),.cons (by simpa only [identity_environment] using nullishVariableFrameNote_holds ν₀ C₀ identity name rhs env) inventory.runtime.source.stack,inventory.runtime.source.cells⟩,
      ⟨returnNote_holds (.obj owner),.cons (nullishVariableFrameNote_holds ν C R name rhs env) inventory.runtime.target.stack,inventory.runtime.target.cells⟩⟩
  refine ⟨?_,?_,post,inventory.heap_step runtime rfl rfl (.refl C₀) (.refl C)⟩
  · rw [step_nullish_variable_eq F s₀ name rhs env cell (.obj owner) control lookup read]; rfl
  · rw [step_nullish_variable_eq F s name rhs (R.env env) (R.a cell) (.obj (R.a owner)) targetControl targetLookup targetRead]; rfl
end Host.Ts.Owned.Annotated
