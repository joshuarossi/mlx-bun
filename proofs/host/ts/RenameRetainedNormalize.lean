import host.ts.RenameRetainedInventory
import Lean.Elab.Tactic

set_option Elab.async false
namespace Host.Ts.Owned.Annotated.Driver
open Lean Elab Meta Tactic

private def dataStructure (name : Lean.Name) : Bool :=
  #[``St,``Aux,``RetainedNotes,``RuntimeNotes,``Notes,``PrivateNotes,``NativeCaptureNotes,
    ``ArrayNotes,``PublicNotes,``BufferNotes].contains name

/-- Reduce only projections of runtime/inventory records. In particular the
selected heap, native state, and note-map functions are not evaluated. -/
private def projectData (expression : Lean.Expr) : MetaM Lean.Expr :=
  Meta.transform expression (pre := fun expression => do
    if let .proj name index object := expression then
      if dataStructure name then
        if let some value ← projectCore? (← whnf object) index then return .visit value
    if let some value ← reduceProjOf? expression dataStructure then return .visit value
    return .continue) (skipConstInApp := true)

private def flatState (expression : Lean.Expr) : MetaM Lean.Expr := do
  let reduced ← whnf expression
  unless reduced.getAppFn.isConstOf ``St.mk do return expression
  projectData reduced

/-- Flatten current symbolic state/inventory records in a local proof context.
Both replacements use the ordinary definitional-equality check. The returned
goal retains the same proof-variable IDs and all original logical premises. -/
def normalizeRetainedLocals (goal : MVarId) (stateProof inventoryProof : Lean.Expr) : MetaM MVarId :=
  goal.withContext do
    unless stateProof.isFVar && inventoryProof.isFVar do throwError "expected local current invariant proofs"
    let stateType := (← instantiateMVars (← inferType stateProof)).consumeMData.headBeta.consumeMData
    let inventoryType := (← instantiateMVars (← inferType inventoryProof)).consumeMData.headBeta.consumeMData
    unless stateType.getAppFn.isConstOf ``Parametric.StateR &&
        inventoryType.getAppFn.isConstOf ``RetainedInventory do
      throwError "expected a full StateR and all six retained families, got {stateType.getAppFn} / {inventoryType.getAppFn}"
    let arguments := stateType.getAppArgs
    let source := arguments[arguments.size-2]!
    let target := arguments.back!
    let sourceFlat ← flatState source
    let targetFlat ← flatState target
    let replaceStates (type : Lean.Expr) := type.replace fun e =>
      if e == source then some sourceFlat else if e == target then some targetFlat else none
    let newStateType ← projectData (replaceStates stateType)
    let newInventoryType ← projectData (replaceStates inventoryType)
    let goal ← goal.changeLocalDecl stateProof.fvarId! newStateType
    goal.changeLocalDecl inventoryProof.fvarId! newInventoryType

/-- Normalize the current symbolic record updates before composing a rule. -/
elab "host_normalize_retained " state:ident ", " inventory:ident : tactic => do
  let goal ← getMainGoal
  let stateProof ← elabTerm state none
  let inventoryProof ← elabTerm inventory none
  let goal ← normalizeRetainedLocals goal stateProof inventoryProof
  replaceMainGoal [goal]

end Host.Ts.Owned.Annotated.Driver
