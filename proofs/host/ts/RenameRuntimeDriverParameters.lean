import host.ts.RenameRuntimeDriverValues
import host.ts.RenameRouteDriverParameters
import host.ts.RenameRuntimeParameters
set_option Elab.async false
namespace Host.Ts.Owned.Annotated.Driver
open Lean Elab Command Meta

private def printed (stx : Syntax) : CommandElabM String :=
  match stx.reprint with
  | some text => pure text
  | none => throwError "host_runtime_parameter: source syntax cannot be printed"

/-- Select parameter/default continuations from the retained source snapshot.
Argument roles come from the saved parameter frame; a default result keeps the
role produced by its checked expression. Function-body allocation is separate. -/
elab "host_runtime_parameter " f:term ", " s:term " using " initial:term " to " t:term " using " next:term " as " name:ident : command => do
  let pre := (← getCurrNamespace) ++ name.getId
  let branch ← liftTermElabM do
    let f ← Term.elabTermEnsuringType f (mkConst ``Ffi)
    let stateTy := mkApp (mkConst ``St) (mkApp (mkConst ``Ffi.S) f)
    let s ← Term.elabTermEnsuringType s stateTy
    let frame ← whnf (← Parametric.Driver.field (← Parametric.Driver.field (← mkAppM ``St.stack #[s]) ``List.cons 3 1) ``Frame.k 1 0)
    if frame.isAppOfArity ``FnF.paramDflt 5 then pure "return"
    else
      let params ← whnf (← Parametric.Driver.field frame ``FnF.params 4 1)
      unless params.isAppOfArity ``List.cons 3 do
        throwError "host_runtime_parameter: function-body entry requires retained allocation handler"
      let pattern ← whnf (← Parametric.Driver.field params ``List.cons 3 1)
      if pattern.isAppOfArity ``Pat.id 1 then pure "id"
      else if pattern.isAppOfArity ``Pat.dflt 2 then pure "default"
      else throwError "host_runtime_parameter: unsupported parameter pattern"
  Parametric.Driver.emit s!"host_transport_parameter {← printed f.raw}, {← printed s.raw} to {← printed t.raw} as {name.getId}"
  liftTermElabM do
    let initial ← Term.elabTermEnsuringType initial (mkConst ``SSrv)
    let next ← Term.elabTermEnsuringType next (mkConst ``SSrv)
    Parametric.Driver.addData (pre ++ `initialServer) (← mkAppM ``numberServer #[initial])
    Parametric.Driver.addData (pre ++ `nextServer) (← mkAppM ``numberServer #[next])
  let n := "_root_." ++ pre.toString
  let header := "open Host.Ts Host.Ts.Owned Host.Ts.Owned.Parametric Host.Ts.Owned.Annotated in\n"
  let post := "{" ++ s!"{n}.input with stack := {n}.sourceTail" ++ "}"
  let sourcePost := if branch == "id" then
      s!"Parametric.parameterArgument ({post}) {n}.sourceFunction {n}.sourceName {n}.sourceParams {n}.sourceArgs {n}.sourceEnv"
    else if branch == "default" then
      s!"Parametric.parameterDefault ({post}) {n}.sourceFunction {n}.sourcePattern {n}.sourceDefault {n}.sourceParams {n}.sourceArgs {n}.sourceEnv"
    else s!"Parametric.parameterDefaultReturn ({post}) {n}.sourceFunction {n}.sourcePattern {n}.sourceParams {n}.sourceArgs {n}.sourceEnv {n}.sourceValue"
  Parametric.Driver.emit (header ++ s!"theorem {n}.source_post : {sourcePost} = {n}.output := by host_kernel_rfl")
  Parametric.Driver.emit (header ++ s!"theorem {n}.source_step : interpS (step {n}.F {n}.input).run {n}.initialServer = some ({n}.output,{n}.nextServer) := by host_kernel_rfl")
  let parameters := s!"(notes : RuntimeNotes) (ν₀ ν : Nat → F64) (C₀ C : CSrv) (R : Ren)
      (FR : Ren → {n}.F.S → {n}.F.S → Prop) (live framed : Nat → Prop) (before after : List Val) (old old' : List Event)
      (s : St {n}.F.S) (inst : Inst ν₀ {n}.initialServer C₀)
      (h : Parametric.StateR (NumberRoles ν₀ ν C₀ C) FR R live framed before after old old' {n}.input s)
      (inventory : RuntimeInventory notes ν₀ ν C₀ C R live {n}.input s)
      (roles : List Annotated.Value) (tailNotes : List Annotated.Tree)"
  let (extra,frame,postNotes,rule) := if branch == "id" then
      ("",s!"parameterFrameNote {n}.sourceFunction (.id {n}.sourceName::{n}.sourceParams) roles {n}.sourceEnv",
        s!"notes.parameterArgument {n}.sourceFunction {n}.sourceName {n}.sourceParams roles {n}.sourceEnv tailNotes",
        s!"inventory.parameter_id_step {n}.F FR notes ν₀ ν C₀ C R live framed before after old old' {n}.input s h {n}.sourceValue
          {n}.sourceFunction {n}.sourceName {n}.sourceParams {n}.sourceArgs {n}.sourceEnv {n}.sourceTail roles tailNotes
          {n}.source_control {n}.source_frame stackNotes")
    else if branch == "default" then
      ("",s!"parameterFrameNote {n}.sourceFunction (.dflt {n}.sourcePattern {n}.sourceDefault::{n}.sourceParams) roles {n}.sourceEnv",
        s!"notes.parameterDefault {n}.sourceFunction {n}.sourcePattern {n}.sourceDefault {n}.sourceParams roles {n}.sourceEnv tailNotes",
        s!"inventory.parameter_default_step {n}.F FR notes ν₀ ν C₀ C R live framed before after old old' {n}.input s h {n}.sourceValue
          {n}.sourceFunction {n}.sourcePattern {n}.sourceDefault {n}.sourceParams {n}.sourceArgs {n}.sourceEnv {n}.sourceTail roles tailNotes
          {n}.source_control {n}.source_frame {n}.source_default stackNotes")
    else
      ("(role : Annotated.Value) (controlNote : notes.control = returnNote role)",
        s!"parameterDefaultFrameNote {n}.sourceFunction {n}.sourcePattern {n}.sourceParams roles {n}.sourceEnv",
        s!"notes.parameterDefaultReturn {n}.sourceFunction {n}.sourcePattern {n}.sourceParams roles role {n}.sourceEnv tailNotes",
        s!"inventory.parameter_default_return_step {n}.F FR notes ν₀ ν C₀ C R live framed before after old old' {n}.input s h {n}.sourceValue
          {n}.sourceFunction {n}.sourcePattern {n}.sourceParams {n}.sourceArgs {n}.sourceEnv {n}.sourceTail roles role tailNotes
          {n}.source_control {n}.source_frame controlNote stackNotes")
  Parametric.Driver.emit (header ++ s!"theorem {n}.runtime_transport {parameters} {extra}
      (stackNotes : notes.stack = {frame}::tailNotes) :
      ∃ result, interpC (step {n}.F {n}.input).run C₀ = some ({n}.output,C₀) ∧
      interpC (step {n}.F s).run C = some (result,C) ∧
      Parametric.StateR (NumberRoles ν₀ ν C₀ C) FR R live framed before after old old' {n}.output result ∧
      RuntimeInventory ({postNotes}) ν₀ ν C₀ C R live {n}.output result ∧ Inst ν₀ {n}.nextServer C₀ := by
      obtain ⟨result,left,right,related,annotated⟩ := {rule}
      have source : interpC (step {n}.F {n}.input).run C₀ = some ({n}.output,C₀) := by simpa only [{n}.source_post] using left
      exact ⟨_,source,right,{n}.source_post ▸ related,{n}.source_post ▸ annotated,
        pure_step_inst {n}.F ν₀ {n}.initialServer {n}.nextServer C₀ {n}.input {n}.output inst {n}.source_step source⟩")

end Host.Ts.Owned.Annotated.Driver
