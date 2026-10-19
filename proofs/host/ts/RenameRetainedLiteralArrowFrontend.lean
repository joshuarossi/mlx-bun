import host.ts.RenameRetainedLiteralArrow
import host.ts.RenameRuntimeDriverValues
set_option Elab.async false
namespace Host.Ts.Owned.Annotated.Driver
open Lean Elab Command Meta Parametric.Driver

elab "host_retained_literal_arrow " f:term ", " s:term " using " initial:term " to " t:term " using " next:term " as " name:ident : command => do
  let pre := (← getCurrNamespace) ++ name.getId
  liftTermElabM do
    let f ← Term.elabTermEnsuringType f (mkConst ``Ffi)
    let stateTy := mkApp (mkConst ``St) (mkApp (mkConst ``Ffi.S) f)
    let s ← Term.elabTermEnsuringType s stateTy
    let t ← Term.elabTermEnsuringType t stateTy
    let control ← whnf (← mkAppM ``St.ctl #[s])
    let callee ← field (← field control ``Ctl.call 3 0) ``Val.obj 1 0
    let object ← field (← mkAppM ``St.obj? #[s,callee]) ``Option.some 2 1
    let code ← field (← mkAppM ``Obj.kind #[object]) ``Kind.fn 1 0
    let fn ← field code ``Code.closure 4 0
    let expression ← field (← field fn ``Func.mk 7 3) ``Body.expr 1 0
    let literal ← field expression ``Expr.lit 1 0
    let value ← field (← mkAppM ``St.ctl #[t]) ``Ctl.ret 1 0
    for (tag,value) in [("F",f),("input",s),("output",t),("sourceCallee",callee),("sourceObject",object),
        ("sourceName",← field fn ``Func.mk 7 0),("sourceLiteral",literal),("sourceValue",value),
        ("sourceEnv",← field code ``Code.closure 4 1),("sourceHome",← field code ``Code.closure 4 3),
        ("sourceReceiver",← field control ``Ctl.call 3 1),("sourceArgs",← field control ``Ctl.call 3 2)] do
      addData (pre ++ Name.mkSimple tag) value (if tag == "input" || tag == "output" then some stateTy else none)
    addData (pre ++ `span) (mkNatLit 5)
    addData (pre ++ `initialServer) (← mkAppM ``numberServer #[← Term.elabTermEnsuringType initial (mkConst ``SSrv)])
    addData (pre ++ `nextServer) (← mkAppM ``numberServer #[← Term.elabTermEnsuringType next (mkConst ``SSrv)])
  let n := "_root_." ++ pre.toString
  let header := "open Host.Ts Host.Ts.Owned Host.Ts.Owned.Parametric Host.Ts.Owned.Annotated in\n"
  let fact (tag proposition : String) := Parametric.Driver.emit (header ++ s!"theorem {n}.{tag} : {proposition} := by host_kernel_rfl")
  fact "source_control" s!"{n}.input.ctl = .call (.obj {n}.sourceCallee) {n}.sourceReceiver {n}.sourceArgs"
  fact "source_read" s!"{n}.input.heap.get {n}.sourceCallee = some (.obj {n}.sourceObject)"
  fact "source_kind" s!"{n}.sourceObject.kind = .fn (.closure (literalArrow {n}.sourceName {n}.sourceLiteral) {n}.sourceEnv true {n}.sourceHome)"
  Parametric.Driver.emit (header ++ s!"noncomputable def {n}.parsed : LiteralValue {n}.sourceLiteral {n}.sourceValue := by constructor <;> host_kernel_rfl")
  fact "source_output" s!"{n}.input.ret {n}.sourceValue = {n}.output"
  fact "source_servers" s!"{n}.initialServer = {n}.nextServer"
  Parametric.Driver.emit (header ++ s!"theorem {n}.source_bound : {n}.input.next+2 ≤ 2^64 := by decide +kernel")
  Parametric.Driver.emit (header ++ s!"theorem {n}.source_run (C : CSrv) : runC {n}.F 5 {n}.input C = some ({n}.output,C) := by host_kernel_rfl")
  Parametric.Driver.emit (header ++ s!"theorem {n}.retained_transport
      (notes : RetainedNotes) (ν₀ ν : Nat → F64) (C₀ C : CSrv) (R : Ren)
      (FR : Ren → {n}.F.S → {n}.F.S → Prop) (live framed : Nat → Prop)
      (before after : List Val) (old old' : List Event) (s : St {n}.F.S)
      (inst : Inst ν₀ {n}.initialServer C₀)
      (h : Parametric.StateR (NumberRoles ν₀ ν C₀ C) FR R live framed before after old old' {n}.input s)
      (inventory : RetainedInventory notes ν₀ ν C₀ C R live {n}.input s)
      (fnRole thisRole : Annotated.Value) (argRoles : List Annotated.Value)
      (controlNote : notes.runtime.control = callNote fnRole thisRole argRoles)
      (targetBound : s.next+2 ≤ 2^64) :
      ∃ result, runC {n}.F 5 {n}.input C₀ = some ({n}.output,C₀) ∧ runC {n}.F 5 s C = some (result,C) ∧
        Parametric.StateR (NumberRoles ν₀ ν C₀ C) FR R live framed before after old old' {n}.output result ∧
        RetainedInventory (notes.withRuntime ⟨returnNote {n}.parsed.role,notes.runtime.stack,notes.runtime.cells⟩)
          ν₀ ν C₀ C R live {n}.output result ∧ Inst ν₀ {n}.nextServer C₀ := by
      obtain ⟨result,left,right,post,retained,_,_,_⟩ := inventory.literal_arrow_call_block h
        {n}.sourceCallee {n}.sourceObject {n}.sourceName {n}.sourceLiteral {n}.sourceValue {n}.parsed
        {n}.sourceEnv {n}.sourceHome {n}.sourceReceiver {n}.sourceArgs fnRole thisRole argRoles
        {n}.source_control {n}.source_read {n}.source_kind controlNote {n}.source_bound targetBound
      rw [{n}.source_output] at left post retained
      exact ⟨result,left,right,post,retained,{n}.source_servers ▸ inst⟩")
end Host.Ts.Owned.Annotated.Driver
