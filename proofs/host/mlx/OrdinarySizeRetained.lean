import host.load.RuntimeNamespacedSizeCuts
import host.mlx.NativeSizeFrontend
import host.ts.RenameLoopVariableNamespace
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 1000000
namespace Host.Load.Run.Full.Ordinary.SizeSource
open Host.Ts Host.Ts.Owned Host.Ts.Owned.Annotated
open Lean Elab Command Meta in
run_cmd liftTermElabM do
  let source := mkConst ``From9325.s12
  let ctl ← whnf (← mkAppM ``St.ctl #[source])
  let args ← Parametric.Driver.field ctl ``Ctl.call 3 2
  let arg ← Parametric.Driver.field args ``List.cons 3 1
  let handle ← mkAppM ``Int.toNat #[← Parametric.Driver.field arg ``Val.big 1 0]
  let mlx ← mkAppM ``Host.Load.LSt.mlx #[← mkAppM ``St.ffi #[source]]
  let node ← Parametric.Driver.field (← mkAppM ``Host.Mlx.Ffi.St.node? #[mlx,handle]) ``Option.some 2 1
  let dims ← Parametric.Driver.field (← mkAppM ``Host.Mlx.Ffi.natsOfDims #[← mkAppM ``Host.Mlx.Ffi.Node.shape #[node]]) ``Option.some 2 1
  let value ← mkAppM ``Host.Load.Run.Full.Ordinary.SizeHost.product #[dims]
  let arg := mkApp (mkConst ``Arg.big) (← Parametric.Driver.field arg ``Val.big 1 0)
  let args ← mkAppM ``List.cons #[arg,mkApp (mkConst ``List.nil [Level.zero]) (mkConst ``Arg)]
  let output ← mkAppM ``finishBig #[source,← mkAppM ``St.ffi #[source],toExpr chars!"mlx_array_size",args,value]
  let pre ← getCurrNamespace
  Parametric.Driver.addData (pre ++ `output) output
host_retained_size P.F, From9325.s12 using
  (From9325.S12.substitute LoopVariables.oracleVariables) to output using
  (From9325.S12.substitute LoopVariables.oracleVariables) as Source9337

open Lean Elab Command in
run_cmd do
  let saved : Lean.Elab.Command.State ← get
  let mut rejected := false
  try Parametric.Driver.emit "host_retained_size P.F, From9325.s12 using (From9325.S12.substitute LoopVariables.oracleVariables) to output.ret .undef using (From9325.S12.substitute LoopVariables.oracleVariables) as WrongReturn"
  catch exception =>
    rejected := ((← exception.toMessageData.toString).splitOn "kernel").length > 1
  for message in (← get).messages.toList do
    if ((← message.data.toString).splitOn "kernel").length > 1 then rejected := true
  set saved
  unless rejected do throwError "incorrect size return was not rejected by kernel"
end Host.Load.Run.Full.Ordinary.SizeSource
