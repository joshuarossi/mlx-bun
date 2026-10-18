import host.ts.RenameRetainedForInit
import host.ts.RenameRouteDriverFor
import host.ts.RenameRuntimeSourceCut

set_option Elab.async false

namespace Host.Ts.Owned.Annotated.Driver
open Lean Elab Command Meta

private def forPrinted (stx : Syntax) : CommandElabM String :=
  match stx.reprint with
  | some text => pure text
  | none => throwError "host_retained_for: source syntax cannot be printed"

/-- Source-selected lexical for scheduling. The original control rule and
both source equations are checked before composing retained annotations. -/
elab "host_retained_for " f:term ", " s:term " using " initial:term " to " t:term " using " next:term " as " name:ident : command => do
  let pre := (← getCurrNamespace) ++ name.getId
  Parametric.Driver.emit s!"host_transport_for {← forPrinted f.raw}, {← forPrinted s.raw} to {← forPrinted t.raw} as {name.getId}"
  unless (← getEnv).contains (pre ++ `sourceInitializer) do
    throwError "host_retained_for: continuation inventory rule is not registered"
  liftTermElabM do
    let initial ← Term.elabTermEnsuringType initial (mkConst ``SSrv)
    let next ← Term.elabTermEnsuringType next (mkConst ``SSrv)
    Parametric.Driver.addData (pre ++ `initialServer) (← mkAppM ``numberServer #[initial])
    Parametric.Driver.addData (pre ++ `nextServer) (← mkAppM ``numberServer #[next])
  let n := "_root_." ++ pre.toString
  let header := "open Host.Ts Host.Ts.Owned Host.Ts.Owned.Parametric Host.Ts.Owned.Annotated in\n"
  Parametric.Driver.emit (header ++ s!"theorem {n}.source_step : interpS (step {n}.F {n}.input).run {n}.initialServer = some ({n}.output,{n}.nextServer) := by host_kernel_rfl")
  Parametric.Driver.emit (header ++ s!"theorem {n}.retained_transport
      (notes : RetainedNotes) (ν₀ ν : Nat → F64) (C₀ C : CSrv) (R : Ren)
      (FR : Ren → {n}.F.S → {n}.F.S → Prop) (live framed : Nat → Prop) (before after : List Val) (old old' : List Event)
      (s : St {n}.F.S) (inst : Inst ν₀ {n}.initialServer C₀)
      (h : Parametric.StateR (NumberRoles ν₀ ν C₀ C) FR R live framed before after old old' {n}.input s)
      (inventory : RetainedInventory notes ν₀ ν C₀ C R live {n}.input s) (targetBound : s.next+1 ≤ 2^64) :
      ∃ result, interpC (step {n}.F {n}.input).run C₀ = some ({n}.output,C₀) ∧
        interpC (step {n}.F s).run C = some (result,C) ∧
        Parametric.StateR (NumberRoles ν₀ ν C₀ C) FR R (CellsLive live {n}.input.next [{n}.sourceName])
          framed before after old old' {n}.output result ∧
        RetainedInventory (notes.withRuntime (notes.runtime.forLet {n}.sourceName {n}.sourceInitializer {n}.sourceTest
          {n}.sourceUpdate {n}.sourceBody (allocCells {n}.input [{n}.sourceName] {n}.sourceEnv).1))
          ν₀ ν C₀ C R (CellsLive live {n}.input.next [{n}.sourceName]) {n}.output result ∧ Inst ν₀ {n}.nextServer C₀ := by
      obtain ⟨left,right,post,retained⟩ := RetainedInventory.for_let_step {n}.F FR notes ν₀ ν C₀ C R live framed
        before after old old' {n}.input s h inventory {n}.sourceName {n}.sourceInitializer {n}.sourceTest {n}.sourceUpdate
        {n}.sourceBody {n}.sourceEnv {n}.source_control {n}.source_bound targetBound
      have source := {n}.source_run C₀
      have same := congrArg Prod.fst (Option.some.inj (left.symm.trans source))
      dsimp only at same
      rw [same] at post retained
      exact ⟨_,source,right,post,retained,pure_step_inst {n}.F ν₀ {n}.initialServer {n}.nextServer C₀
        {n}.input {n}.output inst {n}.source_step source⟩")

end Host.Ts.Owned.Annotated.Driver
