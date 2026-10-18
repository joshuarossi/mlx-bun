import host.ts.RenameRuntimeDriverParameters
import host.ts.RenameRetainedClosure
import host.ts.RenameRetainedParameterBody
set_option Elab.async false
namespace Host.Ts.Owned.Annotated.Driver
open Lean Elab Command Meta

private def printed (stx : Syntax) : CommandElabM String :=
  match stx.reprint with
  | some text => pure text
  | none => throwError "host_retained_closure: source syntax cannot be printed"

private def servers (pre : Lean.Name) (initial next : Syntax) : CommandElabM Unit := liftTermElabM do
  let initial ← Term.elabTermEnsuringType initial (mkConst ``SSrv)
  let next ← Term.elabTermEnsuringType next (mkConst ``SSrv)
  Parametric.Driver.addData (pre ++ `initialServer) (← mkAppM ``numberServer #[initial])
  Parametric.Driver.addData (pre ++ `nextServer) (← mkAppM ``numberServer #[next])

/-- Enter the actual source closure. Receiver and parameter roles are selected
from the current call note; the mapped closure and captured environment are
derived from the live heap relation. Allocation frames every old inventory. -/
elab "host_retained_closure " f:term ", " s:term " using " initial:term " to " t:term " using " next:term " as " name:ident : command => do
  let pre := (← getCurrNamespace) ++ name.getId
  Parametric.Driver.emit s!"host_transport_closure {← printed f.raw}, {← printed s.raw} to {← printed t.raw} as {name.getId}"
  servers pre initial.raw next.raw
  let n := "_root_." ++ pre.toString
  let header := "open Host.Ts Host.Ts.Owned Host.Ts.Owned.Parametric Host.Ts.Owned.Annotated in\n"
  Parametric.Driver.emit (header ++ s!"theorem {n}.source_step : interpS (step {n}.F {n}.input).run {n}.initialServer = some ({n}.output,{n}.nextServer) := by host_kernel_rfl")
  Parametric.Driver.emit (header ++ s!"theorem {n}.source_bound : {n}.input.next+2+(paramNames {n}.sourceFunction).length ≤ 2^64 := by decide +kernel")
  Parametric.Driver.emit (header ++ s!"theorem {n}.retained_transport
      (notes : RetainedNotes) (ν₀ ν : Nat → F64) (C₀ C : CSrv) (R : Ren)
      (FR : Ren → {n}.F.S → {n}.F.S → Prop) (live framed : Nat → Prop) (before after : List Val) (old old' : List Event)
      (s : St {n}.F.S) (inst : Inst ν₀ {n}.initialServer C₀)
      (h : Parametric.StateR (NumberRoles ν₀ ν C₀ C) FR R live framed before after old old' {n}.input s)
      (inventory : RetainedInventory notes ν₀ ν C₀ C R live {n}.input s)
      (fnRole thisRole : Annotated.Value) (argRoles : List Annotated.Value)
      (controlNote : notes.runtime.control = callNote fnRole thisRole argRoles)
      (targetBound : s.next+2+(paramNames {n}.sourceFunction).length ≤ 2^64) :
      ∃ result, interpC (step {n}.F {n}.input).run C₀ = some ({n}.output,C₀) ∧
        interpC (step {n}.F s).run C = some (result,C) ∧
        Parametric.StateR (NumberRoles ν₀ ν C₀ C) FR R
          (ClosureLive live {n}.input.next {n}.sourceArrow {n}.sourceHome {n}.sourceFunction)
          framed before after old old' {n}.output result ∧
        RetainedInventory (notes.withRuntime (notes.runtime.closure {n}.sourceFunction argRoles
          (closureEnvironment {n}.input {n}.sourceFunction {n}.sourceEnv {n}.sourceArrow {n}.sourceHome {n}.sourceThis)
          {n}.sourceArrow {n}.input.next thisRole)) ν₀ ν C₀ C R
          (ClosureLive live {n}.input.next {n}.sourceArrow {n}.sourceHome {n}.sourceFunction) {n}.output result ∧
        Inst ν₀ {n}.nextServer C₀ := by
      obtain ⟨home,this,args,left,right,post,retained⟩ := inventory.closure_step {n}.F FR notes ν₀ ν C₀ C R live framed
        before after old old' {n}.input s h {n}.address {n}.object {n}.sourceFunction {n}.sourceEnv {n}.sourceArrow
        {n}.sourceHome {n}.sourceThis {n}.sourceArgs fnRole thisRole argRoles {n}.source_control {n}.source_heap
        {n}.source_kind controlNote {n}.source_bound targetBound
      have source := {n}.source_run C₀
      have same := congrArg Prod.fst (Option.some.inj (left.symm.trans source))
      dsimp only at same
      rw [same] at post retained
      exact ⟨_,source,right,post,retained,pure_step_inst {n}.F ν₀ {n}.initialServer {n}.nextServer C₀
        {n}.input {n}.output inst {n}.source_step source⟩")

/-- Finishing the actual synchronous parameter list enters the real body and
its lexical allocations. Old annotations are framed; newly uninitialized cells
receive roles only when their original initialization steps execute. -/
elab "host_retained_parameter_body " f:term ", " s:term " using " initial:term " to " t:term " using " next:term " as " name:ident : command => do
  let pre := (← getCurrNamespace) ++ name.getId
  Parametric.Driver.emit s!"host_transport_parameter {← printed f.raw}, {← printed s.raw} to {← printed t.raw} as {name.getId}"
  servers pre initial.raw next.raw
  let n := "_root_." ++ pre.toString
  let header := "open Host.Ts Host.Ts.Owned Host.Ts.Owned.Parametric Host.Ts.Owned.Annotated in\n"
  Parametric.Driver.emit (header ++ s!"theorem {n}.source_step : interpS (step {n}.F {n}.input).run {n}.initialServer = some ({n}.output,{n}.nextServer) := by host_kernel_rfl")
  let entry := "{" ++ s!"{n}.input with stack := {n}.sourceTail" ++ "}"
  Parametric.Driver.emit (header ++ s!"theorem {n}.retained_transport
      (notes : RetainedNotes) (ν₀ ν : Nat → F64) (C₀ C : CSrv) (R : Ren)
      (FR : Ren → {n}.F.S → {n}.F.S → Prop) (live framed : Nat → Prop) (before after : List Val) (old old' : List Event)
      (s : St {n}.F.S) (inst : Inst ν₀ {n}.initialServer C₀)
      (h : Parametric.StateR (NumberRoles ν₀ ν C₀ C) FR R live framed before after old old' {n}.input s)
      (inventory : RetainedInventory notes ν₀ ν C₀ C R live {n}.input s)
      (headNote : Annotated.Tree) (tailNotes : List Annotated.Tree)
      (stackNotes : notes.runtime.stack = headNote::tailNotes)
      (targetBound : s.next+(blockNames {n}.sourceBody).length ≤ 2^64) :
      ∃ result, interpC (step {n}.F {n}.input).run C₀ = some ({n}.output,C₀) ∧
        interpC (step {n}.F s).run C = some (result,C) ∧
        Parametric.StateR (NumberRoles ν₀ ν C₀ C) FR R (CellsLive live {n}.input.next (blockNames {n}.sourceBody))
          framed before after old old' {n}.output result ∧
        RetainedInventory (notes.withRuntime (notes.runtime.bodyEntered {n}.sourceBody
          (hoist ({entry}) {n}.sourceBody {n}.sourceEnv).1 tailNotes)) ν₀ ν C₀ C R
          (CellsLive live {n}.input.next (blockNames {n}.sourceBody)) {n}.output result ∧
        Inst ν₀ {n}.nextServer C₀ := by
      obtain ⟨frames,left,right,post,retained⟩ := inventory.parameter_body_step h {n}.sourceValue {n}.sourceName
        {n}.sourceParams {n}.sourceBody {n}.sourceArgs {n}.sourceEnv {n}.sourceTail headNote tailNotes
        {n}.source_control {n}.source_frame stackNotes {n}.source_hoist {n}.source_bound targetBound
      have source := {n}.source_run C₀
      have same := congrArg Prod.fst (Option.some.inj (left.symm.trans source))
      dsimp only at same
      rw [same] at post retained
      exact ⟨_,source,right,post,retained,pure_step_inst {n}.F ν₀ {n}.initialServer {n}.nextServer C₀
        {n}.input {n}.output inst {n}.source_step source⟩")

end Host.Ts.Owned.Annotated.Driver
