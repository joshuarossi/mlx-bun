import host.sim.template.a4dec_clearFill.st1.Run
import host.sim.StageRel
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! Stage `DEC_clearFill.st1` (fwd: `#2671709`) as a stage template: the isolated call state `DEC_clearFill.st1.s0`, the checked
local run (`DEC_clearFill.st1.run`, 1487659 steps with `DEC_clearFill.st1.okL`) to `DEC_clearFill.st1.s149` and the return step (`DEC_clearFill.st1.last`)
to `DEC_clearFill.st1.s150`. Its variables (the stage specs' map): `0` T, `9` o, `10` k, `11` k, `12` k, `13` kp, `14` t1, `16` cap. -/

kernel_rfl DEC_clearFill.st1.ok0 : DEC_clearFill.st1.okL DEC_clearFill.st1.s0 DEC_clearFill.st1.S0 = true
kernel_rfl DEC_clearFill.st1.ok1 : DEC_clearFill.st1.okL DEC_clearFill.st1.s149 DEC_clearFill.st1.S149 = true
kernel_rfl DEC_clearFill.st1.halt1 : isHalt DEC_clearFill.st1.s149.ctl = false
kernel_rfl DEC_clearFill.st1.top_check : noBlockTop DEC_clearFill.st1.s150.stack = true

theorem DEC_clearFill.st1.loc : ∀ s Sv, DEC_clearFill.st1.okL s Sv = true → Disp.localB s = true := okLocal_localB

/-- The stage template. -/
noncomputable def DEC_clearFill.st1.tpl : Host.Ts.Sim.Stage.StageTpl DEC_clearFill.st1.F DEC_clearFill.st1.okL where
  s0 := DEC_clearFill.st1.s0
  S0 := DEC_clearFill.st1.S0
  s1 := DEC_clearFill.st1.s149
  S1 := DEC_clearFill.st1.S149
  s2 := DEC_clearFill.st1.s150
  S2 := DEC_clearFill.st1.S150
  n := 1487659
  ok0 := DEC_clearFill.st1.ok0
  run := DEC_clearFill.st1.run
  ok1 := DEC_clearFill.st1.ok1
  halt := DEC_clearFill.st1.halt1
  last := DEC_clearFill.st1.last
  top := noBlockTop_sound DEC_clearFill.st1.top_check

end Host.Load.Run.Tpl
