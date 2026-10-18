import host.ts.RenameRetainedUndefinedVariable
import host.ts.RenameRuntimeDriverValues

set_option Elab.async false
namespace Host.Ts.Owned.Annotated.Driver
open Lean Elab Command Meta

/-- A selected initialized undefined lexical read has a canonical retained role. -/
elab "host_retained_undefined_variable " f:term ", " s:term " using " initial:term " to " t:term " using " next:term " as " name:ident : command => do
  let pre := (← getCurrNamespace) ++ name.getId
  let printed (stx : Syntax) := match stx.reprint with
    | some source => pure source
    | none => throwError "object variable: cannot print source term"
  Parametric.Driver.emit s!"host_transport_variable {← printed f.raw}, {← printed s.raw} to {← printed t.raw} as {name.getId}"
  liftTermElabM do
    Parametric.Driver.addData (pre ++ `initialServer) (← mkAppM ``numberServer #[← Term.elabTermEnsuringType initial (mkConst ``SSrv)])
    Parametric.Driver.addData (pre ++ `nextServer) (← mkAppM ``numberServer #[← Term.elabTermEnsuringType next (mkConst ``SSrv)])
  let n := "_root_." ++ pre.toString
  let header := "open Host.Ts Host.Ts.Owned Host.Ts.Owned.Parametric Host.Ts.Owned.Annotated in\n"
  Parametric.Driver.emit (header ++ s!"theorem {n}.source_undefined : {n}.sourceValue = .undef := by host_kernel_rfl")
  Parametric.Driver.emit (header ++ s!"theorem {n}.source_step : interpS (step {n}.F {n}.input).run {n}.initialServer = some ({n}.output,{n}.nextServer) := by host_kernel_rfl")
  Parametric.Driver.emit (header ++ s!"theorem {n}.retained_transport
      (notes : RetainedNotes) (ν₀ ν : Nat → F64) (C₀ C : CSrv) (R : Ren)
      (FR : Ren → {n}.F.S → {n}.F.S → Prop) (live framed : Nat → Prop)
      (before after : List Val) (old old' : List Event) (s : St {n}.F.S)
      (inst : Inst ν₀ {n}.initialServer C₀)
      (h : Parametric.StateR (NumberRoles ν₀ ν C₀ C) FR R live framed before after old old' {n}.input s)
      (inventory : RetainedInventory notes ν₀ ν C₀ C R live {n}.input s) :
      ∃ result, interpC (step {n}.F {n}.input).run C₀ = some ({n}.output,C₀) ∧
        interpC (step {n}.F s).run C = some (result,C) ∧
        Parametric.StateR (NumberRoles ν₀ ν C₀ C) FR R live framed before after old old' {n}.output result ∧
        RetainedInventory (notes.withRuntime (notes.runtime.returning (.undef))) ν₀ ν C₀ C R live {n}.output result ∧
        Inst ν₀ {n}.nextServer C₀ := by
      have read : {n}.input.heap.get {n}.address = some (.cell (some (.undef))) := by
        simpa only [{n}.source_undefined] using {n}.source_cell
      obtain ⟨left,right,post,retained⟩ := inventory.variable_undefined_step h {n}.sourceName {n}.sourceEnv
        {n}.address {n}.source_control {n}.source_lookup read
      have endpoint : {n}.input.ret (.undef) = {n}.output := by
        simpa only [{n}.source_undefined] using {n}.source_post
      rw [endpoint] at left post retained
      exact ⟨_,left,right,post,retained,pure_step_inst {n}.F ν₀ {n}.initialServer {n}.nextServer C₀
        {n}.input {n}.output inst {n}.source_step left⟩")

end Host.Ts.Owned.Annotated.Driver
