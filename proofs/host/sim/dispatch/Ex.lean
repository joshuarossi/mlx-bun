import host.sim.dispatch.DecideStmt
namespace Host.Ts.Sim.Disp
open Host.Ts Host.Ts.Sim Host.Ts.Sim.StmtSim

/-! # Dispatch of `.ex st env`

Every statement form has a step lemma except `enum` declarations. -/

section
variable {F : Ffi} {FR : Map → Nat → F.S → F.S → Prop} {W : Nat → Option WFrame} {stk : List Frame} {M : Map} {ν : Nat → F64} {K : Ctx}
  {s t : St F.S} {S : SSrv} {C : CSrv}

def okEx (s : St F.S) (st : Stmt) : Bool :=
  match st with
  | .block ss => blockB s ss
  | .try_ b _ _ => blockB s b
  | .switch _ cs => blockB s (caseStmts cs)
  | .for_ init _ _ _ => forInitB init
  | .labeled _ st => Nat.ble (loopDecls 8 st).length two20
  | .enum _ _ _ => false
  | _ => true

theorem simEx (h : RelB F FR W stk M ν K s S t C) {st : Stmt} {env : Env} (hc : s.ctl = .ex st env)
    (hn : s.next + margin < Sim.bound) (hok : okEx s st = true) :
    MSim (PX F FR W stk M ν K S C) S C (step F s) (step F t) := by
  cases st with
  | expr e => exact MSim.toX (step_ex_expr h hc)
  | decl kind ds => exact MSim.toX (step_ex_decl h hc)
  | func f => exact MSim.toX (step_ex_func h hc)
  | cls c => exact MSim.toX (step_ex_cls h hc)
  | enum _ _ _ => simp [okEx] at hok
  | ret e => exact MSim.toX (step_ex_ret h hc)
  | if_ c a b => exact MSim.toX (step_ex_if h hc)
  | block ss =>
    have hb := blockB_sound hok
    exact MSim.toX (step_ex_block h hc hn hb.1 hb.2)
  | for_ init test update body => exact MSim.toX (step_ex_for h hc hn (forInitB_sound hok))
  | forOf aw kind p e body => exact MSim.toX (step_ex_forOf h hc)
  | forIn kind p e body => exact MSim.toX (step_ex_forIn h hc)
  | while_ c body => exact MSim.toX (step_ex_while h hc)
  | doWhile body c => exact MSim.toX (step_ex_doWhile h hc)
  | switch d cs =>
    have hb := blockB_sound hok
    exact MSim.toX (step_ex_switch h hc hn hb.1 hb.2)
  | try_ b hd fin =>
    have hb := blockB_sound hok
    exact MSim.toX (step_ex_try h hc hn hb.1 hb.2)
  | throw e => exact MSim.toX (step_ex_throw h hc)
  | «break» l => exact MSim.toX (step_ex_break h hc)
  | «continue» l => exact MSim.toX (step_ex_continue h hc)
  | labeled l st => exact MSim.toX (step_ex_labeled h hc hn (le20 hok))
  | empty => exact MSim.toX (step_ex_empty h hc)

end
end Host.Ts.Sim.Disp
