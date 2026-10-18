import host.ts.RenameRetainedOutArrayReturn
import host.ts.RenameRuntimeDriverValues
set_option Elab.async false
namespace Host.Ts.Owned.Annotated.Driver
open Lean Elab Command Meta Parametric.Driver

/-- Select the successful out-parameter return suffix from the current source
syntax and cells. Every metadata equation and the whole endpoint are checked
before instantiating the reusable fifteen-step theorem. -/
elab "host_retained_outArray_return " f:term ", " s:term " using " initial:term " to " t:term " using " next:term " as " name:ident : command => do
  let pre := (← getCurrNamespace) ++ name.getId
  liftTermElabM do
    let f ← Term.elabTermEnsuringType f (mkConst ``Ffi)
    let stateTy := mkApp (mkConst ``St) (mkApp (mkConst ``Ffi.S) f)
    let s ← Term.elabTermEnsuringType s stateTy
    let t ← Term.elabTermEnsuringType t stateTy
    let stack ← mkAppM ``St.stack #[s]
    let block ← field (← field stack ``List.cons 3 1) ``Frame.s 1 0
    let statements ← field block ``StmtF.block 2 0
    let env ← field block ``StmtF.block 2 1
    let test ← field statements ``List.cons 3 1
    let condition ← field test ``Stmt.if_ 3 0
    let status ← field (← field condition ``Expr.bin 3 1) ``Expr.id 1 0
    let handle ← field (← field (← field (← field (← field statements ``List.cons 3 2)
      ``List.cons 3 1) ``Stmt.ret 1 0) ``Option.some 2 1) ``Expr.id 1 0
    let statusCell ← field (← mkAppM ``lookupEnv #[status,env]) ``Option.some 2 1
    let handleCell ← field (← mkAppM ``lookupEnv #[handle,env]) ``Option.some 2 1
    let value ← field (← field (← mkAppM ``St.cell? #[s,handleCell]) ``Option.some 2 1) ``Option.some 2 1
    let caller ← mkAppM ``List.drop #[mkNatLit 3,stack]
    for (tag,value) in [("F",f),("input",s),("output",t),("sourceEnv",env),("sourceStatusName",status),
      ("sourceHandleName",handle),("sourceStatusCell",statusCell),("sourceHandleCell",handleCell),
      ("sourceFailure",← field test ``Stmt.if_ 3 1),("sourceValue",value),("sourceCaller",caller)] do
      addData (pre ++ Name.mkSimple tag) value (if tag == "input" || tag == "output" then some stateTy else none)
    addData (pre ++ `span) (mkNatLit 15)
    addData (pre ++ `initialServer) (← mkAppM ``numberServer #[← Term.elabTermEnsuringType initial (mkConst ``SSrv)])
    addData (pre ++ `nextServer) (← mkAppM ``numberServer #[← Term.elabTermEnsuringType next (mkConst ``SSrv)])
  let n := "_root_." ++ pre.toString
  let header := "open Host.Ts Host.Ts.Owned Host.Ts.Owned.Parametric Host.Ts.Owned.Annotated in\n"
  let fact (tag proposition : String) := Parametric.Driver.emit (header ++ s!"theorem {n}.{tag} : {proposition} := by host_kernel_rfl")
  for (tag,type) in [
    ("source_control",s!"{n}.input.ctl = .ret .undef"),
    ("source_stack",s!"{n}.input.stack = .s (.block (outArraySuccessStatements {n}.sourceStatusName {n}.sourceHandleName {n}.sourceFailure) {n}.sourceEnv):: .s (.scope []):: .k (.fn .call):: {n}.sourceCaller"),
    ("source_status_lookup",s!"lookupEnv {n}.sourceStatusName {n}.sourceEnv = some {n}.sourceStatusCell"),
    ("source_handle_lookup",s!"lookupEnv {n}.sourceHandleName {n}.sourceEnv = some {n}.sourceHandleCell"),
    ("source_status_read",s!"{n}.input.heap.get {n}.sourceStatusCell = some (.cell (some (.num (.lit (.zero false)))))"),
    ("source_handle_read",s!"{n}.input.heap.get {n}.sourceHandleCell = some (.cell (some {n}.sourceValue))"),
    ("source_output",("{" ++ s!"{n}.input with ctl := .ret {n}.sourceValue,stack := {n}.sourceCaller" ++ "} = " ++ n ++ ".output")),
    ("source_servers",s!"{n}.initialServer = {n}.nextServer")]
    do fact tag type
  Parametric.Driver.emit (header ++ s!"theorem {n}.source_run (C : CSrv) : runC {n}.F 15 {n}.input C = some ({n}.output,C) := by host_kernel_rfl")
  Parametric.Driver.emit (header ++ s!"theorem {n}.retained_transport
      (notes : RetainedNotes) (ν₀ ν : Nat → F64) (C₀ C : CSrv) (R : Ren)
      (FR : Ren → {n}.F.S → {n}.F.S → Prop) (live framed : Nat → Prop)
      (before after : List Val) (old old' : List Event) (s : St {n}.F.S)
      (inst : Inst ν₀ {n}.initialServer C₀)
      (h : Parametric.StateR (NumberRoles ν₀ ν C₀ C) FR R live framed before after old old' {n}.input s)
      (inventory : RetainedInventory notes ν₀ ν C₀ C R live {n}.input s)
      (role : Annotated.Value) (blockNote scopeNote callNote : Annotated.Tree) (callerNotes : List Annotated.Tree)
      (statusNote : notes.runtime.cells.cells {n}.sourceStatusCell = some (.literal (.lit (.zero false))))
      (handleNote : notes.runtime.cells.cells {n}.sourceHandleCell = some role)
      (stackNotes : notes.runtime.stack = blockNote::scopeNote::callNote::callerNotes) :
      ∃ result, runC {n}.F 15 {n}.input C₀ = some ({n}.output,C₀) ∧ runC {n}.F 15 s C = some (result,C) ∧
        Parametric.StateR (NumberRoles ν₀ ν C₀ C) FR R live framed before after old old' {n}.output result ∧
        RetainedInventory (notes.withRuntime ⟨returnNote role,callerNotes,notes.runtime.cells⟩)
          ν₀ ν C₀ C R live {n}.output result ∧ Inst ν₀ {n}.nextServer C₀ := by
      obtain ⟨result,left,right,post,retained,_,_,_⟩ := inventory.outArray_success_return h {n}.sourceEnv
        {n}.sourceStatusName {n}.sourceHandleName {n}.sourceStatusCell {n}.sourceHandleCell {n}.sourceFailure
        {n}.sourceValue role {n}.sourceCaller blockNote scopeNote callNote callerNotes {n}.source_control {n}.source_stack
        {n}.source_status_lookup {n}.source_handle_lookup {n}.source_status_read {n}.source_handle_read
        statusNote handleNote stackNotes
      rw [{n}.source_output] at left post retained
      exact ⟨result,left,right,post,retained,{n}.source_servers ▸ inst⟩")

end Host.Ts.Owned.Annotated.Driver
