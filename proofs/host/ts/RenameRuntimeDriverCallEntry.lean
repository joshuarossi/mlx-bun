import host.ts.RenameRuntimeDriverValues
import host.ts.RenameRuntimeCallEntry
set_option Elab.async false
namespace Host.Ts.Owned.Annotated.Driver
open Lean Elab Command Meta

/-- Checked source selection for identifier and named-method call entries. -/
elab "host_runtime_call_entry " f:term ", " s:term " using " initial:term " to " t:term " using " next:term " as " name:ident : command => do
  let pre := (← getCurrNamespace) ++ name.getId
  liftTermElabM do
    let f ← Term.elabTermEnsuringType f (mkConst ``Ffi)
    let stateTy := mkApp (mkConst ``St) (mkApp (mkConst ``Ffi.S) f)
    let s ← Term.elabTermEnsuringType s stateTy
    let t ← Term.elabTermEnsuringType t stateTy
    let control ← mkAppM ``St.ctl #[s]
    let call ← whnf (← Parametric.Driver.field control ``Ctl.ev 2 0)
    let callee ← whnf (← Parametric.Driver.field call ``Expr.call 3 0)
    let entry ← if callee.isAppOfArity ``Expr.id 1 then
        pure (mkApp (mkConst ``CallEntry.identifier) callee.getAppArgs[0]!)
      else if callee.isAppOfArity ``Expr.member 3 then
        pure (mkAppN (mkConst ``CallEntry.method) callee.getAppArgs)
      else throwError "host_runtime_call_entry: unsupported source callee syntax"
    for (tag,value) in [("F",f),("input",s),("output",t),("sourceEntry",entry),
      ("sourceArgs",call.getAppArgs[1]!), ("sourceOptional",call.getAppArgs[2]!),
      ("sourceEnv",← Parametric.Driver.field control ``Ctl.ev 2 1)] do
      let type? := if tag == "input" || tag == "output" then
        some (mkApp (mkConst ``St) (mkApp (mkConst ``Ffi.S) (mkConst (pre ++ `F)))) else none
      Parametric.Driver.addData (pre ++ Name.mkSimple tag) value type?
    let initial ← Term.elabTermEnsuringType initial (mkConst ``SSrv)
    let next ← Term.elabTermEnsuringType next (mkConst ``SSrv)
    Parametric.Driver.addData (pre ++ `initialServer) (← mkAppM ``numberServer #[initial])
    Parametric.Driver.addData (pre ++ `nextServer) (← mkAppM ``numberServer #[next])
  let n := "_root_." ++ pre.toString
  let header := "open Host.Ts Host.Ts.Owned Host.Ts.Owned.Parametric Host.Ts.Owned.Annotated in\n"
  let fact (tag proposition : String) := Parametric.Driver.emit (header ++ s!"theorem {n}.{tag} : {proposition} := by host_kernel_rfl")
  fact "source_control" s!"{n}.input.ctl = .ev (.call {n}.sourceEntry.callee {n}.sourceArgs {n}.sourceOptional) {n}.sourceEnv"
  fact "source_post" s!"({n}.input.push ({n}.sourceEntry.frame {n}.sourceArgs {n}.sourceOptional {n}.sourceEnv)).go (.ev {n}.sourceEntry.focus {n}.sourceEnv) = {n}.output"
  fact "source_step" s!"interpS (step {n}.F {n}.input).run {n}.initialServer = some ({n}.output,{n}.nextServer)"
  Parametric.Driver.emit (header ++ s!"theorem {n}.runtime_transport
      (notes : RuntimeNotes) (ν₀ ν : Nat → F64) (C₀ C : CSrv) (R : Ren)
      (FR : Ren → {n}.F.S → {n}.F.S → Prop) (live framed : Nat → Prop) (before after : List Val) (old old' : List Event)
      (s : St {n}.F.S) (inst : Inst ν₀ {n}.initialServer C₀)
      (h : Parametric.StateR (NumberRoles ν₀ ν C₀ C) FR R live framed before after old old' {n}.input s)
      (inventory : RuntimeInventory notes ν₀ ν C₀ C R live {n}.input s) :
      ∃ result, interpC (step {n}.F {n}.input).run C₀ = some ({n}.output,C₀) ∧
      interpC (step {n}.F s).run C = some (result,C) ∧
      Parametric.StateR (NumberRoles ν₀ ν C₀ C) FR R live framed before after old old' {n}.output result ∧
      RuntimeInventory (notes.callEntry {n}.sourceEntry {n}.sourceArgs {n}.sourceOptional {n}.sourceEnv) ν₀ ν C₀ C R live {n}.output result ∧ Inst ν₀ {n}.nextServer C₀ := by
      obtain ⟨left,right,related,annotated⟩ := inventory.call_entry_step {n}.F FR notes ν₀ ν C₀ C R live framed before after old old'
        {n}.input s h {n}.sourceEntry {n}.sourceArgs {n}.sourceOptional {n}.sourceEnv {n}.source_control
      have source : interpC (step {n}.F {n}.input).run C₀ = some ({n}.output,C₀) := by simpa only [{n}.source_post] using left
      exact ⟨_,source,right,{n}.source_post ▸ related,{n}.source_post ▸ annotated,
        pure_step_inst {n}.F ν₀ {n}.initialServer {n}.nextServer C₀ {n}.input {n}.output inst {n}.source_step source⟩")

end Host.Ts.Owned.Annotated.Driver
