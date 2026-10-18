import host.ts.RenameRetainedNormalize

set_option Elab.async false
namespace Host.Ts.Owned.Annotated.NormalizeTests
open Parametric

/-- Normalized proof aliases coexist with old proof-dependent locals. The
kernel checks both alias applications and the retained old dependency. -/
theorem dependent_aliases {F : Ffi} {FR : Ren → F.S → F.S → Prop} {notes : RetainedNotes}
    {ν₀ ν : Nat → F64} {C₀ C : CSrv} {R : Ren} {live framed : Nat → Prop}
    {before after : List Val} {old old' : List Event} {source target : St F.S}
    (current : Parametric.StateR (NumberRoles ν₀ ν C₀ C) FR R live framed before after old old'
      (source.ret .undef) (target.ret .undef))
    (retained : RetainedInventory (notes.withRuntime notes.runtime) ν₀ ν C₀ C R live (source.ret .undef) (target.ret .undef))
    (dependent : current = current) :
    Parametric.StateR (NumberRoles ν₀ ν C₀ C) FR R live framed before after old old' (source.ret .undef) (target.ret .undef) ∧
      RetainedInventory (notes.withRuntime notes.runtime) ν₀ ν C₀ C R live (source.ret .undef) (target.ret .undef) ∧ current = current := by
  run_tac do
    let currentId ← Lean.Elab.Tactic.getFVarId (Lean.mkIdent `current)
    let retainedId ← Lean.Elab.Tactic.getFVarId (Lean.mkIdent `retained)
    let dependentId ← Lean.Elab.Tactic.getFVarId (Lean.mkIdent `dependent)
    let (goal,stateAlias,inventoryAlias) ← Driver.normalizeRetainedAliases (← Lean.Elab.Tactic.getMainGoal)
      (Lean.mkFVar currentId) (Lean.mkFVar retainedId)
    goal.withContext do
      let _ ← Lean.Meta.getFVarLocalDecl (Lean.mkFVar currentId)
      let _ ← Lean.Meta.getFVarLocalDecl (Lean.mkFVar retainedId)
      let _ ← Lean.Meta.getFVarLocalDecl (Lean.mkFVar dependentId)
      goal.assign (← Lean.Meta.mkAppM ``And.intro #[stateAlias,
        ← Lean.Meta.mkAppM ``And.intro #[inventoryAlias,Lean.mkFVar dependentId]])
    Lean.Elab.Tactic.replaceMainGoal []

end Host.Ts.Owned.Annotated.NormalizeTests
