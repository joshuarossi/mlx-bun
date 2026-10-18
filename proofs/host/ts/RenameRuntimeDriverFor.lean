import host.ts.RenameRetainedForInit
import host.ts.RenameRetainedForCopy
import host.ts.RenameRetainedForSchedule
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
  let known ← getEnv
  let branch ← if known.contains (pre ++ `sourceInitializer) then pure "init"
    else if known.contains (pre ++ `sourceGuard) then pure "body"
    else if known.contains (pre ++ `sourceCell) then liftTermElabM do
      let stack ← mkAppM ``St.stack #[mkConst (pre ++ `input)]
      let frame ← Parametric.Driver.field stack ``List.cons 3 1
      let loop ← whnf (← Parametric.Driver.field frame ``Frame.lp 1 0)
      pure (if loop.isAppOfArity ``LoopF.forUpd 6 then "update" else "copy")
    else pure "test"
  liftTermElabM do
    if branch == "copy" || branch == "update" then
      Parametric.Driver.addData (pre ++ `sourcePhase) (mkConst (if branch == "copy" then ``ForCopyPhase.testPhase else ``ForCopyPhase.updatePhase))
    else if branch == "body" || branch == "test" then
      let phase := if branch == "body" then mkApp (mkConst ``ForSchedulePhase.bodyPhase) (mkConst (pre ++ `sourceGuard))
        else mkConst ``ForSchedulePhase.testPhase
      Parametric.Driver.addData (pre ++ `sourceSchedulePhase) phase
    let initial ← Term.elabTermEnsuringType initial (mkConst ``SSrv)
    let next ← Term.elabTermEnsuringType next (mkConst ``SSrv)
    Parametric.Driver.addData (pre ++ `initialServer) (← mkAppM ``numberServer #[initial])
    Parametric.Driver.addData (pre ++ `nextServer) (← mkAppM ``numberServer #[next])
  let n := "_root_." ++ pre.toString
  let header := "open Host.Ts Host.Ts.Owned Host.Ts.Owned.Parametric Host.Ts.Owned.Annotated in\n"
  Parametric.Driver.emit (header ++ s!"theorem {n}.source_step : interpS (step {n}.F {n}.input).run {n}.initialServer = some ({n}.output,{n}.nextServer) := by host_kernel_rfl")
  if branch == "init" then
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
  else if branch == "copy" || branch == "update" then
    Parametric.Driver.emit (header ++ s!"theorem {n}.retained_transport
      (notes : RetainedNotes) (ν₀ ν : Nat → F64) (C₀ C : CSrv) (R : Ren)
      (FR : Ren → {n}.F.S → {n}.F.S → Prop) (live framed : Nat → Prop) (before after : List Val) (old old' : List Event)
      (s : St {n}.F.S) (inst : Inst ν₀ {n}.initialServer C₀)
      (h : Parametric.StateR (NumberRoles ν₀ ν C₀ C) FR R live framed before after old old' {n}.input s)
      (inventory : RetainedInventory notes ν₀ ν C₀ C R live {n}.input s)
      (role : Annotated.Value) (headNote : Annotated.Tree) (tailNotes : List Annotated.Tree)
      (entry : notes.runtime.cells.cells {n}.sourceCell = some role) (stackNotes : notes.runtime.stack = headNote::tailNotes)
      (targetBound : s.next < 2^64) :
      ∃ result, interpC (step {n}.F {n}.input).run C₀ = some ({n}.output,C₀) ∧
        interpC (step {n}.F s).run C = some (result,C) ∧
        Parametric.StateR (NumberRoles ν₀ ν C₀ C) FR R (LiveAfter live {n}.input.next)
          framed before after old old' {n}.output result ∧
        RetainedInventory (notes.withRuntime ({n}.sourcePhase.notes (notes.runtime.copyIndex {n}.input.next role)
          {n}.sourceTest {n}.sourceUpdate {n}.sourceBody (({n}.sourceName,{n}.input.next)::{n}.sourceEnv.drop 1)
          {n}.sourceName {n}.sourceLabels tailNotes)) ν₀ ν C₀ C R (LiveAfter live {n}.input.next) {n}.output result ∧
        Inst ν₀ {n}.nextServer C₀ := by
      obtain ⟨sourcePost,result,left,right,post,retained⟩ := RetainedInventory.for_copy_step {n}.F {n}.sourcePhase FR notes
        ν₀ ν C₀ C R live framed before after old old' {n}.input s h inventory {n}.sourceValue {n}.sourceTest {n}.sourceUpdate
        {n}.sourceBody {n}.sourceEnv {n}.sourceName {n}.sourceLabels {n}.sourceTail {n}.sourceCell {n}.sourceCellValue
        role headNote tailNotes {n}.source_control {n}.source_frame {n}.source_lookup {n}.source_cell entry stackNotes
        {n}.source_bound targetBound
      have source := {n}.source_run C₀
      have same := congrArg Prod.fst (Option.some.inj (left.symm.trans source))
      dsimp only at same
      rw [same] at post retained
      exact ⟨_,source,right,post,retained,pure_step_inst {n}.F ν₀ {n}.initialServer {n}.nextServer C₀
        {n}.input {n}.output inst {n}.source_step source⟩")
  else
    Parametric.Driver.emit (header ++ s!"theorem {n}.retained_transport
      (notes : RetainedNotes) (ν₀ ν : Nat → F64) (C₀ C : CSrv) (R : Ren)
      (FR : Ren → {n}.F.S → {n}.F.S → Prop) (live framed : Nat → Prop) (before after : List Val) (old old' : List Event)
      (s : St {n}.F.S) (inst : Inst ν₀ {n}.initialServer C₀)
      (h : Parametric.StateR (NumberRoles ν₀ ν C₀ C) FR R live framed before after old old' {n}.input s)
      (inventory : RetainedInventory notes ν₀ ν C₀ C R live {n}.input s)
      (headNote : Annotated.Tree) (tailNotes : List Annotated.Tree) (stackNotes : notes.runtime.stack = headNote::tailNotes) :
      ∃ result, interpC (step {n}.F {n}.input).run C₀ = some ({n}.output,C₀) ∧
        interpC (step {n}.F s).run C = some (result,C) ∧
        Parametric.StateR (NumberRoles ν₀ ν C₀ C) FR R live framed before after old old' {n}.output result ∧
        RetainedInventory (notes.withRuntime ({n}.sourceSchedulePhase.notes notes.runtime {n}.sourceTest {n}.sourceUpdate
          {n}.sourceBody {n}.sourceEnv {n}.sourceNames {n}.sourceLabels tailNotes)) ν₀ ν C₀ C R live {n}.output result ∧
        Inst ν₀ {n}.nextServer C₀ := by
      obtain ⟨sourcePost,result,left,right,post,retained⟩ := RetainedInventory.for_schedule_step {n}.F {n}.sourceSchedulePhase
        FR notes ν₀ ν C₀ C R live framed before after old old' {n}.input s h inventory {n}.sourceValue {n}.sourceTest
        {n}.sourceUpdate {n}.sourceBody {n}.sourceEnv {n}.sourceNames {n}.sourceLabels {n}.sourceTail headNote tailNotes
        {n}.source_control {n}.source_frame stackNotes
      have source := {n}.source_run C₀
      have same := congrArg Prod.fst (Option.some.inj (left.symm.trans source))
      dsimp only at same
      rw [same] at post retained
      exact ⟨_,source,right,post,retained,pure_step_inst {n}.F ν₀ {n}.initialServer {n}.nextServer C₀
        {n}.input {n}.output inst {n}.source_step source⟩")

end Host.Ts.Owned.Annotated.Driver
