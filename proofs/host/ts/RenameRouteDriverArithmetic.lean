import host.ts.RenameRouteDriver
import host.ts.RenameParametricArithmeticStep
namespace Host.Ts.Owned.Parametric.Driver
open Lean Elab Command Meta

/-- Arithmetic dispatch uses the actual source operands and the common meanings
already carried by the state relation. Source literals may specialize to target
references; the target server extension is returned explicitly. -/
elab "host_transport_arithmetic " f:term ", " s:term " to " t:term " as " name:ident : command => do
  let pre := (← getCurrNamespace) ++ name.getId
  liftTermElabM do
    let f ← Term.elabTermEnsuringType f (mkConst ``Ffi)
    let stateTy := mkApp (mkConst ``St) (mkApp (mkConst ``Ffi.S) f)
    let s ← Term.elabTermEnsuringType s stateTy
    let t ← Term.elabTermEnsuringType t stateTy
    let ctl ← mkAppM ``St.ctl #[s]
    let right ← field (← field ctl ``Ctl.ret 1 0) ``Val.num 1 0
    let stack ← mkAppM ``St.stack #[s]
    let frame ← field stack ``List.cons 3 1
    let tail ← field stack ``List.cons 3 2
    let exprFrame ← whnf (← field frame ``Frame.e 1 0)
    unless exprFrame.isAppOfArity ``ExprF.binR 2 do
      throwError "host_transport_arithmetic: expected binary-right frame"
    let args := exprFrame.getAppArgs
    let op ← whnf args[0]!
    let opName := op.getAppFn.constName!
    let kinds : List (Lean.Name × Lean.Name) := [(``BinOp.add,``ArithmeticKind.add),(``BinOp.sub,``ArithmeticKind.sub),
      (``BinOp.mul,``ArithmeticKind.mul),(``BinOp.div,``ArithmeticKind.div),(``BinOp.mod,``ArithmeticKind.rem),
      (``BinOp.band,``ArithmeticKind.band),(``BinOp.bor,``ArithmeticKind.bor),(``BinOp.bxor,``ArithmeticKind.bxor),
      (``BinOp.shl,``ArithmeticKind.shl),(``BinOp.shr,``ArithmeticKind.shr),(``BinOp.ushr,``ArithmeticKind.ushr)]
    let some (_,kind) := kinds.find? (fun (js,_) => js == opName) |
      throwError "host_transport_arithmetic: unsupported operator {opName}"
    let left ← field args[1]! ``Val.num 1 0
    for (tag,value) in [("F",f),("input",s),("output",t),("kind",mkConst kind),
      ("sourceLeft",left),("sourceRight",right),("sourceTail",tail)] do
      let type? := if tag == "input" || tag == "output" then
        some (mkApp (mkConst ``St) (mkApp (mkConst ``Ffi.S) (mkConst (pre ++ `F)))) else none
      addData (pre ++ Name.mkSimple tag) value type?
  let n := "_root_." ++ pre.toString
  let header := "open Host.Ts Host.Ts.Owned Host.Ts.Owned.Parametric in\n"
  emit (header ++ s!"theorem {n}.source_control : {n}.input.ctl = .ret (.num {n}.sourceRight) := by host_kernel_rfl")
  emit (header ++ s!"theorem {n}.source_frame : {n}.input.stack = .e (.binR {n}.kind.jsOp (.num {n}.sourceLeft)) :: {n}.sourceTail := by host_kernel_rfl")
  emit (header ++ s!"theorem {n}.source_run (C₀ : CSrv) : interpC (step {n}.F {n}.input).run C₀ = some ({n}.output,C₀) := by host_kernel_rfl")
  emit (header ++ s!"theorem {n}.transport
      (FR : Ren → {n}.F.S → {n}.F.S → Prop) (R : Ren) (ν₀ ν : Nat → F64) (C₀ C : CSrv)
      (live framed : Nat → Prop) (before after : List Val) (old old' : List Event)
      (s : St {n}.F.S)
      (h : StateR (NumberRoles ν₀ ν C₀ C) FR R live framed before after old old' {n}.input s) :
      ∃ (result : St {n}.F.S) (D : CSrv), interpC (step {n}.F s).run C = some (result,D) ∧
        StateR (NumberRoles ν₀ ν C₀ D) FR R live framed before after old old' {n}.output result ∧
        TableExtends C D := by
    obtain ⟨ea,eb,v₀,D₀,v,D,fs,hr₀,hr,_,hpost,_,he⟩ := step_arithmetic_from_source {n}.F FR R
      ν₀ ν C₀ C live framed before after old old' {n}.input s h {n}.kind
      {n}.sourceLeft {n}.sourceRight {n}.sourceTail {n}.source_control {n}.source_frame
    rw [{n}.source_run] at hr₀
    have hp := Option.some.inj hr₀
    have hd := congrArg Prod.snd hp
    dsimp only at hd
    subst D₀
    have hs := congrArg Prod.fst hp
    dsimp only at hs
    rw [← hs] at hpost
    exact ⟨_,D,hr,hpost,he⟩")
end Host.Ts.Owned.Parametric.Driver
