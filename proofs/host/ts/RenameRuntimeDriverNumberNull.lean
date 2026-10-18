import host.ts.RenameRetainedNumberNull
import host.ts.RenameRouteDriver
import host.ts.RenameRuntimeSourceCut

set_option Elab.async false
namespace Host.Ts.Owned.Annotated.Driver
open Lean Elab Command Meta Parametric.Driver

/-- The original strict number/null guard is selected by constructors;
unresolved numeric references are accepted without reading their table. -/
elab "host_retained_number_null " f:term ", " s:term " using " initial:term " to " t:term " using " next:term " as " name:ident : command => do
  let pre := (← getCurrNamespace) ++ name.getId
  liftTermElabM do
    let f ← Term.elabTermEnsuringType f (mkConst ``Ffi)
    let stateTy := mkApp (mkConst ``St) (mkApp (mkConst ``Ffi.S) f)
    let s ← Term.elabTermEnsuringType s stateTy
    let t ← Term.elabTermEnsuringType t stateTy
    let control ← whnf (← mkAppM ``St.ctl #[s])
    unless control.isAppOfArity ``Ctl.ret 1 && (← whnf control.getAppArgs[0]!).isConstOf ``Val.null do
      throwError "host_retained_number_null: expected returned null"
    let stack ← mkAppM ``St.stack #[s]
    let frame ← field (← field stack ``List.cons 3 1) ``Frame.e 1 0
    let operation ← field frame ``ExprF.binR 2 0
    unless (← whnf operation).isConstOf ``BinOp.seq do
      throwError "host_retained_number_null: expected strict equality"
    let value ← field (← field frame ``ExprF.binR 2 1) ``Val.num 1 0
    let frames ← field stack ``List.cons 3 2
    for (tag,value) in [("F",f),("input",s),("output",t),("value",value),("frames",frames)] do
      addData (pre ++ Name.mkSimple tag) value (if tag == "input" || tag == "output" then some stateTy else none)
    addData (pre ++ `initialServer) (← mkAppM ``numberServer #[← Term.elabTermEnsuringType initial (mkConst ``SSrv)])
    addData (pre ++ `nextServer) (← mkAppM ``numberServer #[← Term.elabTermEnsuringType next (mkConst ``SSrv)])
  let n := "_root_." ++ pre.toString
  let header := "open Host.Ts Host.Ts.Owned Host.Ts.Owned.Parametric Host.Ts.Owned.Annotated in\n"
  for (tag,type) in [
    ("source_control",s!"{n}.input.ctl = .ret .null"),
    ("source_stack",s!"{n}.input.stack = .e (.binR .seq (.num {n}.value))::{n}.frames"),
    ("source_servers",s!"{n}.initialServer = {n}.nextServer")]
    do Parametric.Driver.emit (header ++ s!"theorem {n}.{tag} : {type} := by host_kernel_rfl")
  Parametric.Driver.emit (header ++ s!"theorem {n}.source_run (C : CSrv) : interpC (step {n}.F {n}.input).run C = some ({n}.output,C) := by host_kernel_rfl")
  Parametric.Driver.emit (header ++ s!"theorem {n}.source_step : interpS (step {n}.F {n}.input).run {n}.initialServer = some ({n}.output,{n}.nextServer) := by host_kernel_rfl")
  Parametric.Driver.emit (header ++ s!"theorem {n}.retained_transport
      (notes : RetainedNotes) (ν₀ ν : Nat → F64) (C₀ C : CSrv) (R : Ren)
      (FR : Ren → {n}.F.S → {n}.F.S → Prop) (live framed : Nat → Prop)
      (before after : List Val) (old old' : List Event) (s : St {n}.F.S)
      (inst : Inst ν₀ {n}.initialServer C₀)
      (h : Parametric.StateR (NumberRoles ν₀ ν C₀ C) FR R live framed before after old old' {n}.input s)
      (inventory : RetainedInventory notes ν₀ ν C₀ C R live {n}.input s) :
      ∃ result, interpC (step {n}.F {n}.input).run C₀ = some ({n}.output,C₀) ∧
        interpC (step {n}.F s).run C = some (result,C) ∧
        Parametric.StateR (NumberRoles ν₀ ν C₀ C) FR R live framed before after old old' {n}.output result ∧
        RetainedInventory (notes.withRuntime (notes.runtime.binaryResult (.bool false) notes.runtime.stack.tail))
          ν₀ ν C₀ C R live {n}.output result ∧ Inst ν₀ {n}.nextServer C₀ := by
      obtain ⟨frames,left,right,post,retained⟩ := inventory.number_null_seq_step h {n}.value {n}.frames {n}.source_control {n}.source_stack
      have source := {n}.source_run C₀
      have same := congrArg Prod.fst (Option.some.inj (left.symm.trans source))
      dsimp only at same
      rw [same] at post retained
      exact ⟨_,source,right,post,retained,{n}.source_servers ▸ inst⟩")

end Host.Ts.Owned.Annotated.Driver
