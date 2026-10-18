import host.ts.RenameRuntimeRetain
import host.ts.RenameRuntimePureScheduler
set_option Elab.async false
namespace Host.Ts.Owned.Annotated.Driver
open Lean Elab Command Meta
open Parametric

private def printed (stx : Syntax) : CommandElabM String :=
  match stx.reprint with
  | some text => pure text
  | none => throwError "host_retained_pure_step: source syntax cannot be printed"

/-- Reuse the source-selected runtime rule and retain all six annotation
families through its original pure machine effects. The effect proof is
constructed from source facts and the initial state relation inside the result
theorem, not supplied as a hypothesis about a future target execution. -/
elab "host_retained_pure_step " f:term ", " s:term " using " initial:term " to " t:term " using " next:term " as " name:ident : command => do
  let pre := (← getCurrNamespace) ++ name.getId
  let n := "_root_." ++ pre.toString
  Parametric.Driver.emit s!"host_runtime_step {← printed f.raw}, {← printed s.raw} using {← printed initial.raw} to {← printed t.raw} using {← printed next.raw} as {name.getId}"
  let env ← getEnv
  let has (tag : Lean.Name) := env.contains (pre ++ tag)
  let effect ← if has `sourceLiteral then
      pure s!"PureRuntimeCase.literal h {n}.sourceLiteral {n}.sourceValue {n}.sourceEnv {n}.parsed {n}.source_control"
    else if has `address then
      pure s!"PureRuntimeCase.variable h {n}.sourceName {n}.sourceEnv {n}.address {n}.sourceValue {n}.source_control {n}.source_lookup {n}.source_cell"
    else if has `sourceDescent then
      pure s!"PureRuntimeCase.descent h {n}.sourceDescent {n}.sourceEnv {n}.source_control"
    else if has `kind then
      pure s!"PureRuntimeCase.arithmetic h {n}.kind {n}.sourceLeft {n}.sourceRight {n}.sourceTail {n}.source_control {n}.source_stack"
    else if has `sourceMode then
      pure s!"PureRuntimeCase.callStart h {n}.sourceMode {n}.sourceAddress {n}.sourceThis {n}.sourceArgs {n}.sourceEnv {n}.sourceTail {n}.source_control {n}.source_frame"
    else if has `sourceEntry then liftTermElabM do
      let entry ← whnf (mkConst (pre ++ `sourceEntry))
      if entry.isAppOfArity ``CallEntry.identifier 1 then
        pure s!"PureRuntimeCase.identifierCall h _ {n}.sourceArgs {n}.sourceOptional {n}.sourceEnv {n}.source_control"
      else pure s!"PureRuntimeCase.methodDescent h _ _ {n}.sourceArgs {n}.sourceEnv _ {n}.sourceOptional {n}.source_control"
    else if has `sourceFunction && has `sourceParams && !(has `sourceKind) then
      if has `sourceDefault then
        pure s!"PureRuntimeCase.parameterDefault h {n}.sourceValue {n}.sourceFunction {n}.sourcePattern {n}.sourceDefault {n}.sourceParams {n}.sourceArgs {n}.sourceEnv {n}.sourceTail {n}.source_control {n}.source_frame {n}.source_default"
      else if has `sourceName then
        pure s!"PureRuntimeCase.parameterId h {n}.sourceValue {n}.sourceFunction {n}.sourceName {n}.sourceParams {n}.sourceArgs {n}.sourceEnv {n}.sourceTail {n}.source_control {n}.source_frame"
      else pure s!"PureRuntimeCase.parameterDefaultReturn h {n}.sourceValue {n}.sourceFunction {n}.sourcePattern {n}.sourceParams {n}.sourceArgs {n}.sourceEnv {n}.sourceTail {n}.source_control {n}.source_frame"
    else if has `sourceAcc then
      pure s!"PureRuntimeCase.arguments h {n}.sourceValue {n}.sourceKind {n}.sourceFunction {n}.sourceThis {n}.sourceAcc {n}.sourceRest {n}.sourceEnv {n}.sourceTail {n}.source_control {n}.source_frame (by decide +kernel)"
    else if has `sourceOp then
      if has `sourceValue then
        pure s!"PureRuntimeCase.binaryLeft h {n}.sourceValue {n}.sourceOp {n}.sourceRight {n}.sourceEnv {n}.sourceTail {n}.source_control {n}.source_frame"
      else pure s!"PureRuntimeCase.descent h (.binary {n}.sourceOp {n}.sourceLeft {n}.sourceRight) {n}.sourceEnv {n}.source_control"
    else if has `sourceStatement then
      pure s!"PureRuntimeCase.blockNext h {n}.sourceValue {n}.sourceStatement {n}.sourceRest {n}.sourceEnv {n}.sourceTail {n}.source_control {n}.source_frame"
    else if has `sourceAction then liftTermElabM do
      let type ← inferType (mkConst (pre ++ `sourceAction))
      if type.isConstOf ``StatementAction then
        pure s!"PureRuntimeCase.statement h {n}.sourceAction {n}.sourceEnv {n}.source_control"
      else if type.isConstOf ``ReturnExit then
        pure s!"PureRuntimeCase.returnExit h {n}.sourceValue {n}.sourceEnv {n}.sourceAction {n}.sourceTail {n}.source_control {n}.source_frame"
      else if type.isConstOf ``ReturnUnwind then
        pure s!"PureRuntimeCase.returnUnwind h {n}.sourceValue {n}.sourceEnv {n}.sourceAction {n}.sourceTail {n}.source_control {n}.source_frame"
      else throwError "host_retained_pure_step: unsupported source action effects"
    else if has `sourcePattern && has `sourceKind then
      pure s!"PureRuntimeCase.declaration h {n}.sourceValue {n}.sourceKind {n}.sourcePattern {n}.sourceRest {n}.sourceEnv {n}.sourceTail {n}.source_control {n}.source_frame {n}.source_kind"
    else throwError "host_retained_pure_step: source rule has no registered paired pure-effect certificate"
  let theoremName := if has `runtime_literal_transport then "runtime_literal_transport" else "runtime_transport"
  Parametric.Driver.emit ("open Host.Ts Host.Ts.Owned Host.Ts.Owned.Parametric Host.Ts.Owned.Annotated in\n" ++
    s!"host_retain_runtime {n}.{theoremName} using ({effect}) as {name.getId}.retained_transport")

end Host.Ts.Owned.Annotated.Driver
