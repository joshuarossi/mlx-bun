import host.ts.RenameRuntimeDriverValues

set_option Elab.async false
namespace Host.Ts.Owned.Annotated.Driver
open Lean Elab Command Meta

structure NativeSourceRegistration where
  symbol : String
  command : String
deriving Inhabited, BEq

private def insertNativeSource (entries : Array NativeSourceRegistration)
    (entry : NativeSourceRegistration) : Array NativeSourceRegistration :=
  if entries.contains entry then entries else entries.push entry

/-- An optional source-command registry, independent of route snapshots.
Registrations select proof generators; they never certify a native operation.
Each selected generator still has to establish its original source equations
and complete transport theorem in the kernel. -/
initialize nativeSourceRegistry : SimplePersistentEnvExtension NativeSourceRegistration
    (Array NativeSourceRegistration) ← registerSimplePersistentEnvExtension {
  name := `nativeSourceRegistry
  addImportedFn := mkStateFromImportedEntries insertNativeSource #[]
  addEntryFn := insertNativeSource
}

elab "host_register_native_source " symbol:str " => " command:str : command => do
  let symbol := symbol.getString
  if symbol.isEmpty then throwError "native source registry: empty symbol"
  let command := command.getString
  if command.isEmpty then throwError "native source registry: empty command"
  let entry := {symbol,command : NativeSourceRegistration}
  modifyEnv fun env => nativeSourceRegistry.addEntry env entry

/-- Return only commands whose registered name equals the current source
symbol. More than one checked source specialization may implement a symbol;
the caller must restore command state between unsuccessful candidates. -/
def registeredNativeSourceCommands (symbol : Lean.Expr) : MetaM (Array String) := do
  let mut commands := #[]
  for entry in nativeSourceRegistry.getState (← getEnv) do
    let saved ← saveState
    let sameSymbol ← isDefEq symbol (toExpr entry.symbol.toList)
    saved.restore
    if sameSymbol then commands := commands.push entry.command
  return commands

end Host.Ts.Owned.Annotated.Driver
