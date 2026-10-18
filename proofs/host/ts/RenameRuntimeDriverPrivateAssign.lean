import host.ts.RenameRetainedPrivateAssign
import host.ts.RenameRouteDriverPrivateAssign
import host.ts.RenameRuntimeDriverValues

set_option Elab.async false
namespace Host.Ts.Owned.Annotated.Driver
open Lean Elab Command Meta
open Parametric.Driver

private def privateAssignPrinted (stx : Syntax) : CommandElabM String :=
  match stx.reprint with
  | some value => pure value
  | none => throwError "host_retained_private_assign: source syntax cannot be printed"

/-- Reuse the source private-assignment metadata and original step equations.
The adapter adds the retained receiver/value occurrences and frames all six
inventory families; source/target values are not interpreted anew. -/
elab "host_retained_private_assign " f:term ", " s:term " using " initial:term " to " t:term " using " next:term " as " name:ident : command => do
  let pre := (← getCurrNamespace) ++ name.getId
  Parametric.Driver.emit s!"host_transport_private_assign {← privateAssignPrinted f}, {← privateAssignPrinted s} to {← privateAssignPrinted t} as {name.getId}"
  liftTermElabM do
    addData (pre ++ `initialServer) (← mkAppM ``numberServer #[← Term.elabTermEnsuringType initial (mkConst ``SSrv)])
    addData (pre ++ `nextServer) (← mkAppM ``numberServer #[← Term.elabTermEnsuringType next (mkConst ``SSrv)])
  let n := "_root_." ++ pre.toString
  let header := "open Host.Ts Host.Ts.Owned Host.Ts.Owned.Parametric Host.Ts.Owned.Annotated in\n"
  Parametric.Driver.emit (header ++ s!"theorem {n}.source_step : interpS (step {n}.F {n}.input).run {n}.initialServer = some ({n}.output,{n}.nextServer) := by host_kernel_rfl")
  let descent := (← getEnv).contains (pre ++ `sourceReceiver)
  let store := (← getEnv).contains (pre ++ `sourceAddress)
  let common := s!"{n}.F FR notes ν₀ ν C₀ C R live framed before after old old' {n}.input s h"
  let (extra,postNotes,call,results) := if descent then
      ("",s!"notes.withRuntime (notes.runtime.privateAssignment {n}.sourceReceiver {n}.sourceBrand {n}.sourceName {n}.sourceRhs {n}.sourceEnv)",
        s!"inventory.private_assignment_step {common} {n}.sourceReceiver {n}.sourceName {n}.sourceOptional {n}.sourceRhs
          {n}.sourceEnv {n}.sourceBrand {n}.source_control {n}.source_lookup", "left,right,post,retained")
    else if store then
      ("(role : Annotated.Value) (headNote : Annotated.Tree) (tailNotes : List Annotated.Tree)
        (controlNote : notes.runtime.control = returnNote role) (stackNotes : notes.runtime.stack = headNote::tailNotes)
        (targetBound : s.next ≤ 2^64)",
        s!"notes.privateStored {n}.sourceAddress {n}.sourceBrand {n}.sourceName role tailNotes",
        s!"inventory.private_store_step h {n}.sourceAddress {n}.sourceBrand {n}.sourceName role
          {n}.sourceValue {n}.sourcePrior {n}.sourceOld {n}.sourceEnumerable {n}.sourceObject {n}.sourceTail headNote tailNotes
          {n}.source_control {n}.source_frame {n}.source_heap {n}.source_kind {n}.source_property
          controlNote stackNotes {n}.source_bound targetBound", "value,object,frames,left,right,post,retained")
    else
      ("(role : Annotated.Value) (headNote : Annotated.Tree) (tailNotes : List Annotated.Tree)
        (controlNote : notes.runtime.control = returnNote role) (stackNotes : notes.runtime.stack = headNote::tailNotes)",
        s!"notes.withRuntime (notes.runtime.privateReceiver role {n}.sourceBrand {n}.sourceName {n}.sourceRhs {n}.sourceEnv tailNotes)",
        s!"inventory.private_receiver_step {common} {n}.sourceValue {n}.sourceBrand {n}.sourceName {n}.sourceRhs
          {n}.sourceEnv {n}.sourceTail role headNote tailNotes {n}.source_control {n}.source_frame controlNote stackNotes",
        "value,frames,left,right,post,retained")
  Parametric.Driver.emit (header ++ s!"theorem {n}.retained_transport
      (notes : RetainedNotes) (ν₀ ν : Nat → F64) (C₀ C : CSrv) (R : Ren)
      (FR : Ren → {n}.F.S → {n}.F.S → Prop) (live framed : Nat → Prop) (before after : List Val) (old old' : List Event)
      (s : St {n}.F.S) (inst : Inst ν₀ {n}.initialServer C₀)
      (h : Parametric.StateR (NumberRoles ν₀ ν C₀ C) FR R live framed before after old old' {n}.input s)
      (inventory : RetainedInventory notes ν₀ ν C₀ C R live {n}.input s) {extra} :
      ∃ result, interpC (step {n}.F {n}.input).run C₀ = some ({n}.output,C₀) ∧
        interpC (step {n}.F s).run C = some (result,C) ∧
        Parametric.StateR (NumberRoles ν₀ ν C₀ C) FR R live framed before after old old' {n}.output result ∧
        RetainedInventory ({postNotes}) ν₀ ν C₀ C R live {n}.output result ∧ Inst ν₀ {n}.nextServer C₀ := by
      obtain ⟨{results}⟩ := {call}
      have source := {n}.source_run C₀
      have same := congrArg Prod.fst (Option.some.inj (left.symm.trans source))
      dsimp only at same
      rw [same] at post retained
      exact ⟨_,source,right,post,retained,pure_step_inst {n}.F ν₀ {n}.initialServer {n}.nextServer C₀
        {n}.input {n}.output inst {n}.source_step source⟩")

end Host.Ts.Owned.Annotated.Driver
