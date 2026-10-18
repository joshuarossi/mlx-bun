import host.ts.RenameRuntimeDriverValues
import host.ts.RenameRuntimeDescent
set_option Elab.async false
namespace Host.Ts.Owned.Annotated.Driver
open Lean Elab Command Meta
open Parametric

/-- Choose a pure expression descent from the actual source syntax. Fixed old
operands survive under the newly created structural continuation. -/
elab "host_runtime_descent " f:term ", " s:term " using " initial:term " to " t:term " using " next:term " as " name:ident : command => do
  let pre := (← getCurrNamespace) ++ name.getId
  liftTermElabM do
    let f ← Term.elabTermEnsuringType f (mkConst ``Ffi)
    let stateTy := mkApp (mkConst ``St) (mkApp (mkConst ``Ffi.S) f)
    let s ← Term.elabTermEnsuringType s stateTy
    let t ← Term.elabTermEnsuringType t stateTy
    let control ← whnf (← mkAppM ``St.ctl #[s])
    let expr ← whnf (← Parametric.Driver.field control ``Ctl.ev 2 0)
    let descent ← match expr.getAppFn.constName! with
      | ``Expr.bin => pure (mkAppN (mkConst ``Descent.binary) expr.getAppArgs)
      | ``Expr.log => pure (mkAppN (mkConst ``Descent.logical) expr.getAppArgs)
      | ``Expr.cond => pure (mkAppN (mkConst ``Descent.conditional) expr.getAppArgs)
      | ``Expr.seq => pure (mkAppN (mkConst ``Descent.sequence) expr.getAppArgs)
      | ``Expr.member => pure (mkAppN (mkConst ``Descent.member) expr.getAppArgs)
      | ``Expr.index => pure (mkAppN (mkConst ``Descent.index) expr.getAppArgs)
      | ``Expr.new => pure (mkAppN (mkConst ``Descent.construct) expr.getAppArgs)
      | ``Expr.chain => pure (mkAppN (mkConst ``Descent.chain) expr.getAppArgs)
      | ``Expr.await => pure (mkAppN (mkConst ``Descent.await) expr.getAppArgs)
      | ``Expr.yield =>
        let value ← Parametric.Driver.field expr.getAppArgs[0]! ``Option.some 2 1
        pure (mkApp2 (mkConst ``Descent.yield) value expr.getAppArgs[1]!)
      | _ => throwError "host_runtime_descent: unsupported source expression"
    for (tag,value) in [("F",f),("input",s),("output",t),("sourceDescent",descent),
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
  fact "source_control" s!"{n}.input.ctl = .ev {n}.sourceDescent.whole {n}.sourceEnv"
  fact "source_post" s!"({n}.input.push ({n}.sourceDescent.frame {n}.sourceEnv)).go (.ev {n}.sourceDescent.focus {n}.sourceEnv) = {n}.output"
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
      RuntimeInventory (notes.descent {n}.sourceDescent {n}.sourceEnv) ν₀ ν C₀ C R live {n}.output result ∧ Inst ν₀ {n}.nextServer C₀ := by
      obtain ⟨left,right,related,annotated⟩ := inventory.descent_step {n}.F FR notes ν₀ ν C₀ C R live framed before after old old'
        {n}.input s h {n}.sourceDescent {n}.sourceEnv {n}.source_control
      have source : interpC (step {n}.F {n}.input).run C₀ = some ({n}.output,C₀) := by simpa only [{n}.source_post] using left
      exact ⟨_,source,right,{n}.source_post ▸ related,{n}.source_post ▸ annotated,
        pure_step_inst {n}.F ν₀ {n}.initialServer {n}.nextServer C₀ {n}.input {n}.output inst {n}.source_step source⟩")

end Host.Ts.Owned.Annotated.Driver
