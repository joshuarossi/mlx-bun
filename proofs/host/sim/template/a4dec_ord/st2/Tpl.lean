import host.sim.template.a4dec_ord.st2.Run
import host.sim.StageRel
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! Stage `DEC_ord.st2` (async: `asyncEvalAll`) as a stage template: the isolated call state `DEC_ord.st2.s0`, the checked
local run (`DEC_ord.st2.run`, 184 steps with `DEC_ord.st2.okL`) to `DEC_ord.st2.s1` and the return step (`DEC_ord.st2.last`)
to `DEC_ord.st2.s2`. Its variables (the stage specs' map): `0` T, `9` o, `10` k, `11` k, `12` k, `13` kp, `14` t1, `16` cap. -/

kernel_rfl DEC_ord.st2.ok0 : DEC_ord.st2.okL DEC_ord.st2.s0 DEC_ord.st2.S0 = true
kernel_rfl DEC_ord.st2.ok1 : DEC_ord.st2.okL DEC_ord.st2.s1 DEC_ord.st2.S1 = true
kernel_rfl DEC_ord.st2.halt1 : isHalt DEC_ord.st2.s1.ctl = false
kernel_rfl DEC_ord.st2.top_check : noBlockTop DEC_ord.st2.s2.stack = true

theorem DEC_ord.st2.loc : ∀ s Sv, DEC_ord.st2.okL s Sv = true → Disp.localB s = true := okLocal_localB

/-- The stage template. -/
noncomputable def DEC_ord.st2.tpl : Host.Ts.Sim.Stage.StageTpl DEC_ord.st2.F DEC_ord.st2.okL where
  s0 := DEC_ord.st2.s0
  S0 := DEC_ord.st2.S0
  s1 := DEC_ord.st2.s1
  S1 := DEC_ord.st2.S1
  s2 := DEC_ord.st2.s2
  S2 := DEC_ord.st2.S2
  n := 184
  ok0 := DEC_ord.st2.ok0
  run := DEC_ord.st2.run
  ok1 := DEC_ord.st2.ok1
  halt := DEC_ord.st2.halt1
  last := DEC_ord.st2.last
  top := noBlockTop_sound DEC_ord.st2.top_check

end Host.Load.Run.Tpl
