import host.load.RuntimeOracleWeightShapeReturn
import host.ts.RenameRetainedShapeCallEntryFrontend
import host.ts.RenameRetainedChain

set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Full.Ordinary.ShapeEntryWhole
open Host.Ts Host.Ts.Owned Host.Ts.Owned.Parametric Host.Ts.Owned.Annotated

host_retained_shape_entry P.F, P.RestStream.micro0.micro4.s45 using (P.RestStream.micro0.micro4.S45.substitute LoopVariables.oracleVariables)
  to P.RestStream.micro0.micro4.s52 using (P.RestStream.micro0.micro4.S52.substitute LoopVariables.oracleVariables) as Entry445

host_assert_retained_schema Entry445.retained_transport, 7

/-- error: retained batch schema: target run has the wrong step count -/
#guard_msgs in
host_assert_retained_schema Entry445.retained_transport, 6

/-- error: retained batch schema: target run has the wrong step count -/
#guard_msgs in
host_assert_retained_schema Entry445.retained_transport, 8

noncomputable def wrongClosureInput : St Host.Load.LSt :=
  {Entry445.input with heap := (Entry445.input.heap.set Entry445.sourceGetter
    (.obj {Entry445.sourceObject with kind := .fn (.closure Sources.Mlx.Array.ast_n61 Entry445.sourceEnv false Entry445.sourceHome)}))}

open Lean Elab Command in
run_cmd do
  let f ← `(term| P.F)
  let source ← `(term| P.RestStream.micro0.micro4.s45)
  let malformed ← `(term| wrongClosureInput)
  let initial ← `(term| (P.RestStream.micro0.micro4.S45.substitute LoopVariables.oracleVariables))
  let next ← `(term| (P.RestStream.micro0.micro4.S52.substitute LoopVariables.oracleVariables))
  let endpoint ← `(term| P.RestStream.micro0.micro4.s52)
  let early ← `(term| P.RestStream.micro0.micro4.s51)
  let late ← `(term| P.RestStream.micro0.micro4.s53)
  for (suffix,input,output) in [("Early",source.raw,early.raw),("Late",source.raw,late.raw),("Closure",malformed.raw,endpoint.raw)] do
    let saved : Command.State ← get
    let count := saved.messages.reportedPlusUnreported.toList.length
    let identifier := mkIdent (Name.mkSimple s!"Rejected{suffix}")
    let base := (← getCurrNamespace) ++ identifier.getId
    let mut rejection := ""
    try
      Host.Ts.Owned.Annotated.Driver.elaborateShapeEntry f.raw input initial.raw output next.raw identifier
    catch exception => rejection := (← exception.toMessageData.toString)
    let leaked := (← getEnv).constants.foldStage2 (fun names name _ =>
      if base.isPrefixOf name then name::names else names) ([] : List Lean.Name)
    let newMessages := (← get).messages.reportedPlusUnreported.toList.drop count
    let intended := base.toString ++ (if suffix == "Closure" then ".source_kind" else ".source_endpoint")
    let wrongShapeKind := suffix != "Closure" || (rejection.splitOn "Sources.Mlx.Array.ast_n67").length > 1
    unless (rejection.splitOn intended).length > 1 && (rejection.splitOn "(kernel)").length > 1 &&
        (rejection.toLower.splitOn "type mismatch").length > 1 && wrongShapeKind do
      throwError "incorrect shape entry {suffix} did not reach intended kernel rejection: {rejection}"
    unless leaked.isEmpty do throwError "failed shape entry {suffix} leaked declarations: {leaked}"
    unless newMessages.isEmpty do throwError "failed shape entry {suffix} leaked messages"

end Host.Load.Run.Full.Ordinary.ShapeEntryWhole
