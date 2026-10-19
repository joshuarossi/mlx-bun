import host.load.RuntimeNamespacedDecodeCuts1220
import host.ts.RenameRetainedNdimCallFrontend
import host.ts.RenameRetainedChain

set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Full.Ordinary.NamespacedDecode.NdimWhole
open Host.Ts Host.Ts.Owned Host.Ts.Owned.Parametric Host.Ts.Owned.Annotated

host_retained_ndim_call P.F, From1175.s12 using (From1175.S12.substitute LoopVariables.oracleVariables)
  to From1220.s6 using (From1220.S6.substitute LoopVariables.oracleVariables) as Call1187

host_assert_retained_schema Call1187.retained_transport, 39

/-- error: retained batch schema: target run has the wrong step count -/
#guard_msgs in
host_assert_retained_schema Call1187.retained_transport, 38

/-- error: retained batch schema: target run has the wrong step count -/
#guard_msgs in
host_assert_retained_schema Call1187.retained_transport, 40

noncomputable def wrongClosureInput : St Host.Load.LSt :=
  {Call1187.input with heap := (Call1187.input.heap.set Call1187.sourceNdimGetter
    (.obj {Call1187.sourceNdimObject with kind := .fn (.closure
      (singleReturnFunction none (.priv .this chars!"handle" false)) Call1187.sourceEnv false Call1187.sourceHome)}))}

open Lean Elab Command in
run_cmd do
  let f ← `(term| P.F)
  let source ← `(term| From1175.s12)
  let malformed ← `(term| wrongClosureInput)
  let initial ← `(term| (From1175.S12.substitute LoopVariables.oracleVariables))
  let next ← `(term| (From1220.S6.substitute LoopVariables.oracleVariables))
  let endpoint ← `(term| From1220.s6)
  let early ← `(term| From1220.s5)
  let late ← `(term| From1220.s7)
  for (suffix,input,output) in [("Early",source.raw,early.raw),("Late",source.raw,late.raw),("Closure",malformed.raw,endpoint.raw)] do
    let saved : Command.State ← get
    let count := saved.messages.reportedPlusUnreported.toList.length
    let identifier := mkIdent (Name.mkSimple s!"Rejected{suffix}")
    let base := (← getCurrNamespace) ++ identifier.getId
    let mut rejection := ""
    try
      Host.Ts.Owned.Annotated.Driver.elaborateNdimCall f.raw input initial.raw output next.raw identifier
    catch exception => rejection := (← exception.toMessageData.toString)
    let leaked := (← getEnv).constants.foldStage2 (fun names name _ =>
      if base.isPrefixOf name then name::names else names) ([] : List Lean.Name)
    let newMessages := (← get).messages.reportedPlusUnreported.toList.drop count
    unless (rejection.splitOn "kernel").length > 1 do
      throwError "incorrect ndim {suffix} did not reach the intended kernel rejection: {rejection}"
    unless leaked.isEmpty do throwError "failed ndim {suffix} frontend leaked declarations: {leaked}"
    unless newMessages.isEmpty do throwError "failed ndim {suffix} frontend leaked messages"

end Host.Load.Run.Full.Ordinary.NamespacedDecode.NdimWhole
