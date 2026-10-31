import host.sim.template.a4dec_grow.st1.Run
import host.sim.StageRel
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! Stage `DEC_grow.st1` (fwd: `#2671709`) as a stage template: the isolated call state `DEC_grow.st1.s0`, the checked
local run (`DEC_grow.st1.run`, 1517499 steps with `DEC_grow.st1.okL`) to `DEC_grow.st1.s152` and the return step (`DEC_grow.st1.last`)
to `DEC_grow.st1.s153`. Its variables (the stage specs' map): `0` T, `9` o, `10` k, `11` k, `12` k, `13` kp, `14` t1, `16` cap. -/

kernel_rfl DEC_grow.st1.ok0 : DEC_grow.st1.okL DEC_grow.st1.s0 DEC_grow.st1.S0 = true
kernel_rfl DEC_grow.st1.ok1 : DEC_grow.st1.okL DEC_grow.st1.s152 DEC_grow.st1.S152 = true
kernel_rfl DEC_grow.st1.halt1 : isHalt DEC_grow.st1.s152.ctl = false
kernel_rfl DEC_grow.st1.top_check : noBlockTop DEC_grow.st1.s153.stack = true

theorem DEC_grow.st1.loc : ∀ s Sv, DEC_grow.st1.okL s Sv = true → Disp.localB s = true := okLocal_localB

/-- The stage template. -/
noncomputable def DEC_grow.st1.tpl : Host.Ts.Sim.Stage.StageTpl DEC_grow.st1.F DEC_grow.st1.okL where
  s0 := DEC_grow.st1.s0
  S0 := DEC_grow.st1.S0
  s1 := DEC_grow.st1.s152
  S1 := DEC_grow.st1.S152
  s2 := DEC_grow.st1.s153
  S2 := DEC_grow.st1.S153
  n := 1517499
  ok0 := DEC_grow.st1.ok0
  run := DEC_grow.st1.run
  ok1 := DEC_grow.st1.ok1
  halt := DEC_grow.st1.halt1
  last := DEC_grow.st1.last
  top := noBlockTop_sound DEC_grow.st1.top_check

end Host.Load.Run.Tpl
