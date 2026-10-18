import host.ts.RenameRouteDriver
import host.ts.RenameRuntimeSourceCut

set_option Elab.async false
namespace Host.Ts.Owned.Annotated.Driver
open Lean Elab Command Meta

/-- Derive a small host-only source region by ordinary symbolic reduction.
Each state field is named before the next lookup, preserving sharing. This
command does not cross a native MLX symbol call; those use retained cuts. Every
selected source success equation is submitted to the kernel. -/
elab "host_derive_source_cuts " f:term ", " start:term " using " server:term " steps " count:num " as " name:ident : command => liftTermElabM do
  let count := count.getNat
  unless 0 < count && count ≤ 25 do throwError "derived source cuts: expected between 1 and 25 steps"
  let pre := (← getCurrNamespace) ++ name.getId
  let f ← Term.elabTermEnsuringType f (mkConst ``Ffi)
  let stateType := mkApp (mkConst ``St) (mkApp (mkConst ``Ffi.S) f)
  let source ← Term.elabTermEnsuringType start stateType
  let server ← Term.elabTermEnsuringType server (mkConst ``SSrv)
  let add (name : Lean.Name) (value : Lean.Expr) (type? : Option Lean.Expr := none) : TermElabM Unit := do
    let value ← instantiateMVars value
    let type ← instantiateMVars (← match type? with | some type => pure type | none => inferType value)
    Parametric.Driver.addData name value (some type)
  add (pre ++ `F) f
  add (pre ++ `s0) source (some stateType)
  add (pre ++ `S0) server (some (mkConst ``SSrv))
  for i in List.range count do
    let source := mkConst (pre ++ Name.mkSimple s!"s{i}")
    let server := mkConst (pre ++ Name.mkSimple s!"S{i}")
    let control ← whnf (← mkAppM ``St.ctl #[source])
    if control.isAppOfArity ``Ctl.call 3 then
      let callee ← whnf control.getAppArgs[0]!
      if callee.isAppOfArity ``Val.obj 1 then
        let object ← whnf (← mkAppM ``St.obj? #[source,callee.getAppArgs[0]!])
        if object.isAppOfArity ``Option.some 2 then
          let kind ← whnf (← mkAppM ``Obj.kind #[object.getAppArgs[1]!])
          if kind.isAppOfArity ``Kind.fn 1 then
            let code ← whnf kind.getAppArgs[0]!
            if code.isAppOfArity ``Code.native 2 then
              let native ← whnf code.getAppArgs[0]!
              if native.isAppOfArity ``Native.ffi 1 &&
                  (← whnf native.getAppArgs[0]!).isConstOf ``FfiN.symbol then
                throwError "derived source cuts: original native symbol at step {i} requires a materialized cut"
    let program ← mkAppM ``M.run #[← mkAppM ``step #[f,source]]
    let run ← mkAppM ``interpS #[program,server]
    let result ← whnf run
    unless result.isAppOfArity ``Option.some 2 do
      throwError "derived source cuts: original source transition {i} did not succeed"
    let pair ← whnf result.getAppArgs[1]!
    unless pair.isAppOfArity ``Prod.mk 4 do throwError "derived source cuts: malformed source result"
    let nextState ← whnf pair.getAppArgs[2]!
    unless nextState.getAppFn.isConstOf ``St.mk do throwError "derived source cuts: source state is not a record"
    let mut fields := nextState.getAppArgs
    for field in List.range (fields.size-1) do
      let tag := pre ++ Name.mkSimple s!"state{i+1}part{field}"
      add tag fields[field+1]!
      fields := fields.set! (field+1) (mkConst tag)
    add (pre ++ Name.mkSimple s!"s{i+1}") (mkAppN nextState.getAppFn fields) (some stateType)
    add (pre ++ Name.mkSimple s!"S{i+1}") pair.getAppArgs[3]! (some (mkConst ``SSrv))
    let reached ← mkAppM ``Prod.mk #[mkConst (pre ++ Name.mkSimple s!"s{i+1}"),mkConst (pre ++ Name.mkSimple s!"S{i+1}")]
    let success ← mkAppM ``Option.some #[reached]
    let type ← mkEq run success
    addDecl (.thmDecl {name:=pre ++ Name.mkSimple s!"source_step{i}",levelParams:=[],type,value:=← mkEqRefl run})
end Host.Ts.Owned.Annotated.Driver
