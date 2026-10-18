import host.ts.RenameRetainedGetterReturn
import host.ts.RenameRetainedGetterFrontend
set_option Elab.async false
namespace Host.Ts.Owned.Annotated.Driver
open Lean Elab Command Meta

/-- Complete an existing checked getter entry through its original caller.
The entry namespace supplies checked source metadata, never target facts. -/
elab "host_retained_getter_return " entry:ident " to " target:term " using " next:term " as " name:ident : command => do
  let pre := (← getCurrNamespace) ++ name.getId
  let p := entry.getId.toString
  let n := "_root_." ++ pre.toString
  let header := "open Host.Ts Host.Ts.Owned Host.Ts.Owned.Parametric Host.Ts.Owned.Annotated in\n"
  let some target := target.raw.reprint | throwError "getter return: cannot print source endpoint"
  Parametric.Driver.emit (header ++ s!"def {n}.span : Nat := 13")
  Parametric.Driver.emit (header ++ s!"noncomputable def {n}.F : Ffi := {p}.F")
  Parametric.Driver.emit (header ++ s!"noncomputable def {n}.input : St {n}.F.S := {p}.input")
  Parametric.Driver.emit (header ++ s!"noncomputable def {n}.output : St {n}.F.S := {target}")
  Parametric.Driver.emit (header ++ s!"noncomputable def {n}.initialServer : SSrv := {p}.initialServer")
  liftTermElabM do
    let server ← Term.elabTermEnsuringType next (mkConst ``SSrv)
    Parametric.Driver.addData (pre ++ `nextServer) (← mkAppM ``numberServer #[server])
  let fact (tag proposition : String) := Parametric.Driver.emit (header ++ s!"theorem {n}.{tag} : {proposition} := by host_kernel_rfl")
  fact "source_caller" s!"{p}.sourceTail = .s (.scope []) :: .k (.fn .call) :: {p}.sourceTail.drop 2"
  fact "source_stack" s!"{n}.input.stack = .s (.if_ {p}.sourceYes none {p}.sourceEnv) :: .s (.block [.ret (some (.priv .this {p}.sourceHandleName false))] {p}.sourceEnv) :: .s (.scope []) :: .k (.fn .call) :: {p}.sourceTail.drop 2"
  fact "source_output" ("{" ++ s!"{n}.input with ctl := .ret {p}.sourceValue,stack := {p}.sourceTail.drop 2" ++ "} = " ++ n ++ ".output")
  fact "source_servers" s!"{n}.initialServer = {n}.nextServer"
  Parametric.Driver.emit (header ++ s!"theorem {n}.source_run (C : CSrv) : runC {n}.F 13 {n}.input C = some ({n}.output,C) := by host_kernel_rfl")
  Parametric.Driver.emit (header ++ s!"theorem {n}.retained_transport
      (notes : RetainedNotes) (ν₀ ν : Nat → F64) (C₀ C : CSrv) (R : Ren)
      (FR : Ren → {n}.F.S → {n}.F.S → Prop) (live framed : Nat → Prop)
      (before after : List Val) (old old' : List Event) (s : St {n}.F.S)
      (inst : Inst ν₀ {n}.initialServer C₀)
      (h : Parametric.StateR (NumberRoles ν₀ ν C₀ C) FR R live framed before after old old' {n}.input s)
      (inventory : RetainedInventory notes ν₀ ν C₀ C R live {n}.input s)
      (role : Annotated.Value) (ifNote blockNote scopeNote callNote : Annotated.Tree) (callerNotes : List Annotated.Tree)
      (thisNote : notes.runtime.cells.cells {p}.sourceThisCell = some (.obj {p}.sourceOwner))
      (fieldNote : notes.privates.owners {p}.sourceOwner = some ⟨{p}.sourceBrand,{p}.sourceHandleName,role⟩)
      (stackNotes : notes.runtime.stack = ifNote::blockNote::scopeNote::callNote::callerNotes) :
      ∃ result, runC {n}.F 13 {n}.input C₀ = some ({n}.output,C₀) ∧ runC {n}.F 13 s C = some (result,C) ∧
        Parametric.StateR (NumberRoles ν₀ ν C₀ C) FR R live framed before after old old' {n}.output result ∧
        RetainedInventory (notes.withRuntime ⟨returnNote role,callerNotes,notes.runtime.cells⟩)
          ν₀ ν C₀ C R live {n}.output result ∧ Inst ν₀ {n}.nextServer C₀ := by
      obtain ⟨result,left,right,post,retained,_,_,_⟩ := inventory.getter_body_return_block h
        {p}.sourceEnv {p}.sourceThisCell {p}.sourceOwner {p}.sourceBrand {p}.sourceDisposedName {p}.sourceHandleName
        {p}.sourceObject {p}.sourceValue role {p}.sourceDisposedWritable {p}.sourceDisposedEnumerable
        {p}.sourceHandleWritable {p}.sourceHandleEnumerable {p}.sourceYes ({p}.sourceTail.drop 2)
        ifNote blockNote scopeNote callNote callerNotes {p}.source_control
        {n}.source_stack {p}.source_this_lookup {p}.source_disposed_lookup
        {p}.source_handle_lookup {p}.source_this_read {p}.source_object_read {p}.source_kind
        {p}.source_disposed {p}.source_handle thisNote fieldNote stackNotes
      rw [{n}.source_output] at left post retained
      exact ⟨result,left,right,post,retained,{n}.source_servers ▸ inst⟩")

end Host.Ts.Owned.Annotated.Driver
