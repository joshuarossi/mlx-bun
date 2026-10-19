import host.load.RuntimeOracleWeightShapeReturn
import host.ts.RenameRetainedShapeCallFrontend
import host.ts.RenameRetainedChain

set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Full.Ordinary.ShapeCallWhole
open Host.Ts Host.Ts.Owned Host.Ts.Owned.Parametric Host.Ts.Owned.Annotated

host_retained_shape_call P.F, P.RestStream.micro0.micro4.s45 using (P.RestStream.micro0.micro4.S45.substitute LoopVariables.oracleVariables)
  to P.RestStream.micro0.micro5.s60 using (P.RestStream.micro0.micro5.S60.substitute LoopVariables.oracleVariables) as Call445

host_assert_retained_schema Call445.retained_transport, 115

/-- error: retained batch schema: target run has the wrong step count -/
#guard_msgs in
host_assert_retained_schema Call445.retained_transport, 114

/-- error: retained batch schema: target run has the wrong step count -/
#guard_msgs in
host_assert_retained_schema Call445.retained_transport, 116

noncomputable def wrongClosureInput : St Host.Load.LSt :=
  {Call445.input with heap := (Call445.input.heap.set Call445.shapeGetter
    (.obj {Call445.shapeObject with kind := .fn (.closure Sources.Mlx.Array.ast_n61 Call445.shapeEnv false Call445.shapeHome)}))}

open Lean Elab Command in
run_cmd do
  let f ← `(term| P.F)
  let source ← `(term| P.RestStream.micro0.micro4.s45)
  let malformed ← `(term| wrongClosureInput)
  let initial ← `(term| (P.RestStream.micro0.micro4.S45.substitute LoopVariables.oracleVariables))
  let next ← `(term| (P.RestStream.micro0.micro5.S60.substitute LoopVariables.oracleVariables))
  let endpoint ← `(term| P.RestStream.micro0.micro5.s60)
  let early ← `(term| P.RestStream.micro0.micro5.s59)
  let late ← `(term| P.RestStream.micro0.micro5.s61)
  for (suffix,input,output) in [("Early",source.raw,early.raw),("Late",source.raw,late.raw),("Closure",malformed.raw,endpoint.raw)] do
    let saved : Command.State ← get
    let count := saved.messages.reportedPlusUnreported.toList.length
    let identifier := mkIdent (Name.mkSimple s!"Rejected{suffix}")
    let base := (← getCurrNamespace) ++ identifier.getId
    let mut rejection := ""
    try
      Host.Ts.Owned.Annotated.Driver.elaborateShapeCall f.raw input initial.raw output next.raw identifier
    catch exception => rejection := (← exception.toMessageData.toString)
    let leaked := (← getEnv).constants.foldStage2 (fun names name _ =>
      if base.isPrefixOf name then name::names else names) ([] : List Lean.Name)
    let newMessages := (← get).messages.reportedPlusUnreported.toList.drop count
    let intended := base.toString ++ (if suffix == "Closure" then ".sourceData" else ".source_endpoint")
    let wrongShapeKind := suffix != "Closure" || ((rejection.splitOn "ShapeCall.Source.mk").length > 1 &&
      (rejection.splitOn "shapeObject.kind").length > 1 && (rejection.splitOn "Sources.Mlx.Array.ast_n67").length > 1)
    unless (rejection.splitOn intended).length > 1 && (rejection.splitOn "(kernel)").length > 1 &&
        (rejection.toLower.splitOn "type mismatch").length > 1 && wrongShapeKind do
      throwError "incorrect shape call {suffix} did not reach intended kernel rejection: {rejection}"
    unless leaked.isEmpty do throwError "failed shape call {suffix} leaked declarations: {leaked}"
    unless newMessages.isEmpty do throwError "failed shape call {suffix} leaked messages"

end Host.Load.Run.Full.Ordinary.ShapeCallWhole
