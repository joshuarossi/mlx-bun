import host.mlx.NativeMetadataFrontend
import host.ts.RenameRuntimeDerivedCuts
set_option Elab.async false
namespace Host.Ts.Owned.Annotated.Driver
open Lean Elab Command Meta

/-- Materialize one original readonly metadata transition. This fixed allowlist
cannot enter graph inference, replay, allocation or a user-provided FFI. -/
elab "host_derive_metadata_cut " f:term ", " start:term " using " server:term " as " name:ident : command => liftTermElabM do
  let pre := (← getCurrNamespace) ++ name.getId
  let f ← Term.elabTermEnsuringType f (mkConst ``Ffi)
  unless ← isDefEq f (mkConst ``Host.Load.ffi) do throwError "metadata source cut: expected original load FFI"
  let stateTy := mkApp (mkConst ``St) (mkApp (mkConst ``Ffi.S) f)
  let source ← Term.elabTermEnsuringType start stateTy
  let server ← Term.elabTermEnsuringType server (mkConst ``SSrv)
  let ctl ← whnf (← mkAppM ``St.ctl #[source])
  let fn ← Parametric.Driver.field (← Parametric.Driver.field ctl ``Ctl.call 3 0) ``Val.obj 1 0
  let object ← Parametric.Driver.field (← mkAppM ``St.obj? #[source,fn]) ``Option.some 2 1
  let code ← Parametric.Driver.field (← mkAppM ``Obj.kind #[object]) ``Kind.fn 1 0
  let native ← Parametric.Driver.field code ``Code.native 2 0
  let builtin ← Parametric.Driver.field native ``Native.ffi 1 0
  unless (← whnf builtin).isConstOf ``FfiN.symbol do throwError "metadata source cut: expected original symbol"
  let captures ← Parametric.Driver.field code ``Code.native 2 1
  let symbol ← Parametric.Driver.field (← Parametric.Driver.field captures ``List.cons 3 1) ``Val.str 1 0
  let mut allowed := false
  for raw in [chars!"mlx_array_ndim",chars!"mlx_array_shape",chars!"mlx_array_dtype",chars!"mlx_array_size"] do
    if ← isDefEq symbol (toExpr raw) then allowed := true
  unless allowed do throwError "metadata source cut: source symbol is not readonly metadata"
  for (tag,value) in [("F",f),("s0",source),("S0",server)] do
    Parametric.Driver.addData (pre ++ Name.mkSimple tag) value
  let source := mkConst (pre ++ `s0)
  let server := mkConst (pre ++ `S0)
  let run ← mkAppM ``interpS #[← mkAppM ``M.run #[← mkAppM ``step #[f,source]],server]
  let result ← whnf run
  let pair ← Parametric.Driver.field result ``Option.some 2 1
  let nextState ← whnf (← Parametric.Driver.field pair ``Prod.mk 4 2)
  unless nextState.getAppFn.isConstOf ``St.mk do throwError "metadata source cut: expected state record"
  let mut fields := nextState.getAppArgs
  for i in List.range (fields.size-1) do
    let tag := pre ++ Name.mkSimple s!"state1part{i}"
    Parametric.Driver.addData tag fields[i+1]!
    fields := fields.set! (i+1) (mkConst tag)
  Parametric.Driver.addData (pre ++ `s1) (mkAppN nextState.getAppFn fields) (some stateTy)
  Parametric.Driver.addData (pre ++ `S1) (← Parametric.Driver.field pair ``Prod.mk 4 3)
  let success ← mkAppM ``Option.some #[← mkAppM ``Prod.mk #[mkConst (pre ++ `s1),mkConst (pre ++ `S1)]]
  addDecl (.thmDecl {name:=pre ++ `source_step,levelParams:=[],type:=← mkEq run success,value:=← mkEqRefl run})
end Host.Ts.Owned.Annotated.Driver
