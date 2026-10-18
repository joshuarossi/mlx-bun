import host.ts.RenameRouteDriver
import host.ts.RenameParametricTests

namespace Host.Ts.Owned.Parametric.Driver
open Lean Elab Command Meta

/-- A literal loop comparison derives its guard from the checked operands.
Both operand occurrences are supplied by preceding source operations. -/
elab "host_transport_fixed_lt " f:term ", " s:term " to " t:term " as " name:ident : command => do
  let pre := (← getCurrNamespace) ++ name.getId
  liftTermElabM do
    let f ← Term.elabTermEnsuringType f (mkConst ``Ffi)
    let stateTy := mkApp (mkConst ``St) (mkApp (mkConst ``Ffi.S) f)
    let s ← Term.elabTermEnsuringType s stateTy
    let t ← Term.elabTermEnsuringType t stateTy
    for (tag,value) in [("F",f),("input",s),("output",t)] do
      addData (pre ++ Name.mkSimple tag) value (if tag == "F" then none else some stateTy)
    let add (tag : String) (value : Lean.Expr) := addData (pre ++ Name.mkSimple tag) value
    let right ← field (← field (← mkAppM ``St.ctl #[s]) ``Ctl.ret 1 0) ``Val.num 1 0
    add "sourceRight" (← field right ``NumV.lit 1 0)
    let stack ← mkAppM ``St.stack #[s]
    add "sourceTail" (← field stack ``List.cons 3 2)
    let ef ← field (← field stack ``List.cons 3 1) ``Frame.e 1 0
    let left ← field (← field ef ``ExprF.binR 2 1) ``Val.num 1 0
    add "sourceLeft" (← field left ``NumV.lit 1 0)
    add "sourceGuard" (← field (← mkAppM ``St.ctl #[t] >>= fun c => field c ``Ctl.ret 1 0) ``Val.bool 1 0)
  let n := "_root_." ++ pre.toString
  let header := "open Host.Ts Host.Ts.Owned Host.Ts.Owned.Parametric in\n"
  let fact (tag proposition : String) := emit (header ++ s!"theorem {n}.{tag} : {proposition} := by host_kernel_rfl")
  fact "source_control" s!"{n}.input.ctl = .ret (.num (.lit {n}.sourceRight))"
  fact "source_frame" s!"{n}.input.stack = .e (.binR .lt (.num (.lit {n}.sourceLeft)))::{n}.sourceTail"
  fact "source_guard" s!"F64.test .lt {n}.sourceLeft {n}.sourceRight = {n}.sourceGuard"
  emit (header ++ s!"theorem {n}.source_run (C₀ : CSrv) : interpC (step {n}.F {n}.input).run C₀ = some ({n}.output,C₀) := by host_kernel_rfl")
  emit (header ++ s!"theorem {n}.transport (FR : Ren → {n}.F.S → {n}.F.S → Prop) (R : Ren)
      (ν₀ ν : Nat → F64) (C₀ C : CSrv) (live framed : Nat → Prop)
      (before after : List Val) (old old' : List Event) (s : St {n}.F.S)
      (h : StateR (NumberRoles ν₀ ν C₀ C) FR R live framed before after old old' {n}.input s)
      (control : s.ctl = .ret (.num (.lit {n}.sourceRight)))
      (frames : ∃ fs, s.stack = .e (.binR .lt (.num (.lit {n}.sourceLeft)))::fs) :
      ∃ result, interpC (step {n}.F s).run C = some (result,C) ∧
        StateR (NumberRoles ν₀ ν C₀ C) FR R live framed before after old old' {n}.output result ∧
        result.ctl = .ret (.bool {n}.sourceGuard) ∧ result.heap = s.heap := by
    obtain ⟨fs,frame⟩ := frames
    obtain ⟨hr₀,hr,hpost⟩ := step_comparison_roles {n}.F FR R ν₀ ν C₀ C live framed before after old old'
      {n}.input s h .lt (.lit {n}.sourceLeft) (.lit {n}.sourceLeft) (.lit {n}.sourceRight) (.lit {n}.sourceRight)
      (.lit {n}.sourceLeft) (.lit {n}.sourceRight) {n}.sourceTail fs
      (NumRole.literal ν₀ ν C₀ C {n}.sourceLeft) (NumRole.literal ν₀ ν C₀ C {n}.sourceRight)
      {n}.source_control control {n}.source_frame frame {n}.sourceGuard {n}.source_guard {n}.source_guard
    rw [{n}.source_run] at hr₀
    have he := congrArg Prod.fst (Option.some.inj hr₀)
    dsimp only at he
    rw [← he] at hpost
    exact ⟨_,hr,hpost,rfl,rfl⟩")

end Host.Ts.Owned.Parametric.Driver
