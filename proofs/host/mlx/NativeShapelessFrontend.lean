import host.mlx.OrdinaryShapelessRetained
import host.ts.RenameRouteDriver

set_option Elab.async false

namespace Host.Ts.Owned.Annotated.Driver
open Lean Elab Command Meta
open Parametric.Driver
open Host.Load.Run.Full.Ordinary

/-- Select the checked ordinary shapeless cached-call summary from the original source.
The exported theorem keeps the current strong native invariant and producer
policy. The source equation for the supplied numeric tables is derived and
kernel-checked here; it is not an extra premise of the adapter. -/
elab "host_retained_shapeless " f:term ", " s:term " using " initial:term " to " t:term " using " next:term " as " name:ident : command => do
  let pre := (← getCurrNamespace) ++ name.getId
  liftTermElabM do
    let f ← Term.elabTermEnsuringType f (mkConst ``Ffi)
    let stateTy := mkApp (mkConst ``St) (mkApp (mkConst ``Ffi.S) f)
    let s ← Term.elabTermEnsuringType s stateTy
    let t ← Term.elabTermEnsuringType t stateTy
    let ctl ← whnf (← mkAppM ``St.ctl #[s])
    unless ctl.isAppOfArity ``Ctl.call 3 do throwError "host_retained_shapeless: expected source call"
    let address ← field ctl.getAppArgs[0]! ``Val.obj 1 0
    let object ← field (← mkAppM ``St.obj? #[s,address]) ``Option.some 2 1
    let code ← whnf (← field (← mkAppM ``Obj.kind #[object]) ``Kind.fn 1 0)
    let native ← whnf (← field code ``Code.native 2 0)
    let ffi ← whnf (← field native ``Native.ffi 1 0)
    unless ffi.isConstOf ``FfiN.symbol do throwError "host_retained_shapeless: expected FFI symbol"
    let captures := code.getAppArgs[1]!
    let symbol ← field (← field captures ``List.cons 3 1) ``Val.str 1 0
    unless ← isDefEq symbol (mkConst ``CachedFamilyHost.symbol) do
      throwError "host_retained_shapeless: expected mlx_closure_apply"
    let rest ← field ctl.getAppArgs[2]! ``List.cons 3 2
    let closureValue ← whnf (← field rest ``List.cons 3 1)
    unless closureValue.isAppOfArity ``Val.big 1 do
      throwError "host_retained_shapeless: expected owned closure handle"
    unless ← isDefEq closureValue.getAppArgs[0]! (mkApp (mkConst ``Int.ofNat) (mkRawNatLit 18194)) do
      throwError "host_retained_shapeless: expected checked closure18194"
    let mut arguments := ctl.getAppArgs[2]!
    for _ in [:3] do
      arguments ← field arguments ``List.cons 3 2
    unless (← whnf arguments).isAppOfArity ``List.nil 1 do
      throwError "host_retained_shapeless: expected exactly three arguments"
    for (tag,value) in [("F",f),("input",s),("output",t)] do
      let type? := if tag == "input" || tag == "output" then
        some (mkApp (mkConst ``St) (mkApp (mkConst ``Ffi.S) (mkConst (pre ++ `F)))) else none
      addData (pre ++ Name.mkSimple tag) value type?
    let initial ← Term.elabTermEnsuringType initial (mkConst ``SSrv)
    let next ← Term.elabTermEnsuringType next (mkConst ``SSrv)
    addData (pre ++ `initialServer) (← mkAppM ``numberServer #[initial])
    addData (pre ++ `nextServer) (← mkAppM ``numberServer #[next])
    let substitutions : List (Lean.Name × Lean.Name) := [
      (``ShapelessHost.F,pre ++ `F),(``ShapelessHost.input,pre ++ `input),(``ShapelessHost.output,pre ++ `output),
      (``ShapelessHost.initialServer,pre ++ `initialServer),(``ShapelessHost.nextServer,pre ++ `nextServer)]
    for (original,tag) in [(``ShapelessHost.source_run,`source_run),(``ShapelessHost.source_step,`source_step),
      (``ShapelessHost.retained_transport,`retained_transport)] do
      let info ← getConstInfo original
      let type := info.type.replace fun expression =>
        match expression with
        | .const constant levels => substitutions.find? (fun item => item.1 == constant) |>.map (fun item => mkConst item.2 levels)
        | _ => none
      let value ← if tag == `source_step then
          let program ← mkAppM ``M.run #[← mkAppM ``step #[mkConst ``ShapelessHost.F,mkConst ``ShapelessHost.input]]
          let run ← mkAppM ``interpS #[program,mkConst (pre ++ `initialServer)]
          let result ← mkAppM ``Option.some #[← mkAppM ``Prod.mk #[mkConst ``ShapelessHost.output,mkConst (pre ++ `nextServer)]]
          let sourceType ← mkEq run result
          let proof ← Term.elabTermEnsuringType (← `(by rw [ShapelessHost.source_native_step]; host_kernel_rfl)) sourceType
          Term.synthesizeSyntheticMVarsNoPostponing
          instantiateMVars proof
        else if tag == `retained_transport then
          pure (mkAppN (mkConst ``ShapelessHost.retained_transport_servers)
            #[mkConst (pre ++ `initialServer),mkConst (pre ++ `nextServer),mkConst (pre ++ `source_step)])
        else pure (mkConst original (info.levelParams.map Level.param))
      addDecl (.thmDecl {name := pre ++ tag,levelParams := info.levelParams,type := type,value := value})

end Host.Ts.Owned.Annotated.Driver
