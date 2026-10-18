import host.ts.RenameRetainedNullishVariable
import host.ts.RenameRuntimeDriverValues
set_option Elab.async false
namespace Host.Ts.Owned.Annotated.Driver
open Lean Elab Command Meta
elab "host_retained_nullish_variable " f:term ", " s:term " using " initial:term " to " t:term " using " next:term " as " name:ident : command => do
  let pre := (← getCurrNamespace) ++ name.getId
  liftTermElabM do
    let f ← Term.elabTermEnsuringType f (mkConst ``Ffi)
    let stateTy := mkApp (mkConst ``St) (mkApp (mkConst ``Ffi.S) f)
    let s ← Term.elabTermEnsuringType s stateTy
    let t ← Term.elabTermEnsuringType t stateTy
    let ctl ← whnf (← mkAppM ``St.ctl #[s])
    let env ← Parametric.Driver.field ctl ``Ctl.ev 2 1
    let expr ← whnf (← Parametric.Driver.field ctl ``Ctl.ev 2 0)
    let op ← Parametric.Driver.field expr ``Expr.assign 3 0
    unless ← isDefEq op (mkApp (mkConst ``AsgOp.log) (mkConst ``LogOp.nullish)) do
      throwError "host_retained_nullish_variable: expected nullish assignment"
    let key ← Parametric.Driver.field (← Parametric.Driver.field expr ``Expr.assign 3 1) ``Pat.id 1 0
    let rhs ← Parametric.Driver.field expr ``Expr.assign 3 2
    let cell ← Parametric.Driver.field (← mkAppM ``lookupEnv #[key,env]) ``Option.some 2 1
    let value ← Parametric.Driver.field (← Parametric.Driver.field (← mkAppM ``St.cell? #[s,cell]) ``Option.some 2 1) ``Option.some 2 1
    let owner ← Parametric.Driver.field value ``Val.obj 1 0
    for (tag,value) in [("F",f),("input",s),("output",t),("sourceName",key),("sourceEnv",env),
      ("sourceRhs",rhs),("sourceCell",cell),("sourceOwner",owner)] do
      Parametric.Driver.addData (pre ++ Name.mkSimple tag) value (if tag == "input" || tag == "output" then some stateTy else none)
    let initial ← Term.elabTermEnsuringType initial (mkConst ``SSrv)
    let next ← Term.elabTermEnsuringType next (mkConst ``SSrv)
    Parametric.Driver.addData (pre ++ `initialServer) (← mkAppM ``numberServer #[initial])
    Parametric.Driver.addData (pre ++ `nextServer) (← mkAppM ``numberServer #[next])
  let n := "_root_." ++ pre.toString
  let header := "open Host.Ts Host.Ts.Owned Host.Ts.Owned.Parametric Host.Ts.Owned.Annotated in\n"
  let fact (tag proposition : String) := Parametric.Driver.emit (header ++ s!"theorem {n}.{tag} : {proposition} := by host_kernel_rfl")
  fact "source_control" s!"{n}.input.ctl = .ev (.assign (.log .nullish) (.id {n}.sourceName) {n}.sourceRhs) {n}.sourceEnv"
  fact "source_lookup" s!"lookupEnv {n}.sourceName {n}.sourceEnv = some {n}.sourceCell"
  fact "source_read" s!"{n}.input.heap.get {n}.sourceCell = some (.cell (some (.obj {n}.sourceOwner)))"
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
        RetainedInventory (notes.withRuntime ⟨returnNote (.obj {n}.sourceOwner),
          nullishVariableFrameNote {n}.sourceName {n}.sourceRhs {n}.sourceEnv::notes.runtime.stack,notes.runtime.cells⟩)
          ν₀ ν C₀ C R live {n}.output result ∧ Inst ν₀ {n}.nextServer C₀ := by
      obtain ⟨left,right,post,retained⟩ := inventory.nullish_variable_object_step h {n}.sourceName {n}.sourceRhs {n}.sourceEnv
        {n}.sourceCell {n}.sourceOwner {n}.source_control {n}.source_lookup {n}.source_read
      have source := {n}.source_run C₀
      have same := congrArg Prod.fst (Option.some.inj (left.symm.trans source))
      dsimp only at same
      rw [same] at post retained
      exact ⟨_,source,right,post,retained,pure_step_inst {n}.F ν₀ {n}.initialServer {n}.nextServer C₀
        {n}.input {n}.output inst {n}.source_step source⟩")
end Host.Ts.Owned.Annotated.Driver
