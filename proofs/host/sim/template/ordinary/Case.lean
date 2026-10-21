import host.sim.template.ordinary.Run
import host.sim.template.ordinary.NShift
import host.sim.template.ordinary.Facts
import host.sim.LoopInv
set_option Elab.async false
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template
set_option maxRecDepth 1000000
set_option maxHeartbeats 0

/-! Case `ORDINARY` as a checked loop case (`Host.Ts.Sim.LoopCase`): the checked run
(`ORDINARY.okRun`), the shifts (`ORDINARY.shiftJS`, `ORDINARY.nshift`) and the facts
(`host.sim.template.ordinary.Facts`). -/

kernel_rfl ORDINARY.ok0 : ok Base.s0 ORDINARY.S0 = true

noncomputable def ORDINARY.loopCase : LoopCase ok loadP0 Base.s0 Base.S0.tab loopFix where
  S0 := ORDINARY.S0
  n := ORDINARY.steps
  s1 := ORDINARY.s150
  S1 := ORDINARY.S150
  σ := ORDINARY.σ
  θ := ORDINARY.θ
  grow := false
  xs := ORDINARY.xs
  tab := ORDINARY.S0_tab
  ok0 := ORDINARY.ok0
  run := ORDINARY.okRun
  ctl := ORDINARY.ctl_notRet
  noVarTab := ORDINARY.noVarTab
  noVarOr := ORDINARY.noVarOr
  shiftJS := fun p1 p2 K hfr hlo hhi => ORDINARY.shiftJS p1 p2 K hfr hlo hhi
  nshift := ORDINARY.nshift
  num79 := ORDINARY.num79
  hE := ORDINARY.hE
  theta := ORDINARY.theta
  fwd := ORDINARY.fwd
  emit := ORDINARY.emit
  fix := ORDINARY.fix

end Host.Load.Run.Tpl
