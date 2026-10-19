import host.load.RuntimeOptIntCuts8100
import host.ts.RenameRetainedOptIntFrontend
import host.ts.RenameLoopVariableNamespace
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 1000000
namespace Host.Load.Run.Full.Ordinary.OptIntCases
open Host.Ts Host.Ts.Owned Host.Ts.Owned.Parametric Host.Ts.Owned.Annotated
noncomputable def input64 : St LSt := OptIntSource.From8175.s1
noncomputable def output64 : St LSt := optIntSourceOutput input64
host_retained_optInt P.F, input64 using (OptIntSource.From8175.S1.substitute LoopVariables.oracleVariables)
  to output64 using (OptIntSource.From8175.S1.substitute LoopVariables.oracleVariables) as Source8176

theorem actual_first_argument : Source8176.sourceNumber = 64 ∧ Source8176.address = 2731 := ⟨rfl,rfl⟩
theorem actual_first_return : output64.ctl = .ret (.big 4294967360) := by host_kernel_rfl
host_derive_source_cuts P.F, output64 using (OptIntSource.From8175.S1.substitute LoopVariables.oracleVariables) steps 8 as From8216
noncomputable def input4 : St LSt := From8216.s8
noncomputable def output4 : St LSt := optIntSourceOutput input4
host_retained_optInt P.F, input4 using From8216.S8 to output4 using From8216.S8 as Source8224

theorem actual_second_argument : Source8224.sourceNumber = 4 ∧ Source8224.address = 2731 := ⟨rfl,rfl⟩
theorem actual_second_return : output4.ctl = .ret (.big 4294967300) := by host_kernel_rfl

run_cmd Lean.Elab.Command.liftTermElabM do
  let info ←Lean.getConstInfo ``Source8176.retained_transport
  Lean.Meta.forallTelescopeReducing info.type fun binders _ => do
    let mut names : Array Lean.Name := #[]
    for binder in binders do names := names.push (←Lean.Meta.getFVarLocalDecl binder).userName
    for forbidden in [`targetValue,`targetParameter,`targetGlobal,`targetBigint,`targetRun,`postInventory] do
      if names.contains forbidden then throwError "optInt: future target premise remained"

open Lean Elab Command in
run_cmd do
  let saved : Lean.Elab.Command.State ← get
  let mut rejected := false
  try Host.Ts.Owned.Parametric.Driver.emit "host_retained_optInt P.F, input64 using (OptIntSource.From8175.S1.substitute LoopVariables.oracleVariables) to input64 using (OptIntSource.From8175.S1.substitute LoopVariables.oracleVariables) as RejectEndpoint"
  catch exception =>
    rejected := ((← exception.toMessageData.toString).splitOn "kernel").length > 1
  for message in (← get).messages.toList do
    if ((← message.data.toString).splitOn "kernel").length > 1 then rejected := true
  set saved
  unless rejected do throwError "incorrect optInt source/body/result was not rejected by the kernel"
end Host.Load.Run.Full.Ordinary.OptIntCases
