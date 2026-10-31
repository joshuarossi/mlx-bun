import host.sim.template.FullWorld
set_option Elab.async false
namespace Host.Ts.Sim.Template
open Lean Elab Command Meta Host.Ts Host.Ts.Stream

/-- Choose streamed candidates with the fixed load cut's two lookaheads restored.
The existing kernel checks must be rerun after changing these candidate files. -/
elab "tpl_stream_keep_lookahead " p:ident " through " last:num : command => liftTermElabM do
  let pre := (← getCurrNamespace) ++ p.getId
  let dir ← streamDir
  let tokens := toExpr ([NumV.ref 1, NumV.ref 2] : List NumV)
  let patch (e : Lean.Expr) := e.replace fun e =>
    if e.isAppOfArity ``Host.Mlx.Ffi.St.mk 13 then
      some (mkAppN e.getAppFn (e.getAppArgs.set! 5 tokens))
    else none
  let mut changed : Nat := 0
  let total : Nat := last.getNat + 1
  for i in [0:total] do
    let file := fileOf dir pre i
    let roots ← match readRoots (← IO.FS.readBinFile file) with
      | .ok roots => pure roots
      | .error message => throwError "stream_keep_lookahead: {file}: {message}"
    let result : Roots := { roots with
      defs := roots.defs.map fun (n, t, v) => (n, t, patch v)
      st := patch roots.st }
    if result.defs != roots.defs || result.st != roots.st then
      IO.FS.writeBinFile file (writeRoots result)
      changed := changed + 1
  logInfo m!"stream_keep_lookahead {pre}: restored two references in {changed}/{total} candidate files"

end Host.Ts.Sim.Template
