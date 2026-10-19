import host.load.RuntimeOracleWeightShapeReturn
import host.ts.RenameRetainedShapeCallTailFrontend
import host.ts.RenameRetainedChain

set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Full.Ordinary.ShapeTailWhole
open Host.Ts Host.Ts.Owned Host.Ts.Owned.Parametric Host.Ts.Owned.Annotated

host_retained_shape_tail P.F, P.RestStream.micro0.micro5.s52 using (P.RestStream.micro0.micro5.S52.substitute LoopVariables.oracleVariables)
  to P.RestStream.micro0.micro5.s60 using (P.RestStream.micro0.micro5.S60.substitute LoopVariables.oracleVariables) as Tail552

host_assert_retained_schema Tail552.retained_transport, 8

/-- error: retained batch schema: target run has the wrong step count -/
#guard_msgs in
host_assert_retained_schema Tail552.retained_transport, 7

/-- error: retained batch schema: target run has the wrong step count -/
#guard_msgs in
host_assert_retained_schema Tail552.retained_transport, 9

noncomputable def wrongConstructorInput : St Host.Load.LSt :=
  {Tail552.input with heap := (Tail552.input.heap.set Tail552.sourceTypedFn
    (.obj {Tail552.sourceTypedObject with kind := (.fn (.native (.buf .typedCtor)
      [.num (.lit (F64.ofNat 5)),.num (.lit Tail552.sourceProto)]))}))}

open Lean Elab Command in
run_cmd do
  let f ← `(term| P.F)
  let source ← `(term| P.RestStream.micro0.micro5.s52)
  let malformed ← `(term| wrongConstructorInput)
  let initial ← `(term| (P.RestStream.micro0.micro5.S52.substitute LoopVariables.oracleVariables))
  let next ← `(term| (P.RestStream.micro0.micro5.S60.substitute LoopVariables.oracleVariables))
  let endpoint ← `(term| P.RestStream.micro0.micro5.s60)
  let early ← `(term| P.RestStream.micro0.micro5.s59)
  let late ← `(term| P.RestStream.micro0.micro5.s61)
  for (suffix,input,output) in [("Early",source.raw,early.raw),("Late",source.raw,late.raw),("Constructor",malformed.raw,endpoint.raw)] do
    let saved : Command.State ← get
    let count := saved.messages.reportedPlusUnreported.toList.length
    let identifier := mkIdent (Name.mkSimple s!"Rejected{suffix}")
    let base := (← getCurrNamespace) ++ identifier.getId
    let mut rejection := ""
    try
      Host.Ts.Owned.Annotated.Driver.elaborateShapeTail f.raw input initial.raw output next.raw identifier
    catch exception => rejection := (← exception.toMessageData.toString)
    let leaked := (← getEnv).constants.foldStage2 (fun names name _ =>
      if base.isPrefixOf name then name::names else names) ([] : List Lean.Name)
    let newMessages := (← get).messages.reportedPlusUnreported.toList.drop count
    unless (rejection.splitOn "kernel").length > 1 do
      throwError "incorrect shape tail {suffix} did not reach intended kernel rejection: {rejection}"
    unless leaked.isEmpty do throwError "failed shape tail {suffix} leaked declarations: {leaked}"
    unless newMessages.isEmpty do throwError "failed shape tail {suffix} leaked messages"

end Host.Load.Run.Full.Ordinary.ShapeTailWhole
