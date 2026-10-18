import host.ts.RenameRuntimeDriverStep
import Lean.Util.FoldConsts
set_option Elab.async false
namespace Host.Ts.Owned.Annotated.Driver
open Lean Elab Command Meta

private initialize batchState : IO.Ref (Option Command.State) ← IO.mkRef none

private partial def dependencyOrder (original current : Environment) (name : Lean.Name)
    (seen : NameSet) (ordered : Array ConstantInfo) : CommandElabM (NameSet × Array ConstantInfo) := do
  if original.contains name || seen.contains name then return (seen,ordered)
  let some info := current.find? name | throwError "host_runtime_export: missing helper {name}"
  unless info.levelParams.isEmpty do
    throwError "host_runtime_export: polymorphic helper {name} requires explicit specialization"
  let some value := info.value? (allowOpaque := true) | throwError "host_runtime_export: helper {name} has no checked value"
  let mut seen := seen.insert name
  let mut ordered := ordered
  for dependency in info.type.getUsedConstants ++ value.getUsedConstants do
    let result ← dependencyOrder original current dependency seen ordered
    seen := result.1
    ordered := result.2
  return (seen,ordered.push info)

private def replaceHelpers (mapping : Lean.NameMap Lean.Expr) (value : Lean.Expr) : Lean.Expr :=
  value.replace fun expression => match expression with
    | .const name [] => mapping.find? name
    | _ => none

private partial def localProof (ordered : Array ConstantInfo) (index : Nat)
    (mapping : Lean.NameMap Lean.Expr) (locals : Array Lean.Expr) (name : Lean.Name) : MetaM Lean.Expr := do
  if h : index < ordered.size then
    let info := ordered[index]
    let some value := info.value? (allowOpaque := true) | throwError "host_runtime_export: missing checked helper value"
    withLetDecl info.name (replaceHelpers mapping info.type) (replaceHelpers mapping value) fun fv =>
      localProof ordered (index+1) (mapping.insert info.name fv) (locals.push fv) name
  else
    let some result := mapping.find? name | throwError "host_runtime_export: selected proof was not collected"
    mkLetFVars locals result (usedLetOnly := false) (generalizeNondepLet := false)

/-- Begin a bounded proof-generation chunk. Its temporary declarations remain
kernel checked, but are made local to the final exported theorem. -/
elab "host_runtime_begin" : command => do
  unless (← batchState.get).isNone do throwError "host_runtime_begin: a chunk is already active"
  batchState.set (some (← get))

/-- Export a checked composition theorem with its temporary helpers closed as
let-bound proof locals, then restore the pre-chunk environment. This limits
persistent declaration growth without adding a new logical inference rule. -/
elab "host_runtime_export " selected:ident " as " exported:ident : command => do
  let some saved ← batchState.get | throwError "host_runtime_export: no active chunk"
  let selected ← liftTermElabM do
    let expression ← Term.elabTerm selected none
    unless expression.isConst do throwError "host_runtime_export: expected a named theorem"
    pure expression.constName!
  let current ← getEnv
  let some info := current.find? selected | throwError "host_runtime_export: selected theorem is missing"
  unless info.isTheorem do throwError "host_runtime_export: selected declaration is not a theorem"
  let (_,ordered) ← dependencyOrder saved.env current selected {} #[]
  let (type,value) ← liftTermElabM do
    let value ← localProof ordered 0 {} #[] selected
    let type ← inferType value
    unless !value.hasFVar && !value.hasMVar && !type.hasFVar && !type.hasMVar do
      throwError "host_runtime_export: generated proof is not closed"
    pure (type,value)
  let exportedName := (← getCurrNamespace) ++ exported.getId
  set saved
  liftTermElabM do addDecl (.thmDecl {name := exportedName,levelParams := [],type,value})
  batchState.set none

elab "host_runtime_abort" : command => do
  let some saved ← batchState.get | throwError "host_runtime_abort: no active chunk"
  set saved
  batchState.set none

end Host.Ts.Owned.Annotated.Driver
