import host.ts.RenameRuntimeDriverValues
import host.ts.RenameRouteDriverReturns
import host.ts.RenameRuntimeReturns
set_option Elab.async false
namespace Host.Ts.Owned.Annotated.Driver
open Lean Elab Command Meta

private def printed (stx : Syntax) : CommandElabM String :=
  match stx.reprint with
  | some text => pure text
  | none => throwError "host_runtime_return: source syntax cannot be printed"

/-- Checked return selection keeps the fixed current value role through
lexical unwinding and the original synchronous function boundary. -/
elab "host_runtime_return " f:term ", " s:term " using " initial:term " to " t:term " using " next:term " as " name:ident : command => do
  let pre := (← getCurrNamespace) ++ name.getId
  let abrupt ← liftTermElabM do
    let f ← Term.elabTermEnsuringType f (mkConst ``Ffi)
    let s ← Term.elabTermEnsuringType s (mkApp (mkConst ``St) (mkApp (mkConst ``Ffi.S) f))
    let control ← whnf (← mkAppM ``St.ctl #[s])
    pure (control.isAppOfArity ``Ctl.abr 1)
  Parametric.Driver.emit s!"host_transport_return {← printed f.raw}, {← printed s.raw} to {← printed t.raw} as {name.getId}"
  liftTermElabM do
    let initial ← Term.elabTermEnsuringType initial (mkConst ``SSrv)
    let next ← Term.elabTermEnsuringType next (mkConst ``SSrv)
    Parametric.Driver.addData (pre ++ `initialServer) (← mkAppM ``numberServer #[initial])
    Parametric.Driver.addData (pre ++ `nextServer) (← mkAppM ``numberServer #[next])
  let n := "_root_." ++ pre.toString
  let header := "open Host.Ts Host.Ts.Owned Host.Ts.Owned.Parametric Host.Ts.Owned.Annotated in\n"
  Parametric.Driver.emit (header ++ s!"theorem {n}.source_step : interpS (step {n}.F {n}.input).run {n}.initialServer = some ({n}.output,{n}.nextServer) := by host_kernel_rfl")
  let method := if abrupt then "return_unwind_step" else "return_exit_step"
  let inputNote := if abrupt then "abruptReturnNote" else "returnNote"
  let outputNote := if abrupt then "unwindReturn" else "exitReturn"
  Parametric.Driver.emit (header ++ s!"theorem {n}.runtime_transport
      (notes : RuntimeNotes) (ν₀ ν : Nat → F64) (C₀ C : CSrv) (R : Ren)
      (FR : Ren → {n}.F.S → {n}.F.S → Prop) (live framed : Nat → Prop) (before after : List Val) (old old' : List Event)
      (s : St {n}.F.S) (inst : Inst ν₀ {n}.initialServer C₀)
      (h : Parametric.StateR (NumberRoles ν₀ ν C₀ C) FR R live framed before after old old' {n}.input s)
      (inventory : RuntimeInventory notes ν₀ ν C₀ C R live {n}.input s)
      (role : Annotated.Value) (headNote : Annotated.Tree) (tailNotes : List Annotated.Tree)
      (controlNote : notes.control = {inputNote} role) (stackNotes : notes.stack = headNote::tailNotes) :
      ∃ result, interpC (step {n}.F {n}.input).run C₀ = some ({n}.output,C₀) ∧
      interpC (step {n}.F s).run C = some (result,C) ∧
      Parametric.StateR (NumberRoles ν₀ ν C₀ C) FR R live framed before after old old' {n}.output result ∧
      RuntimeInventory (notes.{outputNote} {n}.sourceAction role tailNotes) ν₀ ν C₀ C R live {n}.output result ∧ Inst ν₀ {n}.nextServer C₀ := by
      obtain ⟨result,left,right,related,annotated⟩ := inventory.{method} {n}.F FR notes ν₀ ν C₀ C R live framed before after old old'
        {n}.input s h {n}.sourceValue role {n}.sourceAction {n}.sourceEnv {n}.sourceTail headNote tailNotes
        {n}.source_control {n}.source_frame controlNote stackNotes
      have source : interpC (step {n}.F {n}.input).run C₀ = some ({n}.output,C₀) := by simpa only [{n}.source_post] using left
      exact ⟨_,source,right,{n}.source_post ▸ related,{n}.source_post ▸ annotated,
        pure_step_inst {n}.F ν₀ {n}.initialServer {n}.nextServer C₀ {n}.input {n}.output inst {n}.source_step source⟩")

end Host.Ts.Owned.Annotated.Driver
