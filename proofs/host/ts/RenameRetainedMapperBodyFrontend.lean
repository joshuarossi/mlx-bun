import host.ts.RenameRetainedMapperBody
import host.ts.RenameRetainedMapperFrontend
set_option Elab.async false
namespace Host.Ts.Owned.Annotated.Driver
open Lean Elab Command Meta

/-- Extend a checked mapper-entry descriptor through its parameter read.
All source metadata is checked again against the six-step endpoint. -/
elab "host_retained_mapper_receiver " entry:ident " to " target:term " using " next:term " as " name:ident : command => do
  let pre := (← getCurrNamespace) ++ name.getId
  let p := entry.getId.toString
  let n := "_root_." ++ pre.toString
  let header := "open Host.Ts Host.Ts.Owned Host.Ts.Owned.Parametric Host.Ts.Owned.Annotated in\n"
  let some target := target.raw.reprint | throwError "mapper receiver: cannot print endpoint"
  Parametric.Driver.emit (header ++ s!"def {n}.span : Nat := 6")
  Parametric.Driver.emit (header ++ s!"noncomputable def {n}.F : Ffi := {p}.F")
  Parametric.Driver.emit (header ++ s!"noncomputable def {n}.input : St {n}.F.S := {p}.input")
  Parametric.Driver.emit (header ++ s!"noncomputable def {n}.output : St {n}.F.S := {target}")
  Parametric.Driver.emit (header ++ s!"noncomputable def {n}.initialServer : SSrv := {p}.initialServer")
  liftTermElabM do
    let server ← Term.elabTermEnsuringType next (mkConst ``SSrv)
    Parametric.Driver.addData (pre ++ `nextServer) (← mkAppM ``numberServer #[server])
  let fact (tag proposition : String) := Parametric.Driver.emit (header ++ s!"theorem {n}.{tag} : {proposition} := by host_kernel_rfl")
  fact "source_output" s!"mapperReceiverSource {n}.input {p}.sourceEnv {p}.sourceName {p}.sourceField {p}.sourceThis {p}.sourceOwner {p}.sourceExtraArgs = {n}.output"
  fact "source_servers" s!"{n}.initialServer = {n}.nextServer"
  Parametric.Driver.emit (header ++ s!"theorem {n}.source_run (C : CSrv) : runC {n}.F 6 {n}.input C = some ({n}.output,C) := by host_kernel_rfl")
  Parametric.Driver.emit (header ++ s!"theorem {n}.retained_transport
      (notes : RetainedNotes) (ν₀ ν : Nat → F64) (C₀ C : CSrv) (R : Ren)
      (FR : Ren → {n}.F.S → {n}.F.S → Prop) (live framed : Nat → Prop)
      (before after : List Val) (old old' : List Event) (s : St {n}.F.S)
      (inst : Inst ν₀ {n}.initialServer C₀)
      (h : Parametric.StateR (NumberRoles ν₀ ν C₀ C) FR R live framed before after old old' {n}.input s)
      (inventory : RetainedInventory notes ν₀ ν C₀ C R live {n}.input s)
      (fnRole thisRole : Annotated.Value) (extraRoles : List Annotated.Value)
      (controlNote : notes.runtime.control = callNote fnRole thisRole (.obj {p}.sourceOwner::extraRoles))
      (targetBound : s.next+3 ≤ 2^64) :
      ∃ result, runC {n}.F 6 {n}.input C₀ = some ({n}.output,C₀) ∧ runC {n}.F 6 s C = some (result,C) ∧
        Parametric.StateR (NumberRoles ν₀ ν C₀ C) FR R (ClosureLive live {n}.input.next true .undef (mapperFunction {p}.sourceName {p}.sourceField))
          framed before after old old' {n}.output result ∧
        RetainedInventory (notes.withRuntime (notes.runtime.mapperReceiver {p}.sourceEnv {p}.sourceName {p}.sourceField {n}.input.next {p}.sourceOwner))
          ν₀ ν C₀ C R (ClosureLive live {n}.input.next true .undef (mapperFunction {p}.sourceName {p}.sourceField)) {n}.output result ∧
        Inst ν₀ {n}.nextServer C₀ := by
      obtain ⟨result,left,right,post,retained,_,_,_⟩ := inventory.mapper_receiver_block h
        {p}.sourceCallee {p}.sourceOwner {p}.sourceObject {p}.sourceEnv {p}.sourceName {p}.sourceField {p}.sourceThis
        fnRole thisRole {p}.sourceExtraArgs extraRoles {p}.source_control {p}.source_read {p}.source_kind controlNote {p}.source_bound targetBound
      rw [{n}.source_output] at left post retained
      exact ⟨result,left,right,post,retained,{n}.source_servers ▸ inst⟩")

elab "host_retained_mapper_return " f:term ", " s:term " using " initial:term " to " t:term " using " next:term " as " name:ident : command => do
  let pre := (← getCurrNamespace) ++ name.getId
  liftTermElabM do
    let f ← Term.elabTermEnsuringType f (mkConst ``Ffi)
    let stateTy := mkApp (mkConst ``St) (mkApp (mkConst ``Ffi.S) f)
    let s ← Term.elabTermEnsuringType s stateTy
    let t ← Term.elabTermEnsuringType t stateTy
    let value ← Parametric.Driver.field (← mkAppM ``St.ctl #[s]) ``Ctl.ret 1 0
    let stack ← mkAppM ``St.stack #[s]
    let afterReturn ← Parametric.Driver.field stack ``List.cons 3 2
    let caller ← Parametric.Driver.field afterReturn ``List.cons 3 2
    for (tag,value) in [("F",f),("input",s),("output",t),("sourceValue",value),("sourceCaller",caller)] do
      Parametric.Driver.addData (pre ++ Name.mkSimple tag) value (if tag == "input" || tag == "output" then some stateTy else none)
    Parametric.Driver.addData (pre ++ `span) (mkNatLit 2)
    Parametric.Driver.addData (pre ++ `initialServer) (← mkAppM ``numberServer #[← Term.elabTermEnsuringType initial (mkConst ``SSrv)])
    Parametric.Driver.addData (pre ++ `nextServer) (← mkAppM ``numberServer #[← Term.elabTermEnsuringType next (mkConst ``SSrv)])
  let n := "_root_." ++ pre.toString
  let header := "open Host.Ts Host.Ts.Owned Host.Ts.Owned.Parametric Host.Ts.Owned.Annotated in\n"
  let fact (tag proposition : String) := Parametric.Driver.emit (header ++ s!"theorem {n}.{tag} : {proposition} := by host_kernel_rfl")
  fact "source_control" s!"{n}.input.ctl = .ret {n}.sourceValue"
  fact "source_stack" s!"{n}.input.stack = .s .ret :: .k (.fn .call) :: {n}.sourceCaller"
  fact "source_output" ("{" ++ s!"{n}.input with ctl := .ret {n}.sourceValue,stack := {n}.sourceCaller" ++ "} = " ++ n ++ ".output")
  fact "source_servers" s!"{n}.initialServer = {n}.nextServer"
  Parametric.Driver.emit (header ++ s!"theorem {n}.source_run (C : CSrv) : runC {n}.F 2 {n}.input C = some ({n}.output,C) := by host_kernel_rfl")
  Parametric.Driver.emit (header ++ s!"theorem {n}.retained_transport
      (notes : RetainedNotes) (ν₀ ν : Nat → F64) (C₀ C : CSrv) (R : Ren)
      (FR : Ren → {n}.F.S → {n}.F.S → Prop) (live framed : Nat → Prop)
      (before after : List Val) (old old' : List Event) (s : St {n}.F.S)
      (inst : Inst ν₀ {n}.initialServer C₀)
      (h : Parametric.StateR (NumberRoles ν₀ ν C₀ C) FR R live framed before after old old' {n}.input s)
      (inventory : RetainedInventory notes ν₀ ν C₀ C R live {n}.input s)
      (role : Annotated.Value) (retNote callNote : Annotated.Tree) (callerNotes : List Annotated.Tree)
      (controlNote : notes.runtime.control = returnNote role)
      (stackNotes : notes.runtime.stack = retNote::callNote::callerNotes) :
      ∃ result, runC {n}.F 2 {n}.input C₀ = some ({n}.output,C₀) ∧ runC {n}.F 2 s C = some (result,C) ∧
        Parametric.StateR (NumberRoles ν₀ ν C₀ C) FR R live framed before after old old' {n}.output result ∧
        RetainedInventory (notes.withRuntime ⟨returnNote role,callerNotes,notes.runtime.cells⟩) ν₀ ν C₀ C R live {n}.output result ∧
        Inst ν₀ {n}.nextServer C₀ := by
      obtain ⟨result,left,right,post,retained,_,_,_⟩ := inventory.mapper_return_block h
        {n}.sourceValue role [] {n}.sourceCaller retNote callNote callerNotes
        {n}.source_control {n}.source_stack controlNote stackNotes
      rw [{n}.source_output] at left post retained
      exact ⟨result,left,right,post,retained,{n}.source_servers ▸ inst⟩")

end Host.Ts.Owned.Annotated.Driver
