import host.ts.RenameRetainedMapperEntry
import host.ts.RenameRuntimeDriverValues
set_option Elab.async false
namespace Host.Ts.Owned.Annotated.Driver
open Lean Elab Command Meta Parametric.Driver

elab "host_retained_mapper_entry " f:term ", " s:term " using " initial:term " to " t:term " using " next:term " as " name:ident : command => do
  let pre := (← getCurrNamespace) ++ name.getId
  liftTermElabM do
    let f ← Term.elabTermEnsuringType f (mkConst ``Ffi)
    let stateTy := mkApp (mkConst ``St) (mkApp (mkConst ``Ffi.S) f)
    let s ← Term.elabTermEnsuringType s stateTy
    let t ← Term.elabTermEnsuringType t stateTy
    let control ← mkAppM ``St.ctl #[s]
    let callee ← field (← field control ``Ctl.call 3 0) ``Val.obj 1 0
    let object ← field (← mkAppM ``St.obj? #[s,callee]) ``Option.some 2 1
    let closure ← whnf (← field (← mkAppM ``Obj.kind #[object]) ``Kind.fn 1 0)
    let fn ← field closure ``Code.closure 4 0
    let name ← field (← field (← mkAppM ``fnParams #[fn]) ``List.cons 3 1) ``Pat.id 1 0
    let expression ← field (← field fn ``Func.mk 7 3) ``Body.expr 1 0
    let fieldName ← field expression ``Expr.member 3 1
    let arguments ← whnf (← field control ``Ctl.call 3 2)
    let owner ← field (← field arguments ``List.cons 3 1) ``Val.obj 1 0
    let extraArgs ← field arguments ``List.cons 3 2
    for (tag,value) in [("F",f),("input",s),("output",t),("sourceCallee",callee),("sourceOwner",owner),
      ("sourceExtraArgs",extraArgs),("sourceObject",object),("sourceEnv",closure.getAppArgs[1]!),
      ("sourceName",name),("sourceField",fieldName),("sourceThis",← field control ``Ctl.call 3 1)] do
      addData (pre ++ Name.mkSimple tag) value (if tag == "F" then none else if tag == "input" || tag == "output" then some stateTy else none)
    addData (pre ++ `span) (mkNatLit 4)
    addData (pre ++ `initialServer) (← mkAppM ``numberServer #[← Term.elabTermEnsuringType initial (mkConst ``SSrv)])
    addData (pre ++ `nextServer) (← mkAppM ``numberServer #[← Term.elabTermEnsuringType next (mkConst ``SSrv)])
  let n := "_root_." ++ pre.toString
  let header := "open Host.Ts Host.Ts.Owned Host.Ts.Owned.Parametric Host.Ts.Owned.Annotated in\n"
  let fact (tag proposition : String) := Parametric.Driver.emit (header ++ s!"theorem {n}.{tag} : {proposition} := by host_kernel_rfl")
  fact "source_control" s!"{n}.input.ctl = .call (.obj {n}.sourceCallee) {n}.sourceThis (.obj {n}.sourceOwner::{n}.sourceExtraArgs)"
  fact "source_read" s!"{n}.input.heap.get {n}.sourceCallee = some (.obj {n}.sourceObject)"
  fact "source_kind" s!"{n}.sourceObject.kind = .fn (.closure (mapperFunction {n}.sourceName {n}.sourceField) {n}.sourceEnv true .undef)"
  fact "source_output" s!"mapperEntrySource {n}.input {n}.sourceEnv {n}.sourceName {n}.sourceField {n}.sourceThis {n}.sourceOwner {n}.sourceExtraArgs = {n}.output"
  fact "source_servers" s!"{n}.initialServer = {n}.nextServer"
  Parametric.Driver.emit (header ++ s!"theorem {n}.source_bound : {n}.input.next+3 ≤ 2^64 := by decide +kernel")
  Parametric.Driver.emit (header ++ s!"theorem {n}.source_run (C : CSrv) : runC {n}.F 4 {n}.input C = some ({n}.output,C) := by host_kernel_rfl")
  Parametric.Driver.emit (header ++ s!"theorem {n}.retained_transport
      (notes : RetainedNotes) (ν₀ ν : Nat → F64) (C₀ C : CSrv) (R : Ren)
      (FR : Ren → {n}.F.S → {n}.F.S → Prop) (live framed : Nat → Prop)
      (before after : List Val) (old old' : List Event) (s : St {n}.F.S)
      (inst : Inst ν₀ {n}.initialServer C₀)
      (h : Parametric.StateR (NumberRoles ν₀ ν C₀ C) FR R live framed before after old old' {n}.input s)
      (inventory : RetainedInventory notes ν₀ ν C₀ C R live {n}.input s)
      (fnRole thisRole : Annotated.Value) (extraRoles : List Annotated.Value)
      (controlNote : notes.runtime.control = callNote fnRole thisRole (.obj {n}.sourceOwner::extraRoles))
      (targetBound : s.next+3 ≤ 2^64) :
      ∃ result, runC {n}.F 4 {n}.input C₀ = some ({n}.output,C₀) ∧ runC {n}.F 4 s C = some (result,C) ∧
        Parametric.StateR (NumberRoles ν₀ ν C₀ C) FR R (ClosureLive live {n}.input.next true .undef (mapperFunction {n}.sourceName {n}.sourceField))
          framed before after old old' {n}.output result ∧
        RetainedInventory (notes.withRuntime (notes.runtime.mapperEntry {n}.sourceEnv {n}.sourceName {n}.sourceField {n}.input.next {n}.sourceOwner))
          ν₀ ν C₀ C R (ClosureLive live {n}.input.next true .undef (mapperFunction {n}.sourceName {n}.sourceField)) {n}.output result ∧
        Inst ν₀ {n}.nextServer C₀ := by
      obtain ⟨result,left,right,post,retained,_,_,_⟩ := inventory.mapper_entry_block h {n}.sourceCallee {n}.sourceOwner
        {n}.sourceObject {n}.sourceEnv {n}.sourceName {n}.sourceField {n}.sourceThis fnRole thisRole {n}.sourceExtraArgs extraRoles
        {n}.source_control {n}.source_read {n}.source_kind controlNote {n}.source_bound targetBound
      rw [{n}.source_output] at left post retained
      exact ⟨result,left,right,post,retained,{n}.source_servers ▸ inst⟩")

end Host.Ts.Owned.Annotated.Driver
