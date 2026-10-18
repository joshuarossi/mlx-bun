import host.ts.RenameRuntimeDriver
set_option Elab.async false
namespace Host.Ts.Owned.Annotated.Driver
open Lean Elab Command Meta
open Parametric.Driver

private def sourceText (stx : Syntax) : CommandElabM String :=
  match stx.reprint with
  | some text => pure text
  | none => throwError "host_runtime_value: source syntax cannot be printed"

private def servers (pre : Lean.Name) (initial next : Syntax) : CommandElabM Unit := liftTermElabM do
  let initial ← Term.elabTermEnsuringType initial (mkConst ``SSrv)
  let next ← Term.elabTermEnsuringType next (mkConst ``SSrv)
  addData (pre ++ `initialServer) (← mkAppM ``numberServer #[initial])
  addData (pre ++ `nextServer) (← mkAppM ``numberServer #[next])

/-- Emit source-checked literal/variable rules that obtain their current roles
from syntax or the retained cell inventory. Source servers are explicit. -/
elab "host_runtime_value " f:term ", " s:term " using " initial:term " to " t:term " using " next:term " as " name:ident : command => do
  let pre := (← getCurrNamespace) ++ name.getId
  let isLiteral ← liftTermElabM do
    let f ← Term.elabTermEnsuringType f (mkConst ``Ffi)
    let stateTy := mkApp (mkConst ``St) (mkApp (mkConst ``Ffi.S) f)
    let s ← Term.elabTermEnsuringType s stateTy
    let control ← whnf (← mkAppM ``St.ctl #[s])
    unless control.isAppOfArity ``Ctl.ev 2 do throwError "host_runtime_value: expected source expression control"
    let expression ← whnf control.getAppArgs[0]!
    if expression.isAppOfArity ``Expr.lit 1 then pure true
    else if expression.isAppOfArity ``Expr.id 1 then pure false
    else throwError "host_runtime_value: unsupported source expression"
  let selected := if isLiteral then "host_transport_literal" else "host_transport_variable"
  Parametric.Driver.emit s!"{selected} {← sourceText f.raw}, {← sourceText s.raw} to {← sourceText t.raw} as {name.getId}"
  servers pre initial.raw next.raw
  let n := "_root_." ++ pre.toString
  let header := "open Host.Ts Host.Ts.Owned Host.Ts.Owned.Parametric Host.Ts.Owned.Annotated in\n"
  Parametric.Driver.emit (header ++ s!"theorem {n}.source_step : interpS (step {n}.F {n}.input).run {n}.initialServer = some ({n}.output,{n}.nextServer) := by host_kernel_rfl")
  let parameters := s!"(notes : RuntimeNotes) (ν₀ ν : Nat → F64) (C₀ C : CSrv) (R : Ren)
      (FR : Ren → {n}.F.S → {n}.F.S → Prop) (live framed : Nat → Prop) (before after : List Val) (old old' : List Event)
      (s : St {n}.F.S) (inst : Inst ν₀ {n}.initialServer C₀)
      (h : Parametric.StateR (NumberRoles ν₀ ν C₀ C) FR R live framed before after old old' {n}.input s)
      (inventory : RuntimeInventory notes ν₀ ν C₀ C R live {n}.input s)"
  if isLiteral then
    Parametric.Driver.emit (header ++ s!"theorem {n}.runtime_transport {parameters} :
      interpC (step {n}.F {n}.input).run C₀ = some ({n}.output,C₀) ∧
      interpC (step {n}.F s).run C = some (s.ret {n}.sourceValue,C) ∧
      Parametric.StateR (NumberRoles ν₀ ν C₀ C) FR R live framed before after old old' {n}.output (s.ret {n}.sourceValue) ∧
      RuntimeInventory (notes.returning {n}.parsed.role) ν₀ ν C₀ C R live {n}.output (s.ret {n}.sourceValue) ∧
      Inst ν₀ {n}.nextServer C₀ := by
      obtain ⟨left,right,related,annotated⟩ := inventory.literal_step {n}.F FR notes ν₀ ν C₀ C R live framed before after old old'
        {n}.input s h {n}.sourceLiteral {n}.sourceValue {n}.sourceEnv {n}.parsed {n}.source_control
      have source : interpC (step {n}.F {n}.input).run C₀ = some ({n}.output,C₀) := by
        simpa only [{n}.source_post] using left
      exact ⟨source,right,{n}.source_post ▸ related,{n}.source_post ▸ annotated,
        pure_step_inst {n}.F ν₀ {n}.initialServer {n}.nextServer C₀ {n}.input {n}.output inst {n}.source_step source⟩")
  else
    Parametric.Driver.emit (header ++ s!"theorem {n}.runtime_transport {parameters}
      (role : Annotated.Value) (entry : notes.cells.cells {n}.address = some role) :
      ∃ value, interpC (step {n}.F {n}.input).run C₀ = some ({n}.output,C₀) ∧
      interpC (step {n}.F s).run C = some (s.ret value,C) ∧
      Parametric.StateR (NumberRoles ν₀ ν C₀ C) FR R live framed before after old old' {n}.output (s.ret value) ∧
      RuntimeInventory (notes.returning role) ν₀ ν C₀ C R live {n}.output (s.ret value) ∧
      Inst ν₀ {n}.nextServer C₀ := by
      obtain ⟨value,left,right,related,annotated⟩ := inventory.variable_step {n}.F FR notes ν₀ ν C₀ C R live framed before after old old'
        {n}.input s h {n}.sourceName {n}.sourceEnv {n}.address {n}.sourceValue role {n}.source_control {n}.source_lookup {n}.source_cell entry
      have source : interpC (step {n}.F {n}.input).run C₀ = some ({n}.output,C₀) := by
        simpa only [{n}.source_post] using left
      exact ⟨value,source,right,{n}.source_post ▸ related,{n}.source_post ▸ annotated,
        pure_step_inst {n}.F ν₀ {n}.initialServer {n}.nextServer C₀ {n}.input {n}.output inst {n}.source_step source⟩")

end Host.Ts.Owned.Annotated.Driver
