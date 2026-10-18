import host.ts.RenameRetainedGuardedComparison
import host.ts.RenameRuntimeDriverValues
set_option Elab.async false
namespace Host.Ts.Owned.Annotated.Driver
open Lean Elab Command Meta
open Parametric.Driver

/-- Numeric comparisons consume current operand meanings and a pure semantic
guard. Both source endpoint certificates remain checked by the kernel. -/
elab "host_retained_guarded_comparison " f:term ", " s:term " using " initial:term " to " t:term " using " next:term " as " name:ident : command => do
  let pre := (← getCurrNamespace) ++ name.getId
  liftTermElabM do
    let data (name : Lean.Name) (value : Lean.Expr) (type? : Option Lean.Expr := none) := do
      let value ← instantiateMVars value
      let type ← instantiateMVars (← match type? with | some type => pure type | none => inferType value)
      addData name value (some type)
    let f ← Term.elabTermEnsuringType f (mkConst ``Ffi)
    let stateTy := mkApp (mkConst ``St) (mkApp (mkConst ``Ffi.S) f)
    let s ← Term.elabTermEnsuringType s stateTy
    let t ← Term.elabTermEnsuringType t stateTy
    for (tag,value) in [("F",f),("input",s),("output",t)] do
      data (pre ++ Name.mkSimple tag) value (if tag == "F" then none else
        some (mkApp (mkConst ``St) (mkApp (mkConst ``Ffi.S) (mkConst (pre ++ `F)))))
    let control ← mkAppM ``St.ctl #[s]
    let b ← field (← field control ``Ctl.ret 1 0) ``Val.num 1 0
    let b ← field b ``NumV.lit 1 0
    let stack ← mkAppM ``St.stack #[s]
    let frame ← field (← field stack ``List.cons 3 1) ``Frame.e 1 0
    let op ← whnf (← field frame ``ExprF.binR 2 0)
    let a ← field (← field (← field frame ``ExprF.binR 2 1) ``Val.num 1 0) ``NumV.lit 1 0
    let kind ← if op.isConstOf ``BinOp.lt then pure (mkConst ``Parametric.ComparisonKind.lt)
      else if op.isConstOf ``BinOp.le then pure (mkConst ``Parametric.ComparisonKind.le)
      else if op.isConstOf ``BinOp.seq then pure (mkConst ``Parametric.ComparisonKind.seq)
      else if op.isConstOf ``BinOp.sne then pure (mkConst ``Parametric.ComparisonKind.sne)
      else if op.isConstOf ``BinOp.eq then pure (mkConst ``Parametric.ComparisonKind.eq)
      else if op.isConstOf ``BinOp.ne then pure (mkConst ``Parametric.ComparisonKind.ne)
      else throwError "host_retained_guarded_comparison: unsupported numeric comparison"
    for (tag,value) in [("sourceLeft",a),("sourceRight",b),("kind",kind),("sourceTail",← field stack ``List.cons 3 2)] do
      data (pre ++ Name.mkSimple tag) value
    let initial ← Term.elabTermEnsuringType initial (mkConst ``SSrv)
    let next ← Term.elabTermEnsuringType next (mkConst ``SSrv)
    data (pre ++ `initialServer) (← mkAppM ``numberServer #[initial])
    data (pre ++ `nextServer) (← mkAppM ``numberServer #[next])
  let n := "_root_." ++ pre.toString
  let header := "open Host.Ts Host.Ts.Owned Host.Ts.Owned.Parametric Host.Ts.Owned.Annotated in\n"
  let fact (tag proposition : String) := Parametric.Driver.emit (header ++ s!"theorem {n}.{tag} : {proposition} := by host_kernel_rfl")
  fact "source_control" s!"{n}.input.ctl = .ret (.num (.lit {n}.sourceRight))"
  fact "source_frame" s!"{n}.input.stack = .e (.binR {n}.kind.jsOp (.num (.lit {n}.sourceLeft)))::{n}.sourceTail"
  Parametric.Driver.emit (header ++ s!"theorem {n}.source_run (C : CSrv) : interpC (step {n}.F {n}.input).run C = some ({n}.output,C) := by host_kernel_rfl")
  fact "source_step" s!"interpS (step {n}.F {n}.input).run {n}.initialServer = some ({n}.output,{n}.nextServer)"
  Parametric.Driver.emit (header ++ s!"theorem {n}.retained_transport
      (notes : RetainedNotes) (ν₀ ν : Nat → F64) (C₀ C : CSrv) (R : Ren)
      (FR : Ren → {n}.F.S → {n}.F.S → Prop) (live framed : Nat → Prop)
      (before after : List Val) (old old' : List Event) (s : St {n}.F.S)
      (inst : Inst ν₀ {n}.initialServer C₀)
      (h : Parametric.StateR (NumberRoles ν₀ ν C₀ C) FR R live framed before after old old' {n}.input s)
      (inventory : RetainedInventory notes ν₀ ν C₀ C R live {n}.input s)
      (ea eb : SymE) (leftRole rightRole : Annotated.Value)
      (tail : List Annotated.Tree)
      (controlNote : notes.runtime.control = returnNote rightRole)
      (stackNotes : notes.runtime.stack = binaryRightNote {n}.kind.jsOp leftRole::tail)
      (leftNumeric : NumericRole leftRole ea) (rightNumeric : NumericRole rightRole eb)
      (guard : F64.test {n}.kind.numOp (ea.eval ν) (eb.eval ν) =
        F64.test {n}.kind.numOp {n}.sourceLeft {n}.sourceRight) :
      ∃ result, interpC (step {n}.F {n}.input).run C₀ = some ({n}.output,C₀) ∧
        interpC (step {n}.F s).run C = some (result,C) ∧
        Parametric.StateR (NumberRoles ν₀ ν C₀ C) FR R live framed before after old old' {n}.output result ∧
        RetainedInventory (notes.withRuntime (notes.runtime.binaryResult
          (.bool ({n}.kind.result (F64.test {n}.kind.numOp {n}.sourceLeft {n}.sourceRight))) tail))
          ν₀ ν C₀ C R live {n}.output result ∧ Inst ν₀ {n}.nextServer C₀ := by
      obtain ⟨frames,left,right,post,retained⟩ := inventory.guarded_comparison_step h {n}.kind {n}.sourceLeft {n}.sourceRight
        ea eb leftRole rightRole leftNumeric rightNumeric {n}.sourceTail tail {n}.source_control {n}.source_frame controlNote stackNotes guard
      have source := {n}.source_run C₀
      have same := congrArg Prod.fst (Option.some.inj (left.symm.trans source))
      dsimp only at same
      rw [same] at post retained
      exact ⟨_,source,right,post,retained,pure_step_inst {n}.F ν₀ {n}.initialServer {n}.nextServer C₀
        {n}.input {n}.output inst {n}.source_step source⟩")
end Host.Ts.Owned.Annotated.Driver
