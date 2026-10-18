import host.load.RuntimeNamespacedDtypeCuts
import host.mlx.NativeDtypeFrontend
import host.ts.RenameLoopVariableNamespace
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 1000000
namespace Host.Load.Run.Full.Ordinary.DtypeSource
open Host.Ts Host.Ts.Owned Host.Ts.Owned.Annotated
open Lean Elab Command Meta in
run_cmd liftTermElabM do
  let source := mkConst ``From4450.s21
  let ctl ← whnf (← mkAppM ``St.ctl #[source])
  let args ← Parametric.Driver.field ctl ``Ctl.call 3 2
  let arg ← Parametric.Driver.field args ``List.cons 3 1
  let handle ← mkAppM ``Int.toNat #[← Parametric.Driver.field arg ``Val.big 1 0]
  let mlx ← mkAppM ``Host.Load.LSt.mlx #[← mkAppM ``St.ffi #[source]]
  let node ← Parametric.Driver.field (← mkAppM ``Host.Mlx.Ffi.St.node? #[mlx,handle]) ``Option.some 2 1
  let dtype ← mkAppM ``Host.Mlx.Ffi.Node.dtype #[node]
  let value := mkApp (mkConst ``NumV.lit) (← mkAppM ``F64.ofNat #[dtype])
  let arg := mkApp (mkConst ``Arg.big) (← Parametric.Driver.field arg ``Val.big 1 0)
  let args ← mkAppM ``List.cons #[arg,mkApp (mkConst ``List.nil [Level.zero]) (mkConst ``Arg)]
  let output ← mkAppM ``finishNumber #[source,← mkAppM ``St.ffi #[source],toExpr chars!"mlx_array_dtype",args,value]
  let pre ← getCurrNamespace
  Parametric.Driver.addData (pre ++ `output) output
host_retained_dtype P.F, From4450.s21 using
  (From4450.S21.substitute LoopVariables.oracleVariables) to output using
  (From4450.S21.substitute LoopVariables.oracleVariables) as Source4471

open Lean Elab Command in
run_cmd do
  let saved : Lean.Elab.Command.State ← get
  let mut rejected := false
  try Parametric.Driver.emit "host_retained_dtype P.F, From4450.s21 using (From4450.S21.substitute LoopVariables.oracleVariables) to output.ret .undef using (From4450.S21.substitute LoopVariables.oracleVariables) as WrongReturn"
  catch exception =>
    rejected := ((← exception.toMessageData.toString).splitOn "kernel").length > 1
  for message in (← get).messages.toList do
    if ((← message.data.toString).splitOn "kernel").length > 1 then rejected := true
  set saved
  unless rejected do throwError "incorrect dtype return was not rejected by kernel"
end Host.Load.Run.Full.Ordinary.DtypeSource
