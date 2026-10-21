import host.sim.template.clear.Run
import host.sim.template.clear.NShift
import host.sim.template.clear.Facts
import host.sim.LoopInv
set_option Elab.async false
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template
set_option maxRecDepth 1000000
set_option maxHeartbeats 0

/-! Case `CLEAR` as a checked loop case (`Host.Ts.Sim.LoopCase`): the checked run
(`CLEAR.okRun`), the shifts (`CLEAR.shiftJS`, `CLEAR.nshift`) and the facts
(`host.sim.template.clear.Facts`). -/

kernel_rfl CLEAR.ok0 : ok Base.s0 CLEAR.S0 = true

noncomputable def CLEAR.loopCase : LoopCase ok loadP0 Base.s0 Base.S0.tab loopFix where
  S0 := CLEAR.S0
  n := CLEAR.steps
  s1 := CLEAR.s150
  S1 := CLEAR.S150
  σ := CLEAR.σ
  θ := CLEAR.θ
  grow := false
  xs := CLEAR.xs
  tab := CLEAR.S0_tab
  ok0 := CLEAR.ok0
  run := CLEAR.okRun
  ctl := CLEAR.ctl_notRet
  noVarTab := CLEAR.noVarTab
  noVarOr := CLEAR.noVarOr
  shiftJS := fun p1 p2 K hfr hlo hhi => CLEAR.shiftJS p1 p2 K hfr hlo hhi
  nshift := CLEAR.nshift
  num79 := CLEAR.num79
  hE := CLEAR.hE
  theta := CLEAR.theta
  fwd := CLEAR.fwd
  emit := CLEAR.emit
  fix := CLEAR.fix

end Host.Load.Run.Tpl
