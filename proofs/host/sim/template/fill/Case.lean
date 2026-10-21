import host.sim.template.fill.Run
import host.sim.template.fill.NShift
import host.sim.template.fill.Facts
import host.sim.LoopInv
set_option Elab.async false
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template
set_option maxRecDepth 1000000
set_option maxHeartbeats 0

/-! Case `FILL` as a checked loop case (`Host.Ts.Sim.LoopCase`): the checked run
(`FILL.okRun`), the shifts (`FILL.shiftJS`, `FILL.nshift`) and the facts
(`host.sim.template.fill.Facts`). -/

kernel_rfl FILL.ok0 : ok Base.s0 FILL.S0 = true

noncomputable def FILL.loopCase : LoopCase ok loadP0 Base.s0 Base.S0.tab loopFix where
  S0 := FILL.S0
  n := FILL.steps
  s1 := FILL.s150
  S1 := FILL.S150
  σ := FILL.σ
  θ := FILL.θ
  grow := false
  xs := FILL.xs
  tab := FILL.S0_tab
  ok0 := FILL.ok0
  run := FILL.okRun
  ctl := FILL.ctl_notRet
  noVarTab := FILL.noVarTab
  noVarOr := FILL.noVarOr
  shiftJS := fun p1 p2 K hfr hlo hhi => FILL.shiftJS p1 p2 K hfr hlo hhi
  nshift := FILL.nshift
  num79 := FILL.num79
  hE := FILL.hE
  theta := FILL.theta
  fwd := FILL.fwd
  emit := FILL.emit
  fix := FILL.fix

end Host.Load.Run.Tpl
