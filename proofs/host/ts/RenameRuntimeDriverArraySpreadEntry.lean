import host.ts.RenameRetainedArraySpreadEntry
import host.ts.RenameRuntimeDriverValues
set_option Elab.async false
namespace Host.Ts.Owned.Annotated.Driver
open Lean Elab Command Meta

/-- Select the original leading array-spread expression and its saved source
continuation. The kernel checks both source equations and retained transport. -/
elab "host_retained_array_spread_entry " f:term ", " s:term " using " initial:term " to " t:term " using " next:term " as " name:ident : command => do
  let pre := (← getCurrNamespace) ++ name.getId
  liftTermElabM do
    let f ← Term.elabTermEnsuringType f (mkConst ``Ffi)
    let stateTy := mkApp (mkConst ``St) (mkApp (mkConst ``Ffi.S) f)
    let s ← Term.elabTermEnsuringType s stateTy
    let t ← Term.elabTermEnsuringType t stateTy
    for (tag,value) in [("F",f),("input",s),("output",t)] do
      Parametric.Driver.addData (pre ++ Name.mkSimple tag) value (if tag == "F" then none else some stateTy)
    let control ← mkAppM ``St.ctl #[s]
    let elements ← Parametric.Driver.field (← Parametric.Driver.field control ``Ctl.ev 2 0) ``Expr.array 1 0
    let first ← Parametric.Driver.field elements ``List.cons 3 1
    for (tag,value) in [("sourceExpression",← Parametric.Driver.field first ``Elem.spread 1 0),
      ("sourceRest",← Parametric.Driver.field elements ``List.cons 3 2),
      ("sourceEnv",← Parametric.Driver.field control ``Ctl.ev 2 1)] do
      Parametric.Driver.addData (pre ++ Name.mkSimple tag) value
    let initial ← Term.elabTermEnsuringType initial (mkConst ``SSrv)
    let next ← Term.elabTermEnsuringType next (mkConst ``SSrv)
    Parametric.Driver.addData (pre ++ `initialServer) (← mkAppM ``numberServer #[initial])
    Parametric.Driver.addData (pre ++ `nextServer) (← mkAppM ``numberServer #[next])
  let n := "_root_." ++ pre.toString
  let header := "open Host.Ts Host.Ts.Owned Host.Ts.Owned.Parametric Host.Ts.Owned.Annotated in\n"
  let fact (tag proposition : String) := Parametric.Driver.emit (header ++ s!"theorem {n}.{tag} : {proposition} := by host_kernel_rfl")
  fact "source_control" s!"{n}.input.ctl = .ev (.array (.spread {n}.sourceExpression::{n}.sourceRest)) {n}.sourceEnv"
  Parametric.Driver.emit (header ++ s!"theorem {n}.source_run (C : CSrv) : interpC (step {n}.F {n}.input).run C = some ({n}.output,C) := by host_kernel_rfl")
  fact "source_step" s!"interpS (step {n}.F {n}.input).run {n}.initialServer = some ({n}.output,{n}.nextServer)"
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
        RetainedInventory (notes.withRuntime (notes.runtime.arraySpreadEntry
          {n}.sourceExpression {n}.sourceRest {n}.sourceEnv)) ν₀ ν C₀ C R live {n}.output result ∧
        Inst ν₀ {n}.nextServer C₀ := by
      obtain ⟨left,right,post,retained⟩ := inventory.array_spread_entry_step h
        {n}.sourceExpression {n}.sourceRest {n}.sourceEnv {n}.source_control
      have source := {n}.source_run C₀
      have same := congrArg Prod.fst (Option.some.inj (left.symm.trans source))
      dsimp only at same
      rw [same] at post retained
      exact ⟨_,source,right,post,retained,pure_step_inst {n}.F ν₀ {n}.initialServer {n}.nextServer C₀
        {n}.input {n}.output inst {n}.source_step source⟩")

end Host.Ts.Owned.Annotated.Driver
