import host.sim.template.FullWorld
set_option Elab.async false
namespace Host.Ts.Sim.Template
open Lean Elab Command Meta Host.Ts Host.Ts.Stream

/-- Choose candidates with a canonical nonnegative row quantity retained. Every
changed table, oracle and transition still passes the ordinary kernel checks. -/
elab "tpl_stream_bind_rows " p:ident " through " last:num : command => liftTermElabM do
  let pre := (← getCurrNamespace) ++ p.getId
  let dir ← streamDir
  let z : SymE := .lit (F64.zero false)
  let old : SymE := .bin .add z (.bin .sub (.bin .sub (.var 9) z) (.lit (F64.ofNat 1)))
  let needle := toExpr old
  let row := toExpr (SymE.var 10)
  let numbers (e : Lean.Expr) := e.replace fun e => if e == needle then some row else none
  let oldOracle := pre ++ `O
  let oracle := pre ++ `OR
  let oi ← getConstInfo oldOracle
  let some value := oi.value? | throwError "stream_bind_rows: oracle has no data body"
  addDecl (.defnDecl (mkDefinitionValEx oracle [] oi.type (numbers value) (.regular 0) .safe [oracle]))
  let patch (e : Lean.Expr) := (numbers e).replace fun e =>
    if e.isConstOf oldOracle then some (mkConst oracle) else none
  let mut changed : Nat := 0
  let total : Nat := last.getNat + 1
  for i in [0:total] do
    let file := fileOf dir pre i
    let roots ← match readRoots (← IO.FS.readBinFile file) with
      | .ok roots => pure roots
      | .error message => throwError "stream_bind_rows: {file}: {message}"
    let result : Roots := { roots with
      defs := roots.defs.map fun (n, t, v) => (n, t, patch v)
      st := patch roots.st
      srv := patch roots.srv }
    if result.defs != roots.defs || result.st != roots.st || result.srv != roots.srv then
      IO.FS.writeBinFile file (writeRoots result)
      changed := changed + 1
  logInfo m!"stream_bind_rows {pre}: retained row variable 10 in {changed}/{total} candidate files"

end Host.Ts.Sim.Template
