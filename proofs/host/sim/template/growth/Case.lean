import host.sim.template.growth.Run
import host.sim.template.growth.NShift
import host.sim.template.growth.Facts
import host.sim.LoopInv
set_option Elab.async false
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template
set_option maxRecDepth 1000000
set_option maxHeartbeats 0

/-! Case `GROWTH` as a checked loop case (`Host.Ts.Sim.LoopCase`): the checked run
(`GROWTH.okRun`), the shifts (`GROWTH.shiftJS`, `GROWTH.nshift`) and the facts
(`host.sim.template.growth.Facts`). -/

kernel_rfl GROWTH.ok0 : ok Base.s0 GROWTH.S0 = true

noncomputable def GROWTH.loopCase : LoopCase ok loadP0 Base.s0 Base.S0.tab loopFix where
  S0 := GROWTH.S0
  n := GROWTH.steps
  s1 := GROWTH.s153
  S1 := GROWTH.S153
  σ := GROWTH.σ
  θ := GROWTH.θ
  grow := true
  xs := GROWTH.xs
  tab := GROWTH.S0_tab
  ok0 := GROWTH.ok0
  run := GROWTH.okRun
  ctl := GROWTH.ctl_notRet
  noVarTab := GROWTH.noVarTab
  noVarOr := GROWTH.noVarOr
  shiftJS := fun p1 p2 K hfr hlo hhi => GROWTH.shiftJS p1 p2 K hfr hlo hhi
  nshift := GROWTH.nshift
  num79 := GROWTH.num79
  hE := GROWTH.hE
  theta := GROWTH.theta
  fwd := GROWTH.fwd
  emit := GROWTH.emit
  fix := GROWTH.fix

end Host.Load.Run.Tpl
